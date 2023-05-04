{
	M8r98a4f2s Complex Item Sorter for FallUI - Custom Rule Sets module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Used for custom rule set management
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}
unit CustomRuleSets;

var
	customProcRuleSets, 
	customProcRuleSetCrc32s: THashedStringList;
	
	crsModifiedRuleSets,
	crsRuleSetIniFiles: TStringList;
	crsModBaseNameToFullName: TStringList;
	
	_crsRlFrFilterProcRules: THashedStringList;
	_crsInitedCacheSystemRuleResultForDP: Boolean;

const
	RULESETS_IDENTIFIER_MAIN_RULES     = 'MAIN_RULES';
	RULESETS_IDENTIFIER_USER_RULES     = 'USER_RULES';
	RULESETS_IDENTIFIER_MOD_RULES      = 'MOD_RULES:';
	RULESETS_IDENTIFIER_USER_MOD_RULES = 'USER_MOD_RULES:';

{Initialize the unit}
procedure init();
var
	modBaseName, iniPath: String;
	esps: TStringList;
	i,j,ruleSetsSum, rulesSum: Integer;
begin
	try
	cleanup();
		
	_crsRlFrFilterProcRules := THashedStringList.Create;
	customProcRuleSets := THashedStringList.Create;
	customProcRuleSetCrc32s := TStringList.Create;
	crsModifiedRuleSets := TStringList.Create;
	crsRuleSetIniFiles := THashedStringList.Create;
	crsModBaseNameToFullName := THashedStringList.Create;
		
	// Load main rules
	iniPath := sComplexSorterBasePath+'Rules (Default)\rules-processing.ini';
	
	_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_MAIN_RULES, ruleSetsSum, rulesSum);
	AddMessage('Loading main processing rules: Added '+IntToStr(ruleSetsSum)+' rulesets containing '+IntToStr(rulesSum)+' rules.');

	// Load user rules
	iniPath := sComplexSorterBasePath+'Rules (User)\rules-processing.ini';
	if FileExists(iniPath) then begin
		_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_USER_RULES, ruleSetsSum, rulesSum);
		AddMessage('Loading user processing rules: Added '+IntToStr(ruleSetsSum)+' rulesets containing '+IntToStr(rulesSum)+' rules.');
		end
	else
		AddMessage('No custom user processing ruleset.');

	
	// Search rules for custom esps
	esps := TStringList.Create;
	esps.CommaText := sFiles;
	for i := 0 to esps.Count -1 do begin
		modBaseName := getBaseESPName(esps[i]);
		// Save basename2fullname index for later use 
		crsModBaseNameToFullName.Values[modBaseName] := esps[i];
		// Search main rules for mod
		iniPath := sComplexSorterBasePath+'Rules (Mods)\'+modBaseName+'.ini';
		if FileExists(iniPath) then begin
			_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_MOD_RULES+modBaseName, ruleSetsSum, rulesSum);
			AddMessage('Loading main processing rules for mod '+modBaseName+': Added '+IntToStr(ruleSetsSum)+' rulesets containing '+IntToStr(rulesSum)+' rules.');
			end;

		// Search user rules for mod
		iniPath := sComplexSorterBasePath+'Rules (User)\'+modBaseName+'.ini';
		if FileExists(iniPath) then begin
			_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName, ruleSetsSum, rulesSum);
			AddMessage('Loading user processing rules for mod '+modBaseName+': Added '+IntToStr(ruleSetsSum)+' rulesets containing '+IntToStr(rulesSum)+' rules.');
			end;
		
		end;
	finally
		// Cleanup
		if Assigned(esps) then esps.Free;
	end;
end;


{Returns a combined array of rule sets applying to for record rec}
function getProccessingRuleSetsArray(prefixRecordType:String):TStringList;
var
	i,index: Integer;
	procRuleSet: TStringList;
	modBaseName: String;
	modFileName, intCacheKey, rsSubIdent: String;
	masterRec: IInterface;
