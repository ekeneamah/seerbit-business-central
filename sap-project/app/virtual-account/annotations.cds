using SeerBitService as service from '../../srv/seerbit-service';

annotate service.VirtualAccounts with @(
  UI.HeaderInfo: {
    TypeName: 'Virtual Account',
    TypeNamePlural: 'Virtual Accounts',
    Title: { Value: FullName },
    Description: { Value: AccountNumber }
  },
  UI.SelectionFields: [Status, FullName, Email, AccountNumber, Reference],
  UI.LineItem: [
    { Value: FullName, Label: 'Full Name' },
    { Value: Email, Label: 'Email' },
    { Value: AccountNumber, Label: 'Account Number' },
    { Value: Reference, Label: 'Reference' },
    { Value: Status, Label: 'Status' },
    { Value: TotalPayments, Label: 'Total Payments' },
    { Value: LastSyncStatus, Label: 'Last Sync Status' },
    { Value: LastRetrievedAt, Label: 'Last Retrieved' }
  ],
  UI.Facets: [
    {
      $Type: 'UI.ReferenceFacet',
      Label: 'General',
      Target: '@UI.FieldGroup#General'
    },
    {
      $Type: 'UI.ReferenceFacet',
      Label: 'Posting Setup',
      Target: '@UI.FieldGroup#Posting'
    }
  ],
  UI.FieldGroup #General: {
    Data: [
      { Value: FullName, Label: 'Full Name' },
      { Value: Email, Label: 'Email' },
      { Value: BankVerificationNo, Label: 'BVN' },
      { Value: Currency, Label: 'Currency' },
      { Value: Country, Label: 'Country' },
      { Value: Reference, Label: 'Reference' },
      { Value: AccountNumber, Label: 'Account Number' },
      { Value: BankName, Label: 'Bank Name' },
      { Value: WalletName, Label: 'Wallet Name' },
      { Value: Status, Label: 'Status' }
    ]
  },
  UI.FieldGroup #Posting: {
    Data: [
      { Value: PaymentAccountType, Label: 'Account Type' },
      { Value: PaymentAccountNo, Label: 'Account No.' },
      { Value: BalancingAccountType, Label: 'Balancing Type' },
      { Value: BalancingAccountNo, Label: 'Balancing Account' }
    ]
  }
);

annotate service.VirtualAccountPayments with @(
  UI.HeaderInfo: {
    TypeName: 'Virtual Account Payment',
    TypeNamePlural: 'Virtual Account Payments',
    Title: { Value: PaymentReference },
    Description: { Value: PaymentStatus }
  },
  UI.SelectionFields: [PaymentStatus, PaymentReference, PostedToS4, AccountNumber],
  UI.LineItem: [
    { Value: PaymentReference, Label: 'Payment Reference' },
    { Value: FullName, Label: 'Customer Name' },
    { Value: Amount, Label: 'Amount' },
    { Value: Currency, Label: 'Currency' },
    { Value: PaymentStatus, Label: 'Status' },
    { Value: PaymentDate, Label: 'Payment Date' },
    { Value: PostedToS4, Label: 'Posted To S/4' },
    { Value: S4PostingDocumentNo, Label: 'S/4 Document' }
  ]
);
