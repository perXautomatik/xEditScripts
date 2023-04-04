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

unit INNRProcessing;

var
	// private 
	_tlWeapArmoINNR: TStringList;
	_innrProcUnitInited: Boolean;
	_tlMeleeANIM, _tlGunANIM: TStringList;
	_rulesDynamicNaming: TMemIniFile;
	_transManualRules,_transTo: TStringList;
	_transFrom: THashedStringList;
	_dynNamesRegistry: THashedStringList;
	_dynInnrScriptRegistry: THashedStringList;
	_infoOnlyOnceIndex: TStringList;
	_lstAutoTagKeywords: THashedStringList;
	_lstAutoDynamicRules: THashedStringList;
	_lstAutoDynamicResults: THashedStringList;
	_tlPatched: THashedStringList;


implementation

{Initialise unit}
procedure init;
begin
	if _innrProcUnitInited then 
		Exit;
	_innrProcUnitInited := true;
	
	_readNamingRulesConfig();
	if not Assigned(_tlWeapArmoINNR) then begin		
		_tlWeapArmoINNR := TStringList.Create;
		_tlWeapArmoINNR.add('DLC01dn_LightningGun');
		_tlWeapArmoINNR.add('DLC01dn_PowerArmor');
		_tlWeapArmoINNR.add('DLC03_dn_CommonArmor');
		_tlWeapArmoINNR.add('DLC03_dn_CommonGun');
		_tlWeapArmoINNR.add('DLC03_dn_CommonMelee');
		_tlWeapArmoINNR.add('DLC03_dn_Legendary_Armor');
		_tlWeapArmoINNR.add('DLC03_dn_Legendary_Weapons');
		_tlWeapArmoINNR.add('DLC04_dn_CommonArmorUpdate');
		_tlWeapArmoINNR.add('DLC04_dn_CommonGunUpdate');
		_tlWeapArmoINNR.add('DLC04_dn_CommonMeleeUpdate');
		_tlWeapArmoINNR.add('dn_Clothes');
		_tlWeapArmoINNR.add('dn_CommonArmor');
		_tlWeapArmoINNR.add('dn_CommonGun');
		_tlWeapArmoINNR.add('dn_CommonMelee');
		_tlWeapArmoINNR.add('dn_DLC04_PowerArmor_Overboss');
		_tlWeapArmoINNR.add('dn_PowerArmor');
		_tlWeapArmoINNR.add('dn_VaultSuit');
		_tlWeapArmoINNR.add('dn_DLC04_PowerArmor_NukaCola');
		_tlWeapArmoINNR.add('dn_DLC04_PowerArmor_Quantum');
		end;

	// create animation lists
	if not Assigned(_tlMeleeANIM) then begin 
		_tlMeleeANIM := TStringlist.create;
		_tlMeleeANIM.add('HandToHandMelee');
		_tlMeleeANIM.add('OneHandAxe');
		_tlMeleeANIM.add('OneHandDagger');
		_tlMeleeANIM.add('OneHandMace');
		_tlMeleeANIM.add('OneHandSword');
		_tlMeleeANIM.add('TwoHandAxe');
		_tlMeleeANIM.add('TwoHandSword');
		end;
	
	if not Assigned(_tlGunANIM) then begin
		_tlGunANIM := TStringlist.create;
		_tlGunANIM.add('Bow');
		_tlGunANIM.add('Gun');
		_tlGunANIM.add('Staff');
		end;
	
	if not Assigned(_infoOnlyOnceIndex) then 
		_infoOnlyOnceIndex := TStringList.Create;
	// Auto dynamic rules
	if not Assigned(_lstAutoDynamicRules) then 
		_lstAutoDynamicRules := THashedStringList.Create;
	if not Assigned(_lstAutoTagKeywords) then 
		_lstAutoTagKeywords := THashedStringList.Create;
	if not Assigned(_lstAutoDynamicResults) then 
		_lstAutoDynamicResults := THashedStringList.Create;
	if not Assigned(_tlPatched) then
		_tlPatched := THashedStringList.Create;

	_dynInnrScriptRegistry := THashedStringList.Create;
end;


{Process the INNR records as last process of patching}
procedure processINNR();
var 
	rec: IInterface;
	i: Integer;
	records: TStringList;
begin
	records := recordsIndex.Objects[recordsIndex.indexOf('INNR')];
	AddMessage('Processing '+IntToStr(records.Count)+' INNR records...');
	for i := records.Count-1 downto 0 do begin
		rec := ObjectToElement(records[i]);
		if not _patchRecordINNR(rec) then
			if _tlPatched.indexOf(GetElementEditValues(rec, 'EDID')) = -1 then
				Remove(rec);
		end;
end;


{Created the translation index used in other inner methods}
procedure buildTranslationIndex();
var
	iniFile: TIniFile;
	rec,m,ruleset,names,nameset,keywords,keyword:IInterface;
	k,i,j,l: Integer;
	nameStr, nameClean: String;
	transIdent:String;
	records: TStringList;
begin
	// Get preindexed INNR records
	records := recordsIndex.Objects[recordsIndex.indexOf('INNR')];
	AddMessage('Prebuilding translation index using '+IntToStr(records.Count)+' INNR records... ');

	// Init submodule translation
	if not Assigned(_transFrom) then begin
		_transFrom := TStringList.Create;
		_transTo := TStringList.Create;
		// Manual rules
		_transManualRules := TStringList.Create;
		if FileExists(sComplexSorterBasePath+'Rules (User)\autotranslation.ini') then
			iniFile := TIniFile.Create(sComplexSorterBasePath+'Rules (User)\autotranslation.ini')
		else
			iniFile := TIniFile.Create(sComplexSorterBasePath+'Rules (Default)\autotranslation.ini');
		iniFile.ReadSectionValues('ManualRules', _transManualRules);
		iniFile.Free;
	end;

	// Process each INNR
	for l := records.Count-1 downto 0 do begin 
		rec := ObjectToElement(records[l]);
		// Find last entry in target language
		// m := ElementByName(WinningOverrideBefore(rec, r88SimpleSorterInnrEsp), 'Naming Rules');
		m := ElementByName(Master(rec), 'Naming Rules');
		for k := 0 to ElementCount(m)-1 do begin
			ruleset := ElementByIndex(m, k);
			if GetElementEditValues(ruleset,'VNAM - Count') = 0 then
				continue;
			names := ElementByName(ruleset, 'Names');
			for i := 0 to ElementCount(names)-1 do begin
				nameset := ElementByIndex(names, i);
				nameStr := GetElementEditValues(nameset,'WNAM');
				nameClean := pregReplace('(^[\[|]\s*|\s*[\]|]$|^\s+|\s+$)','',nameStr);
				transIdent := GetElementEditValues(rec, 'EDID');
				keywords := ElementByName(nameset, 'KWDA - Keywords');
				for j := 0 to ElementCount(keywords)-1 do
					transIdent := transIdent +'+'+ GetElementEditValues(WinningOverride(LinksTo(ElementByIndex(keywords,j))), 'EDID');

				//AddMessage('Trans: '+transIdent+' -> "'+nameClean+'"');
				if nameClean <> '' then begin
					//if ( _transFrom.indexOf(transIdent) >= 0 ) then
					//	AddMessage('Double: '+transIdent+ '	Saved:	'+_transTo[_transFrom.indexOf(transIdent)]+' Current: '+nameClean);
					_transFrom.Add(transIdent);
					_transTo.Add(nameClean);
					end;
				end;
			end;
		end;
