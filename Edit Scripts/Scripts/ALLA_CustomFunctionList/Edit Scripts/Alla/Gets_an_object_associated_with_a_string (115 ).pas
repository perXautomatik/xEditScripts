

// Gets an object associated with a string
Function StringObject(s: String; aList: TStringList): String;
var
	tempString: String;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[GetObject] GetObject('+s+', aList );');
	{Debug} if debugMsg then msgList('[GetObject] aList := ', aList, '');
	for i := 0 to aList.Count-1 do begin
		if ContainsText(aList[i], s) then begin
			Result := StrPosCopy(aList[i], '=', False);
			{Debug} if debugMsg then msg('[GetObject] Result := '+Result);
			Exit;
		end;
	end;	

	debugMsg := false;
// End debugMsg section
end;