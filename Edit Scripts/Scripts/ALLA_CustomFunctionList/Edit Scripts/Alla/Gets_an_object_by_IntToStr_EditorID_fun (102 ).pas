
// Gets an object by IntToStr EditorID
function IndexOfObjectEDID(s: String; aList: TStringList): Integer;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msgList('[IndexOfObjectEDID] IndexOfObjectEDID '''+s+''', (', aList, ');');
	Result := -1;
	for i := 0 to aList.Count-1 do begin
		if (EditorID(ote(aList.Objects[i])) = s) then begin
			Result := i;
			{Debug} if debugMsg then msg('[IndexOfObjectEDID] Result := '+IntToStr(Result));
		end;
	end;

	debugMsg := false;
// End debugMsg section
end;