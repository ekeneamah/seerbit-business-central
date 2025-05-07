/// <summary>
/// Codeunit SBP Open SeerBit signup (ID 50134).
/// </summary>
codeunit 71855671 "SBP Open SeerBit User guide"
{
    trigger OnRun()
    var
        ZYHyperLink: Page "SBPSeerBit User Guide";
    begin
        ZYHyperLink.SetURL('https://www.seerbit.com/integration-directory?id=bcuserguide');
        //ZYHyperLink.SetURL(GetUrl(ClientType::Current, Rec.CurrentCompany, ObjectType::Page, Page::"Customer List"));
        ZYHyperLink.Run();
    end;

    var
        myInt: Integer;
}