/// <summary>
/// Codeunit SBPSalesInvoiceCodeunit (ID 50149).
/// </summary>
codeunit 71855579 SBPSalesInvoiceCodeunit
{
    Permissions =
        tabledata SBPSalesInvoice = RI;
    /// <summary>
    /// CreateNewInvoice.
    /// </summary>
    procedure CreateNewInvoice()
    var
        SalesInvoiceRec: Record SBPSalesInvoice;
    begin
        SalesInvoiceRec."Invoice No." := 'INV0001';
        SalesInvoiceRec."Customer No." := 'CUST001';
        SalesInvoiceRec."Posting Date" := CurrentDateTime;
        SalesInvoiceRec."Due Date" := CurrentDateTime + 30;
        SalesInvoiceRec."Currency Code" := 'USD';
        // Set other field values as needed

        SalesInvoiceRec.INSERT;
    end;
}
