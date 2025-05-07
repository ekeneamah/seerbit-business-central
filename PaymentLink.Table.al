

/// <summary>
/// Table Required Fields (ID 50105).
/// </summary>

table 71855618
 "SBPPayment Link"
{
    DataClassification = CustomerContent;
    DataCaptionFields = RecId, Customername, PaymentLinkName;
    DrillDownPageId = SBPPaymentLinkSetupList;
    LookupPageId = "SBP PG Payment Link";
    Caption = 'Payment Link Table';


    fields
    {

        field(1; RecId; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;

        }
        field(2; Status; Text[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            InitValue = ACTIVE;
        }
        field(20; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            DecimalPlaces = 2;
            trigger OnValidate()
            begin
                rec.Amount := rec.Amount;
            end;

        }
        field(3; PaymentLinkName; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = true;
            NotBlank = true;

        }
        field(4; Description; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(5; Currency; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(6; SuccessMessage; Text[250])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(7; PublicKey; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(8; CustomizationName; Text[100])
        {
            DataClassification = CustomerContent;


        }
        field(9; PaymentFrequency; Enum "SBP Payment Frequency")
        {
            DataClassification = CustomerContent;


        }
        field(10; PaymentReference; Text[100])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(101; "GL Account Name"; Text[120])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(11; Email; Text[100])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(22; CustomerName; Text[200])
        {
            DataClassification = CustomerContent;
        }
        field(12; address; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(24; ReqcustomerName; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27; ReqAddress; Boolean)
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(26; ReqAmount; Boolean)
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }

        field(25; MobileNumber; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(28; InvoiceNumber; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(13; AdditionalData; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(14; LinkExpirable; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; ExpiryDate; Date)
        {
            DataClassification = CustomerContent;

        }
        field(16; OneTime; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(21; Reference; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(30; PaymentLink; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(33; "General Journal"; Text[250])
        {
            DataClassification = CustomerContent;
            InitValue = 'SEERBIT';
        }
        field(34; "Total Payments"; Integer)
        {
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; RecId)
        {
            Clustered = true;

        }

    }





    trigger OnInsert()
    begin


    end;


    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
