/// <summary>
/// Page SBPVirtualAccountList (ID 50139).
/// </summary>
page 71855589 SBPVirtualAccountList
{
    SourceTable = SBPVirtualAccountTable;
    Caption = 'SeerBit - Virtual Accounts';
    UsageCategory = Lists;
    CardPageId = SBPVirtualAccountPage;
    Editable = false;
    DataCaptionFields = ID, fullName, accountNumber;
    PageType = List;
    Permissions =
        tabledata SBPVirtualAccountTable = R;





    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field(ID; Rec."ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Date';
                }
                field(publicKey; Rec.Reference)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(accountNumber; Rec.accountNumber)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Account Number';
                }
                field(fullName; Rec."FullName")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(currency; Rec."Currency")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(country; Rec."Country")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Rec.SystemCreatedAt);
        Rec.SetAscending(Rec.SystemCreatedAt, true);
    end;
}