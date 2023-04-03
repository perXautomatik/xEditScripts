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
	recordsInTasks: TStringList;
	globalModificationsAllowed: Boolean;
	// Performance global
	kywdCache: THashedStringList;
	// Private
	_rl_cacheFileCRCs, _lstRecSigCache: THashedStringList;

implementation


{Applies the pre-filter to all records}
procedure filterRecords();
var
	rec: IInterface;
	recordType: String;
	lstPrcTasks: TStringList;
	lRecordsOfRecType: TList;
	i, r, iTaskIndex, n, iProcessedCnt: Integer;
	bFlagInOneList: Boolean;
begin
	
	// Setup
	lstPrcTasks := Tasks.getProcessingActiveTasks();
	if Assigned(recordsInTasks) then
		for iTaskIndex:= 0 to recordsInTasks.Count - 1 do 
			recordsInTasks.Objects[iTaskIndex].Free;
	FreeAndNil(recordsInTasks);

	recordsInTasks := TStringList.Create;
	for iTaskIndex := 0 to lstPrcTasks.Count - 1 do
		recordsInTasks.AddObject(lstPrcTasks.Names[iTaskIndex],THashedStringList.Create);
	
	DynamicPatcher.initRecordProcessing();

	iOriginalRecFilteredCnt := 0;
	iProcessedCnt := 0;
	
	// Filter records
	for i := lOriginalRecords.Count-1 downto 0 do begin
		lRecordsOfRecType := lOriginalRecords.Objects[i];
		//sRecType := lOriginalRecords[i];
		for r := lRecordsOfRecType.Count-1 downto 0 do begin
			rec := ObjectToElement(lRecordsOfRecType[r]);

			// Nice visual progress
			Inc(n);
			if n = 100 then 
				_updateStats(iProcessedCnt,n);
			
			// Get record
			recordType := Signature(rec);

			// Allow abort
			if bUserRequestAbort then
				Exit;
			
			// Covered by custom rules
			DynamicPatcher.startRecordProcessing(rec,recordType);
			bFlagInOneList := False;
			for iTaskIndex := 0 to lstPrcTasks.Count - 1 do
				if _applyProcRuleSets(lstPrcTasks.Names[iTaskIndex],recordType) then begin
					bFlagInOneList := True;
					recordsInTasks.Objects[iTaskIndex].Add(IntToHex(GetLoadOrderFormID(rec) and $00FFFFFF,6));
					end;
			
			// Record processed by anything?
			if not bFlagInOneList then begin
				lRecordsOfRecType.Delete(r);
				Inc(iOriginalRecFilteredCnt);
				end;
			Inc(iProcessedCnt);
			end;
		end;
		
	// Save last entry cache
	DynamicPatcher.startRecordProcessing(nil,nil);
	
	// Fin
	_updateStats(iProcessedCnt,n);
	// Update record count
	iOriginalRecCnt := iOriginalRecCnt - iOriginalRecFilteredCnt;
	ProgressGUI.setProgressPercentCurrentStep(100);
	DynamicPatcher.updateCacheStatistics();
end;

{Applies a whole rulesetlist. Returns true if the record is kept }
function _applyProcRuleSets(taskIdent:String;const recordType:String):Boolean;
var
	i: Integer;
	procRuleSets: TStringList;
	sPfTag: String;
begin
	procRuleSets := CustomRuleSets.getProccessingRuleSetsArray(taskIdent,'prefilter:',recordType,recordsSourceFiles.Values[pDR_cacheLoadOrderFormId]);
	for i:= 0 to procRuleSets.Count -1 do
		if DynamicPatcher.processRuleset(procRuleSets[i],procRuleSets.Objects[i], nil, sPfTag) then
			if sPfTag = 'IGNORE' then // Ignore - most used
				Exit
			else if sPfTag = 'KEEP' then begin // Keep - lesser used -> Result = true
				Result := true;
				Exit;
				end
			else
				// Unknown action
				AddMessage('Unknown prefilter action: "'+sPfTag+'"');			

