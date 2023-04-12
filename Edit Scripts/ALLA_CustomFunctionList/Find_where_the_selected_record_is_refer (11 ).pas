
// Find where the selected record is referenced in leveled lists and make a 'Copy as Override' into a specified file.  Then replace all instances of templateRecord with inputRecord in the override
Procedure AddOutfitByList(aList: TStringList; aPlugin: IInterface);
var
  LLrecord, LLcopy, masterRecord, tempRecord, tempElement, currentElement, primarySlotItem: IInterface;
	startTime, stopTime, tempStart, tempStop: TDateTime;
	i, x, y, tempInteger, LoadOrder, tempCount, currentCount: Integer;
  debugMsg, tempBoolean, Patch: Boolean;
	slLL, slTemp, slTempList, slItem, slNames, slOutfits: TStringList;
	tempString, commonString, Slot: String;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;
	slTempList := TStringList.Create;
	slTemp := TStringList.Create;
	slTemp.Sorted := True;
	slTemp.Duplicates := dupIgnore;
	slOutfits := TStringList.Create;
	slNames := TStringList.Create;
	slItem := TStringList.Create;
	slLL := TStringList.Create;

	{Debug} if debugMsg then begin // Seperates the debug messages so they're a little easier to read
		msg('[AddOutfitByList] AddOutfitByList(aList, '+GetFileName(aPlugin)+' );');
		msg(' ');
		msgList('[AddOutfitByList] slGlobal := ', slGlobal, '');
		msg(' ');
		msgList('[AddOutfitByList] aList := ', aList, '');
		msg(' ');
		for i := 0 to slGlobal.Count-1 do if ContainsText(slGlobal[i], '-//-') then msg('[AddOutfitByList] '+slGlobal[i]+' := '+EditorID(ote(slGlobal.Objects[i])));
		for i := 0 to slGlobal.Count-1 do if ContainsText(slGlobal[i], '-/Level/-') then msg('[AddOutfitByList] '+slGlobal[i]+' := '+IntToStr(Integer(slGlobal.Objects[i])));
	end;
	Patch := slContains(slGlobal, 'Patch');	// Whether or not we're using the 'Patch' QOL function
	LoadOrder := GetLoadOrder(aPlugin);
	// Add Masters
	{Debug} if debugMsg then msg('[AddOutfitByList] Adding Masters');

	// Collect Outfits
	for i := 0 to aList.Count-1 do begin // Collect names
		if not (sig(ote(aList.Objects[i])) = 'ARMO') then Continue;
		tempRecord := ote(GetObject(aList[i], slGlobal));
		slNames.AddObject(full(tempRecord), tempRecord);
	end;
	slTemp.CommaText := 'Bracers, Gloves, Glove, Cloak, Underwear, Panties, Lingerie, Skirt, Armlets, Armlet, Gauntlets, Helmet, Crown, Helm, Hood, Mask, Circlet, Headdress, Shield, Buckler, Boots, Shoes, Cuirass, Armor, Top, Pants, Robes, Scarf, Clothes, Cape, Hooded';
	for i := 0 to slTemp.Count-1 do // Remove junk words
		RemoveSubStr(slNames, slTemp[i]);
	{Debug} if debugMsg then msgList('[AddOutfitByList] slNames := ', slNames, '');
	tempInteger := 0; // Keeps track of where we are in the list
	while (slNames.Count > tempInteger) do begin // while tier 3
		tempBoolean := False; // Keeps track of whether or not the current entry is deleted
		if not (GetPrimarySlot(ote(slNames.Objects[tempInteger])) = '00') then begin // Skips primary slot items
			Inc(tempInteger);
			Continue;
		end;
		commonString := Trim(slNames[tempInteger]); // String we're searching for
		while (Length(commonString) > 0) do begin // While tier 2
			{Debug} if debugMsg then msg('[AddOutfitByList] commonString := '+commonString);
			slTemp.Clear;
			for i := 0 to slNames.Count-1 do begin
				if ContainsText(slNames[i], commonString) then begin // if there's another item with the same prefix add it to slTemp
					tempElement := ote(slNames.Objects[i]);
					slTemp.AddObject(EditorID(tempElement), tempElement);
				end;
			end;
			if (slTemp.Count > 1) then begin // If there's more than one item with the same name assemble an outfit
				{Debug} if debugMsg then msgList('[AddOutfitByList] slTemp := ', slTemp, '');
				tempCount := 0; // Using the same trick again to keep track of where we are in the list
				while (slTemp.Count > tempCount) do begin // while tier 3
					slItem.Clear;
					tempRecord := ote(slTemp.Objects[tempCount]);
					Slot := GetPrimarySlot(tempRecord);
					if (Slot <> '00') then begin // Skips primary slot items
						Inc(tempCount);
						Continue;
					end;
					slGetFlagValues(tempRecord, slItem, False); // Get the BOD2 for this non-primary slot item
					AddPrimarySlots(slItem); // Associate with primary slot
					primarySlotItem := nil;
					for i := 0 to slTemp.Count-1 do begin // Associate the non-primary slot item with a primary-slot one of the same type
						if (i = tempCount) then Continue;
						tempElement := ote(slTemp.Objects[i]);
						tempString := GetPrimarySlot(tempElement);
						if SlContains(slItem, tempString) then begin // if the outfit contains a primary slot item equal to the primary slot associated with this item then begin
							primarySlotItem := tempElement;
							Slot := tempString;
							Break;
						end;
					end;
					if Assigned(primarySlotItem) then begin
						LLrecord := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(primarySlotItem)+'SubList');
						if not Assigned(LLrecord) then
							LLrecord := createLeveledList(aPlugin, EditorID(primarySlotItem)+'SubList', slTempList, 0); // Create a 'Use All' leveled list to contain all the non-primary slot items associated with this primary slot
					end else begin // if there isn't a same-type primary slot use any primary-slot item
						for i := 0 to slTemp.Count-1 do begin // Associate the non-primary slot item with a primary-slot one of the same type
							if (i = tempCount) then Continue;
							tempElement := ote(slTemp.Objects[i]);
							tempString := GetPrimarySlot(tempElement);
							if (GetPrimarySlot(tempElement) <> '00') then begin // if the outfit contains a primary slot item equal to the primary slot associated with this item then begin
								primarySlotItem := tempElement;
								Slot := tempString;
								Break;
							end;
						end;
						if Assigned(primarySlotItem) then begin // This is a hard-coded addition since this item won't be associated with the primary slot item in the main addition section
							LLrecord := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(primarySlotItem)+'SubList');
							if not Assigned(LLrecord) then
								LLrecord := createLeveledList(aPlugin, EditorID(primarySlotItem)+'SubList', slTempList, 0); // Create a 'Use All' leveled list to contain all the non-primary slot items associated with this primary slot
							if not LLcontains(LLrecord, tempRecord) then begin
								addToLeveledList(LLrecord, tempRecord, 1);
								y := IndexOfObjectEDID(EditorID(tempRecord), slNames);
								if (y <> -1) then begin
									{Debug} if debugMsg then msg('[AddOutfitByList] slNames.Delete ('+EditorID(ote(slNames.Objects[y]))+');');
									slNames.Delete(y); // Remove from name list				
								end;
								slTemp.Delete(tempCount); // Remove from outfit list
								if slContains(aList, EditorID(tempRecord)+'Original') then begin
									{Debug} if debugMsg then msg('slContains(aList, '+EditorID(tempRecord)+') then begin');
									{Debug} if debugMsg then msg('[AddOutfitByList] aList.Delete ('+aList[aList.IndexOf(EditorID(tempRecord)+'Original')]+');');
									aList.Delete(aList.IndexOf(EditorID(tempRecord)+'Original')); // Remove from leveled list addition
								end;							
							end;
						end;
					end;
					if not Assigned(primarySlotItem) then Break; // if there aren't any primary slot items in this outfit skip it entirely
					// Leveled List Addition
					{Debug} if debugMsg then msg('[AddOutfitByList] primarySlotItem := '+EditorID(primarySlotItem));
					// Create Leveled List
					{Debug} if debugMsg then msg('[AddOutfitByList] Begin Outfit Creation');
					slTempList.CommaText := '"Use All"';
					{Debug} if debugMsg then msg('[AddOutfitByList] addToLeveledList('+EditorID(LLrecord)+', '+EditorID(primarySlotItem)+'), 1);');
					if not LLcontains(LLrecord, primarySlotItem) then
						addToLeveledList(LLrecord, primarySlotItem, 1);
					{Debug} if debugMsg then msg('[AddOutfitByList] LLrecord := '+EditorID(LLrecord));
					currentCount := 0; // Last 'while' loop, I promise
					while (slTemp.Count > currentCount) do begin // Get all outfit items that are associated with this slot
						currentElement := ote(slTemp.Objects[currentCount]);
						{Debug} if debugMsg then msg('[AddOutfitByList] currentElement := '+EditorID(currentElement));
						if not (GetPrimarySlot(currentElement) = '00') then begin // Skips primary slot items
							Inc(currentCount);
							Continue;
						end;
						slItem.Clear;
						slGetFlagValues(currentElement, slItem, False); // Get BOD2 slots
						AddPrimarySlots(slItem); // Associate BOD2 with a primary slot
						{Debug} if debugMsg then msgList('[AddOutfitByList] '+EditorID(currentElement)+' Element BOD2 := ', slItem, '');
						{Debug} if debugMsg then msgList('[AddOutfitByList] if slContains (', slItem,'), '+Slot);
						if slContains(slItem, Slot) then begin // if its associated with the current slot add it to the leveled list
							{Debug} if debugMsg then msg('[AddOutfitByList] addToLeveledList('+EditorID(LLrecord)+', '+EditorID(currentElement)+'), 1);');
							if not LLcontains(LLrecord, currentElement) then
								addToLeveledList(LLrecord, currentElement, 1);
							y := IndexOfObjectEDID(EditorID(currentElement), slNames);
							if (y <> -1) then begin
								{Debug} if debugMsg then msg('[AddOutfitByList] slNames.Delete ('+EditorID(ote(slNames.Objects[y]))+');');
								slNames.Delete(y); // Remove from name list				
							end;
							{Debug} if debugMsg then msg('[AddOutfitByList] slTemp.Delete ('+slTemp[currentCount]+');');
							slTemp.Delete(currentCount); // Remove from outfit list
							if slContains(aList, EditorID(currentElement)+'Original') then begin
								{Debug} if debugMsg then msg('slContains(aList, '+EditorID(currentElement)+') then begin');
								{Debug} if debugMsg then msg('[AddOutfitByList] aList.Delete ('+aList[aList.IndexOf(EditorID(currentElement)+'Original')]+');');
								aList.Delete(aList.IndexOf(EditorID(currentElement)+'Original')); // Remove from leveled list addition
							end;
							if (currentCount = 0) then
								tempBoolean := True; // Only need to delete the current element in the master 'while' loop once
						end else // else go to next
							Inc(currentCount);
					end;
					if (LLec(LLrecord) > 1) then begin
						if not slContains(slOutfits, EditorID(LLrecord)) then
							slOutfits.AddObject(EditorID(LLrecord), LLrecord);
					end else
						Remove(LLrecord);
				end; // while tier 3 end
				Break; // if an outfit was assembled from this string exit the while loop
			end;
			if ContainsText(commonString, ' ') then begin // If an outfit is not found, shorten the number of words by 1 and check again
				commonString := Trim(StrPosCopy(commonString, ' ', True));
			end else
				Break;	
		end; // while tier 2 end
		if not tempBoolean then // if not already deleted
			slNames.Delete(tempInteger); // Remove the name we just checked for
	end; // while tier 1 end
	{Debug} if debugMsg then msgList('[AddOutfitByList] slOutfits := ', slOutfits, '');
	{Debug} if debugMsg then msgList('[AddOutfitByList] aList := ', aList, '');
	// Collect leveled lists
	msg('Beginning Leveled List Collection');
	// Custom Leveled List Input
	for i := 0 to slGlobal.Count-1 do
		if ContainsText(slGlobal[i], '-/LeveledList/-') then
			slLL.AddObject(StrPosCopy(slGlobal, '-/LeveledList/-', True), slGlobal.Objects[i]);
	// Leveled list from template
	for i := 0 to aList.Count-1 do begin
		masterRecord := ote(aList.Objects[i]);
		tempString := EditorID(masterRecord);
		// If two records have the same template this prevents it from getting processed twice
		{Debug} if debugMsg then msg('[AddOutfitByList] If two records have the same template this prevents it from getting processed twice');
		if slContains(slTemp, tempString) then
			Continue
		else
			slTemp.Add(tempString);
		{Debug} if debugMsg then msgList('[AddOutfitByList] ', slTemp, '');
		msg('['+IntToStr(i+1)+'/'+IntToStr(aList.Count)+'] Collecting '+tempString+' Leveled Lists');
		{Debug} if debugMsg then msg('[AddOutfitByList] for x := 0 to '+IntToStr(Pred(rbc(masterRecord)))+' do begin');
		for x := 0 to Pred(rbc(masterRecord)) do begin
			LLrecord := rbi(masterRecord, x);
			tempString := EditorID(LLrecord);
			{Debug} if debugMsg then msg('[AddOutfitByList] EditorID(LLrecord) := '+tempString);
			// Filter Invalid Entries
			{Debug} if debugMsg then msg('[AddOutfitByList] Filter Invalid Entries');
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
			end else if debugMsg then msg('[AddOutfitByList] '+EditorID(LLrecord)+' := '+IntToStr(LoadOrder)+' >= '+IntToStr(GetLoadOrder(GetFile(LLrecord))));			
			// Restricts the valid leveled lists to a single file (for 'Patch' function)
			{Debug} if debugMsg then msg('[AddOutfitByList] Restricts the valid leveled lists to a single file (for Patch function)');
			if Patch then begin
				tempString := GetFileName(ote(GetObject('Patch', slGlobal)));
				tempBoolean := False;
				// {Debug} if debugMsg then msg('[AddOutfitByList] for x := 0 to '+IntToStr(Pred(OverrideCount(LLrecord)))+' do begin');
				if (OverrideCount(LLrecord) > 0) then begin
					for y := 0 to Pred(OverrideCount(LLrecord)) do begin
						{Debug} if debugMsg then msg('[AddOutfitByList] if (GetFileName(GetFile(OverrideByIndex('+EditorID(LLrecord)+', '+IntToStr(x)+'))) = '+tempString+') then begin');
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
	{Debug} if debugMsg then msgList('[AddOutfitByList] slLL := ', slLL, ' );');
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
		{Debug} if debugMsg then msg('[AddOutfitByList] LLrecord := '+EditorID(LLrecord));
		if (Length(EditorID(LLrecord)) <= 0) then Continue
		tempElement := ebn(LLrecord, 'Leveled List Entries');
		for x := 0 to Pred(LLec(LLrecord)) do begin
			tempRecord := ebi(tempElement, x);
			slTemp.AddObject(StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True), StrToInt(geev(tempRecord, 'LVLO\Level'))); {Debug} if debugMsg then msg('[AddOutfitByList] slTemp.AddObject('+StrPosCopy(geev(tempRecord, 'LVLO\Reference'), ' ', True)+', '+IntToStr(StrToInt(geev(tempRecord, 'LVLO\Level')))+' )');
		end; {Debug} if debugMsg then msgList('[AddOutfitByList] slTemp := ', slTemp, '');
		for x := 0 to aList.Count-1 do begin
			tempRecord := ote(GetObject(aList[x], slGlobal));
			{Debug} if debugMsg then msg('[AddOutfitByList] tempRecord := '+EditorID(tempRecord));
			tempInteger := -1;
			// Custom input from 'Add To Leveled List' menu	
			tempString := EditorID(LLrecord)+'-/Level/-'+EditorID(tempRecord);
			if slContains(slGlobal, tempString) then begin
				tempInteger := Integer(GetObject(tempString, slGlobal)); {Debug} if debugMsg then msg('[AddOutfitByList] Custom Level for '+EditorID(tempRecord)+' in '+EditorID(LLrecord)+' := '+IntToStr(tempInteger));
				slGlobal.Delete(slGlobal.IndexOf(tempString));
				slGlobal.Delete(slGlobal.IndexOf(EditorID(LLrecord)+'-/LeveledList/-'+EditorID(tempRecord)));			
				if (tempInteger <= 0) then
					Continue;
			end;
			// Level from template
			if (tempInteger = -1) then begin
				tempString := EditorID(ote(aList.Objects[x]));
				{Debug} if debugMsg then msg('[AddOutfitByList] Find Template := '+tempString);
				if slContains(slTemp, tempString) then
					tempInteger := slTemp.Objects[slTemp.IndexOf(tempString)];
			end;
			{Debug} if debugMsg then msg('[AddOutfitByList] Level from '+EditorID(LLrecord)+' := '+IntToStr(tempInteger));
			if (tempInteger = -1) then Continue;
			if (tempInteger = 0) then
				tempInteger := 1;
			// Detect Pre-Existing List or Create Override
			case GetLoadOrder(GetFile(LLrecord)) of
				LoadOrder: LLcopy := LLrecord;
				else LLcopy := CopyRecordToFile(LLrecord, aPlugin, False, True);
			end;
			{Debug} if debugMsg then msg('[AddOutfitByList] LLcopy := '+EditorID(LLcopy));
			if not slContains(slTemp, EditorID(tempRecord)) then begin
				// {Debug} if debugMsg then msgList('[AddOutfitByList] if slContains(', slOutfits, '), '''+EditorID(tempRecord)+'SubList then');
				if slContains(slOutfits, EditorID(tempRecord)+'SubList') then // if non-primary slots have been associated with this item add it instead
					tempRecord := ote(slOutfits.Objects[slOutfits.IndexOf(EditorID(tempRecord)+'SubList')]);
				addToLeveledList(LLcopy, tempRecord, tempInteger); {Debug} if debugMsg then msg('[AddOutfitByList] addToLeveledList('+EditorID(LLcopy)+', '+EditorID(tempRecord)+', '+IntToStr(tempInteger)+' )');
				slTempList.Add(EditorID(tempRecord));
			end;
		end;
		if (slTempList.Count > 0) then
			msgList('['+IntToStr(i+1)+'/'+IntToStr(slLL.Count)+'] '+EditorID(LLrecord)+' added: ', slTempList, '');
  end;

	// Finalize
	stopTime := Time;
	if ProcessTime then addProcessTime('AddOutfitByList', TimeBtwn(startTime, stopTime));
	slOutfits.Free;
	slNames.Free;
	slTempList.Free;
	slTemp.Free;
	slItem.Free;
	slLL.Free;
end;