pageextension 71855576 SBPSalesInvoiceListExt extends "Sales Invoice List"
{

    layout
    {
        addafter("Sell-to Customer No.")
        {
         
           
                field("SBP sent to seerbit"; Rec."SBP sent to seerbit")
                {
                    ApplicationArea = All;
                    Caption='sent to seerbit';
                    ToolTip = 'Invoices sent to customer through seerbit payment gateway';
                }
                field("SBP SeerBit - Batch ID"; Rec."SBP SeerBit - Batch ID")
                {
                    ApplicationArea = All;
                    Caption='Batch ID';
                    ToolTip = 'Batch ID of invoice sent to customer by SeerBit';
                }
                field("SBP SeerBit - Invoice Number"; Rec."SBP SeerBit - Invoice Number")
                {
                    ApplicationArea = All;
                    Caption='Invoice Number';
                    ToolTip = 'Invoice number of invoice sent to customer by SeerBit';
                }
                field("SBP SeerBit - Status"; Rec."SBP SeerBit - Status")
                {
                    ApplicationArea = All;
                    Caption='Status';
                    ToolTip = 'Status of invoice sent to customer by SeerBit';
                }

            
        }
        addlast(factboxes)
        {


            part("SBP Sales Invoice FactBox"; "SBP Fact Box Sales Invoice")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "No." = FIELD("No.");
                Caption = 'SeerBit Details';
                Visible = true;
                
          
            }
        }
    }

    actions
    {
        addlast(Processing)
        {



            action(SBPMultiSalesInvoiceCodeunit)
            {
                ApplicationArea = All;
                Caption = 'Send to Payment Gateway';
                Image = SendConfirmation;
                Enabled = IsSelectionMade;
                ToolTip = 'Send selected invoices to SeerBit Gateway';


                trigger OnAction()
                var
                    Sender: Codeunit SBPMultiSalesInvoice;
                    SelectedInvoices: Record "Sales Header";
                    TempSelectedInvoices: Record "Sales Header" temporary;
                    ConfirmResult: Boolean;
                    ConfirmPageID: Integer;
                    Success: Boolean;
                    TodayDate: Date;
                    CompanyInfo: Record "Company Information";

                begin
                    CurrPage.SetSelectionFilter(SelectedInvoices);

                    if SelectedInvoices.IsEmpty() then
                        Error('No invoices selected.');

                    TodayDate := Today();
                    CompanyInfo.Get();
                    // Check if the selected invoices are valid
                    ConfirmResult := false;
                    ConfirmPageID := 0;
                    Success := false;

                    // Copy selected invoices into a temporary record and validate each
                    if SelectedInvoices.FindSet() then
                        repeat
                            // Validation: Due Date
                            if SelectedInvoices."Due Date" < TodayDate then
                                Error('Invoice %1 has a due date in the past: %2', SelectedInvoices."No.", SelectedInvoices."Due Date");

                            // Validation: Currency Code
                            // Validation: Currency Code & Company Default
                            if SelectedInvoices."Currency Code" = '' then
                                if CompanyInfo."SBP Default Currency" = '' then
                                    Error('Invoice %1 has no currency code, and no company default currency is set.', SelectedInvoices."No.");

                            TempSelectedInvoices := SelectedInvoices;
                            TempSelectedInvoices.Insert();
                        until SelectedInvoices.Next() = 0;

                    // Show confirmation page
                    ConfirmPageID := Page::SBPConfirmMultiInvoiceSend;
                    if PAGE.RunModal(ConfirmPageID, TempSelectedInvoices) = Action::LookupOK then begin
                        Success := Sender.SendSelectedInvoices(TempSelectedInvoices);

                        if not Success then
                            Error('Failed to send invoices:\n%1', Sender.GetLastErrorText());
                    end else
                        Error('User canceled the confirmation page.');

                    if Success then
                        Message('Invoices sent successfully.')
                    else
                        Error('Failed to send invoices:\n%1', Sender.GetLastErrorText());

                    TempSelectedInvoices.DeleteAll();
                end;

            }


        }
    }
    trigger OnAfterGetRecord()
    var
        TempRec: Record "Sales Header";
    begin
        CurrPage.SetSelectionFilter(TempRec);
        IsSelectionMade := not TempRec.IsEmpty();
    end;

    var
        IsSelectionMade: Boolean;
}
