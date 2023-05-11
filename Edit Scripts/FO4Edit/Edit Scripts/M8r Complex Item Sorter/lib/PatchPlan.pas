{
	M8r98a4f2s Complex Item Sorter for FallUI - PatchPlan module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Analyses records and planing optimized record distribution to patch files.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}


unit PatchPlan;

var
	lPatchPlan: TStringList;
	recordsIndex: TStringList;
	recordsSourceFiles: THashedStringList;
	lOriginalRecords: TStringList;
	iOriginalRecCnt,iOriginalRecFilteredCnt, iPatchRecCnt: Integer;
	// Private
	_planEntriesRecordCount: TStringList;
	_planUsedRecordTypes: TStringList;

procedure init();
begin
	cleanup();
	// Setup
	lPatchPlan := TStringList.Create;
	lOriginalRecords := TStringList.Create;
	_planEntriesRecordCount := TStringList.Create;
	_planUsedRecordTypes := TStringList.Create;
	recordsSourceFiles := THashedStringList.Create;
	// Find used record types 
	_findUsedRecords();
end;


procedure _findUsedRecords();
var
	i,j: Integer;
	lstPrcTasks: TStringList;
begin
	// Load records by group
	lstPrcTasks := Tasks.getProcessingActiveTasks();
	for i := 0 to lstUseRecordTypes.Count -1 do
		for j := 0 to lstPrcTasks.Count - 1 do 
			if (CustomRuleSets.getProccessingRuleSetsArray(lstPrcTasks.Names[j],'',lstUseRecordTypes[i],sFiles).Count > 0)
				or (lstUseRecordTypes[i] = 'INNR' ) then begin // Only if rules available
				_planUsedRecordTypes.Append(lstUseRecordTypes[i]);
				break; // Loading records of one type only once				
				end;
		// Add dynamic record types 
	{for i := 0 to _planUsedRecordTypes.Count -1 do
		if _planUsedRecordTypes[i] <> 'INNR' then
			ProgressGUI.addStep('ptch'+_planUsedRecordTypes[i],'Patch '+_planUsedRecordTypes[i],
				Round(45+50*( i/ _planUsedRecordTypes.Count ) ) );
	if _planUsedRecordTypes.indexOf('INNR') > -1 then 
		ProgressGUI.addStep('ptchINNR', 'Processing INNR records',95);
	//ShowMessage(_planUsedRecordTypes.CommaText);
	ProgressGUI.updateForm();}


end;

{Load all records for pre-filtering}
function loadAllRecords():Boolean;
var
	i: Integer;
	lstRecords: TList;
