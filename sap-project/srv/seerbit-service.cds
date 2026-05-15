/**
 * SeerBit Payments Service — CDS Service Definition
 *
 * Exposes REST/OData endpoints for:
 *   - Viewing and managing SeerBit invoice records
 *   - Actions: send, bulk-send, resend, get-status, validate-payment
 *   - SeerBit configuration management
 *   - Payment links
 */

using { seerbit.s4hana as db } from '../db/schema';

service SeerBitService @(path: '/seerbit') {

  // -------------------------------------------------------------------------
  // Entities (CRUD + read)
  // -------------------------------------------------------------------------

  /** Tracked SeerBit invoices (equivalent to "SBP SeerBit Invoices" table in BC) */
  entity Invoices         as projection on db.SeerBitInvoices
    actions {
      /** Get the latest status of this invoice from SeerBit */
      action refreshStatus()              returns StatusResult;
      /** Resend the invoice email to the customer */
      action resend()                     returns ActionResult;
    };

  /** Line items belonging to a SeerBit invoice */
  entity InvoiceItems     as projection on db.SeerBitInvoiceItems;

  /** Global SeerBit API configuration (public key, secret key) */
  @(restrict: [{ grant: '*', to: 'SeerBitAdmin' }])
  entity Configuration    as projection on db.SeerBitConfig;

  /** Payment links */
  entity PaymentLinks     as projection on db.PaymentLinks;

  /** Virtual accounts */
  @(restrict: [{ grant: '*', to: ['SeerBitUser','SeerBitAdmin'] }])
  entity VirtualAccounts  as projection on db.VirtualAccounts
    actions {
      action syncPayments() returns RetrievePaymentsResult;
    };

  /** Payments retrieved for virtual accounts */
  @(restrict: [{ grant: '*', to: ['SeerBitUser','SeerBitAdmin'] }])
  entity VirtualAccountPayments as projection on db.VirtualAccountPayments;


  // -------------------------------------------------------------------------
  // Unbound Actions (service-level operations)
  // -------------------------------------------------------------------------

  /**
   * Send a single SAP billing document as a SeerBit invoice.
   * Mirrors: SBPSendPostedSalesInvoice.sendToAPI() with actionType = "Create"
   */
  action sendBillingDocument(
    billingDocumentID : String,  // SAP Billing Document number
    configID          : UUID     // SeerBitConfig ID to use
  ) returns InvoiceSendResult;

  /**
   * Send a single SAP sales order as a SeerBit invoice.
   */
  action sendSalesOrder(
    salesOrderID : String,
    configID     : UUID
  ) returns InvoiceSendResult;

  /**
   * Send multiple billing documents as a bulk SeerBit invoice request.
   * Mirrors: SBPSendInvoicesWithAuthHeader.SendSelectedInvoicesWithAuthHeader()
   */
  action sendBulkBillingDocuments(
    billingDocumentIDs : array of String,
    configID           : UUID
  ) returns BulkSendResult;

  /**
   * Validate payment for an invoice (called after posting / payment confirmation).
   * Mirrors: SBPSendPostedSalesInvoice.validatepayment()
   */
  action validatePayment(
    seerBitInvoiceNumber : String,
    transactionReference : String
  ) returns ActionResult;

  /**
   * Test SeerBit credentials by generating an auth token.
   */
  action testConnection(configID : UUID) returns ActionResult;

  /**
   * Create a virtual account on SeerBit.
   * Mirrors: VirtualAccountPage actionType='Create'
   */
  action createVirtualAccount(
    virtualAccountID : UUID,
    configID         : UUID
  ) returns VirtualAccountResult;

  /**
   * Update a virtual account on SeerBit.
   * Mirrors: VirtualAccountPage actionType='Update'
   */
  action updateVirtualAccount(
    virtualAccountID : UUID,
    configID         : UUID
  ) returns VirtualAccountResult;

  /**
   * Retrieve and persist virtual account payments.
   * Mirrors: VirtualAccountPage actionType='Verify'
   */
  action retrieveVirtualAccountPayments(
    virtualAccountID : UUID,
    configID         : UUID
  ) returns RetrievePaymentsResult;

  /**
   * Activate or deactivate a virtual account.
   * Internally mapped to the update endpoint with status ACTIVE/INACTIVE.
   */
  action setVirtualAccountStatus(
    virtualAccountID : UUID,
    status           : String,
    configID         : UUID
  ) returns VirtualAccountResult;

  /**
   * Mark a retrieved virtual account payment as posted in S/4.
   * Use this after your FI posting process succeeds.
   */
  action markVirtualAccountPaymentPosted(
    paymentID            : UUID,
    s4PostingDocumentNo  : String
  ) returns ActionResult;

  /**
   * Post one virtual account payment into S/4 journal entry API.
   */
  action postVirtualAccountPaymentToS4(
    paymentID      : UUID,
    configID       : UUID,
    companyCode    : String,
    documentType   : String
  ) returns ActionResult;

  /**
   * Post all unposted virtual account payments for one virtual account.
   */
  action postPendingVirtualAccountPaymentsToS4(
    virtualAccountID : UUID,
    configID         : UUID,
    companyCode      : String,
    documentType     : String
  ) returns BulkSendResult;

  /**
   * End-to-end flow: retrieve latest virtual account payments from SeerBit,
   * persist them, then post all unposted payments to S/4.
   */
  action retrieveAndPostVirtualAccountPayments(
    virtualAccountID : UUID,
    configID         : UUID,
    companyCode      : String,
    documentType     : String
  ) returns SyncAndPostResult;


  // -------------------------------------------------------------------------
  // Return Types
  // -------------------------------------------------------------------------

  type InvoiceSendResult {
    success             : Boolean;
    seerBitInvoiceNumber: String;
    seerBitInvoiceID    : String;
    status              : String;
    message             : String;
  }

  type BulkSendResult {
    success       : Boolean;
    sentCount     : Integer;
    failedCount   : Integer;
    message       : String;
    errors        : array of String;
  }

  type ActionResult {
    success : Boolean;
    message : String;
  }

  type StatusResult {
    success : Boolean;
    status  : String;
    paid    : Boolean;
    message : String;
  }

  type VirtualAccountResult {
    success       : Boolean;
    accountNumber : String;
    reference     : String;
    status        : String;
    message       : String;
  }

  type RetrievePaymentsResult {
    success      : Boolean;
    newPayments  : Integer;
    totalFetched : Integer;
    message      : String;
  }

  type SyncAndPostResult {
    success            : Boolean;
    fetchedCount       : Integer;
    newPayments        : Integer;
    postedCount        : Integer;
    failedPostingCount : Integer;
    message            : String;
    errors             : array of String;
  }
}
