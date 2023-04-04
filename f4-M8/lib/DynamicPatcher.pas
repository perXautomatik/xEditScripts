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
	_pDR_customVarValues,
	_pDR_customVarIsset,
	_pDR_conditionsChecked,
	_pDR_fileNameQuickCache,
	_pDR_fileNameQuick2Cache,
	_pDR_statUsedRules: THashedStringList;
	
	_pDR_bodyPartFlagsNotFace,
	_pDR_quickCheckPack: TStringList;
	
	_pDR_editValue,
	_pDR_elmOperator,
	pDR_recordType,
	pDR_fullName:String;

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
	_pDR_cacheCC_StoreCur,
	_pDR_cacheCurrentRuleSetTaints: THashedStringList;

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
	elmIdent, elmOperator, conditionValue: String;
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
		
		
		Result := TStringList.Create;
		// Slot 0: Has special identifer
		if (elmIdent = 'BPNotFace:flagsCount') or (elmIdent = 'BP:flagsCount') or (elmIdent = 'INRD:link:EDID')
			or (Pos('SPECIAL:',elmIdent)=1) then
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
		if (elmOperator = 'contains') or (elmOperator = 'beginsWith') or (elmOperator = 'equals') then
			Result.add(QUICK_CHECK_PACK_FLAG_POS3_IS_STR_COMPARE)
		else
			Result.add('0');
		
		// Slot 4: conditionValue has special identifer
		if (Pos('SPECIAL:',conditionValue)=1) then
			Result.add(QUICK_CHECK_PACK_FLAG_POS4_SPECIAL_COMPVALUE_TRUE)
		else Result.add('0');
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
	// Nur Master sind anhand der load order eindeutig erkenntbar
	{if not isMaster(pDR_record) or (pDR_cacheLoadOrderFormId = '') then begin
		Result := GetFileName(GetFile(pDR_record));
		Exit;
		end;}
		
	{if globalModificationsAllowed then
		AddMessage('getFileNameQuick1 isn''t working correctly in edit mode!');}
		
	loadOrderNrStr := Copy(pDR_cacheLoadOrderFormId,1,2);
		
	Result := _pDR_fileNameQuickCache.values[loadOrderNrStr];
	if Result <> '' then
		Exit;
	Result := GetFileName(GetFile(pDR_record));
	_pDR_fileNameQuickCache.values[loadOrderNrStr] := Result;	
end;


{Returns the source file name for the current record from cached values}
function getFileNameQuick2():String;
begin
	if pDR_cacheLoadOrderFormId = '' then 
		AddMessage('DARF NICHT!');
	
	if globalModificationsAllowed then begin// Records are now always in our new file, so one step back!
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
			_pDR_fileNameQuick2Cache.append(pDR_cacheLoadOrderFormId+'='+Result);
			end
		else begin
			// Result := GetFileName(GetFile(MasterOrSelf(pDR_record)));
			// Allow overrides		
			// We just need the latest override, as mods normally don't get merged or have the merge in name
			Result := GetFileName(GetFile(pDR_record));
			// Store source file for later use
			_pDR_fileNameQuick2Cache.append(pDR_cacheLoadOrderFormId+'='+Result);
			end;	
end;


{Process the dynamic rules set for one record type}
procedure patchDynamicRules(recordType:String);
var
	rec: IInterface;
	saveRecord, condMatch: Boolean;
	i,j,l, statAll, n,recordsBegCnt: Integer;
	sTag, str, sTagTargetPath, modBaseName: String;
	records,procRuleSets, afterMatchRules, amrProcRuleSetIdent, amrProcRuleSetSection: TStringList;
