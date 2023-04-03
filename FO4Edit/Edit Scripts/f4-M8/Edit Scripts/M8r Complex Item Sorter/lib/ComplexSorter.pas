{
	M8r98a4f2s Complex Item Sorter for FallUI
		based on Ruddy88's VIS-G Auto Patcher
	FALLOUT 4
	
	A more complex automatic Item Sorting Script.
	Adds language indepence.
	Configuration files can be found in "..\F04Edit\Edit Scripts\M8r Complex Item Sorter" as ini files
	
	Requires: FO4Edit, Ruddy88's Simple Sorter, MXPF and FallUI.

	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
	
	Credits:
	 Rudy88 (Author of original script)
	 Neeanka (Author of DEF_INV)
	 Valdacil (Author of DEF_UI)
	 MatorTheEternal (Author of MXPF)
	 The full F04Edit team
	 Bethesda (Fallout 4)
	
	Hotkey: Ctrl+Y
}
{
Nice features to
* rule editor overhaul
* cache plugin output
* sub status bar
* text replacer

}
unit ComplexSorter;

// Imports
uses
	//IniFiles, // Automatically imported...
	'lib/mxpf',
	'M8r Complex Item Sorter/lib/helper',
	'M8r Complex Item Sorter/lib/ScriptConfiguration',
	'M8r Complex Item Sorter/lib/FlagFunctions',
	'M8r Complex Item Sorter/lib/DynamicPatcher',
	'M8r Complex Item Sorter/lib/INNRProcessing',
	'M8r Complex Item Sorter/lib/RecordLib',
	'M8r Complex Item Sorter/lib/CustomRuleSets',
	'M8r Complex Item Sorter/lib/CSPluginSystem',
	'M8r Complex Item Sorter/lib/Cache',
	'M8r Complex Item Sorter/lib/GUI/ProgressGUI',
	'M8r Complex Item Sorter/lib/GUI/ComplexSorterGUI',
	'M8r Complex Item Sorter/lib/GUI/RuleEditorGUI',
	'M8r Complex Item Sorter/lib/GUI/FormSimpleSelection',
	'M8r Complex Item Sorter/lib/GUI/CSPluginsGUI'
;



var
	r88SimpleSorterInnrEsp: IInterface;
	languageCode,  sFiles, sComplexSorterBasePath, languageFO4EditParam: String;
	tagsIniFile,tagsIniFileUser: TIniFile;
	// Global vars
	bReset, bAppendMode: Boolean;
	bUserRequestAbort, bStartCP, b_DevLessTodo, bCPAutoStartGen: Boolean;
	{iRatio: Integer;}
	tlPatched: THashedStringList;

	
{Main start routine}
procedure run();
var pattern,sStr:String;
	
begin
	// b_DevLessTodo := true;
	
	// _tests(); exit;
	try
	// bAppendMode := true;
	// Init
	ComplexSorterInit();
	
	// RuleEditorGUI.showRuleEditor('MAIN_RULES');exit;
	
	// Find general setup problems
	checkForGeneralSetupProblems();
	
	// Main GUI
	bStartCP := ComplexSorterGUI.ShowFormMainMenu();
		
	// Canceld?
	if not bStartCP then
		AddMessage('User cancelled patching: Operation cancelled. No patch generated')
	else begin
		
		// Save settings
		ScriptConfiguration.saveSettings();
		
		// Start main script
		ComplexSorterStart();
		
		end;
	
	finally
		cleanup();
	end;
end;

	
{Inits Complex Sorter}
procedure ComplexSorterInit();
var 
	i: Integer;
