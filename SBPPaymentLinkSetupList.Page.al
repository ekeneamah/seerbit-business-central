/// <summary>
/// Page SBPPaymentLinkSetupList (ID 50106).
/// </summary>
page 71855584
 SBPPaymentLinkSetupList
{
    PageType = List;
    SourceTable = "SBPPayment Link";
    Caption = 'SeerBit - Payment Links';
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    CardPageId = "SBP PG Payment Link";
    DataCaptionFields = RecId, CustomizationName, CustomerName;
    Permissions =
        tabledata "SBPPayment Link" = R;


    layout
    {
        area(Content)
        {
            repeater("PaymentLinkItem")
            {
                field(OneTime; Rec.PaymentReference)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Reference';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Caption = 'Date';
                }
                field("Customisation Name"; Rec.CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                }
                field(PaymentLinkName; Rec.PaymentLinkName)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Link Name';
                }
                field(Currency; Rec.Currency)
                {
                    ApplicationArea = All;
                    Caption = 'Currency';
                }
                field(PaymentFrequency; Rec.PaymentFrequency)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Frequency';
                }

            }
        }

    }


}