begin
	if recordsIndex.indexOf(recordType) = -1 then
		exit;
	if bUserRequestAbort then
		Exit;
	measureTimeStart(1);
		
	// Setup
	initRecordProcessing();
	sTag := '';
	statAll := 0;
	_pDR_statWritten := 0;
	_pDR_statRemoved := 0;
	
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
		sTag := '';
		startRecordProcessing(rec,recordType);
		
		// Process custom mod rules
		procRuleSets := CustomRuleSets.getProccessingRuleSetsArray('');
		
		// Process all rulesets
		for j:= 0 to procRuleSets.Count -1 do
			if processRuleSet(procRuleSets[j],procRuleSets.Objects[j],saveRecord, sTag) then
				break;
		
		// IGNORED entry?
		if sTag = 'IGNORE' then begin
			Remove(rec);
			Inc(_pDR_statRemoved);
			continue;
			end;
			
	
		// Apply plugins of type pluginRecordModifier
		afterMatchRules := CSPluginSystem.getPluginRuleSetsWithAfterMatchRules(recordType);
		for j := 0 to afterMatchRules.Count -1 do 
			processRuleSet(afterMatchRules[j],afterMatchRules.Objects[j],saveRecord,sTag);
			{begin
			amrProcRuleSetIdent := afterMatchRules[j];
			amrProcRuleSetSection := CustomRuleSets.getCustomProcessingRuleSet(amrProcRuleSetIdent, recordType);
			if Assigned(amrProcRuleSetSection) then
				// No processing of result at this point ... all plugins will be handled
				processRuleSet(amrProcRuleSetIdent+'>'+recordType,amrProcRuleSetSection,saveRecord,sTag)
			end;}
		

		// Save?
		if sTag <> '' then begin
		
			// Special processing of ARMO
			if recordType = 'ARMO' then 
				_processAfterRecordsTypeARMO(rec, sTag);
			
			// Find final tag
			if sTag <> '' then begin
				if not Assigned(tagNames.values[sTag]) then
					raise Exception.Create('Warning: Tag identifier "'+sTag+'" have no final tag!')
				else
					sTag := tagNames.values[sTag];
			end;

			// Target path
			if recordType = 'LVLI' then
				sTagTargetPath := 'ONAM' // 'ONAM - Override Name'
			else
				sTagTargetPath := 'FULL';//;'FULL - Name';
			
			// Special processing of WEAP
			if recordType = 'WEAP' then 
				_processAfterRecordsTypeWEAP(rec, sTag, saveRecord)
			else if ElementExists(rec, sTagTargetPath) then
				saveRecord := true;
		
			// Save tag
			if sTag <> '' then
				recordAddTagString(sTag, sTagTargetPath, rec, pDR_fullName);
			end;
			
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
		
		except
			on E: Exception do
			AddMessage('Exception: ' + E.Message + ' | While processing '+recordType+' record '+ getElementEditValues(rec,'EDID') + ' (Form-ID: '+IntToHex(GetLoadOrderFormID(rec),8)+' )');
			end;
		{finally end;}
		
		end;
		
	// Save last entry
	startRecordProcessing(nil,nil);
	// Summary
	AddMessage('Record type '+recordType+': '+IntToStr(records.Count)+' records processed '
			+ ' in '+measureTimeGetFormatted(1)+'     Results -  Written: '+IntToStr(_pDR_statWritten)+'   Ignored: '+IntToStr(_pDR_statRemoved));
	if pDR_gatherStats then begin
		AddMessage('Rules usage statistics for record type '+recordType+': ');
		for i := 0 to _pDR_statUsedRules.Count -1 do
			AddMessage('  '+_pDR_statUsedRules.ValueFromIndex[i]+' x '+_pDR_statUsedRules.Names[i]);
		end;
end;


{Afterprocessing for records of type ARMO}
procedure _processAfterRecordsTypeARMO(rec:IInterface;var sTag:String);
begin
	if not recordIsArmor(rec) then begin
		if Assigned(tagNames.values[sTag+'-clothes']) then
			sTag := sTag+'-clothes';
		end
	else if Assigned(tagNames.values[sTag+'-armor']) then
		sTag := sTag+'-armor';
