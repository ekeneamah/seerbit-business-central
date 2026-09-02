/// <summary>
/// Copies SeerBit payment details from a general journal line to the G/L entries
/// created when that journal line is posted.
/// </summary>
codeunit 71855614 "SBP G/L Entry Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitGLEntry', '', false, false)]
    local procedure CopySeerBitDetailsToGLEntry(var GLEntry: Record "G/L Entry"; GenJournalLine: Record "Gen. Journal Line"; Amount: Decimal; AddCurrAmount: Decimal; UseAddCurrAmount: Boolean; var CurrencyFactor: Decimal; var GLRegister: Record "G/L Register")
    begin
        if (GenJournalLine."SBPSeerBit - Tx. Refenece" = '') and
           (GenJournalLine."SBPSeerBit - Payment Date" = '')
        then
            exit;

        GLEntry."SBP SeerBit - Tx. Refenece" := GenJournalLine."SBPSeerBit - Tx. Refenece";
        GLEntry."SBP SeerBit - Payment Date" := GenJournalLine."SBPSeerBit - Payment Date";
    end;
}
