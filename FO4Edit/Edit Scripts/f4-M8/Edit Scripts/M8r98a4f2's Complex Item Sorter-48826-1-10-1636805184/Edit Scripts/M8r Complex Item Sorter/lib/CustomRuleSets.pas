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

const
	RULESETS_IDENTIFIER_MAIN_RULES     = 'MAIN_RULES';
	RULESETS_IDENTIFIER_USER_RULES     = 'USER_RULES';
	RULESETS_IDENTIFIER_MOD_RULES      = 'MOD_RULES:';
	RULESETS_IDENTIFIER_USER_MOD_RULES = 'USER_MOD_RULES:';
	RULESETS_IDENTIFIER_PLUGIN_RULES   = 'PLUGIN_RULES:';

var
	customProcRuleSets, 
	customProcRuleSetCrc32s: THashedStringList;
	
	crsModifiedRuleSets: TStringList;
	crsRuleSetIniFiles,
	crsModBaseNameToFullName: THashedStringList;
	
	// Private
	_crsRlFrFilterProcRules: THashedStringList;
	_crsInitedCacheSystemRuleResultForDP: Boolean;

{Initialize the unit}
procedure init();
begin

	// Setup
	INNRProcessing.cleanup();
	cleanup();
	CSPluginSystem.cleanupCache();
		
	_crsRlFrFilterProcRules := THashedStringList.Create;
	customProcRuleSets := THashedStringList.Create;
	customProcRuleSetCrc32s := THashedStringList.Create;
	crsModifiedRuleSets := TStringList.Create;
	crsRuleSetIniFiles := THashedStringList.Create;
	crsModBaseNameToFullName := THashedStringList.Create;
	INNRProcessing.init();
	
	// Load rules
	_loadIniFiles();
end;

{Load rules from ini files}
procedure _loadIniFiles();
var
	modBaseName, iniPath, iniPath2, sFileName: String;
	lstPrcTasks: TStringList;
	i,taskIndex: Integer;
begin	

	// Load main rules
	iniPath := sComplexSorterBasePath+'Rules (Default)\rules-processing.ini';
	
	_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_MAIN_RULES, 'main processing rules');

	// Load user rules
	iniPath := sComplexSorterBasePath+'Rules (User)\rules-processing.ini';
	if FileExists(iniPath) then
		_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_USER_RULES, 'user processing rules')
	else
		AddMessage('No custom user processing ruleset.');

	// Using all files available for processing rules lookup
	for i := 0 to FileCount - 2 do begin
		sFileName := GetFileName(FileByLoadOrder(i));
		modBaseName := getBaseESPName(sFileName);
		
		ProgressGUI.setProgressPercentCurrentStep( i / FileCount * 50 );
		
		// Save basename2fullname index for later use 
		crsModBaseNameToFullName.Values[modBaseName] := sFileName;
		
		// Search main rules for mod
		iniPath := sComplexSorterBasePath+'Rules (Mods)\'+modBaseName+'.ini';
		iniPath2 := sComplexSorterFo4DataPath+'Rules (Mods)\'+modBaseName+'.ini';
		
		if FileExists(iniPath) and FileExists(iniPath2) then 
			AddMessage('Info: Conflicting ini rules files:'+#10#13+' '+iniPath+' (IGNORED)'+#10#13+' '+iniPath2+' (USED)');
			
		if FileExists(iniPath2) then 
			iniPath := iniPath2;
			
		if FileExists(iniPath) then
			_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_MOD_RULES+modBaseName, 'main processing rules for mod '+modBaseName);

		// Search user rules for mod
		iniPath := sComplexSorterBasePath+'Rules (User)\'+modBaseName+'.ini';
		if FileExists(iniPath) then
			_readRuleSetFromINI(iniPath, RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName, 'user processing rules for mod '+modBaseName);
		
		end;
		
	// Search rules in plugins - Just call the rules getter which adds the rules to the registry
	// This ensure that the cache storage is created in case the rule will be used
	lstPrcTasks := Tasks.getProcessingActiveTasks();
	
	ProgressGUI.setProgressPercentCurrentStep( 60 );
	for taskIndex := 0 to lstPrcTasks.Count - 1 do
		for i := 0 to lstUseRecordTypes.Count - 1 do begin	
			//ProgressGUI.setProgressPercentCurrentStep( 60 + (taskIndex*lstUseRecordTypes.Count+i*2) / (lstUseRecordTypes.Count*2*lstPrcTasks.Count) * 40 );
			CSPluginSystem.getPluginRuleSets(lstPrcTasks.Names[taskIndex], 'PluginRulesBeforeAll', 'prefilter:'+lstUseRecordTypes[i]);
			CSPluginSystem.getPluginRuleSets(lstPrcTasks.Names[taskIndex], 'PluginRulesBeforeMain', 'prefilter:'+lstUseRecordTypes[i]);
			//ProgressGUI.setProgressPercentCurrentStep( 60 + (taskIndex*lstUseRecordTypes.Count+i*2+1) / (lstUseRecordTypes.Count*2*lstPrcTasks.Count) * 40 );
			CSPluginSystem.getPluginRuleSets(lstPrcTasks.Names[taskIndex], 'PluginRulesBeforeAll', lstUseRecordTypes[i]);
			CSPluginSystem.getPluginRuleSets(lstPrcTasks.Names[taskIndex], 'PluginRulesBeforeMain', lstUseRecordTypes[i]);
			end;

	// Read INNR rules by plugins
	ProgressGUI.setProgressPercentCurrentStep( 90 );
	CSPluginSystem.getInnrRulesByPlugins();
	
