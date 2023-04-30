{
	M8r98a4f2s Complex Item Sorter for FallUI
		based on Ruddy88's VIS-G Auto Patcher
	FALLOUT 4
	
	Main unit.

	A more complex automatic Item Sorting Script.
	Adds language independence and many other features.
	Configuration files can be found in "..\F04Edit\Edit Scripts\M8r Complex Item Sorter" as ini files
	
	Requires: FO4Edit and Ruddy88's Simple Sorter INNR esp.
	Recommended, but not required: FallUI

	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
	
	Credits:
	 Ruddy88 (Author of Simple Sorter. Complex Sorter uses parts of it - Usage is granted by Ruddy88)
	 Neeanka (Author of DEF_INV)
	 Valdacil (Author of DEF_UI)
	 MatorTheEternal (Author of MXPF)
	 The full F04Edit team
	 Bethesda (Fallout 4)
	
	Hotkey: Ctrl+Y
}

unit ComplexSorter;

// Imports
uses
	'M8r Complex Item Sorter/lib/MXPF/mxpf',
	'M8r Complex Item Sorter/lib/CSPluginSystem',
	'M8r Complex Item Sorter/lib/Cache',
	'M8r Complex Item Sorter/lib/CustomRuleSets',
	'M8r Complex Item Sorter/lib/Diagnostics',
	'M8r Complex Item Sorter/lib/DynamicPatcher',
	'M8r Complex Item Sorter/lib/FlagFunctions',
	'M8r Complex Item Sorter/lib/INNRProcessing',
	'M8r Complex Item Sorter/lib/PatchPlan',
	'M8r Complex Item Sorter/lib/RecordLib',
	'M8r Complex Item Sorter/lib/RecordScript',
	'M8r Complex Item Sorter/lib/ScriptConfiguration',
	'M8r Complex Item Sorter/lib/Tasks',
	'M8r Complex Item Sorter/lib/helper',
	//'M8r Complex Item Sorter/lib/CSToolBox',
	'M8r Complex Item Sorter/lib/GUI/AutoForm',
	'M8r Complex Item Sorter/lib/GUI/EasyForm',
	'M8r Complex Item Sorter/lib/GUI/ProgressGUI',
	'M8r Complex Item Sorter/lib/GUI/ComplexSorterGUI',
	'M8r Complex Item Sorter/lib/GUI/RuleEditorGUI',
	'M8r Complex Item Sorter/lib/GUI/FormSimpleSelection',
	'M8r Complex Item Sorter/lib/GUI/CSPluginsGUI'
;

var
	// Global vars
	sComplexSorterBasePath, sComplexSorterFo4DataPath, sFiles, sLanguageFO4EditParam, sLineBreak: String;
	tagsIniFile, tagsIniFileUser, tagsIniFileData: TIniFile;
	r88SimpleSorterInnrEsp: IInterface;
	bReset, bUserRequestAbort, bCPAutoStartGen: Boolean;
	lstUseRecordTypes: TStringList;

const 
	COMPLEX_SORTER_INTVERSION = '1.10';
	
{Main start routine}
procedure run();
var 
	iStartCP: Integer;
begin
	try

	// Init
	_init();
	
	// Find general setup problems
	_checkSetupProblems();
	
	// Main GUI
	iStartCP := -1;
	while iStartCP = -1 do 
		iStartCP := ComplexSorterGUI.ShowFormMainMenu();
		
	// Canceld?
	if iStartCP = 0 then
		AddMessage('User cancelled patching: Operation cancelled. No patch generated')
	else if iStartCP = 1 then begin
		
		// Save settings
		ScriptConfiguration.saveSettings();
		
		// Start main script
		_startProcessing();
		
		end;
	
	finally
		_cleanup();
	end;
end;

	
{Inits Complex Sorter}
procedure _init();
var 
	i: Integer;
	tmpLst: TStringList;