end;

{Afterprocessing for records of type WEAP}
procedure _processAfterRecordsTypeWEAP(rec:IInterface;var sTag:String;var saveRecord:Boolean);
begin
	// look for object templates - save if found
	if _processRecordsObjectTemplates(rec, sTag) then
		saveRecord := true;
		
	// Does a INRD entry exist? 
	if ElementExists(rec, 'INRD - Instance Naming') and (GetElementEditValues(rec, 'INRD - Instance Naming') <> '') then begin
		if INNRProcessing.patchWEAPWithNamingRules(rec) then
			sTag := '' // Covered by INNR rules 
		else
			saveRecord := true; // Not covered, save direct
		end
	else
		saveRecord := true; // No INRD, save direct.
end;


{Initializes the record processing system}
procedure initRecordProcessing();
var
	i: Integer;
begin
	if not Assigned(_pDR_customVarValues) then
		_pDR_customVarValues := TStringList.Create
	else
		_pDR_customVarValues.Clear();
		
	if not Assigned(_pDR_customVarIsset) then
		_pDR_customVarIsset := TStringList.Create
	else
		_pDR_customVarIsset.Clear();
		
	if not Assigned(_pDR_conditionsChecked) then
		_pDR_conditionsChecked := TStringList.Create
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
		_pDR_cacheCurrentRuleSetTaints := THashedStringList.Create;
	
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
	recFileName: String;
	recFile, recParent,master, overrideRec: IInterface;
begin
	
	if _pDR_cacheCC_enabled then
		if Assigned(pDR_cacheLoadOrderFormId) and Assigned(_pDR_conditionsChecked.values['cache_validation']) then
			if _pDR_cacheCC_modified then
				if _pDR_cacheFileCondOrig <> _pDR_conditionsChecked.CommaText then
					Cache.SetEntry('conditionCheckCache',pDR_cacheLoadOrderFormId,_pDR_conditionsChecked.CommaText);

	if not Assigned(rec) then
		Exit;
		
	// Setup new record - clear before stuff
	pDR_fullName := '';
	pDR_record := rec;
	pDR_recordType := recordType;
	_pDR_customVarValues.Clear();
	_pDR_customVarIsset.Clear();
	_pDR_conditionsChecked.Clear();
	_pDR_cacheCC_modified := false;
	
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

	// Use any cache?
	if (not _pDR_cacheRR_enabled) and (not _pDR_cacheCC_enabled) and (not _ps_cache_enabled) then
		Exit;

		
	// Build cache validation string
	if not globalModificationsAllowed then begin
		// prefilter
		recFileName := getFileNameQuick2();
		pDR_cacheValidationStr := recFileName+':'+getFileCRC(recFileName);
		_pDR_cacheRecFiles.add(pDR_cacheLoadOrderFormId + '=' + pDR_cacheValidationStr);
		end
	else begin // condition checks
		pDR_cacheValidationStr := _pDR_cacheRecFiles.values[pDR_cacheLoadOrderFormId];
		if pDR_cacheValidationStr = '' then begin
			AddMessage('Warning: no cache validation string for: '+pDR_cacheLoadOrderFormId);
			Exit;
			end;
		end;

	
	if not _pDR_cacheCC_enabled then
		Exit;
		
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
	ProgressGUI.setStatistic('Patched records', _pDR_statWrittenAll);
	ProgressGUI.setStatistic('Late filtered records', _pDR_statRemovedAll);
end;


{Process a processing rule set}
function processRuleSet(const procRuleSetFullQualName:String;procRuleSetSection:TStringList;var saveRecord:Boolean;var sTag:String):Boolean;
var
	match, madeModifications: Boolean;
	i,j:Integer;
	ruleConditionsLst, conditionPack: TStringList;
	ruleApplyTag, conditionString, conditionResult, cacheIdent, cacheEntry, procRulesCrc32, newCacheEntry: String;
