/// <summary>
/// PageExtension sales order (ID 50139) extends Record Sales Order.
/// </summary>
pageextension 71855594
 "SBPsales order" extends "Sales Order"
{
    layout
    {
        addbefore("Sell-to Customer Name")
        {
            field("SBPSeerBit POS ID"; Rec."SBP SeerBit POS ID")
            {
                ApplicationArea = All;
                Caption = 'Select POS';
                ShowMandatory = true;
                ToolTip = 'SeerBit POS ID';

                trigger OnLookup(var Text: Text): Boolean
                var
                    ItemRec: Record SBPPOSDetailTable;
                begin
                    ItemRec.Reset();
                    ItemRec.SetRange("Location ID", locationid);
                    if Page.RunModal(Page::"SBP POS LIST", ItemRec) = Action::LookupOK then
                        Rec."SBP SeerBit POS ID" := ItemRec."POS id";
                    //"Select POS" := ItemRec."POS id";


                end;

            }
        }
        addbefore("Invoice Details")
        {

            group("SBPSeerBit POS")
            {
                Caption = 'SeerBit POS';

                field("SBPTransaction Status"; Rec."SBP SeerBit POS Status")
                {
                    Caption = 'Transaction Status';
                    Editable = false;
                    ToolTip = 'Transaction Status';
                    ApplicationArea = Suite;
                }
                field("SBPTransaction Time"; Rec."SBP SeerBit POS Trx. Time")
                {
                    Caption = 'Transaction Time';
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                }
                field("SBPPOS ID"; Rec."SBP SeerBit POS ID")
                {
                    Caption = 'POS ID';
                    Editable = false;
                    ApplicationArea = All;
                }
                field("SBPUser Name"; Rec."SBP User Email")
                {
                    Caption = 'User Name';
                    Editable = false;
                    ApplicationArea = All;
                }
                field("SBPTransaction Ref. No"; Rec."SBP SeerBit Transaction Ref.")
                {
                    Caption = 'Transaction Ref. No';
                    Editable = false;
                    ApplicationArea = All;
                }

                field("SBPTransaction Ref. ID"; Rec."SBP SeerBit Transaction Id.")
                {
                    Caption = 'Transaction Ref. Id';
                    Editable = false;
                    ApplicationArea = All;

                }




            }

        }

    }

    actions
    {
        /* modify("P&osting")
        {
            Enabled = false;
            Visible = false;
        }

        modify("Post")
        {
            Enabled = false;
        }
        modify(PostAndNew)
        {
            enabled = false;
        }
        modify(PostAndSend)
        {
            enabled = false;
            Visible = false;
        }

        modify(Action96)
        {
            enabled = false;
            Visible = false;
        } */



        addlast(processing)
        {

            group(SBPseerbit)
            {
                Caption = 'SeerBit POS';
                action(SBPseerbitpos)
                {
                    ApplicationArea = All;
                    Caption = 'SeerBit POS';
                    Image = Inventory;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Click here to send the required payment ammount to the selected SeerBit POS Terminal';
                    ShortcutKey = 'Ctrl+Shift+P'; // Assigning keyboard shortcut
                    trigger OnAction()


                    begin
                        transactionSatus := 'Open';
                        SendTOAPI()
                    end;


                }

                action(SBPCancel)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Transaction';
                    Image = CancelledEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'Ctrl+Shift+C'; // Assigning keyboard shortcut
                    ToolTip = 'Cancel the current POS transaction';

                    trigger OnAction()


                    begin
                        transactionSatus := 'Cancel';
                        SendTOAPI()
                    end;


                }

                action("SBPVerify Payment")
                {
                    Caption = 'Retrieve Payment';
                    ApplicationArea = All;
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortcutKey = 'Ctrl+Shift+V';
                    ToolTip = 'Verify POS payment and post sales';
                    trigger OnAction()
                    var
                        HttpClient: HttpClient;
                        content: HttpContent;
                        getContent: HttpContent;
                        contentHeaders: HttpHeaders;
                        getRequest: HttpRequestMessage;
                        request: HttpRequestMessage;
                        response: HttpResponseMessage;
                        jsonObj: JSONObject;
                        jsonToken: JsonToken;
                        EncryptedKey: Text;
                        getPayload: Text;
                        Payload: Text;
                        responseText: Text;
                        seerbInvoices: Record "SBP SeerBit Invoices";
                    begin
                        //MyGlobalCodeunit.MyProcedure(Pubkey, SECKey, Orgname);
                        //Message('Value 1: %1, Value 2: %2, Value 3: %3', Pubkey, SECKey, Orgname);
                        // Options := Text000;
                        // Sets the default to option 3  
                        // Selected := Dialog.StrMenu(Options, 1, Text002);
                        // / Text000: Label 'Successfull ,Transaction Declined ,Transactin Failed , Cancelled';
                        //IF Selected = 1 THEN BEGIN

                        Orgprofile.FindFirst();
                        // Initialize the HttpClient 
                        getPayload := '{';
                        getPayload += '"key": "' + Orgprofile.SBPSecKey + '.' + Orgprofile.SBPPublicKey + '"';
                        getPayload += '}';
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
                        //Message('Get response ' + responseText);
                        jsonObj.ReadFrom(responseText);
                        IF not jsonObj.Get('data', jsonToken) then
                            Error('Invalid response from server');
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
                        Payload += '"erpTransactionRef": "' + Rec."No." + '",';
                        payload += '"publickey": "' + Orgprofile.SBPPublicKey + '"';

                        Payload += '}';
                        content.WriteFrom(Payload);
                        // Message(Payload);
                        content.GetHeaders(contentHeaders);
                        contentHeaders.Clear();
                        content.GetHeaders(contentHeaders);
                        contentHeaders.Add('Content-Type', 'application/json');
                        request.Content := content;

                        request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/postransaction/verifytrasactionbyposid');
                        request.Method := 'POST';

                        HttpClient.Send(request, response);
                        if (response.HttpStatusCode() = 404) then begin
                            Error('No sales found');
                            exit;
                        end else
                            if (response.HttpStatusCode() = 500) then begin
                                Error('Error: ' + Format(response.HttpStatusCode()) + ' \Fatal error from server');
                                exit;
                            end;
                        // Read the response content as json.
                        responseText := '';
                        response.Content().ReadAs(responseText);
                        // Message('response ' + responseText);

                        jsonObj.ReadFrom(responseText);
                        IF jsonObj.Get('error', jsonToken) then
                            Error('Invalid response from server') else begin
                            IF jsonObj.Get('status', jsonToken) then begin
                                //Message('Transaction: ' + Format(jsonToken));
                                if jsonObj.Get('data', jsonToken) then jsonObj.ReadFrom(FORMAT(jsonToken));
                                //Message('response ' + FORMAT(jsonToken)); //get data
                                if jsonObj.Get('payments', Paymentstoken) then jsonObj.ReadFrom(FORMAT(Paymentstoken));
                                // Message('response ' + FORMAT(Paymentstoken)); //get payments
                                if jsonObj.Get('paymentReference', TransactionRefNoToken) then begin
                                    //jsonObj.ReadFrom(FORMAT(TransactionRefNoToken)); //get reference
                                    Message('response ' + FORMAT(TransactionRefNoToken).Replace('"', ''));
                                    Rec."SBP SeerBit Transaction Ref." := FORMAT(TransactionRefNoToken).Replace('"', '');
                                    Rec."SBP SeerBit POS Status" := 'Verified';
                                    Rec."SBP SeerBit - Invoice Number" := Rec."No.";
                                    Rec.Modify();
                                    seerbInvoices.Init();
                                    seerbInvoices."SeerBit POS ID" := Rec."SBP SeerBit POS ID";
                                    seerbInvoices."SeerBit Transaction Ref." := FORMAT(TransactionRefNoToken).Replace('"', '');
                                    seerbInvoices."SeerBit - Total Amount" := Rec."SBP SeerBit - Total Amount";
                                    seerbInvoices.Invoiceno := rec."No.";
                                    seerbInvoices."SeerBit - Invoice Number" := rec."No.";
                                    seerbInvoices.Insert();
                                    PostSalesOrder(CODEUNIT::"Sales-Post (Yes/No)", "Navigate After Posting"::"Posted Document");
                                end;
                            end
                        end;
                    end;

                }
            }
        }
    }

    var
        Orgprofile: Record "Company Information";
        locationid: Code[30];
        Paymentstoken: JsonToken;
        TransactionIdToken: JsonToken;
        TransactionRefNoToken: JsonToken;
        TransactionSentTimeToken: JsonToken;
        TransactionStatusToken: JsonToken;
        TransactionUserToken: JsonToken;
        transactionSatus: text;


    trigger OnOpenPage()
    var

        PosLocaton: Record "SBP Table POS Vendors";
        Userrecord: Record "User";
    begin
        PosLocaton.SetFilter("User ID", Userrecord."Authentication Email");
        POSLocaton.FindFirst();
        locationid := POSLocaton.LocationId

    end;

    local procedure SendTOAPI()
    var
        Orgprofile: Record "Company Information";
        PosDetailRec: Record SBPPOSDetailTable;

        salesHeader: Record "Sales Header";
        OrderRLine: Record "Sales Line";
        PosLocaton: Record "SBP Table POS Vendors";
        Userrecord: Record "User";
        MyGlobalCodeunit: Codeunit SBPSeerBitGlobalCodeunit;
        CustomerRecref: RecordRef;
        SalesHeaderRef: RecordRef;
        DocTypeRef: FieldRef;
        LinRef: FieldRef;
        MyFieldRef: FieldRef;
        Orgname: FieldRef;
        PosIdRef: FieldRef;

        Pubkey: FieldRef;

        SalesorderNoRef: FieldRef;
        SECKey: FieldRef;
        TransactionIdRef: FieldRef;
        TransactionRefNoRef: FieldRef;
        TransactionSentTimeref: FieldRef;
        TransactionStatusRef: FieldRef;
        TransactionUserRef: FieldRef;
        chk: Boolean;
        ConfirmResult: Boolean;
        SalesOrderNo: Code[20];
        SalesToCustomerNo: Code[20];

        varCustomerNo: Code[100];
        CurrentTimestamp: DateTime;
        Amt: Decimal;
        Amt2: Decimal;
        TotalAmt: Decimal;
        DataHttpClient: HttpClient;

        HttpClient: HttpClient;
        VerHttpClient: HttpClient;
        content: HttpContent;
        getContent: HttpContent;
        contentHeaders: HttpHeaders;
        getRequest: HttpRequestMessage;
        request: HttpRequestMessage;
        request2: HttpRequestMessage;
        Response: HttpResponseMessage;
        myInt: Integer;
        Selected: Integer;
        JObjectRequest: JsonObject;
        jsonObj: JsonObject;
        jsonToken: JsonToken;
        PosIdToken: JsonToken;
        TestActionLbl: Label 'Verify Transaction';
        Text000: Label 'Successfull ,Transaction Declined ,Transactin Failed , Cancelled';
        Text001: Label 'You selected option %1.';
        Text002: Label 'Choose POS transaction status:';
        EncryptedKey: Text;
        getPayload: Text;
        Payload: Text;
        PosIdText: Text;
        postresponseText: Text;
        RequestBody: Text;
        ResponseBody: Text;
        responseText: Text;

        TransactionUserText: Text;
        Options: Text[120];
    begin
        SalesHeaderRef.close();
        CustomerRecref.Close();
        IF Rec."SBP SeerBit POS ID" = '' then begin Error('Select a POS'); exit; end;
        salesHeader := Rec;
        SalesOrderNo := salesHeader."No.";
        CurrentTimestamp := CurrentDateTime;
        SalesToCustomerNo := salesHeader."Sell-to Customer No.";
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
        if transactionSatus = 'Open' then Message('Total sales amount ' + FORMAT(TotalAmt) + ' Sent to POS ' + Rec."SBP SeerBit POS ID") else if not Confirm('Cancel pending transaction on POS ' + Rec."SBP SeerBit POS ID") then exit;
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
            //Message('Get response ' + responseText);
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
                Payload += '"pubkey" : "' + Orgprofile.SBPPublicKey + '",';
                payload += '"id" :  "' + Rec."No." + '",';
                Payload += '"posid": "' + Rec."SBP SeerBit POS ID" + '",';
                Payload += '"status": "' + transactionSatus + '",';
                Payload += '"merchantid": "' + Userrecord."User Name" + '",';
                Payload += '"transactionId": "' + Rec."No." + '",';
                payload += '"senTime": "' + Format(CurrentDateTime) + '",';
                payload += '"receivDateTime":"receivDateTime",';
                payload += '"transactionValue": "' + Format(TotalAmt).Replace(',', '') + '",';
                Payload += '"transactionRef":"' + SalesOrderNo + '"';
                Payload += '}';
                content.WriteFrom(Payload);
                Message(Payload);
                // Retrieve the contentHeaders associated with the content
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

                if postresponseText = 'Wait' then begin
                    transactionSatus := 'Wait';
                    Message('Please wait or cancel the pending transation on POS ' + Rec."SBP SeerBit POS ID");
                end else
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
                ///TransactionStatusRef := SalesHeaderRef.Field(501351);
                //PosIdRef := SalesHeaderRef.Field(501354);

                SalesorderNoRef.Value := SalesOrderNo;
                salesHeader.SetCurrentKey("No.", "Document Type");
                salesHeader.FindSet;
                DocTypeRef.Value := "Sales Document Type"::Order;
                salesHeader.SetRange("No.", SalesOrderNo, SalesOrderNo);
                salesHeader.SetFilter("Document Type", FORMAT("Sales Document Type"::Order));
                salesHeader.SetFilter("No.", FORMAT(SalesOrderNo));
                salesHeader.SetCurrentKey("No.");
                if salesHeader.FindSet() then begin
                    salesHeader."SBP User Email" := Userrecord."Authentication Email";
                    salesHeader."SBP SeerBit POS ID" := Rec."SBP SeerBit POS ID";
                    salesHeader."SBP sent to seerbit" := true;
                    salesHeader.Modify(true);
                    if (transactionSatus = 'Open') then Message('Please click on verify to complete the sales order and print receipt') else Error(transactionSatus);
                    //If Message(Text001, Selected);

                    // Check the result of the confirm dialog
                end;
            end;

            // Show the confirm dialog with a custom message


        end;
    end;



}