begin
	{sEditorId := getElementEditValues(pDR_record, 'EDID');
	if isMaster( pDR_record ) then begin
		modFileName := DynamicPatcher.getFileNameQuick();
		// Store source file for later use
		_storedRecordSourceFilenames.append(sEditorId+'='+modFileName);
		end
	else begin
		// modFileName := GetFileName(GetFile(MasterOrSelf(pDR_record)));
		// Allow overrides		
		// We just need the latest override, as mods normally don't get merged or have the merge in name
		if globalModificationsAllowed then begin// Records are now always in our new file, so one step back!
			// Use stored source file 
			if _storedRecordSourceFilenames.indexOfName(sEditorId) = -1 then 
				AddMessage('Unknown record source for '+sEditorId+'!')
			else 
				modFileName := _storedRecordSourceFilenames.values[sEditorId];
			end
		else begin 
			modFileName := GetFileName(GetFile((pDR_record)));
			// Store source file for later use
			_storedRecordSourceFilenames.append(sEditorId+'='+modFileName);
			end;
		end;
	}
	modFileName := getFileNameQuick2();
	rsSubIdent := prefixRecordType + pDR_recordType;
	intCacheKey := modFileName + '.' + rsSubIdent;
	index := _crsRlFrFilterProcRules.indexOf(intCacheKey);
	if index > -1 then begin
		Result := _crsRlFrFilterProcRules.Objects[index];
		Exit;
		end;

	// Create new list
	Result := TStringList.Create;
	_crsRlFrFilterProcRules.addObject(intCacheKey,Result);
		
	modBaseName := getBaseESPName(modFileName);
	
	// User rules for mods
	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName, rsSubIdent);
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName+'>'+rsSubIdent, procRuleSet);

	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName, prefixRecordType+'ALL');
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName+'>'+prefixRecordType+'ALL', procRuleSet);
	
	// Main rules for mods
	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_MOD_RULES+modBaseName, rsSubIdent);
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_MOD_RULES+modBaseName+'>'+rsSubIdent, procRuleSet);

	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_MOD_RULES+modBaseName, prefixRecordType+'ALL');
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_MOD_RULES+modBaseName+'>'+prefixRecordType+'ALL', procRuleSet);

	// User processing rules
	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_USER_RULES,rsSubIdent);
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_USER_RULES+'>'+rsSubIdent, procRuleSet);
				
	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_USER_RULES,prefixRecordType+'ALL');
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_USER_RULES+'>'+prefixRecordType+'ALL', procRuleSet);
	
	// Main processing rules
	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_MAIN_RULES,rsSubIdent);
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_MAIN_RULES+'>'+rsSubIdent, procRuleSet);
	
	procRuleSet := getCustomProcessingRuleSet(RULESETS_IDENTIFIER_MAIN_RULES,prefixRecordType+'ALL');
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			Result.addObject(RULESETS_IDENTIFIER_MAIN_RULES+'>'+prefixRecordType+'ALL', procRuleSet);
	
	// AddMessage('Created list for '+intCacheKey+' containing '+IntToStr(Result.Count)+ ' rule sets: '+Result.CommaText);
end;


{Reads a ruleset from a ini file. Then add it to customProcRuleSets}
procedure _readRuleSetFromINI(iniPath,ruleSetIdentifier:String;var ruleSetsSum, var rulesSum:Integer);
var
	iniFile: TIniFile;
	j, k,rulesSum: Integer;
	sections,sectionProcRules: TStringList;
	parsedIniSection: THashedStringList;
	sectionName: String;
