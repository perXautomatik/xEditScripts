

// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of inputRecord with replaceRecord in the override
Procedure ReplaceInLeveledListAuto(inputRecord, replaceRecord, aPlugin: IInterface);
var
	LLrecord, LLcopy, masterRecord: IInterface;
	debugMsg, patchBool: Boolean;
	startTime, stopTime: TDateTime;
	tempString, patchFileName, LLrecord_EditorID, LLrecord_Sig: String;
	i, x: Integer;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;
	{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] ReplaceInLeveledListAuto('+EditorID(inputRecord)+' with '+EditorID(replaceRecord)+' in '+GetFileName(aPlugin)+' );');
	
	patchBool := slContains(slGlobal, 'Patch');
	if patchBool then patchFileName := GetFileName(ote(GetObject('Patch', slGlobal)));
	masterRecord := MasterOrSelf(inputRecord);
	for i := rbc(masterRecord) - 1 downto 0 do begin
		LLRecord := rbi(masterRecord, i);
		LLrecord_EditorID := EditorID(LLrecord);
		//records to skip
		if patchBool then if (GetFileName(GetFile(LLrecord)) <> patchFileName) then Continue;
		if not SameText(Signature(LLrecord), 'LVLI') then continue;
		if (GetFileName(GetFile(LLrecord)) <> patchFileName) then Continue;
		if ContainsText(LLrecord_EditorID, '++') or not IsHighestOverride(LLrecord, GetLoadOrder(aPlugin))
		or (GetLoadOrder(GetFile(LLrecord)) > GetLoadOrder(aPlugin)) or (Length(LLrecord_EditorID) = 0) or FlagCheck(LLrecord, 'Special Loot') then Continue;
		
		if slContains(slGlobal, LLrecord_EditorID) then
			if (EditorID(masterRecord) = EditorID(ote(slGlobal.Objects[slGlobal.IndexOf(LLrecord_EditorID)]))) then
				Continue;
		if LLcontains(LLrecord, masterRecord) then begin
			LLcopy := ebEDID(gbs(aPlugin, 'LVLI'), LLrecord_EditorID);
			if not Assigned(LLcopy) then
				LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
			{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] LLcopy := '+EditorID(LLcopy));
			if Assigned(LLcopy) then begin
				{Debug} if debugMsg then msg('[ReplaceInLeveledListAuto] LLreplace('+EditorID(LLcopy)+', '+EditorID(masterRecord)+', '+EditorID(replaceRecord)+' );');
				LLreplace(LLcopy, masterRecord, replaceRecord);
			end;
		end;
		
	end;
	
	// Finalize
	stopTime := Time;
	if ProcessTime then addProcessTime('ReplaceInLeveledListAuto', TimeBtwn(startTime, stopTime));
end;