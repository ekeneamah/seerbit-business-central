/// <summary>
/// Page SalesInvoicePage (ID 50140).
/// </summary>
page 71855600
 SBPSalesInvoicePage
{
    Caption = 'Sales Invoice';
    PageType = Document;
    SourceTable = SBPSalesInvoice;
    ApplicationArea = All;
    Permissions =
        tabledata SBPSalesInvoice = RIMD;

    layout
    {
        // Add relevant fields from Sales Invoice table
        area(content)
        {
            field("Invoice No."; Rec."Invoice No.")
            {
                ApplicationArea = All;
                Caption = 'Invoice No.';
            }
            field("Customer No."; Rec."Customer No.")
            {
                ApplicationArea = All;
                Caption = 'Customer No.';
            }
            field("Posting Date"; Rec."Posting Date")
            {
                ApplicationArea = All;
                Caption = 'Posting Date';
            }
            field("Due Date"; Rec."Due Date")
            {
                ApplicationArea = All;
                Caption = 'Due Date';
            }
            field("Currency Code"; Rec."Currency Code")
            {
                ApplicationArea = All;
                Caption = 'Currency Code';
            }
            // Add more fields as per your requirements
        }
    }


}
