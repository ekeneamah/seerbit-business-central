/// <summary>
/// Codeunit SBPSendPostedSalesInvoice (ID 50133).
/// </summary>
codeunit 71855577 SBPSendPostedSalesInvoice
{
    Permissions =
        tabledata "Company Information" = R,
        tabledata "Sales Header" = RM,
        tabledata "Sales Invoice Header" = RIMD,
        tabledata "Sales Line" = R,
        tabledata "SBP SeerBit Invoices" = RIM;

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
        // Message('Get response ' + responseText);
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
        Message('Request Payload: ' + Payload);
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
        Message('Response Payload: ' + postresponseText);
        jsonObj.ReadFrom(postresponseText);
        if jsonObj.get('status', responsestatusToken) then begin
            Message(Format(responsestatusToken).Replace('"', ''));
            // exit;
        end else
            if jsonObj.get('message', responsestatusToken) then begin Message(Format(responsestatusToken).Replace('"', '"')) end;
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
                        Message('Invoice Status is ' + Format(responsestatusToken));
                        salesHeader.Reset();
                        salesHeader.SetRange("No.", InvoiceNo);
                        if salesHeader.FindFirst() then begin
                            IF jsonObj.Get('status', responsestatusToken) THEN begin
                                salesHeader."SBP SeerBit - Status" := Format(responsestatusToken).Replace('"', '');
                                // salesHeader."SBP SeerBit Transaction Ref." :=
                                if Format(responsestatusToken).Replace('"', '') = 'PAID' then salesHeader.SBPpaid := true else salesHeader.SBPpaid := false;
                                salesHeader.Modify();
                            end;
                        end;
                        seerbitsalesinvoice.SetRange(InvoiceNo, InvoiceNo);
                        if seerbitsalesinvoice.FindFirst() then begin
                            seerbitsalesinvoice."SeerBit - Status" := Format(responsestatusToken).Replace('"', '');
                            if Format(responsestatusToken).Replace('"', '') = 'PAID' then seerbitsalesinvoice.paid := true else seerbitsalesinvoice.paid := false;
                            seerbitsalesinvoice.InvoiceNo := InvoiceNo;

                            seerbitsalesinvoice.Modify();
                            if Format(responsestatusToken).Replace('"', '') = 'PAID' then EXIT(true) else exit(false);
                        end
                    end else
                        Error('No payment recieved yet.')





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
        if (salesInvoiceHeader."Posting Description".Contains('Invoice')) then begin
            if seerbitInvoices.FindFirst() then begin
                // salesInvoiceHeader.init();
                // message(seerbitInvoices."SeerBit - Invoice Number");
                //Message('Sales header1X ' + salesHeader."SBP SeerBit POS ID" + ' Status ' + salesInvoiceHeader."No.");
                seerbitInvoices.FindFirst();
                // salesInvoiceHeader.init();
                //seerbitInvoices."SBP sent to seerbit" := true;
                seerbitInvoices."SeerBit Transaction Ref." := salesinvoiceHeaderRec."SBPSeerBitPaymentRef";
                seerbitInvoices."SeerBit - Status" := 'Verified';
                seerbitInvoices."SeerBit - Invoice ID" := salesinvoiceHeaderRec."No.";
                if seerbitInvoices.Modify() then Message('Success ' + Format(salesInvoiceHeader."SBP sent to seerbit")) else Message('No record modified');
                Message('Success ' + seerbitInvoices."SeerBit - Status");

            end //
            else
                Message('No payment recieved by SeerBit Payment Gateway');
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
                    seerbitInvoices."SeerBit - Invoice ID" := salesinvoiceHeaderRec."No.";
                    if seerbitInvoices.Modify() then Message('Success ' + Format(salesInvoiceHeader."SBP sent to seerbit")) else Message('No record modified');
                end else begin

                    // Message('Sales header ' + salesHeader."SBP SeerBit POS ID" + ' Status ' + salesInvoiceHeader."No.");
                    seerbitInvoices.FindFirst();
                    // salesInvoiceHeader.init();
                    seerbitInvoices."SeerBit POS ID" := salesHeader."SBP SeerBit POS ID";
                    //seerbitInvoices."SBP sent to seerbit" := true;
                    seerbitInvoices."SeerBit Transaction Ref." := salesHeader."SBP SeerBit Transaction Ref.";
                    seerbitInvoices."SeerBit - Status" := 'Verified';
                    seerbitInvoices."SeerBit - Invoice ID" := salesinvoiceHeaderRec."No.";


                    if seerbitInvoices.Modify() then Message('Success ' + Format(salesInvoiceHeader."SBP sent to seerbit")) else Message('No record modified');
                end
            end;
        end;
        // end else
        //   Error('Error No Record');
    end;

    procedure update(salesinvoiceHeaderRec: Record "Sales Invoice Header")
    var
        salesInvoiceHeader: Record "Sales Invoice Header";
        salesHeader: Record "Sales Header";
        seerbitInvoices: Record "SBP SeerBit Invoices";
        invoiceno: Text;
    begin

        seerbitInvoices.SetFilter("SeerBit - Invoice ID", salesinvoiceHeaderRec."No.");
        seerbitInvoices.FindFirst();
        //Message(seerbitInvoices."SeerBit POS ID");
        salesinvoiceHeaderRec."SBP sent to seerbit" := true;
        salesinvoiceHeaderRec.SBPpaid := true;
        salesinvoiceHeaderRec."SBP SeerBit - Status" := 'Verified';
        if seerbitInvoices."SeerBit - Invoice Number" = '' then
            salesinvoiceHeaderRec."SBPSeerBitPaymentRef" := seerbitInvoices."SeerBit Transaction Ref."
        else
            salesinvoiceHeaderRec."SBPSeerBitPaymentRef" := seerbitInvoices."SeerBit - Invoice Number";
        salesinvoiceHeaderRec.Modify();
        //seerbitInvoices.Delete();
    end;
}