end;

{Patches INNR records}
function _patchRecordINNR(rec: IInterface):Boolean;
var
	innrEditorId: String;
	rulesLst : TStringList;
	flagDynNamesAlreadyInserted:Boolean;
begin
	Result := False;
	if not globalModificationsAllowed then begin
		AddMessage('Prefilter rule misconfiguration! This could lead to modified source files. Action is not executed.');
		Exit;
		end;
	// Get edid
	innrEditorId := GetElementEditValues(rec, 'EDID');

	// Translate INNR 
	if getSettingsBoolean('config.bTranslateINNR') and (_tlWeapArmoINNR.indexOf(innrEditorId) >= 0)
		and Assigned(r88SimpleSorterInnrEsp) then
		Result := _processTranslation(rec) or Result;
	
	// Modification script?
	flagDynNamesAlreadyInserted := False;
	if _dynInnrScriptRegistry.indexOf(innrEditorId) > -1 then 
		_applyInnrScripts(rec,innrEditorId, Result,flagDynNamesAlreadyInserted);

	// Rules to inject available? 
	if not(flagDynNamesAlreadyInserted) and ( _dynNamesRegistry.indexOf(innrEditorId) > -1 ) then 
		_appendRulesToInnrRecord(rec, nil, Result);
		
	// Include all R88?
	if getSettingsBoolean('config.bIncludeR88InnrRules') and Assigned(r88SimpleSorterInnrEsp) then
		if OverrideExistsIn(rec, r88SimpleSorterInnrEsp) then
			Result := true;
	
end;

{Called for WEAP entries with a INNR entry - Patches WEAP records with dynamic naming rules in records linked INNR}
function patchWEAPWithNamingRules(rec: IInterface):Boolean;
var
	innr: IInterface;
	animType: String;
begin
	Result := false;
	// Safety first 
	if not globalModificationsAllowed then begin
		AddMessage('Prefilter rule misconfiguration! This could lead to modified source files. Action is not executed.');
		Exit;
		end;
		
	// Enabled? 
	if not getSettingsBoolean('config.bHeuristicInjectRulesToWeaponsINNR') then
		Exit;
	//if ( Pos('INNR',getSettingsString('config.sUseRecords', '')) = 0 ) then
	if lstUseRecordTypes.indexOf('INNR') = -1 then
		Exit;
	// Find responsible INNR
	innr := LinksTo(ElementBySignature(rec, 'INRD'));
		
	// Vanilla rules already fully covered 
	if (_tlWeapArmoINNR.indexOf(GetElementEditValues(WinningOverride(innr), 'EDID')) >= 0) then begin
		Result := true;
		Exit;
	end;

	// Safety 
	if GetFileName(GetFile(innr)) <> GetFileName(mxPatchFile) then begin
		AddMessage('INNR record is not available in patch, cannot inject rules. ('+GetFileName(GetFile(innr))+','+GetFileName(mxPatchFile)+')');
		Exit;
		end;

	// Try to inject 
	animType := GetElementEditValues(rec,'DNAM - Data\Animation Type');
	if _tlGunANIM.indexOf(animType) > -1 then
		_appendRulesToInnrRecord(innr,'_custom_INNR_guns', Result)
	else if _tlMeleeANIM.indexOf(animType) > -1 then
		_appendRulesToInnrRecord(innr,'_custom_INNR_melee', Result)
	else
		AddMessage('Unknown Animation type for INNR patching: ' + animType);
	
end;


{Processing the INNR records for translation}
function _processTranslation(rec:IInterface):Boolean;
var
	namingRule,ruleset,names,nameset,keywords:IInterface;
	k,i,j: Integer;
	nameStr, nameClean: String;
	transIdent, translated, translatedCorrected:String;
begin
	Result := False;
	if not globalModificationsAllowed then begin
		AddMessage('Prefilter rule misconfiguration! This could lead to modified source files. Action is not executed.');
		Exit;
		end;
	// Process current innr's
	namingRule := ElementByName(rec, 'Naming Rules');
	for k := 0 to ElementCount(namingRule)-1 do begin
		ruleset := ElementByIndex(namingRule, k);
		if ( GetElementEditValues(ruleset,'VNAM - Count') = 0 ) then
			continue;
		names := ElementByName(ruleset, 'Names');
		for i := 0 to ElementCount(names)-1 do begin
			nameset := ElementByIndex(names, i);
			nameStr := GetElementEditValues(nameset,'WNAM');
			nameClean := pregReplace('(^[\[|]\s*|\s*[\]|]$|^\s+|\s+$)','',nameStr);
			transIdent := GetElementEditValues(rec, 'EDID');
			keywords := ElementByName(nameset, 'KWDA - Keywords');
			for j := 0 to ElementCount(keywords)-1 do begin
				transIdent := transIdent +'+'+ GetElementEditValues(WinningOverride(LinksTo(ElementByIndex(keywords,j))), 'EDID');
			end;
			translated := nil;
			if ( _transFrom.indexOf(transIdent) >= 0 ) then
				translated := _transTo[_transFrom.indexOf(transIdent)]
			else if Assigned(_transManualRules.values[transIdent] ) then begin
				// Apply manual translation rule
				transIdent := _transManualRules.values[transIdent];
				if ( _transFrom.indexOf(transIdent) >= 0 ) then
					translated := _transTo[_transFrom.indexOf(transIdent)];
			end;
			
			if Assigned(translated) then	begin
				translatedCorrected := StringReplace(nameStr, nameClean, translated, [rfReplaceAll]);
				if ( nameStr <> translatedCorrected ) then begin
					//AddMessage('Found: "'+nameStr+'" -clean> "'+nameClean+'" -trans> "'+translated+'" -cor> "'+translatedCorrected+'"');
					SetElementEditValues(nameset, 'WNAM', translatedCorrected);
					Result := True;
				end;
			end
			else if nameClean <> '' then
				AddMessage('Info: Automatic translation not available for "'+nameStr+'" (internal match key: '+transIdent+').');
		end;
	end;
