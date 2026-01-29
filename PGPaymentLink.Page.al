/// <summary>
/// Page PG Payment Link (ID 50113).
/// </summary>
page 71855599
 "SBP PG Payment Link"
{
    PageType = Card;
    SourceTable = "SBPPayment Link";
    Caption = 'SeerBit - Payment Link';
    AboutText = 'Use this form to create a payment link which you can copy and send to your customers in order to receive payments';
    Editable = true;
    SaveValues = false;
    UsageCategory = Lists;
    ApplicationArea = All;




    layout
    {
        area(Content)
        {

            group(General)
            {
                field("General Journal"; Rec."General Journal")
                {
                    ApplicationArea = All;
                    Caption = 'Gen. General Journal';
                    ToolTip = 'Please select the this payment will posted to';
                    Editable = false;




                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = All;
                    Caption = 'Bank/Cash Account';
                    ToolTip = 'Select the Bank or Cash account where customer payments will be deposited (Debit side)';
                    Editable = Rec."Total Payments" < 1;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record "G/L Account";
                    begin
                        ItemRec.Reset();
                        if Page.RunModal(Page::"Chart of Accounts", ItemRec) = Action::LookupOK then
                            Rec.PaymentReference := ItemRec."No."

                    end;

                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                    Caption = 'Revenue/Receivable Account';
                    ToolTip = 'Select the Revenue or Customer Receivable account to credit when payment is received';
                    Editable = Rec."Total Payments" < 1;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record "G/L Account";
                    begin
                        ItemRec.Reset();
                        ItemRec.SetRange("Account Type", ItemRec."Account Type"::Posting);
                        if Page.RunModal(Page::"Chart of Accounts", ItemRec) = Action::LookupOK then
                            Rec."Bal. Account No." := ItemRec."No.";
                    end;
                }

                field("Customer Name"; Rec.CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ShowMandatory = true;
                    NotBlank = true;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record Customer;
                    begin
                        ItemRec.Reset();
                        if Page.RunModal(Page::"Customer List", ItemRec) = Action::LookupOK then
                            Rec.Email := ItemRec."E-Mail";
                        Rec.CustomerName := ItemRec.Name;
                        Rec.Amount := ItemRec."Invoice Amounts"
                    end;


                }
                field(CustomizationName; Rec.CustomizationName)
                {
                    ApplicationArea = All;
                    Caption = 'Customization Name';
                    ShowMandatory = true;
                    Editable = Rec.Reference = '';
                    NotBlank = true;
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Editable = false;

                }
                field(PaymentLinkName; Rec.PaymentLinkName)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Link Name';
                    ShowMandatory = true;
                    NotBlank = true;
                }
                field("Currency Code"; Rec."Currency")
                {
                    ApplicationArea = All;
                    Caption = 'Currency';
                    Editable = true;
                    Enabled = true;
                    ShowMandatory = true;
                    trigger OnAssistEdit()
                    var
                        Currencyrec: Record Currency;
                    begin
                        Currencyrec.reset();

                        if Page.RunModal(page::Currencies, Currencyrec) = ACTION::LookupOK then
                            rec.Currency := Currencyrec.Code;
                        // Rec."Currency" :=ChangeExchangeRate.CurrencyCode2


                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;

                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    Editable = true;
                    Enabled = true;
                    ShowMandatory = true;
                    NotBlank = true;

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = true;
                    Enabled = true;
                    MultiLine = true;

                }

                field(SuccessMessage; Rec.SuccessMessage)
                {
                    ApplicationArea = All;
                    Caption = 'Success Message';
                    ShowMandatory = true;
                }


                field(PaymentFrequency; Rec.PaymentFrequency)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Frequency';
                }

                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Email';
                    ShowMandatory = true;




                }

                field(AdditionalData; Rec.AdditionalData)
                {
                    ApplicationArea = All;
                    Caption = 'Additional Data';
                    Visible = false;
                }
                field(LinkExpirable; Rec.LinkExpirable)
                {
                    ApplicationArea = All;
                    Caption = 'Link Expirable';
                    Visible = false;
                }
                field(ExpiryDate; Rec.ExpiryDate)
                {
                    ApplicationArea = All;
                    Caption = 'Expiry Date';
                    Editable = Rec.LinkExpirable = true;
                    Visible = false;

                }
                field(OneTime; Rec.OneTime)
                {
                    ApplicationArea = All;
                    Caption = 'One Time';
                    Visible = false;
                }
                field("Require Mobile Number?"; Rec.MobileNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Require Mobile Number?';
                    Visible = false;
                }

                field("Require Customer Address?"; Rec.ReqAddress)
                {
                    ApplicationArea = All;
                    Caption = 'Require Customer Address?';
                    Visible = false;
                }

                field("Require Amount?"; Rec.ReqAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Require Amount?';
                    Visible = false;

                }
                field("Require Customer Name?"; Rec.ReqcustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Require Customer Name?';
                    Visible = false;
                }

                field("Require Invoice Number?"; Rec.InvoiceNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Require Invoice Number?';
                    Visible = false;
                }

                field("SeerBit Reference"; Rec.Reference)
                {
                    ApplicationArea = All;
                    Caption = 'SeerBit Reference';
                    Editable = false;
                }
                field("Payment Link URL"; Rec.PaymentLink)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Link URL';
                    Editable = true;
                    Enabled = true;
                    AboutText = 'Copy payment link url and send to your customers';
                    AboutTitle = 'COpy Payment link';
                    ToolTip = 'Copy payment link url and send to your customers';




                }


            }
            group(Payment)
            {
                Visible = Rec.Reference <> '';
                part("PPayments"; SBPPaymentLinkPaymentsParts)
                {
                    // Filter on the sales orders that relate to the customer in the card page.
                    SubPageLink = "payment link reference" = FIELD(Reference), "TransactionType" = Const('PaymentLink');
                    Caption = 'Payments';
                    ApplicationArea = All;
                }
            }
        }

    }



    actions
    {


        area(Processing)
        {
            action("Create Link")
            {
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = CreateDocument;
                Visible = Rec.Reference = '';

                trigger OnAction()
                var
                    CustomerRec: Record "SBPPayment Link";
                    MsgText000: Label 'Payment Link no: %1 inserted.';
                    MsgText001: Label 'Payment Link no: %1 already exists.';

                begin

                    // if Rec.CustomizationName = '' then begin Error('Customised Name is required.'); exit; end;
                    if Rec.PaymentLinkName = '' then Error('Payment Link Name is required.');
                    if Format(Rec.Currency) = '' then Error('Currency is required.');
                    if Format(Rec.Amount) = '' then Error('Amount is required.');
                    if Rec.Currency = '' then Error('Curency is required.');
                    if Rec.CustomerName = '' then Error('Customer name is required.');
                    //if Rec.ExpiryDate = 0D then begin Error('Link Expiry Date is required.'); exit; end;
                    actionType := 'Create';
                    Status := 'ACTIVE';
                    //CustomerRec.init();
                    SendDataToAPI(rec.RecId);

                end;
            }
            action("Retrieve Payments")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = GetEntries;
                Visible = Rec.Reference <> '';

                trigger OnAction()
                var
                    CustomerRec: Record "SBPPayment Link";
                    Text000: Label 'Payment Link no: %1 inserted.';
                    Text001: Label 'Payment Link no: %1 already exists.';
                //ObjectJSONManagement: Codeunit "Retrieve Paymentlink Payments";

                begin
                    actionType := 'Verify';
                    if Dialog.Confirm('Retrieve payment for payment link ' + Format(Rec.Reference) + '. If you have set a Bank/Cash Account and Revenue/Receivable Account, payments will be posted directly to the General Ledger.', true, false) then
                        SendDataToAPI(rec.RecId);
                    //ObjectJSONManagement."Retrieve payments"(Rec.Reference)

                end;
            }
            action("Update Payment")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = UpdateDescription;
                Visible = Rec.Reference <> '';

                trigger OnAction()
                var
                    CustomerRec: Record "SBPPayment Link";
                    Text000: Label 'Payment Link no: %1 inserted.';
                    Text001: Label 'Payment Link no: %1 already exists.';

                begin
                    actionType := 'Update';
                    Status := Rec.Status;
                    if Dialog.Confirm('Update payment for payment link ' + Format(Rec.Reference), true, false) then
                        SendDataToAPI(rec.RecId);
                end;
            }

            action("Stop")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = StopPayment;
                Visible = (Rec.Reference <> '') and (Rec.Status = 'ACTIVE'); //Rec.accountNumber <> '';

                trigger OnAction()
                var
                    EmptyCurrencyOption: Option;
                begin
                    actionType := 'Update';
                    status := 'INACTIVE';
                    if Dialog.Confirm('Stop payment for payment link ' + Format(Rec.Reference), true, false) then
                        SendDataToAPI(rec.RecId);


                end;


            }

            action("Re-activate")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Image = ReOpen;
                Visible = (Rec.Reference <> '') and (Rec.Status = 'INACTIVE'); //Rec.accountNumber <> '';

                trigger OnAction()
                var
                    EmptyCurrencyOption: Option;
                begin
                    actionType := 'Update';
                    status := 'ACTIVE';
                    if Dialog.Confirm('Re-activate payment for payment link ' + Format(Rec.Reference), true, false) then
                        SendDataToAPI(rec.RecId);


                end;


            }
        }
    }
    Trigger OnOpenPage();
    var
        SBPPaymentLinkRec: Record "SBPPayment Link";
        SalesOrderNo: Integer;
    begin
        SBPPaymentLinkRec := SBPPaymentLinkRec;
        SalesOrderNo := SBPPaymentLinkRec.RecId;
        // Message(Format(SalesOrderNo));
    end;


    /// <summary>
    /// SendDataToAPI.
    /// </summary>
    /// <param name="RecId">Integer.</param>
    procedure SendDataToAPI(RecId: Integer)
    var
        HttpClient: HttpClient;
        PaymentLink: Record "SBPPayment Link";

        Items: Record Item;
        Response: HttpResponseMessage;
        Payload: Text;
        getPayload: Text;
        InvoiceItems: Text;
        client: HttpClient;
        request: HttpRequestMessage;
        getRequest: HttpRequestMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        getContent: HttpContent;
        responseText: Text;
        postresponseText: Text;
        ResponseBody: Text;
        RequestBody: Text;
        jsonObj: JsonObject;
        jsonToken: JsonToken;
        PaymentLinkRefToken: JsonToken;
        paymentLinkIdToken: JsonToken;
        paymentLinkUrlToken: JsonToken;
        JObjectRequest: JsonObject;
        PayloadJson: Text;
        data: Text;
        chk: Boolean;
        EncryptedKey: Text;
        AmountRequired: Text;
        CustomerNameRequired: Text;
        TxtLinkExpirable: Text;
        TxtOneTime: Text;
        PCnt: Integer;

        payments: JsonObject;
        PaymentsJsonObject: JsonObject;
        PaymentsJsonObjectToken: JsonToken;
        ShipTo: JsonObject;
        PaymentsArray: JsonArray;
        customerToken: jsonToken;
        PaymentArrayToken: jsonToken;
        customerIdToken: jsonToken;
        paymentTypeToken: jsonToken;
        amountToken: jsonToken;
        paymentIdToken: jsonToken;
        paymentKeyToken: jsonToken;
        paymentReferenceToken: jsonToken;
        payLinkAmountToken: jsonToken;
        fullNameToken: jsonToken;
        createdAtToken: jsonToken;
        InsertResponseText: Text;
        Index: Integer;
        paymentsRecord: Record "SBPPaymentPayments";
        genraljournalline: Record "Gen. Journal Line";
        glaccount: Record "G/L Account";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        businessdetails: Record "Company Information";
        reasonToken: JsonToken;
        statusToken: JsonToken;
        emailToken: JsonToken;
        countryToken: JsonToken;
        currencyToken: JsonToken;
        paymentDateToken: JsonToken;
        StatusMsg: Text;

    begin
        businessdetails.FindFirst();
        // Initialize the HttpClient 
        getPayload := '{';
        getPayload += '"key": "' + businessdetails.SBPSecKey + '.' + businessdetails.SBPPublicKey + '"';
        getPayload += '}';
        getContent.WriteFrom(getPayload);
        //Message(getPayload);
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
        IF not jsonObj.Get('data', jsonToken) then
            Error('Invalid response from server');
        jsonObj.Get('data', jsonToken);
        jsonObj.ReadFrom(Format(jsonToken));
        jsonObj.Get('EncryptedSecKey', jsonToken);

        jsonObj.ReadFrom(Format(jsonToken));
        jsonObj.Get('encryptedKey', jsonToken);
        EncryptedKey := Format(jsonToken);
        Rec.SETRANGE("RecId", Rec.RecId);
        IF Rec.OneTime THEN TxtOneTime := 'true' else TxtOneTime := 'false';
        IF Rec.reqAmount THEN AmountRequired := 'true' else AmountRequired := 'false';
        IF Rec.LinkExpirable THEN TxtLinkExpirable := 'true' else TxtLinkExpirable := 'false';
        IF Rec.ReqcustomerName THEN CustomerNameRequired := 'true' else CustomerNameRequired := 'false';

        IF PaymentLink.FINDSET THEN BEGIN
            // Prepare the payload
            Payload := '{';
            If (actionType = 'Create') or (actionType = 'Update') then begin
                Payload += '"token": ' + EncryptedKey + ',';
                Payload += '"status": "' + Status + '",';
                Payload += '"paymentLinkId": "' + Rec.Reference + '",';
                Payload += '"publicKey": "' + businessdetails.SBPPublicKey + '",';
                Payload += '"paymentLinkName": "' + Rec.PaymentLinkName + '",';
                Payload += '"description": "' + Rec.Description + '",';
                Payload += '"currency": "' + Rec.Currency + '",';
                Payload += '"amount": "' + Format(Rec.Amount).Replace(',', '') + '",';
                Payload += '"successMessage": "' + Rec.SuccessMessage + '",';
                Payload += '"customizationName": "' + Format(System.CurrentDateTime()).Replace('/', '').Replace(' ', '').Replace(':', '') + '",';
                Payload += '"paymentFrequency": "' + Format(Rec.PaymentFrequency) + '",';
                Payload += '"paymentReference": "",';
                Payload += '"email": "' + Rec.Email + '",';
                Payload += '"requiredFields": {';
                Payload += '"address": true,';
                Payload += '"amount": true,';
                Payload += '"customerName": true,';
                Payload += '"mobileNumber": false,';
                Payload += '"invoiceNumber": false';
                Payload += '},';
                Payload += '"linkExpirable": ' + TxtLinkExpirable + ',';
                Payload += '"expiryDate": "' + Format(Rec.ExpiryDate, 0, 9) + '",';
                Payload += '"oneTime": ' + TxtOneTime + '';
            end else
                if actionType = 'Verify' then begin
                    Payload += '"bearertoken": ' + EncryptedKey + ',';
                    Payload += '"status": "' + Rec.Status + '",';
                    Payload += '"paymentReference": "' + Rec.Reference + '",';
                    Payload += '"publicKey": "' + businessdetails.SBPPublicKey + '"';

                end;
            Payload += '}';
            content.WriteFrom(Payload);
            // Message(Payload);
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

            IF actionType = 'Create' then begin
                request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/paymentlink/create');
                request.Method := 'POST';
            end else
                if actionType = 'Update' then begin
                    request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/paymentlink/update');
                    request.Method := 'POST';
                end else
                    if actionType = 'Verify' then begin
                        request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/paymentlink/getpaymentLinkById');
                        request.Method := 'POST';
                    end;

            client.Send(request, response);

            // Read the response content as json.
            response.Content().ReadAs(postresponseText);

            chk := jsonObj.ReadFrom(postresponseText);
            // Message(postresponseText);
            // if jsonObj.Get('data', jsonToken) then
            //if not Format(jsonToken).Contains('Successful') then begin
            //  Error(Format(jsonToken));
            // begin


            if (actionType <> 'Verify') then begin
                if not jsonObj.Get('data', jsonToken) then
                    Error('Invalid response from server');

                if (actionType = 'Create') or (actionType = 'Update') then
                    Message('Payment link ' + actionType + ' was successful ')
                else
                    if (status = 'INACTVE') then Message('Payment Link stoped! ');
                //jsonObj.Get('data', jsonToken);
                jsonObj.ReadFrom(Format(jsonToken));
                jsonObj.Get('paymentLinks', jsonToken);
                jsonObj.ReadFrom(Format(jsonToken));
                jsonObj.Get('status', jsonToken);
                //jsonObj.Get('paymentReference', PaymentLinkRefToken);
                jsonObj.Get('paymentLinkId', paymentLinkIdToken);
                jsonObj.Get('paymentLinkUrl', paymentLinkUrlToken);
                Status := Format(jsonToken);
                Rec.Reference := Format(paymentLinkIdToken).Replace('"', '');
                Rec.Status := Format(jsonToken).Replace('"', '');
                Rec.PaymentLink := 'https://pay.seerbitapi.com/' + Format(paymentLinkIdToken).Replace('"', '');//Format(paymentLinkUrlToken).Replace('"', '');
                Rec.Modify();
            end

            else
                if actionType = 'Verify' then begin

                    InsertResponseText := 'No new payment';
                    IF not jsonObj.Get('payload', jsonToken) then begin
                        if jsonObj.Get('message', jsonToken) then Message(Format(jsonToken).Replace('"', '')) else Error('Invalid response from server');
                    end
                    else begin


                        //genraljournalline.Modify();

                        PaymentsArray.ReadFrom(Format(jsonToken));
                        // Message(Format(PaymentsArray));
                        for Index := 0 to PaymentsArray.Count - 1 do begin
                            if (PaymentsArray.Get(index, PaymentArrayToken)) then begin
                                // Message('paymentArrayToken ' + Format(paymentArrayToken));
                                paymentsRecord.Init();
                                PaymentsJsonObject.ReadFrom(Format(PaymentArrayToken));
                                PaymentsJsonObject.get('paymentReference', paymentReferenceToken);
                                // Message('Payment refre ' + Format(paymentReferenceToken));
                                paymentsRecord.SetFilter(paymentReference, Format(paymentReferenceToken).REPLACE('"', ''));
                                // paymentsRecord.SetRange(paymentReference, Format(paymentReferenceToken).REPLACE('"', ''));
                                // Message('Payment count ' + Format(paymentsRecord.Count));
                                //Message('Payment count ' + Format(paymentsRecord.));

                                if not paymentsRecord.FINDSET then begin
                                    paymentsRecord.Reset();
                                    // Message('0ot Table count ' + Format(paymentsRecord.Count));
                                    if paymentsRecord.IsEmpty then begin
                                        //paymentsRecord.FindLast();
                                        //Message('0ot X ' + Format(paymentsRecord.Id));
                                        paymentsRecord.Init();
                                        // paymentsRecord.Find('+');

                                        paymentsRecord.Id := 1;
                                        //.Id := 0;
                                        // paymentsRecord.Find('+');
                                    end else begin
                                        paymentsRecord.Reset();
                                        paymentsRecord.FindLast();
                                        paymentsRecord.Id := paymentsRecord.Id + 1;
                                    end;


                                    //  Message('Payment 1 ' + Format(paymentsRecord.Id));
                                    // paymentsRecord.SetFilter(Id, Format(paymentsRecord.Id));
                                    paymentsRecord.Id := paymentsRecord.Id + 1;

                                    if not PaymentsJsonObject.get('status', statusToken) then begin
                                        Message('Invalid response from server - status not found');
                                        exit;
                                    end;

                                    // Convert status (PUSHED becomes SUCCESS)
                                    if Format(statusToken).REPLACE('"', '') = 'PUSHED' then
                                        StatusMsg := 'SUCCESS'
                                    else
                                        StatusMsg := Format(statusToken).REPLACE('"', '');

                                    if (PaymentsJsonObject.get('customerName', fullNameToken)) then paymentsRecord."Full Name" := Format(fullNameToken).REPLACE('"', '');
                                    if (PaymentsJsonObject.get('paymentLinkId', paymentLinkIdToken)) then paymentsRecord.paymentLinkId := Format(paymentLinkIdToken).REPLACE('"', '');
                                    if (PaymentsJsonObject.get('paymentReference', paymentReferenceToken)) then paymentsRecord.paymentReference := Format(paymentReferenceToken).REPLACE('"', '');
                                    if (PaymentsJsonObject.get('amount', payLinkAmountToken)) then paymentsRecord.payLinkAmount := payLinkAmountToken.AsValue().AsDecimal();
                                    if (PaymentsJsonObject.get('createdAt', createdAtToken)) then paymentsRecord."payment date" := FORMAT(FORMAT(FORMAT(createdAtToken).REPLACE('"', '')).REPLACE('T', ' '), 19, 0);
                                    if (PaymentsJsonObject.get('paymentLinkId', PaymentLinkRefToken)) then paymentsRecord."payment link reference" := Format(PaymentLinkRefToken).REPLACE('"', '');

                                    if (PaymentsJsonObject.get('reason', reasonToken)) then paymentsRecord.Reason := Format(reasonToken).REPLACE('"', '');
                                    paymentsRecord."Payment Status" := StatusMsg;
                                    if (PaymentsJsonObject.get('country', countryToken)) then paymentsRecord.country := Format(countryToken).REPLACE('"', '');
                                    if (PaymentsJsonObject.get('customerEmail', emailToken)) then paymentsRecord.email := Format(emailToken).REPLACE('"', '');
                                    if (PaymentsJsonObject.get('currency', currencyToken)) then paymentsRecord.currency := Format(currencyToken).REPLACE('"', '');
                                    if (PaymentsJsonObject.get('paymentDate', paymentDateToken)) then paymentsRecord."payment date" := Format(paymentDateToken).REPLACE('"', '');

                                    paymentsRecord.TransactionType := 'PaymentLink';
                                    Rec."Total Payments" := PaymentsArray.Count;
                                    //Message('Ammount ' + Format(payLinkAmountToken));

                                    //paymentsRecord.paymentReference := Rec.PaymentReference;



                                    //paymentsRecord.SystemId := FORMAT(paymentReferenceToken);
                                    paymentsRecord.Insert(false);//then Status := 'success';
                                    InsertResponseText := 'New payment saved';

                                    if (Rec.PaymentReference <> '') then begin
                                        // Validate Bank/Cash Account exists
                                        glaccount.SetFilter("No.", Rec.PaymentReference);
                                        if not glaccount.FindFirst() then begin
                                            Message('Bank/Cash Account ' + Rec.PaymentReference + ' not found');
                                            exit;
                                        end;

                                        // Validate Revenue/Receivable Account is set (required for balanced posting)
                                        if Rec."Bal. Account No." = '' then begin
                                            Message('Please set a Revenue/Receivable Account before posting. This is required for balanced G/L entries.');
                                            exit;
                                        end;

                                        // Get the LCY code to check if we should set currency
                                        GeneralLedgerSetup.Get();

                                        // Initialize the journal line for direct posting (no journal setup required)
                                        genraljournalline.Init();
                                        genraljournalline."Line No." := 10000;
                                        genraljournalline."Posting Date" := Today;
                                        genraljournalline."Document Type" := "Gen. Journal Document Type"::Payment;
                                        // Use unique payment record ID for document number (ensures uniqueness)
                                        genraljournalline."Document No." := 'PL-' + Format(paymentsRecord.Id);
                                        // Store full SeerBit payment reference in External Document No. (35 char limit) for querying/reconciliation
                                        genraljournalline."External Document No." := CopyStr(Format(paymentReferenceToken).REPLACE('"', ''), 1, 35);
                                        genraljournalline."Account Type" := "Gen. Journal Account Type"::"G/L Account";
                                        genraljournalline."Account No." := Rec.PaymentReference;
                                        genraljournalline.Validate("Account No.");
                                        genraljournalline.Description := 'SeerBit Payment Link - ' + Format(paymentReferenceToken).REPLACE('"', '');

                                        // For local currency (NGN), do NOT set Currency Code - leave it blank
                                        // Only set Currency Code if it's a foreign currency
                                        if (Rec.Currency <> '') and (Rec.Currency <> GeneralLedgerSetup."LCY Code") and (Rec.Currency <> 'NGN') then
                                            genraljournalline.Validate("Currency Code", Rec.Currency)
                                        else
                                            genraljournalline."Currency Code" := ''; // Ensure it's blank for LCY

                                        genraljournalline."Gen. Posting Type" := glaccount."Gen. Posting Type";
                                        genraljournalline."Gen. Bus. Posting Group" := glaccount."Gen. Bus. Posting Group";
                                        genraljournalline."Gen. Prod. Posting Group" := glaccount."Gen. Prod. Posting Group";

                                        // Set Amount directly without currency conversion for LCY
                                        genraljournalline.Amount := payLinkAmountToken.AsValue().AsDecimal();
                                        genraljournalline."Amount (LCY)" := payLinkAmountToken.AsValue().AsDecimal();

                                        // Set the balancing account for proper double-entry posting
                                        genraljournalline."Bal. Account Type" := "Gen. Journal Account Type"::"G/L Account";
                                        genraljournalline."Bal. Account No." := Rec."Bal. Account No.";
                                        genraljournalline.Validate("Bal. Account No.");

                                        genraljournalline."SBPSeerBit - Tx. Refenece" := Format(paymentReferenceToken).REPLACE('"', '');
                                        genraljournalline."SBPSeerBit -Doc. Type" := 'Payment Link';

                                        // Post directly to the General Ledger (no journal setup required)
                                        GenJnlPostLine.RunWithCheck(genraljournalline);
                                        Message('Payment of ' + Format(payLinkAmountToken.AsValue().AsDecimal()) + ' posted to G/L Account ' + Rec.PaymentReference);
                                    end;
                                end else begin
                                    paymentsRecord.FindLast();
                                    // Message('Payment count 5 ' + Format(paymentsRecord.Id));
                                    // Message('Payment count 5 ' + Format(paymentReferenceToken).REPLACE('"', ''));



                                    // paymentsRecord.SetRange(paymentReference, Format(paymentReferenceToken).REPLACE('"', ''));
                                    // Message('Payment count ' + Format(paymentsRecord.Count));
                                    if (PaymentsJsonObject.get('status', statusToken)) then paymentsRecord."Payment Status" := Format(statusToken).REPLACE('"', '');
                                    // message('else rec ' + Format(statusToken).REPLACE('"', ''));

                                    paymentsRecord.Modify();


                                end;
                            end;
                        end;
                        Message(InsertResponseText);
                    end;
                end;
        end;



    end;


    var
        actionType: Text;
        plinks: Record "SBPPayment Link";
        Status: Text;
        paymentLinkText: Label 'Payment Link';
        TestActionLbl: Label 'Verify Transaction';
        payfreq: Enum "SBP Payment Frequency";


}


