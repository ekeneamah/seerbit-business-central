/// <summary>
/// Page VirtualAccountPage (ID 50102).
/// </summary>
page 71855616
 SBPVirtualAccountPage
{
    SourceTable = SBPVirtualAccountTable;
    Caption = 'SeerBit - Virtual Account';
    UsageCategory = Administration;
    PageType = Card;
    Editable = true;
    ApplicationArea = All;


    Description = 'This page allows you to create virtual account numbers \n This is only available to businesses in Nigeria.';
    Permissions =
        tabledata "Company Information" = R,
        tabledata Customer = R,
        tabledata "G/L Account" = R,
        tabledata "Gen. Journal Line" = RI,
        tabledata "SBPPaymentPayments" = RI,
        tabledata SBPVirtualAccountTable = RIMD;


    layout
    {
        area(Content)
        {
            Description = 'This page allows you to create virtual account numbers n/ This is only available to businesses in Nigeria.';
            group(General)
            {
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



                field(fullName; Rec.fullName)
                {
                    ApplicationArea = All;
                    Editable = true;
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Fullname of Customer';
                    Caption = 'Full Name';
                    trigger OnValidate()
                    begin
                        if Rec.reference = '' then Error('Please insert a customer full name');
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record Customer;
                    begin
                        ItemRec.Reset();
                        if Page.RunModal(Page::"Customer List", ItemRec) = Action::LookupOK then
                            Rec.Email := ItemRec."E-Mail";
                        Rec.fullName := ItemRec.Name;
                    end;
                }

                field(email; Rec."Email")
                {
                    ShowMandatory = true;
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Email';
                    Caption = 'Email';
                    trigger OnValidate()
                    begin
                        if Rec.reference = '' then Error('Please insert customer email');
                    end;
                }
                field(bankVerificationNumber; Rec.BankVerificationNumber)
                {
                    ApplicationArea = All;
                    Editable = true;
                    Numeric = true;
                    ToolTip = 'Enter the BVN of the customer';
                    Visible = false;
                    /*  trigger OnValidate()
                     begin
                         IF StrLen(Rec.BankVerificationNumber) <> 11 then BEGIN
                             Message('BVN is invalid. Length mshould be 11 digits');
                             Rec.BankVerificationNumber := '';
                         end;
                     end; */

                }

                field(currency; Rec."Currency")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowMandatory = true;
                    ToolTip = 'Currency';
                    Caption = 'Çurrency';
                    /* trigger OnAssistEdit()
                    var
                        Currencyrec: Record Currency;
                    begin
                        Currencyrec.reset();

                        if Page.RunModal(page::Currencies, Currencyrec) = ACTION::LookupOK then begin
                            rec.Currency := Currencyrec.Code;
                            // Rec."Currency" :=ChangeExchangeRate.CurrencyCode2
                        end;

                    end; */
                }

                field(country; Rec."Country")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowMandatory = true;
                    ToolTip = 'Country';
                    Caption = 'Country';
                    /*  trigger OnAssistEdit()
                     var
                         Currencyrec: Record "Country/Region";
                     begin
                         Currencyrec.reset();

                         if Page.RunModal(page::"Countries/Regions", Currencyrec) = ACTION::LookupOK then begin
                             rec.country := Currencyrec.Code;
                             // Rec."Currency" :=ChangeExchangeRate.CurrencyCode2
                         end;

                     end; */


                }



                group("Account Details")
                {
                    field(accountNumber; Rec.accountNumber)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Virtual Account No.';
                        ToolTip = 'VIrtual Account No.';
                    }
                    field(walet; Rec.wallet)
                    {
                        Caption = 'Wallet';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Walet';
                    }
                    field(bankname; Rec.bankName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Bank Name';
                    }
                    field(walletName; Rec.walletName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(linkingReference; Rec.linkingReference)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                    }


                }
            }
            group("Recieved Payment")
            {
                Visible = Rec.accountNumber <> '';
                part("PPayments"; SBPPaymentLinkPaymentsParts)
                {
                    // Filter on the sales orders that relate to the customer in the card page.
                    SubPageLink = accountNumber = FIELD(accountNumber), "TransactionType" = Const('Virtual Account');
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
            action("Send")
            {
                Promoted = true;
                PromotedCategory = Process;
                Caption = 'Create';
                ApplicationArea = All;
                Visible = Rec.accountNumber = '';
                Image = Select;
                PromotedOnly = true;

                trigger OnAction()
                var
                    EmptyCurrencyOption: Option;
                begin
                    actionType := 'Create';
                    if Rec.email = '' then begin Error('Email is required.'); exit; end;
                    if Rec.fullName = '' then begin Error('Customer full name is required.'); exit; end;
                    if Rec.Email = '' then begin Error('Customer email is required.'); exit; end;



                    SendDataToAPI(rec.ID);

                end;


            }

            action("Update")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = false; //Rec.accountNumber <> '';

                trigger OnAction()
                var
                    EmptyCurrencyOption: Option;
                begin
                    actionType := 'Update';
                    if Rec.email = '' then begin Error('Email is required.'); exit; end;
                    if Rec.fullName = '' then begin Error('Customer full name is required.'); exit; end;
                    if Rec.Email = '' then begin Error('Customer email is required.'); exit; end;

                    SendDataToAPI(rec.ID);


                end;


            }
            action("Retrieve Payments")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = Rec.accountNumber <> '';
                Image = GetActionMessages;

                trigger OnAction()
                var
                    EmptyCurrencyOption: Option;
                begin
                    actionType := 'Verify';
                    if Dialog.Confirm('Retrieve payments for account number ' + Format(Rec.accountNumber) + '. If you have set a Bank/Cash Account and Revenue/Receivable Account, payments will be posted directly to the General Ledger.', true, false) then
                        SendDataToAPI(rec.ID);

                end;


            }
            action("Stop")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = false; //Rec.accountNumber <> '';

                trigger OnAction()
                var
                    EmptyCurrencyOption: Option;
                begin
                    actionType := 'Update';
                    if Rec.email = '' then begin Error('Email is required.'); exit; end;
                    if Rec.fullName = '' then begin Error('Customer full name is required.'); exit; end;
                    if Rec.Email = '' then begin Error('Customer email is required.'); exit; end;
                    Rec.status := 'Inactive';
                    SendDataToAPI(rec.ID);


                end;


            }
        }
    }

    /// <summary>
    /// SendDataToAPI.
    /// </summary>
    /// <param name="RecId">Integer.</param>
    procedure SendDataToAPI(RecId: Integer)
    var
        HttpClient: HttpClient;
        PaymentLink: Record SBPVirtualAccountTable;
        businessdetails: Record "Company Information";
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
        statusjsonToken: JsonToken;
        codejsonToken: JsonToken;
        paymentsToken: JsonToken;
        referenceToken: JsonToken;
        walletNameToken: JsonToken;
        messageToken: JsonToken;
        bankNameToken: JsonToken;
        accountNumberToken: JsonToken;
        PaymentLinkRefToken: JsonToken;
        walletToken: JsonToken;
        paymentLinkIdToken: JsonToken;
        linkingReferenceToken: JsonToken;
        JObjectRequest: JsonObject;
        PayloadJson: Text;
        data: Text;
        chk: Boolean;
        EncryptedKey: Text;
        AmountRequired: Text;
        CustomerNameRequired: Text;
        TxtLinkExpirable: Text;
        TxtOneTime: Text;
        Status: Text;
        InsertResponseText: Text;
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
        jsonStatusToken: JsonToken;
        paymentKeyToken: jsonToken;
        paymentReferenceToken: jsonToken;
        payLinkAmountToken: jsonToken;
        fullNameToken: jsonToken;
        createdAtToken: jsonToken;
        reasonToken: JsonToken;
        statusToken: JsonToken;
        emailToken: JsonToken;
        countryToken: JsonToken;
        currencyToken: JsonToken;
        Index: Integer;
        paymentsRecord: Record "SBPPaymentPayments";
        genraljournalline: Record "Gen. Journal Line";
        glaccount: Record "G/L Account";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        paymentDateToken: JsonToken;
        StatusMsg: Text;
    begin
        businessdetails.FindFirst();
        // Initialize the HttpClient 
        getPayload := '{';
        getPayload += '"key": "' + businessdetails.SBPSecKey + '.' + businessdetails.SBPPublicKey + '"';
        getPayload += '}';
        //Message(getPayload);
        getContent.WriteFrom(getPayload);
        // Message(getPayload);
        // HttpClient.GET('https://seerbitapi.com/api/v2/encrypt/keys' + RequestBody, response);
        getContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        // Assigning content to request. Content will actually create a copy of the content and assign it.
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
        if not jsonObj.Get('status', jsonStatusToken) then
            //  message(Format(jsonStatusToken)) else
            Error('Invalid response from server');
        IF not jsonObj.Get('data', jsonToken) then
            Error('Invalid response from server');
        jsonObj.Get('data', jsonToken);
        jsonObj.ReadFrom(Format(jsonToken));
        jsonObj.Get('EncryptedSecKey', jsonToken);

        jsonObj.ReadFrom(Format(jsonToken));
        jsonObj.Get('encryptedKey', jsonToken);
        EncryptedKey := Format(jsonToken);
        // Message(Format(RecId) + ' ' + Format(Rec.ID));
        Rec.SETRANGE("ID", Rec.ID);
        Rec.Status := 'ACTIVE';
        IF PaymentLink.FINDSET THEN BEGIN
            // Prepare the payload
            Payload := '{';
            If (actionType = 'Create') or (actionType = 'Update') then begin
                Payload += '"token": ' + EncryptedKey + ',';
                Payload += '"fullName": "' + Rec.fullName + '",';
                Payload += '"bankVerificationNumber": "' + Rec.bankVerificationNumber + '",';
                Payload += '"publicKey": "' + businessdetails.SBPPublicKey + '",';
                Payload += '"country": "' + Rec.country + '",';
                Payload += '"currency": "' + Rec.Currency + '",';
                Payload += '"email": "' + Rec.Email + '",';
                Payload += '"status": "' + Rec.Status + '",';
                Payload += '"reference":"' + Format(System.CurrentDateTime()).Replace('/', '').Replace(' ', '').Replace(':', '') + '"';

            end else
                if actionType = 'Verify' then begin
                    Payload += '"bearertoken": ' + EncryptedKey + ',';
                    Payload += '"status": "' + Rec.Status + '",';
                    Payload += '"accountNumber": "' + Rec.accountNumber + '",';
                    Payload += '"publickey": "' + businessdetails.SBPPublicKey + '"';

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
                request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/virtualAccount/create');
                request.Method := 'POST';
            end else
                if actionType = 'Update' then begin
                    request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/virtualAccount/update');
                    request.Method := 'POST';
                end else
                    if actionType = 'Verify' then begin
                        request.SetRequestUri('https://erp.middleware.seerbitapi.com/api/v1/virtualAccount/byreferenceno');
                        request.Method := 'POST';
                    end;

            client.Send(request, response);

            // Read the response content as json.
            response.Content().ReadAs(postresponseText);
            //  Message('create response ' + postresponseText);

            chk := jsonObj.ReadFrom(postresponseText);
            if jsonObj.Get('message', messageToken) then begin if not FORMAT(messageToken).Contains('successful') then Error('Message ' + Format(messageToken)); end;
            IF not jsonObj.Get('data', jsonToken) then begin
                Error('Invalid response from server')
            end
            else begin
                if (actionType = 'Create') then begin
                    jsonObj.Get('data', jsonToken);
                    jsonObj.Get('status', statusjsonToken);
                    jsonObj.ReadFrom(Format(jsonToken));
                    jsonObj.Get('code', codejsonToken);
                    if jsonObj.Get('payments', paymentsToken) then begin
                        jsonObj.ReadFrom(Format(paymentsToken));

                        jsonObj.Get('reference', referenceToken);
                        jsonObj.Get('walletName', walletNameToken);
                        jsonObj.Get('bankName', bankNameToken);
                        jsonObj.Get('accountNumber', accountNumberToken);
                        jsonObj.Get('wallet', walletToken);

                        // jsonObj.Get('linkingReference', linkingReferenceToken);

                        rec.accountNumber := Format(accountNumberToken).Replace('"', '');
                        rec.code := Format(codejsonToken).Replace('"', '');
                        rec.bankName := Format(bankNameToken).Replace('"', '');
                        rec.walletName := Format(walletNameToken).Replace('"', '');
                        rec.reference := Format(referenceToken).Replace('"', '');
                        rec.wallet := Format(walletToken).Replace('"', '');//rec.linkingReference := Format(linkingReferenceToken).Replace('"', '');
                        rec.status := Format(statusjsonToken).Replace('"', '');

                        Rec.Modify();
                        Message('Virtual account ' + Format(accountNumberToken).Replace('"', '') + ' created successfully ');
                    end else
                        error('Virtual account could not be created');
                end else
                    if actionType = 'Verify' then begin
                        PaymentsJsonObject.ReadFrom(Format(jsonToken));
                        InsertResponseText := 'No new payment';
                        if PaymentsJsonObject.Get('payload', PaymentArrayToken) then begin
                            PaymentsArray.ReadFrom(Format(PaymentArrayToken));
                            // Message(Format(PaymentArrayToken));
                            //paymentsRecord.Init();
                            for Index := 0 to PaymentsArray.Count() - 1 do begin
                                if (PaymentsArray.Get(index, PaymentArrayToken)) then begin
                                    PaymentsJsonObject.ReadFrom(Format(PaymentArrayToken));
                                    PaymentsJsonObject.get('paymentReference', paymentReferenceToken);
                                    // Message('Payment refre ' + Format(paymentReferenceToken));
                                    paymentsRecord.SetFilter(paymentReference, Format(paymentReferenceToken).REPLACE('"', ''));
                                    // paymentsRecord.SetRange(paymentReference, Format(paymentReferenceToken).REPLACE('"', ''));
                                    // Message('Payment count ' + Format(paymentsRecord.Count));
                                    //Message('Payment count ' + Format(paymentsRecord.));
                                    if not PaymentsJsonObject.get('status', statusToken) then begin message('invalid response from server value for status is not found'); exit; end;
                                    message('status ' + Format(statusToken));
                                    if not paymentsRecord.FindSet then begin
                                        paymentsRecord.Reset();
                                        //  Message('0ot Table count ' + Format(paymentsRecord.Count));
                                        if paymentsRecord.IsEmpty then begin
                                            //paymentsRecord.FindLast();
                                            // Message('0ot X ' + Format(paymentsRecord.Id));
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


                                        // Message('Payment 1 ' + Format(paymentsRecord.Id));
                                        // paymentsRecord.SetFilter(Id, Format(paymentsRecord.Id));

                                        if Format(statusToken).REPLACE('"', '') = 'PUSHED' then StatusMsg := 'SUCCESS' else StatusMsg := Format(statusToken).REPLACE('"', '');

                                        if (PaymentsJsonObject.get('customerName', fullNameToken)) then paymentsRecord."Full Name" := Format(fullNameToken).REPLACE('"', '');
                                        if (PaymentsJsonObject.get('paymentLinkId', paymentLinkIdToken)) then paymentsRecord.paymentLinkId := Format(paymentLinkIdToken).REPLACE('"', '');
                                        if (PaymentsJsonObject.get('paymentReference', paymentReferenceToken)) then paymentsRecord.paymentReference := Format(paymentReferenceToken).REPLACE('"', '');
                                        if (PaymentsJsonObject.get('amount', payLinkAmountToken)) then paymentsRecord.payLinkAmount := payLinkAmountToken.AsValue().AsDecimal();
                                        if (PaymentsJsonObject.get('createdAt', createdAtToken)) then paymentsRecord."payment date" := FORMAT(FORMAT(FORMAT(createdAtToken).REPLACE('"', '')).REPLACE('T', ' '), 19, 0);
                                        if (PaymentsJsonObject.get('paymentLinkId', PaymentLinkRefToken)) then paymentsRecord."payment link reference" := Format(PaymentLinkRefToken).REPLACE('"', '');

                                        if (PaymentsJsonObject.get('reason', reasonToken)) then paymentsRecord.Reason := Format(reasonToken).REPLACE('"', '');
                                        if (PaymentsJsonObject.get('status', statusToken)) then paymentsRecord."Payment Status" := StatusMsg;
                                        if (PaymentsJsonObject.get('country', countryToken)) then paymentsRecord.country := Format(countryToken).REPLACE('"', '');
                                        if (PaymentsJsonObject.get('customerEmail', emailToken)) then paymentsRecord.email := Format(emailToken).REPLACE('"', '');
                                        if (PaymentsJsonObject.get('currency', currencyToken)) then paymentsRecord.currency := Format(currencyToken).REPLACE('"', '');
                                        if (PaymentsJsonObject.get('paymentDate', paymentDateToken)) then paymentsRecord."payment date" := Format(paymentDateToken).REPLACE('"', '');
                                        paymentsRecord.accountNumber := Rec.accountNumber;
                                        // Rec."Total Payments" := PaymentsArray.Count;
                                        //Rec.Modify(true);
                                        paymentsRecord.TransactionType := 'Virtual Account';

                                        //.Id := 0;
                                        // paymentsRecord.FInd('+');


                                        //paymentsRecord.FindLast();
                                        // Message('Payment 1' + Format(paymentsRecord.Id));
                                        // paymentsRecord.SetFilter(Id, Format(paymentsRecord.Id));
                                        //Message('Ammount ' + Format(payLinkAmountToken));
                                        // paymentsRecord.Id := paymentsRecord.Id + 1;
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
                                            genraljournalline."Document No." := 'SB-VA-' + Format(paymentReferenceToken).REPLACE('"', '');
                                            genraljournalline."Account Type" := "Gen. Journal Account Type"::"G/L Account";
                                            genraljournalline."Account No." := Rec.PaymentReference;
                                            genraljournalline.Validate("Account No.");
                                            genraljournalline.Description := 'SeerBit Customer Payment - ' + Format(paymentReferenceToken).REPLACE('"', '');

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
                                            genraljournalline."SBPSeerBit -Doc. Type" := 'Virtual Account';

                                            // Post directly to the General Ledger (no journal setup required)
                                            GenJnlPostLine.RunWithCheck(genraljournalline);
                                            Message('Payment of ' + Format(payLinkAmountToken.AsValue().AsDecimal()) + ' posted to G/L Account ' + Rec.PaymentReference);
                                        end;
                                    end else begin
                                        paymentsRecord.FindLast();
                                        //  Message('Payment count 5 ' + Format(paymentsRecord.Id));
                                        // Message('Payment count 5 ' + Format(paymentReferenceToken).REPLACE('"', ''));



                                        // paymentsRecord.SetRange(paymentReference, Format(paymentReferenceToken).REPLACE('"', ''));
                                        //  Message('Payment count ' + Format(paymentsRecord.Count));
                                        if (PaymentsJsonObject.get('status', statusToken)) then paymentsRecord."Payment Status" := Format(statusToken).REPLACE('"', '');
                                        //  message('else rec ' + Format(statusToken).REPLACE('"', ''));

                                        paymentsRecord.Modify();
                                    end;


                                end;
                            end;
                            Message(InsertResponseText);
                        end
                    end;
            end;
        END;


    end;

    var
        actionType: Text;

    Trigger OnOpenPage();
    var
        rec: Record SBPVirtualAccountTable;
        SalesOrderNo: Integer;
    begin
        rec := Rec;
        SalesOrderNo := rec.ID;
        // Message(Format(SalesOrderNo));
    end;

}