begin	

	// Find new line char - define as sLineBreak
	tmpLst := TStringList.Create;
	tmpLst.Add('');
	sLineBreak := tmpLst.Text;
	tmpLst.Free;
	
	// Find language parameter if exists
	sLanguageFO4EditParam := '';
	bCPAutoStartGen := false;
	for i := 1 to ParamCount do 
		if Pos('-l:', ParamStr(i)) = 1 then
			sLanguageFO4EditParam := Copy(ParamStr(i),4,100)
		else if Pos('-cpAutoStartGen', ParamStr(i)) = 1 then 
			bCPAutoStartGen := true;
	
	// Global settings
	sComplexSorterBasePath := ScriptsPath()+'M8r Complex Item Sorter\';
	sComplexSorterFo4DataPath := DataPath()+'Complex Sorter\';
	
	bUserRequestAbort := false;
	lstUseRecordTypes := TStringList.Create;

	
	
	// Setting defaults
	scDefaults := THashedStringList.Create();
	scDefaults.values['config.bEspFilesAutoAll'] := True;
	scDefaults.values['config.bResetRecords'] := True;
	
	scDefaults.values['config.bTranslateINNR'] := helper.getFallout4LanguageCode() <> 'en';
	scDefaults.values['config.bIncludeR88InnrRules'] := False;
	
	scDefaults.values['config.bProgressCloseOnFinished'] := True;
	
	scDefaults.values['config.bHeuristicAddTagsToWeaponsTemplates'] := True;
	scDefaults.values['config.bHeuristicAddTagsToWeapons'] := True;
	scDefaults.values['config.bHeuristicInjectRulesToWeaponsINNR'] := True;
	scDefaults.values['config.bHeuristicAddTagsToApparel'] := True;
	scDefaults.values['config.bHeuristicInjectInnrKeywordTags'] := True;

	scDefaults.values['config.bUseCacheKeywords'] := True;
	scDefaults.values['config.bUseCachePluginScript'] := True;
	scDefaults.values['config.bUseCacheConditionCheck'] := False;
	scDefaults.values['config.bUseCacheProcSetResult'] := True;
	scDefaults.values['config.bGatherStatistics'] := False;

	scDefaults.values['config.iMaxMastersPerFile'] := '240';
	
	scDefaults.values['task.ItemSorterTags.active'] := True;
	
		
	// Read environment
	r88SimpleSorterInnrEsp := FileByName('R88_SimpleSorter.esp');
	
	// Init Modules
	Cache.init();
	Tasks.init();

	// Load plugins
	AddMessage('Load Complex Sorter plugins...');
	measureTimeStart(1);
	CSPluginSystem.init();
	measureTimeDefaultAfter(1);
	
	// Load settings
	tagsIniFile := TIniFile.Create(sComplexSorterBasePath+'Rules (Default)\tags.ini');
	tagsIniFileData := TIniFile.Create(sComplexSorterFo4DataPath+'Rules (Tag Configuration)\tags.ini');
	tagsIniFileUser := TIniFile.Create(sComplexSorterBasePath+'Rules (User)\tags.ini');
	
	// Load profiles
	loadSettingsProfile();
		
end;


{Load a settings profile}
procedure loadSettingsProfile();
begin
	ScriptConfiguration.init(getCurrentSettingsProfileName());

	// Clean up settings and defaults
	if getSettingsString('config.sUseRecords', '') = '' then
		setSettingsString('config.sUseRecords', helper.getDefaultRecordsString());
	lstUseRecordTypes.CommaText := getSettingsString('config.sUseRecords', '');
			
	if getSettingsString('config.sTargetESPPatchFile','') <> '' then
		mxPatchFile := FileByName(getSettingsString('config.sTargetESPPatchFile',''));

	// Input esps
	AddMessage('Check available esp and creating file checksums...');
	measureTimeStart(1);
		
	// Check files since last gen
	_findFilesInLoadOrderForUpdate();
	
	// Standard all files
	updateSFiles();
	
	measureTimeDefaultAfter(1);		
	
	// Update plugins 
	CSPluginSystem.readPluginActiveFromSettings();
		
end;

{Checks files since last generation for new or updated ones}
procedure _findFilesInLoadOrderForUpdate();
var
	i: Integer;
	filesKnown, filesLoadOrder, filesNeedUpdate: TStringList;
	f: IInterface;
	sFileName, sFileCRC: String;
