/// <summary>
/// Page SBPPaymentLinkPaymentsParts (ID 50133).
/// </summary>
page 71855583
 SBPPaymentLinkPaymentsParts
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SBPPaymentPayments";
    Editable = false;
    Extensible = true;
    CardPageId = "SBPPayment Link Payment";
    DataCaptionFields = paymentReference;





    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Payment Refence"; Rec.paymentReference)
                {
                    Caption = 'Payment Reference';
                    MultiLine = true;
                    ApplicationArea = All;
                    //Visible = Rec.paymentReference <> '';
                }
                field("Customer Name"; Rec."Full Name")
                {
                    ApplicationArea = All;

                }
                field("Date"; Rec."payment date")
                {
                    ApplicationArea = All;
                    Caption = 'Date';
                }
                field("Amount"; Rec.payLinkAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                }

                field("Status"; Rec."Payment Status")
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                }


            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(Details)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}