{
	M8r98a4f2s Complex Item Sorter for FallUI - Dynamic Patcher module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Used for dynamic patching
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit DynamicPatcher;

var
	// processing and performance cache vars
	pDR_record: IInterface;

	_pDR_quickFlagSetFor: String;
	pDR_gatherStats: Boolean;
	
	pDR_keywords,
	_pDR_effects,
	_pDR_fileNameQuickCache,
	_pDR_fileNameQuick2Cache,
	_pDR_statUsedRules: THashedStringList;
	
	_pDR_bodyPartFlagsNotFace,
	_pDR_customVarValues,
	_pDR_customVarIsset,
	_pDR_conditionsChecked,
	_pDR_quickCheckPack: TStringList;
	
	_pDR_editValue,
	_pDR_elmOperator,
	pDR_fullName,
	pDR_recordSrcFileName:String;

	_pDR_statRemoved,
	_pDR_statWritten,
	_pDR_statRemovedAll,
	_pDR_statWrittenAll: Integer;
	
	// Caching system
	_pDR_cacheCC_enabled,
	_pDR_cacheRR_enabled,
	_pDR_cacheRR_curEntryIsValid,
	_pDR_cacheCC_modified: Boolean;

	_pDR_cacheFileCondOrig,
	pDR_cacheLoadOrderFormId,
	pDR_cacheValidationStr:String;
		
	_pDR_cacheRecFiles,
	_pDR_cacheCC_StoreCur: THashedStringList;
	_pDR_cacheCurrentRuleSetTaints: TStringList;

	// Cache stats
	_pDR_cacheInvalidationsCC: Integer;
	_pDR_cacheInvalidationsRR: Integer;
	
const
	// "Condition pack" index offsets
	CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR = 0;
	CONDITION_PACK_INDEX_STR_RULE_RAW_STRING = 1;
	CONDITION_PACK_INDEX_OBJ_PARSED_RULES = 1;
	
	// "Quick check pack" values
	QUICK_CHECK_PACK_FLAG_POS0_SPECIAL_VALUE_TRUE = '1';
	QUICK_CHECK_PACK_FLAG_POS3_IS_STR_COMPARE = '1';
	QUICK_CHECK_PACK_FLAG_POS4_SPECIAL_COMPVALUE_TRUE = '1';
	
	
implementation

{Initialize the unit}
procedure init();
begin
	
	_pDR_statWrittenAll := 0;
	_pDR_statRemovedAll := 0;
	
	_pDR_cacheCC_enabled := getSettingsBoolean('config.bUseCacheConditionCheck');
	_pDR_cacheRR_enabled := getSettingsBoolean('config.bUseCacheProcSetResult');
end;

{Creates a package for fast checking a condition}
function createQuickCheckPack(parsedRules:TStringList):TStringList;
var
	elmIdent, elmOperator, conditionValue,tmpStr,pluginId,settingName, ruleCacheTaint: String;
begin
	Result := nil;
	// Produce QuickCheckPack
	if (parsedRules.Count = 3) then begin
		elmIdent := parsedRules[0];
		elmOperator := parsedRules[1];
		conditionValue := parsedRules[2];
		
		// Adjust one time in preparsing process
		if elmIdent = 'BP' then
			parsedRules[0] := 'BOD2 - Biped Body Template\First Person Flags';
		
		// Pre-resolve plugin settings as conditionValue
		if BeginsWithExtract('SPECIAL:PluginSetting:',conditionValue,tmpStr) then
			if SplitSimple(':',tmpStr,pluginId,settingName) then begin
				conditionValue := CSPluginSystem.getPluginUserSetting(pluginId,settingName);
				// Add Taint
				ruleCacheTaint := 'TAINT:PluginSetting:'+tmpStr;
				end;
		
		
		Result := TStringList.Create;
		// Slot 0: Has special identifer
		if (elmIdent = 'BPNotFace:flagsCount') or (elmIdent = 'BP:flagsCount') {or (elmIdent = 'INRD:link:EDID')}
			or (Pos('SPECIAL:',elmIdent)=1) or (Pos(':link:',elmIdent)>0) or (Pos(':keywordsCount',elmIdent)>0) then
			Result.add(QUICK_CHECK_PACK_FLAG_POS0_SPECIAL_VALUE_TRUE)
		else Result.add('0');
		
		// Slot 1: Values
		//if Pos('|',conditionValue) > 0 then begin
		Result.addObject('vals', Split('|',conditionValue)); // Intended to unfree
		
		// Slot 2: Determine comp func type
		if elmIdent = 'KEYWORDS' then begin
			Result.add('201');
			if ( elmOperator <> 'contains') and (elmOperator <> 'equals') then
				AddMessage('WARNING: Unsupported operator for KEYWORDS element: '+elmOperator );
			end
		else if elmIdent = 'EFFECTS' then begin
			Result.add('202');
			if ( elmOperator <> 'contains') and (elmOperator <> 'equals') then
				AddMessage('WARNING: Unsupported operator for EFFECTS element: '+elmOperator );
			end
		else
			Result.add('200');

		// Slot 3: Near type of comparison
		if (elmOperator = 'contains') or (elmOperator = 'beginsWith') or (elmOperator = 'endsWith') or (elmOperator = 'equals') then
			Result.add(QUICK_CHECK_PACK_FLAG_POS3_IS_STR_COMPARE)
		else
			Result.add('0');
		
		// Slot 4: conditionValue has special identifer
		if (Pos('SPECIAL:',conditionValue)=1) then
			Result.add(QUICK_CHECK_PACK_FLAG_POS4_SPECIAL_COMPVALUE_TRUE)
		else Result.add('0');
		
		// Slot 5: Rule taint
		Result.add(ruleCacheTaint);
		end;
end;


{Cleanup quickCheckPack}
procedure cleanupQuickCheckPack(quickCheckPack:TStringList);
begin
	quickCheckPack.Objects[1].Free;
	quickCheckPack.Free;
end;


{Get a filename with caching}
function getFileNameQuick1():String;
var
	loadOrderNrStr: String;
begin
	// Only masters are recognizable by load order 
	loadOrderNrStr := Copy(pDR_cacheLoadOrderFormId,1,2);
	if (loadOrderNrStr <> 'FE') and (loadOrderNrStr <> 'FF') then begin
		Result := _pDR_fileNameQuickCache.values[loadOrderNrStr];
		if Result <> '' then
			Exit;
		end;
	Result := GetFileName(GetFile(pDR_record));
	_pDR_fileNameQuickCache.values[loadOrderNrStr] := Result;	
end;


{Returns the source file name for the current record from cached values}
function _getFileNameQuick2():String;
begin
	
	if globalModificationsAllowed then begin // Records are now all indexed. use it. 
		// Use stored source file 
		if _pDR_fileNameQuick2Cache.indexOfName(pDR_cacheLoadOrderFormId) = -1 then 
			AddMessage('Unknown record source for '+pDR_cacheLoadOrderFormId+'!')
		else 
			Result := _pDR_fileNameQuick2Cache.values[pDR_cacheLoadOrderFormId];
		Exit;
		end
	else if isMaster( pDR_record ) then begin
			Result := DynamicPatcher.getFileNameQuick1();
			// Store source file for later use
			_pDR_fileNameQuick2Cache.Append(pDR_cacheLoadOrderFormId+'='+Result);
			end
		else begin
			// Result := GetFileName(GetFile(MasterOrSelf(pDR_record)));
			// Allow overrides		
			// We just need the latest override, as mods normally don't get merged or have the merge in name
			Result := GetFileName(GetFile(pDR_record));
			// Store source file for later use
			_pDR_fileNameQuick2Cache.Append(pDR_cacheLoadOrderFormId+'='+Result);
			end;	
end;


{Process the dynamic rules set for one record type}
procedure patchDynamicRules(recordType:String);
var
	rec: IInterface;
	saveRecord, condMatch: Boolean;
	i,j,l,taskIndex, statAll, n,recordsBegCnt: Integer;
	sTag, str, sTagTargetPath, modBaseName, taskIdent: String;
	records,procRuleSets, afterMatchPerTaskRules, afterMatchRules, amrProcRuleSetIdent, amrProcRuleSetSection: TStringList;
	lstPrcTasks: TStringList;
begin
	if recordsIndex.indexOf(recordType) = -1 then
		Exit;
	if bUserRequestAbort then
		Exit;
	measureTimeStart(1);
		
	// Setup
	initRecordProcessing();
	lstPrcTasks := Tasks.getProcessingActiveTasks();
	statAll := 0;
	_pDR_statWritten := 0;
	_pDR_statRemoved := 0;
	
	
	// Pre-fetch AfterMatchRules
	afterMatchPerTaskRules := TStringList.Create;
	for taskIndex := 0 to lstPrcTasks.Count - 1 do begin
		taskIdent := lstPrcTasks.Names[taskIndex];
		afterMatchPerTaskRules.AddObject(taskIdent,CSPluginSystem.getPluginRuleSets(taskIdent,'PluginRulesAfterMatch',recordType));
		end;
		
	// Target path
	if recordType = 'LVLI' then
		sTagTargetPath := 'ONAM' // 'ONAM - Override Name'
	else
		sTagTargetPath := 'FULL';// 'FULL - Name'
			

	// Get records of type
	records := recordsIndex.Objects[recordsIndex.indexOf(recordType)];
	recordsBegCnt := records.Count;
	n := 0;

	for l := records.Count-1 downto 0 do begin
		try

		// Nice progress
		if n = 50 then begin
			ProgressGUI.setProgressPercentCurrentStep( (recordsBegCnt-l)*100/recordsBegCnt);
			updateCacheStatistics();
			n := 0;
			end;
		Inc(n);

		// Allow abort
		if bUserRequestAbort then
			Exit;
			
		// Process record
		rec := ObjectToElement(records[l]);
		saveRecord := false;
		startRecordProcessing(rec,recordType);
		
		// For each task 
		for taskIndex := 0 to lstPrcTasks.Count - 1 do begin
			// Record in task? 
			//if recordsInTasks.Objects[taskIndex].indexOf(IntToHex(FixedFormID(rec),8)) = -1 then begin
			if recordsInTasks.Objects[taskIndex].indexOf(IntToHex(GetLoadOrderFormID(rec) and $00FFFFFF,6)) = -1 then begin
				//AddMessage('Formid ' + IntToHex(FixedFormID(rec),8)+' ' + IntToHex(FixedFormID(rec),6)+' not in '+lstPrcTasks.Names[taskIndex]);
				continue;
				end;
				
			// Process record for this task
			sTag := '';
			taskIdent := lstPrcTasks.Names[taskIndex];
			afterMatchRules := afterMatchPerTaskRules.Objects[taskIndex];
			
			// Process custom mod rules
			procRuleSets := CustomRuleSets.getProccessingRuleSetsArray(taskIdent,'',recordType,recordsSourceFiles.Values[pDR_cacheLoadOrderFormId]);
			
			// Process all rulesets
			for j:= 0 to procRuleSets.Count - 1 do
				if processRuleset(procRuleSets[j],procRuleSets.Objects[j],saveRecord, sTag) then
					break;

			// IGNORED entry? deprecated, use ''
			if sTag = 'IGNORE' then begin
				// AddMessage('Usage if TagIdent=IGNORE is deprecated. Use empty string instead');
				sTag := ''; // TODO TEST?
				end;
				
		
			// Apply plugins of type pluginRecordModifier		
			for j := 0 to afterMatchRules.Count - 1 do 
				processRuleset(afterMatchRules[j],afterMatchRules.Objects[j],saveRecord,sTag);
				
			// Save?
			if sTag <> '' then begin
			
				// Special processing 1 of ARMO
				if recordType = 'ARMO' then 
					_processAfterRecordsTypeARMO1(rec, sTag, saveRecord);
				
				// Find final tag
				//__sTagIdent := sTag;
				if sTag <> '' then
					if not Assigned(tagNames.values[sTag]) then
						raise Exception.Create('TagIdent "'+sTag+'" have no entry in tags.ini.')
					else
						sTag := tagNames.values[sTag];

				// Special processing 2 of ARMO
				if recordType = 'ARMO' then 
					_processAfterRecordsTypeARMO2(rec, sTag, saveRecord);
					
				// Special processing of WEAP
				if recordType = 'WEAP' then 
					_processAfterRecordsTypeWEAP2(rec, sTag, saveRecord);
			
				// Save tag
				if sTag <> '' then
					if ElementExists(rec, sTagTargetPath) then
						_recordAddTagString(sTag, sTagTargetPath, rec, pDR_fullName, saveRecord);
					
				end;
				
			end; // end for each task

		// Write or not to write ...
		if not saveRecord then
			Remove(rec);
			
		// Stats
		Inc(statAll);
		if saveRecord then begin
			Inc(_pDR_statWritten);
			Inc(_pDR_statWrittenAll);
			end
		else begin
			Inc(_pDR_statRemoved);
			Inc(_pDR_statRemovedAll);
			end;
		
		// Exceptions
		except
			on E: Exception do
				AddMessage('Exception: ' + E.Message + ' | While processing '+recordType+' record '+ getElementEditValues(rec,'EDID') + ' (Form-ID: '+IntToHex(GetLoadOrderFormID(rec),8)+' )'
				+ ' Name: "' + getElementEditValues(rec,'FULL')+'"'
				);
			end;
		
		end;
		
	// Save last entry
	startRecordProcessing(nil,nil);
	
	// Summary
	updateCacheStatistics();
	AddMessage('Record type '+recordType+': '+IntToStr(records.Count)+' records processed'
			+ ' in '+measureTimeGetFormatted(1)+'     Results - Written: '+IntToStr(_pDR_statWritten)+'  Ignored: '+IntToStr(_pDR_statRemoved));
			
	if pDR_gatherStats then begin
		AddMessage('Rules usage statistics for record type '+recordType+': ');
		for i := 0 to _pDR_statUsedRules.Count -1 do
			AddMessage('  '+_pDR_statUsedRules.ValueFromIndex[i]+' x '+_pDR_statUsedRules.Names[i]);
		end;
		
	// Cleanup
	afterMatchPerTaskRules.Free;
end;

{Process a processing rule set. Returns true if a final TagIdent is found}
function processRuleset(const procRuleSetFullQualName:String;procRuleSetSection:TStringList;var saveRecord:Boolean;var sTag:String):Boolean;
var
	match, madeModifications, bEndRuleset, bFinalRule: Boolean;
	i,j:Integer;
	ruleConditionsLst, conditionPack, tmpLst: TStringList;
	sTagIdent, conditionString, conditionResult, cacheEntry, procRuleSetValStr, newCacheEntry: String;
begin

	// Safety first
	if not Assigned(procRuleSetSection) then begin 
		AddMessage('Warning: Rule set '+procRuleSetFullQualName+' contains a invalid procRuleSetSection list.');
		Exit;
		end;
	
	// Cache?
	if _pDR_cacheRR_enabled then begin
		// Checksum
		procRuleSetValStr := customProcRuleSetCrc32s.values[procRuleSetFullQualName] + ';' + pDR_cacheValidationStr + #9;
		// Cache available?
		cacheEntry := Cache.getEntryLevelTwo('dynamicPatcherRuleSetResults', procRuleSetFullQualName, pDR_cacheLoadOrderFormId);
		// Valid and empty list 
		if cacheEntry = procRuleSetValStr then 
			Exit;
		
		if cacheEntry <> '' then begin
			_pDR_cacheRR_curEntryIsValid := true;
			Result := _processRulesetUseCacheEntry(cacheEntry,procRuleSetValStr,saveRecord,sTag);
			// Valid?
			if _pDR_cacheRR_curEntryIsValid then
				Exit;

			// AddMessage('Found invalid cache: ruleident='+procRuleSetFullQualName+' crc='+procRuleSetValStr);
			// Reset flag for next entry
			end;
		// Clear cache
		newCacheEntry := procRuleSetValStr;
		_pDR_cacheCurrentRuleSetTaints.Clear();
		end;
	
	// Stats
	if pDR_gatherStats then
		_prepareStatisticsForProcRuleSet(procRuleSetSection);
	
	tmpLst := TStringList.Create;
	tmpLst.StrictDelimiter := True;
	
	// Go through all rules of the ruleset
	for i := 0 to procRuleSetSection.Count - 1 do begin

		ruleConditionsLst := procRuleSetSection.Objects[i];
		// Check conditions
		if ruleConditionsLst.Count = 0 then
			continue;
			
		// Check every condition of the rule
		for j := 0 to ruleConditionsLst.Count - 1 do begin
			conditionPack := ruleConditionsLst.Objects[j];
			conditionString := conditionPack[CONDITION_PACK_INDEX_STR_RULE_RAW_STRING];
			conditionResult := _pDR_conditionsChecked.values[conditionString];
			if conditionResult = '' then begin
				conditionResult := _checkRuleConditionMatch(conditionPack,conditionPack.Objects[CONDITION_PACK_INDEX_OBJ_PARSED_RULES], i, sTag);
				_pDR_conditionsChecked.values[conditionString] := conditionResult;
				_pDR_cacheCC_modified := true;
				end;

			match := conditionResult = conditionPack[CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR];
			if not match then
				break; // To BREAK 2
			end;

		// Rule mismatch (break 2 not available in pascal ...)
		if not match then
			continue; // BREAK 2

		// Statistics?
		if pDR_gatherStats then
			_pDR_statUsedRules.values[ruleConditionsLst.Strings[j]] := IntToStr(
				StrToInt(_pDR_statUsedRules.values[ruleConditionsLst.Strings[j]]) + 1 );
		
		// Rule match, final one?
		sTagIdent := procRuleSetSection.Strings[i];
		
		// Special tag
		if Pos('SPECIAL:', sTagIdent) > 0 then begin
			tmpLst.CommaText := sTagIdent;
			for j := 0 to tmpLst.Count-1 do begin
				sTagIdent := tmpLst[j]; // var im param mag arrays jarnich
				if not _processSpecialTagIdent(sTagIdent, sTag, saveRecord, madeModifications, bEndRuleset) then begin
					bFinalRule := true;
					break; // Go to final rule!
					end
				else begin
					// For custom record save final sTag (in sTagIdent) directly ...
					if madeModifications then
						newCacheEntry := newCacheEntry + #9 + sTagIdent;
					if bEndRuleset then 
						break;
					continue;
					end;
				end;
			if bEndRuleset then 
				break;
			if not bFinalRule then 
				continue;
			end;
		
		// Cache
		newCacheEntry := newCacheEntry + #9 + sTagIdent;
				
		// Final rule
		Result := true; // true = final rule, no further processing of other rulesets
		
		// Special rule: Ignore record entry
		if sTagIdent = 'IGNORE' then
			saveRecord := false;
		
		// Set tag
		sTag := sTagIdent;
		
		// End for
		break;
		end;

	// Save result to cache
	if _pDR_cacheRR_enabled then
		_processRulesetSaveCacheEntry(procRuleSetFullQualName,pDR_cacheLoadOrderFormId,newCacheEntry);
		
	// Cleanup
	tmpLst.Free;
end;



{Tries to use a cached result set}
function _processRulesetUseCacheEntry(cacheEntry:String;const procRuleSetValStr:String;var saveRecord:Boolean;var sTag:String):Boolean;
var
	i,crc32PosEnd: Integer;
	tmpStr: String;
	tmpLst: TStringList;
begin
	
	// Validation of cache
	crc32PosEnd := Pos(#9,cacheEntry);
	if (crc32PosEnd = 0) or (Copy(cacheEntry,1,crc32PosEnd) <> procRuleSetValStr ) then begin
		_pDR_cacheRR_curEntryIsValid := false;
		Exit;
		end;

	// Pos of first existing entry in list
	cacheEntry := Copy(cacheEntry,crc32PosEnd+2,10000);
		
	// Speed optimation: Single Entry without split and for
	if Pos(#9,cacheEntry) = 0 then begin
		tmpStr := cacheEntry;
		if Pos('SPECIAL:', tmpStr) = 1 then 
			_processSpecialTagIdent(tmpStr, sTag, saveRecord,nil,nil)
		else begin
			Result := true;
			sTag := tmpStr;
			if sTag = 'IGNORE' then
				saveRecord := false;
			end;
		Exit;
		end;
		
	// Multi entry
	tmpLst := Split(#9,cacheEntry);
	for i := 0 to tmpLst.Count - 1 do begin
		tmpStr := tmpLst[i]; // Own variable because param in _processSpecialTagIdent is var
		if Pos('SPECIAL:', tmpStr) = 1 then 
			_processSpecialTagIdent(tmpStr, sTag, saveRecord,nil,nil)
		else begin
			Result := true;
			sTag := tmpStr;
			if sTag = 'IGNORE' then
				saveRecord := false;
			end;
		end;
	tmpLst.Free;
		
end;



{Write the RR cache }
procedure _processRulesetSaveCacheEntry(const procRuleSetFullQualName:String;const cacheIdent:String; newCacheEntry:String);
var i, taintIndex:Integer;
	storedTaints: String;
	sectionCacheCur, sectionCacheNew: TStringList;
begin
	if newCacheEntry = '' then
		newCacheEntry := 'INVALID';
		
	if not Cache.setEntryLevelTwo('dynamicPatcherRuleSetResults', procRuleSetFullQualName, cacheIdent, newCacheEntry, sectionCacheCur, sectionCacheNew) then begin
		// New head cache ?
		AddMessage('Info - Missing cache entry: ' + procRuleSetFullQualName);
		Exit;
		end;
	
	// Stats
	Inc(_pDR_cacheInvalidationsRR);
	
	// Validate that taint is stored by sublist
	if _pDR_cacheCurrentRuleSetTaints.Count = 0 then 
		Exit;

	// Add taint
	taintIndex := sectionCacheCur.IndexOfName('RULESET_TAINTS');
	storedTaints := sectionCacheNew.ValueFromIndex[taintIndex];
	// It must be available...
	for i := 0 to _pDR_cacheCurrentRuleSetTaints.Count - 1 do
		if ( Pos(_pDR_cacheCurrentRuleSetTaints.Names[i], storedTaints) = 0 ) then begin
			// Taint missing. add item
			storedTaints := storedTaints + ',' + _pDR_cacheCurrentRuleSetTaints.Names[i];
			sectionCacheNew.ValueFromIndex[taintIndex] := storedTaints;
			
			// In and revalidate section cache. if true cache was reset. Add entry again
			if CustomRuleSets.cache_validateRuleSetSectionCache(procRuleSetFullQualName,sectionCacheCur, sectionCacheNew) then 
				Cache.setEntryLevelTwo('dynamicPatcherRuleSetResults', procRuleSetFullQualName, cacheIdent, newCacheEntry, sectionCacheCur, sectionCacheNew);
			end;
end;


{Afterprocessing 1 for records of type ARMO}
procedure _processAfterRecordsTypeARMO1(rec:IInterface;var sTag:String;var saveRecord:Boolean);
begin
	// Armor or cloth?
	if not recordIsArmor(rec) then begin
		if Assigned(tagNames.values[sTag+'-clothes']) then
			sTag := sTag+'-clothes';
		end
	else if Assigned(tagNames.values[sTag+'-armor']) then
		sTag := sTag+'-armor';

	// Automatic injection of INNR keyword tags? 
	if getSettingsBoolean('config.bHeuristicInjectInnrKeywordTags') then
		if ElementExists(rec, 'INRD') and (GetElementEditValues(rec, 'INRD') <> '') then
			INNRProcessing.processAutomaticInnrTags(rec,sTag, saveRecord);	
		
end;

{Afterprocessing 2 for records of type ARMO}
procedure _processAfterRecordsTypeARMO2(rec:IInterface;var sTag:String;var saveRecord:Boolean);
begin
	// look for object templates - save if found
	if _processRecordsObjectTemplates(rec, sTag) then
		saveRecord := true;
end;

{Afterprocessing for records of type WEAP}
procedure _processAfterRecordsTypeWEAP2(rec:IInterface;var sTag:String;var saveRecord:Boolean);
begin
	// look for object templates - save if found
	if _processRecordsObjectTemplates(rec, sTag) then
		saveRecord := true;
		
	// Does a INRD entry exist? 
	if ElementExists(rec, 'INRD - Instance Naming') and (GetElementEditValues(rec, 'INRD - Instance Naming') <> '') then
		if INNRProcessing.patchWEAPWithNamingRules(rec) then begin
			sTag := ''; // Covered by INNR rules - not touching saveRecord
			Exit;
			end;

	// Not covered/No INRD, save direct.
	//saveRecord := true;
end;


{Initializes the record processing system}
procedure initRecordProcessing();
var
	i: Integer;
begin
	if not Assigned(_pDR_customVarValues) then
		_pDR_customVarValues := THashedStringList.Create
	else
		_pDR_customVarValues.Clear();
		
	if not Assigned(_pDR_customVarIsset) then
		_pDR_customVarIsset := THashedStringList.Create
	else
		_pDR_customVarIsset.Clear();
		
	if not Assigned(_pDR_conditionsChecked) then
		_pDR_conditionsChecked := THashedStringList.Create
	else
		_pDR_conditionsChecked.Clear();

	// Init cache system
	pDR_cacheLoadOrderFormId := '';
	_pDR_cacheRR_curEntryIsValid := true;
	if not Assigned(_pDR_cacheRecFiles) then
		_pDR_cacheRecFiles := THashedStringList.Create;
	if not Assigned(_pDR_fileNameQuickCache) then
		_pDR_fileNameQuickCache := THashedStringList.Create;
	if not Assigned(_pDR_fileNameQuick2Cache) then
		_pDR_fileNameQuick2Cache := THashedStringList.Create;
	if not Assigned(_pDR_statUsedRules) then
		_pDR_statUsedRules := TStringList.Create;
	if not Assigned(_pDR_cacheCurrentRuleSetTaints) then
		_pDR_cacheCurrentRuleSetTaints := TStringList.Create;
	
	// Init cache storages
	if _pDR_cacheRR_enabled then
		if not Cache.existsCache('dynamicPatcherRuleSetResults') then begin
			Cache.initBulkStorage('dynamicPatcherRuleSetResults');
			// Explode result cache for faster access
			Cache.initLevelTwoCache('dynamicPatcherRuleSetResults');			
			CustomRuleSets.initPdrCacheForExistingRuleSets();
			end;
			
	if _pDR_cacheCC_enabled then
		if not Cache.existsCache('conditionCheckCache') then begin
			Cache.initBulkStorage('conditionCheckCache');
			_pDR_cacheCC_StoreCur := Cache.getDirectAccessCachedEntriesList('conditionCheckCache');
			end;
	
end;

{Setup the record processing system for the next record}
procedure startRecordProcessing(rec:IInterface;const recordType:String);
var
	i,toInt: Integer;
begin
	// No record - End of processing
	if not Assigned(rec) then
		Exit;
		
	// Save cache of prev round
	if _pDR_cacheCC_enabled then
		if Assigned(pDR_cacheLoadOrderFormId) and Assigned(_pDR_conditionsChecked.values['cache_validation']) then
			if _pDR_cacheCC_modified then
				if _pDR_cacheFileCondOrig <> _pDR_conditionsChecked.CommaText then
					Cache.SetEntry('conditionCheckCache',pDR_cacheLoadOrderFormId,_pDR_conditionsChecked.CommaText);

	// Setup new record - clear before stuff
	if globalModificationsAllowed then
		mxPatchFile := getFile(rec);
	pDR_fullName := '';
	pDR_record := rec;
	_pDR_customVarValues.Clear();
	_pDR_customVarIsset.Clear();
	_pDR_conditionsChecked.Clear();
	
	_pDR_quickFlagSetFor := '';
	if Assigned(pDR_keywords) then begin
		pDR_keywords.Free;
		pDR_keywords := nil;
	end;
	if Assigned(_pDR_effects) then begin
		_pDR_effects.Free;
		_pDR_effects := nil;
	end;
	
	// Cache entry key - need for more than cache now 
	pDR_cacheLoadOrderFormId := IntToHex(GetLoadOrderFormID(rec),8);
	pDR_recordSrcFileName := _getFileNameQuick2();

	// Use any cache?
	if (not _pDR_cacheRR_enabled) and (not _pDR_cacheCC_enabled) and (not _ps_cache_enabled) then
		Exit;
	
		
	// Build cache validation string
	if not globalModificationsAllowed then begin
		// prefilter
		//recFileName := _getFileNameQuick2();
		pDR_cacheValidationStr := pDR_recordSrcFileName+':'+getFileCRC(pDR_recordSrcFileName);
		_pDR_cacheRecFiles.Append(pDR_cacheLoadOrderFormId + '=' + pDR_cacheValidationStr);
		end
	else begin // default processing
		pDR_cacheValidationStr := _pDR_cacheRecFiles.values[pDR_cacheLoadOrderFormId];
		if pDR_cacheValidationStr = '' then begin
			AddMessage('Warning: no cache validation string for: '+pDR_cacheLoadOrderFormId);
			Exit;
			end;
		end;

	// Only for CacheCondition-Cache
	if not _pDR_cacheCC_enabled then
		Exit;
		
	_pDR_cacheCC_modified := false;

	// Use cache entry
	_pDR_conditionsChecked.CommaText := _pDR_cacheCC_StoreCur.values[pDR_cacheLoadOrderFormId];

	_pDR_cacheFileCondOrig := _pDR_conditionsChecked.CommaText;
	if _pDR_conditionsChecked.values['cache_validation'] = pDR_cacheValidationStr then
		Exit;

	// Cache invalidation
	Inc(_pDR_cacheInvalidationsCC);
	
	_pDR_conditionsChecked.Clear;
	_pDR_conditionsChecked.values['cache_validation'] := pDR_cacheValidationStr;
end;


{Updates the statistics}
procedure updateCacheStatistics();
begin
	if Cache.existsCache('dynamicPatcherRuleSetResults') then begin
		ProgressGUI.setStatistic('CacheCount: RuleResult', Cache.getLevelTwoEntriesCount('dynamicPatcherRuleSetResults', true) );
		ProgressGUI.setStatistic(' - new/updated (RR)', IntToStr(_pDR_cacheInvalidationsRR));
		end;
	if Cache.existsCache('conditionCheckCache') then begin
		ProgressGUI.setStatistic('CacheCount: ConditionCheck', Cache.getEntriesCount('conditionCheckCache'));
		ProgressGUI.setStatistic(' - new/updated (CC)', IntToStr(_pDR_cacheInvalidationsCC));
		end;
	if Cache.existsCache('pluginScriptsResult') then begin
		ProgressGUI.setStatistic('CacheCount: PluginScripts', Cache.getLevelTwoEntriesCount('pluginScriptsResult', false));
		ProgressGUI.setStatistic(' - new/updated (PS)', IntToStr(pPS_cacheInvalidationsPS));
		end;
	ProgressGUI.setStatistic('Records patched', _pDR_statWrittenAll);
	ProgressGUI.setStatistic('Records filtered (late)', _pDR_statRemovedAll);
end;


{Returns the ini path for dynamic naming rules}
function getDynamicNamingRulesIniPath():String;
begin
	if FileExists( sComplexSorterBasePath+'Rules (User)\rules-innr.ini' ) then
		Result := sComplexSorterBasePath+'Rules (User)\rules-innr.ini'
	else
		Result := sComplexSorterBasePath+'Rules (Default)\rules-innr.ini';
end;


{Checks a condition}
function _checkRuleConditionMatch(conditionPack,parsedRules:TStringList;i:Integer;const sTag:String):Boolean;
var
	lstTmpKeywords: TStringList;
	elmIdent, conditionValue: String;
	i: Integer;
begin
	Result := true;
	// Quick checks
	if ( parsedRules.Count = 3 ) then begin
		
		elmIdent := parsedRules[0];
		_pDR_elmOperator := parsedRules[1];
		conditionValue := parsedRules[2];
		_pDR_quickCheckPack := conditionPack.Objects[2];
		
		// Lookup special identifer
		if _pDR_quickCheckPack[0] = QUICK_CHECK_PACK_FLAG_POS0_SPECIAL_VALUE_TRUE then
			_processSpecialIdentifier(pDR_record,elmIdent,sTag);

		if _pDR_quickCheckPack[4] = QUICK_CHECK_PACK_FLAG_POS4_SPECIAL_COMPVALUE_TRUE then
			_processSpecialConditionValue(pDR_record,conditionValue);
			
		// Ruleset taint? 
		if _pDR_quickCheckPack[5] <> '' then 
			if _pDR_cacheCurrentRuleSetTaints.values[_pDR_quickCheckPack[5]] = '' then
				_pDR_cacheCurrentRuleSetTaints.values[_pDR_quickCheckPack[5]] := '1';
		
		// Execute condition check
		if _pDR_quickCheckPack[2] = '200' then begin
			if not Assigned(_pDR_customVarIsset.values[elmIdent]) then begin
				_pDR_customVarIsset.values[elmIdent] := '1';
				_pDR_customVarValues.values[elmIdent] := GetElementEditValues(pDR_record, elmIdent);
				end;
			_pDR_editValue := _pDR_customVarValues.values[elmIdent];
			end;
			
		if _pDR_quickCheckPack[3] = QUICK_CHECK_PACK_FLAG_POS3_IS_STR_COMPARE then begin
			Result := _checkCondition();
			Exit;
			end
		else if _pDR_elmOperator = 'hasFlag' then begin
			if _pDR_quickFlagSetFor <> elmIdent then begin
				startQuickFlagCheck(ElementByPath(pDR_record, elmIdent));
				_pDR_quickFlagSetFor := elmIdent;
				end;
			Result := quickMatchingFlags(StringReplace( conditionValue,'|',',', [rfReplaceAll])) > 0;
			Exit;
			end
		else if _pDR_elmOperator = 'hasOnlyFlags' then begin
			if _pDR_quickFlagSetFor <> elmIdent then begin
				startQuickFlagCheck(ElementByPath(pDR_record, elmIdent));
				_pDR_quickFlagSetFor := elmIdent;
				end;
			Result := quickMatchingFlags(StringReplace( conditionValue,'|',',', [rfReplaceAll])) = quickGetSettedFlagsCount();
			Exit;
			end
		else if _pDR_elmOperator = 'numEquals' then begin
			if StrToFloat(_pDR_editValue) <> StrToFloat( conditionValue) then
				Result := false;
			Exit;
			end
		else if _pDR_elmOperator = 'greaterThan' then begin
			if StrToFloat(_pDR_editValue) <= StrToFloat( conditionValue) then
				Result := false;
			Exit;
			end
		else if _pDR_elmOperator = 'lessThan' then begin
			if StrToFloat(_pDR_editValue) >= StrToFloat( conditionValue) then
				Result := false;
			Exit;
			end
		else if _pDR_elmOperator = 'hasKeyword' then begin
			lstTmpKeywords := recordReadKeywords(pDR_record, elmIdent);
			Result := false;
			for i := 0 to _pDR_quickCheckPack.Objects[1].Count-1 do 
				if lstTmpKeywords.indexOf(_pDR_quickCheckPack.Objects[1].Strings[i]) <> -1 then begin 
					Result := true;
					lstTmpKeywords.Free;
					Exit;
					end;
			lstTmpKeywords.Free;
			Exit;
			end
		else
			raise Exception.Create('Unsupported operator "'+_pDR_elmOperator+'" in rule #'+IntToStr(i+1)+': '+parsedRules.CommaText);
		end
	else if ( parsedRules.Count = 2 ) then begin
		if parsedRules[1] = 'exists' then begin
			Result := ElementExists(pDR_record, parsedRules[0]);
			Exit;
			end
		else
			raise Exception.Create('Unknown operation in rule #'+IntToStr(i+1)+': '+parsedRules.CommaText);
		end
	else if ( parsedRules.Count = 1 ) then begin
		if parsedRules[0] = '*' then
			Result := true
		else if parsedRules[0] = 'SPECIAL:recordHasHumanRace' then
			Result := recordHasHumanRace(pDR_record)
		else if parsedRules[0] = 'SPECIAL:IsArmor' then
			Result := recordIsArmor(pDR_record)
		else
			raise Exception.Create('Error - invalid command "'+parsedRules[0]+'" in rule#'+IntToStr(i+1)+': '+parsedRules.CommaText);
		end
	else
		raise Exception.Create('Error - invalid parameter count in rule #'+IntToStr(i+1)+': '+parsedRules.CommaText);
end;


{ Check one condition of a rule}
function _checkCondition():Boolean;
var
	vals: TStringList;
	dnamFlags: IInterface;
	i,toInt,funcType:Integer;
begin
	Result := true; // Default to true to quit exit = true
	vals := _pDR_quickCheckPack.Objects[1];
	funcType := StrToInt(_pDR_quickCheckPack[2]);
	toInt := vals.Count -1;
		
	// Optimize special case equals
	if funcType = 200 then 
		if _pDR_elmOperator = 'equals' then begin
			Result := vals.indexOf(_pDR_editValue) <> -1;
			Exit;
		end;
		
	if funcType = 201 then
		if not Assigned(pDR_keywords) then
			pDR_keywords := recordReadKeywords(pDR_record, 'KWDA');
		
	if funcType = 202 then
		if not Assigned(_pDR_effects) then
			_pDR_effects := recordReadEffects(pDR_record);
			
	for i := 0 to toInt do begin
		if funcType = 200 then begin
			if _pDR_elmOperator = 'contains' then begin
				if ContainsText(_pDR_editValue,vals[i]) then
					Exit;
				continue;
				end
			else if _pDR_elmOperator = 'beginsWith' then
				if Pos(vals[i],_pDR_editValue) = 1 then
					Exit
				else
			else if _pDR_elmOperator = 'endsWith' then
				if (Pos(vals[i],_pDR_editValue) > 0) and ( vals[i] = Copy(_pDR_editValue,Length(_pDR_editValue)-Length(vals[i])+1,Length(vals[i])) ) then
					Exit
				else
			else
				raise Exception.Create('Unknown element operator for editValues comparison: "'+_pDR_elmOperator+'"');
			continue;
			end
		else if funcType = 201 then begin
			//if HasKeyWord(rec,vals[i]) then
			if pDR_keywords.indexOf(vals[i])>-1 then
				Exit
				end
		else if funcType = 202 then
			//if HasEffect(rec,vals[i]) then
			if _pDR_effects.indexOf(vals[i])>-1 then
				Exit
			else
		else raise Exception.Create('Unknown funcType '+IntToStr(funcType)+'!');
	end;
	
	Result := false;
end;



{Processes one TagIdent. Returns true if the rule chain should be continued. false for final rule }
function _processSpecialTagIdent(var sTagIdent, var sTag:String;var saveRecord, var madeModifications, var bEndRuleset:Boolean):Boolean;
var
	tmpStr, sTagAction, sSetNewTagIdentByScript: String;
	tmpLst: TStringList;
	tmpElm: IInterface;
begin
	tmpLst := TStringList.Create;
	tmpLst.Delimiter := ':';
	tmpLst.StrictDelimiter := true;
	tmpLst.DelimitedText := sTagIdent;
	if tmpLst.Count >= 2 then 
		sTagAction := tmpLst[1];
	madeModifications := true; // Only changed by script
	Result := true;
	// Result = true for continue processing chain, false will apply sTagIdent to item
	if sTagAction = 'PluginScript' then begin
		// Taint cache 
		if _pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginScript:'+tmpLst[2]+':'+tmpLst[3]] = '' then
			_pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginScript:'+tmpLst[2]+':'+tmpLst[3]] := '1';
		bEndRuleset := CSPluginSystem.applyPluginScript(tmpLst[2]+':'+tmpLst[3],saveRecord,sSetNewTagIdentByScript, sTag, madeModifications);
		if sSetNewTagIdentByScript <> '' then 
			sTag := sSetNewTagIdentByScript;
		tmpLst.Free;
		Exit;
		end
	else if sTagAction = 'AddKeyword' then
		_prcTagIdentAddKeyword(saveRecord, tmpLst)
	else if sTagAction = 'EndRuleset' then begin
		bEndRuleset := true;
		madeModifications := False;
		end
	else if sTagAction = 'PregReplace' then
		_prcTagIdentPregReplace(saveRecord, tmpLst)
	else if sTagAction = 'SetFieldValue' then
		_prcTagIdentSetFieldValue(saveRecord, tmpLst)
	else if sTagAction = 'SetFieldRecRef' then
		_prcTagIdentSetFieldRecRef(saveRecord, tmpLst)
	else if sTagAction = 'RemoveINRD' then
		_prcTagIdentRemoveINRD(saveRecord)
	else if (sTagAction = 'FindCustomTag') or (sTagAction = 'FindCustomTagLVLI') then begin
		if _prcTagIdentFindCustomTag(sTagAction = 'FindCustomTagLVLI', sTag, tmpLst) then begin 
			sTagIdent := sTag; // Save directly to cache.
			Result := false; // Final rule!
			end;
		end
	else if sTagAction = 'RecordScript' then
		_prcTagIdentRecordScript(saveRecord, tmpLst)
	else begin
		Result := true; // To save in cache, so false entry isnt skipped next time until changed ...
		_pDR_cacheRR_curEntryIsValid := false;
		AddMessage('WARNING: Unsupported or malformed SPECIAL-TagIdent: '+sTagIdent);
		
		saveRecord := false;
		end;

	tmpLst.Free;
end;


{Process TagIdent FindCustomTag. Returns true if a TagIdent is found}
function _prcTagIdentFindCustomTag(isLVLIRecord: Boolean; var sTag:String; tmpLst:TStringList):Boolean;
var 
	sFoundTagIdent: String;
	rec: IInterface;
begin
	if isLVLIRecord then 
		rec := _findLeveledItemRefRecord()
	else
		rec := pDR_record;
	if not Assigned(rec) then
		Exit;

	// Add taint to ruleset cache
	if _pDR_cacheCurrentRuleSetTaints.values['TAINT:FindCustomTag'] = '' then
		_pDR_cacheCurrentRuleSetTaints.values['TAINT:FindCustomTag'] := '1';

	if _findTagForWeaponByDynRules(rec, tmpLst[2],sFoundTagIdent) then begin
		sTag := sFoundTagIdent;
		Result := true;
		end;

end;

{Process TagIdent PregReplace}
procedure _prcTagIdentPregReplace(var saveRecord:Boolean;tmpLst:TStringList);
var
	tmpStr: String;
begin
	if tmpLst.Count = 5 then begin
		DynamicPatcher.flushCacheFullName;
		tmpStr := getElementEditValues(pDR_record, tmpLst[2]);
		tmpStr := PregReplace(tmpLst[3],tmpLst[4],tmpStr);
		SetElementEditValues(pDR_record, tmpLst[2], tmpStr);
		saveRecord := true;
		end
	else 
		raise Exception.Create('Invalid SPECIAL-TagIdent syntax for: '+tmpLst.DelimitedText);
end;

{Process TagIdent SetFieldRecRef}
procedure _prcTagIdentSetFieldRecRef(var saveRecord:Boolean;tmpLst:TStringList);
begin
	if tmpLst.Count = 5 then begin
		// SetElementEditValues(pDR_record, tmpLst[2], RecordLib.getRecordReferenceIndex(tmpLst[3]).Values[tmpLst[4]]);
		RecordLib.setRecordReference(pDR_record,tmpLst[2], tmpLst[3],tmpLst[4]);
		saveRecord := true;
		end
	else 
		raise Exception.Create('Invalid SPECIAL-TagIdent syntax for: '+tmpLst.DelimitedText);
end;

{Process TagIdent RecordScript}
procedure _prcTagIdentRecordScript(var saveRecord:Boolean;tmpLst:TStringList);
begin
	if tmpLst.Count = 3 then begin
		RecordScript.processRecScript(pDR_record,tmpLst[2]);
		saveRecord := true;
		end
	else 
		raise Exception.Create('Invalid SPECIAL-TagIdent syntax for: '+tmpLst.DelimitedText);
end;

{Process TagIdent SetFieldRecRef}
procedure _prcTagIdentSetFieldValue(var saveRecord:Boolean;tmpLst:TStringList);
begin
	if tmpLst.Count = 4 then begin
		// SetElementEditValues(pDR_record, tmpLst[2], RecordLib.getRecordReferenceIndex(tmpLst[3]).Values[tmpLst[4]]);
		// RecordLib.setRecordReference(pDR_record,tmpLst[2], tmpLst[3],tmpLst[4]);
		SetElementEditValues(pDR_record, tmpLst[2], tmpLst[3]);
		saveRecord := true;
		end
	else 
		raise Exception.Create('Invalid SPECIAL-TagIdent syntax for: '+tmpLst.DelimitedText);
end;

{Process TagIdent AddKeyword}
procedure _prcTagIdentAddKeyword(var saveRecord:Boolean;tmpLst:TStringList);
var 
	keyWordFieldPath, keyword:String;
begin
	if globalModificationsAllowed then begin
		if tmpLst.count = 4 then begin
			keyWordFieldPath := tmpLst[2];
			keyword := tmpLst[3];
			end
		else if tmpLst.count = 3 then begin
			keyWordFieldPath := 'KWDA - Keywords';
			keyword := tmpLst[2];
			end
		else 
			raise Exception.Create('Invalid SPECIAL-TagIdent syntax for: '+tmpLst.DelimitedText);
			
		if _addKeywordToRecord(pDR_record,keyword,keyWordFieldPath) then
			saveRecord := true
		else
			AddMessage('Warning: Keyword "'+keyword+'" couldn''t added to record '+ShortName(pDR_record)+'.');
		end;
end;

{Process TagIdent RemoveINRD}
procedure _prcTagIdentRemoveINRD(var saveRecord:Boolean);
begin
	if ElementExists(pDR_record,'INRD') then begin
		RemoveElement(pDR_record,'INRD');
		saveRecord := true;
		end;
end;

{Add a keyword to a record}
function _addKeywordToRecord(rec:IInterface;keyword:String;keyWordFieldPath:String):Boolean;
var
	keywords: IInterface;
	kwHex: String;
begin
	Result := false;
	
	// Check if already exists
	if not Assigned(pDR_keywords) then
		pDR_keywords := recordReadKeywords(pDR_record, 'KWDA');
	
	if pDR_keywords.indexOf(keyword) > -1 then begin
		Result := true;
		Exit;
		end;
	
	// Try to add keyword
	kwHex := kywdCache.values[keyword];
	if kwHex = '' then
		Exit;
	keywords := ElementByName(rec,keyWordFieldPath{'KWDA - Keywords'});
	if not Assigned(keywords) then begin
		// Create
		keywords := Add(rec,keyWordFieldPath,False);
		if not Assigned(keywords) then 
			Exit;
		end
	// Add keyword!
	AddMasterIfMissing(mxPatchFile, kywdCache.Values[keyword+':file']);
	SetEditValue(ElementAssign(keywords, HighInteger, nil, False), kwHex);
	Result := true;
	// Clear cache 
	FreeAndNil(pDR_keywords);
end;


{Proces special identifier}
procedure _processSpecialIdentifier(rec:IInterface;var elmIdent:String;const sTag:String);
var
	tmpLst: TStringList;
	tmpStr: String;
begin
	_pDR_customVarIsset.values[elmIdent] := '1';
	if elmIdent = 'BPNotFace:flagsCount' then begin
		// elmIdent := 'BOD2 - Biped Body Template\First Person Flags';
		if ElementExists(rec, 'BOD2 - Biped Body Template\First Person Flags') then begin
			if not Assigned(_pDR_bodyPartFlagsNotFace) then
				_buildBodyPartFlagsNotFace(rec);
			_pDR_customVarValues.values[elmIdent] := IntToStr(matchingFlags(ElementByPath(rec, 'BOD2 - Biped Body Template\First Person Flags'),_pDR_bodyPartFlagsNotFace));
			end
		else
			_pDR_customVarValues.values[elmIdent] := '0';
		Exit;
		end
	else if elmIdent = 'BP:flagsCount' then begin
		_pDR_customVarValues.values[elmIdent] := IntToStr(LENGTH(StringReplace(GetEditValue(ElementByPath(rec, 'BOD2 - Biped Body Template\First Person Flags')), '0', '', [rfReplaceAll])));
		Exit;
		end
	else if elmIdent = 'INRD:link:EDID' then begin
		if ElementExists(rec, 'INRD - Instance Naming') then
			_pDR_customVarValues.values[elmIdent] := GetElementEditValues(LinksTo(ElementBySignature(rec, 'INRD')), 'EDID - Editor ID')
		else
			_pDR_customVarValues.values[elmIdent] := '';
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		Exit;
		end
	else if Pos(':link:',elmIdent) > 0 then begin
		tmpLst := Split(':',elmIdent);
		if ElementExists(rec, tmpLst[0]) then
			//_pDR_customVarValues.values[elmIdent] := GetElementEditValues(LinksTo(ElementBySignature(rec, tmpLst[0])), tmpLst[2])
			_pDR_customVarValues.values[elmIdent] := GetElementEditValues(WinningOverride(LinksTo(ElementBySignature(rec, tmpLst[0]))), tmpLst[2])
		else
			_pDR_customVarValues.values[elmIdent] := '';
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		tmpLst.Free;
		end
	else if elmIdent = 'SPECIAL:MasterESP' then begin
		_pDR_customVarValues.values[elmIdent] := getBaseESPName(GetFileName(GetFile(MasterOrSelf(rec))));
		Exit
		end
	else if Pos('SPECIAL:TagIdent',elmIdent)=1 then begin
		_pDR_customVarIsset.values[elmIdent] := '1';
		_pDR_customVarValues.values[elmIdent] := sTag;
		end
	else if Pos('SPECIAL:LeveledItemReference:',elmIdent)=1 then begin
		tmpLst := Split(':',elmIdent);
		_pDR_customVarIsset.values[elmIdent] := '1';
		_pDR_customVarValues.values[elmIdent] := _findLeveledItemRefFieldData(tmpLst[2]);
		tmpLst.Free;
		end
	else if BeginsWithExtract('SPECIAL:PluginSetting:',elmIdent, tmpStr) then begin
		tmpLst := Split(':',tmpStr);
		_pDR_customVarIsset.values[elmIdent] := '1';
		_pDR_customVarValues.values[elmIdent] := CSPluginSystem.getPluginUserSetting(tmpLst[0],tmpLst[1]);
		tmpLst.Free;
		if _pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginSetting:'+tmpStr] = '' then
			_pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginSetting:'+tmpStr] := '1';
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		end
	else if elmIdent = 'SPECIAL:WinningOverrideESP' then begin
		_pDR_customVarValues.values[elmIdent] := getBaseESPName(GetFileName(GetFile(WinningOverrideBefore(rec,mxPatchFile))));
		Exit
		end
	else if Pos(':keywordsCount',elmIdent) > 0 then begin
		tmpLst := Split(':',elmIdent);
		_pDR_customVarValues.values[elmIdent] := IntToStr(ElementCount(ElementByPath(rec, tmpLst[0])));
		tmpLst.Free;
		end
	else begin
		AddMessage('Unknown special identifier: '+elmIdent);
		_pDR_cacheCurrentRuleSetTaints.values['TAINT:UNKNOWN_SPECIAL'] := '1';
		_pDR_customVarIsset.values[elmIdent] := '0';
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		end;
end;


{Find the base record for a leveled item}
function _findLeveledItemRefRecord():IInterface;
var
	rec: IInterface;
	n: Integer;
begin
	Result := nil;
	rec := pDR_record;
	// Find base referenced record
	while true do begin 
		if not Assigned(rec) then 
			Exit;
		if Signature(rec) <> 'LVLI' then begin
			Result := rec;
			Exit;
			end;
		rec := LinksTo(ElementByPath(rec,'Leveled List Entries\Leveled List Entry\LVLO\Reference'));
		Inc(n);
		if n > 20 then begin
			AddMessage('Warning: Possible endless loop detected.');
			break;
			end;
	end;
end;

{Find a field value in a referenced leveled item}
function _findLeveledItemRefFieldData(elmPath:String):String;
var 
	rec: IInterface;
begin
	rec := _findLeveledItemRefRecord();
	if Assigned(rec) then
		Result := GetElementEditValues(rec,elmPath);
end;


{Proces special condition value}
procedure _processSpecialConditionValue(rec:IInterface;var conditionValue:String);
var tmpLst: TStringList;
begin
	if Pos('SPECIAL:PluginSetting:',conditionValue)=1 then begin
		tmpLst := Split(':',conditionValue);
		// AddMessage('SPEZIAL: '+tmpLst.CommaText);
		conditionValue := CSPluginSystem.getPluginUserSetting(tmpLst[2],tmpLst[3]);
		if _pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginSetting:'+tmpLst[2]+':'+tmpLst[3]] = '' then
			_pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginSetting:'+tmpLst[2]+':'+tmpLst[3]] := '1';
		tmpLst.Free;
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		end
	else begin
		AddMessage('Unknown special condition value: '+conditionValue);
		conditionValue := '';
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		end;
end;


{Find and patch custom item template names}
function _processRecordsObjectTemplates(rec: IInterface;sTag:String):Boolean;
var
	objTplCombs,objElm: IInterface;
	j: int;
begin
	Result := false;
	if not getSettingsBoolean('config.bHeuristicAddTagsToWeaponsTemplates') then
		exit;

	objTplCombs := ElementByPath(rec, 'Object Template\Combinations'); // 'OBTE'
	for j := 0 to ElementCount(objTplCombs) - 1 do begin
		objElm := ElementByIndex(objTplCombs, j);
		if not ElementExists(objElm,'OBTF') and ElementExists(objElm,'Full - Name') then
			_recordAddTagString(sTag, 'FULL - Name', objElm,'', Result);
	end
end;


procedure _prepareStatisticsForProcRuleSet(procRuleSetSection:TStringList);
var
	i,j: Integer;
	processingRulesList: TStringList;
begin
	for i := 0 to procRuleSetSection.Count - 1 do begin
		processingRulesList := procRuleSetSection.Objects[i];
		for j := 0 to processingRulesList.Count - 1 do
			if _pDR_statUsedRules.values[processingRulesList.Strings[j]] = '' then
				_pDR_statUsedRules.values[processingRulesList.Strings[j]] := '0';
		end;
end;


{Build the predefined list of body parts not located in head area}
procedure _buildBodyPartFlagsNotFace(rec:IInterface);
var
	tmpLst: TStringList;
begin
	tmpLst := TStringList.Create();
	tmpLst.Text := FlagValues(ElementByPath(rec, 'BOD2 - Biped Body Template\First Person Flags'));
	_pDR_bodyPartFlagsNotFace := TStringList.Create();
	_pDR_bodyPartFlagsNotFace.Text := tmpLst.Text;
	tmpLst.free;
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('30 - Hair Top'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('31 - Hair Long'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('32 - FaceGen Head'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('46 - Headband'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('47 - Eyes'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('48 - Beard'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('49 - Mouth'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('50 - Neck'));
	_pDR_bodyPartFlagsNotFace.Delete(_pDR_bodyPartFlagsNotFace.indexOf('52 - Scalp'));
end;


{ Patches WEAP record with custom rules. Returns true if sTag is found. }
function _findTagForWeaponByDynRules(rec:IInterface;ruleSetName:String;var sTag:String):Boolean;
var
	rulesSection, ruleKeywords: TStringList;
	keywords: THashedStringList;
	ruleKeywordsString, SInnrRuleTagIdent: String;
	i,j: int;
	match: Boolean;
begin
	Result := false;

	if not getSettingsBoolean('config.bHeuristicAddTagsToWeapons') then
		Exit;
	// Load rules set
	rulesSection := INNRProcessing.getDynamicNamingRulesSection(ruleSetName);
	
	keywords := recordReadKeywords(rec, 'KWDA');

	// Test naming rules for application
	for j := 0 to rulesSection.Count - 1 do begin
		ruleKeywordsString := rulesSection.Names[j];
		if ruleKeywordsString = 'ADD_EMPTY_RULESET' then
			continue;
		if ruleKeywordsString = 'MODIFICATION_INSTRUCTIONS' then
			continue;
		
		// TagIdent to apply
		SInnrRuleTagIdent := rulesSection.values[ruleKeywordsString];
		
		// Test if all keywords matching
		match := true;
		ruleKeywords := Split(',',ruleKeywordsString);
		for i := 0 to ruleKeywords.Count - 1 do begin
			if (keywords.indexOf(Trim(ruleKeywords[i])) = -1) then
				if (ruleKeywords[i] <> '*' ) then begin
					match := false;
					break;
				end;
		end;
		ruleKeywords.Free;
		// Match found? Tag!
		if match then begin
			Result := true;
			sTag := SInnrRuleTagIdent;
			keywords.Free;
			Exit;
		end
	end;
	rulesSection.Free;
	keywords.Free;
end;
	
{if filled, saves and cleans the cached "FULL - Name" entry}
procedure flushCacheFullName;
begin
	if pDR_fullName <> '' then begin
		SetElementEditValues(pDR_record, 'FULL - Name', pDR_fullName);
		pDR_fullName := '';
		end;
end;

// Writes sTag string to beginning of existing string.
procedure _recordAddTagString(sTag, sPath: String; rec: IInterface;fullNamePrecached:String;var saveRecord:Boolean);
var 
	newName: String;
begin
	if not globalModificationsAllowed then 
		Exit;
	if fullNamePrecached = '' then
		fullNamePrecached := GetElementEditValues(rec, sPath);
	if fullNamePrecached = '' then
		Exit;
	// -- Scanning old to new tags 
	//__devAnalyseOldToNewRecord(sTag,sPath,rec,fullNamePrecached);
	// --
	newName := sTag + ' ' + RecordLib.deleteExistingTag(fullNamePrecached);
    if newName = fullNamePrecached then
		Exit; // No change
	// Set new tag
	SetElementEditValues(rec, sPath, newName);
	saveRecord := True;
end;

{Cleanup}
procedure cleanup();
var
	i: Integer;
begin
	// Save cache
	if Cache.existsCache('conditionCheckCache') then begin
		Cache.save('conditionCheckCache', true);
		_pDR_cacheCC_StoreCur := nil;
		end;
	if Cache.existsCache('dynamicPatcherRuleSetResults') then
		Cache.save('dynamicPatcherRuleSetResults', true);

	FreeAndNil(_pDR_bodyPartFlagsNotFace);
	
	FreeAndNil(_pDR_fileNameQuickCache);
	FreeAndNil(_pDR_fileNameQuick2Cache);
	FreeAndNil(pDR_keywords);
	FreeAndNil(_pDR_effects);
	FreeAndNil(_pDR_customVarValues);
	FreeAndNil(_pDR_customVarIsset);
	FreeAndNil(_pDR_conditionsChecked);
	FreeAndNil(_pDR_statUsedRules);
	
	// Clear cache
	FreeAndNil(_pDR_cacheRecFiles);
	FreeAndNil(_pDR_cacheCurrentRuleSetTaints);
	
	INNRProcessing.cleanup();
	
end;

end.