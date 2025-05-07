/// <summary>
/// PageExtension Posted Sales Invoice (ID 50141) extends Record Posted Sales Invoice.
/// </summary>
pageextension 71855592
 "SBPPosted Sales Invoice" extends "Posted Sales Invoice"
{

    layout
    {
        addafter(Closed)
        {
            field("SBPSBPCustomer Email"; Rec."Sell-to E-Mail")
            {
                Caption = 'Customer Email';
                Editable = false;
                Enabled = true;
                ToolTip = 'Email of the Customer to send the invoice to';
                ApplicationArea = ALL;

            }
        }
        addafter("Invoice Details")
        {
            group("SBPSeerBit Details")
            {
                Caption = 'SeerBit Details';
                field("SBPSent by Serbit"; Rec."SBP sent to seerbit")
                {
                    Caption = 'Sent via SeerBit';
                    ToolTip = 'Invoices sent to customer through seerbit payment gateway';
                    ApplicationArea = All;
                }
                field("SBPpaymnet by Serbit"; Rec."SBPPaid")
                {
                    Caption = 'Recieved by SeerBit';
                    ToolTip = 'Invoices whose payments have been received by seerbit payment gateway';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("SBPStatus"; Rec."SBP SeerBit - Status")
                {
                    Caption = 'Status';
                    ToolTip = 'Payment status of invoice';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("SBPInvoice Payment Date"; Rec."SBP Date Of Payment")
                {
                    Caption = 'Payment Date';
                    ToolTip = 'Date SeerBit recieved the payment';
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("SBPInvoice Ref. Number"; Rec."SBPSeerBitPaymentRef")
                {
                    Caption = 'Payment Ref. Number';
                    ToolTip = 'SeerBit payment reference';
                    ApplicationArea = All;
                }
                field("SBPInvoice ID"; Rec."SBP SeerBit - Invoice ID")
                {
                    Caption = 'Invoice ID';
                    ToolTip = 'SeerBit ID of the invoice sent';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }


    actions
    {
        addfirst(Category_Process)
        {
            group("SBPSeerBit Invoice")
            {
                Image = Accounts;
                Caption = 'SeerBit Invoice';
                ToolTip = 'Use seerbit invoice management service to manage this invoice.';
                actionref("SBPGet By Invoice Number"; "SBPInvoice Number")
                { }
                group("SBPPayment Details")
                {

                    Visible = false;
                    Image = ViewDetails;
                    Caption = 'Payment Details';
                    actionref("SBPGet By Invoice No."; "SBPInvoice Number")
                    { }

                }
            }

        }
        addafter(Approvals)
        {
            action(SBPsend)
            {
                Caption = 'Send to customer';
                ApplicationArea = All;
                Image = SalesInvoice;

                ToolTip = 'Send the invoice to the customer through seerbit platform. You will be notifed when the invoice is paid by the customer.';
                trigger OnAction()
                var
                    SalesInvoice: Record "Sales Invoice Header";
                    AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;
                    SalesOrderNo: Code[20];

                    Actiontype: Text;
                begin
                    Actiontype := 'Create';
                    SalesInvoice := Rec;
                    SalesOrderNo := SalesInvoice."No.";
                    AppMgmtInstance.sendToAPI(SalesOrderNo, Actiontype, Rec."SBP SeerBit - Invoice Number");
                    // SendToAPI(SalesOrderNo)
                end;


            }
            action("SBPResend")
            {

                Caption = 'Re-send invoice';
                ApplicationArea = All;
                Image = SendApprovalRequest;
                ToolTip = 'Re-send invoice';


                trigger OnAction()
                var
                    SalesInvoice: Record "Sales Invoice Header";
                    AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;
                    SalesOrderNo: Code[20];

                    Actiontype: Text;
                begin
                    Actiontype := 'Re-send an Invoice';
                    SalesInvoice := Rec;
                    SalesOrderNo := SalesInvoice."No.";
                    AppMgmtInstance.sendToAPI(SalesOrderNo, Actiontype, Rec."SBP SeerBit - Invoice Number");
                    // SendToAPI(SalesOrderNo)
                end;


            }
            action("SBPInvoice Number")
            {
                Caption = 'Validate Payment';
                ToolTip = 'Validate Payment';
                ApplicationArea = All;
                Image = Invoice;
                trigger OnAction()
                var
                    salesheader: Record "Sales Header";
                    seerbitInvoices: Record "SBP SeerBit Invoices";

                    AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;

                    invoiceno: Text;
                begin
                    invoiceno := Rec."Posting Description".Replace('Invoice ', '');
                    AppMgmtInstance.validatepayment(Rec, invoiceno);

                end;


            }


        }
    }



    // local procedure SendToAPI(InvoiceNo: Code[20])

    trigger OnOpenPage()
    var

        sendPostedSalesInvoice: Codeunit SBPSendPostedSalesInvoice;
        invoiceno: Text;
    begin
        // Message('Sales header ' + Rec."No.");
        //  if Rec."Posting Description".Contains('Invoice') then invoiceno := Rec."Posting Description".Replace('Invoice ', '') else invoiceno := Rec."Posting Description".Replace('Order ', '');
        sendPostedSalesInvoice.update(Rec);


    end;


    local procedure GetInvoice(InvoiceNo: Code[20])

    var


        salesInvoiceHeader: Record "Sales Invoice Header";
        salesInvoiceLine: Record "Sales Invoice Line";
        companyInformation: Record "Company Information";
        httpResponseMessage: HttpResponseMessage;
        Payload: Text;
        InvoiceItems: Text;
        client: HttpClient;
        httpRequestMessage: HttpRequestMessage;
        contentHeaders: HttpHeaders;
        httpContent: HttpContent;
        responseText: Text;

        HttpClient: HttpClient;
    begin

        // Initialize the HttpClient
        //HttpClient.GET('https://api.example.com/initialize', Response);

        // Get the specific Posted Sales Invoice record
        salesInvoiceHeader.SETRANGE("No.", InvoiceNo);
        if salesInvoiceHeader.FINDSET() then begin
            // Prepare the payload
            Payload := '{';
            Payload += '"publicKey": "' + companyInformation.SBPPublicKey + '",';
            Payload += '"orderNo": "' + salesInvoiceHeader."No." + '",';
            Payload += '"dueDate": "' + FORMAT(salesInvoiceHeader."Due Date") + '",';
            Payload += '"currency": "' + salesInvoiceHeader."Currency Code" + '",';
            Payload += '"receiversName": "' + salesInvoiceHeader."Bill-to Name" + '",';
            Payload += '"customerEmail": "' + salesInvoiceHeader."SBP Bill-to E-Mail" + '",';
            Payload += '"invoiceItems": [';

            // Loop through the invoice lines and add them to the JSON payload
            salesInvoiceLine.SETRANGE("Document No.", salesInvoiceHeader."No.");
            if salesInvoiceLine.FINDSET() then
                repeat
                    // Add invoice line data to the JSON payload
                    InvoiceItems += '{';
                    InvoiceItems += '"itemName": "' + salesInvoiceLine.Description + '",';
                    InvoiceItems += '"quantity": "' + FORMAT(salesInvoiceLine.Quantity) + '",';
                    InvoiceItems += '"rate": "' + FORMAT(salesInvoiceLine."Unit Price").replace(',', '') + '",';
                    InvoiceItems += '"tax": "' + FORMAT(salesInvoiceLine."VAT %") + '"';
                    InvoiceItems += '},';
                until salesInvoiceLine.NEXT() = 0;


            // Remove the trailing comma if any
            IF STRLEN(InvoiceItems) > 0 THEN
                InvoiceItems := DELSTR(InvoiceItems, STRLEN(InvoiceItems), 1);

            // Complete the JSON payload
            Payload += InvoiceItems;
            Payload += ']';
            Payload += '}';
            //Message(Payload);
            httpContent.WriteFrom(payload);
            // Retrieve the contentHeaders associated with the content
            httpContent.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');

            // Assigning content to request.Content will actually create a copy of the content and assign it.
            // After this line, modifying the content variable or its associated headers will not reflect in 
            // the content associated with the request message
            httpRequestMessage.Content := httpContent;

            httpRequestMessage.SetRequestUri('https://catfact.ninja/fact');
            httpRequestMessage.Method := 'Get';

            client.Send(httpRequestMessage, httpResponseMessage);

            // Read the response content as json.
            httpResponseMessage.Content().ReadAs(responseText);
            // Message(responseText);
            IF httpResponseMessage.IsSuccessStatusCode THEN
                salesInvoiceHeader."SBP sent to seerbit" := True;
            salesInvoiceHeader.Modify() //Response.Content.ReadAs(responseText)


        END;
    end;


}
