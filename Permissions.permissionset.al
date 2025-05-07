/// <summary>
/// Unknown SBPPermissions (ID 71855575).
/// </summary>
permissionset 71855575 SBPPermissions
{
    Assignable = true;
    Permissions = tabledata "SBPPayment Link" = RIMD,
        tabledata "SBPPaymentPayments" = RIMD,
        tabledata "SBP Pos location table" = RIMD,
        tabledata SBPPOSDetailTable = RIMD,
        tabledata SBPSalesInvoice = RIMD,
        tabledata "SBP SeerBit Invoices" = RIMD,
        tabledata "SBP Table POS Vendors" = RIMD,
        tabledata SBPVirtualAccountTable = RIMD,
        table "SBPPayment Link" = X,
        table "SBPPaymentPayments" = X,
        table "SBP Pos location table" = X,
        table SBPPOSDetailTable = X,
        table SBPSalesInvoice = X,
        table "SBP SeerBit Invoices" = X,
        table "SBP Table POS Vendors" = X,
        table SBPVirtualAccountTable = X,
        codeunit "SBPAPI Integration" = X,
        codeunit "SBP Open SeerBit signup" = X,
        codeunit SBPRetrievePaymentlinkPayments = X,
        codeunit SBPSalesInvoiceCodeunit = X,
        codeunit SBPSeerBitGlobalCodeunit = X,
        codeunit SBPSendPostedSalesInvoice = X,
        page "SBPPayment Link Payment" = X,
        page "SBP PG Payment Link" = X,
        page SBPSalesInvoicePage = X,
        page "SBP List POS Locations" = X,
        page "SBP List POS Vendors" = X,
        page "SBP POS LIST" = X,
        page SBPPaymentLinkPaymentsParts = X,
        page SBPPaymentLinkSetupList = X,
        page SBPVirtualAccountList = X,
        page "SBPSeerBit Signup" = X,
        page SBPVirtualAccountPage = X;
}