end;


{Updates statistics for prefilter and test if user aborted}
procedure _updateStats(iProcessedCnt:Integer; var n:Integer);
begin
	ProgressGUI.setProgressPercentCurrentStep( iProcessedCnt * 100 / iOriginalRecCnt);
	DynamicPatcher.updateCacheStatistics();
	ProgressGUI.setStatistic('Records passed', IntToStr(iProcessedCnt - iOriginalRecFilteredCnt ) );
	ProgressGUI.setStatistic('Records filtered', IntToStr( iOriginalRecFilteredCnt ) );
	n := 0;
end;

{Extract the sum resistance of a record}
function _recordGetResistance(rec: IInterface): Integer;
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
	m, p, q: IInterface;
	i, l: Integer;
	sStr: String;
begin
	Result := True;
	sStr := GetElementEditValues(rec, 'RNAM - Race');
	if Pos(' [RACE:00013746]',sStr) <> 0 then
			Exit;
	if Pos(' [RACE:0011D83F]',sStr) <> 0 then
			Exit;			
	m := ElementByName(rec, 'Models');
	for i := 0 to ElementCount(m)-1 do begin
		p := WinningOverride(LinksTo(ElementBySignature(ElementByIndex(m, i), 'MODL')));
		sStr := GetElementEditValues(p, 'RNAM - Race');
		if Pos(' [RACE:00013746]',sStr ) <> 0 then
			Exit;
		if Pos(' [RACE:0011D83F]',sStr ) <> 0 then
			Exit;
		q := ElementByName(p, 'Additional Races');
		for l := 0 to ElementCount(q)-1 do begin
			sStr := GetEditValue(ElementByIndex(q, l));
			if Pos(' [RACE:00013746]',sStr ) <> 0 then // This is the part that isnt working
				Exit;
			if Pos(' [RACE:0011D83F]',sStr ) <> 0 then // This is the part that isnt working
				Exit;
			end;
	end;
	Result := False;
end;


{Returs a list of the effects of a record}
function recordReadEffects(rec: IInterface): THashedStringList;
var
  eEffects, eEff, eBase: IInterface;
  i: Integer;
begin
  Result := THashedStringList.Create;
  eEffects := ElementByName(rec, 'Effects');
  for i := 0 to ElementCount(eEffects)-1 do begin
    eEff := ElementByIndex(eEffects, i);
    eBase := WinningOverride(LinksTo(ElementBySignature(eEff, 'EFID')));
	Result.add(GetElementEditValues(eBase, 'EDID'));
  end;
end;


{Ready the keyword of a main record}
function recordReadKeywords(rec:IInterface;fieldSig:String):THashedStringList;
var
	kwda: IInterface;
	i: int;
begin
	Result := THashedStringList.Create;
	kwda := ElementByPath(rec, fieldSig);
	for i := 0 to ElementCount(kwda) - 1 do
		Result.add(GetElementEditValues(WinningOverride(LinksTo(ElementByIndex(kwda, i))), 'EDID'));
end;


{Add a keyword to a records keyword list}
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
		Exit;
	end
	AddMasterIfMissing(getFile(keywords), kywdCache.Values[keyword+':file']);
	SetEditValue(ElementAssign(keywords, HighInteger, nil, False), kwHex);
end;

{Remove a keyword from a records keyword list}
procedure recordRemoveKeyword(keywords:IInterface;keyword:String);
var
	kwHex: String;
	i: Integer;
begin
	kwHex := kywdCache.values[keyword];
	if not Assigned(kwHex) or ( kwHex = '' ) then
		AddMessage('Warning: Keyword "'+keyword+'" not found!')
	else 
		for i:= 0 to ElementCount(keywords) -1 do 
			if GetElementEditValues(WinningOverride(LinksTo(ElementByIndex(keywords, i))), 'EDID') = keyword then begin
				Remove(ElementByIndex(keywords, i));
				Exit;
				end;
