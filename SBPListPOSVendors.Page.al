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
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Administration;
                    TableRelation = User."Application ID";
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record User;
                    begin
                        ItemRec.Reset();
                        if Page.RunModal(Page::"Users", ItemRec) = Action::LookupOK then begin
                            Rec."User ID" := ItemRec."Authentication Email";
                            Rec."Full Name" := ItemRec."Full Name";
                            Rec.Email := ItemRec."Contact Email";
                        end;
                    end;


                }
                field("Email"; Rec.Email)
                {
                    ApplicationArea = Administration;
                    Caption = 'Contact Email';


                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = Administration;


                }


                field(Location; Rec.LocationId)
                {
                    ApplicationArea = Administration;
                    TableRelation = "SBP Pos location table".LocationId;
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record "SBP Pos location table";
                    begin
                        ItemRec.Reset();
                        if Page.RunModal(Page::"SBP List POS Locations", ItemRec) = Action::LookupOK then begin
                            Rec.LocationId := ItemRec.LocationId;
                            Rec.LocationName := ItemRec.Description;
                            // Rec.L := ItemRec.LocationId
                        end;
                    end;


                }

                field("Location Name"; Rec.LocationName)
                {
                    ApplicationArea = Administration;


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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}