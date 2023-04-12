{
	M8r98a4f2s Complex Item Sorter for FallUI - Diagnostics
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Provides diagnostic tools
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}
unit Diagnostics;

implementation

{Init unit}
procedure init();
begin
	
end;

{Show generic diagnostic things for a given mod file}
procedure showGenericDiagnostic(modFile, recordType,useEditorId:String);
var
	i,j,iTaskIndex: Integer;
	diagMessage, taskIdent: String;
	afterMatchRules, csNamingRules, lstPrcTasks, lstRuleSetsPreFilter,lstRuleSetsPrcRules: TStringList;
	grp,rec,testRec: IInterface;
begin
	// Init stuff
	ScriptConfiguration.readTags();
	CustomRuleSets.init();
	DynamicPatcher.init();
	DynamicPatcher.initRecordProcessing();
	CSPluginScript.reinitCache();
	RecordLib.initKeywordCache();

	diagMessage := '';
	
	// Find target record
	rec := _getRecordByEditorIdFromFile(modFile,recordType,useEditorId);
	rec := WinningOverrideBefore(rec, mxPatchFile);
	
	if not Assigned(rec) then begin 
		ShowMessage('Record not found!');
		Exit;
		end;

	csNamingRules := INNRProcessing.getDynamicNamingRulesSection(EditorId(LinksTo(ElementByPath(rec,'INRD'))));
		
	diagMessage := diagMessage
		+ 'Show diagnostics for record: ['+recordType+':'+IntToHex(FormId(rec),8) + ']' + #13
		+ '  File: '+modFile+' (Winning override in: '+getFileName(getFile(rec))+')'+#13
		+ '  EditorId: ' + useEditorId + #13
		+ '  Name: "'+GetElementEditValues(rec,'FULL - Name')+'"'
		+ #13+#13;
	diagMessage := diagMessage + 'Involved mod files: '+_getRecordSourceFiles(rec)+#13;

	if recordType = 'INNR' then
		diagMessage := diagMessage + #13 + _showInnrDiagnostics(rec)
	else begin
			
		// Have an INRD entry?
		if (GetElementEditValues(rec,'INRD') <> '') and ((recordType='WEAP') or (recordType='ARMO')) then begin
			diagMessage := diagMessage + #13 + 'INRD entry'+#13+'------------'+#13+'Record has INRD entry: ' + GetElementEditValues(rec,'INRD') + #13;
			
			// Say sth to the way of processing INNR
			if not getSettingsBoolean('config.bHeuristicInjectRulesToWeaponsINNR') then 
				diagMessage := diagMessage + 'Heuristic injection disabled.'+#13
			else begin
				if recordType = 'WEAP' then 
					diagMessage := diagMessage + 'IMPORTANT: Due to this, this record marked as to be tagged by INNR rules. The TagIdent in the following processing rules will be IGNORED.'+#13;
				if csNamingRules.Count > 0 then
					diagMessage := diagMessage +'Dynamic naming rules exists for that INNR record. '
						+ 'The dynamic naming rules will be displayed below.'+#13
				else begin
					diagMessage := diagMessage +'No dynamic naming rules found. The INNR record '+EditorId(rec)+' will be extended by default dynamic naming rules for in-game-tagging.'+#13;
					end;
				end;
				
				end;

		// Get tasks
		Tasks.updateActiveTasks();
		lstPrcTasks := Tasks.getProcessingActiveTasks();
		for iTaskIndex := 0 to lstPrcTasks.Count-1 do begin 
			
			taskIdent := lstPrcTasks.Names[iTaskIndex];

			lstRuleSetsPreFilter := CustomRuleSets.getProccessingRuleSetsArray(taskIdent,'prefilter:',recordType,modFile);
			lstRuleSetsPrcRules := CustomRuleSets.getProccessingRuleSetsArray(taskIdent,'',recordType,modFile);

			if (lstRuleSetsPreFilter.Count = 0 ) and ( lstRuleSetsPrcRules.Count = 0 ) then 	
				continue;
			
			diagMessage := diagMessage + #13+'== TASK: '+lstPrcTasks.ValueFromIndex[iTaskIndex]+' =='+#13;
			
			// Init processing
			DynamicPatcher.startRecordProcessing(rec,recordType);
			
			// Diagnostics for pre-filter path
			diagMessage := diagMessage + #13 + 'Pre-filter rules path (only matched will be shown)'+#13+'-----------------------'+#13;
			diagMessage := diagMessage + '(Note: The first MATCH decides if the processing continues. Standard is to ignore record.)'+#13;
			diagMessage := diagMessage + _addDiagRules(rec,recordType,lstRuleSetsPreFilter);
			
			// Diagnostics for processing rules path
			diagMessage := diagMessage + #13 + 'Processing rules path (only matched will be shown)'+#13+'-----------------------'+#13;
			diagMessage := diagMessage + '(Note: Usually the first non-"SPECIAL:"-MATCH ends processing)'+#13;
			diagMessage := diagMessage + _addDiagRules(rec,recordType,lstRuleSetsPrcRules);

			// Apply plugins of type pluginRecordModifier
			afterMatchRules := CSPluginSystem.getPluginRuleSets(taskIdent, 'PluginRulesAfterMatch',recordType);
			if afterMatchRules.Count > 0 then begin
				diagMessage := diagMessage + #13 + 'AFTER-MATCH processing rules path (only matched will be shown)'+#13+'-----------------------'+#13;
				diagMessage := diagMessage + _addDiagRules(rec,recordType,afterMatchRules);
				end;
			end;
		end;

		// Add dynamic naming rules (if exists)
	if (csNamingRules.Count > 0) or Assigned(INNRProcessing.getInnrScripts(EditorId(LinksTo(ElementByPath(rec,'INRD'))))) then
		diagMessage := diagMessage + #13+_showInnrDiagnostics(LinksTo(ElementByPath(rec,'INRD')));
		
	ShowMessage(diagMessage);
	
	// Cleanup
	csNamingRules.Free;

