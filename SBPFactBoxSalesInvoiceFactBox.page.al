page 71855575 "SBP Fact Box Sales Invoice"
{
    PageType = CardPart;
    SourceTable = "Sales Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    layout
    {
        area(content)
        {
            group("SeerBit Details")
            {
                field("SBP sent to seerbit"; Rec."SBP sent to seerbit")
                {
                    ApplicationArea = All;
                    Caption = 'Sent to SeerBit';
                    Editable = false;
                   // Visible = Rec."SBP SeerBit - Invoice Number" <> '';
                    ToolTip = 'Invoices sent to customer through seerbit payment gateway';
                }
                field("SBP SeerBit - Batch ID"; Rec."SBP SeerBit - Batch ID")
                {
                    ApplicationArea = All;
                    Caption = 'Batch ID';
                    Editable = false;
                   
                    ToolTip = 'Batch ID of invoice sent to customer by SeerBit';
                }
                field("SBP SeerBit - Invoice Number"; Rec."SBP SeerBit - Invoice Number")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Number';
                    Editable = false;
                   
                    ToolTip = 'Invoice number of invoice sent to customer by SeerBit';
                }
                field("SBP SeerBit - Status"; Rec."SBP SeerBit - Status")
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Editable = false;
                   
                    ToolTip = 'Status of invoice sent to customer by SeerBit';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Method Code';
                    Editable = false;
                   
                    ToolTip = 'Payment Method Code';
                }
                field("SBP SeerBit - Date Sent"; Rec."SBP SeerBit - Date Sent")
                {
                    ApplicationArea = All;
                    Caption = 'Date Sent to SeerBit';
                    Editable = false;
                   
                    ToolTip = 'Date Sent to SeerBit';
                }
                field("SBP SeerBit - Payment Date"; Rec."SBP SeerBit - Payment Date")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Date';
                    Editable = false;
                   
                    ToolTip = 'Payment Date';
                }
            }
        }
    }
}