end;

{Shift the "*" rule in INNR record to the top}
function _moveAsterixToTop(rec:IInterface):Boolean;
var
	namingRules, ruleset: IInterface;
	i, asterixPosition: Integer;
begin
	Result := false;
	if not globalModificationsAllowed then begin
		AddMessage('Prefilter rule misconfiguration! This could lead to modified source files. Action is not executed.');
		Exit;
		end;
	
	// Get naming rules field 
	namingRules := ElementByName(rec, 'Naming Rules');
	if Assigned(namingRules) then begin
		// Find Asterix
		asterixPosition := -1; 
		for i := 0 to ElementCount(namingRules) -1 do 
			if GetElementEditValues(ElementByIndex(namingRules, i),'Names\Name\WNAM - Text') = '*' then begin 
				asterixPosition := i;
				break;
				end;
		// If found, shift it up! 
		if asterixPosition = -1 then 
			AddMessage('Could not find Asterix(*) entry for '+GetElementEditValues(rec, 'EDID'))
		else begin 
			Result := true;
			ruleset := ElementByIndex(namingRules, asterixPosition);
			while CanMoveUp(ruleset) do
				MoveUp(ruleset);
			end;
	end;
end;

{Modifies a INNR on a instruction set}
function _applyINNRModificationInstructions(rec:IInterface;instSet:String):Boolean;
var 
	lstActions,lstActionParts:TStringList;
	sAction, sContent: String;
	i: Integer;
begin
	try 
	lstActions := TStringList.Create;
	lstActionParts := TStringList.Create;

	// Process actions
	lstActions.Delimiter := ' ';
	lstActions.StrictDelimiter := True;
	lstActions.DelimitedText := instSet;
	lstActionParts.Delimiter := ':';
	lstActionParts.StrictDelimiter := True;
	
	for i:= 0 to lstActions.Count - 1 do begin
		if Trim(lstActions[i]) = '' then 
			continue;
			
		lstActionParts.DelimitedText := lstActions[i];
		if lstActionParts.Count = 0 then
			continue;
		sAction := lstActionParts[0];
		lstActionParts.Delete(0);
		//sContent := lstActionParts[1];
		sContent := lstActionParts.DelimitedText;
		if ( i = 0 ) and ( sAction <> 'check' ) then 
			AddMessage('WARNING: First INNR modification for "'+EditorId(rec)+'" action isn''t a "check" action');
			
		// Action: Check
		if sAction = 'check' then 
			if not _applyINNRModCheck(rec,sContent) then
				Exit
			else
				AddMessage('Executing modification based on INNR instructions for '+EditorId(rec));
				
		// Action: New order
		if sAction = 'neworder' then 
			_applyINNRModNewOrder(rec,sContent, Result);
				
		end;
	
	finally
	if Assigned(lstActions) then lstActions.Free;
	if Assigned(lstActionParts) then lstActionParts.Free;
	end;
end;

{Executes the Innr checksum check}
function _applyINNRModCheck(rec: IInterface;sCheck:String):Boolean;
var 
	lst3:TStringList;
begin
	Result := false;
	try 
		lst3 := getInnrChecksumList(rec);
				
		// Check conditions
		if lst3.CommaText = sCheck then 
			Result := True
		else
			AddMessage('Info: INNR checksum for '+EditorId(rec)+' doesn''t match instruction set checksum. Skipping instruction set.'
				+' - INNR checksum: '+lst3.CommaText+' Instruction checksum: '+sCheck+'');
			
	finally
		FreeAndNil(lst3);
		end;
end;

{Create a checksum for an INNR from a namingRules child. Needs to be freed.}
function getInnrChecksumList(rec:IInterface):TStringList;
var
	namingRules,ruleset, names: IInterface;
	i:Integer;
begin
	Result := TStringList.Create;

	namingRules := ElementByName(rec, 'Naming Rules');

	// Available? 
	if not Assigned(namingRules) then 
		Exit;

	// Create checksum and index
	for i:= 0 to ElementCount(namingRules) - 1 do begin 
		ruleset := ElementByIndex(namingRules, i);
		names := ElementByName(ruleset,'Names');
		if Assigned(names) then
			Result.Add(IntToStr(ElementCount(names)))
		else 
			Result.Add('0');
		end;
		
	// Remove trailing 0
	for i:= Result.Count - 1 downto 0 do 
		if Result[i] = '0' then 
			Result.Delete(i)
		else
			break;
end;

{Reorders INNR rulesets}
procedure _applyINNRModNewOrder(rec: IInterface;sNewOrder:String;var saveRecord:Boolean);
var
	i,j,iOldPos,iCurPos,iMaxValInnrIndex: Integer;
	lstNewOrder, lstIndex, lstCurrentPos:TStringList;
	namingRules,ruleset, names: IInterface;
	bPipeIt, bRemoveTagChars, bClearEntries: Boolean;
