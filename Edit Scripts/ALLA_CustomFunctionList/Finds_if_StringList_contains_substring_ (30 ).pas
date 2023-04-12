
// Finds if StringList contains substring
function StrWithinSL(s: String; aList: TStringList): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[StrWithinSL] s := '+s);
	Result := False;
	for i := 0 to aList.Count-1 do begin
		if ContainsText(aList[i], s) then begin
			Result := True;
			Break;
		end;
	end;

	debugMsg := false;
// End debugMsg section
end;