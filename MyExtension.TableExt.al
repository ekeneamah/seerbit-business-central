/// <summary>
/// TableExtension MyExtension (ID 50145) extends Record Gen. Journal Line.
/// </summary>
tableextension 71855612
 SBPMyExtension extends "Gen. Journal Line"
{

    fields
    {
        field(71855611; "SBPSeerBit - Tx. Refenece"; Text[50])
        {
            DataClassification = CustomerContent;
            Description = 'Transaction reference number for every payment recieved by SeerBit';

        }
        field(71855612; "SBPSeerBit - Payment Date"; Text[50])
        {
            DataClassification = CustomerContent;
            Description = 'Date payment was recieved by SeerBit';

        }
        field(71855613; "SBPSeerBit -Doc. Type"; Text[50])
        {
            DataClassification = CustomerContent;
            Description = 'The payment type which can be Virtual Account or Payment Link';

        }
    }


}