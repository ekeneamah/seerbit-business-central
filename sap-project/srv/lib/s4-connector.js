'use strict';

/**
 * SAP S/4HANA OData Connector
 *
 * Reads Sales Orders and Billing Documents (Customer Invoices) from
 * SAP S/4HANA via standard OData V2 APIs, then shapes the data into
 * the same payload structure that the BC AL integration used.
 *
 * OData APIs used:
 *   - API_SALES_ORDER_SRV        → A_SalesOrder, A_SalesOrderItem
 *   - API_BILLING_DOCUMENT_SRV   → A_BillingDocument, A_BillingDocumentItem
 *
 * In CAP, these are consumed via cds.connect.to('S4_HANA') which reads
 * destination credentials from SAP BTP Destination Service (or .env in dev).
 */

const cds = require('@sap/cds');

// OData entity set paths
const BILLING_DOC_ENTITY    = 'A_BillingDocument';
const BILLING_ITEM_ENTITY   = 'A_BillingDocumentItem';
const SALES_ORDER_ENTITY    = 'A_SalesOrder';
const SALES_ITEM_ENTITY     = 'A_SalesOrderItem';

// ---------------------------------------------------------------------------
// Billing Documents (Posted Sales Invoices equivalent)
// ---------------------------------------------------------------------------

/**
 * Fetch a single billing document plus its items from S/4HANA.
 * Equivalent to reading "Sales Invoice Header" + "Sales Invoice Lines" in BC.
 *
 * @param {string} billingDocumentID  - e.g. "9000000001"
 * @returns {Promise<{header: object, items: Array}>}
 */
async function getBillingDocument(billingDocumentID) {
  const s4 = await cds.connect.to('S4_HANA');

  const [header, items] = await Promise.all([
    s4.run(
      SELECT.one
        .from(BILLING_DOC_ENTITY)
        .where({ BillingDocument: billingDocumentID })
        .columns(
          'BillingDocument',
          'SoldToParty',
          'BillingDocumentDate',
          'PaymentTerms',
          'TotalNetAmount',
          'TransactionCurrency',
          'BillingDocumentType',
          'SDDocumentReason',
          'CompanyCode',
          'CreatedByUser'
        )
    ),
    s4.run(
      SELECT
        .from(BILLING_ITEM_ENTITY)
        .where({ BillingDocument: billingDocumentID })
        .columns(
          'BillingDocumentItem',
          'Material',
          'BillingDocumentItemText',
          'BillingQuantity',
          'NetAmount',
          'TaxAmount',
          'ItemNetWeight',
          'MaterialGroup'
        )
    )
  ]);

  return { header, items };
}

/**
 * Fetch all open (unbilled / not-yet-sent) billing documents for a company.
 *
 * @param {object} filters  - optional OData filter fields
 * @returns {Promise<Array>}
 */
async function getOpenBillingDocuments(filters = {}) {
  const s4 = await cds.connect.to('S4_HANA');

  const query = SELECT
    .from(BILLING_DOC_ENTITY)
    .columns(
      'BillingDocument',
      'SoldToParty',
      'BillingDocumentDate',
      'TotalNetAmount',
      'TransactionCurrency',
      'BillingDocumentType'
    )
    .orderBy('BillingDocumentDate desc')
    .limit(200);

  if (filters.companyCode) {
    query.where({ CompanyCode: filters.companyCode });
  }

  return s4.run(query);
}

// ---------------------------------------------------------------------------
// Sales Orders (Open Sales Documents equivalent)
// ---------------------------------------------------------------------------

/**
 * Fetch a single sales order plus its items from S/4HANA.
 * Equivalent to reading "Sales Header" + "Sales Lines" in BC.
 *
 * @param {string} salesOrderID  - e.g. "10000001"
 * @returns {Promise<{header: object, items: Array}>}
 */
