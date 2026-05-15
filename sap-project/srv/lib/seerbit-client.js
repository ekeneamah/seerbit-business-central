'use strict';

/**
 * SeerBit API Client
 *
 * Mirrors the authentication and API calls made across these BC codeunits:
 *   - SBPSendPostedSalesInvoice.Codeunit.al   (single invoice, token-in-body)
 *   - SBPSendInvoicesWithAuthHeader.Codeunit.al (bulk, Bearer header)
 *
 * SeerBit API reference:
 *   Auth    : POST https://seerbitapi.com/api/v2/encrypt/keys
 *   ERP MW  : https://erp.middleware.seerbitapi.com/api/v1/
 *   Merchant: https://merchant.seerbitapi.com/invoice/
 */

const axios = require('axios');

const SEERBIT_AUTH_URL   = process.env.SEERBIT_AUTH_URL || 'https://seerbitapi.com/api/v2/encrypt/keys';
const SEERBIT_ERP_BASE   = process.env.SEERBIT_ERP_BASE || 'https://erp.middleware.seerbitapi.com/api/v1';
const SEERBIT_MERCH_BASE = process.env.SEERBIT_MERCH_BASE || 'https://merchant.seerbitapi.com/invoice';
const REQUEST_TIMEOUT_MS = Number(process.env.SEERBIT_TIMEOUT_MS || 30000);
const MAX_RETRIES        = Number(process.env.SEERBIT_MAX_RETRIES || 2);
const RETRY_DELAY_MS     = Number(process.env.SEERBIT_RETRY_DELAY_MS || 350);

const http = axios.create({ timeout: REQUEST_TIMEOUT_MS });

// Token cache keyed by `${publicKey}:${secretKey}` — short-lived (5 min)
const _tokenCache = new Map();
const TOKEN_TTL_MS = 5 * 60 * 1000;

/**
 * Retrieve an encrypted bearer token from SeerBit.
 * Equivalent to the two-step auth in SBPSendPostedSalesInvoice (Step 1).
 *
 * @param {string} publicKey
 * @param {string} secretKey
 * @returns {Promise<string>} encryptedKey
 */
async function getEncryptedToken(publicKey, secretKey) {
  const cacheKey = `${publicKey}:${secretKey}`;
  const cached   = _tokenCache.get(cacheKey);
  if (cached && Date.now() < cached.expiresAt) {
    return cached.token;
  }

  const response = await _postJson(SEERBIT_AUTH_URL, { key: `${secretKey}.${publicKey}` }, { timeout: 15000 });

  // Navigate: response.data.data.EncryptedSecKey.encryptedKey
  const token = response.data?.data?.EncryptedSecKey?.encryptedKey;
  if (!token) {
    throw new Error(
      `SeerBit auth failed — unexpected response: ${JSON.stringify(response.data)}`
    );
  }

  _tokenCache.set(cacheKey, { token, expiresAt: Date.now() + TOKEN_TTL_MS });
  return token;
}

// ---------------------------------------------------------------------------
// Single Invoice Operations
// Mirrors: SBPSendPostedSalesInvoice.Codeunit.al → sendToAPI()
// ---------------------------------------------------------------------------

/**
 * Send a single invoice to SeerBit (creates & emails the payment link).
 *
 * @param {object} params
 * @param {string} params.publicKey
 * @param {string} params.secretKey
 * @param {string} params.orderNo         - SAP sales order / billing doc number
 * @param {string} params.dueDate         - ISO date "YYYY-MM-DD"
 * @param {string} params.currency        - e.g. "NGN"
 * @param {string} params.receiversName   - customer display name
 * @param {string} params.customerEmail
 * @param {string} params.companyName
 * @param {Array}  params.invoiceItems    - [{ itemName, quantity, rate, tax }]
 * @returns {Promise<object>} SeerBit response payload
 */
