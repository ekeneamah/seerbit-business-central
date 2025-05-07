page 71855577 SBPConfirmMultiInvoiceSend
{
    PageType = List;
    SourceTable = "Sales Header";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Caption = 'Confirm Invoices to Send';
    Editable = false; // Prevents editing
    InsertAllowed = false; // Prevents adding
    ModifyAllowed = false; // Prevents editing
    DeleteAllowed = false; // Prevents deleting

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; CompanyName)
                {
                    ApplicationArea = All;
                }
                field("Email"; Email)
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
     actions
    {
        area(processing)
        {
            action(ConfirmSend)
            {
                ApplicationArea = All;
                Caption = 'Yes, Send';
                Image = SendToMultiple;
                trigger OnAction()
                begin
                    ConfirmResult := true;
                    CurrPage.Close();
                end;
            }

            action(CancelSend)
            {
                ApplicationArea = All;
                Caption = 'No, Cancel';
                Image = Cancel;
                trigger OnAction()
                begin
                    ConfirmResult := false;
                    CurrPage.Close();
                end;
            }
        }
    }


    var
        CompanyName: Text[100];
        Email: Text[100];
         ConfirmResult: Boolean;

   trigger OnOpenPage()
    var
        CustomerRec: Record Customer;
    begin
        if Rec.FindSet() then
            repeat
                if CustomerRec.Get(Rec."Sell-to Customer No.") then begin
                    CompanyName := CustomerRec.Name;
                    Email := CustomerRec."E-Mail";
                end;
            until Rec.Next() = 0;
    end;

    procedure GetConfirmResult(): Boolean
    begin
        exit(ConfirmResult);
    end;
}
