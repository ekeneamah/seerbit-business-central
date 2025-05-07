pageextension 71855576 SBPSalesInvoiceListExt extends "Sales Invoice List"
{


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
                begin
                    CurrPage.SetSelectionFilter(SelectedInvoices);

                    if SelectedInvoices.IsEmpty() then
                        Error('No invoices selected.');

                    // Copy selected invoices into a temporary record
                    if SelectedInvoices.FindSet() then
                        repeat
                            TempSelectedInvoices := SelectedInvoices;
                            TempSelectedInvoices.Insert();
                        until SelectedInvoices.Next() = 0;

                    // Pass the temporary table properly to the confirmation page
                      ConfirmPageID := Page::SBPConfirmMultiInvoiceSend;
   if PAGE.RunModal(ConfirmPageID, TempSelectedInvoices) = Action::LookupOK then begin
    Sender.SendSelectedInvoices(TempSelectedInvoices);
    Success := true; // Assume success if no error is raised, or adjust based on actual method behavior
    if not Success then
        Error('Failed to send invoices:\n%1', Sender.GetLastErrorText());
end;
                    // Clear the temporary record
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