async function sendInvoice(params) {
  const {
    publicKey, secretKey, orderNo, dueDate, currency = 'NGN',
    receiversName, customerEmail, companyName, invoiceItems = []
  } = params;

  const token = await getEncryptedToken(publicKey, secretKey);

  const body = {
    token,
    publicKey,
    orderNo,
    dueDate,
    currency,
    receiversName,
    customerEmail,
    companyName,
    invoiceItems: invoiceItems.map(item => ({
      itemName: item.itemName,
      quantity: String(item.quantity),
      rate:     String(item.rate),
      tax:      String(item.tax ?? '0')
    }))
  };

  const response = await _postJson(`${SEERBIT_ERP_BASE}/sendinvoice`, body);

  return response.data;
}

/**
 * Get invoice details from SeerBit by SAP order number.
 * Mirrors: actionType = "Get invoice by orderNo"
 */
async function getInvoiceByOrderNo(params) {
  const { publicKey, secretKey, orderNo, invoiceNo, customerEmail } = params;
  const token = await getEncryptedToken(publicKey, secretKey);

  const response = await _postJson(`${SEERBIT_ERP_BASE}/getInvoiceByorderno`, {
    token, publicKey, orderno: orderNo, invoiceno: invoiceNo, customerEmail
  }, { timeout: 15000 });

  return response.data;
}

/**
 * Get invoice details from SeerBit by SeerBit invoice number.
 * Mirrors: actionType = "Get invoice by InvoiceNo"
 */
async function getInvoiceByInvoiceNo(params) {
  const { publicKey, secretKey, invoiceNo, orderNo, customerEmail } = params;
  const token = await getEncryptedToken(publicKey, secretKey);

  const response = await _postJson(`${SEERBIT_ERP_BASE}/getInvoiceByInvoiceno`, {
    token, publicKey, invoiceno: invoiceNo, orderno: orderNo, customerEmail
  }, { timeout: 15000 });

  return response.data;
}

/**
 * Resend an existing invoice email to the customer.
 * Mirrors: actionType = "Re-send an Invoice"
 */
async function resendInvoice(params) {
  const { publicKey, secretKey, invoiceNo, orderNo, customerEmail } = params;
  const token = await getEncryptedToken(publicKey, secretKey);

  const response = await _postJson(`${SEERBIT_ERP_BASE}/resendInvoice`, {
    token, publicKey, invoiceno: invoiceNo, orderno: orderNo, customerEmail
  }, { timeout: 15000 });

  return response.data;
}

// ---------------------------------------------------------------------------
// Bulk Invoice Operations
// Mirrors: SBPSendInvoicesWithAuthHeader.Codeunit.al → SendSelectedInvoicesWithAuthHeader()
// ---------------------------------------------------------------------------

/**
 * Send multiple invoices in a single bulk request.
 * Uses Bearer token in Authorization header (not in request body).
 *
 * @param {string} publicKey
 * @param {string} secretKey
 * @param {Array}  invoices  - Array of invoice objects matching samplepayload.json
 * @returns {Promise<object>} SeerBit response
 */
async function sendBulkInvoices(publicKey, secretKey, invoices) {
  const token = await getEncryptedToken(publicKey, secretKey);

  const payload = invoices.map(inv => ({
    orderNo:       inv.orderNo,
    dueDate:       inv.dueDate,
    currency:      inv.currency || 'NGN',
    receiversName: inv.receiversName,
    customerEmail: inv.customerEmail,
    invoiceItems:  (inv.invoiceItems || []).map(item => ({
      itemName: item.itemName,
      quantity: String(item.quantity),
      rate:     String(item.rate),
      tax:      String(item.tax ?? '0')
    }))
  }));

  const response = await _postJson(
    `${SEERBIT_MERCH_BASE}/${publicKey}/bulk-requests`,
    payload,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'User-Agent':    'seerbit-s4hana/1.0'
      },
      timeout: 60000
    }
  );

  return response.data;
}

