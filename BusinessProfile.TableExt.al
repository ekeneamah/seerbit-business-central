/// <summary>
/// TableExtension Business Profile (ID 50129) extends Record Company Information.
/// </summary>
tableextension 71855609
 "SBPBusiness Profile" extends "Company Information"
{

    fields
    {

        field(71855601; "SBP Business Name"; Text[120])
        {
            DataClassification = CustomerContent;
            // InitValue = 'Seerbit Test';
        }

        field(71855602; SBPPublicKey; Text[200])
        {
            DataClassification = CustomerContent;
            // InitValue = 'SBTESTPUBK_hHxgwhHYIU7G9DqpOy4n2oT1XvSxjM6j';
        }

        field(71855603; SBPSecKey; Text[200])
        {
            DataClassification = CustomerContent;
            //InitValue = 'SBTESTSECK_feA0zl2qXRPx8VwXFVy1ljlfqqOnR0hYbM9Axf32';
        }

        field(71855604; "SBP Default Currency"; Code[10])
        {
            DataClassification = CustomerContent;
            InitValue = "NGN";
        }

        field(71855605; SBPPrefix; Text[10])
        {
            DataClassification = CustomerContent;

        }

        field(71855606; "SBP Business Email"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(71855609; SBPRecId; Integer)
        {
            DataClassification = CustomerContent;

        }
    }


}
