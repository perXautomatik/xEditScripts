

// Generates enchanted versions of a list of records from a list of input files
Procedure GenerateEnchantedVersionsAuto;
var
	slTemp, slItem, slItemTiers, slIndex, slFiles, slTempList, slRecords, slEnchanted, slExistingRecords, slBOD2: TStringList;
  tempRecord, tempElement, objEffect, enchLevelList, chanceLevelList, GEVfile: IInterface;
	debugMsg, tempBoolean, AllowDisenchanting, ReplaceInLeveledList: Boolean;
  tempString, suffix, record_sig, record_edid, PatchFile, enchString: String;
	startTime, stopTime, tempStartTime, tempStopTime, processStartTime, processStopTime: TDateTime;
	enchAmount, enchMultiplier: Float;
	i, x, y, z, tempInteger, enchCount: Integer;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;
	if not Assigned(slExistingRecords) then slExistingRecords := TStringList.Create;
	if not Assigned(slEnchanted) then slEnchanted := TStringList.Create;
	if not Assigned(slItemTiers) then slItemTiers := TStringList.Create;
	if not Assigned(slTempList) then slTempList := TStringList.Create;
	if not Assigned(slRecords) then slRecords := TStringList.Create;
	if not Assigned(slGlobal) then slGlobal := TStringList.Create;
	if not Assigned(slIndex) then slIndex := TStringList.Create;
	if not Assigned(slFiles) then slFiles := TStringList.Create;
	if not Assigned(slBOD2) then slBOD2 := TStringList.Create;
	if not Assigned(slItem) then slItem := TStringList.Create;
	if not Assigned(slTemp) then slTemp := TStringList.Create;

	// Detect loaded plugins
	slTemp.CommaText := 'Skyrim.esm, Dawnguard.esm, Hearthfires.esm, Dragonborn.esm, HolyEnchants.esp, LostEnchantments.esp, "More Interesting Loot for Skyrim.esp", "Summermyst - Enchantments of Skyrim.esp", "Wintermyst - Enchantments of Skyrim.esp"';
	for i := 0 to slTemp.Count-1 do
		if DoesFileExist(slTemp[i]) then
			slFiles.AddObject(Trim(slTemp[i]), FileByName(slTemp[i]));
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slFiles := ', slFiles, '');

	// Skips dlg if external input is present
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slGlobal := ', slGlobal, '');
	{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] AllowDisenchanting := '+BoolToStr(Boolean(GetObject('AllowDisenchanting', slGlobal))));
	AllowDisenchanting := Boolean(GetObject('AllowDisenchanting', slGlobal));
	if slContains(slGlobal, 'AddtoLeveledList') then
		ReplaceInLeveledList := Boolean(GetObject('AddtoLeveledList', slGlobal))
	else
		ReplaceInLeveledList := Boolean(GetObject('ReplaceInLeveledList', slGlobal));
	GEVfile := ote(GetObject('GEVfile', slGlobal));
	enchMultiplier := Integer(GetObject('EnchMultiplier', slGlobal));
	{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] enchMultiplier := '+IntToStr(enchMultiplier));

	// Prep File
	if not Assigned(GEVfile) then begin
		GEV_GeneralSettings;
		GEVfile := ote(GetObject('GEVfile', slGlobal));
	end;
	if Assigned(GEVfile) then begin
		// Create the necessary groups
		slTemp.CommaText := 'LVLI, ARMO, WEAP, COBJ, KYWD';
		for x := 0 to slTemp.Count-1 do
			if not HasGroup(GEVfile, slTemp[x]) then
				Add(GEVfile, slTemp[x], True);
	end else begin
		msg('[ERROR] [GenerateEnchantedVersionsAuto] GEVfile unassigned');
		if Assigned(slExistingRecords) then slExistingRecords.Free;
		if Assigned(slEnchanted) then slEnchanted.Free;
		if Assigned(slItemTiers) then slItemTiers.Free;	
		if Assigned(slTempList) then slTempList.Free;
		if Assigned(slRecords) then slRecords.Free;
		if Assigned(slIndex) then slIndex.Free;
		if Assigned(slFiles) then slFiles.Free;
		if Assigned(slBOD2) then slBOD2.Free;
		if Assigned(slTemp) then slTemp.Free;
		if Assigned(slItem) then slItem.Free;
		Exit;
	end;
	{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] AllowDisenchanting := '+BoolToStr(Boolean(GetObject('AllowDisenchanting', slGlobal))));

	// Load slRecords with all valid original records
	for i := 0 to slGlobal.Count-1 do
		if ContainsText(slGlobal[i], 'Original') then
			SetObject(StrPosCopy(slGlobal[i], 'Original', True), slGlobal.Objects[i], slRecords);
	{Debug} if debugMsg then msgList('slGlobal := ', slGlobal, '');
	{Debug} if debugMsg then msgList('slRecords := ', slRecords, '');

	// Add masters
	tempStartTime := Time;


	tempStopTime := Time;
	if ProcessTime then addProcessTime('Add Masters', TimeBtwn(tempStartTime, tempStopTime));

	// Build indexes of loaded plugins
	tempStartTime := Time;
	{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] Build indexes of loaded plugins');
	slTemp.Clear;
	// Get keywords
	for x := 0 to slRecords.Count-1 do begin
		tempRecord := ote(slRecords.Objects[x]);
		if (sig(tempRecord) = 'ARMO') then begin
			slItem.Clear;
			slGetFlagValues(tempRecord, slItem, False);
			// Add clothing type to keywords
			for y := 0 to slItem.Count-1 do begin
				if not ((slItem[y] = '35') or (slItem[y] = '36') or (slItem[y] = '42')) then
					slItem[y] := slItem[y]+'-'+geev(tempRecord, GetElementType(tempRecord)+'\Armor Type');
			end;
			// This is an index for the BOD2 slots so they don't have to be generated again in 'Process'
			if (slItem.Count > 0) then begin
				for y := 0 to slItem.Count-1 do
					tempString := tempString+' '+slItem[y];
				slBOD2.Add(EditorID(tempRecord)+'-//-'+tempString);
			end;
			// Non-vanilla armor types prioritize keywords over BOD2
			slTempList.CommaText :=  '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
			for y := 0 to slItem.Count-1 do
				if not StrWithinSL(slItem[y], slTempList) then
					if not slContains(slItem, AssociatedBOD2(slItem[y])) then
						slItem.Add(AssociatedBOD2(slItem[y]));
			for y := 0 to slItem.Count-1 do
				if not slContains(slTemp, slItem[y]) then
					slTemp.Add(slItem[y]);
		end else
			if not slContains(slTemp, sig(tempRecord)) then
				slTemp.Add(sig(tempRecord));
		slClearEmptyStrings(slTemp);
	end;
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] Keywords (slTemp) := ', slTemp, '');
	for x := 0 to slFiles.Count-1 do begin
		tempInteger := ec(gbs(ote(slFiles.Objects[x]), 'ENCH'));
		enchCount := enchCount + tempInteger;
		msg('Indexing '+IntToStr(tempInteger)+' Enchantments in '+slFiles[x]);
		IndexObjEffect(ote(slFiles.Objects[x]), slTemp, slIndex);			
	end;
	if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slIndex := ', slIndex, '');
	tempStopTime := Time;
	addProcessTime('Create Library of '+IntToStr(enchCount)+' Enchantments', TimeBtwn(tempStartTime, tempStopTime));

	// Set Item Tiers
	for x := 1 to 6 do
		SetObject('0'+IntToStr(x), Integer(GetObject('ItemTier0'+IntToStr(x), slGlobal)), slItemTiers);

	// Get a list of existing records
	slExistingRecords.Clear;
	slTemp.CommaText := 'ARMO, AMMO, WEAP';
	for x := 0 to slTemp.Count-1 do begin
		tempElement := gbs(GEVfile, slTemp[x]);
		for y := 0 to Pred(ec(tempElement)) do
			slExistingRecords.Add(EditorID(ebi(tempElement, y)));
	end;
	// {Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slExistingRecords := ', slExistingRecords, '');

	// Process
	processStartTime := Time;
	for i := 0 to slRecords.Count-1 do begin
		// Common function output
		{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slRecords := ', slRecords, '');
		selectedRecord := ote(slRecords.Objects[i]);
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] selectedRecord := '+EditorID(ote(slRecords.Objects[i])));
		record_sig := sig(selectedRecord);
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] record_sig := '+record_sig);
		record_edid := EditorID(selectedRecord);
	
		// Detect Pre-Existing Leveled Lists
		if ProcessTime then tempStartTime := Time;
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] Detecting Pre-Existing Leveled Lists');
		enchLevelList := nil;
		chanceLevelList := nil;
		for x := 0 to Pred(rbc(selectedRecord)) do begin
			tempRecord := rbi(selectedRecord, x);
			if (sig(tempRecord) = 'LVLI') then begin
				tempString := EditorID(tempRecord);
				if ContainsText(tempString, 'Ench') and ContainsText(tempString, '++') then begin
					if ContainsText(tempString, 'Chance') then begin
						if not (GetLoadOrder(GEVfile) = GetLoadOrder(GetFile(tempRecord))) then
							chanceLevelList := CopyRecordToFile(tempRecord, GEVfile, False, True)
						else
							chanceLevelList := tempRecord;
					end else begin
						if not (GetLoadOrder(GEVfile) = GetLoadOrder(GetFile(tempRecord))) then
							enchLevelList := CopyRecordToFile(tempRecord, GEVfile, False, True)
						else
							enchLevelList := tempRecord;
					end;
			end;
			if Assigned(enchLevelList) and Assigned(chanceLevelList) then Break;
			end;
		end;
		if ProcessTime then begin
			tempStopTime := Time;
			addProcessTime('[GEV] Detect Pre-Existing Leveled Lists', TimeBtwn(tempStartTime, tempStopTime));
		end;
	
		// Create new Leveled Lists if not already present
		{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] Create new Leveled Lists if not already present');
		if not Assigned(enchLevelList) then begin
			slTemp.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count"';
			{Debug} if debugMsg then msgList('createLeveledList('+GetFileName(GEVfile)+', LItem'+StrCapFirst(record_sig)+'Ench'+record_edid+'++, ', slTemp, ', 0 );');	
			enchLevelList := createLeveledList(GEVfile, 'LItem'+StrCapFirst(record_sig)+'Ench'+record_edid+'++', slTemp, 0);
			addToLeveledList(enchLevelList, selectedRecord, 1);
		end;
		if not Assigned(chanceLevelList) then begin
			{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] createChanceLeveledList('+GetFileName(GEVfile)+', LItem'+StrCapFirst(record_sig)+'EnchChance'+record_edid+'++, '+IntToStr(Integer(GetObject('ChanceMultiplier', slGlobal)))+', '+record_edid+', '+EditorID(enchLevelList)+' );');
			chanceLevelList := createChanceLeveledList(GEVfile, 'LItem'+StrCapFirst(record_sig)+'EnchChance'+record_edid+'++', Integer(GetObject('ChanceMultiplier', slGlobal)), selectedRecord, enchLevelList);
			slEnchanted.AddObject(record_edid, chanceLevelList);
		end;
	
		// Process records using the indexed list
		tempStartTime := Time;
		msg('['+IntToStr(i+1)+'/'+IntToStr(slRecords.Count)+'] Processing '+record_edid+' enchanted versions');
		{Debug} if debugMsg then msg('record_sig := '+record_sig);
		// Get BOD2 list from BOD2 index
		for x := 0 to slBOD2.Count-1 do begin
			if (StrPosCopy(slBOD2[x], '-//-', True) = record_edid) then begin
				slTemp.CommaText := StrPosCopy(slBOD2[x], '-//-', False);
				Break;
			end;
		end;
	
		// Use library to add enchantments
		for x := 0 to slIndex.Count-1 do begin
			objEffect := nil;
			suffix := StrPosCopy(slIndex[x], '-//-', True);
			enchString := StrPosCopy(slIndex[x], '-//-', False);
			if (record_sig = 'ARMO') then begin 
				{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slTemp := ', slTemp, '');
				if SLWithinStr(enchString, slTemp) then begin
					objEffect := ote(slIndex.Objects[x]);
					{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] objEffect := '+EditorID(objEffect));
				end;
			end else if ContainsText(enchString, record_sig) then begin
					objEffect := ote(slIndex.Objects[x]);
					{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] objEffect := '+EditorID(objEffect));
			end;
			if Assigned(objEffect) then begin
				tempInteger := GetEnchLevel(objEffect, slItemTiers); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] enchLevel := '+IntToStr(tempInteger));
				if (tempInteger > 0) then begin		
					{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] enchAmount := '+IntToStr((enchMultiplier*genv(objEffect, 'ENIT\Enchantment Amount')) div 100)+' * '+IntToStr(genv(objEffect, 'ENIT\Enchantment Amount')));
					enchAmount := (enchMultiplier*GetEnchAmount(tempInteger)) div 100;
					// Pre-Existing records
					if not slContains(slExistingRecords, EditorID(selectedRecord)+'_'+EditorID(objEffect)) then begin
						tempElement := CopyRecordToFile(selectedRecord, GEVfile, True, True); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] enchRecord := '+EditorID(tempElement));
					end else
						Continue;
					// Generate Enchantment
					tempRecord := createEnchantedVersion(selectedRecord, GEVfile, objEffect, tempElement, suffix, Round(enchAmount), AllowDisenchanting); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] tempRecord := CreateEnchantedVersion('+record_edid+', '+GetFileName(GEVfile)+', '+EditorID(objEffect)+', '+EditorID(tempElement)+', '+StrPosCopy(full(objEffect), 'of', False)+', '+IntToStr(Round(enchAmount))+', '+BoolToStr(AllowDisenchanting)+' );');																							
					addToLeveledList(enchLevelList, tempRecord, tempInteger); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] AddToLeveledList('+EditorID(enchLevelList)+', '+EditorID(tempRecord)+', '+IntToStr(tempInteger)+' );');
					slExistingRecords.Add(EditorID(tempRecord));
				end;
			end;
		end;
	
		// This replaces records in the vanilla leveled lists
		if ReplaceInLeveledList then begin
			//  Add to enchanted lists
			tempElement := nil;
			if (sig(selectedRecord) = 'WEAP') then begin
				tempElement := ebEDID(gbs(FileByName('Skyrim.esm'), 'LVLI'), 'LItemEnch'+EditorID(ote(GetObject(EditorID(selectedRecord)+'Template', slGlobal)))); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] tempElement := '+EditorID(tempElement));
			end else
				tempElement := ebEDID(gbs(FileByName('Skyrim.esm'), 'LVLI'), 'LItemEnchArmor'+StrPosCopy(geev(selectedRecord, GetElementType(selectedRecord)+'\Armor Type'), ' ', True)+GetItemType(selectedRecord)); {Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] tempElement := '+EditorID(tempElement));	
			if Assigned(tempElement) then begin
				tempRecord := nil;
				if HasFileOverride(tempElement, GEVfile) then begin
					tempRecord := GetFileOverride(tempElement, GEVfile);
				end else
					tempRecord := CopyRecordToFile(selectedRecord, GEVfile, False, True);
				if Assigned(tempRecord) and Assigned(enchLevelList) then begin
					{Debug} if debugMsg then msg('[GenerateEnchantedVersionsAuto] if Assigned(tempRecord) and Assigned(enchLevelList) then ReplaceInLeveledListAuto('+EditorID(tempRecord)+', '+EditorID(enchLevelList)+', '+GetFileName(GEVfile)+' );');
					ReplaceInLeveledListAuto(tempRecord, enchLevelList, GEVfile);
				end;
			end;
		end;
	
		// Process Time Messages
		if ProcessTime then begin
			tempStopTime := Time;
			addProcessTime('[GEV] Process Enchanted Versions', TimeBtwn(tempStartTime, tempStopTime));
		end;
	end;
	if ProcessTime then begin
		processStopTime := Time;
		addProcessTime('Generate Enchantments for '+IntToStr(slRecords.Count)+' Records', TimeBtwn(processStartTime, processStopTime));
	end;

	// Replace original with enchanted versions
	if ReplaceInLeveledList then
		ReplaceInLeveledListByList(slRecords, slEnchanted, GEVfile);

	// Set Result
	{Debug} if debugMsg then msgList('[GenerateEnchantedVersionsAuto] slGlobal := ', slGlobal, '');

	// Finalize
	if ProcessTime then begin
		stopTime := Time;
		addProcessTime('GenerateEnchantedVersionsAuto', TimeBtwn(startTime, stopTime));
	end;
	if Assigned(slExistingRecords) then slExistingRecords.Free;
	if Assigned(slEnchanted) then slEnchanted.Free;
	if Assigned(slItemTiers) then slItemTiers.Free;
	if Assigned(slTempList) then slTempList.Free;
	if Assigned(slRecords) then slRecords.Free;
	if Assigned(slIndex) then slIndex.Free;
	if Assigned(slFiles) then slFiles.Free;
	if Assigned(slBOD2) then slBOD2.Free;
	if Assigned(slTemp) then slTemp.Free;
	if Assigned(slItem) then slItem.Free;
end;