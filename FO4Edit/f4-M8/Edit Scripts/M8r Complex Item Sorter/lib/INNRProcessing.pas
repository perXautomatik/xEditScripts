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
	tlWeapArmoINNR: TStringList;
	// private 
	_innrProcUnitInited: Boolean;
	_tlMeleeANIM, _tlGunANIM: TStringList;
	_rulesDynamicNaming: TMemIniFile;
	_transManualRules,_transTo: TStringList;
	_transFrom: THashedStringList;
	_dynNamesRegistry: THashedStringList;

implementation

{Initialise unit}
procedure init;
begin
	if _innrProcUnitInited then 
		Exit;
	_innrProcUnitInited := true;
	
	_readNamingRulesConfig();
	if not Assigned(tlWeapArmoINNR) then begin		
		tlWeapArmoINNR := TStringList.Create;
		tlWeapArmoINNR.add('DLC01dn_LightningGun');
		tlWeapArmoINNR.add('DLC01dn_PowerArmor');
		tlWeapArmoINNR.add('DLC03_dn_CommonArmor');
		tlWeapArmoINNR.add('DLC03_dn_CommonGun');
		tlWeapArmoINNR.add('DLC03_dn_CommonMelee');
		tlWeapArmoINNR.add('DLC03_dn_Legendary_Armor');
		tlWeapArmoINNR.add('DLC03_dn_Legendary_Weapons');
		tlWeapArmoINNR.add('DLC04_dn_CommonArmorUpdate');
		tlWeapArmoINNR.add('DLC04_dn_CommonGunUpdate');
		tlWeapArmoINNR.add('DLC04_dn_CommonMeleeUpdate');
		tlWeapArmoINNR.add('dn_Clothes');
		tlWeapArmoINNR.add('dn_CommonArmor');
		tlWeapArmoINNR.add('dn_CommonGun');
		tlWeapArmoINNR.add('dn_CommonMelee');
		tlWeapArmoINNR.add('dn_DLC04_PowerArmor_Overboss');
		tlWeapArmoINNR.add('dn_PowerArmor');
		tlWeapArmoINNR.add('dn_VaultSuit');
		tlWeapArmoINNR.add('dn_DLC04_PowerArmor_NukaCola');
		tlWeapArmoINNR.add('dn_DLC04_PowerArmor_Quantum');
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
			if tlPatched.indexOf(GetElementEditValues(rec, 'EDID')) = -1 then
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
	sEditorId: String;
	rulesLst : TStringList;
begin
	Result := False;
	if not globalModificationsAllowed then begin
		AddMessage('Prefilter rule misconfiguration! This could lead to modified source files. Action is not executed.');
		Exit;
		end;
	// Get edid
	sEditorId := GetElementEditValues(rec, 'EDID');

	// Translate INNR 
	if getSettingsBoolean('config.bTranslateINNR') and (tlWeapArmoINNR.indexOf(sEditorId) >= 0) then
		Result := _processTranslation(rec) or Result;
		

	// Rules to inject available? 
	if ( _dynNamesRegistry.indexOf(sEditorId) > -1 ) then 
		Result := _appendRulesToInnrRecord(rec, nil) or Result;
		
	// Include all R88?
	if getSettingsBoolean('config.bIncludeR88InnrRules')
		{and Assigned(r88SimpleSorterInnrEsp)} and OverrideExistsIn(rec, r88SimpleSorterInnrEsp) then
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
	if ( Pos('INNR',getSettingsString('config.sUseRecords', '')) = 0 ) then
		Exit;
	// Find responsible INNR
	innr := LinksTo(ElementBySignature(rec, 'INRD'));
		
	// Vanilla rules already fully covered 
	if (tlWeapArmoINNR.indexOf(GetElementEditValues(WinningOverride(innr), 'EDID')) >= 0) then begin
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
		Result := _appendRulesToInnrRecord(innr,'_custom_INNR_guns')
	else if _tlMeleeANIM.indexOf(animType) > -1 then
		Result := _appendRulesToInnrRecord(innr,'_custom_INNR_melee')
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
				AddMessage('Translation failed for "'+nameStr+'" (internal match key: '+transIdent+').');
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

