/// <summary>
/// Codeunit SBP Open SeerBit signup (ID 50134).
/// </summary>
codeunit 71855578 "SBP Open SeerBit signup"
{
    trigger OnRun()
    var
        ZYHyperLink: Page "SBPSeerBit Signup";
    begin
        ZYHyperLink.SetURL('https://www.dashboard.seerbit.com/#/auth/register');
        //ZYHyperLink.SetURL(GetUrl(ClientType::Current, Rec.CurrentCompany, ObjectType::Page, Page::"Customer List"));
        ZYHyperLink.Run();
    end;

    var
        myInt: Integer;
}