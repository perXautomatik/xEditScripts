
// Adds a TStringList and its objects to an msg on a single line
Procedure msgListObject(s1: String; aList: TStringList; s2: String);
var
  debugMsg: Boolean;
  i: Integer;
  tempString: String;
begin
// Begin debugMsg section
	debugMsg := false;

	if not Assigned(aList) or (aList.Count = 0) then begin
		msg(s1+'EMPTY LIST'+s2);
		Exit;
	end;
	for i := 0 to aList.Count-1 do begin
		if (i = 0) then begin
			tempString := aList[0];
		end else begin
			tempString := tempString+', '+aList[i]+' ('+varTypeAsText(aList.Objects[i])+')';
		end;
	end;
	msg(s1+tempString+s2);

	debugMsg := false;
// End debugMsg section
end;