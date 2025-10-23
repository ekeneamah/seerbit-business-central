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
            // Remove table relation - will be populated from page lookup
        }
        field(71855604; "User ID"; Text[100])
        {
            DataClassification = CustomerContent;
            // Remove table relation - will be handled in page lookup
        }

        field(71855611; "Full Name"; Text[100])
        {
            DataClassification = CustomerContent;
            // Remove table relation - will be populated from page lookup
        }
        field(71855605; "Email"; Text[100])
        {
            DataClassification = CustomerContent;
            // Remove table relation - will be populated from page lookup
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
        // Allow partial insert - validation will happen when user completes the record
    end;

    trigger OnModify()
    begin
        // Only validate if both fields have values (user is completing the record)
        if ("User ID" <> '') and (LocationId = '') then
            Error('Location must be selected when User ID is specified.');
        if (LocationId <> '') and ("User ID" = '') then
            Error('User ID must be selected when Location is specified.');
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ValidateRecord()
    begin
        if "User ID" = '' then
            Error('User ID is required.');
        if LocationId = '' then
            Error('Location is required.');
    end;

}