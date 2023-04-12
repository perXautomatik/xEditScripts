

// Finds if StringList contains substring
function ContainsTextSL(aList, bList: TStringList): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[ContainsTextSL] s := '+s);
	Result := False;
	for i := 0 to aList.Count-1 do begin
		if StrWithinSL(aList[i], bList) then begin
			Result := True;
			Exit
		end;
	end;

	debugMsg := false;
// End debugMsg section
end;