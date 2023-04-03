
// Finds if StringList contains substring
function SLWithinStr(s: String; aList: TStringList): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[SLWithinStr] s := '+s);
	Result := False;
	for i := 0 to aList.Count-1 do begin
		if ContainsText(s, aList[i]) then begin
			Result := True;
			Break;
		end;
	end;

	debugMsg := false;
// End debugMsg section
end;