begin
	filesKnown := TStringList.Create;
	sFileName := sComplexSorterBasePath+'cache\lastGenLoadOrderFiles.'+getCurrentSettingsProfileName()+'.cache';
	if FileExists(sFileName) then
		filesKnown.LoadFromFile(sFileName);
	
	filesNeedUpdate := TStringList.Create;
	for i := 0 to FileCount - 2 do begin
		f := FileByLoadOrder(i);
		sFileName := GetFileName(f);
		if (sFileName = '') or (GetAuthor(f) = 'R88_SimpleSorter') then
			continue;
		sFileCRC := DynamicPatcher.getFileCRC(sFileName);
		
		if filesKnown.indexOf(sFileName + ':' + sFileCRC ) = -1 then 
			filesNeedUpdate.append(sFileName);
		end;
	
	if (filesNeedUpdate.Count > 0 ) and Assigned(r88SimpleSorterInnrEsp) then 
		filesNeedUpdate.append(GetFileName(r88SimpleSorterInnrEsp));
	
	setSettingsString('config.sUseESPFilesUpdate',filesNeedUpdate.CommaText);
	filesKnown.Free;
	filesNeedUpdate.Free;
end;

{Update mod file list for processing}
procedure updateSFiles;
var 
	i:Integer;
	useSettingKey,sFileName: String;
	tmpLst1,tmpLst2: TStringList;
begin
	if not getSettingsBoolean('config.bResetRecords') then		
		sFiles := getSettingsString('config.sUseESPFilesUpdate','')
	else begin
		if getSettingsBoolean('config.bEspFilesAutoAll') or (getSettingsString('config.sUseESPFiles','') = '') then
			sFiles := getAllEspFilesString()
		else
			sFiles := getSettingsString('config.sUseESPFiles','');
		end;
	// Only allow existing files
	tmpLst1 := TStringList.Create;
	tmpLst2 := TStringList.Create;
	tmpLst1.CommaText := sFiles;
	for i := 0 to FileCount - 2 do begin
		sFileName := (GetFileName(FileByLoadOrder(i)));
		if tmpLst1.indexOf(sFileName) <> -1 then 
			tmpLst2.append(sFileName);
		end;
	sFiles := tmpLst2.CommaText;
	tmpLst1.Free;
	tmpLst2.Free;
end;

{Shows a log message for the next step. Also adding measuring times.}
procedure _logStep(msg:String);
begin
	measureTimeDefaultAfter(1); // Finish job before
	AddMessage(msg);
	measureTimeStart(1);
end;

{Starts the main Complex Sorter Scripts}
procedure _startProcessing();
var
	i,j: Integer;
	tmpFile: IInterface;
	bCopyingStarted: Boolean;
