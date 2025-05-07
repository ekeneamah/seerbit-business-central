/// <summary>
/// PageExtension General Ledger Entries Ext (ID 50133) extends Record General Ledger Entries.
/// </summary>
pageextension 71855591
 "SBPGeneral Ledger Entries Ext" extends "General Ledger Entries"
{
    layout
    {
        addafter(Amount)
        {
            field("SBP SeerBit"; Rec."SBP SeerBit - Tx. Refenece")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Seerbit - Tx. Reference';
                ToolTip = 'Seerbit - Tx. Reference';

            }
            field("SBP SeerBit Tx. Date"; Rec."SBP SeerBit - Payment Date")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'SeerBit - Payment Date';
                ToolTip = 'SBP SeerBit - Payment Date';

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}