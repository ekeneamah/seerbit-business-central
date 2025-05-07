table 71855605
 SBPSalesInvoice
{
    DataClassification = CustomerContent;
    Caption = 'Sales Invoice';

    fields
    {
        field(1; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';

        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(3; "Posting Date"; DateTime)
        {
            Caption = 'Posting Date';
        }
        field(4; "Due Date"; DateTime)
        {
            Caption = 'Due Date';
        }
        field(5; "Currency Code"; Code[3])
        {
            Caption = 'Currency Code';
        }
        // Add more fields as per your requirements
    }

    keys
    {
        key(PK; "Invoice No.")
        {
            Clustered = true;
        }
    }
}
