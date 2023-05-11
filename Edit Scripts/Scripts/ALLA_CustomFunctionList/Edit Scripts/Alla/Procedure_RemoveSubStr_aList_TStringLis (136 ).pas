
Procedure RemoveSubStr(aList: TStringList; aString: String);
var
	debugMsg: Boolean;
	Count: Integer;
begin
	debugMsg := false;
	{Debug} if debugMsg then msgList('[RemoveSubStr] RemoveSubStr(', aList, ', '+aString+' );');
	Count := 0;
	while (aList.Count > Count) do begin
		while ContainsText(aList[Count], aString) do begin
			aList[Count] := Trim(Trim(StrPosCopy(aList[Count], aString, True))+' '+Trim(StrPosCopy(aList[Count], aString, False)));
			{Debug} if debugMsg then msg('[RemoveSubStr] aList[Count] := '+aList[Count]);
		end;
		Inc(Count);
	end;
end;