begin
	// Load records by group
	{lstPrcTasks := Tasks.getProcessingActiveTasks();
	for i := 0 to lstUseRecordTypes.Count -1 do
		for j := 0 to lstPrcTasks.Count - 1 do 
			if (CustomRuleSets.getProccessingRuleSetsArray(lstPrcTasks.Names[j],'',lstUseRecordTypes[i],sFiles).Count > 0)
				or (lstUseRecordTypes[i] = 'INNR' ) then begin // Only if rules available}
	for i := 0 to _planUsedRecordTypes.Count-1 do begin
		if bUserRequestAbort then Exit;
		lstRecords := _loadRecordsMxpfFast(_planUsedRecordTypes[i]);
		lOriginalRecords.AddObject(_planUsedRecordTypes[i], lstRecords);
		iOriginalRecCnt := iOriginalRecCnt + lstRecords.Count;
		ProgressGUI.setStatistic('Records', IntToStr(iOriginalRecCnt));
		//ProgressGUI.setProgressPercentCurrentStep( (j+i*lstPrcTasks.Count) * 100 / (lstUseRecordTypes.Count*lstPrcTasks.Count) );
		ProgressGUI.setProgressPercentCurrentStep( i * 100 / (_planUsedRecordTypes.Count) );
		end;
	Result := iOriginalRecCnt > 0;
end;

{Fast conversion of mxpf LoadRecords}
function _loadRecordsMxpfFast(sig: string):TList;
var
	i,j,k: Integer;
	iFile0,iFile1,iFile2, iGroup, rec, recMS: IInterface;
	tmpLst: TStringList;
begin
	tmpLst := TStringList.Create;
	mxLoadCalled := true;
	Result := TList.Create;
	
	// loop through files
	for i := 0 to Pred(FileCount) do begin
		iFile0 := FileByIndex(i);
		
		// Only included files 
		if mxFiles.IndexOf(GetFileName(iFile0)) = -1 then
			continue;
		
		iGroup := GroupBySignature(iFile0, sig);
		if not Assigned(iGroup) then
			continue;

		// For every item in group
		for j := 0 to ElementCount(iGroup)-1 do begin
			rec := ElementByIndex(iGroup, j);

			// Master only
			if not IsMaster(rec) then
				continue;

			// Winning override
			rec := WinningOverrideBefore(rec, mxPatchFile);
			
			// Add record
			Result.Add(TObject(rec));
			
			// Index source files
			iFile1 := getFile(rec);
			if isMaster(rec) then
				recordsSourceFiles.append(IntToHex(GetLoadOrderFormID(rec),8)+'='+getFileName(iFile1))
			else begin
				tmpLst.Clear();
				recMS := MasterOrSelf(rec);
				for k := OverrideCount(recMS) - 1 downto 0 do begin
					iFile2 := getFile(OverrideByIndex(recMS,k));
					tmpLst.append(getFileName(iFile2));
					// Last: Check for patch files in record history 
					if GetElementEditValues(ElementByIndex(iFile2, 0), 'CNAM - Author') <> 'R88_SimpleSorter' then
						Continue;
					end;
				tmpLst.append(getFileName(getFile(recMS)));
									
				// Index - simulate non-existing TStringList.AddPair
				{tmpLst2.Clear();tmpLst2.Values[IntToHex(GetLoadOrderFormID(recMS),8)] := tmpLst.CommaText;recordsSourceFiles.append(tmpLst2[0]);}
				recordsSourceFiles.append(IntToHex(GetLoadOrderFormID(recMS),8)+'='+tmpLst.CommaText);
				
				end;

			// Last: Check for patch files in record history 
			if GetElementEditValues(ElementByIndex(iFile1, 0), 'CNAM - Author') <> 'R88_SimpleSorter' then
				Continue;
			AddMessage('WARNING: Record ['+Signature(rec)+':'+IntToHex(GetLoadOrderFormID(rec),8)+']'
				+' (EditorId: '+EditorId(rec)+') is already modified by sorter script file "'+getFileName(iFile1)+'"! Doubled processing will most possible lead to unwanted results!');
			
			end;
		end;
	tmpLst.Free;
end;

{Creates the index of record source files}
{procedure _indexRecordSourceFiles;
var 
	i,k,r: Integer;
	tmpLst: TStringList;
	lRecordsOfRecType: TList;
	rec,iFile,iFile2: IInterface;
begin
	recordsSourceFiles.Clear();
	tmpLst := TStringList.Create;
	
	for i := lOriginalRecords.Count-1 downto 0 do begin
		lRecordsOfRecType := lOriginalRecords.Objects[i];
		for r := lRecordsOfRecType.Count-1 downto 0 do begin
			rec := ObjectToElement(lRecordsOfRecType[r]);
			iFile := getFile(rec);
			if isMaster(rec) then
				recordsSourceFiles.append(IntToHex(GetLoadOrderFormID(rec),8)+'='+getFileName(iFile))
			else begin
				tmpLst.Clear();
				rec := MasterOrSelf(rec);
				for k := OverrideCount(rec) - 1 downto 0 do begin
					iFile2 := getFile(OverrideByIndex(rec,k));
					tmpLst.append(getFileName(iFile2));
					// Last: Check for patch files in record history 
					if GetElementEditValues(ElementByIndex(iFile2, 0), 'CNAM - Author') <> 'R88_SimpleSorter' then
						Continue;
					AddMessage('WARNING: Record ['+Signature(rec)+':'+IntToHex(GetLoadOrderFormID(rec),8)+']'
						+' (EditorId: '+EditorId(rec)+') is already modified by sorter script file "'+getFileName(iFile2)+'"! Doubled processing will most possible lead to unwanted results!');
					end;
				tmpLst.append(getFileName(iFile));
									
				// Index - simulate non-existing TStringList.AddPair
				//tmpLst2.Clear();tmpLst2.Values[IntToHex(GetLoadOrderFormID(rec),8)] := tmpLst.CommaText;recordsSourceFiles.append(tmpLst2[0]);
				recordsSourceFiles.append(IntToHex(GetLoadOrderFormID(rec),8)+'='+tmpLst.CommaText);
				end;

			// Last: Check for patch files in record history 
			if GetElementEditValues(ElementByIndex(iFile, 0), 'CNAM - Author') <> 'R88_SimpleSorter' then
				Continue;
			AddMessage('WARNING: Record ['+Signature(rec)+':'+IntToHex(GetLoadOrderFormID(rec),8)+']'
				+' (EditorId: '+EditorId(rec)+') is already modified by sorter script file "'+getFileName(iFile)+'"! Doubled processing will most possible lead to unwanted results!');
			
			end;
		end;
	tmpLst.Free;
end;}

{Checks all records for required masters (include requried masters due to winning overrides)}
procedure createPatchPlan();
var
	i, j,r, iMastersGrpIndex, iMaxMastersPerFile: Integer;
	rec,iFile: IInterface;
	tmpLst2,tmpLst3, lRecordsOfRecType, lstReqMastersGrouping, lstCurMasters, lstPatchFilenames: TStringList;
	lstRecords: TList; // Start: 11.2
	bIsGrouped: Boolean;
	sMasters, patchFilename, sRecType: String;
begin
	
	// Setup
	iMaxMastersPerFile := getSettingsInteger('config.iMaxMastersPerFile', StrToInt(scDefaults.values['config.iMaxMastersPerFile']) );
	if iMaxMastersPerFile < 10 then
		raise Exception.Create('Invalid or too low max masters. Abort planning.');

	lPatchPlan.Clear();
	lstPatchFilenames := TStringList.Create;
	lstReqMastersGrouping := TStringList.Create;
	tmpLst2 := TStringList.Create;
	tmpLst2.Sorted := true;
	tmpLst2.Duplicates := dupIgnore;
	tmpLst3 := TStringList.Create;
	tmpLst3.Sorted := true;
	tmpLst3.Duplicates := dupIgnore;
	
	for i := lOriginalRecords.Count-1 downto 0 do begin
		lRecordsOfRecType := lOriginalRecords.Objects[i];
		sRecType := lOriginalRecords[i];
		for r := lRecordsOfRecType.Count-1 downto 0 do begin
			rec := ObjectToElement(lRecordsOfRecType[r]);
			if not Assigned(rec) then
				continue;
				
			// Add required masters to temp list
			tmpLst2.Clear();
			ReportRequiredMasters(rec,tmpLst2,false,true);
			sMasters := tmpLst2.CommaText;
			
			// Group by req masters
			iMastersGrpIndex := lstReqMastersGrouping.indexOf(sMasters);
			if iMastersGrpIndex = -1 then 
				iMastersGrpIndex := lstReqMastersGrouping.AddObject(sMasters, TList.Create);
			lstReqMastersGrouping.Objects[iMastersGrpIndex].Add(lRecordsOfRecType[r]);
			
			end;
		end;
	
	// Build patch plan. Merging req masters groups into bigger groups up to maxMastersCount
	for i := 0 to Pred(lstReqMastersGrouping.Count) do begin
		sMasters := lstReqMastersGrouping[i];
		lstRecords := lstReqMastersGrouping.Objects[i];
		// Search big group to stuff into
		bIsGrouped := false;
		for j := 0 to lPatchPlan.Count-1 do begin 
			tmpLst2.CommaText := lPatchPlan[j] + ',' + sMasters;
			if tmpLst2.Count <= iMaxMastersPerFile then 
				bIsGrouped := true
			else begin
				// Check more intense - Already contains all needed masters?
				tmpLst3.CommaText := lPatchPlan[j];
				if tmpLst2.Count = tmpLst3.Count then 
					bIsGrouped := true;
				end;
			// In?
			if bIsGrouped then begin
				// Add to planned patch file
				lPatchPlan[j] := tmpLst2.CommaText;
				lPatchPlan.Objects[j].AddObject('',lstRecords);
				_planEntriesRecordCount[j] := IntToStr(StrToInt(_planEntriesRecordCount[j])+lstRecords.Count);
				break;
				end;
			
			end;
		if bIsGrouped then 
			continue;
			
		// Plan new output patch file - first find a pretty filename!
		if lPatchPlan.Count = 0 then
			patchFilename := getSettingsString('config.sTargetESPPatchFile','')
		else patchFilename := getBaseESPName(getSettingsString('config.sTargetESPPatchFile',''))+'-part'+IntToStr(lPatchPlan.Count+1)+'.esp';
		lstPatchFilenames.Add(patchFilename);
		// Read existing masters and merge with new masters
		lstCurMasters := _readMasterFiles(FileByName(patchFilename));
		tmpLst2.CommaText := sMasters;
		tmpLst2.AddStrings(lstCurMasters);
		lstCurMasters.Free;
		if tmpLst2.Count = 0 then 
			tmpLst2.Add('Fallout4.esm');
		
		// Add new plan entry
		j := lPatchPlan.AddObject(tmpLst2.CommaText, TStringList.Create);
		lPatchPlan.Objects[j].AddObject('',lstRecords);
		_planEntriesRecordCount.Add(IntToStr(lstRecords.Count));
		
		end;
	
	// Add patch filenames
	for i := 0 to Pred(lPatchPlan.Count) do
		lPatchPlan[i] := lstPatchFilenames[i] + '=' + lPatchPlan[i];
	
	// Cleanup
	tmpLst2.Free;
	tmpLst3.Free;
	lstReqMastersGrouping.Free;
end;

{Prepare patch files}
{procedure preparePatchFiles();
var 
	i,j: Integer;
	patchFilename, sMasters: String;
	lstTestMasters: THashedStringList;
	lstPatchFileReqMasters, lstPatchFileCurMasters: TStringList;
	iFile: IInterface;
begin
	lstPatchFileReqMasters := TStringList.Create;
	lstPatchFileReqMasters.Sorted := True;
	lstPatchFileReqMasters.Duplicates := dupIgnore;
	for i := 0 to lPatchPlan.Count - 1 do begin
		// Start
		patchFilename := lPatchPlan.Names[i];
		iFile := FileByName(patchFilename);
		sMasters := lPatchPlan.ValueFromIndex[i];
		lstTestMasters := THashedStringList.Create;
		lstTestMasters.Sorted := True;
		lstTestMasters.Duplicates := dupIgnore;
		lstTestMasters.CommaText := sMasters;
		// Add existing used masters in file
		lstPatchFileReqMasters.Clear();
		ReportRequiredMasters(iFile,lstPatchFileReqMasters,false,true);
		lstTestMasters.AddStrings(lstPatchFileReqMasters);
		
		lstPatchFileCurMasters := _readMasterFiles(iFile);
		for j := 0 to lstPatchFileCurMasters.Count - 1 do begin
			if lstTestMasters.indexOf(lstPatchFileCurMasters[j]) = -1 then begin
				AddMessage('Found probably unnecessary master: '+lstPatchFileCurMasters[j]+'. Start cleaning.');
				CleanMasters(iFile);
				break;
				end;
			end;
		lstPatchFileCurMasters.Free;
		
		end;
	lstPatchFileReqMasters.Free;
end;}

{Reads master entries of mod file}
function _readMasterFiles(iFile:IInterface):TStringList;
var
	i: Integer;
	iMasters: IInterface;
begin
	iMasters := ElementByPath(ElementByIndex(iFile, 0), 'Master Files');
	Result := TStringList.Create;
	Result.Sorted := True;
	Result.Duplicates := dupIgnore;
	if Assigned(iMasters) then
		for i := 0 to ElementCount(iMasters) - 1 do
			Result.Add(GetElementEditValues(ElementByIndex(iMasters, i), 'MAST'));
			

end;

{Distribute the records to the target patch files}
procedure copyRecordsToPatches();
var 
	i,j,k,n,index, iCurrentK: Integer;
	patchFilename, sMasters: String;
	patchFileRecordLists: TStringList;
	lstRecords, lstPatchRecords: TList;
	rec: IInterface;
begin
	recordsIndex := TStringList.Create;
	iPatchRecCnt := 0;

	try
		for i := 0 to lPatchPlan.Count - 1 do begin
			// Start
			patchFileRecordLists := lPatchPlan.Objects[i];
			patchFilename := lPatchPlan.Names[i];
			sMasters := lPatchPlan.ValueFromIndex[i];
			
			// Target patch file - create on demand
			mxPatchFile := FileByName(patchFilename);
			if not Assigned(mxPatchFile) then begin
				mxPatchFile := AddNewFileName(patchFilename);
				SetAuthor(mxPatchFile, 'R88_SimpleSorter');
				end;
			
			// Summary
			mxMasters.CommaText := sMasters;
			AddMessage('Patch file ('+IntToStr(i+1)+'/'+IntToStr(lPatchPlan.Count)+'): '+patchFilename+' - '
				+' MasterCount=' + IntToStr(mxMasters.Count)
				+' RecordCount='+_planEntriesRecordCount[i]
				+' MasterFiles=' + sMasters);
			
			_logStep('Adding masters...');
			mxMastersAdded := False;
			AddMastersToPatch();
			
			_logStep('Copy records...');
			
			for j := 0 to Pred(patchFileRecordLists.Count) do begin
				lstRecords := patchFileRecordLists.Objects[j];
				// Some records are bad, so try catch needed
				iCurrentK := 0;
				while iCurrentK < lstRecords.Count do begin
					try
						for k := iCurrentK to Pred(lstRecords.Count) do begin
							Inc(iCurrentK);
							rec := wbCopyElementToFile(ObjectToElement(lstRecords[k]), mxPatchFile, false, true);

							if not Assigned(rec) then
								raise Exception.Create('Error while copying records!');
							// Add to processing index
							index := recordsIndex.indexOf(Signature(rec));
							if index = -1 then
								index := recordsIndex.addObject(Signature(rec), TList.Create);
							
							recordsIndex.Objects[index].Add(TObject(rec));
							Inc(iPatchRecCnt);
							// Statistics			
							Inc(n);
							if n = 100 then begin 
								if bUserRequestAbort then Exit;
								n := 0;
								ProgressGUI.setProgressPercentCurrentStep( iPatchRecCnt / iOriginalRecCnt * 100 );
								end;
							end;					
					except 
						on E: Exception do begin
							AddMessage('Error while copying records to output file "'+patchFilename+'": '+E.Message);
							try 
								rec := ObjectToElement(lstRecords[k]);
								AddMessage('Failing record: '+ShortName(rec));
								AddMessage('  in File: '+GetFileName(GetFile(rec)));
							except 
								AddMessage('No info about failing record available!');
								end;
							end;
						end;
					end;
				lstRecords.Free; // No longer needed
				end;
					
			end;
		
	except 
		on E: Exception do begin
			AddMessage('Error while copying records to output file "'+patchFilename+'": '+E.Message);
			ShowMessage('Error while copying records to output file "'+patchFilename+'": '+E.Message);
			bUserRequestAbort := True;
			try 
				rec := ObjectToElement(lstRecords[k]);
				AddMessage('Failing record: '+ShortName(rec));
				AddMessage('  in File: '+GetFileName(GetFile(rec)));
			except 
				AddMessage('No info about failing record available!');
				end;
			end;
		end;
	
end;


{Cleanup}
procedure cleanup();
var 
	i: Integer;
begin
	if Assigned(lPatchPlan) then
		for i := 0 to lPatchPlan.Count - 1 do 
			lPatchPlan.Objects[i].Free;
	FreeAndNil(lPatchPlan);

	if Assigned(lOriginalRecords) then
		for i := 0 to lOriginalRecords.Count-1 do 
			lOriginalRecords.Objects[i].Free;
	FreeAndNil(lOriginalRecords);

	if Assigned(recordsIndex) then
		for i := recordsIndex.Count - 1 downto 0 do
			if Assigned(recordsIndex.Objects[i]) then
				recordsIndex.Objects[i].Free;
	FreeAndNil(recordsIndex);
	FreeAndNil(recordsSourceFiles);
	FreeAndNil(_planEntriesRecordCount);
	FreeAndNil(_planUsedRecordTypes);
	
end;

end.