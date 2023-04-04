

// Adds item reference to the leveled list [SkyrimUtils]
function addToLeveledList(aLeveledList, aRecord: IInterface; aLevel: integer): IInterface;
var
	tempRecord, currentList: IInterface;
	i, tempInteger: Integer;
	tempString, previousRecord: String;
	debugMsg, tempBoolean: Boolean;
	slTemp: TStringList;
begin
// Begin debugMgs section
	debugMsg := false;
	{Debug} if debugMsg then msg('[addToLeveledList] addToLeveledList('+EditorID(currentList)+', '+EditorID(aRecord)+', '+IntToStr(aLevel)+' );');
	slTemp := TStringList.Create;
	slTemp.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count"';
	currentList := aLeveledList;
	// Check for leveled lists exceeding maximum entries
	while (LLec(currentList) >= 250) do begin
		if StrEndsWithInteger(previousRecord) then begin
			// Add one to the integer and then check if that leveled list exists; Avoids duplicate lists
			if StrEndsWith(EditorID(currentList), '9') then begin
				tempString := Copy(EditorID(currentList), Length(EditorID(currentList))-2, Length(EditorID(currentList)))+
				IntToStr((StrToInt(Copy(EditorID(currentList), Length(EditorID(currentList))-2, Length(EditorID(currentList))))+1));
			end else
				tempString := RemoveFinalCharacter(EditorID(currentList))+IntToStr(StrToInt(RightStr(EditorID(currentList), 1))+1);
		end else
			tempString := EditorID(currentList)+'1';
		tempRecord := ebEDID(gbs(GetFile(currentList), 'LVLI'), tempString);
		if Assigned(tempRecord) then
			currentList := tempRecord;
		// If a sequential leveled list is found or there's an infinite loop create a new leveled list
		if (LLec(currentList) <= 250) or (previousRecord = EditorID(currentList)) then begin
			currentList := createLeveledList(GetFile(currentList), tempString, slTemp, 0);
			// Remove trailing integers
			while StrEndsWithInteger(tempString) do
				tempString := RemoveFinalCharacter(tempString);
			// Check for an existing group containing this leveled list
			tempString := tempString+'_Group';
			tempRecord := nil;
			tempRecord := ebEDID(gbs(GetFile(currentList), 'LVLI'), tempString);
			// Add to exisitng group or create new group and run a replacement
			if Assigned(tempRecord) then begin
				addToLeveledList(tempRecord, currentList, 1);
			end else begin
				tempRecord := createLeveledList(GetFile(currentList), tempString, slTemp, 0);
				addToLeveledList(tempRecord, currentList, 1);
				addToLeveledList(tempRecord, aLeveledList, 1);
				ReplaceInLeveledListAuto(aLeveledList, tempRecord, GetFile(aLeveledList));
			end;
			Break;
		end;
		previousRecord := EditorID(currentList); // Prevent infinite loop
	end;
	slTemp.Free;
	tempRecord := ElementAssign(ebp(currentList, 'Leveled List Entries'), HighInteger, nil, False);
	BeginUpdate(tempRecord);
	try
		seev(tempRecord, 'LVLO\Reference', Name(aRecord));
		seev(tempRecord, 'LVLO\Count', 1);
		seev(tempRecord, 'LVLO\Level', aLevel);
	finally
		EndUpdate(tempRecord);
	end;
	Result := tempRecord;

	debugMsg := false;
// End debugMsg section
end;