end;


{Check if a keyword reference exists}
function keywordReferenceExists(keyword:String):Boolean;
var
	kwHex: String;
begin
	kwHex := kywdCache.Values[keyword];
	Result :=  Assigned(kwHex) and ( kwHex <> '' );
end;

function canKeywordUsedInCurrentPatchFile(keyword:String;addIfMissing:Boolean):Boolean;
var
	kwHex, kwFile:String;
begin
	kwHex := kywdCache.Values[keyword];
	kwFile := kywdCache.Values[keyword+':file'];
	if  Assigned(kwHex) and ( kwHex <> '' ) and (kwFile <> '' ) then begin
		Result := HasMaster(mxPatchFile, kwFile);
		// Try to add it
		if addIfMissing and not Result then begin
			AddMasterIfMissing(mxPatchFile, kywdCache.Values[keyword+':file']);
			Result := HasMaster(mxPatchFile, kwFile);
			end;
		end;
end;

{Delete existing pretags}
function deleteExistingTag( sStr:String ):String;
var
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

{Check if an armo record looks like a piece of armor}
function recordIsArmor(rec:IInterface):Boolean;
begin
	if not Assigned(pDR_keywords) then
		pDR_keywords := recordReadKeywords(rec,'KWDA');
	if Assigned(GetElementNativeValues(rec, 'FNAM - FNAM\Armor Rating')) then 
		if GetElementNativeValues(rec, 'FNAM - FNAM\Armor Rating') > 0 then
			if ((pDR_keywords.indexOf( 'ObjectTypeArmor')>-1) or (pDR_keywords.indexOf('ArmorTypeHat')>-1)) then begin
				Result := true;
				Exit;
				end;
			
	Result := _recordGetResistance(rec) > 2;
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



{Initialize the keyword cache}
procedure initKeywordCache;
var 
	keywordCacheValidationStr: String;
	kywdIndexReindex : Boolean;
	
begin
	RecordLib.loadKeywords();
		
	// Stats
	ProgressGUI.setStatistic('Keywords', IntToStr(kywdCache.Count));
end;

{Load all keywords from the current load order list}
procedure loadKeywords();
var 
	i,j: Integer;
	f,grp, rec: IInterface;
begin
	kywdCache := getRecordReferenceIndex('KYWD');
end;


{Create an index for records edid to load order form id for a signature group}
function _createRecordReferenceIndex(signature:String):THashedStringList;
var 
	i,j: Integer;
	f,grp, rec: IInterface;
	keywordCacheValidationStr, fileName: String;
	sectionCacheCur, sectionCacheNew: TStringList;
begin
	
	if _lstRecSigCache.indexOfName(signature) <> -1 then begin
		AddMessage('Warning: Index already exists!');
		Exit;
		end;

	Cache.getEntrySetLevelTwo('recordReferences',signature,true,sectionCacheCur,sectionCacheNew);
	keywordCacheValidationStr := 'RECREF_VALIDATION:'+getLoadOrderFilesString();
	Cache.setEntryLevelTwo('recordReferences',signature, '_VALIDATION',keywordCacheValidationStr, nil,nil);

	for i := 0 to FileCount - 2 do begin
		grp := GroupBySignature(FileByLoadOrder(i), signature);
		fileName := GetFileName(FileByLoadOrder(i));
		for j := 0 to ElementCount(grp) -1 do begin
			rec := ElementByIndex(grp, j);

			// Direct write to cache 
			sectionCacheNew.Append( EditorId(rec) + '=' + IntToHex(GetLoadOrderFormID(rec),8));
			sectionCacheNew.Append( EditorId(rec) + ':file=' + fileName);
			end;
		end;
	// Store new data to cur data
	sectionCacheCur.CommaText := sectionCacheNew.CommaText;
	AddMessage('(Created record reference list for signature '+signature+' with '+IntToStr(sectionCacheCur.Count-1)+' entries)');
	Result := sectionCacheCur;
