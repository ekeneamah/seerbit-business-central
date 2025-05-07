/// <summary>
/// PageExtension MyExtension (ID 50132) extends Record Business Manager Role Center.
/// </summary>
pageextension 71855597
 SBPSalesProcessor extends "Sales Manager Role Center"
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
                action("SBP SeerBit - PaymentLink")
                {
                    RunObject = page SBPPaymentLinkSetupList;
                    ApplicationArea = All;
                    Caption = 'Payment Link';
                    ToolTip = 'View and Create payment link';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Duplicate';
                }
                action("SBP SeerBit - VirtualAccount")
                {
                    RunObject = page SBPVirtualAccountList;
                    ApplicationArea = All;
                    Caption = 'Virtual Account';
                }
                action("SBP SeerBit - POS")
                {
                    RunObject = page "Sales Order List";
                    ApplicationArea = All;
                    Caption = 'POS';
                }
                action("SBP SeerBit - Invoice")
                {
                    RunObject = page "Sales Invoice List";
                    ApplicationArea = All;
                    Caption = 'Send Invoice';
                }
                // Creates a sub-menu
                group("SBP Settings")
                {
                    Caption = 'Settings';
                    action("SBP Profile")
                    {
                        ApplicationArea = All;
                        RunObject = page "Company Information";
                        Caption = 'Company Profile';
                    }
                    action("SBP Register")
                    {
                        ApplicationArea = All;
                        RunObject = Codeunit "SBP Open SeerBit signup";
                        ToolTip = 'Click here to sign up on seerbit';
                        Caption = 'Sign up';
                    }
                    action("SBP Locations")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP List POS Locations";
                        ToolTip = 'View and create your POS locations';
                        Caption = 'POS Locations';
                    }
                    action("SBP POS Vendors")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP List POS Vendors";
                        Caption = 'POS Vendors';
                        ToolTip = 'View and create POS vendors';
                    }
                    action("SBP POS Terminals")
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