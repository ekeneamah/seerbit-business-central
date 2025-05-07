/// <summary>
/// Table Pos location table (ID 50101).
/// </summary>
table 71855607
 "SBP Pos location table"
{
    DataClassification = CustomerContent;
    Caption = 'POS Locations';

    fields
    {
        field(71855607; RecId; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;

        }
        field(71855601; LocationId; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;

        }
        field(71855602; Description; Text[200])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }

    }

    keys
    {
        key(Key1; RecId)
        {
            Clustered = true;
        }
        key(Uk; LocationId)
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