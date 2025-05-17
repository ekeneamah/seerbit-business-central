/// <summary>
/// TableExtension Sales Header Ext (ID 50135) extends Record Sales Header.
/// </summary>
tableextension 71855614
 "SBP Sales Header Ext" extends "Sales Header"
{
    fields
    {
        // Add changes to table fields here
        field(71855614; "SBP SeerBit POS Status"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit POS Status';
            InitValue = 'Open';
        }

        field(71855612; "SBP SeerBit Transaction Ref."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit Transaction Ref';

        }

        field(71855613; "SBP SeerBit Transaction Id."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit Transaction Ref';

        }

        field(71855615; "SBP SeerBit POS ID"; Code[50])
        {
            DataClassification = AccountData;
            Caption = 'SeerBit POS ID';

        }
        field(71855616; "SBP SeerBit POS Trx. Time"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit POS Trx. Time';

        }
        field(71855617; "SBP User Email"; Code[100])
        {
            DataClassification = CustomerContent;
            Caption = 'User Email';

        }
        field(71855618; "SBP SeerBit - Invoice Number"; Code[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Invoice Number';
        }

        field(71855619; "SBP SeerBit - Payment Date"; Text[23])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Payment Date';
        }

        field(71855610; "SBP SeerBit - Invoice ID"; Text[23])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Invoice ID';
        }

        field(71855621; "SBP SeerBit - Total Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(71855622; "SBP SeerBit - Status"; Text[20])
        {
            DataClassification = CustomerContent;
        }

        field(71855623; "SBP sent to seerbit"; Boolean)
        {
            DataClassification = CustomerContent;
        }

        field(71855624; SBPpaid; Boolean)
        {
            Caption = 'paid';
            DataClassification = CustomerContent;

        }
        field(71855625; "SBP SeerBit - Batch ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Batch ID';
            InitValue = 'NA';
        }
        field(71855626; "SBP SeerBit - Payment Method"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'SeerBit - Payment Method';
            InitValue = 'NA';
        }
         field(71855627; "SBP SeerBit - Date Sent"; Text[23])
        {
            DataClassification = CustomerContent;
            Caption = 'Date Sent to SeerBit';
            InitValue = 'NA';
        }

    }



    var
        myInt: Integer;



}