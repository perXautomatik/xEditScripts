
// Fills a TStringList with 'true' flag values; Boolean controls if list gets just numbers or the whole element name
Procedure slGetFlagValues(e: IInterface; aList: TStringList; aBoolean: Boolean);
var
	tempString, BinaryList: String;
	startTime, stopTime: TDateTime;
	slTemp: TStringList;
	debugMsg: Boolean;
	i: Integer;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;

	// Function
	if (sig(e) = 'ARMO') then begin
		{Debug} if debugMsg then msgList('[slGetFlagValues] slGetFlagValues('+EditorID(e)+', ', aList, ', '+BoolToStr(aBoolean));
		slTemp.CommaText := FlagValues(ebp(ebs(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msgList('[slGetFlagValues] FlagValues := ', slTemp, '');
		BinaryList := GetEditValue(ebp(ebs(e, GetElementType(e)), 'First Person Flags'));
		{Debug} if debugMsg then msg('[slGetFlagValues] BinaryList := '+BinaryList);
		if aBoolean then begin
			for i := 1 to Length(BinaryList) do	begin
				if (Copy(BinaryList, i, 1) = '1') then begin
					if (i+2 <= slTemp.Count-1) then begin
						tempString := slTemp[3*(i-1)]+' '+slTemp[3*(i-1)+1]+' '+slTemp[3*(i-1)+2];
						if not slContains(aList, tempString) then
							aList.Add(tempString);
					end;
				end;
			end;
		end else begin
			for i := 1 to Length(BinaryList) do	begin
				if (Copy(BinaryList, i, 1) = '1') then begin
					if not slContains(aList, slTemp[3*(i-1)]) then begin
						{Debug} if debugMsg then msg('[slGetFlagValues] aList.Add('+slTemp[3*(i-1)]+' );');
						aList.Add(slTemp[3*(i-1)]);
					end;
				end;
			end;
		end;
	end else if (sig(e) = 'LVLI') then begin
		{Debug} if debugMsg then msgList('[slGetFlagValues] slGetFlagValues('+EditorID(e)+', ', aList, ', '+BoolToStr(aBoolean));
		sl1.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count", "Use All", "Special Loot"';
		{Debug} if debugMsg then msgList('[slGetFlagValues] FlagValues := ', slTemp, '');
	end else begin
		aList.Add(sig(e));
		slTemp.Free;
		Exit;
	end;

	// Finalize
	slTemp.Free;
	stopTime := Time;
	if ProcessTime then addProcessTime('slGetFlagValues', TimeBtwn(startTime, stopTime));
	debugMsg := false;
end;