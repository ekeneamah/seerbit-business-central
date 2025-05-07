/// <summary>
/// PageExtension General Journal Ext (ID 50136) extends Record General Journal.
/// </summary>
pageextension 71855590
 "SBPGeneral Journal Ext" extends "General Journal"
{
    layout
    {
        addafter(AccountName)
        {
            field("SBP Line No"; Rec."Line No.")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Line No';
                ToolTip = 'Line No.';

            }
            field("SBP SeerBit"; Rec."SBPSeerBit - Tx. Refenece")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Seerbit - Tx. Reference';
                ToolTip = 'Seerbit - Tx. Reference';

            }
            field("SBP SeerBit Tx. Date"; Rec."SBPSeerBit - Payment Date")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Seerbit Tx. Date';
                ToolTip = 'Seerbit - Tx. Date';

            }
            field("SBPSeerBit - Document Type"; Rec."SBPSeerBit -Doc. Type")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Seerbit - Document Type';
                ToolTip = 'Seerbit - Document Type';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}