begin

	// Check
	if sFiles = '' then begin 
		showMessage('No input files selected.');
		Exit;
		end;
	try
	// Start
	measureTimeStart(0);

	_logStep('Patching process started. Initialize processing system...');

	// Setup
	globalModificationsAllowed := false;
	pDR_gatherStats := getSettingsBoolean('config.bGatherStatistics');
	lstUseRecordTypes.CommaText := getSettingsString('config.sUseRecords', '');
	
	// Setup tasks
	Tasks.updateActiveTasks();
	
	// Initialize progress window
	_initProgressGUI(lstUseRecordTypes);

	// First step
	ProgressGUI.setCurrentStep('gen_init');
	
	// Read tags
	ScriptConfiguration.readTags();
			
	// Setup mxpf - Call MXPF init functions and set MXPF prefs
	_initMXPF();
		
	// Save valid settings
	setSettingsString('config.sTargetESPPatchFile',getFileName(mxPatchFile));	
	ScriptConfiguration.saveSettings();
		
	// Search custom ESP rules
	_logStep('Loading processing rules...');
	ProgressGUI.setCurrentStep('loadruls');
	CustomRuleSets.init();
	
	// Init modules
	_logStep('Initialise submodules...');
	DynamicPatcher.init();
	CSPluginScript.reinitCache();
	
	// Keywords and -cache
	_logStep('Loading keywords...');
	RecordLib.initKeywordCache();
	
	// Nukes previous patch files if creating NEW PATCH.
	if bReset then begin
		_logStep('Remove existing records...');
		ProgressGUI.setCurrentStep('remXRecs');
		
		// Clean further parts
		for j := 0 to 100 do begin
			if j = 0 then 
				tmpFile := mxPatchFile
			else
				tmpFile := FileByName(getBaseESPName(getSettingsString('config.sTargetESPPatchFile',''))+'-part'+IntToStr(j+1)+'.esp');
			if not Assigned(tmpFile) then 
				break
			else for i := 0 to lstUseRecordTypes.Count -1 do
				RemoveNode(GroupBySignature(tmpFile, lstUseRecordTypes[i]));
			end;
		end

	// Patch Plan
	_logStep('Initialize patch plan module...');
	PatchPlan.init();
		
	// Load valid records.
	_logStep('Loading records and building source file index...');
	ProgressGUI.setCurrentStep('loadRecs');
	if not PatchPlan.loadAllRecords() then begin
		if not bUserRequestAbort then
			ShowMessage('No records found.');
		Exit;
		end;
	
	// Abort?
	if bUserRequestAbort then Exit;

	AddMessage('    Records loaded: ' + IntToStr(iOriginalRecCnt ) +'  in '+measureTimeGetFormatted(1));
		
	// Start prefiltering
	_logStep('Pre-filtering records... ');
	ProgressGUI.setCurrentStep('filtRecs');
	RecordLib.filterRecords();
	AddMessage('    Records filtered: '+IntToStr(iOriginalRecFilteredCnt)+'  in '+measureTimeGetFormatted(1));
	if bUserRequestAbort then Exit; // Abort?
		
	// Nothing left?
	if iOriginalRecCnt = 0 then begin
		ShowMessage('No records left after pre-filtering.');
		Exit;
		end;
	
	// Update mode: Cleaning records from file before update (so new copyRecToFile copies the new data)
	if not bReset then
		_removeExistingRecordsInUpdateMode();
	
	// Checking for new required master due to winning overrides
	_logStep('Analysing and indexing records for required masters and plan optimized output patch files...');
	PatchPlan.createPatchPlan();
	if bUserRequestAbort then Exit; // Abort?
	
	// Copy remaining records to patch file. Indexing on the way
	_logStep('Creating patch files and copying '+IntToStr(iOriginalRecCnt)+' records to patch...');
	ProgressGUI.setCurrentStep('copyRecs');
	bCopyingStarted := True;
	PatchPlan.copyRecordsToPatches();
	if bUserRequestAbort then Exit; // Abort?

	// Patch time has begun
	globalModificationsAllowed := true;

	// Build translation index
	if getSettingsBoolean('config.bTranslateINNR') and (recordsIndex.indexOf('INNR')> -1) then begin
		_logStep('Build translation index...');
		INNRProcessing.buildTranslationIndex();
		end;
	if bUserRequestAbort then Exit; // Abort?
	
	// Let the fun start
	_logStep('Beginning patch file process... - Patching ' + IntToStr(iPatchRecCnt) + (' Records...'));
	
	// New dynamic processing rules
	for i := 0 to lstUseRecordTypes.Count -1 do
		if ( lstUseRecordTypes[i] <> 'INNR' ) then begin
			ProgressGUI.setCurrentStep('ptch'+lstUseRecordTypes[i]);
			DynamicPatcher.patchDynamicRules(lstUseRecordTypes[i]);
			end;
	if bUserRequestAbort then Exit; // Abort?
	
	// Process INNR
	if (recordsIndex.indexOf('INNR')> -1) then begin
		_logStep('Processing INNR records...');
		ProgressGUI.setCurrentStep('ptchINNR');
		INNRProcessing.processINNR();
		end;

	// Save this gen load order files
	_saveLastGenLoadOrderFiles();
	
	finally
		// a bit cleanup free mem
		_logStep('Patching Process Complete. Records: '+ IntToStr(iPatchRecCnt)+'. Shut down processing system...');
		DynamicPatcher.cleanup();
		CustomRuleSets.cleanup();
		CSPluginSystem.cleanup();
		RecordLib.cleanup();
			
		// Cleanup MXPF
		if mxInitialized then begin
			if globalModificationsAllowed and bCopyingStarted then begin 
				_logStep('Finalising Script. This process can take several minutes, please be patient');
				mxPatchFile := FileByName(getSettingsString('config.sTargetESPPatchFile',''));
				if Assigned(mxPatchFile) then
					CleanMasters(mxPatchFile);
				mxPatchFile := nil;
				for j := 1 to 100 do begin
					tmpFile := FileByName(getBaseESPName(getSettingsString('config.sTargetESPPatchFile',''))+'-part'+IntToStr(j+1)+'.esp');
					if not Assigned(tmpFile) then 
						break
					else
						CleanMasters(tmpFile);
					end;
				//mxpf.PrintMXPFReport();
				mxpf.FinalizeMXPF();
				end;
			end;
			
		// Dun! - Last time measure
		measureTimeDefaultAfter(1);
		
		// Aborted or done?
		if bUserRequestAbort then
			AddMessage('======= ABORTED ======')
		else
			AddMessage('======== DONE ========');
		AddMessage('Complex Sorter runtime: '+measureTimeGetFormatted(0)+'.');
		AddMessage('======================');
		
		ProgressGUI.setCurrentStep('gen_done');
		ProgressGUI.setFinished();
		FreeAndNil(lstUseRecordTypes);
	end;

