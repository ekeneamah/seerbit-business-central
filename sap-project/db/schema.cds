/**
 * SeerBit S/4HANA Integration — CDS Data Model
 *
 * Mirrors the Business Central data model from the AL extension,
 * adapted for SAP HANA / SQLite via CAP.
 */

namespace seerbit.s4hana;

using { cuid, managed, Currency } from '@sap/cds/common';

// ---------------------------------------------------------------------------
// SeerBit Invoice Tracking
// Mirrors: SeerBitInvoices.Table.al (Table 71855610 "SBP SeerBit Invoices")
// ---------------------------------------------------------------------------
entity SeerBitInvoices : managed {
  key SeerBitInvoiceNumber  : String(100);   // SeerBit-assigned invoice number (PK)
      S4InvoiceNumber       : String(20);    // SAP billing document / sales order no.
      S4SalesOrderNumber    : String(20);    // SAP sales order number
      SeerBitInvoiceID      : String(50);    // Internal SeerBit invoice ID
      OrderNumber           : String(50);    // Order reference sent to SeerBit
      Status                : String(20)     // OPEN | PAID | VERIFIED | ERROR | RESENT
                              default 'OPEN';
      Paid                  : Boolean        default false;
      SentToSeerBit         : Boolean        default false;
      TotalAmount           : Decimal(15,2);
      Currency              : String(10)     default 'NGN';
      CustomerEmail         : String(100);
      ReceiversName         : String(200);
      CompanyName           : String(200);
      DueDate               : String(20);    // ISO date string e.g. "2025-05-01"
      PaymentDate           : String(30);
      PaymentMethod         : String(50);    // CARD | TRANSFER | USSD | etc.
      TransactionReference  : String(100);
      TransactionID         : String(100);
      BatchID               : String(50);
      ErrorMessage          : String(500);
      SentAt                : Timestamp;
      PaidAt                : Timestamp;
}

// ---------------------------------------------------------------------------
// SeerBit Invoice Line Items
// Mirrors: the invoiceItems array that BC builds from Sales Lines
// ---------------------------------------------------------------------------
entity SeerBitInvoiceItems : managed {
  key ID            : UUID;
      Invoice       : Association to SeerBitInvoices;
      ItemName      : String(250);
      Quantity      : Decimal(13,3);
      Rate          : Decimal(15,2);
      Tax           : Decimal(15,5);
}

// ---------------------------------------------------------------------------
// SeerBit Configuration (per company / BTP subaccount)
// Mirrors: Company Information extensions in BusinessProfile.TableExt.al
// ---------------------------------------------------------------------------
entity SeerBitConfig : managed {
  key ID            : UUID;
      CompanyName   : String(200);
      PublicKey     : String(200);
      SecretKey     : String(200);  // stored encrypted at rest via SAP Credential Store
      Environment   : String(20)   // LIVE | SANDBOX
                      default 'SANDBOX';
  S4CompanyCode : String(4);
  S4DocumentType: String(4)    default 'DZ';
  S4SoapMode    : String(10)   default 'SYNC'; // SYNC | ASYNC
  S4SoapEndpointSync  : String(500);
  S4SoapEndpointAsync : String(500);
  S4SoapUser    : String(200);
  S4SoapPassword: String(200);
  S4SoapNamespace     : String(200);
  S4SoapActionSync    : String(300);
  S4SoapActionAsync   : String(300);
  S4SoapTimeoutMs     : Integer;
      IsActive      : Boolean      default false;
}

// ---------------------------------------------------------------------------
// Payment Links
// Mirrors: PaymentLink.Table.al (Table 71855618 "SBPPayment Link")
// ---------------------------------------------------------------------------
entity PaymentLinks : managed {
  key ID                  : UUID;
      Status              : String(20)     default 'ACTIVE';
      Amount              : Decimal(15,2);
      PaymentLinkName     : String(100);
      Description         : String(250);
      Currency            : String(10);
      SuccessMessage      : String(250);
      PublicKey           : String(200);
      PaymentFrequency    : String(20)     default 'ONE_TIME';
      PaymentReference    : String(100);
      CustomerEmail       : String(100);
      CustomerName        : String(200);
      RequireAddress      : Boolean        default false;
      RequireAmount       : Boolean        default false;
      RequireMobile       : Boolean        default false;
      RequireInvoiceNo    : Boolean        default false;
      IsExpirable         : Boolean        default false;
      ExpiryDate          : Date;
      OneTimeUse          : Boolean        default true;
      PaymentLinkURL      : String(500);
      TotalPaymentsCount  : Integer        default 0;
      BalancingAccountNo  : String(20);
}

    // ---------------------------------------------------------------------------
    // Virtual Accounts
    // Mirrors: SBPVirtualAccountTable (Table 71855611)
    // ---------------------------------------------------------------------------
    @assert.unique.vaReference : [Reference]
    @assert.unique.vaAccountNo : [AccountNumber]
    entity VirtualAccounts : managed {
      key ID                   : UUID;
      PublicKey            : String(200);
      FullName             : String(150);
      BankVerificationNo   : String(20);
      Currency             : String(10)      default 'NGN';
      Country              : String(10)      default 'NG';
      Reference            : String(120);
      Email                : String(120);
      AccountNumber        : String(40);
      WalletName           : String(100);
      BankName             : String(100);
      Status               : String(20)      default 'ACTIVE';
      Code                 : String(20);
      LinkingReference     : String(120);
      Wallet               : String(50);
      PaymentAccountType   : String(30)      default 'BANK_ACCOUNT';
      PaymentAccountNo     : String(20);
      PaymentAccountName   : String(120);
      BalancingAccountType : String(30)      default 'CUSTOMER';
      BalancingAccountNo   : String(20);
      TotalPayments        : Integer         default 0;
      LastRetrievedAt      : Timestamp;
      LastSyncStatus       : String(20);
      LastSyncMessage      : String(500);
      LastErrorMessage     : String(500);
    }

    // ---------------------------------------------------------------------------
    // Virtual Account Payments
    // Mirrors: SBPPaymentPayments for TransactionType='Virtual Account'
    // ---------------------------------------------------------------------------
    @assert.unique.vaPaymentRef : [PaymentReference]
    entity VirtualAccountPayments : managed {
      key ID                    : UUID;
      VirtualAccount        : Association to VirtualAccounts;
      PaymentReference      : String(100);
      PaymentLinkID         : String(50);
      PaymentLinkReference  : String(50);
      FullName              : String(120);
      CustomerEmail         : String(120);
      Country               : String(20);
      Currency              : String(20);
      Amount                : Decimal(15,2);
      PaymentDate           : String(120);
      Reason                : String(250);
      PaymentStatus         : String(120);
      TransactionType       : String(30)      default 'VIRTUAL_ACCOUNT';
      AccountNumber         : String(50);
      PostedToS4            : Boolean         default false;
      S4PostingDocumentNo   : String(35);
      S4PostedAt            : Timestamp;
      S4PostingError        : String(500);
      PostingAttempts       : Integer         default 0;
      RawPayload            : LargeString;
    }

// ---------------------------------------------------------------------------
// Enum-like code lists
// ---------------------------------------------------------------------------
entity PaymentFrequencies {
  key Code        : String(20);
      Description : String(100);
}

entity InvoiceStatuses {
  key Code        : String(20);
      Description : String(100);
}
