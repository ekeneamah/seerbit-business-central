/// <summary>
/// Table Table POS Vendors (ID 50102).
/// </summary>
table 71855608
 "SBP Table POS Vendors"
{
    DataClassification = CustomerContent;
    Caption = 'POS Vendors';

    fields
    {
        field(71855601; RecId; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;

        }
        field(71855602; LocationId; Code[30])
        {
            DataClassification = CustomerContent;
            TableRelation = "SBP Pos location table".LocationId;
        }
        field(71855603; LocationName; Text[30])
        {
            DataClassification = CustomerContent;
            TableRelation = "SBP Pos location table".Description;
        }
        field(71855604; "User ID"; Text[100])
        {
            DataClassification = CustomerContent;
            TableRelation = User."Authentication Email";
        }

        field(71855611; "Full Name"; Text[100])
        {
            DataClassification = CustomerContent;
            TableRelation = User."Full Name";
        }
        field(71855605; "Email"; Text[100])
        {
            DataClassification = CustomerContent;
            TableRelation = User."Authentication Email";
        }


    }

    keys
    {
        key(Key1; RecId)
        {
            Clustered = true;
        }
        Key(uk; "User ID")
        {
            Unique = true;
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