begin

	// Initial
	namingRules := ElementByName(rec, 'Naming Rules');
	if not Assigned(namingRules) then 
		Exit;

	try
	lstNewOrder := TStringList.Create;
	lstIndex := TStringList.Create;
	lstCurrentPos := TStringList.Create;
	
	// Check all available? 
	if sNewOrder = '' then
		Exit; 
	
	lstNewOrder.DelimitedText := sNewOrder;

	// Max valid innr index
	iMaxValInnrIndex := 0;
	for i:= 0 to ElementCount(namingRules) - 1 do
		if ElementCount(ElementByName(ElementByIndex(namingRules, i),'Names')) > 0 then
			iMaxValInnrIndex := i + 1;

	if lstNewOrder.Count <> iMaxValInnrIndex then begin 
		AddMessage('Warning for modification instructions for '+EditorId(rec)+': New order count mismatch ruleset count'
			+ ' - INNR ruleset count: '+IntToStr(iMaxValInnrIndex)+' instruction neworder count: '+IntToStr(lstNewOrder.Count));
		Exit;
		end;

	
	// Create index
	for i:= 0 to lstNewOrder.Count -1 do begin
		lstIndex.AddObject(IntToStr(i),TObject(ElementByIndex(namingRules, i)));
		lstCurrentPos.Add(IntToStr(i));
		end;
	
	// Execute instructions		
	for i:= lstNewOrder.Count - 1 downto 0 do begin 
		// Remove existing tag characters? 
		bRemoveTagChars := Pos('R', lstNewOrder[i]) = 1;
		if bRemoveTagChars then
			lstNewOrder[i] := Copy(lstNewOrder[i],2,length(lstNewOrder[i])-1);
		
		// Clear ruleset? 
		bClearEntries := Pos('C', lstNewOrder[i]) = 1;
		if bClearEntries then
			lstNewOrder[i] := Copy(lstNewOrder[i],2,length(lstNewOrder[i])-1);
		
		// Add a prepending pipe char? 
		bPipeIt := Pos('|', lstNewOrder[i]) = 1;
		if bPipeIt then
			lstNewOrder[i] := Copy(lstNewOrder[i],2,length(lstNewOrder[i])-1);
		
		iOldPos := StrToInt(lstNewOrder[i]);
		ruleset := ObjectToElement(lstIndex.Objects[iOldPos]);
		
		if bRemoveTagChars then 
			_removeExistingTagChars(ruleset, saveRecord);
			
		if bClearEntries then 
			_clearINNRRuleset(ruleset, saveRecord);
			
		if bPipeIt then 
			_addPipesToRuleset(ruleset, saveRecord);
			
		if CanMoveUp(ruleset) then 
			saveRecord := true;
		while CanMoveUp(ruleset) do
			MoveUp(ruleset);
		
		end;

	finally
		FreeAndNil(lstNewOrder);
		FreeAndNil(lstIndex);
		FreeAndNil(lstCurrentPos);

	end;
end;

{Clears a whole ruleset}
procedure _clearINNRRuleset(ruleset:IInterface;var saveRecord:Boolean);
var
	i: Integer;
begin
	if ElementCount(ruleset) > 0 then 
		saveRecord := True;
	for i := ElementCount(ruleset) - 1 downto 0 do 
		Remove(ElementByIndex(ruleset,i));
end;

{Add pre-leading pipes to a given ruleset}
procedure _addPipesToRuleset(ruleset: IInterface;var saveRecord:Boolean);
var 
	i:Integer;
	names: IInterface;
begin
	names := ElementByName(ruleset, 'Names');
	if ElementCount(names) > 0 then 
		saveRecord := True;
	for i := 0 to ElementCount(names) - 1 do
		SetElementEditValues(ElementByIndex(names,i),'WNAM','| '+GetElementEditValues(ElementByIndex(names,i),'WNAM'));
end;

{Removes existing tag characters in a given ruleset}
procedure _removeExistingTagChars(ruleset: IInterface;var saveRecord:Boolean);
var 
	i:Integer;
	names: IInterface;
	old,new: String;
begin
	names := ElementByName(ruleset, 'Names');
	for i := 0 to ElementCount(names) - 1 do begin
		old := GetElementEditValues(ElementByIndex(names,i),'WNAM');
		new := pregReplace('(^\s*[\[({|])','', pregReplace('([\])}|]\s*$)','', old));
		if new = old then 
			continue;
		saveRecord := True;
		SetElementEditValues(ElementByIndex(names,i),'WNAM', new);
		end;
end;

{Custom injection for innr rules}
function _appendRulesToInnrRecord(rec: IInterface; defaultINNREdid:String;var saveRecord:Boolean):Integer;
var
	rulesSection,rulesKeywords: TStringList;
	sEditorId, ruleKeywords, ruleApplyTag: String;
	namingRules, ruleset, names,name, keywords: IInterface;
	i,j: Integer;
	allKeywordsAvailable: Boolean;
begin
	Result := -2; // Inserted ruleset index (-2 = "none")

	//Result := false;
	if not globalModificationsAllowed then begin
		AddMessage('Prefilter rule misconfiguration! This could lead to modified source files. Action is not executed.');
		Exit;
		end;
	
	sEditorId := GetElementEditValues(rec, 'EDID');
	
	// Already patched?
	if (_tlPatched.indexOf(sEditorId) >= 0) then begin
		saveRecord := true;
		Exit;
	end;

	// Reading rules
	rulesSection := getDynamicNamingRulesSection(sEditorId);
			
	if ( rulesSection.Count = 0 ) and Assigned(defaultINNREdid) then begin
		rulesSection := getDynamicNamingRulesSection(defaultINNREdid);
		AddMessage('Add dynamic tagging to custom INNR: ' + sEditorId+' - Injecting rules: '+defaultINNREdid);
		end;
	
	// Special rules: MOVE_ASTERIX_TO_TOP, MODIFICATION_INSTRUCTIONS
	if rulesSection.Count > 0 then
		for j := rulesSection.Count - 1 downto 0  do begin 
			if rulesSection.Names[j] = 'MOVE_ASTERIX_TO_TOP' then begin
				saveRecord := _moveAsterixToTop(rec) or saveRecord;
				rulesSection.Delete(j);
				continue;
				end;
			if rulesSection.Names[j] = 'MODIFICATION_INSTRUCTIONS' then begin
				saveRecord := _applyINNRModificationInstructions(rec, rulesSection.ValueFromIndex[j]) or saveRecord;
				rulesSection.Delete(j);
				continue;
				end;
			end;
	
	// Inject found rules to INNR record
	if rulesSection.Count > 0 then begin
		namingRules := ElementByName(rec, 'Naming Rules');
		if Assigned(namingRules) then begin
			
			// Create new Ruleset
			ruleset := ElementAssign(namingRules, HighInteger, nil, false);	 // New 'Ruleset' added to end
			saveRecord := true;
			Result := 0; // Will be moved to 0 later
			
			names := ElementByName(ruleset,'Names');
			
			// new names record field? 
			if ( rulesSection.Count > 1 ) or ( rulesSection.Names[j] <> 'ADD_EMPTY_RULESET' ) then
				if not Assigned(names) then
					names := ElementAssign(ruleset, 1, nil, False);
			
			for j := 0 to rulesSection.Count - 1 do begin
				ruleKeywords := rulesSection.Names[j];
				ruleApplyTag := rulesSection.values[ruleKeywords];
				ruleApplyTag := tagNames.values[ruleApplyTag];

				if ruleKeywords = 'ADD_EMPTY_RULESET' then
					continue;

				// Check all keywords available
				rulesKeywords := Split(',',ruleKeywords);
				allKeywordsAvailable := true;
				if ruleKeywords <> '*' then
					for i := 0 to rulesKeywords.Count - 1 do
						if _lstAutoDynamicRules.indexOf(sEditorId) = -1 then // Ignore auto lists
							if not keywordReferenceExists(Trim(rulesKeywords[i])) then begin
								AddMessage('Warning: Keyword "'+rulesKeywords[i]+'" not available. Skipping entry.');
								allKeywordsAvailable := false;
								break;
								end
							else if not canKeywordUsedInCurrentPatchFile(Trim(rulesKeywords[i]),true) then begin 
								if _infoOnlyOnceIndex.Values['infoMasterNotAvail-'+rulesKeywords[i]] = '' then begin 
									_infoOnlyOnceIndex.Values['infoMasterNotAvail-'+rulesKeywords[i]] := '1';
									AddMessage(' Info: Keyword "'+rulesKeywords[i]+'"'' master not available. Skipping entry. (Info will be only displayed once)');
									end;
								allKeywordsAvailable := false;
								break;
								end;
				
				// Skip if keywords missing
				if not allKeywordsAvailable then begin
					rulesKeywords.Free;
					continue;
					end;
				
				if j = 0 then
					name := ElementByName(names, 'Name')  // New 'Names' to Ruleset, links to 'Name'
				else
					name := ElementAssign(names, ElementCount(names), nil, false);
				
				// All ok?
				if (ruleApplyTag = '' ) then
					AddMessage('WARNING: Missing tag definition for: "'+rulesSection.values[ruleKeywords]+'"!');

				// Set naming rule WNAM
				SetElementEditValues(name, 'WNAM', ruleApplyTag);

				// Set naming rule conditions
				if (ruleKeywords <> '') and (ruleKeywords <> '*') then begin
					keywords := ElementAssign(name, 2, nil, False);
					// Created keywords? 
					if _lstAutoDynamicRules.indexOf(sEditorId) <> -1 then begin
						for i := 0 to rulesKeywords.Count - 1 do
							SetEditValue(ElementAssign(keywords, HighInteger, nil, False), _lstAutoTagKeywords.Values[rulesKeywords[i]+'-rev']);
						end
					else for i := 0 to rulesKeywords.Count - 1 do
						recordAddKeyword(keywords, Trim(rulesKeywords[i]));
					
					end;
				rulesKeywords.Free;
				end;
			// Move new rules to the top!
			while CanMoveUp(ruleset) do
				MoveUp(ruleset);
			end;
		end;

	// Remember patching
	if saveRecord then 
		_tlPatched.add(sEditorId);
						

		
	// Cleanup
	if Assigned(rulesSection) then rulesSection.Free;
