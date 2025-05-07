/// <summary>
/// PageExtension Business Profile List (ID 50110) extends Record Company Information.
/// </summary>
pageextension 71855575 "SBP Business Profile List" extends "Company Information"
{


    layout
    {
        addbefore(Communication)
        {

            group("SBP SeerBit Payment")
            {
                field("SBP Business Name"; Rec."SBP Business Name")
                {
                    ApplicationArea = All;
                    Caption = 'Business Name';
                    Visible = false;
                }

                field("SBP Public Key"; Rec.SBPPublicKey)
                {
                    ApplicationArea = All;
                    Caption = 'Public Key';
                    Editable = true;
                }

                field("SBP Secret Key"; Rec.SBPSecKey)
                {
                    ApplicationArea = All;
                    Caption = 'Secret Key';
                    Editable = true;

                }
                field("SBP Default Currency"; Rec."SBP Default Currency")
                {
                    ApplicationArea = All;
                    Caption = 'Default Currency';
                    Editable = true;
                    trigger OnAssistEdit()
                    var
                        Currencyrec: Record Currency;
                    begin
                        Currencyrec.reset();

                        if Page.RunModal(page::Currencies, Currencyrec) = ACTION::LookupOK then begin
                            Rec."SBP Default Currency" := Currencyrec.Code;
                            // Rec."SBP Currency" :=ChangeExchangeRate.CurrencyCode2
                        end;

                    end;
                }

                field("SBP Prefix"; Rec.SBPPrefix)
                {
                    ApplicationArea = All;
                    Caption = 'Prefix';
                    Editable = true;
                }

                field("SBP  Business Email"; Rec."SBP Business Email")
                {
                    ApplicationArea = All;
                    Caption = 'Business Email';
                    Editable = true;
                }
            }


            // Add other fields as desired

        }

    }
}