begin	
	// Find language parameter if exists
	languageFO4EditParam := '';
	bCPAutoStartGen := false;
	for i := 1 to ParamCount do 
		if Pos('-l:', ParamStr(i)) = 1 then
			languageFO4EditParam := Copy(ParamStr(i),4,100)
		else if Pos('-cpAutoStartGen', ParamStr(i)) = 1 then 
			bCPAutoStartGen := true;
	
	// Global settings
	sComplexSorterBasePath := ScriptsPath()+'M8r Complex Item Sorter\';
	bUserRequestAbort := false;
	languageCode := getFallout4LanguageCode();
	
	
	// Setting defaults
	scDefaults := THashedStringList.Create();
	scDefaults.values['config.bEspFilesAutoAll'] := True;
	scDefaults.values['config.bResetRecords'] := True;
	
	scDefaults.values['config.bTranslateINNR'] := languageCode <> 'en';
	scDefaults.values['config.bIncludeR88InnrRules'] := False;
	
	scDefaults.values['config.bProgressCloseOnFinished'] := True;
	
	scDefaults.values['config.bHeuristicAddTagsToWeaponsTemplates'] := True;
	scDefaults.values['config.bHeuristicAddTagsToWeapons'] := True;
	scDefaults.values['config.bHeuristicInjectRulesToWeaponsINNR'] := True;
	scDefaults.values['config.bHeuristicAddTagsToApparel'] := True;

	scDefaults.values['config.bUseCacheKeywords'] := True;
	scDefaults.values['config.bUseCachePluginScript'] := True;
	scDefaults.values['config.bUseCacheConditionCheck'] := False;
	scDefaults.values['config.bUseCacheProcSetResult'] := True;
	scDefaults.values['config.bGatherStatistics'] := False;
	
	// Call MXPF init functions and set MXPF prefs
	mxpf.InitializeMXPF;
	mxLoadMasterRecords := true;
	mxSkipPatchedRecords := true;
	mxLoadWinningOverrides := true;
	mxDebug := false;
	mxSaveDebug := false;
	mxSaveFailures := false;
	mxPrintFailures := false;
	tlPatched := THashedStringList.Create;
	
	// Read environment
	//fArmorKeywords := FileByName('ArmorKeywords.esm');
	r88SimpleSorterInnrEsp := FileByName('R88_SimpleSorter.esp');
	
	// Init Modules
	Cache.init();
	
	// Load settings
	tagsIniFile := TIniFile.Create(sComplexSorterBasePath+'Rules (Default)\tags.ini');
	tagsIniFileUser := TIniFile.Create(sComplexSorterBasePath+'Rules (User)\tags.ini');
	ScriptConfiguration.init(sComplexSorterBasePath+'Rules (User)\settings.ini', 'Settings');

	// Clean up settings and defaults
	if getSettingsString('config.sUseRecords', '') = '' then
		setSettingsString('config.sUseRecords', helper.getDefaultRecordsString());
		
	{if not hasSettingsBoolean('config.bAWKCR') then
		setSettingsBoolean('config.bAWKCR', Assigned(fArmorKeywords));}
		
	{if not Assigned(fArmorKeywords) then
		setSettingsBoolean('config.bAWKCR', false);}
		
	if getSettingsString('config.sTargetESPPatchFile','') <> '' then
		mxPatchFile := FileByName(getSettingsString('config.sTargetESPPatchFile',''));
		
	// Standard all files
	if getSettingsBoolean('config.bEspFilesAutoAll') or (getSettingsString('config.sUseESPFiles','') = '') then
		sFiles := ''+getAllEspFilesString()
	else
		sFiles := getSettingsString('config.sUseESPFiles','');

		
	// Load plugins
	CSPluginSystem.init();
	
end;

{Starts the main Complex Sorter Scripts}
procedure ComplexSorterStart();
var
	i,j: Integer;
	rec: IInterface;
	recordsToPatchLst,records: TStringList;
	kywdIndexReindex : Boolean;
