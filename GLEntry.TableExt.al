/// <summary>
/// TableExtension G/L Entry (ID 50137) extends Record G/L Entry.
/// </summary>
tableextension 71855613
 "SBPG/L Entry" extends "G/L Entry"
{
    fields
    {
        field(71855601; "SBP SeerBit - Tx. Refenece"; Text[50])
        {
            DataClassification = CustomerContent;
            Description = 'Transaction reference number for every payment recieved by SeerBit';

        }
        field(71855602; "SBP SeerBit - Payment Date"; Text[50])
        {
            DataClassification = CustomerContent;
            Description = 'Date payment was recieved by SeerBit';

        }
    }


}