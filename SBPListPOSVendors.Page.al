/// <summary>
/// Page SBP List POS Vendors (ID 50125).
/// </summary>
page 71855587
 "SBP List POS Vendors"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SBP Table POS Vendors";
    Editable = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;
    AutoSplitKey = true;
    DelayedInsert = true;
    AccessByPermission = tabledata "SBP Table POS Vendors" = RIMD;
    Permissions =
        tabledata "SBP Pos location table" = R,
        tabledata "SBP Table POS Vendors" = RIMD,
        tabledata User = R;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field(RecId; Rec.RecId)
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    Editable = false;
                    ToolTip = 'Unique record identifier';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User Email';
                    ShowMandatory = true;
                    Editable = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        UserRec: Record User;
                    begin
                        UserRec.Reset();
                        if Page.RunModal(Page::"Users", UserRec) = Action::LookupOK then begin
                            Rec."User ID" := UserRec."Authentication Email";
                            Rec."Full Name" := UserRec."Full Name";
                            Rec.Email := UserRec."Contact Email";
                            CurrPage.Update();
                        end;
                    end;

                    trigger OnValidate()
                    var
                        UserRec: Record User;
                    begin
                        if Rec."User ID" <> '' then begin
                            UserRec.Reset();
                            UserRec.SetRange("Authentication Email", Rec."User ID");
                            if UserRec.FindFirst() then begin
                                Rec."Full Name" := UserRec."Full Name";
                                Rec.Email := UserRec."Contact Email";
                            end;
                        end;
                    end;


                }
                field("Email"; Rec.Email)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Email';


                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;


                }


                field(Location; Rec.LocationId)
                {
                    ApplicationArea = All;
                    Caption = 'Location';
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        LocationRec: Record "SBP Pos location table";
                    begin
                        LocationRec.Reset();
                        if Page.RunModal(Page::"SBP List POS Locations", LocationRec) = Action::LookupOK then begin
                            Rec.LocationId := LocationRec.LocationId;
                            Rec.LocationName := LocationRec.Description;
                            CurrPage.Update();
                        end;
                    end;

                    trigger OnValidate()
                    var
                        LocationRec: Record "SBP Pos location table";
                    begin
                        if Rec.LocationId <> '' then begin
                            LocationRec.Reset();
                            LocationRec.SetRange(LocationId, Rec.LocationId);
                            if LocationRec.FindFirst() then
                                Rec.LocationName := LocationRec.Description;
                        end;
                    end;


                }

                field("Location Name"; Rec.LocationName)
                {
                    ApplicationArea = All;


                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateVendors)
            {
                ApplicationArea = All;
                Caption = 'Validate All Vendors';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Check that all vendors have required fields filled';

                trigger OnAction()
                var
                    TempVendor: Record "SBP Table POS Vendors";
                    ErrorText: Text;
                    ValidCount: Integer;
                begin
                    TempVendor.Copy(Rec);
                    TempVendor.Reset();
                    ValidCount := 0;

                    if TempVendor.FindSet() then
                        repeat
                            if (TempVendor."User ID" <> '') and (TempVendor.LocationId <> '') then
                                ValidCount += 1
                            else if (TempVendor."User ID" <> '') or (TempVendor.LocationId <> '') then
                                ErrorText += 'Record ID ' + Format(TempVendor.RecId) + ': Missing required fields.\';
                        until TempVendor.Next() = 0;

                    if ErrorText <> '' then
                        Error('Validation errors found:\%1', ErrorText)
                    else
                        Message('%1 vendor records are valid.', ValidCount);
                end;
            }
            action(NewVendor)
            {
                ApplicationArea = All;
                Caption = 'New Vendor';
                Image = New;
                Promoted = true;
                PromotedCategory = New;
                ToolTip = 'Create a new POS vendor';

                trigger OnAction()
                var
                    NewVendor: Record "SBP Table POS Vendors";
                begin
                    Clear(NewVendor);
                    NewVendor.Init();
                    if NewVendor.Insert(true) then begin
                        Commit();
                        CurrPage.SetRecord(NewVendor);
                        CurrPage.Update(false);
                        Message('New vendor record created. Please fill in the required fields.');
                    end else
                        Error('Unable to create new vendor record.');
                end;
            }
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.IsEmpty() then
            CurrPage.Editable(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Initialize new record
        Rec.Init();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // Allow closing without strict validation
        exit(true);
    end;
}