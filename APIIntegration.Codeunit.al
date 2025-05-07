/// <summary>
/// Codeunit API Integration (ID 50130).
/// </summary>
codeunit 71855575 "SBPAPI Integration"
{
    Permissions =
        tabledata "Sales Invoice Header" = RIMD,
        tabledata "Sales Invoice Line" = R;
    /// <summary>
    /// SendToAPI.
    /// </summary>
    /// <param name="InvoiceNo">Code[20].</param>
    procedure SendToAPI(InvoiceNo: Code[20])

    //Message(responseText);
    var

        salesInvoiceHeader: Record "Sales Invoice Header";
        salesInvoiceLine: Record "Sales Invoice Line";
        httpClient: HttpClient;
        //HttpClient: HttpClient;
        httpContent: HttpContent;
        contentHeaders: HttpHeaders;
        httpRequestMessage: HttpRequestMessage;
        httpResponseMessage: HttpResponseMessage;
        InvoiceItems: Text;
        Payload: Text;
        responseText: Text;

    begin

        // Initialize the HttpClient
        HttpClient.GET('https://api.example.com/initialize', httpResponseMessage);

        // Get the specific Posted Sales Invoice record
        salesInvoiceHeader.SETRANGE("No.", InvoiceNo);
        if salesInvoiceHeader.FINDSET() then
            // Prepare the payload
            Payload := '{';
        Payload += '"publicKey": "publicKey",';
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
                InvoiceItems += '"quantity": ' + FORMAT(salesInvoiceLine.Quantity) + ',';
                InvoiceItems += '"rate": ' + FORMAT(salesInvoiceLine."Unit Price") + ',';
                InvoiceItems += '"tax": ' + FORMAT(salesInvoiceLine."VAT %") + '';
                InvoiceItems += '},';
            until salesInvoiceLine.NEXT() = 0;


        // Remove the trailing comma if any
        if STRLEN(InvoiceItems) > 0 then
            InvoiceItems := DELSTR(InvoiceItems, STRLEN(InvoiceItems), 1);

        // Complete the JSON payload
        Payload += InvoiceItems;
        Payload += ']';
        Payload += '}';

        httpContent.WriteFrom(payload);
        // Retrieve the contentHeaders associated with the content
        httpContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        // Assigning content to request.Content will actually create a copy of the content and assign it.
        // After this line, modifying the content variable or its associated headers will not reflect in 
        // the content associated with the request message
        httpRequestMessage.Content := httpContent;

        httpRequestMessage.SetRequestUri('https://api.example.com/initialize');
        httpRequestMessage.Method := 'POST';

        httpClient.Send(httpRequestMessage, httpResponseMessage);

        // Read the response content as json.
        httpResponseMessage.Content().ReadAs(responseText);
        //Message(responseText);




    end;
}
