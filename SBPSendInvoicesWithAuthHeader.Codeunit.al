codeunit 71855610 SBPSendInvoicesWithAuthHeader
{
    Permissions =
        tabledata "Company Information" = R,
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R;

    var
        LastErrorText: Text;
        HttpClient: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        CompanyInfo: Record "Company Information";
        SalesLine: Record "Sales Line";
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
        DataObj: JsonObject;
        JsonObj: JsonObject;
        url: Text;

    procedure SendSelectedInvoicesWithAuthHeader(var Rec: Record "Sales Header")
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
        Message('Bearer Token: %1', BearerToken);

        // Step 2: Build invoice array
        Clear(InvoicesArray);
        Rec.SetFilter("No.", '<>%1', '');
        if Rec.FindSet() then begin
            repeat
                Clear(InvoiceJson);
                Clear(LinesArray);

                InvoiceJson.Add('orderNo', Rec."No.");
                InvoiceJson.Add('dueDate', Format(Rec."Due Date", 10, 9));
                if Rec."Currency Code" = '' then
                    InvoiceJson.Add('currency', 'NGN') else
                    InvoiceJson.Add('currency', Rec."Currency Code");
                InvoiceJson.Add('receiversName', Rec."Sell-to Customer Name");
                InvoiceJson.Add('customerEmail', Rec."Sell-to E-Mail");

                SalesLine.Reset();
                SalesLine.SetRange("Document No.", Rec."No.");
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
            until Rec.Next() = 0;
        end;

        InvoicesArray.WriteTo(Payload);
        Content.WriteFrom(Payload);
        Message('Payload: %1', Payload);

        // Step 3: Add Authorization header
        if not Content.GetHeaders(contentHeaders) then
            Error('Failed to retrieve content headers.');
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Authorization', StrSubstNo('Bearer %1', BearerToken));
        contentHeaders.Add('User-Agent', 'insomnia/8.4.0');

        Request.Content := Content;

        PublicKeySegment := CompanyInfo.SBPPublicKey;
        if PublicKeySegment = '' then
            Error('Public key is missing from setup.');

        url := 'https://merchant.seerbitapi.com/invoice/' + PublicKeySegment + '/bulk-requests';
        Request.SetRequestUri(url);
        Request.Method := 'POST';

        HttpClient.Send(Request, Response);
        Response.Content().ReadAs(ResponseText);

        if not Response.IsSuccessStatusCode() then
            Error(StrSubstNo('Failed to send invoices. Response: %1', ResponseText));

        Message('Invoices sent successfully. Server response: %1', ResponseText);
    end;

    procedure GetLastErrorText(): Text
    begin
        exit(LastErrorText);
    end;
}
