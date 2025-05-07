/// <summary>
/// PageExtension MyExtension (ID 50132) extends Record Business Manager Role Center.
/// </summary>
pageextension 71855596
 SBPMyExtension extends "Business Manager Role Center"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {


        addlast(Sections)
        {
            group("SBPSeerBit Payment")
            {
                Caption = 'SeerBit Payment';
                action("SBPSeerBit - Register")
                {
                    RunObject = Codeunit "SBP Open SeerBit signup";
                    ApplicationArea = All;
                    Caption = 'Sign up';
                    ToolTip = 'Sign up to seerbit payment';
                }
                action("SBPSeerBit - PaymentLink")
                {
                    RunObject = page SBPPaymentLinkSetupList;
                    ApplicationArea = All;
                    Caption = 'Payment Link';
                    ToolTip = 'View and Create payment link';
                }
                action("SBPSeerBit - VirtualAccount")
                {
                    RunObject = page SBPVirtualAccountList;
                    ApplicationArea = All;
                    Caption = 'Virtual Account';
                }
                action("SBPSeerBit - POS")
                {
                    RunObject = page "Sales Order List";
                    ApplicationArea = All;
                    Caption = 'POS';
                }
                action("SBPSeerBit - Invoice")
                {
                    RunObject = page "Sales Invoice List";
                    ApplicationArea = All;
                    Caption = 'Send Invoice';
                }
                // Creates a sub-menu
                group("SBPSettings")
                {
                    Caption = 'Settings';
                    action("SBPProfile")
                    {
                        ApplicationArea = All;
                        RunObject = page "Company Information";
                        Caption = 'Company Profile';
                    }
                    action("SBPRegister")
                    {
                        ApplicationArea = All;
                        RunObject = Codeunit "SBP Open SeerBit signup";
                        ToolTip = 'Click here to sign up on seerbit';
                        Caption = 'Sign up';
                    }
                    action("SBPLocations")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP List POS Locations";
                        ToolTip = 'View and create your POS locations';
                        Caption = 'POS Locations';
                    }
                    action("SBPPOS Vendors")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP List POS Vendors";
                        Caption = 'POS Vendors';
                        ToolTip = 'View and create POS vendors';
                    }
                    action("SBPPOS Terminals")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP POS LIST";
                        ToolTip = 'View and create POS terminals';
                        Caption = 'POS Terminals';
                    }
                    action("SBP Seerbit - User Guide")
                    {
                        RunObject = Codeunit "SBP Open SeerBit User guide";
                        ApplicationArea = All;
                        Caption = 'User Guide';
                        ToolTip = 'User guide on how to get started';
                    }
                }
            }
        }
    }



}