end;


{Reads the configuration for dynamic naming rules and INNR processing}
procedure _readNamingRulesConfig();
var 
	i: Integer;
	path, sSection:String;
	tmpLst, tmpLst2: TStringList;
begin
	// Reading rules
	if not Assigned(_rulesDynamicNaming) then begin
		path := getDynamicNamingRulesIniPath();
		AddMessage('Loading INNR rules: '+ExtractFileName(ExtractFileDir(path))+'\'+ExtractFileName(path));
		_rulesDynamicNaming := TIniFile.Create( path );
		end;
	if not Assigned(_dynNamesRegistry) then begin 
		_dynNamesRegistry := THashedStringList.Create();
		tmpLst := TStringList.Create;
		_rulesDynamicNaming.readSections(tmpLst);
		for i := 0 to tmpLst.Count -1 do begin 
			sSection := tmpLst[i]; 
			tmpLst2 := TStringList.Create;
			_rulesDynamicNaming.readSectionValues(sSection, tmpLst2);
			_dynNamesRegistry.addObject(sSection, tmpLst2);
			end;
		tmpLst.Free;
		end
end;

{Replaces naming rules with a new set}
procedure replaceModNamingRules(dnName:String;tList:TStringList);
var 
	existingIndex: Integer;
begin
	existingIndex := _dynNamesRegistry.indexOf(dnName);
	if existingIndex <> -1 then begin
		_dynNamesRegistry.Objects[existingIndex].Free;
		_dynNamesRegistry.Delete(existingIndex);
		end;
	storeModNamingRules(dnName, tList);
end;

{Stores mod rules from CustomRuleSets unit to the registry }
procedure storeModNamingRules(dnName:String; tList:TStringList);
var 
	existingIndex: Integer;
	tmpLst: TStringList;
begin
	init();
	tmpLst := TStringList.Create;
	tmpLst.Assign(tList);
	existingIndex := _dynNamesRegistry.indexOf(dnName);
	if existingIndex = -1 then
		_dynNamesRegistry.AddObject(dnName, tmpLst)
	else begin
		// Prepend
		tmpLst.AddStrings(_dynNamesRegistry.Objects[existingIndex]);
		_dynNamesRegistry.Objects[existingIndex].Free;
		_dynNamesRegistry.Objects[existingIndex] := tmpLst;
		end;
end;

{Reads the dynamic naming rules. Needs to be freed}
function getDynamicNamingRulesSection(section:String):TStringList;
begin	
	Result := TStringList.create;

	// Create copy 
	if _dynNamesRegistry.indexOf(section) > -1 then 
		Result.CommaText := _dynNamesRegistry.Objects[_dynNamesRegistry.indexOf(section)].CommaText;
	
	// Special Rule: USE_SECTION
	if Result.Count > 0 then
		if Result.Names[0] = 'USE_SECTION' then
			if section <> Result.values['USE_SECTION'] then begin
				section := Result.values['USE_SECTION'];
				Result.Free;
				Result := getDynamicNamingRulesSection(section);
				end;
end;


{Store INNR modification script}
procedure storeInnrScript(innrEditorId:String;rawLines:TStringList;iniPath:String);
var index:Integer;
begin
	index := _dynInnrScriptRegistry.indexOf(innrEditorId);
	// Create entry on demand
	if index = -1 then
		index := _dynInnrScriptRegistry.AddObject(innrEditorId, TStringList.Create);
	_dynInnrScriptRegistry.Objects[index].addObject(iniPath, rawLines);
end;

{Returns an INNR modification script (if available). Original or nil returned!}
function getInnrScripts(innrEditorId:String):TStringList;
var 
	index:Integer;
begin
	index := _dynInnrScriptRegistry.indexOf(innrEditorId);
	if index > -1 then
		Result := _dynInnrScriptRegistry.Objects[index];
end;

{Apply all innr scripts for a given innrEditorId}
procedure _applyInnrScripts(rec:IInterface;innrEditorId:String;var saveRecord:Boolean;var flagDynNamesAlreadyInserted:Boolean);
var 
	i: Integer;
	innrScripts: TStringList;
begin
	innrScripts := _dynInnrScriptRegistry.Objects[_dynInnrScriptRegistry.indexOf(innrEditorId)];
	for i := 0 to innrScripts.Count -1 do 
		_applyInnrScript(rec,innrEditorId,saveRecord,flagDynNamesAlreadyInserted,innrScripts.Objects[i]);
end;

{Apply a innr modification script to an INNR}
procedure _applyInnrScript(rec:IInterface;innrEditorId:String;var saveRecord:Boolean;var flagDynNamesAlreadyInserted:Boolean;lstScript:TStringList);
var
	curAction: TStringList;
	i,applyToRulesetIndex,applyToNameIndex, lastCurActionCount: Integer;
begin
	curAction := TStringList.Create;
	curAction.Delimiter := ' ';
	curAction.StrictDelimiter := True;
	AddMessage('Apply INNR script to "'+innrEditorId+'".');
	for i := 0 to Pred(lstScript.Count) do begin 
		if Trim(lstScript[i]) = '' then
			continue;
		curAction.DelimitedText := lstScript[i];
		if curAction.Count = 0 then
			continue;
		
		// Action: Check checksum
		if curAction[0] = 'check' then begin
			if not _applyINNRModCheck(rec,curAction[1]) then begin
				AddMessage(' INNR checksum doesnt match. Skip script.');
				Exit;
				end;
			continue;
			end;
				
		// Action: reorder
		if curAction[0] = 'neworder' then begin
			_applyINNRModNewOrder(rec,curAction[1],saveRecord);
			continue;
			end;
		
		// Selectors
		applyToRulesetIndex := -1;
		applyToNameIndex := -1;
		
		while curAction.Count > 0 do begin 
			lastCurActionCount := curAction.Count;
			// Selector: Find
			if curAction[0] = 'find' then
				_applyInnrModFind(rec,curAction,applyToRulesetIndex,applyToNameIndex);
			
			// Selector: Ruleset index
			if curAction[0] = 'ruleset' then begin 
				applyToRulesetIndex := StrToInt(curAction[1]);
				curAction.Delete(0);
				curAction.Delete(0);
				end;
				
			// Selector: Name index
			if curAction[0] = 'name' then begin 
				applyToNameIndex := StrToInt(curAction[1]);
				curAction.Delete(0);
				curAction.Delete(0);
				end;
			
			// Action: New rule set
			if curAction[0] = 'addRuleset' then begin
				_applyInnrModAddRuleset(rec,applyToRulesetIndex,applyToNameIndex);
				saveRecord := True;
				curAction.Delete(0);
				continue;
				end;
						
			// Action: New name entry
			if curAction[0] = 'addName' then begin
				if applyToRulesetIndex < 0 then 
					AddMessage('Warning: No ruleset for INNR name insertion selected')
				else begin
					_applyInnrModAddName(rec,applyToRulesetIndex,applyToNameIndex);
					saveRecord := True;
					end;
				curAction.Delete(0);
				continue;
				end;
			
			// Action: Insert the dynamic names (by INNR_RULES) now (instead of later)
			if ( curAction[0] = 'addDynamicNamesRuleset' ) then begin 
				applyToRulesetIndex := -2;
				if ( _dynNamesRegistry.indexOf(innrEditorId) > -1 ) then 
					applyToRulesetIndex := _appendRulesToInnrRecord(rec, nil, saveRecord);
				flagDynNamesAlreadyInserted := True;
				curAction.Delete(0);
				continue;
				end;
			
			// Action: modification functions
			if (curAction[0] = 'set') or (curAction[0] = 'replace') or (curAction[0] = 'pregReplace')
				or (curAction[0] = 'deleteName') or (curAction[0] = 'deleteRuleset')
				or (curAction[0] = 'addKeyword') or (curAction[0] = 'removeKeyword') 
				or (curAction[0] = 'moveNameTo') or (curAction[0] = 'moveRulesetTo')  then begin
				if _applyInnrModFunction(rec,curAction,applyToRulesetIndex,applyToNameIndex) then 
					saveRecord := True;
				continue;
				end;
			
			// Invalid line syntax?
			if lastCurActionCount = curAction.Count then begin 
				AddMessage('Error: Syntax error in INNR script for "'+innrEditorId+'" at line: "'+lstScript[i]+'".');
				Exit;
				end;
			end;
		
		end;
end;

{Create new rule set}
procedure _applyInnrModAddRuleset(rec:IInterface;var applyToRulesetIndex,applyToNameIndex:Integer);
var
	namingRules,ruleset, names,name: IInterface;
begin
	namingRules := ElementByName(rec, 'Naming Rules');
	applyToRulesetIndex := ElementCount(namingRules);
	applyToNameIndex := -1;
	ruleset := ElementAssign(namingRules, HighInteger, nil, false);	 // New 'Ruleset' added to end
end;

{Create new name entry}
procedure _applyInnrModAddName(rec:IInterface;var applyToRulesetIndex,applyToNameIndex:Integer);
var
	namingRules,ruleset, names,name: IInterface;
begin
	namingRules := ElementByName(rec, 'Naming Rules');
	ruleset := ElementByIndex(namingRules, applyToRulesetIndex);
	names := ElementByName(ruleset,'Names');
	if not Assigned(names) then begin
		names := ElementAssign(ruleset, 1, nil, False);
		name := ElementByName(names, 'Name');
		applyToNameIndex := 0;
		Exit;
		end;
	applyToNameIndex := ElementCount(names);
	{if ElementCount(names) = 0 then
		name := ElementByName(names, 'Name')  // New 'Names' to Ruleset, links to 'Name'
	else
		name := }ElementAssign(names, ElementCount(names), nil, false);
end;

{Applies a innr modification function to the selected entries}
function _applyInnrModFunction(rec: IInterface;curAction:TStringList;var applyToRulesetIndex,applyToNameIndex:Integer):Boolean;
var
	namingRules,ruleset, names,name: IInterface;
	i,j,k: Integer;
	sAction, oldValue, newValue: String;
begin
	// Setup
	try 
	sAction := curAction[0];
	curAction.Delete(0);
	
	// AddMessage('Apply '+sAction+' to ruleset '+IntToStr(applyToRulesetIndex)+' name '+IntToStr(applyToNameIndex)+'');
	
	namingRules := ElementByName(rec, 'Naming Rules');
	for i:= ElementCount(namingRules) - 1 downto 0 do begin 
		if ( applyToRulesetIndex <> -1 ) and ( i <> applyToRulesetIndex ) then 
			continue;
		ruleset := ElementByIndex(namingRules, i);
		
		// Action: Delete ruleset
		if sAction = 'deleteRuleset' then begin
			Result := true;
			Remove(ruleset);
			continue;
			end;
		
		// Action: Move ruleset
		if sAction = 'moveRulesetTo' then begin
			for k := i-1 downto StrToInt(curAction[0]) do 
					MoveUp(ruleset);
				for k := i+1 to Min(StrToInt(curAction[0]),ElementCount(namingRules) - 1) do 
					MoveDown(ruleset);
				applyToRulesetIndex := Min(StrToInt(curAction[0]),ElementCount(namingRules) - 1);
				Exit;
			end;
		names := ElementByName(ruleset,'Names');
		if not Assigned(names) then
			continue;
		for j := ElementCount(names) - 1 downto 0 do begin
			if ( applyToNameIndex <> -1 ) and ( j <> applyToNameIndex ) then 
				continue;
			name := ElementByIndex(names,j);
			if (sAction = 'set') or (sAction = 'replace') or (sAction = 'pregReplace') then begin
				oldValue := GetElementEditValues(name,curAction[0]);
				if sAction = 'set' then
					newValue := curAction[1];
				if sAction = 'replace' then
					newValue := StringReplace(oldValue,curAction[1],curAction[2],[rfReplaceAll]);
				if sAction = 'pregReplace' then
					newValue := PregReplace(curAction[1],curAction[2],oldValue);
				// Changed?
				if oldValue = newValue then 
					continue;
				SetElementEditValues(name,curAction[0], newValue );
				Result := True;
				// AddMessage('Changed "'+oldValue+'" to "'+newValue+'".');
				end
			else if sAction = 'moveNameTo' then begin // Action: Move name entry
				for k := j-1 downto StrToInt(curAction[0]) do 
					MoveUp(name);
				for k := j+1 to Min(StrToInt(curAction[0]),ElementCount(names) - 1) do 
					MoveDown(name);
				applyToNameIndex := Min(StrToInt(curAction[0]),ElementCount(names) - 1);
				Exit;
				end
			else if sAction = 'addKeyword' then begin
				recordAddKeyword(ElementAssign(name, 2, nil, False),curAction[0]);
				end
			else if sAction = 'removeKeyword' then begin
				recordRemoveKeyword(ElementAssign(name, 2, nil, False),curAction[0]);
				end
			else if sAction = 'deleteName' then begin
				Remove(name);
				Result := True;
				end
			else
				AddMessage('Warning: Unknown INNR modification function: "'+sAction+'".');
			end;
		end;
		
	finally 
		// Cleanup batch actions
		if (sAction = 'set') or (sAction = 'replace') or (sAction = 'pregReplace') then begin
			curAction.Delete(0);
			curAction.Delete(0);
			end;
		if (sAction = 'moveNameTo') or (sAction = 'moveRulesetTo') or (sAction = 'removeKeyword') or (sAction = 'addKeyword') or (sAction = 'replace') or (sAction = 'pregReplace') then
			curAction.Delete(0);
		end;
end;

{Applies a innr modification function to the selected entries}
function _applyInnrModFind(rec: IInterface;curAction:TStringList;var applyToRulesetIndex,applyToNameIndex:Integer):Boolean;
var
	namingRules,ruleset, names,name: IInterface;
	i,j: Integer;
	sAction, sCompField, sCompOp, sCompTo, curValue: String;
begin
	// Setup
	sAction := curAction[0];
	sCompField := curAction[1];
	sCompOp := curAction[2];
	sCompTo := curAction[3];
	curAction.Delete(0);
	curAction.Delete(0);
	curAction.Delete(0);
	curAction.Delete(0);
	
	// AddMessage('Apply '+sAction+' to ruleset '+IntToStr(applyToRulesetIndex)+' name '+IntToStr(applyToNameIndex)+'');
	
	namingRules := ElementByName(rec, 'Naming Rules');
	for i:= 0 to ElementCount(namingRules) - 1 do begin 
		if ( applyToRulesetIndex <> -1 ) and ( i <> applyToRulesetIndex ) then 
			continue;
		ruleset := ElementByIndex(namingRules, i);
		names := ElementByName(ruleset,'Names');
		if Assigned(names) then
			for j := 0 to ElementCount(names) - 1 do begin
				if ( applyToNameIndex <> -1 ) and ( j <> applyToNameIndex ) then 
					continue;
				name := ElementByIndex(names,j);
				if (sAction = 'find') then begin
					curValue := GetElementEditValues(name,sCompField);
					if sCompOp = 'equals' then
						if curValue = sCompTo then begin
							applyToRulesetIndex := i;
							applyToNameIndex := j;
							Exit;
						end
						else
					else if sCompOp = 'contains' then
						if Pos(sCompTo,curValue) > 0 then begin
							applyToRulesetIndex := i;
							applyToNameIndex := j;
							Exit;
						end
						else
					else begin
						AddMessage('Error: Unknown compare operator for INNR: "'+sCompOp+'"');
						end;
					end
				else
					AddMessage('Warning: Unknown INNR modification function: "'+sAction+'".');
				end;
		end;
	// Nothing found. Set to select "none"
	applyToRulesetIndex := -2;
	applyToNameIndex := -2;
end;


{Test INNR linked by INRD for taggabability}
procedure processAutomaticInnrTags(rec:IInterface;var sTag:String;var saveRecord:Boolean);
var 
	innrEditorId: String;
	innr, namRules, ruleset, namesets, namesetX: IInterface;
begin
	// INRD exists?
	if GetElementEditValues(rec, 'INRD') = '' then 
		Exit;

	innr := WinningOverride(LinksTo(ElementBySignature(rec, 'INRD')));
	innrEditorId := EditorId(innr);

	if _lstAutoDynamicResults.Values[innrEditorId] = '' then begin 
		_lstAutoDynamicResults.Values[innrEditorId] := 'INNR_TESTED';
		
		// Already covered by rules?
		if (_dynNamesRegistry.indexOf(innrEditorId) > -1) and (_lstAutoDynamicRules.indexOf(innrEditorId) = -1) then begin
			AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - Covered by rules.');
			exit;
			end;
			
		// Standard INNRs ? - Vanilla rules already fully covered
		if (_tlWeapArmoINNR.indexOf(innrEditorId) >= 0) then begin
			AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - Vanilla INNR covered by Ruddy88 INNR.');
			exit;
			end;
			
		namRules := ElementByName(innr, 'Naming Rules');
		if not Assigned(namRules) then 
			AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - No naming rules.'
		else begin
			ruleset := ElementByIndex(namRules, 0);
			if GetElementEditValues(ruleset,'VNAM - Count') = 0 then 
				AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - zero VNAM - Count.'
			else begin
				namesets := ElementByName(ruleset, 'Names');
				if not Assigned(namesets) then 
					AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - No names child.'
				else if ElementCount(namesets) = 0 then 
					AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - Zero childs.'
				else begin
						namesetX := ElementByIndex(namesets, 0);
						if Trim(GetElementEditValues(namesetX,'WNAM')) <> '*' then begin 
							// do stuff
							AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - First rule: "' +GetElementEditValues(namesetX,'WNAM')+'" - Injecting automatic INNR tags.');
							_lstAutoDynamicResults.Values[innrEditorId] := 'INNR_AUTO_INJECT_TAGS';
							end
						else
							AddMessage('Automatic INNR tags - Testing INNR: '+innrEditorId+' - First rule: "' +GetElementEditValues(namesetX,'WNAM')+'" - Compatible.');
						end;					
					end;
			end;
		end;
	
	// Inject? 
	if _lstAutoDynamicResults.Values[innrEditorId] = 'INNR_AUTO_INJECT_TAGS' then
		_extendInnrWithTagKeywords(rec,innr,sTag,saveRecord);
end;

{Extends an INNR with custom tag keywords. sTag is non-final TagIdent}
procedure _extendInnrWithTagKeywords(rec,innr:IInterface;var sTag:String;var saveRecord:Boolean);
var 
	i: Integer;
	patchFileKeywords, new, keywords: IInterface;
	sTagClean: String;
begin
	patchFileKeywords := GroupBySignature(mxPatchFile, 'KYWD');

	// Ensure existance group Keywords
	if not Assigned(patchFileKeywords) then
		patchFileKeywords := Add(mxPatchFile,'KYWD',False);
	
	// Read group 
	for i:=0 to Pred(ElementCount(patchFileKeywords)) do 
		if PregMatch('^m8r_tagid_',EditorId(ElementByIndex(patchFileKeywords,i))) then begin
			_lstAutoTagKeywords.Values[GetElementEditValues(ElementByIndex(patchFileKeywords,i),'DNAM')+'-kwhex'] := IntToHex(GetLoadOrderFormID(ElementByIndex(patchFileKeywords,i)),8);
			_lstAutoTagKeywords.Values[GetElementEditValues(ElementByIndex(patchFileKeywords,i),'DNAM')+'-edid'] := EditorId(ElementByIndex(patchFileKeywords,i));
			_lstAutoTagKeywords.Values[EditorId(ElementByIndex(patchFileKeywords,i))+'-rev'] := IntToHex(GetLoadOrderFormID(ElementByIndex(patchFileKeywords,i)),8);;
			end;
	
	// Doesnt exist yet? 
	if _lstAutoTagKeywords.Values[sTag+'-kwhex'] = '' then begin 
		sTagClean := pregReplace('[^a-zA-Z0-9_]','_',pregReplace('^\[|\]$','',sTag));
		AddMessage('Create new tag keyword: '+'m8r_tagid_'+sTagClean+' > '+sTag);
		
		// Create new minimal keyword		
		new := Add(patchFileKeywords,'KYWD',True);		
		SetElementEditValues(new,'EDID','m8r_tagid_'+sTagClean);
		SetElementEditValues(new,'TNAM','None');
		SetElementEditValues(new,'DNAM',sTag);
		Add(new,'CNAM',True);
		SetElementEditValues(new,'CNAM\Red','255');
		SetElementEditValues(new,'CNAM\Green','255');
		SetElementEditValues(new,'CNAM\Blue','255');
		_lstAutoTagKeywords.Values[sTag+'-kwhex'] := IntToHex(GetLoadOrderFormID(new),8);
		_lstAutoTagKeywords.Values[sTag+'-edid'] := 'm8r_tagid_'+sTagClean;
		_lstAutoTagKeywords.Values['m8r_tagid_'+sTagClean+'-rev'] := IntToHex(GetLoadOrderFormID(new),8);
		end;
		
	if _lstAutoTagKeywords.Values[sTag+'-kwhex'] <> '' then begin 
		// Tagging via INNR for this record
		keywords := ElementBySignature(rec,'KWDA');
		if not Assigned(keywords) then
			Exit;
		SetEditValue(ElementAssign(keywords, HighInteger, nil, False), _lstAutoTagKeywords.Values[sTag+'-kwhex']);
		saveRecord := true;
		
		// Update dynamic rules 
		if _lstAutoDynamicRules.indexOf(EditorId(innr)) = -1 then 
			_lstAutoDynamicRules.AddObject(EditorId(innr),THashedStringList.Create);
		_lstAutoDynamicRules.Objects[_lstAutoDynamicRules.indexOf(EditorId(innr))]
			.Values[_lstAutoTagKeywords.Values[sTag+'-edid']] := sTag;
		replaceModNamingRules(EditorId(innr),_lstAutoDynamicRules.Objects[_lstAutoDynamicRules.indexOf(EditorId(innr))]);
		
		// Empty sTag (as tag is now in innr)
		sTag := '';

		end;
end;

{Cleanup}
procedure cleanup();
var 
	i,j:Integer;
begin
	FreeAndNil(_transManualRules);
	FreeAndNil(_transTo);
	FreeAndNil(_transFrom);
	FreeAndNil(_tlWeapArmoINNR);
	FreeAndNil(_rulesDynamicNaming);
	FreeAndNil(_tlMeleeANIM);
	FreeAndNil(_tlGunANIM);
	FreeAndNil(_infoOnlyOnceIndex);
	FreeAndNil(_lstAutoDynamicRules);
	FreeAndNil(_lstAutoTagKeywords);
	FreeAndNil(_lstAutoDynamicResults);
	if Assigned(_dynNamesRegistry) then begin 
		for i := 0 to _dynNamesRegistry.Count -1 do 
			_dynNamesRegistry.Objects[i].Free;
		FreeAndNil(_dynNamesRegistry);
		end;
	if Assigned(_dynInnrScriptRegistry) then begin 
		for i := 0 to _dynInnrScriptRegistry.Count -1 do begin
			for j := 0 to _dynInnrScriptRegistry.Objects[i].Count - 1 do 
				_dynInnrScriptRegistry.Objects[i].Objects[j].Free;
			_dynInnrScriptRegistry.Objects[i].Free;
			end;
		FreeAndNil(_dynInnrScriptRegistry);
		end;
	_innrProcUnitInited := false;
	FreeAndNil(_tlPatched);
	
end;



end.