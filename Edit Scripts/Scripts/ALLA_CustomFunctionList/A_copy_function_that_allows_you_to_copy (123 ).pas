
//  A copy function that allows you to copy from one position to another [mte functions]
function StrPosCopyBtwn(inputString, aString, bString: String): String;
var
	i, p1, p2: Integer;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := false;

  Result := '';
	Result := StrPosCopy(StrPosCopy(inputString, aString, False), bString, True);
	{Debug} if debugMsg then msg('[StrPosCopyBtwn] Result := '+Result);

	debugMsg := false;
// End debugMsg section
end;