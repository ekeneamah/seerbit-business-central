codeunit 71855609 SBPMultiSalesInvoice
{
    Permissions =
        tabledata "Company Information" = R,
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R,
        tabledata "SBP SeerBit Invoices" = RIMD;

    var
        seerbitsalesinvoice: Record "SBP SeerBit Invoices";
        InvoiceToUpdate: Record "Sales Header";
        responseCodeToken: JsonToken;
        responseBatchIdToken: JsonToken;
        responseCodeText: Text;
        BatchId: Text;
        LastErrorText: Text;
        HttpClient: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        CompanyInfo: Record "Company Information";
        SalesLine: Record "Sales Line";
        RootJson: JsonObject;
        InvoicesArray: JsonArray;
        InvoiceJson: JsonObject;
        LinesArray: JsonArray;
        LineJson: JsonObject;
        Payload: Text;
        ResponseText: Text;
        BearerToken: Text;
        getPayload: Text;
        getContent: HttpContent;
        getRequest: HttpRequestMessage;
        getResponse: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        jsonToken: JsonToken;
        TokenJsonToken: JsonToken;

        DataObj: JsonObject;
        url: Text;
        JsonObj: JsonObject;

    [TryFunction]
    procedure SendSelectedInvoices(var SelectedInvoices: Record "Sales Header")
    var
        PublicKeySegment: Text;
    begin
        CompanyInfo.FindFirst();

        // Step 1: Get the Bearer Token
        getPayload := '{';
        getPayload += '"key": "' + CompanyInfo.SBPSecKey + '.' + CompanyInfo.SBPPublicKey + '"';
        getPayload += '}';

        getContent.WriteFrom(getPayload);
        if not getContent.GetHeaders(contentHeaders) then
            Error('Failed to retrieve headers for token request.');
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        getRequest.Content := getContent;
        getRequest.SetRequestUri('https://seerbitapi.com/api/v2/encrypt/keys');
        getRequest.Method := 'POST';

        HttpClient.Send(getRequest, getResponse);
        getResponse.Content().ReadAs(ResponseText);
        if not getResponse.IsSuccessStatusCode() then
            Error(StrSubstNo('Failed to retrieve Bearer token. Server Response: %1', ResponseText));

        Clear(JsonObj);
        if not JsonObj.ReadFrom(ResponseText) then
            Error('Invalid JSON response from token service.');

        JsonObj.Get('data', jsonToken);
        DataObj.ReadFrom(Format(jsonToken));
        DataObj.Get('EncryptedSecKey', jsonToken);
        DataObj.ReadFrom(Format(jsonToken));
        DataObj.Get('encryptedKey', jsonToken);
        BearerToken := Format(jsonToken);
        TokenJsonToken.ReadFrom(BearerToken);

        // Step 2: Build the invoice payload (invoices array only)
        Clear(InvoicesArray);
        SelectedInvoices.SetFilter("No.", '<>%1', '');
        if SelectedInvoices.FindSet() then begin
            repeat
                Clear(InvoiceJson);
                Clear(LinesArray);

                InvoiceJson.Add('orderNo', SelectedInvoices."No.");
                InvoiceJson.Add('dueDate', Format(SelectedInvoices."Due Date", 10, 9));
                if SelectedInvoices."Currency Code" = '' then
                    InvoiceJson.Add('currency', CompanyInfo."SBP Default Currency")
                else
                    InvoiceJson.Add('currency', SelectedInvoices."Currency Code");
                InvoiceJson.Add('receiversName', SelectedInvoices."Sell-to Customer Name");
                InvoiceJson.Add('customerEmail', SelectedInvoices."Sell-to E-Mail");

                SalesLine.Reset();
                SalesLine.SetRange("Document No.", SelectedInvoices."No.");
                if SalesLine.FindSet() then begin
                    repeat
                        Clear(LineJson);
                        LineJson.Add('itemName', SalesLine.Description);
                        LineJson.Add('quantity', SalesLine.Quantity);
                        LineJson.Add('rate', SalesLine."Unit Price");
                        LineJson.Add('tax', SalesLine."VAT %");
                        LinesArray.Add(LineJson);
                    until SalesLine.Next() = 0;
                end;

                InvoiceJson.Add('invoiceItems', LinesArray);
                InvoicesArray.Add(InvoiceJson);
            until SelectedInvoices.Next() = 0;
        end;

        // Step 3: Build root object with publicKey, token, and invoices[]
        Clear(RootJson);
        RootJson.Add('publicKey', CompanyInfo.SBPPublicKey);
        RootJson.Add('token', TokenJsonToken);
        RootJson.Add('invoices', InvoicesArray);

        RootJson.WriteTo(Payload);
        Content.WriteFrom(Payload);
        Message('Payload: %1', Payload);

        if not Content.GetHeaders(contentHeaders) then
            Error('Failed to retrieve content headers.');

        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        Request.Content := Content;
        PublicKeySegment := CompanyInfo.SBPPublicKey;
        if PublicKeySegment = '' then
            Error('Public key is missing from company setup.');

        url := 'https://erp.middleware.seerbitapi.com/api/v1/multiinvoices/send';
        Request.SetRequestUri(url);
        Request.Method := 'POST';

        HttpClient.Send(Request, Response);
        Response.Content().ReadAs(ResponseText);
        Message('Response: %1', ResponseText);

        if not Response.IsSuccessStatusCode() then
            Error(StrSubstNo('Failed to send invoices. Response: %1', ResponseText));

        Clear(JsonObj);
        if not JsonObj.ReadFrom(ResponseText) then
            Error('Unable to parse API response.');

        begin
            if JsonObj.Get('code', responseCodeToken) then begin
                responseCodeText := responseCodeToken.AsValue().AsText();
                Message('Response: %1', responseCodeText);
                if responseCodeText = '00' then begin
                    if JsonObj.Get('data', jsonToken) then begin
                        DataObj := jsonToken.AsObject();
                        if DataObj.Get('batchId', responseBatchIdToken) then begin
                            BatchId := responseBatchIdToken.AsValue().AsText();
                            Message('Batch ID: %1', BatchId);
                            Message('Document Type: %1, Invoice No.: %2', SelectedInvoices."Document Type", SelectedInvoices."No.");

                            // Update the selected invoices in the database
                            if SelectedInvoices.FindSet() then begin
                                repeat
                                    if InvoiceToUpdate.Get(SelectedInvoices."Document Type", SelectedInvoices."No.") then begin
                                        InvoiceToUpdate.Get(SelectedInvoices."Document Type", SelectedInvoices."No.");
                                        InvoiceToUpdate."SBP sent to seerbit" := true;
                                        InvoiceToUpdate."SBP SeerBit - Batch ID" := BatchId;
                                        InvoiceToUpdate."SBP SeerBit - Invoice Number" := SelectedInvoices."No.";
                                        InvoiceToUpdate."SBP SeerBit - Status" := 'Pending';
                                        InvoiceToUpdate."Payment Method Code" := 'SEERBIT';
                                        InvoiceToUpdate."SBP SeerBit - Date Sent" := Format(CurrentDateTime, 0, '<Day,2>/<Month,2>/<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>');
                                        InvoiceToUpdate."SBP SeerBit - Payment Date" := Format(0D);

                                        InvoiceToUpdate.Modify();
                                    end else begin
                                        Error('Record not found.');
                                    end;
                                    Message('Invoice %1 updated with Batch ID %2', SelectedInvoices."No.", BatchId);
                                    if SelectedInvoices."No." <> '' then begin
                                        if not seerbitsalesinvoice.Get(SelectedInvoices."No.") then begin
                                            seerbitsalesinvoice.Init();
                                            seerbitsalesinvoice."Document Type" := SelectedInvoices."Document Type";
                                            seerbitsalesinvoice."SeerBit - Invoice Number" := SelectedInvoices."No.";
                                            seerbitsalesinvoice."sent to seerbit" := true;
                                            seerbitsalesinvoice."SeerBit - Batch ID" := BatchId;
                                            seerbitsalesinvoice.Invoiceno := SelectedInvoices."No.";
                                            seerbitsalesinvoice.Insert();
                                        end else
                                            Message('Invoice %1 already exists in SeerBit Sales Invoices.', SelectedInvoices."No.");
                                    end else
                                        Error('Invoice number is missing for invoice %1.', SelectedInvoices."No.");
                                until SelectedInvoices.Next() = 0;
                            end;

                            Message('Invoices submitted to SeerBit successfully. Batch ID: %1', BatchId);
                        end;
                    end;
                end;
            end;
        end;

    end;

    procedure GetLastErrorText(): Text
    begin
        exit(LastErrorText);
    end;
}