end;

{Initialize the progress window}
procedure _initProgressGUI(lstUseRecordTypes:TStringList);
var 
	i: Integer;
begin
	ProgressGUI.init();
	
	ProgressGUI.addStep('gen_init','Initialize',0);
	ProgressGUI.addStep('loadruls','Loading rules',5);
	if bReset then
		ProgressGUI.addStep('remXRecs','Remove existing records',7);
	ProgressGUI.addStep('loadRecs','Loading records',12);
	ProgressGUI.addStep('filtRecs','Prefilter records',15);
	if not bReset then
		ProgressGUI.addStep('remYRecs','Remove existing updated records',20);
	ProgressGUI.addStep('copyRecs','Copying records',35);
	ProgressGUI.addStep('indxRecs','Indexing records',40);
	
	// Add dynamic record types 
	for i := 0 to lstUseRecordTypes.Count -1 do
		if lstUseRecordTypes[i] <> 'INNR' then
			ProgressGUI.addStep('ptch'+lstUseRecordTypes[i],'Patch '+lstUseRecordTypes[i],
				Round(45+50*( i/ lstUseRecordTypes.Count ) ) );
	if lstUseRecordTypes.indexOf('INNR') > -1 then 
		ProgressGUI.addStep('ptchINNR', 'Processing INNR records',95);
	ProgressGUI.addStep('gen_done','Done',100);

	ProgressGUI.draw();
	ProgressGUI.setStatistic('Keywords','...');
	ProgressGUI.setStatistic('Records','...');
	ProgressGUI.setStatistic('Records filtered','...');
	ProgressGUI.setStatistic('Records passed','...');
	ProgressGUI.setStatistic('Records filtered (late)','...');
	ProgressGUI.setStatistic('Records patched','...');

end;

