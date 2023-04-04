{
	M8r98a4f2s Complex Item Sorter for FallUI - RecordLib module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. All things around records
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit RecordLib;

var
	kywdCache, recordsIndex: TStringList;
	globalModificationsAllowed: Boolean;
	// Performance global
	_rl_cacheFileCRCs: THashedStringList;

implementation


{Applies the prefilter to all records}
procedure filterRecords();
var
	rec: IInterface;
	recordType: String;
	i,j,n,recordsBegCnt,recordsFilteredCnt: Integer;
begin
	
	// Setup
	DynamicPatcher.initRecordProcessing();
	
	recordsBegCnt := MaxrecordIndex + 1;
	recordsFilteredCnt := 0;
	ProgressGUI.setStatistic('Records passed', '-');
	ProgressGUI.setStatistic('Records filtered', '-');
	
	// Quick testing
	{if b_DevLessTodo then
		for i := MaxrecordIndex downto 0 do
			if GetElementEditValues(GetRecord(i), 'Record Header\Signature') <> 'KYWD' then
				if (i mod 30) <> 0 then begin
					RemoveRecord(i);
					continue;
					end;}
				
	// Filter records
	for i := MaxrecordIndex downto 0 do begin

		// Nice progress
		Inc(n);
		if n = 100 then 
			_updateStats(i,recordsBegCnt,n);
		
		// Get record
		rec := GetRecord(i);
		//recordType := GetElementEditValues(rec, 'Record Header\Signature');
		recordType := Signature(rec);

		// Allow abort
		if bUserRequestAbort then
			Exit;
		
		if recordType = 'KYWD' then begin
			kywdCache.Append(GetElementEditValues(rec, 'EDID - Editor ID') + '=' + IntToHex(GetLoadOrderFormID(rec),8));
			// RemoveRecord(i);
			mxRecords.Delete(i);
			continue;
			end;
		
		{if recordType = 'COBJ' then
			filterCOBJ(i, rec);}
		
		// Covered by custom rules
//		if i <= MaxrecordIndex then
		if not applyProcRuleSets(rec,recordType,i) then
			if bAppendMode then 
				if OverrideExistsIn(rec, mxPatchFile) then 
					mxRecords.Delete(i);
	end;
	// Save last entry cache
	DynamicPatcher.startRecordProcessing(nil,nil);
	// Fin
	ProgressGUI.setProgressPercentCurrentStep(100);
	DynamicPatcher.updateCacheStatistics();
	_updateStats(0,recordsBegCnt,n);
	// Cleanup
end;

{Applies a whole rulesetlist. Returns true if the record is filtered }
function applyProcRuleSets(rec:IInterface;const recordType:String;const i:Integer):Boolean;
var
	j: Integer;
	procRuleSets: TStringList;
	sPfTag: String;
begin
	DynamicPatcher.startRecordProcessing(rec,recordType);
	procRuleSets := CustomRuleSets.getProccessingRuleSetsArray('prefilter:');
	for j:= 0 to procRuleSets.Count -1 do
		if DynamicPatcher.processRuleSet(procRuleSets[j],procRuleSets.Objects[j], nil, sPfTag) then begin
			// Ignore
			if sPfTag = 'IGNORE' then begin // mostly
				//RemoveRecord(i);
				mxRecords.Delete(i);
				Result := true;
				Exit;
				end;

			// Keep 
			if sPfTag = 'KEEP' then // rare
				Exit;

			// Debug show
			{if sPfTag = 'IGNORE_SHOW' then begin
				Result := true;
				RemoveRecord(i);
				d(pDR_record,'(IGNORE_SHOW) Item removed: ');
				Exit;
				end;}
			// Unknown action
			AddMessage('Unknown prefilter action: "'+sPfTag+'"');			
			end;

end;

{Applies a ruleset}
{
function prefilterApplyRuleSet(const procRuleSetIdent:String;procRuleSet:TStringList;const i:Integer):Boolean;
var
	//saveRecord: Boolean; // Ignored for prefilter
	sTag: String;
begin

	// Run processing rules
	if not DynamicPatcher.processRuleSet(procRuleSetIdent,procRuleSet, nil, sTag) then
		Exit; // mostly

	// Ignore
	if sTag = 'IGNORE' then begin // common
		Result := true;
		//RemoveRecord(i);
		mxRecords.Delete(i);
		Exit;
		end;

	// Keep 
	if sTag = 'KEEP' then begin // rare
		Result := true;
		Exit;
		end;

	// No decision
	if sTag = '' then // should not be called that way
		Exit;

	// Debug show
	if sTag = 'IGNORE_SHOW' then begin
		Result := true;
		RemoveRecord(i);
		d(pDR_record,'(IGNORE_SHOW) Item removed: ');
		Exit;
		end;
	// Unknown action
	AddMessage('Unknown prefilter action: "'+sTag+'"');
end;}

{Updates statistics for prefilter and test if user aborted}
procedure _updateStats(i,recordsBegCnt:Integer; var n:Integer);
begin
	ProgressGUI.setProgressPercentCurrentStep( (recordsBegCnt-i)*100/recordsBegCnt);
	DynamicPatcher.updateCacheStatistics();
	ProgressGUI.setStatistic('Records passed', IntToStr(MaxrecordIndex-i));
	ProgressGUI.setStatistic('Records filtered', IntToStr(recordsBegCnt-MaxrecordIndex-1));

	n := 0;
end;

{Extract the sum resistance of a record}
function recordGetResistance(rec: IInterface): Integer;
var
	m: IInterface;
	k: Integer;
begin
	Result := 0;
	m := ElementByPath(rec, 'DAMA');
	if ( ElementCount(m) > 0 ) then
		for k := 0 to ElementCount(m)-1 do begin
			Result := Result + GetElementNativeValues(ElementByIndex(m, k),'Value');
		end;
end;

// Checks an ARMO record and its linked ARMA records for any indication of being compatible with HumanRace. Several fields are checked.
function recordHasHumanRace(rec:IInterface):Boolean;
var
	m, n, p, q: IInterface;
	k, l: Integer;
begin
	result := true;
	if ( Pos(' [RACE:00013746]',GetElementEditValues(rec, 'RNAM - Race')) > 0 ) then
			exit;
	m := ElementByName(rec, 'Models');
	for k := 0 to ElementCount(m)-1 do begin
		n := ElementByIndex(m, k);
		p := WinningOverride(LinksTo(ElementBySignature(n, 'MODL')));
		if (Pos(' [RACE:00013746]',GetElementEditValues(p, 'RNAM - Race') ) > 0 ) then
			exit;
		q := ElementByName(p, 'Additional Races');
		for l := 0 to ElementCount(q)-1 do
			if (Pos(' [RACE:00013746]',GetEditValue(ElementByIndex(q, l)) ) > 0 ) then				// This is the part that isnt working
				exit;
	end;
	result := false;
end;

{Returs a list of the effects of a record}
function recordReadEffects(rec: IInterface): THashedStringList;
var
  eEffects, eEff, eBase: IInterface;
  i,toInt: Integer;
begin
  Result := THashedStringList.Create;
  eEffects := ElementByName(rec, 'Effects');
  toInt := ElementCount(eEffects)-1;
  for i := 0 to toInt do begin
    eEff := ElementByIndex(eEffects, i);
    eBase := WinningOverride(LinksTo(ElementBySignature(eEff, 'EFID')));
	Result.add(GetElementEditValues(eBase, 'EDID'));
  end;
end;


function recordReadKeywords(rec:IInterface):THashedStringList;
var
	kwda: IInterface;
	keywords: THashedStringList;
	j: int;
begin
	keywords := THashedStringList.Create;
	kwda := ElementByPath(rec, 'KWDA');
	for j := 0 to ElementCount(kwda) - 1 do
		keywords.add(GetElementEditValues(WinningOverride(LinksTo(ElementByIndex(kwda, j))), 'EDID'));
	Result := keywords;
end;


procedure recordAddKeyword(keywords:IInterface;keyword:String);
var
	kwHex: String;
begin
	kwHex := kywdCache.values[keyword];
	if not Assigned(kwHex) or ( kwHex = '' ) then begin
		AddMessage('Warning: Keyword "'+keyword+'" not found!');
		// Set inpossible matching value instead
		SetEditValue(ElementAssign(keywords, HighInteger, nil, False), '0002B79C');
		SetEditValue(ElementAssign(keywords, HighInteger, nil, False), '0002B79D');
	end
	else
		SetEditValue(ElementAssign(keywords, HighInteger, nil, False), kwHex);
end;


// Sets weight to 0.
{function recordSetWeightless(rec: IInterface; sPath: String):Boolean;
begin
	Result := false;
	try
	if ElementExists(rec,sPath) then
		if GetElementEditValues(rec,sPath) <> 0 then begin
			SetElementEditValues(rec, sPath, 0);
			Result := true;
			end;
	except
		on E: Exception do
			AddMessage('Error while setting weightless: '+E.Message);
	end;
end;}


// Writes sTag string to beginning of existing string.
procedure recordAddTagString(sTag, sPath: String; rec: IInterface;fullNamePrecached:String);
var
	sStr:String;
begin
	if fullNamePrecached <> '' then
		sStr := fullNamePrecached
	else
		sStr := GetElementEditValues(rec, sPath);
    if (sStr <> '') and globalModificationsAllowed then
		SetElementEditValues(rec, sPath, sTag + ' ' + recordDeleteExistingTag(sStr));
end;

{Delete existing pretags}
function recordDeleteExistingTag( sStr:String ):String;
var
	j: Integer;
	prevSStr: String;
begin
	Result := sStr;
	if (Pos('{',sStr) = 0 ) and (Pos('[',sStr) = 0 ) and (Pos('(',sStr) = 0 ) and (Pos('|',sStr) = 0 ) then
		Exit;
	prevSStr := '';
	while prevSStr <> sStr do begin
		prevSStr := sStr;
		sStr := pregReplace('^('
			+ '\[[^\[\]]+\]'
			+'|\([^\(\)]+\)'
			+'|\{[^\{\}]+\}'
			+'|\{\{\{[^\{\}]+\}\}\}' // Remove component tag to recognize strs with only this
			+'|\|[^\|\{\}\(\)\[\]]+\|'
			+')\s*','',sStr);
		end;
	if sStr <> '' then
		Result := sStr;
end;

// Writes sTag string to beginning of existing string.
procedure AddTagString(sTag, sPath: String; rec: IInterface);
begin
	sStr := GetElementEditValues(rec, sPath);
	if (sStr <> '') then begin
		DeleteExistingTag();
		SetElementEditValues(rec, sPath, (sTag + ' ' + sStr));
	end;
end;


function recordIsArmor(rec:IInterface):Boolean;
begin
	if not Assigned(pDR_keywords) then
		pDR_keywords := recordReadKeywords(rec);
	Result := ( recordGetResistance(rec) > 2)
		or (((pDR_keywords.indexOf( 'ObjectTypeArmor')>-1) or (pDR_keywords.indexOf('ArmorTypeHat')>-1))
		and Assigned(GetElementNativeValues(rec, 'FNAM - FNAM\Armor Rating'))
		and (GetElementNativeValues(rec, 'FNAM - FNAM\Armor Rating') > 0));
end;


{Index all records by their signature}
procedure indexRecords();
var 
	rec: IInterface;
	recordType: String;
	i,index: Integer;
begin
	recordsIndex := TStringList.Create;
	for i := MaxPatchRecordIndex downto 0 do begin
		rec := GetPatchRecord(i);
		//recordType := GetElementEditValues(rec, 'Record Header\Signature');
		recordType := Signature(rec);
	
		index := recordsIndex.indexOf(recordType);
		if index = -1 then
			index := recordsIndex.addObject(recordType, TList.Create);
		
		recordsIndex.Objects[recordsIndex.indexOf(recordType)].Add(TObject(rec));
		end;
end;


{Returns all files in the current load order as comma separated string}
function getLoadOrderFilesString():String;
var 
	i: Integer; 
	f: IInterface;
	sFileName: String;
	sFileNames: TStringList;
begin
	sFileNames := TStringList.Create;
	for i := 0 to FileCount - 2 do begin
		f := FileByLoadOrder(i);
		sFileName := GetFileName(f);
		
		if (sFileName <> '') and (GetAuthor(f) <> 'R88_SimpleSorter') then
			sFileNames.Append(sFileName+':'+DynamicPatcher.getFileCRC(sFileName));
		end;
	Result := sFileNames.CommaText;
	sFileNames.Free;
end;


{Returns the cached CRC32 as string for a file}
function getFileCRC(path:String):String;
begin
	if not Assigned(_rl_cacheFileCRCs) then
		_rl_cacheFileCRCs := THashedStringList.Create;
		
	Result := _rl_cacheFileCRCs.values[path];
	if Result <> '' then
		Exit;
	
	//Result := IntToStr(FileAge(DataPath()+path));
	Result := IntToStr(wbCRC32File(DataPath()+path));
	_rl_cacheFileCRCs.values[path] := Result;
end;




{unit cleanup}
procedure cleanup();
var
	i:Integer;
begin
	if Assigned(kywdCache) then FreeAndNil(kywdCache);
	if Assigned(recordsIndex) then begin
		for i := recordsIndex.Count - 1 downto 0 do
			if Assigned(recordsIndex.Objects[i]) then
				recordsIndex.Objects[i].Free;
		recordsIndex.Free;
		recordsIndex
	end;
	FreeAndNil(_rl_cacheFileCRCs);	
end;

end.