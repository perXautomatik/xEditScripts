

// Searches for string within TStringList
function slContains(aList: TStringList; s: String): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	Result := False;
	{Debug} if debugMsg then msgList('[slContains] if ', aList, ' contains '+s);
	if (aList.IndexOf(s) <> -1) then
		Result := True;
	
	debugMsg := false;
// End debugMsg section
end;