
// Gets an object associated with a string
Function GetObject(s: String; aList: TStringList): TObject;
var
	tempString: String;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[GetObject] GetObject('+s+', aList );');
	{Debug} if debugMsg then msgList('[GetObject] aList := ', aList, '');
	if slContains(slGlobal, s) then
		Result := aList.Objects[aList.IndexOf(s)];

	debugMsg := false;
// End debugMsg section
end;