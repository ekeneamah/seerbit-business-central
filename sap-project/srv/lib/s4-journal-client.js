'use strict';

/**
 * SAP S/4HANA Journal Entry Post (SOAP)
 *
 * Supports both synchronous and asynchronous posting via configuration.
 * Payload uses JournalEntryBulkCreateRequest with GL + Debtor line items.
 */

const axios = require('axios');
const crypto = require('crypto');

const S4_SOAP_MODE = String(process.env.S4_JOURNAL_SOAP_MODE || 'SYNC').trim().toUpperCase();
const S4_SOAP_ENDPOINT_SYNC = process.env.S4_JOURNAL_SOAP_ENDPOINT_SYNC || '';
const S4_SOAP_ENDPOINT_ASYNC = process.env.S4_JOURNAL_SOAP_ENDPOINT_ASYNC || '';
const S4_SOAP_USER = process.env.S4_JOURNAL_SOAP_USER || process.env.S4HANA_USERNAME || '';
const S4_SOAP_PASSWORD = process.env.S4_JOURNAL_SOAP_PASSWORD || process.env.S4HANA_PASSWORD || '';
const S4_SOAP_NAMESPACE = process.env.S4_JOURNAL_SOAP_NAMESPACE || 'http://sap.com/xi/SAPSCORE/SFIN';
const S4_SOAP_ACTION_SYNC = process.env.S4_JOURNAL_SOAP_ACTION_SYNC || 'http://sap.com/xi/SAPSCORE/SFIN/JournalEntryBulkCreateRequest_In';
const S4_SOAP_ACTION_ASYNC = process.env.S4_JOURNAL_SOAP_ACTION_ASYNC || 'http://sap.com/xi/SAPSCORE/SFIN/JournalEntryBulkCreateRequest_Out';
const S4_SOAP_TIMEOUT_MS = Number(process.env.S4_JOURNAL_SOAP_TIMEOUT_MS || 30000);

async function postIncomingPayment(params) {
  const {
    companyCode,
    documentType = 'DZ',
    documentDate,
    postingDate,
    headerText,
    reference,
    debitGLAccount,
    customer,
    amount,
    currency,
    assignmentReference,
    s4Connection = {}
  } = params;

  const mode = String(s4Connection.mode || S4_SOAP_MODE || 'SYNC').trim().toUpperCase();
  const endpointSync = String(s4Connection.endpointSync || S4_SOAP_ENDPOINT_SYNC || '').trim();
  const endpointAsync = String(s4Connection.endpointAsync || S4_SOAP_ENDPOINT_ASYNC || '').trim();
  const endpoint = mode === 'ASYNC' ? endpointAsync : endpointSync;

  const soapNamespace = String(s4Connection.namespace || S4_SOAP_NAMESPACE || '').trim();
  const soapAction = mode === 'ASYNC'
    ? String(s4Connection.actionAsync || S4_SOAP_ACTION_ASYNC || '').trim()
    : String(s4Connection.actionSync || S4_SOAP_ACTION_SYNC || '').trim();
  const soapUser = String(s4Connection.user || S4_SOAP_USER || '').trim();
  const soapPassword = String(s4Connection.password || S4_SOAP_PASSWORD || '').trim();
  const timeoutMs = Number(s4Connection.timeoutMs || S4_SOAP_TIMEOUT_MS || 30000);

  if (!endpoint) {
    throw new Error(`Missing SOAP endpoint for mode ${mode}. Configure customer S4 SOAP endpoint or S4_JOURNAL_SOAP_ENDPOINT_${mode}`);
  }
  if (!soapUser || !soapPassword) {
    throw new Error('Missing S/4 SOAP credentials for journal posting');
  }

  const nowIsoDate = new Date().toISOString().slice(0, 10);
  const postDate = String(postingDate || nowIsoDate);
  const docDate = String(documentDate || postDate);
  const amt = Number(amount || 0);

  const messageId = crypto.randomUUID();
  const requestXml = _buildJournalEntryRequest({
    messageId,
    companyCode,
    documentType,
    postingDate: postDate,
    documentDate: docDate,
    headerText,
    reference,
    debitGLAccount,
    customer,
    amount: amt,
    currency: currency || 'NGN',
    assignmentReference,
    soapNamespace,
  });

  let responseText;
  try {
    const res = await axios.post(endpoint, requestXml, {
      timeout: timeoutMs,
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        SOAPAction: soapAction,
        Authorization: 'Basic ' + Buffer.from(`${soapUser}:${soapPassword}`).toString('base64'),
      },
      maxBodyLength: Infinity,
      maxContentLength: Infinity,
    });

    responseText = typeof res.data === 'string' ? res.data : JSON.stringify(res.data || {});
  } catch (err) {
    const detail = err.response?.data ? _trimXml(String(err.response.data), 4000) : String(err.message || 'SOAP call failed');
    throw new Error(`S/4 SOAP Journal post failed: ${detail}`);
  }

  if (_containsSoapFault(responseText)) {
    const fault = _extractTag(responseText, 'faultstring') || _extractTag(responseText, 'Text') || _trimXml(responseText, 1200);
    throw new Error(`S/4 SOAP Fault: ${fault}`);
  }

  const accountingDocument =
    _extractTag(responseText, 'AccountingDocument')
    || _extractTag(responseText, 'AccountingDocumentNumber')
    || _extractTag(responseText, 'JournalEntry')
    || _extractTag(responseText, 'ID')
    || '';

  return {
    accountingDocument,
    raw: responseText
  };
}

