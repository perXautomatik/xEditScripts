
function GetPreviousOverride(aRecord: IInterface; LoadOrder: Integer): IInterface;
var
	debugMsg, tempBoolean: Boolean;
	tempRecord: IInterface;
	i, y: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	Result := nil;
	if (OverrideCount(aRecord) > 0) then begin
		tempBoolean := False;
		for y := Pred(OverrideCount(aRecord)) downto 0 do begin
			tempRecord := OverrideByIndex(aRecord, y);
			if (LoadOrder >= GetLoadOrder(GetFile(tempRecord))) then begin
				{Debug} if debugMsg then msg('[PreviousOverrideExists] '+EditorID(tempRecord)+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(tempRecord))));
				Result := tempRecord;
				Exit;
			end;
		end;
	end;

	debugMsg := false;
// End debugMsg section
end;