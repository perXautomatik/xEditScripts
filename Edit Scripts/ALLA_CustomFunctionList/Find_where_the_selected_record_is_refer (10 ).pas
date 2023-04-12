
// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of templateRecord with inputRecord in the override
Procedure AddToLeveledListByList(aList: TStringList; aPlugin: IInterface);
var
  LLrecord, LLcopy, masterRecord, tempRecord, tempElement: IInterface;
	startTime, stopTime, tempStart, tempStop: TDateTime;
	i, x, y, tempInteger, LoadOrder: Integer;
  debugMsg, tempBoolean, Patch: Boolean;
	slLL, slTemp, slTempList: TStringList;
	tempString: String;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;
	slTempList := TStringList.Create;
	slTemp := TStringList.Create;
	slTemp.Sorted := True;
	slTemp.Duplicates := dupIgnore;
	slLL := TStringList.Create;

	{Debug} if debugMsg then begin
		msg('[AddToLeveledListByList] AddToLeveledListByList(aList, '+GetFileName(aPlugin)+' );');
		msg(' ');
		msgList('[AddToLeveledListByList] slGlobal := ', slGlobal, '');
		msg(' ');
		msgList('[AddToLeveledListByList] aList := ', aList, '');
		msg(' ');
		for i := 0 to slGlobal.Count-1 do if ContainsText(slGlobal[i], '-//-') then msg('[AddToLeveledListByList] '+slGlobal[i]+' := '+EditorID(ote(slGlobal.Objects[i])));
		for i := 0 to slGlobal.Count-1 do if ContainsText(slGlobal[i], '-/Level/-') then msg('[AddToLeveledListByList] '+slGlobal[i]+' := '+IntToStr(Integer(slGlobal.Objects[i])));
	end;
	Patch := slContains(slGlobal, 'Patch');
	LoadOrder := GetLoadOrder(aPlugin);
	// Add Masters
	{Debug} if debugMsg then msg('[AddToLeveledListByList] Adding Masters');

	// Collect leveled lists
	msg('Beginning Leveled List Collection');
	// Custom Leveled List Input
	for i := 0 to slGlobal.Count-1 do
		if ContainsText(slGlobal[i], '-/LeveledList/-') then
			slLL.AddObject(StrPosCopy(slGlobal[i], '-/LeveledList/-', True), slGlobal.Objects[i]);
	// Leveled list from template
	for i := 0 to aList.Count-1 do begin
		masterRecord := ote(aList.Objects[i]);
		tempString := EditorID(masterRecord);
		// If two records have the same template this prevents it from getting processed twice
		{Debug} if debugMsg then msg('[AddToLeveledListByList] If two records have the same template this prevents it from getting processed twice');
		if slContains(slTemp, tempString) then
			Continue
		else
			slTemp.Add(tempString);
		{Debug} if debugMsg then msgList('[AddToLeveledListByList] ', slTemp, '');
		msg('['+IntToStr(i+1)+'/'+IntToStr(aList.Count)+'] Collecting '+tempString+' Leveled Lists');
		{Debug} if debugMsg then msg('[AddToLeveledListByList] for x := 0 to '+IntToStr(Pred(rbc(masterRecord)))+' do begin');
		for x := 0 to Pred(rbc(masterRecord)) do begin
			LLrecord := rbi(masterRecord, x);
			tempString := EditorID(LLrecord);
			{Debug} if debugMsg then msg('[AddToLeveledListByList] EditorID(LLrecord) := '+tempString);
			// Filter Invalid Entries
			{Debug} if debugMsg then msg('[AddToLeveledListByList] Filter Invalid Entries');
			if slContains(slLL, tempString) then Continue;
			if ContainsText(tempString, '++')
				or (Length(tempString) <= 0)
				or not IsHighestOverride(LLrecord, LoadOrder)
				or not (sig(LLrecord) = 'LVLI')
				or FlagCheck(LLrecord, 'Use All')
				or FlagCheck(LLrecord, 'Special Loot') then
					Continue;
			if not (LoadOrder >= GetLoadOrder(GetFile(LLrecord))) then begin
				if PreviousOverrideExists(LLrecord, LoadOrder) then begin
					LLrecord := GetPreviousOverride(LLrecord, LoadOrder);
				end else
					Continue;
			end else if debugMsg then msg('[AddToLeveledListByList] '+EditorID(LLrecord)+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(LLrecord))));			
			// Restricts the valid leveled lists to a single file (for 'Patch' function)
			{Debug} if debugMsg then msg('[AddToLeveledListByList] Restricts the valid leveled lists to a single file (for Patch function)');
			if Patch then begin
				tempString := GetFileName(ote(GetObject('Patch', slGlobal)));
				tempBoolean := False;
				// {Debug} if debugMsg then msg('[AddToLeveledListByList] for x := 0 to '+IntToStr(Pred(OverrideCount(LLrecord)))+' do begin');
				if (OverrideCount(LLrecord) > 0) then begin
					for y := 0 to Pred(OverrideCount(LLrecord)) do begin
						{Debug} if debugMsg then msg('[AddToLeveledListByList] if (GetFileName(GetFile(OverrideByIndex('+EditorID(LLrecord)+', '+IntToStr(x)+'))) = '+tempString+') then begin');
						if (GetFileName(GetFile(OverrideByIndex(LLrecord, y))) = tempString) then begin
							tempBoolean := True;
							Break;
						end;
					end;
				end else
					if (GetFileName(GetFile(LLrecord)) = tempString) then
						tempBoolean := True;
				if not tempBoolean then Continue;
			end;
			// Add Copy to List
			slLL.AddObject(EditorID(LLrecord), LLrecord);
		end;
	end;
	{Debug} if debugMsg then msgList('[AddToLeveledListByList] slLL := ', slLL, ' );');
	// Add Masters
	tempStart := Time;

	tempStop := Time;
	// addProcessTime('Add Masters', TimeBtwn(tempStart, tempStop));
	// Process Leveled Lists
	msg('Processing Leveled Lists');
	for i := 0 to slLL.Count-1 do begin
		slTempList.Clear;
		slTemp.Clear;
		LLrecord := ote(slLL.Objects[i]);
		{Debug} if debugMsg then msg('[AddToLeveledListByList] LLrecord := '+EditorID(LLrecord));
		if (Length(EditorID(LLrecord)) <= 0) then Continue
		tempElement := ebn(LLrecord, 'Leveled List Entries');
		for x := 0 to Pred(LLec(LLrecord)) do begin
			tempRecord := ebi(tempElement, x);
			slTemp.AddObject(StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True), StrToInt(geev(tempRecord, 'LVLO\Level'))); {Debug} if debugMsg then msg('[AddToLeveledListByList] slTemp.AddObject('+StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True)+', '+IntToStr(StrToInt(geev(tempRecord, 'LVLO\Level')))+' )');
		end; {Debug} if debugMsg then msgList('[AddToLeveledListByList] slTemp := ', slTemp, '');
		for x := 0 to aList.Count-1 do begin
			tempRecord := ote(GetObject(aList[x], slGlobal));
			{Debug} if debugMsg then msg('[AddToLeveledListByList] tempRecord := '+EditorID(tempRecord));
			tempInteger := -1;
			// Custom input from 'Add To Leveled List' menu	
			tempString := EditorID(LLrecord)+'-/Level/-'+EditorID(tempRecord);
			if slContains(slGlobal, tempString) then begin
				tempInteger := Integer(GetObject(tempString, slGlobal)); {Debug} if debugMsg then msg('[AddToLeveledListByList] Custom Level for '+EditorID(tempRecord)+' in '+EditorID(LLrecord)+' := '+IntToStr(tempInteger));
				slGlobal.Delete(slGlobal.IndexOf(tempString));
				slGlobal.Delete(slGlobal.IndexOf(EditorID(LLrecord)+'-/LeveledList/-'+EditorID(tempRecord)));			
				if (tempInteger <= 0) then
					Continue;
			end;
			// Level from template
			if (tempInteger = -1) then begin
				tempString := EditorID(ote(aList.Objects[x]));
				if slContains(slTemp, tempString) then
					tempInteger := Integer(GetObject(tempString, slTemp));
			end;
			{Debug} if debugMsg then msg('[AddToLeveledListByList] Level from '+EditorID(LLrecord)+' := '+IntToStr(tempInteger));
			if (tempInteger = -1) then Continue;
			if (tempInteger = 0) then
				tempInteger := 1;
			// Detect Pre-Existing List or Create Override
			case GetLoadOrder(GetFile(LLrecord)) of
				LoadOrder: LLcopy := LLrecord;
				else LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
			end;
			{Debug} if debugMsg then msg('[AddToLeveledListByList] LLcopy := '+EditorID(LLcopy));
			if not slContains(slTemp, EditorID(tempRecord)) then begin
				addToLeveledList(LLcopy, tempRecord, tempInteger); {Debug} if debugMsg then msg('[AddToLeveledListByList] addToLeveledList('+EditorID(LLcopy)+', '+EditorID(tempRecord)+', '+IntToStr(tempInteger)+' )');
				slTempList.Add(EditorID(tempRecord));
			end;
		end;
		if (slTempList.Count > 0) then
			msgList('['+IntToStr(i+1)+'/'+IntToStr(slLL.Count)+'] '+EditorID(LLrecord)+' added: ', slTempList, '');
  end;

	// Finalize
	stopTime := Time;
	if ProcessTime then addProcessTime('AddToLeveledListByList', TimeBtwn(startTime, stopTime));
	slTempList.Free;
	slTemp.Free;
	slLL.Free;
end;