begin
	try
	
	// Save file name
	crsRuleSetIniFiles.values[ruleSetIdentifier] := iniPath;
	
	// Init
	rulesSum := 0;
	ruleSetsSum := 0;
	iniFile := TIniFile.Create(iniPath);
	// crc32Str := IntToStr(wbCRC32File(iniPath));
	sections := TStringList.Create;
	sectionProcRules := TStringList.Create;
	
	// Read sections
	iniFile.ReadSections(sections);
	if customProcRuleSets.indexOf(ruleSetIdentifier) > -1 then
		AddMessage('Error: Rule set main ident "'+ruleSetIdentifier+'" is not unique!');
	

	for j := 0 to sections.Count -1 do begin
		sectionName := sections[j];
		iniFile.ReadSectionValues(sectionName, sectionProcRules);
		if Pos('INNR_RULES:',sectionName) = 1 then
			// INNR rules for dynamic naming system
			INNRProcessing.storeModNamingRules(Copy(sectionName, Length('INNR_RULES:')+1,200),sectionProcRules)
		else begin
			// Adding to collection
			rulesSum := rulesSum + addProcessingRuleSetSection(ruleSetIdentifier, sectionName, sectionProcRules);
			ruleSetsSum := ruleSetsSum + 1;
			end;
		end;
		
	finally
		// Cleanup
		if Assigned(iniFile) then iniFile.Free;
		if Assigned(sections) then sections.Free;
		if Assigned(sectionProcRules) then sectionProcRules.Free;
	end;
end;

{Adds a new proc. rule set to the rules collection
	The input list should have ini format like from TIniFile.ReadSectionValues
	Returns the count of rules }
function addProcessingRuleSetSection(ruleSetIdentifier:String;sectionName:String;sectionProcRules:TStringList):Integer;
var
	parsedIniSection, sectionsOfRuleSet: TStringList;
	tmpPath: String;
	sectionCacheCur, sectionCacheNew: TStringList;
begin
	tmpPath := sComplexSorterBasePath+'cache\tempcrc32.ini';
	// Determine location to store
	if customProcRuleSets.indexOf(ruleSetIdentifier) = -1 then begin
		// Creating new ruleset
		sectionsOfRuleSet := TStringList.Create;
		customProcRuleSets.addObject(ruleSetIdentifier,sectionsOfRuleSet);
		end
	else begin
		// Adding to existing ruleset
		sectionsOfRuleSet := customProcRuleSets.Objects[customProcRuleSets.indexOf(ruleSetIdentifier)];
		end;

	parsedIniSection := _preparseIniSectionRules(sectionProcRules, ruleSetIdentifier, sectionName);
	sectionsOfRuleSet.addObject(sectionName, parsedIniSection);
	
	// Store crc32 of ruleset
	sectionProcRules.SaveToFile(tmpPath);
	customProcRuleSetCrc32s.values[ruleSetIdentifier+'>'+sectionName] := IntToStr(wbCRC32File(tmpPath));
	// AddMessage('set crc32 '+ruleSetIdentifier+'>'+sectionName+' = ' + customProcRuleSetCrc32s.values[ruleSetIdentifier+'>'+sectionName]);
	Result := parsedIniSection.Count;
	if Assigned(tmpPath) and (tmpPath <> '' ) then
		if FileExists(tmpPath) then
			DeleteFile(tmpPath);
	// On the fly?
	if _crsInitedCacheSystemRuleResultForDP then begin
		// AddMessage('On the fly: '+ruleSetIdentifier+'>'+sectionName);
		// initPdrCacheRuleSetSection(ruleSetIdentifier, sectionName);
		// Create and validate on the fly 
		if Cache.getEntrySetLevelTwo('dynamicPatcherRuleSetResults',ruleSetIdentifier+'>'+sectionName, true, sectionCacheCur, sectionCacheNew) then
			// Validate section cache
			cache_validateRuleSetSectionCache(ruleSetIdentifier+'>'+sectionName,sectionCacheCur, sectionCacheNew);
		end;
end;