async function getSalesOrder(salesOrderID) {
  const s4 = await cds.connect.to('S4_HANA');

  const [header, items] = await Promise.all([
    s4.run(
      SELECT.one
        .from(SALES_ORDER_ENTITY)
        .where({ SalesOrder: salesOrderID })
        .columns(
          'SalesOrder',
          'SoldToParty',
          'SalesOrderDate',
          'RequestedDeliveryDate',
          'TotalNetAmount',
          'TransactionCurrency',
          'SalesOrderType',
          'SalesOrganization',
          'DistributionChannel',
          'SalesOffice',
          'CustomerPurchaseOrderDate'
        )
    ),
    s4.run(
      SELECT
        .from(SALES_ITEM_ENTITY)
        .where({ SalesOrder: salesOrderID })
        .columns(
          'SalesOrderItem',
          'Material',
          'SalesOrderItemText',
          'RequestedQuantity',
          'NetAmount',
          'TaxAmount',
          'ItemNetWeight'
        )
    )
  ]);

  return { header, items };
}

// ---------------------------------------------------------------------------
// Data Shape Helpers
// These translate S/4HANA OData fields → SeerBit payload fields,
// mirroring the JSON assembly logic in the BC codeunits.
// ---------------------------------------------------------------------------

/**
 * Shape a billing document into a SeerBit invoice payload.
 * Mirrors the JSON assembly in SBPSendPostedSalesInvoice (Create path).
 *
 * @param {object} header          - BillingDocument header from OData
 * @param {Array}  items           - BillingDocumentItem rows from OData
 * @param {object} customerInfo    - { email, name } resolved from Business Partner
 * @param {string} companyName
 * @returns {object} SeerBit invoice payload
 */
function shapeBillingDocumentPayload(header, items, customerInfo, companyName) {
  const dueDate = _formatDate(header.BillingDocumentDate);

  const invoiceItems = items.map(item => ({
    itemName: item.BillingDocumentItemText || item.Material || 'Item',
    quantity: Number(item.BillingQuantity  || 1),
    rate:     Number(item.NetAmount        || 0),
    tax:      Number(item.TaxAmount        || 0)
  }));

  return {
    orderNo:       header.BillingDocument,
    dueDate,
    currency:      header.TransactionCurrency || 'NGN',
    receiversName: customerInfo.name  || header.SoldToParty,
    customerEmail: customerInfo.email || '',
    companyName:   companyName || '',
    invoiceItems
  };
}

/**
 * Shape a sales order into a SeerBit invoice payload.
 *
 * @param {object} header       - SalesOrder header from OData
 * @param {Array}  items        - SalesOrderItem rows from OData
 * @param {object} customerInfo - { email, name }
 * @param {string} companyName
 * @returns {object}
 */
function shapeSalesOrderPayload(header, items, customerInfo, companyName) {
  const dueDate = _formatDate(
    header.RequestedDeliveryDate || header.SalesOrderDate
  );

  const invoiceItems = items.map(item => ({
    itemName: item.SalesOrderItemText || item.Material || 'Item',
    quantity: Number(item.RequestedQuantity || 1),
    rate:     Number(item.NetAmount         || 0),
    tax:      Number(item.TaxAmount         || 0)
  }));

  return {
    orderNo:       header.SalesOrder,
    dueDate,
    currency:      header.TransactionCurrency || 'NGN',
    receiversName: customerInfo.name  || header.SoldToParty,
    customerEmail: customerInfo.email || '',
    companyName:   companyName || '',
    invoiceItems
  };
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/**
 * Format an OData date value (Edm.Date or Edm.DateTimeOffset) to "YYYY-MM-DD".
 * SAP OData V2 often returns dates as "/Date(milliseconds)/" JSON format.
 */
function _formatDate(dateValue) {
  if (!dateValue) return '';

  // Handle SAP OData V2 JSON date: /Date(1609459200000)/
  if (typeof dateValue === 'string' && dateValue.startsWith('/Date(')) {
    const ms = parseInt(dateValue.replace(/\/Date\((\d+)[^)]*\)\//, '$1'), 10);
    return new Date(ms).toISOString().split('T')[0];
  }

  // Handle standard ISO date/datetime
  if (dateValue instanceof Date) {
    return dateValue.toISOString().split('T')[0];
  }

  // Already a date string
  return String(dateValue).split('T')[0];
}

module.exports = {
  getBillingDocument,
  getOpenBillingDocuments,
  getSalesOrder,
  shapeBillingDocumentPayload,
  shapeSalesOrderPayload
};