begin
	Result := false;

	// Cache?
	if _pDR_cacheRR_enabled then begin
		// Checksum
		procRulesCrc32 := customProcRuleSetCrc32s.values[procRuleSetFullQualName];
		if procRulesCrc32 <> '' then
			procRulesCrc32 := procRulesCrc32 + ';' + pDR_cacheValidationStr
		else
			AddMessage('No CRC32 available for: '+procRuleSetFullQualName);
		// Cache available?
		cacheIdent   := pDR_cacheLoadOrderFormId;
		cacheEntry   := Cache.getEntryLevelTwo('dynamicPatcherRuleSetResults', procRuleSetFullQualName, cacheIdent);
		
		if cacheEntry <> '' then begin
			Result := _cache_useProcSetResult(cacheEntry,procRulesCrc32,saveRecord,sTag);
			// Valid?
			if _pDR_cacheRR_curEntryIsValid then
				Exit;

			// AddMessage('Found invalid cache: ruleident='+procRuleSetFullQualName+' crc='+procRulesCrc32);
			_pDR_cacheRR_curEntryIsValid := true;
			end;
		// Clear cache
		newCacheEntry := procRulesCrc32;
		_pDR_cacheCurrentRuleSetTaints.Clear();
		end;
	
	// Stats
	if pDR_gatherStats then
		_prepareStatisticsForProcRuleSet(procRuleSetSection);
	
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
		ruleApplyTag := procRuleSetSection.Strings[i];
		
		// Special tag
		if Pos('SPECIAL:', ruleApplyTag) = 1 then
			if _processSpecialTagIdent(ruleApplyTag,sTag, saveRecord, madeModifications) then begin
				if madeModifications and _pDR_cacheRR_enabled then
					newCacheEntry := newCacheEntry + #9 + ruleApplyTag;
				continue;
				end;

		// Cache
		if _pDR_cacheRR_enabled then
			newCacheEntry := newCacheEntry + #9 + ruleApplyTag;

				
		// Final rule
		Result := true; // true = final rule, no further processing
		
		// Special rule: Ignore record entry
		if ruleApplyTag = 'IGNORE' then
			saveRecord := false;
			
		// Set tag
		sTag := ruleApplyTag;

		// Save result to cache
		if _pDR_cacheRR_enabled then
			_cache_writeProcSetResult(procRuleSetFullQualName,cacheIdent,newCacheEntry);
		// Done here
		Exit;
		end;

	// Save no result to cache
	if _pDR_cacheRR_enabled then begin
		newCacheEntry := newCacheEntry + #9 + '#NO_RESULT#';
		_cache_writeProcSetResult(procRuleSetFullQualName,cacheIdent,newCacheEntry);
		end;
end;


{Returns the ini path for dynamic naming rules}
function getDynamicNamingRulesIniPath():String;
begin
	if FileExists( sComplexSorterBasePath+'Rules (User)\rules-innr.ini' ) then
		Result := sComplexSorterBasePath+'Rules (User)\rules-innr.ini'
	else
		Result := sComplexSorterBasePath+'Rules (Default)\rules-innr.ini';
end;