end;

{Reads a ruleset from a ini file. Then add it to customProcRuleSets}
procedure _readRuleSetFromINI(iniPath,ruleSetIdentifier:String;humanReadableName:String);
var
	iniFile: TIniFile;
	j,sumRulesets, sumRulesCnt, sumDynNames,sumInnrScripts: Integer;
	sections,sectionProcRules: TStringList;
	sectionName, taskIdent, tmpStr: String;
begin
	try
	
	// Save file name
	crsRuleSetIniFiles.Values[ruleSetIdentifier] := iniPath;
	
	// Init
	iniFile := TIniFile.Create(iniPath);
	sections := TStringList.Create;
	sectionProcRules := TStringList.Create;
	
	// Read sections
	iniFile.ReadSections(sections);
	if customProcRuleSets.indexOf(ruleSetIdentifier) > -1 then
		AddMessage('Error: Rule set main ident "'+ruleSetIdentifier+'" is not unique!');
	

	for j := 0 to sections.Count -1 do begin
		sectionName := sections[j];
		iniFile.ReadSectionValues(sectionName, sectionProcRules);
		if Pos('INNR_RULES:',sectionName) = 1 then begin // INNR rules for dynamic naming system
			INNRProcessing.storeModNamingRules(Copy(sectionName, Length('INNR_RULES:')+1,200),sectionProcRules);
			Inc(sumDynNames);
			end
		else if Pos('INNR_SCRIPT:',sectionName) = 1 then begin // INNR scripts
			INNRProcessing.storeInnrScript(Copy(sectionName, Length('INNR_SCRIPT:')+1,200),helper.loadIniSectionRaw(iniPath,sectionName),iniPath);
			Inc(sumInnrScripts);
			end
		else begin
			// Adding to collection
			taskIdent := 'ItemSorterTags';
			if BeginsWithExtract('TASK=',sectionName,tmpStr) then begin 
				if not SplitSimple(':',tmpStr,tmpStr,sectionName) then
					continue;
				end;
			crsRuleSetIniFiles.Values[taskIdent+ruleSetIdentifier] := iniPath;
				
			sumRulesCnt := sumRulesCnt + addProcessingRuleSetSection(taskIdent, ruleSetIdentifier, sectionName, sectionProcRules);
			sumRulesets := sumRulesets + 1;
			end;
		end;
		
	finally
		_printLogEntryForIni(humanReadableName,StringReplace(iniPath,sComplexSorterBasePath,'',[rfReplaceAll]),sumRulesets, sumRulesCnt,sumDynNames,sumInnrScripts);

		// Cleanup
		FreeAndNil(iniFile);
		FreeAndNil(sections);
		FreeAndNil(sectionProcRules);
	end;
