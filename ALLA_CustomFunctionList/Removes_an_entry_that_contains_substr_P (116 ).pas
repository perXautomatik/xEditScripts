
// Removes an entry that contains substr
Procedure SetObject(s: String; aObject: Variant; aList: TStringList);
var
	i, tempInteger: Integer;
	debugMsg: Boolean;
begin
// Begin debugMsg Section
	debugMsg := false;

	{Debug} if debugMsg then msg('[SetObject] SetObject('+s+', aObject, aList );');
	{Debug} if debugMsg then msg('[SetObject] aObject := '+varTypeAsText(aObject));
	{Debug} if debugMsg then msgList('[SetObject] aList := ', aList, '');
	tempInteger := aList.IndexOf(s);
	if (tempInteger < 0) then begin
		for i := 0 to aList.Count-1 do begin
			if (aList[i] = s) then begin
				tempInteger := i;
				Break;
			end;
		end;
	end;
	if (tempInteger > -1) then begin
		aList.Objects[tempInteger] := aObject;
	end else begin
		aList.AddObject(s, aObject);
	end;

	debugMsg := false;
// End debugMsg section
end;