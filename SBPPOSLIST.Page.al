/// <summary>
/// Page SBP POS LIST (ID 50127).
/// </summary>
page 71855585
 "SBP POS LIST"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = SBPPOSDetailTable;
    Permissions =
        tabledata SBPPOSDetailTable = RIMD,
        tabledata "SBP Pos location table" = R;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("POS Id"; Rec."POS id")
                {
                    ApplicationArea = All;

                }
                field("Location"; Rec.Location)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Visible = false;



                }
                field("Location ID"; Rec."Location ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemRec: Record "SBP Pos location table";
                    begin
                        ItemRec.Reset();
                        // ItemRec.SetFilter(LocationId,'Location');
                        if Page.RunModal(Page::"SBP List POS Locations", ItemRec) = Action::LookupOK then begin
                            Rec.Location := ItemRec.Description;
                            Rec."Location ID" := ItemRec.LocationId
                        end;
                    end;

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