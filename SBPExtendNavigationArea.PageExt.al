/// <summary>
/// PageExtension ExtendNavigationArea (ID 50120) extends Record Order Processor Role Center.
/// </summary>
pageextension 71855582
 SBPExtendNavigationArea extends "Order Processor Role Center"
{


    actions
    {


        addlast(Sections)
        {
            group("SBP SeerBit Payment")
            {
                action("SBP SeerBit - PaymentLink")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Link';
                    RunObject = page SBPPaymentLinkSetupList;
                }
                action("SBP SeerBit - VirtualAccount")
                {
                    ApplicationArea = All;
                    Caption = 'Virtual Account';
                    RunObject = page SBPVirtualAccountList;
                }
                action("SBP SeerBit - POS")
                {
                    ApplicationArea = All;
                    Caption = 'POS';
                    RunObject = page "Sales Order List";
                }
                action("SBP SeerBit - Invoice")
                {
                    ApplicationArea = All;
                    Caption = 'Send Invoice';
                    RunObject = page "Sales Invoice List";
                }
                // Creates a sub-menu
                group("SBP Settings")
                {
                    Caption = 'Settings';
                    ToolTip = 'Settings';
                    action("SBP Profile")
                    {
                        ApplicationArea = All;
                        RunObject = page "Company Information";
                        Caption = 'Company Profile';
                        ToolTip = 'Company Profile';
                    }
                    action("SBP Register")
                    {
                        ApplicationArea = All;
                        RunObject = Codeunit "SBP Open SeerBit signup";
                        Caption = 'Register';
                        ToolTip = 'Register with SeerBit Payment';
                    }
                    action("SBP pos-Locations")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP List POS Locations";
                    }
                    action("SBPPOS Vendors")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP List POS Vendors";
                        Caption = 'POS Vendors';
                        ToolTip = 'View and create POS vendors';
                    }
                    action("SBP POS Vendors")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP List POS Vendors";
                        Caption = 'POS Vendors';
                        ToolTip = 'View and create POS vendors';
                        ObsoleteReason = 'Duplicate';
                        ObsoleteState = Pending;
                    }
                    action("SBP POS Terminals")
                    {
                        ApplicationArea = All;
                        RunObject = page "SBP POS LIST";
                        Caption = 'Pos Terminals';
                    }
                }
                action("SBP Register 2")
                {
                    ApplicationArea = All;
                    RunObject = Codeunit "SBP Open SeerBit signup";
                    Caption = 'Register';
                    ToolTip = 'Register with SeerBit Paymant';
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