begin

	try
	// Setup
	measureTimeStart(0);
	AddMessage('Patching process started. Initialize processing system...');
	measureTimeStart(1);

	globalModificationsAllowed := false;
	recordsToPatchLst := TStringList.Create;
	recordsToPatchLst.CommaText := getSettingsString('config.sUseRecords', '');
	
	// Initialize progress window
	ProgressGUI.init();
	
	ProgressGUI.addStep('gen_init','Initialize',0);
	ProgressGUI.addStep('loadruls','Loading rules',5);
	ProgressGUI.addStep('remXRecs','Remove existing records',7);
	ProgressGUI.addStep('loadRecs','Loading records',12);
	ProgressGUI.addStep('filtRecs','Prefilter records',15);
	ProgressGUI.addStep('copyRecs','Copying records',35);
	ProgressGUI.addStep('indxRecs','Indexing records',40);
	//ProgressGUI.addStep('ptchRecs','Patch xx record types',75);
	for i := 0 to recordsToPatchLst.Count -1 do
		if ( recordsToPatchLst[i] <> 'INNR' ) then
			ProgressGUI.addStep('ptch'+recordsToPatchLst[i],'Patch '+recordsToPatchLst[i],
				Round(45+50*( i/ recordsToPatchLst.Count ) ) );
	
	if recordsToPatchLst.indexOf('INNR') > -1 then 
		ProgressGUI.addStep('ptchINNR', 'Processing INNR records',95);
	ProgressGUI.addStep('gen_done','Done',100);
	ProgressGUI.draw();

	ProgressGUI.setCurrentStep('gen_init');

	AddMessage('Processing files: ' + sFiles);
	AddMessage('Processing record types: ' + getSettingsString('config.sUseRecords','Unknown'));
	
	// Read tags
	ScriptConfiguration.readTags();
		
	SetInclusions(sFiles);
	
	mxDisallowNewFile := true;
	if not Assigned(mxPatchFile) then
		PatchFileByAuthor('R88_SimpleSorter');
	mxDisallowNewFile := false;

	// Default filename
	if not Assigned(mxPatchFile) then begin
		mxPatchFile := AddNewFileName('M8r Complex Sorter.esp');
		SetAuthor(mxPatchFile, 'R88_SimpleSorter');
		end;
		
	if not Assigned(mxPatchFile) then begin
		AddMessage('No output file selected!');
		exit;
	end;
	AddMessage('Output file: ' + getFileName(mxPatchFile));
	
	pDR_gatherStats := getSettingsBoolean('config.bGatherStatistics');
	
	// Save valid settings
	setSettingsString('config.sTargetESPPatchFile',getFileName(mxPatchFile));
	setSettingsString('config.sUseESPFiles',sFiles);
	ScriptConfiguration.saveSettings();
		
	// Search custom ESP rules
	ProgressGUI.setCurrentStep('loadruls');
	CustomRuleSets.init();
	
	// Init modules
	DynamicPatcher.init();
	CSPluginScript.reinitCache();
		
	// Keywords cache
	kywdCache := TStringList.Create();
	kywdIndexReindex := not getSettingsBoolean('config.bUseCacheKeywords');
	if not kywdIndexReindex and getSettingsBoolean('config.bUseCacheKeywords') then try
		kywdCache.LoadFromFile(sComplexSorterBasePath+'cache\keywords.cache');
		// Validate 
		if kywdCache.Values['_VALIDATION'] = getLoadOrderFilesString() then
			AddMessage('(Loaded keywords cache. Entries: '+IntToStr(kywdCache.Count)+')')
		else
			kywdIndexReindex := true;			
	except
		kywdIndexReindex := true;
	end;
	if kywdIndexReindex then begin 
		kywdCache.Clear();
		kywdCache.Values['_VALIDATION'] := getLoadOrderFilesString();
		AddMessage('(Refresh keywords cache)');
		end;
	
	measureTimeDefaultAfter(1);
	
	// Nukes previous patch files if creating NEW PATCH.
	AddMessage('Remove existing records...');
	ProgressGUI.setCurrentStep('remXRecs');
	measureTimeStart(1);
	
	if bReset then
		for i := 0 to recordsToPatchLst.Count -1 do
			RemoveNode(GroupBySignature(mxPatchFile, recordsToPatchLst[i]));
	measureTimeDefaultAfter(1);
	
	// Load valid records.
	AddMessage('Loading records...');
	ProgressGUI.setCurrentStep('loadRecs');
	measureTimeStart(1);
	
	// Always needs keywords for matching
	if kywdIndexReindex then
		LoadRecords('KYWD');
		
	// Load other records
	for i := 0 to recordsToPatchLst.Count -1 do
		if ( recordsToPatchLst[i] <> 'COBJ' ) {or bAWKCR} then
			LoadRecords(recordsToPatchLst[i]);
	
	ProgressGUI.setStatistic('Records', IntToStr(MaxrecordIndex));
	// Abort?
	if bUserRequestAbort then Exit;

	
	// Loads COBJ and gets load order of ArmorKeywords.esm AEC workbench keywords.
	{if getSettingsBoolean('config.bAWKCR') then begin
		LoadRecords('COBJ');
		cArmoAEC := RecordByFormID(fArmorKeywords, (MasterCount(fArmorKeywords) * $01000000 + localFormID_ArmoAEC), false);
		cWeapAEC := RecordByFormID(fArmorKeywords, (MasterCount(fArmorKeywords) * $01000000 + localFormID_WeapAEC), false);
		cAmmoAEC := RecordByFormID(fArmorKeywords, (MasterCount(fArmorKeywords) * $01000000 + localFormID_AmmoAEC), false);
		cExplAEC := RecordByFormID(fArmorKeywords, (MasterCount(fArmorKeywords) * $01000000 + localFormID_ExplAEC), false);
		cOthrAEC := RecordByFormID(fArmorKeywords, (MasterCount(fArmorKeywords) * $01000000 + localFormID_OthrAEC), false);
		end;}
	
	AddMessage('    Records loaded: ' + IntToStr(MaxrecordIndex + 1) +'  in '+measureTimeGetFormatted(1));
	
	AddMessage('Pre-filtering records... ');
	ProgressGUI.setCurrentStep('filtRecs');
	measureTimeStart(1);
	i := MaxrecordIndex;
	filterRecords();
	if kywdIndexReindex then begin
		AddMessage('    Keywords loaded: '+IntToStr(kywdCache.Count));
		ProgressGUI.setStatistic('Keywords loaded', IntToStr(kywdCache.Count));
		end;
	AddMessage('    Records filtered: '+IntToStr(i-MaxrecordIndex)+'  in '+measureTimeGetFormatted(1));
	// Abort?
	if bUserRequestAbort then Exit;
	
	// Save keywords cache
	if kywdIndexReindex and getSettingsBoolean('config.bUseCacheKeywords') then
		kywdCache.SaveToFile(sComplexSorterBasePath+'cache\keywords.cache');
	
	// Nix übrig?
	if MaxrecordIndex = -1 then begin
		ShowMessage('There no records left after filtering!');
		Exit;
		end;
	
	// Copy remaining records to patch file.
	AddMessage('Copying '+IntToStr(MaxrecordIndex + 1)+' records to patch... - This process can take several minutes, please be patient');
	ProgressGUI.setCurrentStep('copyRecs');
	measureTimeStart(1);
	CopyRecordsToPatch;
	measureTimeDefaultAfter(1);
	globalModificationsAllowed := true;

	// Indexing
	AddMessage('Indexing records... ');
	ProgressGUI.setCurrentStep('indxRecs');
	measureTimeStart(1);
	indexRecords();
	measureTimeDefaultAfter(1);

	// Build translation index
	INNRProcessing.init();
	if getSettingsBoolean('config.bTranslateINNR') and (recordsIndex.indexOf('INNR')> -1) then begin
		measureTimeStart(1);
		INNRProcessing.buildTranslationIndex();
		measureTimeDefaultAfter(1);
		end;
	
	// Let the fun start
	AddMessage('Beginning patch file process... - Patching ' + IntToStr(MaxPatchRecordIndex + 1) + (' Records...'));
	// Abort?
	if bUserRequestAbort then Exit;
	//ProgressGUI.setCurrentStep('ptchRecs');
	
	// New dynamic processing rules
	for i := 0 to recordsToPatchLst.Count -1 do
		if ( recordsToPatchLst[i] <> 'INNR' ) then begin
			ProgressGUI.setCurrentStep('ptch'+recordsToPatchLst[i]);
			if ( recordsToPatchLst[i] = 'COBJ' ) then begin
				if recordsIndex.indexOf('COBJ') > -1 then begin
					records := recordsIndex.Objects[recordsIndex.indexOf('COBJ')];
					for j := records.Count-1 downto 0 do
						patchCOBJ(ObjectToElement(records[j]));
					end;
				end
			else
				DynamicPatcher.patchDynamicRules(recordsToPatchLst[i]);
			end;
		
	// Abort?
	if bUserRequestAbort then Exit;
	
	// Process INNR
	if (recordsIndex.indexOf('INNR')> -1) then begin
		ProgressGUI.setCurrentStep('ptchINNR');
		measureTimeStart(1);
		INNRProcessing.processINNR();
		measureTimeDefaultAfter(1);
		end;
	
	finally
		// a bit cleanup free mem
		AddMessage('Patching Process Complete. Records: '+ IntToStr(MaxPatchRecordIndex + 1)+'. Shut down processing system...');
		measureTimeStart(1);
		DynamicPatcher.cleanup();
		CustomRuleSets.cleanup();
		CSPluginSystem.cleanup();
		measureTimeDefaultAfter(1);
	
		AddMessage('Finalising Script. This process can take several minutes, please be patient');
		measureTimeStart(1);
		
		// Cleanup MXPF
		if Assigned(mxPatchFile) then
			CleanMasters(mxPatchFile);
		//PrintMXPFReport;
		FinalizeMXPF;
		measureTimeDefaultAfter(1);
		
		// Abort?
		if bUserRequestAbort then
			AddMessage('======= ABORTED ======')
		else
		AddMessage('======== DONE ========');
		AddMessage('Complex Sorter runtime: '+measureTimeGetFormatted(0)+'.');
		AddMessage('======================');
		
		ProgressGUI.setCurrentStep('gen_done');
		ProgressGUI.setFinished();
		FreeAndNil(recordsToPatchLst);
	end;