// Creates a ruleset from a ini-Section
function _preparseIniSectionRules(sectionProcRules: THashedStringList;const ruleSetIdentifier:String;const sectionName:String):THashedStringList;
var
	i,j: Integer;
	tmpLst, parsedCondition, conditionPacks,conditionPack,quickCheckPack,testDuplicateNames: TStringList;
	ruleConditions, ruleTagIdent: String;
begin
	
	// Create ruleset
	Result := THashedStringList.Create;
	testDuplicateNames := TStringList.Create;
	// Read section lines into Rules
	for i := 0 to sectionProcRules.Count - 1 do begin
		ruleConditions := sectionProcRules.Names[i];
		if testDuplicateNames.indexOf(ruleConditions) > -1 then
			AddMessage('WARNING: Duplicate rule conditions found: "'+ruleConditions+'". Because of the nature of Pascal''s INI file reader, this values couldn''t read!')
		else
			testDuplicateNames.add(ruleConditions);
		ruleTagIdent := sectionProcRules.ValueFromIndex[i];
		tmpLst := Split(',',' '+StringReplace(ruleConditions,',',', ',[rfReplaceAll])); // Workaround pascal really strange TStringList Delimiter bugs with quotes...
		
		// Add applyTagRule as String and conditions as TStringList
		conditionPacks := TStringList.Create;
		Result.addObject(ruleTagIdent, conditionPacks{List of conditionPacks} );
		
		for j := 0 to tmpLst.Count - 1 do begin
			parsedCondition := parseParameters(tmpLst[j],true);
			conditionPack := TStringList.Create;
			// Condition pack content: 0 = not|eq, 1=parsedCondition, (2=quickCheckPack)

			// Slot 0: Has NOT operator?
			conditionPack.add(parsedCondition[0] <> 'not'); // True for quick comparison. not = False
			if parsedCondition[0] = 'not' then
				parsedCondition.delete(0);
				
			// Slot 1: parsedCondition
			conditionPack.addObject(parsedCondition.CommaText,parsedCondition);
			conditionPacks.addObject('cpack',conditionPack);
			
			if pDR_gatherStats then
				conditionPacks.Strings[j] := '('+ruleSetIdentifier+'>'+sectionName+') - Rule #'+IntToStr(i+1)+' '+ruleConditions + ' -> '+ruleTagIdent;
			
			// Slot 2: Add quickCheckPack?
			quickCheckPack := DynamicPatcher.createQuickCheckPack(parsedCondition);
			if Assigned(quickCheckPack) then
				conditionPack.addObject('quickCheckPack',quickCheckPack);
			end;
		tmpLst.Free;
	end;

end;

{
Structure of stored rules:
	Main storage: customProcRuleSets:THashedStringList
	  Entry format: n * ( str:ruleSetIdentifier  obj: sectionsOfRuleSet )
		- sectionsOfRuleSet:TStringList
		  Entry format: n * ( str: sectonName  obj: parsedIniSection )
		  - parsedIniSection:THashedStringList
	Ruleset:THashedStringList - Ini Section
	  Entry format: n * ( str:TagIdent  obj: conditionPacks )
		- conditionPacks:TStringList
		  Entry format: n * ( str:"cpack"  obj: conditionPack )
			- conditionPack:TStringList
			  Entry format: 0 = ( str:'False' or 'True'  obj: null )
			                1 = ( str:parsedCondition.CommaText  obj: parsedCondition )
			                2 = [optional] ( str:'quickCheckPack'  obj: quickCheckPack )
				- quickCheckPack:TStringList
				  Entry format:  - ... see DynamicPatcher
}


{Returns custom processing rules for a record type}
function getCustomProcessingRuleSet(ruleSetIdentifier, recordType:String):TStringList;
var
	ruleSetIndex: Integer;
begin
	Result := nil;
	if Assigned(customProcRuleSets) then begin
		ruleSetIndex := customProcRuleSets.indexOf(ruleSetIdentifier);
		if ruleSetIndex > -1 then
			if customProcRuleSets.Objects[ruleSetIndex].indexOf(recordType) > -1 then
				Result := customProcRuleSets.Objects[ruleSetIndex].Objects[customProcRuleSets.Objects[ruleSetIndex].indexOf(recordType)];
			end
