

// Set Flag Values based on input string list
Procedure slSetFlagValues(e: IInterface; aList: TStringList; aPlugin: IInterface);
var
	tempString, BinaryList: String;
	slTemp, sl1: TStringList;
	tempRecord: IInterface;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	// Initialize
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	if not Assigned(sl1) then sl1 := TStringList.Create else sl1.Clear;

	// Function
	{Debug} if debugMsg then msgList('[slSetFlagValues] slSetFlagValues('+EditorID(e)+', ', aList, ' )');
	if (sig(e) = 'ARMO') then begin
		slTemp.CommaText := FlagValues(ebp(ebs(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msgList('[slSetFlagValues] FlagValues := ', slTemp, '');
		BinaryList := GetEditValue(ebp(ebs(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msg('[slSetFlagValues] BinaryList := '+BinaryList);
		for i := 0 to slTemp.Count-1 do	begin
			// {Debug} if debugMsg then msg('[slSetFlagValues] if ('+IntToStr(i+2)+' <= '+IntToStr(slTemp.Count-1)+' ) then begin');
			if (3*(i)+2 <= slTemp.Count-1) then begin
				tempString := slTemp[3*(i)]+' '+slTemp[3*(i)+1]+' '+slTemp[3*(i)+2];
				if not slContains(sl1, tempString) then
					sl1.Add(tempString);
				i := i+3;
			end;
		end;
		{Debug} if debugMsg then msgList('[slSetFlagValues] sl1 := ', sl1, '');
		slTemp.Clear;
		tempString := nil;
		for i := 0 to sl1.Count-1 do begin
			if slContains(aList, sl1[i]) then begin
				tempString := tempString + '1';
			end else begin
				tempString := tempString + '0';
			end;
		end;
		{Debug} if debugMsg then msg('[slSetFlagValues] New BinaryList := '+tempString);
		if ContainsText(tempString, '1') then
			SetEditValue(ebp(ebs(e, GetElementType(e)), 'First Person Flags'), Copy(tempString, 0, rPos(tempString, '1')));
	end else if (sig(e) = 'LVLI') then begin
		// Make a copy of the list
		tempRecord := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(e));
		if not Assigned(tempRecord) then begin
		
			tempRecord := CopyRecordToFile(e, aPlugin, False, True);
		end;
	
		// Assemble and assign new binary list
		sl1.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count", "Use All", "Special Loot"';
		{Debug} if debugMsg then msgList('[slGetFlagValues] FlagValues := ', sl1, '');
		{Debug} if debugMsg then msgList('[slSetFlagValues] sl1 := ', sl1, '');
		slTemp.Clear;
		tempString := nil;
		for i := 0 to sl1.Count-1 do begin
			if slContains(aList, sl1[i]) then begin
				tempString := tempString + '1';
			end else begin
				tempString := tempString + '0';
			end;
		end;
		{Debug} if debugMsg then msg('[slSetFlagValues] New BinaryList := '+Copy(tempString, 0, rPos(tempString, '1')));
		if ContainsText(tempString, '1') then
			SetEditValue(ebs(tempRecord, 'LVLF'), Copy(tempString, 0, rPos(tempString, '1')));
	end else begin
		aList.Add(sig(e));
		slTemp.Free;
		Exit;
	end;

	
	// Finalize
	slTemp.Free;
	sl1.Free;

	debugMsg := false;
// End debugMsg section
end;