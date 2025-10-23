/// <summary>
/// Page SBP SeerBit Invoices List (ID 71855611).
/// </summary>
page 71855611 "SBP SeerBit Invoices List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SBP SeerBit Invoices";
    Caption = 'SeerBit Invoices';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Invoiceno; Rec.Invoiceno)
                {
                    ApplicationArea = All;
                    ToolTip = 'Invoice Number';
                }
                field("SeerBit - Invoice Number"; Rec."SeerBit - Invoice Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'SeerBit Invoice Number';
                }
                field("SeerBit - Status"; Rec."SeerBit - Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'SeerBit Status';
                }
                field("SeerBit Transaction Ref."; Rec."SeerBit Transaction Ref.")
                {
                    ApplicationArea = All;
                    ToolTip = 'SeerBit Transaction Reference';
                }
                field("SeerBit - Invoice ID"; Rec."SeerBit - Invoice ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'SeerBit Invoice ID';
                }
                field("SeerBit POS Status"; Rec."SeerBit POS Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'SeerBit POS Status';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;

                trigger OnAction()
                begin
                    CurrPage.Update();
                end;
            }
        }
    }
}