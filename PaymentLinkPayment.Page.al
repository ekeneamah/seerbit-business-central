/// <summary>
/// Page Payment Link Payment (ID 50129).
/// </summary>
page 71855598
 "SBPPayment Link Payment"
{
    ApplicationArea = All;
    Caption = 'Payment';
    PageType = Card;
    SourceTable = "SBPPaymentPayments";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group("Payment Details")
            {

                field("Full Name"; Rec."Full Name")
                {
                    Caption = 'Full Name';
                    Editable = false;


                }

                field("email"; Rec."email")
                {
                    Caption = 'Customer Email';
                    Editable = false;

                }
                field("payment date"; Rec."payment date")
                {
                    Caption = 'Payment Date';
                    Editable = false;
                }
                field("currency"; Rec."currency")
                {
                    Caption = 'Currency';
                    Editable = false;


                }
                field("payLinkAmount"; Rec."payLinkAmount")
                {
                    Caption = 'Amount Paid';
                    Editable = false;


                }
                field("paymentLinkId"; Rec."paymentLinkId")
                {
                    Caption = 'Payment Link ID';
                    Editable = false;


                }

                field("country"; Rec."country")
                {
                    Caption = 'Country';
                    Editable = false;


                }


                field("paymentReference"; Rec."paymentReference")
                {
                    Caption = 'Payment Reference';
                    Editable = false;

                }
                field("invoiceNumber"; Rec."invoiceNumber")
                {
                    Caption = 'Invoice Number';
                    Editable = false;



                }





                field("payment link reference"; Rec."payment link reference")
                {
                    Caption = 'Payment Link Reference';
                    Editable = false;
                }
                field("Reason"; Rec.Reason)
                {
                    Editable = false;
                    ToolTip = 'Add Reason';
                }
                field("Payment Status"; Rec."Payment Status")
                {
                    Editable = false;
                    ToolTip = 'Payment Status';

                }
            }
        }
    }

    /*     actions
        {
            area(Processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin

                    end;
                }
            }
        } */

    var
        myInt: Integer;
}