end;


procedure cleanupPreparsedProcessingRuleSet(processingRuleSet:THashedStringList);
var
	i,j:Integer;
	conditionPack: TStringList;
begin
	if Assigned(processingRuleSet) then begin
		for i := processingRuleSet.Count - 1 downto 0 do  begin
			for j := processingRuleSet.Objects[i].Count - 1 downto 0 do begin
				conditionPack := processingRuleSet.Objects[i].Objects[j];
				cleanupConditionPack(conditionPack);
				end;
			processingRuleSet.Objects[i].Free();
			end
		processingRuleSet.Free;
		processingRuleSet := nil;
		end;

end;

procedure cleanupConditionPack(conditionPack:TStringList);
begin
	conditionPack.Objects[1].Free;
	// Clean quickCheckPack
	if conditionPack.Count > 2 then begin
		cleanupQuickCheckPack(conditionPack.Objects[2]);
		end;
	conditionPack.Free;
end;


{Garanties the existance of cache object lookup lists - Creates all necessary things for the rule result caching system}
procedure initPdrCacheForExistingRuleSets();
var
	i, j: Integer;
	sectionsOfRuleSet: TStringList;
	procRuleSetSectionIdent, sectionName: String;
	sectionCacheCur, sectionCacheNew: TStringList;
begin
	for i:= 0 to customProcRuleSets.Count - 1 do begin
		sectionsOfRuleSet := customProcRuleSets.Objects[i];
		for j:= 0 to sectionsOfRuleSet.Count - 1 do begin
			sectionName := sectionsOfRuleSet.Strings[j];
			procRuleSetSectionIdent := customProcRuleSets[i] + '>' + sectionName;			
			// Create and validate
			if Cache.getEntrySetLevelTwo('dynamicPatcherRuleSetResults',procRuleSetSectionIdent, true, sectionCacheCur, sectionCacheNew) then
				// Validate section cache
				cache_validateRuleSetSectionCache(procRuleSetSectionIdent,sectionCacheCur, sectionCacheNew);
			end;
		end;
	_crsInitedCacheSystemRuleResultForDP := true;
end;

{Clears set sectioncache for a ruleset}
procedure _cacheResetRuleSetSectionCache(var sectionCacheCur,var sectionCacheNew:TStringList);
begin
	sectionCacheCur.Clear();
	sectionCacheNew.Clear();
	sectionCacheCur.add('RULESET_TAINTS=NONE');
	sectionCacheNew.add('RULESET_TAINTS=NONE');
	sectionCacheCur.add('VALIDATION_STR=null');
	sectionCacheNew.add('VALIDATION_STR=null');
end;


{Validates a ruleset section cache}
procedure cache_validateRuleSetSectionCache(const procRuleSetSectionIdent:String;sectionCacheCur, sectionCacheNew:TStringList);
var
	rssChecksumStr, taints: String;