{Init MXPF and basic MXPF setup}
procedure _initMXPF();
begin
	mxpf.InitializeMXPF;
	mxLoadMasterRecords := true;
	mxLoadOverrideRecords := false;
	mxSkipPatchedRecords := false;
	mxLoadWinningOverrides := true;
	mxDebug := false;
	mxSaveDebug := false;
	mxSaveFailures := false;
	mxPrintFailures := false;
	
	// Setup files for mxpf
	AddMessage('Processing files: ' + sFiles);
	AddMessage('Processing record types: ' + getSettingsString('config.sUseRecords','Unknown'));
	mxpf.SetInclusions(sFiles);
	mxDisallowNewFile := true;
	if not Assigned(mxPatchFile) then
		PatchFileByAuthor('R88_SimpleSorter');
	mxDisallowNewFile := false;

	// Default filename
	if not Assigned(mxPatchFile) then begin
		mxPatchFile := AddNewFileName('M8r Complex Sorter.esp');
		SetAuthor(mxPatchFile, 'R88_SimpleSorter');
		if not Assigned(mxPatchFile) then begin
			AddMessage('Warning: Output patch file not writable');
			if FileExists(DataPath+'M8r Complex Sorter.esp') and not assigned(FileByName('M8r Complex Sorter.esp')) then
				if WindowConfirm('Output file not accessible','Output file exists, but isn''t loaded in FO4Edit. '+#10#13+'Should the file be deleted and recreated?') then begin
					DeleteFile(DataPath+'M8r Complex Sorter.esp');
					mxPatchFile := AddNewFileName('M8r Complex Sorter.esp');
					SetAuthor(mxPatchFile, 'R88_SimpleSorter');
					end;
			end;
		end;
	if not Assigned(mxPatchFile) then begin
		AddMessage('No output file selected!');
		exit;
		end;
	AddMessage('Output file: ' + getFileName(mxPatchFile));
end;

{Removes existing records for update mode}
procedure _removeExistingRecordsInUpdateMode();
var
	i,j: Integer;
	rec: IInterface;
begin
	AddMessage('Remove existing updated records...');
	ProgressGUI.setCurrentStep('remYRecs');
	measureTimeStart(1);

	for i := lOriginalRecords.Count-1 downto 0 do
		for j := lOriginalRecords.Objects[i].Count-1 downto 0 do begin
			rec := OverrideByFileBack(ObjectToElement(lOriginalRecords.Objects[i].Items[j]),mxPatchFile);
			if Assigned(rec) then 
				Remove(Rec);
			end;
	measureTimeDefaultAfter(1);
end;

{Remember the generation for next time}
procedure _saveLastGenLoadOrderFiles();
var
	tmpLst: TStringList;
begin
	tmpLst := TStringList.Create;
	tmpLst.CommaText := RecordLib.getLoadOrderFilesString();
	tmpLst.SaveToFile(sComplexSorterBasePath+'cache\lastGenLoadOrderFiles.cache');	
	tmpLst.Free;
end;

{Checks some general problems with the load order etc.}
procedure _checkSetupProblems();
var
	i,patchOutputFileIndex,innrRulesFileIndex:Integer;
	f,fArmorKeywords: IInterface;
	sFileName, firstPatchOutputFileName: String;
	lstProblematic: TStringList;
begin
	innrRulesFileIndex := -1;
	patchOutputFileIndex := -1;
	lstProblematic := TStringList.Create;
	// Find mod file
	for i := 0 to FileCount - 2 do begin
		f := FileByLoadOrder(i);
		sFileName := (GetFileName(f));
		if sFileName = 'R88_SimpleSorter.esp' then
			innrRulesFileIndex := i
		else if (GetAuthor(f) = 'R88_SimpleSorter') then begin
			patchOutputFileIndex := i;
			if firstPatchOutputFileName = '' then
				firstPatchOutputFileName := sFileName;
			end
		else if patchOutputFileIndex > -1 then
			lstProblematic.add(sFileName);
	end;
	
	// Files after output file
	if lstProblematic.Count > 0 then begin
		lstProblematic.Delimiter := #13;
		ShowMessage('WARNING: There are non-CS esp files after a CS output file. This could lead to wrong item naming.'+#13
			+ 'If this warning appears for a file you have downloaded, you should check if you still need the file when generating your own patch.'+#13
			+ 'For best results you should always put your generated output files to the end. '+#13+#13
			+ 'First CS generated output file: '+#13+firstPatchOutputFileName+#13+#13
			+ 'Files found after '+firstPatchOutputFileName+': '+#13+lstProblematic.DelimitedText
			);
		end;
		
	// R88 order
	if (innrRulesFileIndex > -1) and (patchOutputFileIndex > -1) and (innrRulesFileIndex > patchOutputFileIndex) then
		ShowMessage('WARNING: R88_SimpleSorter.esp is ordered after the patch output file. This could lead to serious naming rules problems.');
		
	// AWKCR? 
	fArmorKeywords := FileByName('ArmorKeywords.esm');
	if Assigned(fArmorKeywords) and not getSettingsBoolean('plugin.cpp_awkcr.active') then 
		ShowMessage('You are using AWKCR. It is highly recommended to activate the plugin "AWKCR Compatibility" for generation.');

	lstProblematic.Free;
end;


{Cleanup}
procedure _cleanup();
var 
	i: Integer;
begin
	// Clean up objects
	FreeAndNil(tagsIniFile);
	FreeAndNil(tagsIniFileUser);
	FreeAndNil(tagsIniFileData);

	// Clean up modules
	ComplexSorterGUI.cleanup();
	//RuleEditorGUI.cleanup();
	ProgressGUI.cleanup();
	EasyForm.cleanup();
	
	DynamicPatcher.cleanup();
	INNRProcessing.cleanup();
	ScriptConfiguration.cleanup();
	RecordLib.cleanup();
	CustomRuleSets.cleanup();
	FlagFunctions.cleanup();
	
	CSPluginSystem.cleanup();
	Cache.cleanup();
	Tasks.cleanup();
	PatchPlan.cleanup();
	
end;

end.