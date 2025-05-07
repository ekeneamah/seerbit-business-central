/// <summary>
/// PageExtension sales invoice (ID 50130) extends Record Sales Invoice.
/// </summary>
pageextension 71855617
 "SBP sales invoice" extends "Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("SBP Customer Email"; Rec."Sell-to E-Mail")
            {
                Caption = 'Customer Email';
                Editable = true;
                Enabled = true;
                ToolTip = 'Email of the Customer you sent the invoice to';
                ApplicationArea = ALL;
                trigger OnAssistEdit()
                var
                    ItemRec: Record Customer;
                begin
                    ItemRec.Reset();
                    if Page.RunModal(Page::"Customer List", ItemRec) = Action::LookupOK then begin
                        Rec."Sell-to E-Mail" := ItemRec."E-Mail";
                    end;

                end;
            }
        }

        addafter("Invoice Details")
        {
            group("SBP SBPSeerBit Details")
            {
                Caption = 'SeerBit Details';
                field("SBP Sent by Serbit"; Rec."SBP sent to seerbit")
                {
                    Caption = 'Sent via SeerBit';
                    ToolTip = 'Invoices sent to customer through seerbit payment gateway';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("SBP paymnet by Serbit"; Rec.SBPpaid)
                {
                    Caption = 'Recieved by SeerBit';
                    ToolTip = 'Invoices whose payments have been received by seerbit payment gateway';
                    ApplicationArea = All;
                    Editable = false;

                }
                field("SBP SeerBit - Status"; Rec."SBP SeerBit - Status")
                {
                    Caption = 'SeerBit - Status';
                    ToolTip = 'Payment status of invoice';
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SBP Invoice Ref. Number"; Rec."SBP SeerBit - Invoice Number")
                {
                    Caption = 'Invoice Ref. Number';
                    ToolTip = 'SeerBit reference number to the invoice sent to the customer';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("SBP Invoice ID"; Rec."SBP SeerBit - Invoice ID")
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
            group("SBP SeerBit Invoice")
            {
                Image = Accounts;
                Caption = 'SeerBit Invoice';
                ToolTip = 'Use seerbit invoice management service to manage this invoice.';
                actionref("SBPSend by serbit"; SBPsend)
                {

                }
                actionref("SBPre-Send by serbit"; "SBPResend")
                { }
                actionref("SBPRetrieve Payment & Post"; SBPRetrievePayment)
                { }
                /*   group("SBP Payment Details")
                  {
                      Image = ViewDetails;
                      actionref("Get By Invoice No."; "Invoice Number")
                      { }
                      actionref("Get By Order Number"; "By Order Number")
                      { }

                  } */
            }

        }
        addafter(Approvals)
        {
            action(SBPsend)
            {
                Caption = 'Send to customer';
                ApplicationArea = All;
                Image = SalesInvoice;
                Visible = Rec."SBP SeerBit - Invoice Number" = '';

                ToolTip = 'Send the invoice to the customer through seerbit platform. You will be notifed when the invoice is paid by the customer.';
                trigger OnAction()
                var
                    SalesInvoice: Record "Sales Header";
                    SalesOrderNo: Code[20];
                    AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;
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


                trigger OnAction()
                var
                    SalesInvoice: Record "Sales Header";
                    SalesOrderNo: Code[20];
                    AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;
                    Actiontype: Text;
                begin
                    Actiontype := 'Re-send an Invoice';
                    SalesInvoice := Rec;
                    SalesOrderNo := SalesInvoice."No.";
                    AppMgmtInstance.sendToAPI(SalesOrderNo, Actiontype, Rec."SBP SeerBit - Invoice Number");
                    // SendToAPI(SalesOrderNo)
                end;


            }
            action(SBPRetrievePayment)
            {

                Caption = 'Retrieve Payment & Post';
                ApplicationArea = All;
                Image = Order;
                AboutTitle = 'When all is set, you post';
                AboutText = 'After entering the sales lines and other information, you post the invoice to make it count.? After posting, the sales invoice is moved to the Posted Sales Invoices list.';
                ToolTip = 'Finalize the document or journal by retrieving the payment from SeerBit and posting the amounts and quantities to the related accounts in your company books.';
                Visible = Rec."SBP SeerBit - Invoice Number" <> '';
                trigger OnAction()
                var
                    SalesInvoice: Record "Sales Header";
                    SalesOrderNo: Code[20];
                    AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;
                    Actiontype: Text;
                    ReturnValue: Boolean;
                begin
                    Actiontype := 'Get invoice by InvoiceNo';
                    SalesInvoice := Rec;
                    SalesOrderNo := SalesInvoice."No.";


                    ReturnValue := AppMgmtInstance.sendToAPI(SalesOrderNo, Actiontype, Rec."SBP SeerBit - Invoice Number");
                    // SendToAPI(SalesOrderNo)
                    if returnValue then CallPostDocument(CODEUNIT::"Sales-Post (Yes/No)", "Navigate After Posting"::"Posted Document");

                end;


            }
            group("SBP Get Payment details")
            {

                action("SBPBy Order Number")
                {

                    Caption = 'By Order Number';
                    ApplicationArea = All;
                    Image = Order;
                    trigger OnAction()
                    var
                        SalesInvoice: Record "Sales Header";
                        SalesOrderNo: Code[20];
                        AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;
                        Actiontype: Text;
                    begin
                        Actiontype := 'Get invoice by orderNo';
                        SalesInvoice := Rec;
                        SalesOrderNo := SalesInvoice."No.";
                        AppMgmtInstance.sendToAPI(SalesOrderNo, Actiontype, Rec."SBP SeerBit - Invoice Number");
                        // SendToAPI(SalesOrderNo)
                    end;


                }
                action("SBPInvoice Number")
                {
                    Caption = 'By Invoice Number';
                    ApplicationArea = All;
                    Image = Invoice;
                    trigger OnAction()
                    var
                        SalesInvoice: Record "Sales Header";
                        SalesOrderNo: Code[20];
                        AppMgmtInstance: Codeunit SBPSendPostedSalesInvoice;
                        Actiontype: Text;
                    begin
                        Actiontype := 'Get invoice by InvoiceNo';
                        SalesInvoice := Rec;
                        SalesOrderNo := Rec."No.";
                        //Message(Format(SalesOrderNo));
                        AppMgmtInstance.sendToAPI(SalesOrderNo, Actiontype, Rec."SBP SeerBit - Invoice Number");
                        // SendToAPI(SalesOrderNo)
                    end;


                }
            }

        }
    }

    local procedure SendTOAPI()
    var
        myInt: Integer;
        TestActionLbl: Label 'Verify Transaction';

        OrderHeader: Record "Sales Header";
        OrderRLine: Record "Sales Line";
        Orgprofile: Record "Company Information";
        Userrecord: Record "User";
        PosLocaton: Record "SBP Table POS Vendors";
        PosDetailRec: Record SBPPOSDetailTable;
        SalesOrderNo: Code[20];
        SalesToCustomerNo: Code[20];
        Amt: Decimal;
        Amt2: Decimal;
        Options: Text[120];
        Selected: Integer;
        Text000: Label 'Successfull ,Transaction Declined ,Transactin Failed , Cancelled';
        Text001: Label 'You selected option %1.';
        Text002: Label 'Choose POS transaction status:';
        CustomerRecref: RecordRef;
        TransactionIdRef: FieldRef;
        TransactionRefNoRef: FieldRef;
        TransactionUserRef: FieldRef;
        TransactionSentTimeref: FieldRef;
        TransactionStatusRef: FieldRef;
        PosIdRef: FieldRef;

        TransactionUserText: Text;

        SalesorderNoRef: FieldRef;
        PosIdToken: JsonToken;
        PosIdText: Text;
        SalesHeaderRef: RecordRef;
        MyFieldRef: FieldRef;
        DocTypeRef: FieldRef;
        LinRef: FieldRef;
        TotalAmt: Decimal;

        varCustomerNo: Code[100];
        ConfirmResult: Boolean;

        HttpClient: HttpClient;
        DataHttpClient: HttpClient;
        VerHttpClient: HttpClient;
        Response: HttpResponseMessage;
        Payload: Text;
        getPayload: Text;
        request: HttpRequestMessage;
        request2: HttpRequestMessage;
        getRequest: HttpRequestMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        getContent: HttpContent;
        responseText: Text;
        postresponseText: Text;
        ResponseBody: Text;
        RequestBody: Text;
        EncryptedKey: Text;
        jsonObj: JsonObject;
        jsonToken: JsonToken;
        JObjectRequest: JsonObject;
        chk: Boolean;
        CurrentTimestamp: DateTime;
        MyGlobalCodeunit: Codeunit SBPSeerBitGlobalCodeunit;

        Pubkey: FieldRef;
        SECKey: FieldRef;
        Orgname: FieldRef;
    begin
        SalesHeaderRef.close();
        CustomerRecref.Close();
        IF Rec."SBP SeerBit POS ID" = '' then begin Error('Select a POS'); exit; end;
        OrderHeader := Rec;
        SalesOrderNo := OrderHeader."No.";
        CurrentTimestamp := CurrentDateTime;
        SalesToCustomerNo := OrderHeader."Sell-to Customer No.";
        CustomerRecref.open(37);
        SalesHeaderRef.open(36);
        OrderRLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        OrderRLine."Document Type" := "Sales Document Type"::Order;
        MyFieldRef := CustomerRecref.Field(3);
        DocTypeRef := CustomerRecref.Field(1);
        LinRef := CustomerRecref.Field(4);

        MyFieldRef.VALUE := SalesOrderNo;
        DocTypeRef.Value := "Sales Document Type"::Order;
        OrderRLine.SetRange("Line No.", 10000, 100000);
        OrderRLine.SetFilter("Document Type", FORMAT("Sales Document Type"::Order));
        OrderRLine.SetFilter("Document No.", FORMAT(SalesOrderNo));
        OrderRLine.SetCurrentKey("Line No.");
        OrderRLine.FindSet();
        LinRef.Value := OrderRLine."Line No.";
        TotalAmt := 0;
        repeat
            TotalAmt := OrderRLine."Amount Including VAT" + TotalAmt;
        UNTIL OrderRLine.NEXT = 0;
        if transactionSatus = 'Open' then begin if not confirm('Total sales amount ' + FORMAT(TotalAmt) + '\ Send to POS ' + Rec."SBP SeerBit POS ID") then exit end else if not Confirm('Cancel pending transaction on POS ' + Rec."SBP SeerBit POS ID") then exit;
        SalesHeaderRef.close();
        CustomerRecref.Close();
        CurrentTimestamp := CurrentDateTime;
        // Initialize the HttpClient 


        begin
            Orgprofile.FindFirst();
            // Initialize the HttpClient 
            getPayload := '{';
            getPayload += '"key": "' + Orgprofile.SBPSecKey + '.' + Orgprofile.SBPPublicKey + '"';
            getPayload += '}';
            getContent.WriteFrom(getPayload);
            getContent.WriteFrom(getPayload);
            // HttpClient.GET('https://seerbitapi.com/api/v2/encrypt/keys' + RequestBody, response);
            getContent.GetHeaders(contentHeaders);
            contentHeaders.Clear();
            contentHeaders.Add('Content-Type', 'application/json');

            // Assigning content to request.Content will actually create a copy of the content and assign it.
            // After this line, modifying the content variable or its associated headers will not reflect in 
            // the content associated with the request message
            getRequest.Content := getContent;

            getRequest.SetRequestUri('https://seerbitapi.com/api/v2/encrypt/keys');
            getRequest.Method := 'Options';

            HttpClient.Send(getRequest, response);

            // Read the response content as json.
            response.Content().ReadAs(responseText);
            // Message('Get response ' + responseText);
            chk := jsonObj.ReadFrom(responseText);
            IF not jsonObj.Get('data', jsonToken) then begin

                Error('Invalid response from server');
            end
            else begin
                // getRequest.Content().Clear();
                jsonObj.Get('data', jsonToken);
                jsonObj.ReadFrom(Format(jsonToken));
                jsonObj.Get('EncryptedSecKey', jsonToken);
                jsonObj.ReadFrom(Format(jsonToken));
                jsonObj.Get('encryptedKey', jsonToken);
                EncryptedKey := Format(jsonToken);

                Payload := '{';
                Payload += '"token": ' + EncryptedKey + ',';
                payload += '"id" : "id",';
                Payload += '"posid": "' + Rec."SBP SeerBit POS ID" + '",';
                Payload += '"status": "' + transactionSatus + '",';
                Payload += '"merchatTerminalId": "' + Userrecord."User Name" + '",';
                Payload += '"transactionId": "' + Rec."No." + '",';
                payload += '"senTime": "' + Format(CurrentDateTime) + '",';
                payload += '"receivDateTime":"receivDateTime",';
                payload += '"transactionValue": "' + Format(TotalAmt).Replace(',', '') + '",';
                Payload += '"erpTransactionRef":"' + SalesOrderNo + '"';
                Payload += '}';
                content.WriteFrom(Payload);
                // Retrieve the contentHeaders associated with the content
                //Message(Payload);
                content.GetHeaders(contentHeaders);
                contentHeaders.Clear();
                content.GetHeaders(contentHeaders);
                contentHeaders.Add('Content-Type', 'application/json');
                request.Content := content;

                request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/postransaction');
                request.Method := 'POST';

                DataHttpClient.Send(request, response);

                // Read the response content as json.
                response.Content().ReadAs(postresponseText);
                // Message(postresponseText);

                chk := jsonObj.ReadFrom(postresponseText);

                //HttpClient.Clear();
                //request.Content.Clear();
                SalesHeaderRef.open(36);
                SalesorderNoRef := SalesHeaderRef.Field(3);
                DocTypeRef := SalesHeaderRef.Field(1);
                // TransactionIdRef := SalesHeaderRef.Field(501353);
                //TransactionRefNoRef := SalesHeaderRef.Field(501352);
                //TransactionUserRef := SalesHeaderRef.Field(501356);
                //TransactionSentTimeref := SalesHeaderRef.Field(501355);
                //TransactionStatusRef := SalesHeaderRef.Field(501351);
                //PosIdRef := SalesHeaderRef.Field(501354);

                SalesorderNoRef.Value := SalesOrderNo;
                OrderHeader.SetCurrentKey("No.", "Document Type");
                OrderHeader.FindSet;
                DocTypeRef.Value := "Sales Document Type"::Order;
                OrderHeader.SetRange("No.", SalesOrderNo, SalesOrderNo);
                OrderHeader.SetFilter("Document Type", FORMAT("Sales Document Type"::Order));
                OrderHeader.SetFilter("No.", FORMAT(SalesOrderNo));
                OrderHeader.SetCurrentKey("No.");
                if OrderHeader.FindSet() then begin
                    OrderHeader."SBP User Email" := Userrecord."Authentication Email";
                    OrderHeader."SBP SeerBit POS ID" := Rec."SBP SeerBit POS ID";
                    OrderHeader.Modify(true);
                    if (transactionSatus = 'Open') then Message('Please click on verify to complete the sales order and print receipt') else Error(transactionSatus);
                    //If Message(Text001, Selected);

                    // Check the result of the confirm dialog
                end;
            end;

            // Show the confirm dialog with a custom message


        end;
    end;

    var
        locationid: Code[30];
        transactionSatus: text;
        TransactionIdToken: JsonToken;
        TransactionRefNoToken: JsonToken;
        Paymentstoken: JsonToken;
        TransactionUserToken: JsonToken;
        TransactionSentTimeToken: JsonToken;
        TransactionStatusToken: JsonToken;
        Orgprofile: Record "Company Information";
        salesinvoiceheader: Record "Sales Invoice Header";


    /**  trigger OnOpenPage()
      var

          Userrecord: Record "User";
          PosLocaton: Record "SBP Table POS Vendors";
      begin
          PosLocaton.SetFilter("User ID", Userrecord."Authentication Email");
          POSLocaton.FindFirst();
          locationid := POSLocaton.LocationId

      end;
      **/



}
