/// <summary>
/// Codeunit SBPSeerBitGlobalCodeunit (ID 50136).
/// </summary>
codeunit 71855601
 SBPSeerBitGlobalCodeunit
{
    /// <summary>
    /// MyProcedure.
    /// </summary>
    /// <param name="fieldRef">VAR FieldRef.</param>
    /// <param name="fieldRefSecKey">VAR FieldRef.</param>
    /// <param name="fieldRefOrgname">VAR FieldRef.</param>
    procedure MyProcedure(var fieldRef: FieldRef; var fieldRefSecKey: FieldRef; var fieldRefOrgname: FieldRef)
    var
        recordRef: RecordRef;
        MyFieldRef: FieldRef;
    begin
        recordRef.open(79);
        MyFieldRef := recordRef.Field(50101);
        MyFieldRef.VALUE := 0;
        if recordRef.Find('=') then begin
            fieldRef := recordRef.Field(50103);
            fieldRefSecKey := recordRef.Field(50104);
            fieldRefOrgname := recordRef.Field(50102);


        end;
    end;
}

