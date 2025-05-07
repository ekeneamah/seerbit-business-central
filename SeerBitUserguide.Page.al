/// <summary>
/// Page SeerBit Signup (ID 50135).
/// </summary>
page 71855685
 "SBPSeerBit User Guide"
{
    Extensible = false;
    Caption = 'User Guide';
    Editable = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Control5)
            {
                ShowCaption = false;
            }
            usercontrol(WebPageViewer; "WebPageViewer")
            {
                ApplicationArea = All;

                trigger ControlAddInReady(callbackUrl: Text)
                begin
                    CurrPage.WebPageViewer.Navigate(URL);
                end;

                trigger Callback(data: Text)
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        URL: Text;

    /// <summary>
    /// SetURL.
    /// </summary>
    /// <param name="NavigateToURL">Text.</param>
    procedure SetURL(NavigateToURL: Text)
    begin
        URL := NavigateToURL;
    end;
}