

function IsHighestOverride(aRecord: IInterface; aInteger: Integer): Boolean;
var
    debugMsg: Boolean;
begin
// Begin debugMsg section
    debugMsg := false;
   
    Result := False;
    result := IsWinningOverride(aRecord);
    {Debug} if debugMsg then msg('[IsHighestOverride] IsHighestOverride('+EditorID(aRecord)+', '+GetFileName(FileByLoadOrder(aInteger))+' )');
    {Debug} if debugMsg then msg('[IsHighestOverride] if GetLoadOrder('+GetFileName(GetFile(aRecord))+' ) := '+IntToStr(GetLoadOrder(GetFile(aRecord)))+' = '+IntToStr(GetLoadOrder(GetFile(HighestOverrideOrSelf(aRecord, aInteger))))+' := GetLoadOrder('+GetFileName(GetFile(HighestOverrideOrSelf(aRecord, aInteger)))+' ) then');
    if (GetLoadOrder(GetFile(aRecord)) = GetLoadOrder(GetFile(HighestOverrideOrSelf(aRecord, aInteger)))) then
        Result := True;
    {Debug}  if debugMsg then msg('[IsHighestOverride] Result := '+BoolToStr(Result));
   
    debugMsg := false;
// End debugMsg section
end;