function _checkRuleConditionMatch(conditionPack:TStringList;parsedRules:TStringList;i:Integer;const sTag:String):Boolean;
var
	//quickCheckPack: TStringList;
	elmIdent, conditionValue: String;
	k: Integer;
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
		else
			raise Exception.Create('Unsupported operator "'+_pDR_elmOperator+'" in rule #'+IntToStr(i+1)+' of record type '+pDR_recordType+': '+parsedRules.CommaText);
		//raise Exception.Create('Unkown element: "'+elmIdent+'" in rule #'+IntToStr(i)+' of record type '+pDR_recordType);
		end
	else if ( parsedRules.Count = 2 ) then begin
		if parsedRules[1] = 'exists' then begin
			Result := ElementExists(pDR_record, parsedRules[0]);
			Exit;
			end
		else
			raise Exception.Create('Unknown operation in rule #'+IntToStr(i+1)+' of record type '+pDR_recordType+': '+parsedRules.CommaText);
		end
	else if ( parsedRules.Count = 1 ) then begin
		if parsedRules[0] = '*' then
			Result := true
		{else if parsedRules[0] = 'SPECIAL:IsValuable' then begin
			Result := recordIsValuable(pDR_record);
			// Add taint to ruleset cache
			_pDR_cacheCurrentRuleSetTaints.values['TAINT:IsValuable'] := '1';
			end}
		else if parsedRules[0] = 'SPECIAL:recordHasHumanRace' then
			Result := recordHasHumanRace(pDR_record)
		else if parsedRules[0] = 'SPECIAL:IsArmor' then
			Result := recordIsArmor(pDR_record)
		else
			raise Exception.Create('Error - invalid command "'+parsedRules[0]+'" in rule#'+IntToStr(i+1)+' of record type '+pDR_recordType+': '+parsedRules.CommaText);
		end
	else
		raise Exception.Create('Error - invalid parameter count in rule #'+IntToStr(i+1)+' of record type '+pDR_recordType+': '+parsedRules.CommaText);
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
	
	if funcType = 201 then
		if not Assigned(pDR_keywords) then
			pDR_keywords := recordReadKeywords(pDR_record);
		
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
			else if _pDR_elmOperator = 'equals' then begin
				if _pDR_editValue = vals[i] then
					Exit;
				continue;
				end
			else if _pDR_elmOperator = 'beginsWith' then
				if Pos(vals[i],_pDR_editValue) = 1 then
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


{Tries to use a cached result set}
function _cache_useProcSetResult(cacheEntry:String;const procRulesCrc32:String;var saveRecord:Boolean;var sTag:String):Boolean;
var
	madeModifications: Boolean;
	i,crc32PosEnd: Integer;
	tmpStr: String;
	tmpLst: TStringList;