begin
			
	// Must contains: RULESET_TAINTS, VALIDATION_STR - Add to both list if not
	if sectionCacheCur.indexOfName('RULESET_TAINTS') = -1 then
		_cacheResetRuleSetSectionCache(sectionCacheCur, sectionCacheNew)
	else if sectionCacheCur.indexOfName('VALIDATION_STR') = -1 then
		_cacheResetRuleSetSectionCache(sectionCacheCur, sectionCacheNew);

	rssChecksumStr := customProcRuleSetCrc32s.values[procRuleSetSectionIdent];
	taints := sectionCacheNew.values['RULESET_TAINTS'];
	// AddMessage('RSSVS ('+procRuleSetSectionIdent+'): '+taints);
	if taints <> 'NONE' then
		cache_validateProcessTaints(taints, rssChecksumStr);
		
	// Invalidate cache
	if (rssChecksumStr = 'INVALIDATE') or (rssChecksumStr <> sectionCacheCur.values['VALIDATION_STR'] ) then begin
		// AddMessage('Invalidate ruleset cache: '+procRuleSetSectionIdent+ ' (old='+sectionCacheCur.values['VALIDATION_STR']+' new='+rssChecksumStr+' )');
		_cacheResetRuleSetSectionCache(sectionCacheCur, sectionCacheNew);
		// Add taints again
		{if taints <> '' then begin
			AddMessage('before: ' + sectionCacheNew.values['RULESET_TAINTS']);
			sectionCacheNew.values['RULESET_TAINTS'] := taints;
			AddMessage('after : ' + sectionCacheNew.values['RULESET_TAINTS']);
			end;}
		end;
	
	// Save validation string
	sectionCacheCur.values['VALIDATION_STR'] := rssChecksumStr;
	sectionCacheNew.values['VALIDATION_STR'] := rssChecksumStr;
		
end;

{Process the taints and create validation "checksums" - more strings :D}
procedure cache_validateProcessTaints(taints:String; var rssChecksumStr:String);
var 
	k, iPos: Integer;
	taint,tmpStr: String;
	taintsLst: TStringList;
begin
	taintsLst := Split(',', taints);
	for k := 0 to taintsLst.Count -1 do begin
		taint := taintsLst[k];
		if taint = 'NONE' then
			continue
		else if BeginsWithExtract('TAINT:PluginScript:',taint,tmpStr) then begin
			iPos := Pos(':',tmpStr);
			if not CSPluginSystem.addPluginCacheValidationStr(Copy(tmpStr,1,iPos-1),Copy(tmpStr,iPos+1,length(tmpStr)-iPos),rssChecksumStr) then
				rssChecksumStr := 'INVALIDATE'; // TODO: Add typed NOT_CACHABLE
			Exit;
			end
		else if BeginsWithExtract('TAINT:PluginSetting:',taint,tmpStr) then begin
			iPos := Pos(':',tmpStr);
			rssChecksumStr := rssChecksumStr + '|plgSet:'+tmpStr+':'+
				CSPluginSystem.getPluginUserSetting(Copy(tmpStr,1,iPos-1),Copy(tmpStr,iPos+1,length(tmpStr)-iPos));
			Exit;
			end
		else if taint = 'TAINT:FindCustomTag' then begin
			rssChecksumStr := rssChecksumStr + '|innrCRC-'+IntToStr(wbCRC32File(getDynamicNamingRulesIniPath()));
			Exit;
			end
		else begin
			AddMessage('Unknown ruleset cache taint "'+taint+'". Invalidating cache.');
			rssChecksumStr := 'INVALIDATE';
			end;
		end;
	taintsLst.Free;
end;



{unit cleanup}
procedure cleanup();
var
	i,j: Integer;
begin

	if Assigned(customProcRuleSets) then begin
		for i := customProcRuleSets.Count -1 downto 0 do begin
			for j := customProcRuleSets.Objects[i].Count -1 downto 0 do
				cleanupPreparsedProcessingRuleSet(customProcRuleSets.Objects[i].Objects[j]);
			customProcRuleSets.Objects[i].Free;
			end;
		FreeAndNil(customProcRuleSets);
		end;
		
	if Assigned(_crsRlFrFilterProcRules) then begin
		for i:= 0 to _crsRlFrFilterProcRules.Count -1 do
			_crsRlFrFilterProcRules.Objects[i].Free;
		FreeAndNil(_crsRlFrFilterProcRules);
		end
		
	FreeAndNil(customProcRuleSetCrc32s);
	FreeAndNil(crsModifiedRuleSets);
	FreeAndNil(crsRuleSetIniFiles);
	FreeAndNil(crsModBaseNameToFullName);
end;



end.