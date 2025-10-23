/// <summary>
/// Codeunit SBPRetrievePaymentlinkPayments (ID 71855578).
/// </summary>
codeunit 71855578 SBPRetrievePaymentlinkPayments
{
    /// <summary>
    /// Retrieve payments.
    /// </summary>
    /// <param name="myCode">Code[20].</param>
    procedure "Retrieve payments"(myCode: Code[20])
    var
        Customer: JsonObject;
        ShiptoJsonObject: JsonObject;
        ShiptoJsonObjectToken: JsonToken;
        ShipTo: JsonObject;
        ShipToArray: JsonArray;
        customerToken: jsonToken;
        ShipToArrayToken: jsonToken;

        httpClient: HttpClient;
        Response: HttpResponseMessage;
        payments: Record "SBPPaymentPayments";
        contentHeaders: HttpHeaders;
        content: HttpContent;
        getContent: HttpContent;
        request: HttpRequestMessage;

        Index: Integer;
    begin
        getContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        Customer.ReadFrom('{' +
                '"No": "10000",' +
                '"Address": "192 Market Square",' +
                '"Address_2": "",' +
                '"City": "",' +
                '"County": "NJ",' +
                '"Country_Region": "US",' +
                '"Post_Code": "",' +
                '"Ship-to": [' +
                    '{' +
                        '"Code": "LEWES ROAD",' +
                        '"Address": "2 Lewes Road",' +
                        '"Address_2": "",' +
                       ' "City": "Atlanta",' +
                        '"County": "GA",' +
                       ' "Post_Code": "31772"' +
                    '},' +
                    '{' +
                        '"Code": "PARK ROAD",' +
                        '"Address": "10 Park Road",' +
                        '"Address_2": "",' +
                        '"City": "Atlanta",' +
                        '"County": "GA",' +
                        '"Post_Code": "31772"' +
                    '}]}');
        if (Customer.Get('Ship-to', customerToken)) then message(Format(customerToken));
        ShipToArray.ReadFrom(Format(customerToken));
        for Index := 0 to ShipToArray.Count - 1 do begin
            if (ShipToArray.Get(index, ShipToArrayToken)) then begin
                ShiptoJsonObject.ReadFrom(Format(ShipToArrayToken));
                if (shiptoJsonObject.get('Address', ShiptoJsonObjectToken)) then message(Format(ShiptoJsonObjectToken))
            end;

        end;

    end;

    var
        Customer: JsonObject;
        ShipTo: JsonObject;
        ShipToArray: JsonArray;
        chk: Integer;
}