/// <summary>
/// Table Payment Link Payments (ID 50135).
/// </summary>
table 71855604
 "SBPPaymentPayments"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "SBPPayment Link Payment";
    Caption = 'Payments';

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = false;


        }
        field(3; Id1; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;


        }
        field(30; Id2; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = false;
            ObsoleteState = Removed;
            ObsoleteTag = '17.0';
            ObsoleteReason = 'Fix breaking changes';


        }
        field(2; "Payment link Id"; Code[200])
        {
            DataClassification = CustomerContent;
            TableRelation = "SBPPayment Link".RecId;
        }
        field(4; "productId"; Code[20])
        {
            DataClassification = CustomerContent;


        }
        field(5; "email"; Text[120])
        {
            DataClassification = CustomerContent;


        }
        field(6; "paymentReference"; Code[50])
        {
            DataClassification = CustomerContent;


        }
        field(7; "invoiceNumber"; Code[20])
        {
            DataClassification = CustomerContent;


        }
        field(8; "payLinkAmount"; Decimal)
        {
            DataClassification = CustomerContent;


        }
        field(9; "paymentLinkId"; Code[20])
        {
            DataClassification = CustomerContent;


        }
        field(10; "customerId"; Code[200])
        {
            DataClassification = CustomerContent;


        }
        field(11; "country"; Text[20])
        {
            DataClassification = CustomerContent;


        }
        field(12; "currency"; Code[20])
        {
            DataClassification = CustomerContent;


        }
        field(17; "Full Name"; Text[120])
        {
            DataClassification = CustomerContent;


        }
        field(13; "type"; Text[20])
        {
            DataClassification = CustomerContent;


        }
        field(14; "channelType"; Text[20])
        {
            DataClassification = CustomerContent;


        }
        field(15; "fee"; Code[20])
        {
            DataClassification = CustomerContent;


        }
        field(16; "inCardProcessingFee"; Code[20])
        {
            DataClassification = CustomerContent;


        }
        field(18; "payment date"; Text[120])
        {
            DataClassification = CustomerContent;
        }
        field(19; "paymentType"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(20; "TransactionType"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(21; "accountNumber"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(23; "payment link reference"; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(24; "Reason"; Text[120])
        {
            DataClassification = CustomerContent;
        }
        field(25; "Payment Status"; Text[120])
        {
            DataClassification = CustomerContent;
        }

    }


    keys
    {

        key(PK; Id)
        {

            Clustered = false;


        }
        key(Pk1; Id1)
        {
            clustered = false;
        }
        key(Key1; Id2)
        {
            ObsoleteReason = 'Not valid';
            ObsoleteState = Removed;
            clustered = false;
            ObsoleteTag = '17.0';
        }

    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        Id := Id + 1;
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