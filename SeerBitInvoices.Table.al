/// <summary>
/// Table SeerBit Invoices (ID 50138).
/// </summary>
table 71855610
 "SBP SeerBit Invoices"
{
    DataClassification = CustomerContent;

    fields
    {
        // Add changes to table fields here
        field(1; "SeerBit POS Status"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit POS Status';
            InitValue = 'Open';
        }

        field(2; "SeerBit Transaction Ref."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit Transaction Ref';

        }

        field(3; "SeerBit Transaction Id."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit Transaction Ref';

        }

        field(4; "SeerBit POS ID"; Code[50])
        {
            DataClassification = AccountData;
            Caption = 'SeerBit POS ID';

        }
        field(5; "SeerBit POS Trx. Time"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit POS Trx. Time';

        }
        field(6; "User Email"; Code[100])
        {
            DataClassification = CustomerContent;
            Caption = 'User Email';

        }
        field(7; "SeerBit - Invoice Number"; Code[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Invoice Number';
        }

        field(8; "SeerBit - Payment Date"; Text[23])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Payment Date';
        }

        field(9; "SeerBit - Invoice ID"; Text[23])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Invoice ID';
        }

        field(10; "SeerBit - Total Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; "SeerBit - Status"; Text[20])
        {
            DataClassification = CustomerContent;
        }

        field(12; "sent to seerbit"; Boolean)
        {
            DataClassification = CustomerContent;
        }

        field(13; paid; Boolean)
        {
            Caption = 'paid';
            DataClassification = CustomerContent;

        }
        field(14; Invoiceno; Code[20])
        {
            Caption = 'Invoiceno';
            DataClassification = CustomerContent;

        }
        field(15; "SeerBit - Batch ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Batch ID';
        }
        field(16; "SeerBit - Payment Method"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Payment Method';
        }
        field(17;"No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            InitValue = '';
        }
        field(18;"Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            InitValue = '';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Pk; "SeerBit - Invoice Number")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

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