end;

{Checks some general problems with the load order etc.}
procedure checkForGeneralSetupProblems();
var
	i,patchOutputFileIndex,innrRulesFileIndex:Integer;
	f: IInterface;
	sFileName: String;
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
		else if (GetAuthor(f) = 'R88_SimpleSorter') then
			patchOutputFileIndex := i
		else if patchOutputFileIndex > -1 then
			lstProblematic.add(sFileName);
	end;
	if lstProblematic.Count > 0 then
		ShowMessage('WARNING: There are esp files after the patch output file. This could lead to wrong item naming.'+#13+#13
			+ 'Files found after patch files: '+lstProblematic.CommaText);
	if (innrRulesFileIndex > -1) and (patchOutputFileIndex > -1) and (innrRulesFileIndex > patchOutputFileIndex) then
		ShowMessage('WARNING: R88_SimpleSorter.esp is ordered after the patch output file. This could lead to serious naming rules problems.');
	lstProblematic.Free;
end;



{Just some testing stuff}
procedure _tests();
var
	i, index: Integer;
	tmpStr, tmpStr2,sStr1,sStr2,sStr3: String;
	match: Boolean;
	tmpLst: TStringList;
begin

	match := true;
	{	
	AddMessage('not "True"');
	measureTimeStart(2);
	for i := 0 to 100000 do
		if not 'True' then begin
			end;
	measureTimeDefaultAfter(2);

	AddMessage('not not "False"');
	measureTimeStart(2);
	for i := 0 to 100000 do
		if not not 'False' then begin
			end;
	measureTimeDefaultAfter(2);
		

	AddMessage('Bool("False")');
	measureTimeStart(2);
	for i := 0 to 100000 do
		if Bool('False') then begin
			end;
	measureTimeDefaultAfter(2);
		

	AddMessage('"False"<>"False"');
	measureTimeStart(2);
	for i := 0 to 100000 do
		if 'False' <> 'False' then begin
			end;
	measureTimeDefaultAfter(2);
		

	AddMessage('"False"="False"');
	measureTimeStart(2);
	for i := 0 to 100000 do
		if 'False' = 'False' then begin
			end;
	measureTimeDefaultAfter(2);
		
	AddMessage('"True" = "False"');
	match := true;
	measureTimeStart(2);
	for i := 0 to 100000 do
		if match = 'False' then begin
			end;
	measureTimeDefaultAfter(2);
		

			Exit;
		
	measureTimeStart(2);
	for i := 0 to 100000 do begin
		tmpLst.add(match);
		if tmpLst[0] = 'True' then begin
			end;
		end;
	measureTimeDefaultAfter(2);

	measureTimeStart(2);
	
	for i := 0 to 100000 do begin
		if match then 
			tmpLst.add('T')
		else 
			tmpLst.add('F');
		if tmpLst[0] then begin
			end;
		end;
	measureTimeDefaultAfter(2);

	Exit;
	}
	// AddMessage('TEST: emptyproc call with begin end'); // 0.12
	// AddMessage('TEST: emptyproc call no begin end'); // 0.1
	{AddMessage('TEST control structure 1 IF ELSE ELSE with String '); // 0.6
	AddMessage('TEST control structure 1 IF ELSE ELSE with Int '); // 0.6
	AddMessage('TEST control structure 1 IF ELSE ELSE+ outer if'); // 0.5
	AddMessage('TEST control structure 1 IF ELSE ELSE + pre if exit '); // 0.2
	AddMessage('TEST control structure 1 IF ELSE ELSE+OUTER-subcall no match'); // 0.2
	AddMessage('TEST control structure 1 IF ELSE ELSE NO PROCEDURE'); // 0.4
	AddMessage('TEST control structure 1 IF ELSE ELSE+OUTER-subcall with match'); // 0.8
	AddMessage('TEST control structure 2 CASE instead if else '); // 0.4}

	{AddMessage('TEST: String stored as a,b,c extraced by Split() + assign + free'); // 1.4
	AddMessage('TEST: String stored as a,b,c extraced by strict DelimitedTextUsage + assign + free'); // 1.0
	AddMessage('TEST: String stored as a,b,c extraced by CommaText + assign + free'); // 0.6 (clear winner)
	AddMessage('TEST: String stored as a,b,c extraced by SplitSimple() + assign'); // 2.7}

	// Performance tests
	{Pos('"', 'Dies ist ein Testsatz der ein " enthält. und? '); // 1.0
	Pos('"', '"Dies ist ein Testsatz der zwei " enthält. und? '); // 1.0
	PosOwn('"', '"Dies ist ein Testsatz der zwei " enthält. und? '); // 2.8
	Copy('"Dies ist ein Testsatz der zwei " enthält. und? ',1,1); // 1.1
	BeginsWithExtract('"','Dies ist ein Testsatz der ein " enthält. und? ',tmpStr); // 4.7
	Pos('"', 'Dies ist ein Testsatz der kein ... enthält. und? '); 1.0

	match := Pos('"', '"Dies ist ein Testsatz der zwei " enthält. und? ') = 1; // 1.3
	match := LeftStr('"Dies ist ein Testsatz der zwei " enthält. und? ',1) = '"'; // 1.4
	match := Pos('"Dies ist ein', '"Dies ist ein Testsatz der zwei " enthält. und? ') = 1; // 1.3
	match := LeftStr('"Dies ist ein Testsatz der zwei " enthält. und? ',13) = '"Dies ist ein'; // 1.4

		
	match := ('TEST' = 'TEST');  // 0.6
	match := ('TEST' = tmpStr);  // 0.6
	Pos('TEST',tmpStr);  // 1.0}
	
end;


{Cleanup}
procedure cleanup();
begin
	// AddMessage('Start cleanup');
	// Clean up objects
	if Assigned(tagsIniFile) then FreeAndNil(tagsIniFile);
	if Assigned(tagsIniFileUser) then FreeAndNil(tagsIniFileUser);
	if Assigned(tlPatched) then FreeAndNil(tlPatched);
	
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
	
	CSPluginSystem.cleanup();
	Cache.cleanup();
end;

end.