end;

{Prints nice log message while reading inis}
procedure _printLogEntryForIni(name,baseFilename:String;sumRulesets, sumRulesCnt,sumDynNames,sumInnrScripts:Integer);
var msg: String;
begin
	msg := '';
	if ( sumRulesets > 0 ) or ( sumRulesCnt > 0 ) then 
		msg := msg + 'Added '+IntToStr(sumRulesets)+' rulesets containing '+IntToStr(sumRulesCnt)+' rules. ';
	if sumDynNames > 0 then 
		msg := msg + 'Added '+IntToStr(sumDynNames)+' dyn. name sections. ';
	if sumInnrScripts > 0 then 
		msg := msg + 'Added '+IntToStr(sumInnrScripts)+' INNR scripts. ';
	if msg = '' then 
		msg := 'Loading '+name+': (empty).'+ ' File: '+baseFilename+''
	else
		msg := 'Loading '+name+': ' + msg + ' File: '+baseFilename+'';
	AddMessage( msg );
end;
	


{Returns a combined array of rule sets applying to for record rec}
function getProccessingRuleSetsArray(taskIdent, prefixRecordType,recordType,sourceESPFilesStr:String):TStringList;
var
	i,index: Integer;
	procRuleSets, sourceESPFiles: TStringList;
	modBaseName: String;
	intCacheKey, rsSubIdent, rsAllIdent: String;
begin

	// Identify record sources
	rsSubIdent := prefixRecordType + recordType;
	
	// Cache usable?
	intCacheKey := taskIdent + '.' + sourceESPFilesStr + '.' + rsSubIdent;
	index := _crsRlFrFilterProcRules.indexOf(intCacheKey);
	if index > -1 then begin
		Result := _crsRlFrFilterProcRules.Objects[index];
		Exit;
		end;
	
	// Create new list
	Result := TStringList.Create;
	_crsRlFrFilterProcRules.addObject(intCacheKey,Result);
	rsAllIdent := prefixRecordType + 'ALL';
	
	// Go through each of the records source files
	sourceESPFiles := TStringList.Create;
	sourceESPFiles.StrictDelimiter := True;
	sourceESPFiles.CommaText := sourceESPFilesStr;

	if sourceESPFilesStr= '' then 
		AddMessage('WARNING: Missing source files index for: '+ShortName(pDR_record));

	// Add user mod rules for specific mod esp files
	for i := 0 to sourceESPFiles.Count - 1 do begin 
		modBaseName := getBaseESPName(sourceESPFiles[i]);
		_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName, rsSubIdent);
		_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_USER_MOD_RULES+modBaseName, rsAllIdent);
		end;

	// Add Plugin BEFORE ALL rules
	procRuleSets := CSPluginSystem.getPluginRuleSets(taskIdent, 'PluginRulesBeforeAll', rsSubIdent);
	for i:= 0 to procRuleSets.Count - 1 do
		Result.addObject(procRuleSets[i], procRuleSets.Objects[i]);
		
	// Default mod rules for mods/special esp files
	for i := 0 to sourceESPFiles.Count - 1 do begin 
		modBaseName := getBaseESPName(sourceESPFiles[i]);
		_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_MOD_RULES+modBaseName, rsSubIdent);
		_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_MOD_RULES+modBaseName, rsAllIdent);		
		end;
			
	sourceESPFiles.Free;
	
	// User processing rules
	_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_USER_RULES, rsSubIdent);
	_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_USER_RULES, rsAllIdent);
	
	// Add Plugin BEFORE MAIN rules
	procRuleSets := CSPluginSystem.getPluginRuleSets(taskIdent, 'PluginRulesBeforeMain', rsSubIdent);
	for i:= 0 to procRuleSets.Count - 1 do
		Result.addObject(procRuleSets[i], procRuleSets.Objects[i]);
	
	// Main processing rules
	_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_MAIN_RULES, rsSubIdent);
	_helperAddRulesetIfAvailable(Result, taskIdent, RULESETS_IDENTIFIER_MAIN_RULES, rsAllIdent);
	
	// AddMessage('Created list for '+intCacheKey+' containing '+IntToStr(Result.Count)+ ' rule sets: '+Result.CommaText);
