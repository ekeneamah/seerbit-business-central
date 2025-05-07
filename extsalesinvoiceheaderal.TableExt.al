/// <summary>
/// TableExtension ext.salesinvoiceheader.al (ID 50109) extends Record Sales Invoice Header.
/// </summary>
tableextension 71855602
 "SBP ext.salesinvoiceheader.al" extends "Sales Invoice Header"
{

    fields
    {
        field(71855601; "SBP sent to seerbit"; Boolean)
        {
            Caption = 'sent to seerbit';
            DataClassification = CustomerContent;
            AccessByPermission = TableData "Sales Invoice Header" = RIMD;
        }
        field(71855602; SBPpaid; Boolean)
        {
            Caption = 'paid';
            DataClassification = CustomerContent;

        }
        field(71855603; "SBP total amount"; Code[200])
        {
            Caption = 'Total amount';
            DataClassification = CustomerContent;
        }
        field(71855604; "SBP Bill-to E-Mail"; code[200])
        {
            Caption = 'Customer Email';
            DataClassification = CustomerContent;
        }
        field(71855605; "SBP Date Of Payment"; Date)
        {
            Caption = 'Date of payment';
            DataClassification = CustomerContent;
        }
        field(71855619; "SBPSeerBitPaymentRef"; Code[50])
        {
            Caption = 'SeerBit - Payment Reference';
            DataClassification = CustomerContent;
        }
        field(71855606; "SBP SeerBit - PaymentRef"; Date)
        {
            Caption = 'SeerBitPayment Reference';
            DataClassification = CustomerContent;
        }
        field(71855607; "SBP SeerBit - Invoice Number"; Code[30])
        {
            Caption = 'SeerBit -Invoice Number';
            DataClassification = CustomerContent;
        }

        field(71855608; "SBP SeerBit - Invoice ID"; Code[10])
        {
            Caption = 'SeerBit -Invoice ID';
            DataClassification = CustomerContent;
        }
        field(71855609; "SBP SeerBit - Total Amount"; Decimal)
        {
            Caption = 'SeerBit -Total Amount';
            DataClassification = CustomerContent;
        }

        field(71855610; "SBP SeerBit - Status"; Text[10])
        {
            Caption = 'Payment Status';
            DataClassification = CustomerContent;
        }
        field(71855611; "SBP SeerBit - Payment Date"; Text[20])
        {
            Caption = 'Payment Date';
            DataClassification = CustomerContent;
        }
        field(71855612; "SBP SeerBit - POS ID"; Text[50])
        {
            Caption = 'SeerBit POS ID';
            DataClassification = CustomerContent;
        }

    }

    trigger OnAfterInsert()
    var
        salesInvoiceHeader: Record "Sales Invoice Header";
        salesHeader: Record "Sales Header";
        seerbitInvoices: Record "SBP SeerBit Invoices";
        sendPostedSalesInvoice: Codeunit SBPSendPostedSalesInvoice;
        invoiceno: Text;
    begin
        Message('Sales header ' + Rec."No.");
        //  if Rec."Posting Description".Contains('Invoice') then invoiceno := Rec."Posting Description".Replace('Invoice ', '') else invoiceno := Rec."Posting Description".Replace('Order ', '');
        sendPostedSalesInvoice.validatepayment(Rec, invoiceno);

    end;

}
