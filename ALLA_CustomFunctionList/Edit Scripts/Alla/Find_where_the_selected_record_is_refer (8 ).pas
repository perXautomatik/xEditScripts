
// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of inputRecord with replaceRecord in the override
Procedure ReplaceInLeveledListByList(aList, bList: TStringList; aPlugin: IInterface);
var
  LLrecord, LLcopy, tempRecord, tempElement: IInterface;
	i, x, y, tempInteger, LoadOrder: Integer;
	debugMsg, tempBoolean, patchBool: Boolean;
	startTime, stopTime: TDateTime;
	slTemp, slLL: TStringList;
	LLrecord_EditorID, patchFileName: String;
begin
	// Initialize
	debugMsg := false;
	if ProcessTime then startTime := Time;
	{Debug} if debugMsg then msg('[ReplaceInLeveledListByList] ReplaceInLeveledListByList(aList, bList, '+GetFileName(aPlugin)+' );');
	slTemp := TStringList.Create;
	slLL := TStringList.Create;
	
	// For the 'Patch' function
	patchBool := slContains(slGlobal, 'Patch');
	if patchBool then patchFileName := GetFileName(ote(GetObject('Patch', slGlobal)));
	
	//main work 1
	LoadOrder := GetLoadOrder(aPlugin);
	for i := aList.Count - 1 downto 0 do begin
		tempRecord := ote(aList.Objects[i]);
		for x := rbc(tempRecord) - 1 downto 0 do begin
			LLrecord := rbi(tempRecord, x);
			LLrecord_EditorID := EditorID(LLrecord); 
			if not (sig(LLrecord) = 'LVLI') then continue;
			//single mode
			if (GetFileName(GetFile(LLrecord)) <> patchFileName) then Continue;
			
			// Filter Invalid Entries
			{Debug} if debugMsg then msg('[ReplaceInLeveledListByList] LLrecord := '+LLrecord_EditorID);
			if slContains(slLL, LLrecord_EditorID) then Continue;
			if ContainsText(LLrecord_EditorID, '++') or not (Length(LLrecord_EditorID) > 0) or not IsHighestOverride(LLrecord, GetLoadOrder(aPlugin)) or FlagCheck(LLrecord, 'Special Loot') then Continue;
			
			if slContains(slGlobal, LLrecord_EditorID) then
				if not (EditorID(tempRecord) = EditorID(ote(slGlobal.Objects[slGlobal.IndexOf(LLrecord_EditorID)]))) then
					Continue;
			
			if (LoadOrder <= GetLoadOrder(GetFile(LLrecord))) then begin
				if PreviousOverrideExists(LLrecord, LoadOrder) then begin
					LLrecord := GetPreviousOverride(LLrecord, LoadOrder);
				end else
					Continue;
			end else if debugMsg then msg('[ReplaceInLeveledListByList] '+LLrecord_EditorID+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(LLrecord))));
			// Add Copy to List
			slLL.AddObject(LLrecord_EditorID, LLrecord);
			
		end;
	end;
	
	{Debug} if debugMsg then msgList('[ReplaceInLeveledListByList] slLL := ', slLL, ' );');
	{Debug} if debugMsg then msg(' ');
	//work 2
	for i := slLL.count - 1 downto 0 do begin
		LLrecord := ote(slLL.Objects[i]);
		LLrecord_EditorID:= slLL[i];
		
		{Debug} if debugMsg then msg('[ReplaceInLeveledListByList] LLrecord := '+LLrecord_EditorID);
		if not (Length(LLrecord_EditorID) > 0) then Continue
		tempElement := ebn(LLrecord, 'Leveled List Entries');
		
		for x := LLec(LLrecord) - 1 downto 0 do begin
			tempRecord := ebi(tempElement, x);
			slTemp.AddObject(StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True), genv(tempRecord, 'LVLO\Level'));
		end;
		
		{Debug} if debugMsg then msgList('[ReplaceInLeveledListByList] slTemp := ', slTemp, ' );');
		for x := 0 to bList.Count-1 do begin
			if slContains(slTemp, bList[x]) then begin
				tempRecord := ote(bList.Objects[x]);
				if not slContains(slTemp, EditorID(tempRecord)) then begin
					// Detect Pre-Existing List or Create Override
					if not (LoadOrder = GetLoadOrder(GetFile(LLrecord))) then
						LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True)
					else
						LLcopy := LLrecord;
					// Replace
					LLreplace(LLcopy, ote(aList.Objects[x]), tempRecord);
				end;
			end;
		end;
		slTemp.Clear;
	end;
	
	// Finalize
	if ProcessTime then begin
		stopTime := Time;
		addProcessTime('ReplaceInLeveledListByList', TimeBtwn(startTime, stopTime));
	end;
	
	slTemp.Free;
	slLL.Free;
end;