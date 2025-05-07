/// <summary>
/// Page SBP List POS Locations (ID 50124).
/// </summary>
page 71855586
 "SBP List POS Locations"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "SBP Pos location table";
    Editable = true;
    Permissions =
        tabledata "SBP Pos location table" = RIMD;

    layout
    {
        area(Content)
        {
            repeater("Pos locations")
            {
                field(Name; Rec.LocationId)
                {
                    ApplicationArea = All;

                }
                field(Description; Rec.Description)
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
            action(ActionName)
            {
                ApplicationArea = All;
                Image = Action;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}