end;

{helper: Adds the specified rules to the list, if those are available}
procedure _helperAddRulesetIfAvailable(var targetList:TStringList;const taskIdent,ruleSetIdentifier, sectionName: String);
var
	procRuleSet: TStringList;
begin
	procRuleSet := getProcessingRuleSetSection(taskIdent,ruleSetIdentifier,sectionName);
	if Assigned(procRuleSet) then
		if procRuleSet.Count > 0 then
			targetList.addObject({procRuleSetFullQualName := }taskIdent + ruleSetIdentifier+'>'+sectionName, procRuleSet);
end;


{Adds a new proc. rule set to the rules collection
	The input list should have ini format like from TIniFile.ReadSectionValues
	Returns the count of rules
	ruleSetIdentifier - sth like  MAIN_RULES, USER_MOD_RULES:DLCRobot or PLUGIN_RULES:PluginRulesBeforeMain:cpp_radioTags
	sectionName - sth like ALCH, WEAP or prefilter:MISC
	}
function addProcessingRuleSetSection(taskIdent,ruleSetIdentifier,sectionName:String;sectionProcRules:TStringList):Integer;
var
	parsedIniSection, sectionsOfRuleSet, sectionCacheCur, sectionCacheNew: TStringList;
	tmpPath, procRuleSetFullQualName: String;
	ruleSetIndex: Integer;
begin
	tmpPath := sComplexSorterBasePath+'cache\tempcrc32.ini';

	// Add unknown tasks
	if not Tasks.taskExists(taskIdent) then
		Tasks.registerTask(taskIdent, taskIdent);
		
	// Determine location to store
	ruleSetIndex := customProcRuleSets.indexOf(taskIdent + ruleSetIdentifier);
	
	// Creating new ruleset?
	if ruleSetIndex = -1 then
		ruleSetIndex := customProcRuleSets.addObject(taskIdent + ruleSetIdentifier,TStringList.Create);

	// Adding to (now) existing ruleset
	sectionsOfRuleSet := customProcRuleSets.Objects[ruleSetIndex];
		
	// Parse ini
	parsedIniSection := _preparseIniSectionRules(sectionProcRules, taskIdent + ruleSetIdentifier, sectionName);
	sectionsOfRuleSet.addObject(sectionName, parsedIniSection);
	
	// Store crc32 of ruleset
	sectionProcRules.SaveToFile(tmpPath);
	procRuleSetFullQualName := taskIdent + ruleSetIdentifier+'>'+sectionName;
	if customProcRuleSetCrc32s.values[procRuleSetFullQualName] <> '' then 
		AddMessage('WARNING: CRC32 entry "'+procRuleSetFullQualName+'" already exists!');
	customProcRuleSetCrc32s.values[procRuleSetFullQualName] := IntToStr(wbCRC32File(tmpPath));
	// AddMessage('set crc32 '+procRuleSetFullQualName+' = ' + customProcRuleSetCrc32s.values[procRuleSetFullQualName]);
	Result := parsedIniSection.Count;
	
	// On the fly?
	if _crsInitedCacheSystemRuleResultForDP then // Create and validate on the fly 
		if Cache.getEntrySetLevelTwo('dynamicPatcherRuleSetResults',procRuleSetFullQualName, true, sectionCacheCur, sectionCacheNew) then
			cache_validateRuleSetSectionCache(procRuleSetFullQualName,sectionCacheCur, sectionCacheNew);

	// Cleanup
	if FileExists(tmpPath) then
		DeleteFile(tmpPath);
		