end;

{Add diagnostics for a rulesets array}
function _addDiagRules(rec:IInterface; recordType:String;procRuleSets: TStringList):String;
var
	i: Integer;	 
	rulesetIdent, sTag: String;
begin
	Result := '';
	for i:= 0 to procRuleSets.Count - 1 do begin
		rulesetIdent := '';
		SplitSimple('>',procRuleSets[i],rulesetIdent,nil);
		Result := Result + #13 + 'Rule set: '+procRuleSets[i] + #13+'  defined in: '
			+ StringReplace(crsRuleSetIniFiles.Values[rulesetIdent],sComplexSorterBasePath,'',[rfReplaceAll]);
		Result := Result + #13 + _dryRunRuleset(rec,recordType,procRuleSets.Objects[i],sTag);
		end;
end;


{Diagnostic for INNR records}
function _showInnrDiagnostics(rec:IInterface):String;
var
	csNamingRules, innrChecksum, innrScripts: TStringList;
	i,j: Integer;
begin
	INNRProcessing.init();
	csNamingRules := INNRProcessing.getDynamicNamingRulesSection(EditorId(rec));
	csNamingRules.Delimiter := #13;
	innrChecksum := INNRProcessing.getInnrChecksumList(rec);

	Result := '';
	
	// INNR script
	innrScripts := INNRProcessing.getInnrScripts(EditorId(rec));
	if Assigned(innrScripts) then begin
		for i := 0 to innrScripts.Count -1 do begin
			Result := Result + 'INNR script - defined in '+StringReplace(innrScripts.Strings[i],sComplexSorterBasePath,'',[rfReplaceAll])+#13
				+'----------------------------'+#13
				;
			for j := 0 to innrScripts.Objects[i].Count -1 do 
				Result := Result + innrScripts.Objects[i].Strings[j] + #13;
			Result := Result + #13;
			end;
		end;
	
	// Dynamic naming rules
	Result := Result + 'Dynamic naming rules for: '+EditorId(rec)
			+' (Checksum: '+innrChecksum.CommaText+')'
			+#13+'----------------------------'+#13;
	if Assigned(csNamingRules) then 
		Result := Result + csNamingRules.DelimitedText
	else 
		Result := Result + 'No dynamic rules found.';
	
	// Cleanup
	csNamingRules.Free;
	innrChecksum.Free;
end;

{Tests a given rule set in a dry run}
function _dryRunRuleset(rec:IInterface;recordType:String;procRuleSetSection:TStringList;var sTag:String):String;
var 
	match, madeModifications, bEndRuleset: Boolean;
	i,j, matches:Integer;
	ruleConditionsLst, conditionPack: TStringList;
	ruleApplyTag, conditionString, conditionResult, cacheEntry, procRuleSetValStr, newCacheEntry: String;
begin
	Result := '';
	matches := 0;
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
			continue
			//Result := Result + '    [no match] '
		else begin
			Result := Result + '    [MATCH - TagIdent: '+procRuleSetSection[i]+']    ';
			Inc(matches);
			end;
		Result := Result + Copy(ruleConditionsLst.CommaText,1,80)+'...' + ' = ' + procRuleSetSection[i] + #13;

		end;
	if matches = 0 then 
		Result := Result + '    (no matches)'+#13;
end;

{Fetch a single record from a given file by EDID}
function _getRecordByEditorIdFromFile(modFile,recordType,searchEditorId:String):IInterface;
var
	i,j: Integer;
	grp,rec: IInterface;
begin
	for i := 0 to FileCount - 2 do
		if getFileName(FileByLoadOrder(i)) = modFile then begin
			grp := GroupBySignature(FileByLoadOrder(i), recordType);
			for j := 0 to ElementCount(grp) -1 do begin
				rec := ElementByIndex(grp, j);
				if EditorId(rec) = searchEditorId then begin
					Result := rec;
					Exit;
					end;
				end;
			end;

end;

{Creates the index of record source files}
function _getRecordSourceFiles(srcRec:IInterface):String;
var 
	rec: IInterface;
	j: Integer;
	tmpLst: TStringList;
begin
	tmpLst := TStringList.Create;

	rec := MasterOrSelf(srcRec);
	// "Reversed" display for load order like
	tmpLst.append(getFileName(getFile(rec)));
	for j := 0 to OverrideCount(rec) - 1 do 
		tmpLst.append(getFileName(getFile(OverrideByIndex(rec,j))));
	Result := StringReplace(tmpLst.CommaText,',',', ',[rfReplaceAll]);
	tmpLst.Free;
end;

{Cleanup unit}
procedure cleanup();
begin
	
end;

end.