
// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of templateRecord with inputRecord in the override
function AddToLeveledListAuto(templateRecord: IInterface; inputRecord: IInterface; aPlugin: IInterface): String;
var
  LLrecord, LLcopy, masterRecord, inputEntry, tempRecord, tempElement: IInterface;
  debugMsg, tempBoolean, AddToEnchanted, patchBool: Boolean;
	slRecords: TStringList;
  i, x, y, tempInteger: Integer;
	patchFileName: String;
begin
// Begin debugMsg Section
	debugMsg := false;

	// Initialize
	slRecords := TStringList.Create;

	{Debug} if debugMsg then msg('[AddToLeveledListAuto] AddToLeveledListAuto('+EditorID(templateRecord)+', '+EditorID(inputRecord)+', '+GetFileName(aPlugin)+' );');
	// Pull patch info if present
	patchBool := slContains(slGlobal, 'Patch');
	if patchBool then patchFileName := GetFileName(ote(GetObject('Patch', slGlobal)));
	masterRecord := WinningOverride(templateRecord);	{Debug} if debugMsg then msg('[AddToLeveledListAuto] masterRecord := '+full(masterRecord));
	// This pulls the item out of chanceLeveledList in order to keep the msg statements consistent
  {Debug} if debugMsg then msg('[AddToLeveledListAuto] if '+sig(inputRecord)+' = ''LVLI'' then begin');
  if (sig(inputRecord) = 'LVLI') then begin {Debug} if debugMsg then msg('[AddToLeveledListAuto] Pred(LLec(inputRecord)) := '+IntToStr(Pred(LLec(inputRecord))));
    for i := 0 to Pred(LLec(inputRecord)) do begin {Debug} if debugMsg then msg('[AddToLeveledListAuto] inputEntry := '+full(LLebi(inputRecord, i)));
			inputEntry := LLebi(inputRecord, i); {Debug} if debugMsg then msg('[AddToLeveledListAuto] if not (sig(inputEntry) := '+sig(inputEntry)+' = ''LVLI'') then Break; ');
			if not (sig(inputEntry) = 'LVLI') then Break;
		end;
  end else begin
		inputEntry := templateRecord;
		{Debug} if debugMsg then msg('[AddToLeveledListAuto] full(inputEntry) := '+full(inputEntry)+' EditorID(inputEntry := '+EditorID(inputEntry));
	end;
	// msg('['+full(inputEntry)+'] Processing '+IntToStr(rbc(masterRecord))+' '+EditorID(inputEntry)+' References (This May Take A While)');
	{Debug} if debugMsg then msg('[AddToLeveledListAuto] Pred(rbc(masterRecord)) := '+IntToStr(Pred(rbc(masterRecord))));
	// Begins analyzing records that reference masterRecord
	for i := 0 to Pred(rbc(masterRecord)) do begin
		LLrecord := rbi(masterRecord, i);
		// Filter Invalid Entries
		if patchBool then if (GetFileName(GetFile(LLrecord)) <> patchFileName) then Continue;
		if ContainsText(EditorID(LLrecord), '++') or not (Length(EditorID(LLrecord)) > 0) or not IsHighestOverride(LLrecord, GetLoadOrder(aPlugin)) or not (sig(LLrecord) = 'LVLI') or FlagCheck(LLrecord, 'Use All') or FlagCheck(LLrecord, 'Special Loot') then Continue;
		if slContains(slGlobal, EditorID(LLrecord)) then
			if (EditorID(inputRecord) = EditorID(ote(slGlobal.Objects[slGlobal.IndexOf(EditorID(LLrecord))]))) then
				Continue;
		slRecords.AddObject(EditorID(LLrecord), LLrecord);
	end;
	// Add Masters

	for i := 0 to slRecords.Count-1 do begin
		LLrecord := ote(slRecords.Objects[i]);
		// Detect Pre-Existing List
		{Debug} if debugMsg then msg('[AddToLeveledListAuto] LLcopy := ebEDID(gbs(aPlugin, ''LVLI''), '+EditorID(LLrecord)+' );');
		LLcopy := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(LLrecord));
		// Create override if not already present
		if not Assigned(LLcopy) then
			LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
		RemoveInvalidEntries(LLcopy);
		{Debug} if debugMsg then msg('[AddToLeveledListAuto] LLrecord := '+EditorID(rbi(masterRecord, i)));
		if not LLcontains(LLrecord, inputRecord) then begin
			tempElement := ebn(LLrecord, 'Leveled List Entries');
			for x := 0 to Pred(LLec(LLrecord)) do begin {Debug} if debugMsg then msg('[AddToLeveledListAuto] LLebi(LLrecord, x) := '+EditorID(LLebi(LLrecord, x)));
				{Debug} if debugMsg then msg('[AddToLeveledListAuto] if (GetLoadOrderFormID(masterRecord) := '+IntToStr(GetLoadOrderFormID(masterRecord))+') = (GetLoadOrderFormID(LLebi(LLrecord, x)) := '+IntToStr(GetLoadOrderFormID(LLebi(LLrecord, x)))+') then begin');
				tempRecord := ebi(tempElement, x);
				if geev(tempRecord, 'LVLO\Reference') = Name(masterRecord)) then begin									
					tempInteger := 0;
					tempInteger := genv(tempRecord, 'LVLO\Level');
					if not (tempInteger > 0) then begin
						addToLeveledList(LLcopy, inputRecord, 1);
					end else
						addToLeveledList(LLcopy, inputRecord, tempInteger);
					msg(EditorID(inputRecord)+' added to '+EditorID(LLrecord));
					Break;
				end;
			end;
		end;
  end;

	debugMsg := false;
// End debugMsg section
end;