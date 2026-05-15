'use strict';

/**
 * SeerBit Service — CAP Service Handler
 *
 * Implements all actions defined in seerbit-service.cds.
 * Orchestrates S/4HANA data fetching and SeerBit API calls,
 * mirroring the logic in the BC AL codeunits:
 *
 *   BC Codeunit                              → This handler
 *   SBPSendPostedSalesInvoice                → sendBillingDocument / sendSalesOrder
 *   SBPSendInvoicesWithAuthHeader            → sendBulkBillingDocuments
 *   SBPSeerBitGlobalCodeunit                 → _getConfig()
 *   SBPSendPostedSalesInvoice.validatepayment → validatePayment
 */

const cds     = require('@sap/cds');
const seerbit = require('./lib/seerbit-client');
const s4      = require('./lib/s4-connector');
const s4Journal = require('./lib/s4-journal-client');

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const ALLOWED_VA_STATUS = new Set(['ACTIVE', 'INACTIVE']);

module.exports = cds.service.impl(async function (srv) {

  const {
    Invoices,
    InvoiceItems,
    Configuration,
    VirtualAccounts,
    VirtualAccountPayments
  } = srv.entities;

  // =========================================================================
  // Unbound Actions
  // =========================================================================

  /**
   * Send a single SAP billing document (Customer Invoice) to SeerBit.
   * Mirrors: SBPSendPostedSalesInvoice.sendToAPI() with actionType = "Create"
   */
  srv.on('sendBillingDocument', async req => {
    const { billingDocumentID, configID } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    // 1. Fetch document from S/4HANA
    let header, items;
    try {
      ({ header, items } = await s4.getBillingDocument(billingDocumentID));
    } catch (err) {
      req.error(502, `Failed to fetch billing document ${billingDocumentID}: ${err.message}`);
      return;
    }

    if (!header) {
      req.error(404, `Billing document ${billingDocumentID} not found in S/4HANA`);
      return;
    }

    // 2. Resolve customer email & name (Business Partner / OData)
    //    In a full deployment wire this to API_BUSINESS_PARTNER_SRV
    const customerInfo = _extractCustomerInfo(header);

    // 3. Shape payload
    const payload = s4.shapeBillingDocumentPayload(
      header, items, customerInfo, config.CompanyName
    );

    // 4. Call SeerBit
    return _sendAndPersist(payload, config, billingDocumentID, req);
  });

  /**
   * Send a single SAP sales order to SeerBit.
   */
  srv.on('sendSalesOrder', async req => {
    const { salesOrderID, configID } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    let header, items;
    try {
      ({ header, items } = await s4.getSalesOrder(salesOrderID));
    } catch (err) {
      req.error(502, `Failed to fetch sales order ${salesOrderID}: ${err.message}`);
      return;
    }

    if (!header) {
      req.error(404, `Sales order ${salesOrderID} not found in S/4HANA`);
      return;
    }

    const customerInfo = _extractCustomerInfo(header);
    const payload = s4.shapeSalesOrderPayload(
      header, items, customerInfo, config.CompanyName
    );

    return _sendAndPersist(payload, config, salesOrderID, req);
  });

  /**
   * Bulk send: multiple billing documents in one SeerBit request.
   * Mirrors: SBPSendInvoicesWithAuthHeader.SendSelectedInvoicesWithAuthHeader()
   */
  srv.on('sendBulkBillingDocuments', async req => {
    const { billingDocumentIDs, configID } = req.data;

    if (!billingDocumentIDs?.length) {
      req.error(400, 'billingDocumentIDs must be a non-empty array');
      return;
    }

    const config = await _getConfig(configID, req);
    if (!config) return;

    // Fetch all documents in parallel
    const results = await Promise.allSettled(
      billingDocumentIDs.map(id => s4.getBillingDocument(id))
    );

    const payloads  = [];
    const errors    = [];

    for (let i = 0; i < results.length; i++) {
      const result = results[i];
      if (result.status === 'fulfilled' && result.value.header) {
        const { header, items } = result.value;
        const customerInfo = _extractCustomerInfo(header);
        payloads.push(
          s4.shapeBillingDocumentPayload(header, items, customerInfo, config.CompanyName)
        );
      } else {
        errors.push(
          `${billingDocumentIDs[i]}: ${result.reason?.message || 'not found'}`
        );
      }
    }

    if (!payloads.length) {
      return {
        success: false, sentCount: 0,
        failedCount: errors.length, message: 'No valid documents to send', errors
      };
    }

    // Call SeerBit bulk endpoint
    let seerBitResponse;
    try {
      seerBitResponse = await seerbit.sendBulkInvoices(
        config.PublicKey, config.SecretKey, payloads
      );
    } catch (err) {
      req.error(502, `SeerBit bulk send failed: ${err.message}`);
      return;
    }

    // Persist each sent record
    const db = cds.db;
    await Promise.allSettled(
      payloads.map(p =>
        db.run(
          INSERT.into(Invoices).entries({
            SeerBitInvoiceNumber: p.orderNo, // will be updated if API returns one
            S4InvoiceNumber:      p.orderNo,
            OrderNumber:          p.orderNo,
            Status:               'OPEN',
            SentToSeerBit:        true,
            TotalAmount:          p.invoiceItems.reduce((s, i) => s + (i.rate * i.quantity), 0),
            Currency:             p.currency,
            CustomerEmail:        p.customerEmail,
            ReceiversName:        p.receiversName,
            CompanyName:          p.companyName,
            DueDate:              p.dueDate,
            SentAt:               new Date().toISOString()
          })
        )
      )
    );

    return {
      success:      true,
      sentCount:    payloads.length,
      failedCount:  errors.length,
      message:      `Sent ${payloads.length} invoice(s) to SeerBit`,
      errors
    };
  });

  /**
   * Validate payment for a SeerBit invoice.
   * Mirrors: SBPSendPostedSalesInvoice.validatepayment()
   */
  srv.on('validatePayment', async req => {
    const { seerBitInvoiceNumber, transactionReference } = req.data;

    const db = cds.db;
    const record = await db.run(
      SELECT.one.from(Invoices).where({ SeerBitInvoiceNumber: seerBitInvoiceNumber })
    );

    if (!record) {
      req.error(404, `Invoice ${seerBitInvoiceNumber} not found`);
      return;
    }

    await db.run(
      UPDATE(Invoices)
        .set({
          Status:               'VERIFIED',
          Paid:                 true,
          TransactionReference: transactionReference,
          PaidAt:               new Date().toISOString()
        })
        .where({ SeerBitInvoiceNumber: seerBitInvoiceNumber })
    );

    return { success: true, message: `Invoice ${seerBitInvoiceNumber} marked as Verified` };
  });

  /**
   * Test SeerBit credentials by fetching an auth token.
   */
  srv.on('testConnection', async req => {
    const { configID } = req.data;
    const config = await _getConfig(configID, req);
    if (!config) return;

    try {
      await seerbit.getEncryptedToken(config.PublicKey, config.SecretKey);
      return { success: true, message: 'SeerBit credentials are valid — token obtained successfully' };
    } catch (err) {
      return { success: false, message: `SeerBit auth failed: ${err.message}` };
    }
  });

  /**
   * Create a virtual account in SeerBit and persist returned account details.
   * Mirrors: VirtualAccountPage actionType='Create'
   */
  srv.on('createVirtualAccount', async req => {
    const { virtualAccountID, configID } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: virtualAccountID })
    );
    if (!va) {
      req.error(404, `Virtual account record ${virtualAccountID} not found`);
      return;
    }

    if (!_isNonEmptyString(va.FullName) || !_isValidEmail(va.Email)) {
      req.error(400, 'Virtual account record must contain a valid FullName and Email before create');
      return;
    }
    if (!_isValidBVN(va.BankVerificationNo)) {
      req.error(400, 'BankVerificationNo must be 11 digits when provided');
      return;
    }

    let apiResponse;
    try {
      apiResponse = await seerbit.createVirtualAccount({
        publicKey: config.PublicKey,
        secretKey: config.SecretKey,
        fullName: va.FullName,
        bankVerificationNumber: va.BankVerificationNo || '',
        country: va.Country || 'NG',
        currency: va.Currency || 'NGN',
        email: va.Email,
        status: _normalizeVAStatus(va.Status),
        reference: va.Reference
      });
    } catch (err) {
      await _setVAError(virtualAccountID, err.message);
      req.error(502, `Virtual account create failed: ${err.message}`);
      return;
    }

    const out = _extractVirtualAccountResponse(apiResponse);
    if (!out.ok) {
      await _setVAError(virtualAccountID, out.message);
      return {
        success: false,
        accountNumber: '',
        reference: va.Reference || '',
        status: 'ERROR',
        message: out.message
      };
    }

    await cds.db.run(
      UPDATE(VirtualAccounts)
        .set({
          PublicKey: out.publicKey || config.PublicKey,
          AccountNumber: out.accountNumber,
          Code: out.code,
          BankName: out.bankName,
          WalletName: out.walletName,
          Reference: out.reference || va.Reference,
          Wallet: out.wallet,
          Status: _normalizeVAStatus(out.status),
          LastSyncStatus: 'SUCCESS',
          LastSyncMessage: out.message.slice(0, 500),
          LastErrorMessage: null
        })
        .where({ ID: virtualAccountID })
    );

    return {
      success: true,
      accountNumber: out.accountNumber,
      reference: out.reference || '',
      status: _normalizeVAStatus(out.status),
      message: `Virtual account ${out.accountNumber} created successfully`
    };
  });

  /**
   * Update a virtual account in SeerBit.
   */
  srv.on('updateVirtualAccount', async req => {
    const { virtualAccountID, configID } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: virtualAccountID })
    );
    if (!va) {
      req.error(404, `Virtual account record ${virtualAccountID} not found`);
      return;
    }

    if (!_isNonEmptyString(va.FullName) || !_isValidEmail(va.Email)) {
      req.error(400, 'Virtual account record must contain a valid FullName and Email before update');
      return;
    }
    if (!_isValidBVN(va.BankVerificationNo)) {
      req.error(400, 'BankVerificationNo must be 11 digits when provided');
      return;
    }

    let apiResponse;
    try {
      apiResponse = await seerbit.updateVirtualAccount({
        publicKey: config.PublicKey,
        secretKey: config.SecretKey,
        fullName: va.FullName,
        bankVerificationNumber: va.BankVerificationNo || '',
        country: va.Country || 'NG',
        currency: va.Currency || 'NGN',
        email: va.Email,
        status: _normalizeVAStatus(va.Status),
        reference: va.Reference
      });
    } catch (err) {
      await _setVAError(virtualAccountID, err.message);
      req.error(502, `Virtual account update failed: ${err.message}`);
      return;
    }

    const out = _extractVirtualAccountResponse(apiResponse);
    if (!out.ok) {
      await _setVAError(virtualAccountID, out.message);
      return {
        success: false,
        accountNumber: va.AccountNumber || '',
        reference: va.Reference || '',
        status: 'ERROR',
        message: out.message
      };
    }

    await cds.db.run(
      UPDATE(VirtualAccounts)
        .set({
          PublicKey: out.publicKey || config.PublicKey,
          AccountNumber: out.accountNumber || va.AccountNumber,
          Code: out.code || va.Code,
          BankName: out.bankName || va.BankName,
          WalletName: out.walletName || va.WalletName,
          Reference: out.reference || va.Reference,
          Wallet: out.wallet || va.Wallet,
          Status: _normalizeVAStatus(out.status || va.Status),
          LastSyncStatus: 'SUCCESS',
          LastSyncMessage: out.message.slice(0, 500),
          LastErrorMessage: null
        })
        .where({ ID: virtualAccountID })
    );

    return {
      success: true,
      accountNumber: out.accountNumber || va.AccountNumber || '',
      reference: out.reference || va.Reference || '',
      status: _normalizeVAStatus(out.status || va.Status),
      message: 'Virtual account updated successfully'
    };
  });

  /**
   * Retrieve payments for a virtual account and persist new records.
   * Mirrors: VirtualAccountPage actionType='Verify'
   */
  srv.on('retrieveVirtualAccountPayments', async req => {
    const { virtualAccountID, configID } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: virtualAccountID })
    );
    if (!va) {
      req.error(404, `Virtual account record ${virtualAccountID} not found`);
      return;
    }

    if (!va.AccountNumber) {
      req.error(400, 'Virtual account has no AccountNumber yet. Create it first.');
      return;
    }

    return _retrieveAndPersistVirtualAccountPayments(va, config, req);
  });

  // =========================================================================
  // Bound Actions on Invoices entity
  // =========================================================================

  /**
   * Refresh invoice status from SeerBit.
   * Mirrors: SBPSendPostedSalesInvoice.sendToAPI() with actionType = "Get invoice by InvoiceNo"
   */
  srv.on('refreshStatus', Invoices, async req => {
    const invoice = await cds.db.run(
      SELECT.one.from(Invoices).where({ SeerBitInvoiceNumber: req.params[0].SeerBitInvoiceNumber })
    );

    if (!invoice) {
      req.error(404, 'Invoice not found');
      return;
    }

    // Find active config
    const config = await cds.db.run(
      SELECT.one.from(Configuration).where({ IsActive: true })
    );
    if (!config) {
      req.error(409, 'No active SeerBit configuration found. Set up your API keys first.');
      return;
    }

    let seerBitResponse;
    try {
      seerBitResponse = await seerbit.getInvoiceByInvoiceNo({
        publicKey:    config.PublicKey,
        secretKey:    config.SecretKey,
        invoiceNo:    invoice.SeerBitInvoiceNumber,
        orderNo:      invoice.OrderNumber,
        customerEmail: invoice.CustomerEmail
      });
    } catch (err) {
      req.error(502, `SeerBit status check failed: ${err.message}`);
      return;
    }

    const status = seerBitResponse?.payload?.status || invoice.Status;
    const paid   = status === 'PAID';

    await cds.db.run(
      UPDATE(Invoices)
        .set({ Status: status, Paid: paid, ...(paid ? { PaidAt: new Date().toISOString() } : {}) })
        .where({ SeerBitInvoiceNumber: invoice.SeerBitInvoiceNumber })
    );

    return { success: true, status, paid, message: `Status updated to ${status}` };
  });

  /**
   * Resend invoice email via SeerBit.
   * Mirrors: SBPSendPostedSalesInvoice.sendToAPI() with actionType = "Re-send an Invoice"
   */
  srv.on('resend', Invoices, async req => {
    const invoice = await cds.db.run(
      SELECT.one.from(Invoices).where({ SeerBitInvoiceNumber: req.params[0].SeerBitInvoiceNumber })
    );

    if (!invoice) {
      req.error(404, 'Invoice not found');
      return;
    }

    const config = await cds.db.run(
      SELECT.one.from(Configuration).where({ IsActive: true })
    );
    if (!config) {
      req.error(409, 'No active SeerBit configuration found');
      return;
    }

    try {
      await seerbit.resendInvoice({
        publicKey:    config.PublicKey,
        secretKey:    config.SecretKey,
        invoiceNo:    invoice.SeerBitInvoiceNumber,
        orderNo:      invoice.OrderNumber,
        customerEmail: invoice.CustomerEmail
      });
    } catch (err) {
      req.error(502, `SeerBit resend failed: ${err.message}`);
      return;
    }

    await cds.db.run(
      UPDATE(Invoices)
        .set({ Status: 'RESENT' })
        .where({ SeerBitInvoiceNumber: invoice.SeerBitInvoiceNumber })
    );

    return { success: true, message: 'Invoice resent successfully' };
  });

  /**
   * Bound action to sync payments for one virtual account.
   */
  srv.on('syncPayments', VirtualAccounts, async req => {
    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: req.params[0].ID })
    );
    if (!va) {
      req.error(404, 'Virtual account not found');
      return;
    }

    const config = await cds.db.run(
      SELECT.one.from(Configuration).where({ IsActive: true })
    );
    if (!config) {
      req.error(409, 'No active SeerBit configuration found');
      return;
    }

    if (!va.AccountNumber) {
      req.error(400, 'Virtual account has no AccountNumber yet. Create it first.');
      return;
    }

    return _retrieveAndPersistVirtualAccountPayments(va, config, req);
  });

  srv.on('setVirtualAccountStatus', async req => {
    const { virtualAccountID, status, configID } = req.data;

    const normalizedStatus = _normalizeVAStatusForUpdate(status);
    if (!ALLOWED_VA_STATUS.has(normalizedStatus)) {
      req.error(400, `status must be one of: ${Array.from(ALLOWED_VA_STATUS).join(', ')}`);
      return;
    }

    const config = await _getConfig(configID, req);
    if (!config) return;

    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: virtualAccountID })
    );
    if (!va) {
      req.error(404, `Virtual account record ${virtualAccountID} not found`);
      return;
    }

    let apiResponse;
    try {
      apiResponse = await seerbit.updateVirtualAccount({
        publicKey: config.PublicKey,
        secretKey: config.SecretKey,
        fullName: va.FullName,
        bankVerificationNumber: va.BankVerificationNo || '',
        country: va.Country || 'NG',
        currency: va.Currency || 'NGN',
        email: va.Email,
        status: normalizedStatus,
        reference: va.Reference
      });
    } catch (err) {
      await _setVAError(virtualAccountID, err.message);
      req.error(502, `Virtual account status update failed: ${err.message}`);
      return;
    }

    const out = _extractVirtualAccountResponse(apiResponse);
    if (!out.ok) {
      await _setVAError(virtualAccountID, out.message);
      return {
        success: false,
        accountNumber: va.AccountNumber || '',
        reference: va.Reference || '',
        status: 'ERROR',
        message: out.message
      };
    }

    await cds.db.run(
      UPDATE(VirtualAccounts)
        .set({
          Status: normalizedStatus,
          LastSyncStatus: 'SUCCESS',
          LastSyncMessage: out.message.slice(0, 500),
          LastErrorMessage: null
        })
        .where({ ID: virtualAccountID })
    );

    return {
      success: true,
      accountNumber: va.AccountNumber || '',
      reference: va.Reference || '',
      status: normalizedStatus,
      message: `Virtual account status updated to ${normalizedStatus}`
    };
  });

  srv.on('markVirtualAccountPaymentPosted', async req => {
    const { paymentID, s4PostingDocumentNo } = req.data;

    if (!paymentID) {
      req.error(400, 'paymentID is required');
      return;
    }

    const payment = await cds.db.run(
      SELECT.one.from(VirtualAccountPayments).where({ ID: paymentID })
    );
    if (!payment) {
      req.error(404, `Virtual account payment ${paymentID} not found`);
      return;
    }

    await cds.db.run(
      UPDATE(VirtualAccountPayments)
        .set({
          PostedToS4: true,
          S4PostingDocumentNo: (s4PostingDocumentNo || '').slice(0, 35)
        })
        .where({ ID: paymentID })
    );

    return { success: true, message: `Payment ${payment.PaymentReference} marked as posted` };
  });

  srv.on('postVirtualAccountPaymentToS4', async req => {
    const { paymentID, configID, companyCode, documentType } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    const payment = await cds.db.run(
      SELECT.one.from(VirtualAccountPayments).where({ ID: paymentID })
    );
    if (!payment) {
      req.error(404, `Virtual account payment ${paymentID} not found`);
      return;
    }

    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: payment.VirtualAccount_ID })
    );
    if (!va) {
      req.error(404, `Virtual account ${payment.VirtualAccount_ID} not found`);
      return;
    }

    if (payment.PostedToS4) {
      return {
        success: true,
        message: `Payment already posted in S/4 as ${payment.S4PostingDocumentNo || 'document'}`
      };
    }

    return _postPaymentToS4(payment, va, {
      companyCode,
      documentType,
      s4Connection: _resolveS4Connection(config)
    }, req);
  });

  srv.on('postPendingVirtualAccountPaymentsToS4', async req => {
    const { virtualAccountID, configID, companyCode, documentType } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: virtualAccountID })
    );
    if (!va) {
      req.error(404, `Virtual account ${virtualAccountID} not found`);
      return;
    }

    return _postPendingPaymentsForVirtualAccount(va, {
      companyCode,
      documentType,
      s4Connection: _resolveS4Connection(config)
    }, req);
  });

  srv.on('retrieveAndPostVirtualAccountPayments', async req => {
    const { virtualAccountID, configID, companyCode, documentType } = req.data;

    const config = await _getConfig(configID, req);
    if (!config) return;

    const va = await cds.db.run(
      SELECT.one.from(VirtualAccounts).where({ ID: virtualAccountID })
    );
    if (!va) {
      req.error(404, `Virtual account ${virtualAccountID} not found`);
      return;
    }
    if (!va.AccountNumber) {
      req.error(400, 'Virtual account has no AccountNumber yet. Create it first.');
      return;
    }

    const retrieval = await _retrieveAndPersistVirtualAccountPayments(va, config, req);
    if (!retrieval?.success) {
      return {
        success: false,
        fetchedCount: 0,
        newPayments: 0,
        postedCount: 0,
        failedPostingCount: 0,
        message: retrieval?.message || 'Retrieve step failed',
        errors: []
      };
    }

    const posting = await _postPendingPaymentsForVirtualAccount(va, {
      companyCode,
      documentType,
      s4Connection: _resolveS4Connection(config)
    }, req);

    return {
      success: retrieval.success && posting.success,
      fetchedCount: retrieval.totalFetched,
      newPayments: retrieval.newPayments,
      postedCount: posting.sentCount,
      failedPostingCount: posting.failedCount,
      message: `Retrieved ${retrieval.totalFetched} payment(s), posted ${posting.sentCount}, failed ${posting.failedCount}`,
      errors: posting.errors
    };
  });

  // =========================================================================
  // Internal helpers
  // =========================================================================

  /**
   * Load SeerBit config and validate it. Returns null (and sets req.error) if invalid.
   * Mirrors: SBPSeerBitGlobalCodeunit credential accessor.
   */
  async function _getConfig(configID, req) {
    const query = configID
      ? SELECT.one.from(Configuration).where({ ID: configID })
      : SELECT.one.from(Configuration).where({ IsActive: true });

    const config = await cds.db.run(query);

    if (!config) {
      req.error(409, configID
        ? `SeerBit configuration ${configID} not found`
        : 'No active SeerBit configuration found. Go to /seerbit/Configuration to set up your API keys.'
      );
      return null;
    }

    if (!config.PublicKey || !config.SecretKey) {
      req.error(409, 'SeerBit PublicKey and SecretKey must both be configured');
      return null;
    }

    return config;
  }

  function _resolveS4Connection(config) {
    return {
      mode: config.S4SoapMode,
      endpointSync: config.S4SoapEndpointSync,
      endpointAsync: config.S4SoapEndpointAsync,
      user: config.S4SoapUser,
      password: config.S4SoapPassword,
      namespace: config.S4SoapNamespace,
      actionSync: config.S4SoapActionSync,
      actionAsync: config.S4SoapActionAsync,
      timeoutMs: config.S4SoapTimeoutMs,
      companyCode: config.S4CompanyCode,
      documentType: config.S4DocumentType
    };
  }

  function _extractVirtualAccountResponse(apiResponse) {
    const message = String(apiResponse?.message || '');
    const rawStatus = String(apiResponse?.status || apiResponse?.data?.status || '').trim().toUpperCase();
    const status = _normalizeVAStatus(rawStatus);
    const ok = message.toLowerCase().includes('successful')
      || rawStatus === 'SUCCESS'
      || rawStatus === '00'
      || status === 'ACTIVE'
      ;

    const payments = apiResponse?.data?.payments || {};
    return {
      ok,
      message: message || 'Virtual account request failed',
      status,
      code: apiResponse?.data?.code || '',
      accountNumber: payments?.accountNumber || '',
      walletName: payments?.walletName || '',
      bankName: payments?.bankName || '',
      reference: payments?.reference || '',
      wallet: payments?.wallet || '',
      publicKey: apiResponse?.data?.publicKey || ''
    };
  }

  async function _retrieveAndPersistVirtualAccountPayments(va, config, req) {
    let apiResponse;
    try {
      apiResponse = await seerbit.retrieveVirtualAccountPayments({
        publicKey: config.PublicKey,
        secretKey: config.SecretKey,
        accountNumber: va.AccountNumber,
        status: _normalizeVAStatus(va.Status)
      });
    } catch (err) {
      await _setVAError(va.ID, err.message);
      req.error(502, `Retrieve virtual account payments failed: ${err.message}`);
      return;
    }

    const paymentArray = apiResponse?.data?.payload;
    if (!Array.isArray(paymentArray)) {
      await cds.db.run(
        UPDATE(VirtualAccounts)
          .set({
            LastSyncStatus: 'SUCCESS',
            LastSyncMessage: 'No payment payload returned by SeerBit',
            LastErrorMessage: null,
            LastRetrievedAt: new Date().toISOString()
          })
          .where({ ID: va.ID })
      );
      return {
        success: true,
        message: 'No payment payload returned by SeerBit'
      };
    }

    const stats = await _upsertVirtualAccountPayments(va, paymentArray, req);

    await cds.db.run(
      UPDATE(VirtualAccounts)
        .set({
          TotalPayments: stats.totalPayments,
          LastRetrievedAt: new Date().toISOString(),
          LastSyncStatus: 'SUCCESS',
          LastSyncMessage: `Retrieved ${paymentArray.length} payment(s), ${stats.newCount} new`,
          LastErrorMessage: null
        })
        .where({ ID: va.ID })
    );

    return {
      success: true,
      newPayments: stats.newCount,
      totalFetched: paymentArray.length,
      message: `Retrieved ${paymentArray.length} payment(s), ${stats.newCount} new`
    };
  }

  async function _upsertVirtualAccountPayments(va, paymentArray, req) {
    let newCount = 0;
    const tx = cds.tx(req);

    for (const payment of paymentArray) {
      const paymentReference = String(payment.paymentReference || '').trim();
      if (!paymentReference) {
        continue;
      }

      const existing = await tx.run(
        SELECT.one.from(VirtualAccountPayments).where({ PaymentReference: paymentReference })
      );

      const mapped = {
        VirtualAccount_ID: va.ID,
        PaymentReference: paymentReference,
        PaymentLinkID: payment.paymentLinkId || '',
        PaymentLinkReference: payment.paymentLinkId || '',
        FullName: payment.customerName || '',
        CustomerEmail: payment.customerEmail || '',
        Country: payment.country || '',
        Currency: payment.currency || '',
        Amount: Number(payment.amount || 0),
        PaymentDate: payment.paymentDate || payment.createdAt || '',
        Reason: payment.reason || '',
        PaymentStatus: payment.status === 'PUSHED' ? 'SUCCESS' : (payment.status || ''),
        TransactionType: 'VIRTUAL_ACCOUNT',
        AccountNumber: va.AccountNumber || '',
        RawPayload: JSON.stringify(payment)
      };

      if (!existing) {
        await tx.run(INSERT.into(VirtualAccountPayments).entries(mapped));
        newCount += 1;
      } else {
        await tx.run(
          UPDATE(VirtualAccountPayments)
            .set({
              PaymentStatus: mapped.PaymentStatus,
              Amount: mapped.Amount,
              PaymentDate: mapped.PaymentDate,
              Reason: mapped.Reason,
              RawPayload: mapped.RawPayload
            })
            .where({ ID: existing.ID })
        );
      }
    }

    const countRes = await tx.run(
      SELECT.one.from(VirtualAccountPayments)
        .columns`count(1) as count`
        .where({ VirtualAccount_ID: va.ID })
    );

    return {
      newCount,
      totalPayments: Number(countRes?.count || 0)
    };
  }

  async function _setVAError(virtualAccountID, message) {
    await cds.db.run(
      UPDATE(VirtualAccounts)
        .set({
          LastSyncStatus: 'ERROR',
          LastErrorMessage: String(message || '').slice(0, 500),
          LastSyncMessage: null,
          LastRetrievedAt: new Date().toISOString()
        })
        .where({ ID: virtualAccountID })
    );
  }

  async function _postPendingPaymentsForVirtualAccount(va, options, req) {
    const pending = await cds.db.run(
      SELECT.from(VirtualAccountPayments)
        .where({ VirtualAccount_ID: va.ID, PostedToS4: false })
        .orderBy('createdAt asc')
    );

    if (!pending.length) {
      return {
        success: true,
        sentCount: 0,
        failedCount: 0,
        message: 'No unposted virtual account payments found',
        errors: []
      };
    }

    let sentCount = 0;
    let failedCount = 0;
    const errors = [];

    for (const payment of pending) {
      try {
        const res = await _postPaymentToS4(payment, va, options, req);
        if (res?.success) {
          sentCount += 1;
        } else {
          failedCount += 1;
          errors.push(`${payment.PaymentReference}: ${res?.message || 'posting failed'}`);
        }
      } catch (err) {
        failedCount += 1;
        errors.push(`${payment.PaymentReference}: ${err.message}`);
      }
    }

    return {
      success: failedCount === 0,
      sentCount,
      failedCount,
      message: `Posted ${sentCount} payment(s) to S/4, ${failedCount} failed`,
      errors
    };
  }

  async function _postPaymentToS4(payment, va, options, req) {
    const companyCode = String(options.companyCode || options.s4Connection?.companyCode || '').trim();
    const documentType = String(options.documentType || options.s4Connection?.documentType || 'DZ').trim().toUpperCase();

    if (!companyCode || companyCode.length !== 4) {
      req.error(400, 'companyCode is required and must be 4 characters');
      return;
    }
    if (!_isNonEmptyString(va.PaymentAccountNo) || !_isNonEmptyString(va.BalancingAccountNo)) {
      req.error(400, 'Virtual account must have PaymentAccountNo and BalancingAccountNo configured for posting');
      return;
    }

    const amount = Number(payment.Amount || 0);
    if (!(amount > 0)) {
      req.error(400, `Payment amount must be > 0 for payment ${payment.PaymentReference}`);
      return;
    }

    const now = new Date();
    const isoDate = now.toISOString().split('T')[0];

    let posting;
    try {
      posting = await s4Journal.postIncomingPayment({
        companyCode,
        documentType,
        documentDate: isoDate,
        postingDate: isoDate,
        headerText: `SeerBit VA ${payment.PaymentReference}`,
        reference: payment.PaymentReference,
        debitGLAccount: va.PaymentAccountNo,
        customer: va.BalancingAccountNo,
        amount,
        currency: payment.Currency || va.Currency || 'NGN',
        assignmentReference: payment.PaymentReference,
        s4Connection: options.s4Connection
      });
    } catch (err) {
      await cds.db.run(
        UPDATE(VirtualAccountPayments)
          .set({
            PostingAttempts: Number(payment.PostingAttempts || 0) + 1,
            S4PostingError: String(err.message || '').slice(0, 500)
          })
          .where({ ID: payment.ID })
      );

      return {
        success: false,
        message: `S/4 posting failed: ${err.message}`
      };
    }

    await cds.db.run(
      UPDATE(VirtualAccountPayments)
        .set({
          PostedToS4: true,
          S4PostingDocumentNo: String(posting.accountingDocument || '').slice(0, 35),
          S4PostedAt: now.toISOString(),
          S4PostingError: null,
          PostingAttempts: Number(payment.PostingAttempts || 0) + 1
        })
        .where({ ID: payment.ID })
    );

    return {
      success: true,
      message: `Payment ${payment.PaymentReference} posted to S/4 (${posting.accountingDocument || 'created'})`
    };
  }

  function _isValidEmail(value) {
    return _isNonEmptyString(value) && EMAIL_REGEX.test(String(value).trim());
  }

  function _isValidBVN(value) {
    if (!_isNonEmptyString(value)) return true;
    return /^\d{11}$/.test(String(value).trim());
  }

  function _isNonEmptyString(value) {
    return typeof value === 'string' && value.trim().length > 0;
  }

  function _normalizeVAStatus(value) {
    const normalized = String(value || '').trim().toUpperCase();
    if (normalized === 'INACTVE') return 'INACTIVE';
    if (ALLOWED_VA_STATUS.has(normalized)) return normalized;
    return 'ACTIVE';
  }

  function _normalizeVAStatusForUpdate(value) {
    const normalized = String(value || '').trim().toUpperCase();
    if (normalized === 'INACTVE') return 'INACTIVE';
    return normalized;
  }

  /**
   * Extract customer email and name from OData header fields.
   * In production, extend this to call API_BUSINESS_PARTNER_SRV
   * using header.SoldToParty as the business partner ID.
   */
  function _extractCustomerInfo(header) {
    return {
      email: header.CustomerEmail || header.SoldToPartyEmailAddress || '',
      name:  header.SoldToPartyName || header.SoldToParty || ''
    };
  }

  /**
   * Call SeerBit sendInvoice and persist the result in the Invoices table.
   * Used by both sendBillingDocument and sendSalesOrder.
   */
  async function _sendAndPersist(payload, config, s4DocNumber, req) {
    let seerBitResponse;
    try {
      seerBitResponse = await seerbit.sendInvoice({
        publicKey:  config.PublicKey,
        secretKey:  config.SecretKey,
        ...payload
      });
    } catch (err) {
      req.error(502, `SeerBit API error: ${err.message}`);
      return;
    }

    // Check SeerBit response code (BC checks code == "00")
    const responseCode    = seerBitResponse?.code  || seerBitResponse?.status;
    const responsePayload = seerBitResponse?.payload || {};
    const success         = responseCode === '00' || responseCode === 'SUCCESS';

    if (!success) {
      // Persist error record
      await cds.db.run(
        INSERT.into(Invoices).entries({
          SeerBitInvoiceNumber: `ERR-${s4DocNumber}-${Date.now()}`,
          S4InvoiceNumber:      s4DocNumber,
          OrderNumber:          payload.orderNo,
          Status:               'ERROR',
          SentToSeerBit:        false,
          TotalAmount:          payload.invoiceItems.reduce((s, i) => s + (i.rate * i.quantity), 0),
          Currency:             payload.currency,
          CustomerEmail:        payload.customerEmail,
          ReceiversName:        payload.receiversName,
          ErrorMessage:         JSON.stringify(seerBitResponse).substring(0, 500),
          SentAt:               new Date().toISOString()
        })
      );

      return {
        success:             false,
        seerBitInvoiceNumber: '',
        seerBitInvoiceID:    '',
        status:              'ERROR',
        message:             `SeerBit returned code ${responseCode}: ${JSON.stringify(seerBitResponse)}`
      };
    }

    // Persist success record
    const invoiceNumber = responsePayload.InvoiceNo  || responsePayload.invoiceNo  || payload.orderNo;
    const invoiceID     = responsePayload.InvoiceID  || responsePayload.invoiceId  || '';
    const status        = responsePayload.status     || 'OPEN';
    const totalAmount   = responsePayload.totalAmount
      || payload.invoiceItems.reduce((s, i) => s + (i.rate * i.quantity), 0);

    await cds.db.run(
      INSERT.into(Invoices).entries({
        SeerBitInvoiceNumber: invoiceNumber,
        S4InvoiceNumber:      s4DocNumber,
        SeerBitInvoiceID:     invoiceID,
        OrderNumber:          payload.orderNo,
        Status:               status,
        SentToSeerBit:        true,
        Paid:                 status === 'PAID',
        TotalAmount:          totalAmount,
        Currency:             payload.currency,
        CustomerEmail:        payload.customerEmail,
        ReceiversName:        payload.receiversName,
        CompanyName:          payload.companyName,
        DueDate:              payload.dueDate,
        PaymentMethod:        'SEERBIT',
        SentAt:               new Date().toISOString()
      })
    );

    return {
      success:              true,
      seerBitInvoiceNumber: invoiceNumber,
      seerBitInvoiceID:     invoiceID,
      status,
      message:              `Invoice sent successfully. SeerBit Invoice #: ${invoiceNumber}`
    };
  }
});
