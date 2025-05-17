/// <summary>
/// PageExtension postedsalesinvoicesExt (ID 50143) extends Record Posted Sales Invoices.
/// </summary>
pageextension 71855593
 SBPPostedsalesinvoicesExt extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Bill-to Name")
        {
            field("SBP Customer Email"; Rec."SBP Bill-to E-Mail")
            {
                Caption = 'Customer Email';
                ToolTip = 'Email of the Customer you sent the invoice to';
                ApplicationArea = ALL;
            }
        }
        addafter("Sell-to Customer No.")
        {
            field("SBP Sent by Serbit"; Rec."SBP sent to seerbit")
            {
                Caption = 'SBS';
                ToolTip = 'Invoices sent to customer through seerbit payment gateway';
                ApplicationArea = All;
            }
            field("SBP paymnet by Serbit"; Rec."SBPPaid")
            {
                Caption = 'PBS';
                ToolTip = 'Invoices whose payments have been received by seerbit payment gateway';
                ApplicationArea = All;
            }
            field("SBP SeerBit - Invoice No."; Rec."SBP SeerBit - Invoice Number")
            {
                Caption = 'SeerBit - Invoice No.';
                ToolTip = 'Invoice number of invoice sent to customer by SeerBit';
                ApplicationArea = All;
            }
        }
    }
}