function _buildJournalEntryRequest(payload) {
  const {
    messageId,
    companyCode,
    documentType,
    postingDate,
    documentDate,
    headerText,
    reference,
    debitGLAccount,
    customer,
    amount,
    currency,
    assignmentReference,
    soapNamespace,
  } = payload;

  const ref = String(reference || messageId).slice(0, 35);
  const itemText = String(headerText || `SeerBit ${ref}`).slice(0, 50);
  const assignment = String(assignmentReference || ref).slice(0, 18);

  // SOAP payload supports more item types (creditor/tax/withholding);
  // we intentionally emit GL + Debtor items for the current incoming-payment flow.
  return `<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfin="${_xmlEsc(soapNamespace)}">
  <soapenv:Header/>
  <soapenv:Body>
    <sfin:JournalEntryBulkCreateRequest>
      <MessageHeader>
        <ID>${_xmlEsc(messageId)}</ID>
        <CreationDateTime>${new Date().toISOString()}</CreationDateTime>
      </MessageHeader>
      <JournalEntryCreateRequest>
        <MessageHeader>
          <ID>${_xmlEsc(messageId)}</ID>
          <CreationDateTime>${new Date().toISOString()}</CreationDateTime>
        </MessageHeader>
        <JournalEntry>
          <OriginalReferenceDocumentType>BKPFF</OriginalReferenceDocumentType>
          <OriginalReferenceDocument>${_xmlEsc(ref)}</OriginalReferenceDocument>
          <BusinessTransactionType>RFBU</BusinessTransactionType>
          <AccountingDocumentType>${_xmlEsc(documentType || 'DZ')}</AccountingDocumentType>
          <DocumentReferenceID>${_xmlEsc(ref)}</DocumentReferenceID>
          <DocumentHeaderText>${_xmlEsc(itemText)}</DocumentHeaderText>
          <CompanyCode>${_xmlEsc(companyCode)}</CompanyCode>
          <DocumentDate>${_xmlEsc(documentDate)}</DocumentDate>
          <PostingDate>${_xmlEsc(postingDate)}</PostingDate>
          <Item>
            <ReferenceDocumentItem>1</ReferenceDocumentItem>
            <GLAccount>${_xmlEsc(_pad10(debitGLAccount))}</GLAccount>
            <AmountInTransactionCurrency currencyCode="${_xmlEsc(currency)}">${Math.abs(Number(amount))}</AmountInTransactionCurrency>
            <DebitCreditCode>S</DebitCreditCode>
            <DocumentItemText>${_xmlEsc(itemText)}</DocumentItemText>
            <AssignmentReference>${_xmlEsc(assignment)}</AssignmentReference>
          </Item>
          <DebtorItem>
            <ReferenceDocumentItem>2</ReferenceDocumentItem>
            <Debtor>${_xmlEsc(_pad10(customer))}</Debtor>
            <AmountInTransactionCurrency currencyCode="${_xmlEsc(currency)}">-${Math.abs(Number(amount))}</AmountInTransactionCurrency>
            <DebitCreditCode>H</DebitCreditCode>
            <DocumentItemText>${_xmlEsc(itemText)}</DocumentItemText>
            <AssignmentReference>${_xmlEsc(assignment)}</AssignmentReference>
          </DebtorItem>
        </JournalEntry>
      </JournalEntryCreateRequest>
    </sfin:JournalEntryBulkCreateRequest>
  </soapenv:Body>
</soapenv:Envelope>`;
}

function _pad10(value) {
  return String(value || '').trim().padStart(10, '0').slice(-10);
}

function _xmlEsc(value) {
  return String(value == null ? '' : value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function _containsSoapFault(xml) {
  return /<(?:\w+:)?Fault\b/i.test(String(xml || ''));
}

function _extractTag(xml, tagName) {
  const re = new RegExp(`<(?:\\w+:)?${tagName}(?:\\s[^>]*)?>([^<]*)<\\/(?:\\w+:)?${tagName}>`, 'i');
  const m = String(xml || '').match(re);
  return m ? m[1].trim() : '';
}

function _trimXml(value, maxLength) {
  const text = String(value || '');
  return text.length > maxLength ? `${text.slice(0, maxLength)}...` : text;
}

module.exports = {
  postIncomingPayment
};
