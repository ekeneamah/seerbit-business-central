/// <summary>
/// Table VirtualAccountTable (ID 50132).
/// </summary>
table 71855611
 SBPVirtualAccountTable
{
    DataCaptionFields = ID, fullName;
    DrillDownPageId = SBPPaymentLinkSetupList;
    LookupPageId = SBPVirtualAccountPage;
    DataClassification = CustomerContent;
    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            AutoIncrement = true;
            NotBlank = true;
        }

        field(2; publicKey; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Public Key';
        }

        field(3; fullName; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Full Name';
            NotBlank = true;
        }

        field(4; bankVerificationNumber; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bank Verification Number';
            Numeric = true;
            NotBlank = true;


        }

        field(5; currency; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency';
            InitValue = 'NGN';
            // OptionMembers = USD,EUR,GBP,JPY,CAD,AUD,CHF,CNY,SEK,NZD,MXN,SGD,HKD,NOK,KRW,TRY,RUB,INR,BRL,ZAR;
        }

        field(6; country; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country';
            InitValue = 'NG';
        }

        field(7; reference; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference';
            NotBlank = true;
        }

        field(8; email; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Email';
            NotBlank = true;
        }
        field(9; accountNumber; Code[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Account Number';
        }
        field(10; walletName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Name';
        }
        field(11; bankName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bank Name';
        }
        field(12; status; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(13; Code; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(14; linkingReference; Code[120])
        {
            DataClassification = CustomerContent;
            Caption = 'Linking Reference';
        }
        field(101; PaymentReference; Text[100])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(102; "GL Account Name"; Text[120])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(33; "General Journal"; Text[250])
        {
            DataClassification = CustomerContent;
            InitValue = 'SEERBIT';
            ObsoleteState = Pending;
            ObsoleteReason = 'This field is no longer used and will be removed in a future version.';
        }
        field(25; "Total Payments"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; wallet; Code[50])
        {
            DataClassification = CustomerContent;
        }
        field(36; "Bal. Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bal. Account No.';
            TableRelation = "G/L Account" where("Account Type" = const(Posting));
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(uk; reference)
        {
            Unique = false;
        }
    }
}