end;


{Returns custom processing rules for a record type}
function getProcessingRuleSetSection(taskIdent,ruleSetIdentifier, recordType:String):TStringList;
var
	ruleSetIndex, recordTypeIndex: Integer;
begin
	Result := nil;
	if not Assigned(customProcRuleSets) then
		Exit;
	//taskIdent := 'tags:';
	//ruleSetIdentifier := taskIdent + ':' + ruleSetIdentifier;
	ruleSetIndex := customProcRuleSets.indexOf(taskIdent + ruleSetIdentifier);
	if ruleSetIndex = -1 then
		Exit;
	recordTypeIndex := customProcRuleSets.Objects[ruleSetIndex].indexOf(recordType);
	if recordTypeIndex = -1 then
		Exit;
	Result := customProcRuleSets.Objects[ruleSetIndex].Objects[recordTypeIndex];
end;



// Creates a ruleset from a ini-Section. Pre-parses the contained rules for faster processing
function _preparseIniSectionRules(sectionProcRules: THashedStringList;const ruleSetIdentifier:String;const sectionName:String):TStringList;
var
	i,j: Integer;
	tmpLst, parsedCondition, conditionPacks,conditionPack,quickCheckPack,testDuplicateNames: TStringList;
	ruleConditions, ruleTagIdent: String;
begin
	
	// Create ruleset
	Result := TStringList.Create;
	testDuplicateNames := TStringList.Create;
	// Read section lines into Rules
	for i := 0 to sectionProcRules.Count - 1 do begin
		ruleConditions := sectionProcRules.Names[i];
		if testDuplicateNames.indexOf(ruleConditions) > -1 then
			AddMessage('WARNING: Duplicate rule conditions found: "'+ruleConditions+'". Because of the nature of Pascal''s INI file reader, this values couldn''t read!')
		else
			testDuplicateNames.add(ruleConditions);
		ruleTagIdent := sectionProcRules.ValueFromIndex[i];
		if Pos(',',ruleTagIdent) > 0 then
			ruleTagIdent := PregReplace('\s*,\s*',',',ruleTagIdent);

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
			
			// Slot 2: Add quickCheckPack?
			quickCheckPack := DynamicPatcher.createQuickCheckPack(parsedCondition);
			if Assigned(quickCheckPack) then
				conditionPack.addObject('quickCheckPack',quickCheckPack);
				
			// add to cpacks
			//conditionPacks.addObject('cpack',conditionPack);
			conditionPacks.addObject(Copy(tmpLst[j],2,80),conditionPack);
			
			if pDR_gatherStats then
				conditionPacks.Strings[j] := '('+ruleSetIdentifier+'>'+sectionName+') - Rule #'+IntToStr(i+1)+' '+ruleConditions + ' -> '+ruleTagIdent;
			
			end;
		tmpLst.Free;
		end;
	testDuplicateNames.Free;
	
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


{Cleanup a rule set}
procedure _cleanupPreparsedProcessingRuleSet(processingRuleSet:THashedStringList);
var
	i,j:Integer;
	conditionPack: TStringList;
begin
	if not Assigned(processingRuleSet) then
		Exit;
	for i := processingRuleSet.Count - 1 downto 0 do begin
		for j := processingRuleSet.Objects[i].Count - 1 downto 0 do begin
			conditionPack := processingRuleSet.Objects[i].Objects[j];
			cleanupConditionPack(conditionPack);
			end;
		processingRuleSet.Objects[i].Free();
		end
	processingRuleSet.Free;
end;


{Cleaning up a single condition pack}
procedure cleanupConditionPack(conditionPack:TStringList);
begin
	conditionPack.Objects[1].Free;
	// Clean quickCheckPack
	if conditionPack.Count > 2 then
		DynamicPatcher.cleanupQuickCheckPack(conditionPack.Objects[2]);
	conditionPack.Free;
