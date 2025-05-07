/// <summary>
/// PageExtension SBP Sales Order List (ID 50137) extends Record Sales Order List.
/// </summary>
pageextension 71855619
 "SBP Sales Order List" extends "Sales Order List"
{
    layout
    {
        addafter("No.")
        {
            field("SBP POS ID"; Rec."SBP SeerBit POS ID")
            {
                Caption = 'SeerBit - POS ID';
                ApplicationArea = All;
            }
            field("SBP Transaction Ref."; Rec."SBP SeerBit Transaction Ref.")
            {
                Caption = 'SeerBit - Tx. Ref.';
                ApplicationArea = All;
            }
            field("SBP Transaction Status"; Rec."SBP SeerBit POS Status")
            {
                Caption = 'SeerBit - Tx Status';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}