end;


{Gets the record reference index lookup table}
function getRecordReferenceIndex(signature:String):THashedStringList;
var 
	index: Integer;
begin
	if not Assigned(_lstRecSigCache) then 
		_initRecordReferenceCache;

	if Assigned(_lstRecSigCache) then begin
		index := _lstRecSigCache.indexOfName(signature);
		if index <> -1 then begin
			Result := _lstRecSigCache.Objects[index];
			Exit;
			end;
		end;
	// Cache doesn't exist, create it. 
	Result := RecordLib._createRecordReferenceIndex(signature)
end;

{Initializes the cache for record references. Validates entries on load }
procedure _initRecordReferenceCache;
var 
	i: Integer;
	keywordCacheValidationStr: String;
	sectionCacheCur, sectionCacheNew: TStringList;
begin
	// Init and explode result cache, get direct ref for faster access
	Cache.initBulkStorage('recordReferences');
	Cache.initLevelTwoCache('recordReferences');
	_lstRecSigCache := Cache.getDirectAccessCachedEntriesList('recordReferences');
	
	// Validation
	keywordCacheValidationStr := 'RECREF_VALIDATION:'+getLoadOrderFilesString();
	for i := _lstRecSigCache.Count - 1 downto 0 do 
		if Cache.getEntrySetLevelTwo('recordReferences',_lstRecSigCache.Names[i],false,sectionCacheCur,sectionCacheNew) then begin
			if sectionCacheCur.Values['_VALIDATION'] = keywordCacheValidationStr then
				AddMessage('    (Loaded record references cache for "'+_lstRecSigCache.Names[i]+'". Entries: '+IntToStr(sectionCacheCur.Count-1)+')')
			else // Invalidate
				Cache.removeEntrySetLevelTwo('recordReferences',_lstRecSigCache.Names[i]);
			end;
	
end;

{Set the reference of another record in this record field}
procedure setRecordReference(rec:IInterface;fieldPath, grpSignature, refRecEDID:String);
var 
	refRec: IInterface;
	refLoFormIDHex, refRecSrcFile: String;
begin
	refLoFormIDHex := RecordLib.getRecordReferenceIndex(grpSignature).Values[refRecEDID];
	refRecSrcFile := RecordLib.getRecordReferenceIndex(grpSignature).Values[refRecEDID+':file'];
	AddMasterIfMissing(mxPatchFile, refRecSrcFile);
	if fieldPath = '' then 
		SetEditValue(rec, refLoFormIDHex)
	else
		SetElementEditValues(rec, fieldPath, refLoFormIDHex);
end;

{Just OverrideByFile only backwards}
function OverrideByFileBack(e, f: IInterface): IInterface;
var
  i: Integer;
  ovr: IInterface;
begin
  Result := nil;
  e := MasterOrSelf(e);
  for i := OverrideCount(e) - 1 downto 0 do begin
    ovr := OverrideByIndex(e, i);
    if Equals(GetFile(ovr), f) then begin
      Result := ovr;
      break;
    end;
  end;
end;



{unit cleanup}
procedure cleanup();
var
	i:Integer;
begin
	// Save cache
	if Cache.existsCache('recordReferences') then begin
		Cache.save('recordReferences', true);
		_lstRecSigCache := nil; // Only reference, cleanup by Cache unit
		kywdCache := nil; // Only reference, cleanup by Cache unit
		end;
		
	FreeAndNil(kywdCache);
	FreeAndNil(_rl_cacheFileCRCs);	
	
	if Assigned(recordsInTasks) then
		for i:= 0 to recordsInTasks.Count - 1 do 
			recordsInTasks.Objects[i].Free;
	FreeAndNil(recordsInTasks);
	
end;

end.