end;


{Garanties the existance of cache object lookup lists - Creates all necessary things for the rule result caching system}
procedure initPdrCacheForExistingRuleSets();
var
	i, j: Integer;
	sectionsOfRuleSet: TStringList;
	procRuleSetFullQualName, sectionName: String;
	sectionCacheCur, sectionCacheNew: TStringList;
begin
	for i:= 0 to customProcRuleSets.Count - 1 do begin
		sectionsOfRuleSet := customProcRuleSets.Objects[i];
		for j:= 0 to sectionsOfRuleSet.Count - 1 do begin
			sectionName := sectionsOfRuleSet.Strings[j];
			procRuleSetFullQualName := customProcRuleSets[i] + '>' + sectionName;			
			// Create and validate
			if Cache.getEntrySetLevelTwo('dynamicPatcherRuleSetResults',procRuleSetFullQualName, true, sectionCacheCur, sectionCacheNew) then
				// Validate section cache
				cache_validateRuleSetSectionCache(procRuleSetFullQualName,sectionCacheCur, sectionCacheNew);
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


{Validates a ruleset section cache. Returns true if cache is invalidated}
function cache_validateRuleSetSectionCache(const procRuleSetFullQualName:String;sectionCacheCur, sectionCacheNew:TStringList):Boolean;
var
	rssChecksumStr, taints: String;
begin
			
	// Must contains: RULESET_TAINTS, VALIDATION_STR - Add to both list if not
	if sectionCacheCur.indexOfName('RULESET_TAINTS') = -1 then
		_cacheResetRuleSetSectionCache(sectionCacheCur, sectionCacheNew)
	else if sectionCacheCur.indexOfName('VALIDATION_STR') = -1 then
		_cacheResetRuleSetSectionCache(sectionCacheCur, sectionCacheNew);

	rssChecksumStr := customProcRuleSetCrc32s.values[procRuleSetFullQualName];
	taints := sectionCacheNew.values['RULESET_TAINTS'];
	// AddMessage('RSSVS ('+procRuleSetFullQualName+'): '+taints);
	if taints <> 'NONE' then
		cache_validateProcessTaints(taints, rssChecksumStr);
		
	// Invalidate cache
	if (rssChecksumStr = 'INVALIDATE') or (rssChecksumStr <> sectionCacheCur.values['VALIDATION_STR'] ) then begin
		Result := true;
		_cacheResetRuleSetSectionCache(sectionCacheCur, sectionCacheNew);
		// Add taints again
		if taints <> '' then
			sectionCacheNew.values['RULESET_TAINTS'] := taints;
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
			if not CSPluginSystem.addPluginCacheValidationStr(Copy(tmpStr,1,iPos-1),Copy(tmpStr,iPos+1,length(tmpStr)-iPos),rssChecksumStr) then begin
				rssChecksumStr := 'INVALIDATE'; // TODO: Add typed NOT_CACHABLE
				break;
				end;
			end
		else if BeginsWithExtract('TAINT:PluginSetting:',taint,tmpStr) then begin
			iPos := Pos(':',tmpStr);
			rssChecksumStr := rssChecksumStr + '|plgSet:'+tmpStr+':'+
				CSPluginSystem.getPluginUserSetting(Copy(tmpStr,1,iPos-1),Copy(tmpStr,iPos+1,length(tmpStr)-iPos));
			end
		else if taint = 'TAINT:FindCustomTag' then
			rssChecksumStr := rssChecksumStr + '|innrCRC-'+IntToStr(wbCRC32File(getDynamicNamingRulesIniPath()))
		else begin
			AddMessage('Unknown ruleset cache taint "'+taint+'". Invalidating cache.');
			rssChecksumStr := 'INVALIDATE';
			break;
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
				_cleanupPreparsedProcessingRuleSet(customProcRuleSets.Objects[i].Objects[j]);
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