// ---------------------------------------------------------------------------
// Virtual Account Operations
// Mirrors: VirtualAccountPage.Page.al → SendDataToAPI(actionType)
// ---------------------------------------------------------------------------

/**
 * Create a SeerBit virtual account.
 * Endpoint: POST /virtualAccount/create
 */
async function createVirtualAccount(params) {
  const {
    publicKey,
    secretKey,
    fullName,
    bankVerificationNumber = '',
    country = 'NG',
    currency = 'NGN',
    email,
    status = 'ACTIVE',
    reference
  } = params;

  const token = await getEncryptedToken(publicKey, secretKey);

  const body = {
    token,
    fullName,
    bankVerificationNumber,
    publicKey,
    country,
    currency,
    email,
    status,
    reference: reference || _makeReference('VA')
  };

  const response = await _postJson(`${SEERBIT_ERP_BASE}/virtualAccount/create`, body);

  return response.data;
}

/**
 * Update a SeerBit virtual account.
 * Endpoint: POST /virtualAccount/update
 */
async function updateVirtualAccount(params) {
  const {
    publicKey,
    secretKey,
    fullName,
    bankVerificationNumber = '',
    country = 'NG',
    currency = 'NGN',
    email,
    status = 'ACTIVE',
    reference
  } = params;

  const token = await getEncryptedToken(publicKey, secretKey);

  const body = {
    token,
    fullName,
    bankVerificationNumber,
    publicKey,
    country,
    currency,
    email,
    status,
    reference: reference || _makeReference('VAU')
  };

  const response = await _postJson(`${SEERBIT_ERP_BASE}/virtualAccount/update`, body);

  return response.data;
}

/**
 * Retrieve payments for a virtual account by account number.
 * Endpoint: POST /virtualAccount/byreferenceno
 */
async function retrieveVirtualAccountPayments(params) {
  const { publicKey, secretKey, accountNumber, status = 'ACTIVE' } = params;
  const token = await getEncryptedToken(publicKey, secretKey);

  const body = {
    bearertoken: token,
    status,
    accountNumber,
    publickey: publicKey
  };

  const response = await _postJson(`${SEERBIT_ERP_BASE}/virtualAccount/byreferenceno`, body);

  return response.data;
}

function _makeReference(prefix) {
  return `${prefix}-${Date.now()}`;
}

function _isRetryable(error) {
  if (!error) return false;
  if (error.code === 'ECONNABORTED' || error.code === 'ENOTFOUND' || error.code === 'ECONNRESET') {
    return true;
  }
  const status = error.response?.status;
  return status === 408 || status === 429 || (status >= 500 && status <= 599);
}

async function _postJson(url, body, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {})
  };
  const timeout = options.timeout || REQUEST_TIMEOUT_MS;

  let attempt = 0;
  let lastError;

  while (attempt <= MAX_RETRIES) {
    try {
      return await http.post(url, body, { headers, timeout });
    } catch (err) {
      lastError = err;
      if (!_isRetryable(err) || attempt === MAX_RETRIES) {
        throw new Error(_formatHttpError(url, err));
      }
      await _sleep(RETRY_DELAY_MS * (attempt + 1));
      attempt += 1;
    }
  }

  throw new Error(_formatHttpError(url, lastError));
}

function _formatHttpError(url, error) {
  const status = error?.response?.status;
  const responseData = error?.response?.data;
  const responseMsg = typeof responseData === 'string'
    ? responseData.slice(0, 250)
    : JSON.stringify(responseData || {}).slice(0, 250);
  if (status) {
    return `HTTP ${status} calling ${url}: ${responseMsg}`;
  }
  return `Network error calling ${url}: ${error?.message || 'unknown error'}`;
}

function _sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = {
  getEncryptedToken,
  sendInvoice,
  getInvoiceByOrderNo,
  getInvoiceByInvoiceNo,
  resendInvoice,
  sendBulkInvoices,
  createVirtualAccount,
  updateVirtualAccount,
  retrieveVirtualAccountPayments
};
