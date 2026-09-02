/// <summary>
/// Codeunit SBPSendPostedSalesInvoice (ID 50133).
/// </summary>
codeunit 71855577 SBPSendPostedSalesInvoice
{
    Permissions =
        tabledata "Company Information" = RM,
        tabledata "Sales Header" = RM,
        tabledata "Sales Invoice Header" = RIMD,
        tabledata "Sales Line" = R,
        tabledata "SBP SeerBit Invoices" = RIM,
        tabledata "Payment Method" = R,
        tabledata "Cust. Ledger Entry" = R,
        tabledata "Gen. Journal Line" = RI;

    var

    /// <summary>
    /// sendToAPI.
    /// </summary>
    /// <param name="InvoiceNo">VAR Code[20].</param>
    /// <param name="actionType">VAR Text.</param>
    /// <param name="SeerBitInvoiceNo">VAR Code[20].</param>
    /// <returns>Return value of type Boolean.</returns>
    procedure sendToAPI(var InvoiceNo: Code[20]; var actionType: Text; var SeerBitInvoiceNo: Code[20]): Boolean
    var


        companyInformation: Record "Company Information";
        salesHeader: Record "Sales Header";
        RecordSalesInvoiceHeader: Record "Sales Invoice Header";
        RecordSalesLineInvoiceLine: Record "Sales Line";
        seerbitsalesinvoice: Record "SBP SeerBit Invoices";
        salespage: Page "Sales Invoice";
        chk: Boolean;
        client: HttpClient;
        HttpClient: HttpClient;
        content: HttpContent;
        getContent: HttpContent;
        contentHeaders: HttpHeaders;
        getRequest: HttpRequestMessage;
        request: HttpRequestMessage;
        Response: HttpResponseMessage;
        JObjectRequest: JsonObject;
        jsonObj: JsonObject;
        jsonToken: JsonToken;
        payloadToken: JsonToken;
        responseCodeToken: JSONToken;
        responsecreatedAtToken: JsonToken;
        responseInvoiceIDToken: JsonToken;
        responsestatusToken: JsonToken;
        responsetotalAmountToken: JsonToken;
        responsInvoiceNoToken: JSONToken;
        DateParts: List of [Text];
        data: Text;
        EncryptedKey: Text;
        getPayload: Text;
        InvoiceItems: Text;
        Payload: Text;


        PayloadJson: Text;
        postresponseText: Text;
        RequestBody: Text;
        ResponseBody: Text;
        responseText: Text;

    begin

        companyInformation.FindFirst();
        // Initialize the HttpClient 
        getPayload := '{';
        getPayload += '"key": "' + companyInformation.SBPSecKey + '.' + companyInformation.SBPPublicKey + '"';
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
        chk := jsonObj.ReadFrom(responseText);
        IF not jsonObj.Get('data', jsonToken) then
            Error('Invalid response from server');
        jsonObj.Get('data', jsonToken);
        jsonObj.ReadFrom(Format(jsonToken));
        jsonObj.Get('EncryptedSecKey', jsonToken);

        jsonObj.ReadFrom(Format(jsonToken));
        jsonObj.Get('encryptedKey', jsonToken);
        EncryptedKey := Format(jsonToken);
        // Message(EncryptedKey);
        // Get the specific Posted Sales Invoice record
        Payload := '{';
        Payload += '"token": ' + EncryptedKey + ',';
        Payload += '"publicKey":  "' + companyInformation.SBPPublicKey + '",';
        if actionType = 'Create' then begin
            salesHeader.SETRANGE("No.", InvoiceNo);
            IF salesHeader.FINDSET THEN BEGIN

                // Prepare the payload
                if salesHeader."Currency Code" = '' then begin
                    if companyInformation."SBP Default Currency" <> '' then salesHeader."Currency Code" := companyInformation."SBP Default Currency" else Error('Please set currency code');
                end;

                Payload += '"orderNo": "' + salesHeader."No." + '",';
                Payload += '"dueDate": "' + Format(salesHeader."Due Date", 10, 9) + '",';
                Payload += '"currency": "' + salesHeader."Currency Code" + '",';
                Payload += '"receiversName": "' + salesHeader."Sell-to Customer Name" + '",';
                Payload += '"customerEmail": "' + salesHeader."Sell-to E-Mail" + '",';
                Payload += '"invoiceItems": [';

                // Loop through the invoice lines and add them to the JSON payload
                RecordSalesLineInvoiceLine.SETRANGE("Document No.", salesHeader."No.");
                IF RecordSalesLineInvoiceLine.FINDSET THEN BEGIN
                    REPEAT
                        // Add invoice line data to the JSON payload
                        InvoiceItems += '{';
                        InvoiceItems += '"itemName": "' + RecordSalesLineInvoiceLine.Description + '",';
                        InvoiceItems += '"quantity": ' + FORMAT(RecordSalesLineInvoiceLine.Quantity) + ',';
                        InvoiceItems += '"rate": "' + FORMAT(RecordSalesLineInvoiceLine."Unit Price").replace(',', '') + '",';
                        InvoiceItems += '"tax": ' + FORMAT(RecordSalesLineInvoiceLine."VAT %") + '';
                        InvoiceItems += '},';
                    UNTIL RecordSalesLineInvoiceLine.NEXT = 0;
                END;

                // Remove the trailing comma if any
                IF STRLEN(InvoiceItems) > 0 THEN
                    InvoiceItems := DELSTR(InvoiceItems, STRLEN(InvoiceItems), 1);

                // Complete the JSON payload
                Payload += InvoiceItems;
                Payload += ']';



                //JObjectRequest.WriteTo(Payload);
                //content.WriteFrom(payload);
                PayloadJson := '{';
                PayloadJson += '"invoice": ' + Payload + '';
                PayloadJson += '}';
            end;
        end else

            if actionType <> 'Create' then begin
                // Load the sales header to get customer email
                salesHeader.SETRANGE("No.", InvoiceNo);
                IF salesHeader.FINDSET THEN BEGIN
                    // Invoice."SeerBit - Invoice Number" := 'SBT-INV-000392';
                    Payload += '"orderno": "' + Invoiceno + '",';
                    Payload += '"invoiceno": "' + SeerBitInvoiceNo + '",';
                    Payload += '"customerEmail": "' + salesHeader."Sell-to E-Mail" + '"';
                END ELSE BEGIN
                    // If sales header not found, send without email
                    Payload += '"orderno": "' + Invoiceno + '",';
                    Payload += '"invoiceno": "' + SeerBitInvoiceNo + '",';
                    Payload += '"customerEmail": ""';
                END;
            end;
        //JObjectRequest.WriteTo(PayloadJson);
        Payload += '}';
        content.WriteFrom(Payload);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        content.GetHeaders(contentHeaders);
        contentHeaders.Add('Content-Type', 'application/json');
        // contentHeaders.Add('Authorization', 'Bearer ' + EncryptedKey);
        //content.GetHeaders(contentHeaders);
        // Assigning content to request.Content will actually create a copy of the content and assign it.
        // After this line, modifying the content variable or its associated headers will not reflect in 
        // the content associated with the request message
        request.Content := content;

        if actionType.Contains('Get invoice by orderNo') then begin
            request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/getInvoiceByorderno');
        end
        else
            if actionType = 'Re-send an Invoice' then begin
                request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/resendInvoice');
            end
            else
                if actionType = 'Get invoice by InvoiceNo' then begin
                    request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/getInvoiceByInvoiceno');
                end
                else
                    if actionType = 'Create' then begin
                        request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/sendinvoice');
                    end;




        request.Method := 'POST';

        client.Send(request, response);

        // Read the response content as json.
        response.Content().ReadAs(postresponseText);
        jsonObj.ReadFrom(postresponseText);
        if not jsonObj.get('status', responsestatusToken) then begin
            if jsonObj.get('message', responsestatusToken) then
                Error(Format(responsestatusToken).Replace('"', ''))
            else
                Error('Invalid response from server.');
        end;
        if not actionType.Contains('Get invoice by InvoiceNo 2') then begin
            salesHeader.SetRange("No.", salesHeader."No.");
            salesHeader.SetFilter("No.", FORMAT(InvoiceNo));
            salesHeader.SetCurrentKey("No.");
            if actionType = 'Create' then begin
                if salesHeader.FindSet() then begin
                    IF jsonObj.get('code', responseCodeToken) THEN begin
                        jsonObj.get('code', responseCodeToken);
                        if Format(responseCodeToken).Replace('"', '') = '00' then begin
                            jsonObj.get('payload', jsonToken);
                            jsonObj.ReadFrom(Format(jsonToken));
                            if jsonObj.Get('InvoiceNo', responsInvoiceNoToken) then seerbitsalesinvoice."SeerBit - Invoice Number" := Format(responsInvoiceNoToken).Replace('"', '');
                            if jsonObj.Get('InvoiceNo', responsInvoiceNoToken) then salesHeader."SBP SeerBit - Invoice Number" := Format(responsInvoiceNoToken).Replace('"', '');
                            IF jsonObj.Get('InvoiceID', responseInvoiceIDToken) THEN salesHeader."SBP SeerBit - Invoice ID" := Format(responseInvoiceIDToken).Replace('"', '');
                            IF jsonObj.Get('status', responsestatusToken) THEN salesHeader."SBP SeerBit - Status" := Format(responsestatusToken).Replace('"', '');

                            IF jsonObj.Get('InvoiceID', responseInvoiceIDToken) THEN seerbitsalesinvoice."SeerBit - Invoice ID" := Format(responseInvoiceIDToken).Replace('"', '');
                            IF jsonObj.Get('totalAmount', responsetotalAmountToken) THEN seerbitsalesinvoice."SeerBit - Total Amount" := responsetotalAmountToken.AsValue().AsDecimal();
                            IF jsonObj.Get('status', responsestatusToken) THEN seerbitsalesinvoice."SeerBit - Status" := Format(responsestatusToken).Replace('"', '');
                            IF jsonObj.SelectToken('createdAt', responsecreatedAtToken) THEN begin
                                DateParts := responsecreatedAtToken.AsValue().AsText().Split('T');
                                seerbitsalesinvoice."SeerBit - Payment Date" := Format(DateParts.Get(1));

                            end;

                            seerbitsalesinvoice."sent to seerbit" := True;
                            salesHeader."SBP sent to seerbit" := true;
                            salesHeader."Currency Code" := salesHeader."Currency Code";
                            salesHeader."Payment Method Code" := 'SEERBIT';
                            seerbitsalesinvoice.Invoiceno := InvoiceNo;
                            //Message(Format(DateParts.Get(1)));

                            seerbitsalesinvoice.Insert();
                            salesHeader.modify(); //Response.Content.ReadAs(responseText)
                            Message('The invoice has been sent to the customer');
                        end else begin
                            IF jsonObj.Get('status', responsestatusToken) THEN salesHeader."SBP SeerBit - Status" := 'Error';//Format(responsestatusToken).Replace('"', '');
                            IF jsonObj.Get('status', responsestatusToken) THEN seerbitsalesinvoice."SeerBit - Status" := 'Error';// Format(responsestatusToken).Replace('"', '');
                            if jsonObj.get('message', responseCodeToken) then error('response ' + Format(responseCodeToken) + ' \Invoice has not been sent to customer');
                            if jsonObj.get('error', responseCodeToken) then error('response ' + Format(responseCodeToken) + ' \Invoice has not been sent to customer');
                            exit;
                        end;
                    end else begin
                        IF jsonObj.Get('status', responsestatusToken) THEN salesHeader."SBP SeerBit - Status" := 'Error';//Format(responsestatusToken).Replace('"', '');
                        IF jsonObj.Get('status', responsestatusToken) THEN seerbitsalesinvoice."SeerBit - Status" := 'Error';// Format(responsestatusToken).Replace('"', '');

                        jsonObj.get('error', responseCodeToken);
                        error('response ' + Format(responseCodeToken) + ' \Invoice has not been sent to customer');
                        exit;
                    end;
                end
            end
            else
                if actionType = 'Get invoice by InvoiceNo' then begin
                        if jsonObj.Get('payload', payloadToken) then begin
                            jsonObj.ReadFrom(Format(payloadToken));
                            jsonObj.Get('status', responsestatusToken);
                            salesHeader.Reset();
                            salesHeader.SetRange("No.", InvoiceNo);
                            if salesHeader.FindFirst() then begin
                                IF jsonObj.Get('status', responsestatusToken) THEN begin
                                    salesHeader."SBP SeerBit - Status" := Format(responsestatusToken).Replace('"', '');
                                    IF jsonObj.Get('InvoiceID', responseInvoiceIDToken) THEN
                                        salesHeader."SBP SeerBit - Invoice ID" := Format(responseInvoiceIDToken).Replace('"', '');
                                    IF jsonObj.Get('InvoiceNo', responsInvoiceNoToken) THEN
                                        salesHeader."SBP SeerBit - Invoice Number" := Format(responsInvoiceNoToken).Replace('"', '');
                                    // salesHeader."SBP SeerBit Transaction Ref." :=
                                    if Format(responsestatusToken).Replace('"', '') = 'PAID' then salesHeader.SBPpaid := true else salesHeader.SBPpaid := false;
                                    salesHeader.Modify();
                                end;
                            end;
                            seerbitsalesinvoice.SetRange(InvoiceNo, InvoiceNo);
                            if seerbitsalesinvoice.FindFirst() then begin
                                seerbitsalesinvoice."SeerBit - Status" := Format(responsestatusToken).Replace('"', '');
                                IF jsonObj.Get('InvoiceID', responseInvoiceIDToken) THEN
                                    seerbitsalesinvoice."SeerBit - Invoice ID" := Format(responseInvoiceIDToken).Replace('"', '');
                                IF jsonObj.Get('InvoiceNo', responsInvoiceNoToken) THEN
                                    seerbitsalesinvoice."SeerBit - Invoice Number" := Format(responsInvoiceNoToken).Replace('"', '');
                                IF jsonObj.Get('totalAmount', responsetotalAmountToken) THEN
                                    seerbitsalesinvoice."SeerBit - Total Amount" := responsetotalAmountToken.AsValue().AsDecimal();
                                if Format(responsestatusToken).Replace('"', '') = 'PAID' then seerbitsalesinvoice.paid := true else seerbitsalesinvoice.paid := false;
                                seerbitsalesinvoice.InvoiceNo := InvoiceNo;

                                seerbitsalesinvoice.Modify();
                            end;
                            if Format(responsestatusToken).Replace('"', '') = 'PAID' then EXIT(true) else exit(false);
                    end else
                        Error('No payment received yet.')





                    // salespage.CallPostDocument(CODEUNIT::"Sales-Post (Yes/No)", "Navigate After Posting"::"Posted Document");
                end



        end;


        // Items.Get

        exit(false);

    end;

    /// <summary>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    /// validatepayment.
    /// </summary>
    /// <param name="Invoiceno">VAR Text[20].</param>
    /// <param name="salesheaderNo">VAR Code[20].</param>
    procedure validatepayment(salesinvoiceHeaderRec: Record "Sales Invoice Header"; invoiceno1: text)
    var
        salesInvoiceHeader: Record "Sales Invoice Header";
        salesHeader: Record "Sales Header";
        seerbitInvoices: Record "SBP SeerBit Invoices";
        invoiceno: Text;
    begin

        // salesInvoiceHeader.SetFilter("No.", salesheaderNo);
        //  message('Validatepayment ' + Format(salesinvoiceHeaderRec."No.") + ' ' + salesinvoiceHeaderRec."Posting Description");
        // if salesInvoiceHeader.FindFirst() then begin
        if salesinvoiceHeaderRec."Posting Description".Contains('Invoice') then invoiceno := salesinvoiceHeaderRec."Posting Description".Replace('Invoice ', '') else invoiceno := salesinvoiceHeaderRec."Posting Description".Replace('Order ', '');
        seerbitInvoices.SetFilter(Invoiceno, Invoiceno);
        // message(salesinvoiceHeaderRec."Posting Description" + ' ' + salesinvoiceHeaderRec."SBP SeerBit - Invoice Number");
        if (salesinvoiceHeaderRec."Posting Description".Contains('Invoice')) then begin
            if seerbitInvoices.FindFirst() then begin
                // salesInvoiceHeader.init();
                // message(seerbitInvoices."SeerBit - Invoice Number");
                //Message('Sales header1X ' + salesHeader."SBP SeerBit POS ID" + ' Status ' + salesInvoiceHeader."No.");
                seerbitInvoices.FindFirst();
                // salesInvoiceHeader.init();
                //seerbitInvoices."SBP sent to seerbit" := true;
                seerbitInvoices."SeerBit Transaction Ref." := salesinvoiceHeaderRec."SBPSeerBitPaymentRef";
                seerbitInvoices."SeerBit - Status" := 'Verified';
                seerbitInvoices."No." := salesinvoiceHeaderRec."No.";
                salesinvoiceHeaderRec."SBP sent to seerbit" := true;
                salesinvoiceHeaderRec.SBPpaid := true;
                salesinvoiceHeaderRec."SBP SeerBit - Status" := 'Verified';
                salesinvoiceHeaderRec."SBP SeerBit - Invoice Number" := seerbitInvoices."SeerBit - Invoice Number";
                salesinvoiceHeaderRec."SBP SeerBit - Invoice ID" := seerbitInvoices."SeerBit - Invoice ID";
                salesinvoiceHeaderRec.Modify();
                seerbitInvoices.Modify();

            end //
            else
                Message('No payment received by SeerBit Payment Gateway');
        end else begin
            salesHeader.SetFilter("Posting Description", salesinvoiceHeaderRec."Posting Description");
            if salesHeader.FindFirst() then begin
                //Message('Sales POS ID ' + salesHeader."SBP SeerBit POS ID");
                if Format(salesHeader."SBP SeerBit POS ID") = '' then begin
                    // Message('Sales POS ID ' + salesHeader."SBP SeerBit POS ID");
                    //  Message('Sales header1 ' + salesHeader."SBP SeerBit POS ID" + ' Status ' + salesInvoiceHeader."No.");
                    seerbitInvoices.FindFirst();
                    // salesInvoiceHeader.init();
                    //seerbitInvoices."SBP sent to seerbit" := true;
                    //seerbitInvoices."SeerBit Transaction Ref." :=seerbitsalesinvoice."SeerBit - Invoice Number";
                    seerbitInvoices."SeerBit - Status" := 'Verified';
                    seerbitInvoices."No." := salesinvoiceHeaderRec."No.";
                    seerbitInvoices.Modify();
                end else begin

                    // Message('Sales header ' + salesHeader."SBP SeerBit POS ID" + ' Status ' + salesInvoiceHeader."No.");
                    seerbitInvoices.FindFirst();
                    // salesInvoiceHeader.init();
                    seerbitInvoices."SeerBit POS ID" := salesHeader."SBP SeerBit POS ID";
                    //seerbitInvoices."SBP sent to seerbit" := true;
                    seerbitInvoices."SeerBit Transaction Ref." := salesHeader."SBP SeerBit Transaction Ref.";
                    seerbitInvoices."SeerBit - Status" := 'Verified';
                    seerbitInvoices."No." := salesinvoiceHeaderRec."No.";


                    seerbitInvoices.Modify();
                end
            end;
        end;
        // end else
        //   Error('Error No Record');
    end;

    procedure GetInvoiceStatusPayload(salesinvoiceHeaderRec: Record "Sales Invoice Header"): Text
    var
        CompanyInformation: Record "Company Information";
        HttpClient: HttpClient;
        Content: HttpContent;
        GetContent: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: HttpRequestMessage;
        GetRequest: HttpRequestMessage;
        Response: HttpResponseMessage;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        EncryptedKey: Text;
        GetPayload: Text;
        Payload: Text;
        ResponseText: Text;
        InvoiceNo: Text;
    begin
        CompanyInformation.FindFirst();

        GetPayload := '{';
        GetPayload += '"key": "' + CompanyInformation.SBPSecKey + '.' + CompanyInformation.SBPPublicKey + '"';
        GetPayload += '}';

        GetContent.WriteFrom(GetPayload);
        GetContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        GetRequest.Content := GetContent;
        GetRequest.SetRequestUri('https://seerbitapi.com/api/v2/encrypt/keys');
        GetRequest.Method := 'Options';

        HttpClient.Send(GetRequest, Response);
        Response.Content().ReadAs(ResponseText);

        if not JsonObj.ReadFrom(ResponseText) then
            Error('Invalid response from SeerBit token API: %1', ResponseText);

        if not JsonObj.Get('data', JsonToken) then
            Error('Invalid response from SeerBit token API: %1', ResponseText);

        JsonObj.ReadFrom(Format(JsonToken));
        if not JsonObj.Get('EncryptedSecKey', JsonToken) then
            Error('Invalid response from SeerBit token API: %1', ResponseText);

        JsonObj.ReadFrom(Format(JsonToken));
        if not JsonObj.Get('encryptedKey', JsonToken) then
            Error('Invalid response from SeerBit token API: %1', ResponseText);

        EncryptedKey := Format(JsonToken);

        if salesinvoiceHeaderRec."Posting Description".Contains('Invoice') then
            InvoiceNo := salesinvoiceHeaderRec."Posting Description".Replace('Invoice ', '')
        else
            InvoiceNo := salesinvoiceHeaderRec."Posting Description".Replace('Order ', '');

        Payload := '{';
        Payload += '"token": ' + EncryptedKey + ',';
        Payload += '"publicKey": "' + CompanyInformation.SBPPublicKey + '",';
        Payload += '"orderno": "' + InvoiceNo + '",';
        Payload += '"invoiceno": "' + salesinvoiceHeaderRec."SBP SeerBit - Invoice Number" + '",';
        Payload += '"customerEmail": "' + salesinvoiceHeaderRec."Sell-to E-Mail" + '"';
        Payload += '}';

        Content.WriteFrom(Payload);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        Request.Content := Content;
        Request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/getInvoiceByInvoiceno');
        Request.Method := 'POST';

        HttpClient.Send(Request, Response);
        Response.Content().ReadAs(ResponseText);

        exit(ResponseText);
    end;

    procedure update(salesinvoiceHeaderRec: Record "Sales Invoice Header")
    var
        salesInvoiceHeader: Record "Sales Invoice Header";
        salesHeader: Record "Sales Header";
        seerbitInvoices: Record "SBP SeerBit Invoices";
        invoiceno: Text;
    begin

        seerbitInvoices.SetRange("No.", salesinvoiceHeaderRec."No.");
        if not seerbitInvoices.FindFirst() then begin
            seerbitInvoices.Reset();
            if salesinvoiceHeaderRec."Posting Description".Contains('Invoice') then
                invoiceno := salesinvoiceHeaderRec."Posting Description".Replace('Invoice ', '')
            else
                invoiceno := salesinvoiceHeaderRec."Posting Description".Replace('Order ', '');
            seerbitInvoices.SetRange(Invoiceno, invoiceno);
            if not seerbitInvoices.FindFirst() then
                exit;
        end;
        //Message(seerbitInvoices."SeerBit POS ID");
        salesinvoiceHeaderRec."SBP sent to seerbit" := true;
        salesinvoiceHeaderRec.SBPpaid := true;
        salesinvoiceHeaderRec."SBP SeerBit - Status" := 'Verified';
        salesinvoiceHeaderRec."SBP SeerBit - Invoice ID" := seerbitInvoices."SeerBit - Invoice ID";
        salesinvoiceHeaderRec."SBP SeerBit - Invoice Number" := seerbitInvoices."SeerBit - Invoice Number";
        if seerbitInvoices."SeerBit - Invoice Number" = '' then
            salesinvoiceHeaderRec."SBPSeerBitPaymentRef" := seerbitInvoices."SeerBit Transaction Ref."
        else
            salesinvoiceHeaderRec."SBPSeerBitPaymentRef" := seerbitInvoices."SeerBit - Invoice Number";
        salesinvoiceHeaderRec.Modify();
        //seerbitInvoices.Delete();
    end;

    procedure PostPaymentForPostedInvoice(SalesInvoiceNo: Code[20]; SeerBitInvoiceNo: Code[20]; SeerBitInvoiceID: Text[100])
    var
        PostedSalesInvoice: Record "Sales Invoice Header";
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        SeerBitInvoice: Record "SBP SeerBit Invoices";
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PaymentAccountNo: Code[20];
        PaymentAccountType: Enum "Gen. Journal Account Type";
        PaymentAmount: Decimal;
    begin
        if not FindPostedInvoice(SalesInvoiceNo, SeerBitInvoiceNo, PostedSalesInvoice) then
            Error('Posted sales invoice for %1 was not found. Payment was verified but could not be posted.', SalesInvoiceNo);

        SeerBitInvoice.SetRange(Invoiceno, SalesInvoiceNo);
        if SeerBitInvoice.FindFirst() then begin
            SeerBitInvoice."No." := PostedSalesInvoice."No.";
            SeerBitInvoice."SeerBit - Status" := 'PAID';
            SeerBitInvoice.paid := true;
            if SeerBitInvoiceNo <> '' then
                SeerBitInvoice."SeerBit - Invoice Number" := SeerBitInvoiceNo;
            if SeerBitInvoiceID <> '' then
                SeerBitInvoice."SeerBit - Invoice ID" := SeerBitInvoiceID;
            SeerBitInvoice.Modify();
        end;

        PostedSalesInvoice."SBP sent to seerbit" := true;
        PostedSalesInvoice.SBPpaid := true;
        PostedSalesInvoice."SBP SeerBit - Status" := 'PAID';
        if SeerBitInvoiceNo <> '' then
            PostedSalesInvoice."SBP SeerBit - Invoice Number" := SeerBitInvoiceNo;
        if SeerBitInvoiceID <> '' then
            PostedSalesInvoice."SBP SeerBit - Invoice ID" := SeerBitInvoiceID;
        PostedSalesInvoice.Modify();

        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.SetRange("Document No.", PostedSalesInvoice."No.");
        CustomerLedgerEntry.SetRange(Open, true);
        if not CustomerLedgerEntry.FindFirst() then begin
            Message('Posted invoice %1 is already closed or has no open customer ledger entry.', PostedSalesInvoice."No.");
            exit;
        end;

        CustomerLedgerEntry.CalcFields("Remaining Amount");
        PaymentAmount := Abs(CustomerLedgerEntry."Remaining Amount");
        if PaymentAmount = 0 then begin
            Message('Posted invoice %1 has no remaining amount to apply.', PostedSalesInvoice."No.");
            exit;
        end;

        if PostedSalesInvoice."Payment Method Code" = '' then
            PostedSalesInvoice."Payment Method Code" := 'SEERBIT';

        GetSettlementAccount(PostedSalesInvoice."Payment Method Code", PaymentAccountType, PaymentAccountNo);
        GeneralLedgerSetup.Get();

        GenJournalLine.Init();
        GenJournalLine."Line No." := 10000;
        GenJournalLine."Posting Date" := Today;
        GenJournalLine."Document Type" := "Gen. Journal Document Type"::Payment;
        GenJournalLine."Document No." := CopyStr('SBP-' + PostedSalesInvoice."No.", 1, MaxStrLen(GenJournalLine."Document No."));
        GenJournalLine."External Document No." := CopyStr(SeerBitInvoiceNo, 1, MaxStrLen(GenJournalLine."External Document No."));
        GenJournalLine."Account Type" := "Gen. Journal Account Type"::Customer;
        GenJournalLine.Validate("Account No.", CustomerLedgerEntry."Customer No.");
        GenJournalLine.Description := CopyStr('SeerBit Invoice Payment - ' + PostedSalesInvoice."No.", 1, MaxStrLen(GenJournalLine.Description));

        if (PostedSalesInvoice."Currency Code" <> '') and (PostedSalesInvoice."Currency Code" <> GeneralLedgerSetup."LCY Code") and (PostedSalesInvoice."Currency Code" <> 'NGN') then
            GenJournalLine.Validate("Currency Code", PostedSalesInvoice."Currency Code")
        else
            GenJournalLine."Currency Code" := '';

        GenJournalLine.Validate(Amount, -PaymentAmount);
        if GenJournalLine."Currency Code" = '' then
            GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;

        GenJournalLine."Bal. Account Type" := PaymentAccountType;
        GenJournalLine.Validate("Bal. Account No.", PaymentAccountNo);
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", PostedSalesInvoice."No.");
        GenJournalLine."SBPSeerBit - Tx. Refenece" := CopyStr(SeerBitInvoiceNo, 1, MaxStrLen(GenJournalLine."SBPSeerBit - Tx. Refenece"));
        GenJournalLine."SBPSeerBit - Payment Date" := Format(Today);
        GenJournalLine."SBPSeerBit -Doc. Type" := 'Invoice';

        GenJnlPostLine.RunWithCheck(GenJournalLine);
        Message('SeerBit payment for invoice %1 has been posted and applied.', PostedSalesInvoice."No.");
    end;

    local procedure FindPostedInvoice(SalesInvoiceNo: Code[20]; SeerBitInvoiceNo: Code[20]; var PostedSalesInvoice: Record "Sales Invoice Header"): Boolean
    begin
        PostedSalesInvoice.Reset();
        PostedSalesInvoice.SetRange("Pre-Assigned No.", SalesInvoiceNo);
        if PostedSalesInvoice.FindLast() then
            exit(true);

        PostedSalesInvoice.Reset();
        PostedSalesInvoice.SetRange("SBP SeerBit - Invoice Number", SeerBitInvoiceNo);
        if (SeerBitInvoiceNo <> '') and PostedSalesInvoice.FindLast() then
            exit(true);

        PostedSalesInvoice.Reset();
        PostedSalesInvoice.SetRange("No.", SalesInvoiceNo);
        if PostedSalesInvoice.FindLast() then
            exit(true);

        PostedSalesInvoice.Reset();
        PostedSalesInvoice.SetRange("Posting Description", 'Invoice ' + SalesInvoiceNo);
        exit(PostedSalesInvoice.FindLast());
    end;

    local procedure GetSettlementAccount(PaymentMethodCode: Code[10]; var PaymentAccountType: Enum "Gen. Journal Account Type"; var PaymentAccountNo: Code[20])
    var
        CompanyInformation: Record "Company Information";
        PaymentMethod: Record "Payment Method";
    begin
        CompanyInformation.Get();
        if CompanyInformation."SBP Settlement Account No." <> '' then begin
            if not (CompanyInformation."SBP Settlement Account Type" in
                    [CompanyInformation."SBP Settlement Account Type"::"G/L Account",
                     CompanyInformation."SBP Settlement Account Type"::"Bank Account"])
            then
                Error('SeerBit Settlement Account Type must be G/L Account or Bank Account.');

            PaymentAccountType := CompanyInformation."SBP Settlement Account Type";
            PaymentAccountNo := CompanyInformation."SBP Settlement Account No.";
            exit;
        end;

        if not PaymentMethod.Get(PaymentMethodCode) then
            Error('Set SeerBit Settlement Account Type and Settlement Account No. on Company Information, or create Payment Method %1 with a balancing account.', PaymentMethodCode);

        if PaymentMethod."Bal. Account No." = '' then
            Error('Set SeerBit Settlement Account Type and Settlement Account No. on Company Information, or add a Bal. Account No. to Payment Method %1.', PaymentMethod.Code);

        case Format(PaymentMethod."Bal. Account Type") of
            'G/L Account':
                PaymentAccountType := "Gen. Journal Account Type"::"G/L Account";
            'Bank Account':
                PaymentAccountType := "Gen. Journal Account Type"::"Bank Account";
            else
                Error('Payment Method %1 must use G/L Account or Bank Account as the balancing account type.', PaymentMethod.Code);
        end;

        PaymentAccountNo := PaymentMethod."Bal. Account No.";
    end;
}