{Custom injection for innr rules}
function _appendRulesToInnrRecord(rec: IInterface; forceINNREdid:String):Boolean;
var
	rulesSection,rulesKeywords: TStringList;
	sEditorId, ruleKeywords, ruleApplyTag: String;
	namingRules, ruleset, names,name, keywords: IInterface;
	i,j: Integer;
begin
	Result := false;
	if not globalModificationsAllowed then begin
		AddMessage('Prefilter rule misconfiguration! This could lead to modified source files. Action is not executed.');
		Exit;
		end;
	
	sEditorId := GetElementEditValues(rec, 'EDID');
	
	// Already patched?
	if (tlPatched.indexOf(sEditorId) >= 0) then begin
		Result := true;
		Exit;
	end;

	// Reading rules
	rulesSection := getDynamicNamingRulesSection(sEditorId);
			
	if ( rulesSection.Count = 0 ) and Assigned(forceINNREdid) then begin
		rulesSection := getDynamicNamingRulesSection(forceINNREdid);
		AddMessage('forced innrs: ' + sEditorId+' force to: '+forceINNREdid);
		end;
	
	// Special rule: MOVE_ASTERIX_TO_TOP
	if rulesSection.Count > 0 then
		if rulesSection.Names[0] = 'MOVE_ASTERIX_TO_TOP' then begin
			Result := _moveAsterixToTop(rec);
			rulesSection.Delete(0);
		end;
	

	// Inject found rules to INNR record
	if rulesSection.Count > 0 then begin
		namingRules := ElementByName(rec, 'Naming Rules');
		if Assigned(namingRules) then begin
			Result := true;
			
			// Remember patching
			tlPatched.add(sEditorId);
			ruleset := ElementAssign(namingRules, HighInteger, nil, false);	 // New 'Ruleset' added to end
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
				if j = 0 then
					name := ElementByName(names, 'Name')  // New 'Names' to Ruleset, links to 'Name'
				else
					name := ElementAssign(names, ElementCount(names), nil, false);
				
				// All ok?
				if (ruleApplyTag = '' ) then begin
					ruleApplyTag := tagNames.values[ruleKeywords];
					AddMessage('WARNING: Missing tag definition for: "'+ruleApplyTag+'"!');
				end;
				// Set naming rule WNAM
				SetElementEditValues(name, 'WNAM', ruleApplyTag);
				// Set naming rule conditions
				if (ruleKeywords <> '') and (ruleKeywords <> '*') then begin
					keywords := ElementAssign(name, 2, nil, False);
					rulesKeywords := Split(',',ruleKeywords);
					for i := 0 to rulesKeywords.Count - 1 do
						recordAddKeyword(keywords, Trim(rulesKeywords[i]));
					rulesKeywords.Free;
					end;
				end;
			// Move new rules to the top!
			while CanMoveUp(ruleset) do
				MoveUp(ruleset);
			end;
		end;

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
		AddMessage('(Loading INNR rules: '+ExtractFileName(ExtractFileDir(path))+'\'+ExtractFileName(path));
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
		_dynNamesRegistry.addObject(dnName, tmpLst)
	else begin
		// Prepend
		tmpLst.AddStrings(_dynNamesRegistry.Objects[existingIndex]);
		_dynNamesRegistry.Objects[existingIndex].Free;
		_dynNamesRegistry.Objects[existingIndex] := tmpLst;
		end;
end;

{Reads the dynamic naming rules}
function getDynamicNamingRulesSection(section:String):TStringList;
begin
	
	Result := TStringList.create;
	// _rulesDynamicNaming.ReadSectionValues(section, Result);
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


{Cleanup}
procedure cleanup();
var 
	i:Integer;
begin
	FreeAndNil(_transManualRules);
	FreeAndNil(_transTo);
	FreeAndNil(_transFrom);
	FreeAndNil(tlWeapArmoINNR);
	FreeAndNil(_rulesDynamicNaming);
	FreeAndNil(_tlMeleeANIM);
	FreeAndNil(_tlGunANIM);
	if Assigned(_dynNamesRegistry) then begin 
		for i := 0 to _dynNamesRegistry.Count -1 do 
			_dynNamesRegistry.Objects[i].Free;
		FreeAndNil(_dynNamesRegistry);
		end;
	_innrProcUnitInited := false;
end;



end.