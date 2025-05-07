/// <summary>
/// Table POSDetailTable (ID 50100).
/// </summary>
table 71855606
 SBPPOSDetailTable
{
    DataClassification = CustomerContent;
    Caption = 'POS Terminals';

    fields
    {
        field(1; RecId; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = true;

        }
        field(2; "POS id"; Code[10])
        {
            DataClassification = CustomerContent;
            NotBlank = true;


        }
        field(3; "Location"; Text[50])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "SBP Pos location table".Description;


        }
        field(4; "Location ID"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "SBP Pos location table".LocationId;


        }
    }

    keys
    {
        key(Key1; RecId)
        {
            Clustered = true;
        }
        key(Uk; "POS id")
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