begin
	
	// Validation of cache
	crc32PosEnd := Pos(#9,cacheEntry);
	if (procRulesCrc32 = '' ) or (crc32PosEnd = 0) then
		_pDR_cacheRR_curEntryIsValid := false;
	if Copy(cacheEntry,1,crc32PosEnd-1) <> procRulesCrc32 then
		_pDR_cacheRR_curEntryIsValid := false;
	if not _pDR_cacheRR_curEntryIsValid then
		Exit;
		
	cacheEntry := Copy(cacheEntry,crc32PosEnd+1,1000);

	if cacheEntry = '#NO_RESULT#' then
		Exit;
	
	// Multi entry? 
	if Pos(#9,cacheEntry) > 0 then begin
		tmpLst := Split(#9,cacheEntry);
		if tmpLst.Count > 1 then
			for i := 0 to tmpLst.Count - 2 do begin
				tmpStr := tmpLst[i]; // Own variable because param is var
				_processSpecialTagIdent(tmpStr, sTag, saveRecord,madeModifications);
				end;
		// Set final tag
		tmpStr := tmpLst[tmpLst.Count-1];
		tmpLst.Free;
		end
	else // single entry 
		tmpStr := cacheEntry;
		
	// Final tag available? 
	if tmpStr <> '#NO_RESULT#' then
		if Pos('SPECIAL:',tmpStr) = 0 then begin
			Result := true;
			sTag := tmpStr;
			if sTag = 'IGNORE' then
				saveRecord := false;
			Exit;
			end
		else
			_pDR_cacheRR_curEntryIsValid := false;
end;


{Write the RR cache }
procedure _cache_writeProcSetResult(const procRuleSetFullQualName:String;const cacheIdent:String; newCacheEntry:String);
var i, taintIndex:Integer;
	storedTaints: String;
	sectionCacheCur, sectionCacheNew: TStringList;
begin
	if newCacheEntry = '' then
		newCacheEntry := 'INVALID';
		
	if not setEntryLevelTwo('dynamicPatcherRuleSetResults', procRuleSetFullQualName, cacheIdent, newCacheEntry, sectionCacheCur, sectionCacheNew) then begin
		// New head cache ?
		d(procRuleSetFullQualName);
		Exit;
		end;
	
	// Stats
	Inc(_pDR_cacheInvalidationsRR);
	
	// Validate that taint is stored by sublist
	if _pDR_cacheCurrentRuleSetTaints.Count = 0 then 
		Exit;

	// AddMessage('Taints: '+_pDR_cacheCurrentRuleSetTaints.CommaText);
	taintIndex := sectionCacheCur.IndexOfName('RULESET_TAINTS');
	storedTaints := sectionCacheNew.ValueFromIndex[taintIndex];
	// It must be available...
	for i := 0 to _pDR_cacheCurrentRuleSetTaints.Count - 1 do
		if ( Pos(_pDR_cacheCurrentRuleSetTaints.Names[i], storedTaints) = 0 ) then begin
			// Taint missing. add item
			storedTaints := storedTaints + ',' + _pDR_cacheCurrentRuleSetTaints.Names[i];
			sectionCacheNew.ValueFromIndex[taintIndex] := storedTaints;
			
			// In and revalidate section cache
			CustomRuleSets.cache_validateRuleSetSectionCache(procRuleSetFullQualName,sectionCacheCur, sectionCacheNew);
			end;
end;


{Processes one TagIdent. Returns true if the rule chain should be continued. }
function _processSpecialTagIdent(var ruleApplyTag:String;var sTag:String;var saveRecord:Boolean;var madeModifications:Boolean):Boolean;
var
	sFoundTagIdent, tmpStr: String;
	tmpLst: TStringList;
begin
	madeModifications := true;
	// Result = true for continue processing chain, false will apply ruleApplyTag to item

	// Special: DeleteEndTag
	if Pos('SPECIAL:FindCustomTag:',ruleApplyTag) = 1 then begin
		sFoundTagIdent := '';
		// Add taint to ruleset cache
		_pDR_cacheCurrentRuleSetTaints.values['TAINT:FindCustomTag'] := '1';
		if _findTagForWeaponByDynRules(pDR_record, Copy(ruleApplyTag,length('SPECIAL:FindCustomTag:')+1,length(ruleApplyTag)-length('SPECIAL:FindCustomTag:')),sFoundTagIdent) then
			ruleApplyTag := sFoundTagIdent
		else
			Result := true;
		Exit;
		end
	else if BeginsWithExtract('SPECIAL:PluginScript:',ruleApplyTag,tmpStr) then begin
		// Taint cache 
		_pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginScript:'+tmpStr] := '1';
		Result := CSPluginSystem.applyPluginScript(tmpStr,saveRecord,ruleApplyTag, sTag, madeModifications);
		Exit;
		end
	else if Pos('SPECIAL:AddKeyword:',ruleApplyTag) = 1 then begin
		Result := true; // Continue chain
		if globalModificationsAllowed then
			if _addKeywordToRecord(pDR_record,Copy(ruleApplyTag,length('SPECIAL:AddKeyword:')+1,length(ruleApplyTag)-length('SPECIAL:AddKeyword:'))) then
				saveRecord := true
			else
				AddMessage('Warning: Keyword "'+Copy(ruleApplyTag,length('SPECIAL:AddKeyword:')+1,length(ruleApplyTag)-length('SPECIAL:AddKeyword:'))+'" couldn''t added to record.');
		Exit;
		end
	else if Pos('SPECIAL:PregReplace:',ruleApplyTag) = 1 then begin
		tmpLst := TStringList.Create;
		tmpLst.Delimiter := ':';
		tmpLst.StrictDelimiter := true;
		tmpLst.DelimitedText := ruleApplyTag;
		
		if tmpLst.Count = 5 then begin
			DynamicPatcher.flushCacheFullName;
			tmpStr := getElementEditValues(pDR_record, tmpLst[2]);
			tmpStr := PregReplace(tmpLst[3],tmpLst[4],tmpStr);
			SetElementEditValues(pDR_record, tmpLst[2], tmpStr);
			saveRecord := true;
			Result := true;
			Exit;
			end;
		end
	else if Pos('SPECIAL:RemoveINRD',ruleApplyTag) = 1 then begin
		Result := true;
		if ElementExists(pDR_record,'INRD') then begin
			RemoveElement(pDR_record,'INRD');
			saveRecord := true;
			end;
		Exit;
		end
	
	_pDR_cacheRR_curEntryIsValid := false;
	AddMessage('WARNING: Unsupported or malformed SPECIAL-TagIdent: '+ruleApplyTag);
	Result := true;
	saveRecord := false;
	
	// Special rule: Set temp var
	{if Pos('SPECIAL:setVar:', ruleApplyTag) = 1 then begin
		tmpLst := Split(':',ruleApplyTag);
		_pDR_customVarValues.values[tmpLst[2]] := tmpLst[3];
		_pDR_customVarIsset.values[tmpLst[2]] := '1';
		tmpLst.Free;
		continue;
		end;}
					
end;

function _addKeywordToRecord(rec:IInterface;keyword:String):Boolean;
var
	keywords: IInterface;
	kwHex: String;
begin
	Result := false;
	
	// Check if already exists
	if not Assigned(pDR_keywords) then
		pDR_keywords := recordReadKeywords(pDR_record);
	
	if pDR_keywords.indexOf(keyword) > -1 then begin
		Result := true;
		Exit;
		end;
	
	// Try to add keyword
	kwHex := kywdCache.values[keyword];
	if kwHex = '' then
		Exit;
	keywords := ElementByName(rec,'KWDA - Keywords');
	if not Assigned(keywords) then
		Exit;
	SetEditValue(ElementAssign(keywords, HighInteger, nil, False), kwHex);
	Result := true;
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
	else if elmIdent = 'SPECIAL:MasterESP' then begin
		_pDR_customVarValues.values[elmIdent] := getBaseESPName(GetFileName(GetFile(MasterOrSelf(rec))));
		Exit
		end
	else if Pos('SPECIAL:TagIdent',elmIdent)=1 then begin
		_pDR_customVarIsset.values[elmIdent] := '1';
		_pDR_customVarValues.values[elmIdent] := sTag;
		end
	else if BeginsWithExtract('SPECIAL:PluginSetting:',elmIdent, tmpStr) then begin
		tmpLst := Split(':',tmpStr);
		_pDR_customVarIsset.values[elmIdent] := '1';
		_pDR_customVarValues.values[elmIdent] := CSPluginSystem.getPluginUserSetting(tmpLst[0],tmpLst[1]);
		tmpLst.Free;
		_pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginSetting:'+tmpStr] := '1';
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		end
	else begin
		AddMessage('Unknown special identifier: '+elmIdent);
		_pDR_cacheCurrentRuleSetTaints.values['TAINT:UNKNOWN_SPECIAL'] := '1';
		_pDR_customVarIsset.values[elmIdent] := '0';
		// No condition check cache!
		_pDR_conditionsChecked.values['cache_validation'] := '';
		end;
end;


{Proces special condition value}
procedure _processSpecialConditionValue(rec:IInterface;var conditionValue:String);
var tmpLst: TStringList;
begin
	if Pos('SPECIAL:PluginSetting:',conditionValue)=1 then begin
		tmpLst := Split(':',conditionValue);
		conditionValue := CSPluginSystem.getPluginUserSetting(tmpLst[2],tmpLst[3]);
		tmpLst.Free;
		_pDR_cacheCurrentRuleSetTaints.values['TAINT:PluginSetting:'+tmpLst[2]+':'+tmpLst[3]] := '1';
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
	// AddMessage('Scan weap: '+getEditorId(rec));
	for j := 0 to ElementCount(objTplCombs) - 1 do begin
		objElm := ElementByIndex(objTplCombs, j);
		if not ElementExists(objElm,'OBTF') and ElementExists(objElm,'Full - Name') then begin
			//SetElementEditValues(objElm, 'Full - Name', sTag+' '+getElementEditValues(objElm,'Full - Name'));
			recordAddTagString(sTag, 'FULL - Name', objElm,'');
			// AddMessage('Custom object template name for '+IntToHex(FormId(rec),8)+' : '+getElementEditValues(objElm,'Full - Name'));
			Result := true;
		end
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
	ruleKeywordsString, ruleApplyTag: String;
	i,j: int;
	match: Boolean;
begin
	Result := false;

	if not getSettingsBoolean('config.bHeuristicAddTagsToWeapons') then
		Exit;
	// Load rules set
	rulesSection := INNRProcessing.getDynamicNamingRulesSection(ruleSetName);
	
	keywords := recordReadKeywords(rec);

	// Test naming rules for application
	for j := 0 to rulesSection.Count - 1 do begin
		ruleKeywordsString := rulesSection.Names[j];
		ruleApplyTag := rulesSection.values[ruleKeywordsString];
		if ruleKeywordsString = 'ADD_EMPTY_RULESET' then
			continue;
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
			sTag := ruleApplyTag;
			Exit;
		end
	end;
	rulesSection.Free;
end;
	
(*
function _removePostTags():Boolean;
var
	sStr: String;
begin
	Result := false;
	if pDR_fullName = '' then
		pDR_fullName := GetElementEditValues(pDR_record, 'FULL');
	sStr := pDR_fullName;
	if (Pos('{',sStr) = 0 ) then
		Exit;
	sStr := pregReplace('\s*('
		+ '\{{1}[^\{\}]+\}{1}'
		+'|\{{2}[^\{\}]+\}{2}'
		+'|\{{3}[^\{\}]+\}{3}'
		+')$','',sStr);
	if (sStr <> '') and globalModificationsAllowed then begin
		pDR_fullName := sStr;
		Result := true;
		end;
		//SetElementEditValues(rec, sPath, sStr);
end;
*)
{function _addComponentTags():Boolean;
var
	elmCnt, i: Integer;
	cvpa: IInterface;
	tags, compName,compNativeLinkStr: String;
begin
	
	cvpa := ElementBySignature(pDR_record, 'CVPA');
	elmCnt := ElementCount(cvpa);
	Result := elmCnt > 0;
	if pDR_fullName = '' then
		pDR_fullName := GetElementEditValues(pDR_record, 'FULL');
	
	tags := '{{{';
	for i := 0 to elmCnt-1 do begin
		compNativeLinkStr := IntToStr(GetElementNativeValues(ElementByIndex(cvpa, i),'Component'));
		compName := pDR_cacheComponentNames.values[compNativeLinkStr];
		if compName = '' then begin
			compName := GetElementEditValues(LinksTo(ElementByName(ElementByIndex(cvpa, i), 'Component')), 'FULL');
			pDR_cacheComponentNames.values[compNativeLinkStr] := compName;
			end;
				
		if i = 0 then
			tags := tags + compName
		else
			tags := tags + ', ' + compName;
		end;
	}//tags := tags + '}}}';
	{
	pDR_fullName := pDR_fullName + tags;
end;}

{if filled, saves and cleans the cached "FULL - Name" entry}
procedure flushCacheFullName;
begin
	if pDR_fullName <> '' then begin
		SetElementEditValues(pDR_record, 'FULL - Name', pDR_fullName);
		pDR_fullName := '';
		end;
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