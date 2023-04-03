{
	M8r98a4f2s Complex Item Sorter for FallUI - ComplexSorterGUI module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. All parts of the GUI.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit ComplexSorterGUI;

uses
	 'M8r Complex Item Sorter/lib/AutoForm',
	 'M8r Complex Item Sorter/lib/EasyForm';

var
	tLabelTagSet, tLabelESPFiles,tLabelESPFileCount,tLabelUseRecords,tLabelUseRecordCount, tLabelTargetFile: TLabel;
	btnCancel: TButton;
	_winPromptFrm: TForm;
	_winPromptInput: TEdit;
	

implementation

{ Translation function }
function _(identifier: String): String;
var
	ini: TIniFile;
	filename: String;
	identifierClean: String;
begin
	//if ( languageCode = 'en' ) then begin
	// No real interest in translations ... so dropped.
	Result := identifier;
	exit;
	//end;
	{filename := sComplexSorterBasePath+'lang-'+languageCode+'.ini';
	ini := TIniFile.Create(filename);
	try
		// Mask identifier
		identifierClean := StringReplace(identifier, '=', '_MASKED_%EQUALS$_', [rfReplaceAll]);
		Result := ini.ReadString('Translation', identifierClean, 'MISSING');
		if ( Result = 'MISSING' ) then begin
			Result := identifier;
			ini.WriteString('Translation', identifierClean, identifier);
		end;
	finally
		ini.Free;
	end}
end;

// Sets layout for Main Options Form
function ShowFormMainMenu():Boolean;
const
	heightPerLine = 25;
	groupStdWidth = 330;
	groupSpacingBetween = 20;
	windowPadding = 25;
var
	frm: TForm;
	tLabel: TLabel;
	{cbAWKCR, }tmpCheckbox: TCheckBox;
	tmpButton: TButton;
	tmpGroup: TGroup;
	i, j: integer;
	tmpStr: String;
	plugin: TStringList;
	mxFile: IInterface;
	fImage: TImage;
	logoPicture: TPicture;
begin
	{plugin := TStringList.Create;
	plugin.Add('Shish');
	plugin.Add('Ranged');
	readTags(); 
	if FormSimpleSelection.showCheckboxes('test','test2',tagNames,plugin) then 
		d('ok');
	d(plugin.CommaText);
	plugin.Free;
	Exit;{}
	// readTags();	d(FormSimpleSelection.show('test','test',tagNames,''));	Exit;{}
	// _ShowFormRecordTypeSelection; Exit;

	 // RuleEditorGUI.showRuleEditor('');Exit;
	frm := TForm.Create(nil);
	try
	//frm.OnKeyPress := eventKeyPress;
	frm.Caption := 'M8r Complex Item Sorter';
	frm.Width := windowPadding*2+(groupStdWidth+groupSpacingBetween)*2-groupSpacingBetween;
	
	AutoForm_setForm(frm);
	AutoForm_SetAutoPos(windowPadding, windowPadding);
	optionGroupWidth := groupStdWidth;
	optionGroupPadding := 15;
	
	{tLabel := AutoForm_AddLabel('M8r Complex Item Sorter',20);
	tLabel.Font.Size := 10;
	tLabel.Font.Style := [fsBold];}
	
	logoPicture := TPicture.Create;
	logoPicture.LoadFromFile(sComplexSorterBasePath+'images\logo.png');
	
	fImage := TImage.Create(frm);
	fImage.Picture := logoPicture;
	
	fImage.Parent := frm;
	fImage.Left := 15;
	fImage.Top := 20;
	fImage.Width := frm.Width;
	fImage.Height := fImage.Height;
	
	AutoForm_SetAutoPos(120, nil);

	// Section: INPUT
	AutoForm_BeginGroup('Input ESPs');

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bEspFilesAutoAll',_('Select all ESP files on restart'),true);

	// ESP
	tLabelESPFileCount := AutoForm_AddLabel('{...}', 20);
	tLabelESPFiles := AutoForm_AddLabel('{...}', 20+pluginRegistry.Count*25+8);
	tLabelESPFiles.Font.Size := 6;
	tLabelESPFiles.Font.Style := [fsBold];
	AutoForm_AddLink(tLabelESPFileCount,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD).OnClick := _ShowFormEspFilesSelection;
	
	AutoForm_EndGroup();
	
	// Tags for scan
	AutoForm_BeginGroup('Record types');
	
	tLabelUseRecordCount := AutoForm_AddLabel('{...}', 20);
	tLabelUseRecords := AutoForm_AddLabel('{...}', 36);
	tLabelUseRecords.Width := 320;
	tLabelUseRecords.Font.Style := [fsBold];
	AutoForm_AddLink(tLabelUseRecordCount,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD).OnClick := _ShowFormRecordTypeSelection;

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bResetRecords',_('Purge existing records before start'),true);
	tmpCheckbox.Width := 320;

	AutoForm_EndGroup();

	// Section: Processing
	AutoForm_SetAutoPos(120, windowPadding+(groupStdWidth+groupSpacingBetween)*1);

	AutoForm_BeginGroup('Processing rules');

	AutoForm_SaveAutoPos();
	{AutoForm_AddLink(nil,'View default rules', 0).onClick := _buttonEditRulesMainDefault;
	AutoForm_AddLink(nil,'View mod rules', 0).onClick := _buttonEditRulesModsMain;
	AutoForm_SetAutoPos(-1,AutoForm_GetAutoLeft()+140);
	AutoForm_AddLink(nil,'Edit USER''s rules', AF_OPT_BOLD).onClick := _buttonEditRulesMainUser;
	AutoForm_AddLink(nil,'Edit USER''s mod rules', AF_OPT_BOLD).onClick := _buttonEditRulesModsUser;}
	AutoForm_AddLink(nil,'Open Processing Rules Editor', AF_OPT_BOLD).onClick := _buttonEditRulesGUI;
	AutoForm_AddLink(nil,'Open/Add rules for mod', AF_OPT_BOLD).onClick := _buttonEditRulesGUIMod;
	AutoForm_SetAutoPos(nil,-1);
	
	AutoForm_EndGroup();

	tmpGroup := AutoForm_BeginGroup('Plugins');
	
	for i := 0 to pluginRegistry.Count -1 do begin
		plugin := CSPluginSystem.getPluginObj(pluginRegistry[i]);
		tmpCheckbox := AutoForm_AddCheckboxAutoOption('plugin.'+plugin.values['id']+'.active',plugin.values['name'],
			plugin.values['activeDefault'] = 'true');
		tmpCheckbox.Width := tmpCheckbox.Width - 65;
		
		tLabel := AutoForm_AddLink(tmpCheckbox,'Configure', AF_OPT_BOLD);
		tLabel.HelpKeyword := plugin.values['id'];
		tLabel.onClick := _buttonConfigurePlugin;
		
		end;
	
	AutoForm_EndGroup();

	// Section: Output
	AutoForm_BeginGroup('Output ESP');

	tLabelTargetFile := AutoForm_AddLabel('{...}',20);
	tLabelTargetFile.Font.Style := [fsBold];
	tLabelTargetFile.WordWrap := false;

	mxFile := FileByAuthor('R88_SimpleSorter');
	if Assigned(mxFile) then begin
		tLabel := AutoForm_AddLink(tLabelTargetFile,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
		tLabel.OnClick := _ShowFormTargetESPSelection;
		end;
	tLabelTargetFile.Width := 230;

	tLabel := AutoForm_AddLink(nil,#9734+' New ESP', 0);
	tLabel.Alignment := taRightJustify;
	tLabel.Top := tLabelTargetFile.Top+24;
	tLabel.Left := tLabel.Left-16;
	tLabel.OnClick := _ShowFormAddNewTargetPatchFile;
		
	AutoForm_EndGroup();
	
	// Finalize form
	frm.Height := AutoForm_getAutoTop() + 100;

	tmpButton := AutoForm_AddButtonBottom(mrYes,#10003+' '+_('Generate Patch'));
	tmpButton.TabOrder := 0;
	tmpButton.Width := 180;
	
	tmpButton := AutoForm_AddButtonBottom(nil, #9776+' '+_('Advanced Options'));
	tmpButton.TabOrder := 2;
	tmpButton.OnClick := _buttonShowAdvOptions;
	tmpButton.Width := 180;
	
	btnCancel := AutoForm_AddButtonBottom(mrCancel, #9747+' '+_('Cancel'));
	btnCancel.TabOrder := 1;
	btnCancel.Cancel := true;
	
	btnCancel.Width := 180;
	
	AutoForm_ArrangeButtonBottom();
	// Update values
	updateMainGUI();
	
	if bCPAutoStartGen then 
		i := mrYes
	else 
		i := frm.ShowModal;	

	if (i = mrYes) and ( Pos('INNR',getSettingsString('config.sUseRecords', '')) <> 0 )
		and not Assigned(r88SimpleSorterInnrEsp) then
		if not WindowConfirm('No R88_SimpleSorter.esp', 
			'You have selected INNR processing, but R88_SimpleSorter.esp is not available.'+#10#13+'Continue anyway?') then
			i := mrCancel;
		
	Result := i = mrYes; // mrCancel = 2, mrYes = 6;
		
	if i <> mrCancel then begin
		// setSettingsBoolean('config.bAWKCR',cbAWKCR.Checked);

		// Update plugins active status
		for j := 0 to pluginRegistry.Count -1 do begin
			plugin := CSPluginSystem.getPluginObj(pluginRegistry[j]);
			if getSettingsBoolean('plugin.'+plugin.values['id']+'.active') then
				plugin.values['active'] := 'true'
			else
				plugin.values['active'] := 'false';
		end;
		
		bReset := getSettingsBoolean('config.bResetRecords');
				
	end;
	finally
		frm.Free;
	end;
end;

procedure _showFormAddNewTargetPatchFile();
var prevMXFile:IInterface;
begin
	prevMXFile := mxPatchFile;
	mxPatchFile := AddNewFile;
	if Assigned(mxPatchFile) then
		SetAuthor(mxPatchFile, 'R88_SimpleSorter')
	else mxPatchFile := prevMXFile;
	updateMainGUI();
end;



{Updates dynamic entries in options GUI}
procedure updateAdvOptionsGUI();
begin
			
	// Tag set
	tLabelTagSet.Text := getSettingsString('config.sUseTagSet', 'FallUI');

end;

{Updates dynamic entries in main GUI}
procedure updateMainGUI();
var
	mxFile: IInterface;
	tmpLst1, tmpLst2: TStringList;
begin
	// ESP files
	tLabelESPFiles.Text := pregReplace(',',', ',sFiles);
	tmpLst1 := Split(',',sFiles);
	tmpLst2 := Split(',',getAllEspFilesString());
	tLabelESPFileCount.Text := 'Selected: '+ IntToStr(tmpLst1.Count) + ' / '+	IntToStr(tmpLst2.Count) +'';
	tmpLst1.Free;
	tmpLst2.Free;
	
	// Records
	tmpLst1 := Split(',',getSettingsString('config.sUseRecords', ''));
	tmpLst2 := Split(',',getAllRecordsString());
	tLabelUseRecordCount.Text := _('Selected: ') + ' '+ IntToStr(tmpLst1.Count) + ' / '+	IntToStr(tmpLst2.Count)+'';
	tLabelUseRecords.Text := pregReplace(',',', ',getSettingsString('config.sUseRecords', ''));
	tmpLst1.Free;
	tmpLst2.Free;

	// Output file
	mxFile := FileByAuthor('R88_SimpleSorter');
	if Assigned(mxPatchFile) then
		tLabelTargetFile.Text := GetFileName(mxPatchFile)
	else if Assigned(mxFile) then
		tLabelTargetFile.Text := GetFileName(mxFile)
	else
		tLabelTargetFile.Text := 'M8r Complex Sorter.esp';
			
	// Tag set
	//tLabelTagSet.Text := getSettingsString('config.sUseTagSet', 'FallUI');
	
	// Checkboxes
	AutoForm_UpdateCheckboxesAutoOption();
end;

procedure _buttonEditTags();
begin
	startEditor(sComplexSorterBasePath+'Rules (Default)\tags.ini');
end;

procedure _buttonEditRulesINNR();
begin
	startEditor(getDynamicNamingRulesIniPath());
end;

procedure _buttonEditRulesGUI();
begin
	RuleEditorGUI.showRuleEditor('');
	// RULESETS_IDENTIFIER_MAIN_RULES+'>WEAP'
end;

procedure _buttonEditRulesGUIMod();
var tmpLst, tmpLst2, tmpLst3: TStringList;
	j,retVal:Integer;
	tmpStr: String;
begin
		// Custom mod rules selection
	tmpLst := TStringList.Create;
	tmpLst2 := TStringList.Create;
	tmpLst3 := TStringList.Create;
	tmpLst2.CommaText := sFiles;
	for j := 0 to tmpLst2.Count -1 do
		if FileExists(sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst2[j])+'.ini') then begin
			tmpLst3.add(getBaseESPName(tmpLst2[j]));
			tmpLst.add(getBaseESPName(tmpLst2[j]));
			end;
	for j := 0 to tmpLst2.Count -1 do
		if not FileExists(sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst2[j])+'.ini')
			and not (tmpLst2[j] = 'Fallout4.esm')
			and not (tmpLst2[j] = 'DLCCoast.esm')
			and not (tmpLst2[j] = 'DLCworkshop01.esm')
			and not (tmpLst2[j] = 'DLCworkshop02.esm')
			and not (tmpLst2[j] = 'DLCworkshop03.esm')
			and not (tmpLst2[j] = 'DLCNukaWorld.esm')
			and not (tmpLst2[j] = 'DLCRobot.esm')
			then begin
			tmpLst3.add(getBaseESPName(tmpLst2[j]));
			tmpLst.add('[New] ' + getBaseESPName(tmpLst2[j]));
			end;
	tmpLst2.Free;
	if tmpLst.Count = 0 then
		ShowMessage('No custom rules for your current ESP files selection.')
	else begin
		retVal := FormSimpleSelection.show('Select mod','',tmpLst,'');
		if retVal > -1 then begin
			tmpStr := sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst3[retVal])+'.ini';
			if not FileExists(tmpStr) then
				CopyFile(sComplexSorterBasePath+'Rules (User)\.dummy.custom-mod.ini', tmpStr,false);
			// startEditor(tmpStr);
			RuleEditorGUI.showRuleEditor(RULESETS_IDENTIFIER_USER_MOD_RULES+getBaseESPName(tmpLst3[retVal])+'>'+'');
			end;
		end;
	tmpLst.Free;
	tmpLst3.Free;
	
	// +'>WEAP'
end;

procedure _buttonEditRulesMainDefault();
begin
	startEditor(sComplexSorterBasePath+'Rules (Default)\rules-processing.ini');
end;

procedure _buttonEditRulesMainUser();
var tmpStr: String;
begin
	tmpStr := sComplexSorterBasePath+'Rules (User)\rules-processing.ini';
	if not FileExists(tmpStr) then
		if WindowConfirm('Create new file', 'There is currently no user rules-processing.ini. Create a new file?') then
			CopyFile(sComplexSorterBasePath+'Rules (User)\.dummy.rules-processing.ini', tmpStr,false);
	if FileExists(tmpStr) then
		startEditor(tmpStr);
end;

procedure _buttonEditRulesModsMain();
var tmpLst, tmpLst2, tmpLst3: TStringList;
	j,retVal:Integer;
begin
	// Custom mod rules selection
	tmpLst := TStringList.Create;
	tmpLst2 := TStringList.Create;
	tmpLst2.CommaText := sFiles;
	for j := 0 to tmpLst2.Count -1 do begin
		if FileExists(sComplexSorterBasePath+'Rules (Mods)\'+getBaseESPName(tmpLst2[j])+'.ini') then
			tmpLst.add(getBaseESPName(tmpLst2[j]));
		end;
	tmpLst2.Free;
	if tmpLst.Count = 0 then
		ShowMessage('No custom rules for your current ESP files selection.')
	else begin
		
		retVal := FormSimpleSelection.show('Select mod','',tmpLst,'');
		
		if retVal > -1 then
			//AddMessage('Selected:' +IntToStr(retVal));
			startEditor(sComplexSorterBasePath+'Rules (Mods)\'+getBaseESPName(tmpLst[retVal])+'.ini');
		end;
	tmpLst.Free;
end;

procedure _buttonEditRulesModsUser();
var tmpLst, tmpLst2, tmpLst3: TStringList;
	j,retVal:Integer;
	tmpStr: String;
begin
		// Custom mod rules selection
	tmpLst := TStringList.Create;
	tmpLst2 := TStringList.Create;
	tmpLst3 := TStringList.Create;
	tmpLst2.CommaText := sFiles;
	for j := 0 to tmpLst2.Count -1 do
		if FileExists(sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst2[j])+'.ini') then begin
			tmpLst3.add(getBaseESPName(tmpLst2[j]));
			tmpLst.add(getBaseESPName(tmpLst2[j]));
			end;
	for j := 0 to tmpLst2.Count -1 do
		if not FileExists(sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst2[j])+'.ini')
			and not (tmpLst2[j] = 'Fallout4.esm')
			and not (tmpLst2[j] = 'DLCCoast.esm')
			and not (tmpLst2[j] = 'DLCworkshop01.esm')
			and not (tmpLst2[j] = 'DLCworkshop02.esm')
			and not (tmpLst2[j] = 'DLCworkshop03.esm')
			and not (tmpLst2[j] = 'DLCNukaWorld.esm')
			and not (tmpLst2[j] = 'DLCRobot.esm')
			then begin
			tmpLst3.add(getBaseESPName(tmpLst2[j]));
			tmpLst.add('[Create rules for] ' + getBaseESPName(tmpLst2[j]));
			end;
	tmpLst2.Free;
	if tmpLst.Count = 0 then
		ShowMessage('No custom rules for your current ESP files selection.')
	else begin
		retVal := FormSimpleSelection.show('Select mod','',tmpLst,'');
		if retVal > -1 then begin
			tmpStr := sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst3[retVal])+'.ini';
			//AddMessage('Selected:' +IntToStr(retVal));
			CopyFile(sComplexSorterBasePath+'Rules (User)\.dummy.custom-mod.ini', tmpStr,false);
			startEditor(tmpStr);
			end;
		end;
	tmpLst.Free;
	tmpLst3.Free;
end;


procedure _buttonEditTagsUser();
var tmpStr: String;
begin
	tmpStr := sComplexSorterBasePath+'Rules (User)\tags.ini';
	if not FileExists(tmpStr) then begin
		if WindowConfirm('Create new file', 'There is currently no user tags.ini. Create a new file?') then
			CopyFile(sComplexSorterBasePath+'Rules (User)\.dummy.tags.ini', tmpStr,false);
		end;
	if FileExists(tmpStr) then
		startEditor(tmpStr);
end;

{Event: Show adv. options}
procedure _buttonShowAdvOptions();
begin
	_ShowFormAdvancedOptions();
end;


procedure _ShowFormAdvancedOptions();
const
	heightPerLine = 25;
	groupStdWidth = 330;
	groupSpacingBetween = 20;
	windowPadding = 25;
var
	frm: TForm;
	tLabel: TLabel;
	tmpCheckbox: TCheckBox;
	tmpButton: TButton;
	tmpGroup: TGroup;
	fEditExtEditor: TEdit;
	i, j, maxHeight: integer;
	tmpStr: String;
begin
	frm := TForm.Create(nil);
	try
	maxHeight := 0;
	//frm.OnKeyPress := eventKeyPress;
	frm.Caption := 'Advanced Options';
	frm.Width := windowPadding*2+(groupStdWidth+groupSpacingBetween)*2-groupSpacingBetween;
	
	AutoForm_setForm(frm);
	AutoForm_SetAutoPos(windowPadding, windowPadding);
	optionGroupWidth := groupStdWidth;
	optionGroupPadding := 15;
		
	AutoForm_SetAutoPos(100, nil);
	
	// Section: Processing
	AutoForm_SetAutoPos(windowPadding, windowPadding+(groupStdWidth+groupSpacingBetween)*0);

	AutoForm_BeginGroup('Tag set');

	tLabelTagSet:= AutoForm_AddLabel('{...}',20);
	tLabelTagSet.Font.Style := [fsBold];
	
	tLabel := AutoForm_AddLink(tLabelTagSet,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
	tLabel.onClick := _ShowFormTagSetSelection;
	// tLabel.Width := groupStdWidth;

	AutoForm_EndGroup();
	
	AutoForm_BeginGroup('TagIdent mapping');
	
	AutoForm_SaveAutoPos();
	AutoForm_AddLink(nil,'View default tags', 0).onClick := _buttonEditTags;
	AutoForm_SetAutoPos(-1,AutoForm_GetAutoLeft()+140);
	AutoForm_AddLink(nil,'Edit USER''s tags', AF_OPT_BOLD).onClick := _buttonEditTagsUser;
	AutoForm_SetAutoPos(nil,-1);
	
	AutoForm_EndGroup();
	
	

	AutoForm_BeginGroup('Advanced');
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bTranslateINNR',_('Translate R88_SimpleSorter.esp INNR'),true);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Try to translate all INNR-Tags to your current language.');
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bIncludeR88InnrRules',_('Include all R88 INNR records'),true);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Includes all INNR rules from R88 INNR esp, so the resulting esp is complete and independent from R88_SimpleSorter.esp');
	
	if not Assigned(r88SimpleSorterInnrEsp) then
		AutoForm_AddLabel('Warning: No R88 INNR Tag ESP found!',15);

	AutoForm_EndGroup();

	
	tmpGroup := AutoForm_BeginGroup('Miscellaneous');

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseDarkTheme',_('Dark theme active'),true);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Uses colors suitable for dark color theme. Use this if you use the dark theme from FO4Edit.');
	
	AutoForm_AddLabel('External editor',15);
	fEditExtEditor := ConstructEdit(frm, tmpGroup, AutoForm_GetAutoTop, AutoForm_GetAutoLeft, 15
			, groupStdWidth - 20*2, getSettingsString('config.externalEditorPath','Notepad'), 'Configures the external editor for opening ini and configuration files.');
	AutoForm_AddAutoTop(fEditExtEditor.Height+10);


	AutoForm_EndGroup();
	
	maxHeight := Max(maxHeight, AutoForm_GetAutoTop);
	// COLUMN 2 
	AutoForm_SetAutoPos(windowPadding, windowPadding+(groupStdWidth+groupSpacingBetween)*1);

	
	AutoForm_BeginGroup('INNR and heuristic');

	//AutoForm_AddButton(AutoForm_GetAutoTop(), AutoForm_GetAutoLeft(),30,nil,nil,#9636+' '+_('Edit dynamic naming rules'))
	//	.OnClick := _buttonEditRulesINNR;
	tLabel := AutoForm_AddLink(nil,'Edit dynamic naming rules', 0);
	tLabel.OnClick := _buttonEditRulesINNR;
	tLabel.Width := 280;

	AutoForm_AddAutoTop(10);
	AutoForm_AddCheckboxAutoOption('config.bHeuristicInjectRulesToWeaponsINNR',_('Inject naming rules to weapons INRD>INNR'),true);
	AutoForm_AddCheckboxAutoOption('config.bHeuristicAddTagsToWeapons',_('Apply heuristic tags to weapons without INRD'),true);
	AutoForm_AddCheckboxAutoOption('config.bHeuristicAddTagsToWeaponsTemplates',_('Apply heuristic tags to unique weapon templates'),true);
	AutoForm_AddCheckboxAutoOption('config.bHeuristicAddTagsToApparel',_('Apply heuristic tags to apparel'),true);
	
	AutoForm_EndGroup();
	
	
	AutoForm_BeginGroup('Performance');

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCacheKeywords',_('Keywords cache'),false);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Caches keyword FormID''s. '+#10#13+'Must be manually purged if you use custom mod keywords and change their position in load order.';
	tLabel := AutoForm_AddLink(tmpCheckbox,'Clear all caches', 0);
	tLabel.OnClick := _buttonClearAllCaches;

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCacheProcSetResult',_('Proccessing rules cache'),true);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Caches the result of rules for records. '+#10#13+'Integrated validation system for changed records.';

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCacheConditionCheck',_('Condition check cache (Read hint)'),false);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Caches condition checks for records. '+#10#13+'Integrated validation system for changed records.'
		+ #10#13 +'Only useful if you change rules very often. Slower if rules are mostly unchanged.';
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCachePluginScript','Plugin cache',true);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Caches plugin script results.'+#10#13+'Uses invalidation system for detecting changes to plugin or plugin settings.');
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bGatherStatistics',_('Gather statistics'),false);
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Lowers the performance. Needs ruleset cache inactive.';
	
	AutoForm_EndGroup();

	
	maxHeight := Max(maxHeight, AutoForm_GetAutoTop);
	// COLUMN 3 
	//AutoForm_SetAutoPos(windowPadding, windowPadding+(groupStdWidth+groupSpacingBetween)*2);
	
	maxHeight := Max(maxHeight, AutoForm_GetAutoTop);

	// Finalize form
	frm.Height := maxHeight + 100;
	
	tmpButton := AutoForm_AddButtonBottom(mrYes,#10003+' '+_('Ok'));
	tmpButton.TabOrder := 0;
	tmpButton.Width := 140;
	
	{tmpButton := AutoForm_AddButtonBottom(mrCancel, #9747+' '+_('Cancel'));
	tmpButton.TabOrder := 1;
	tmpButton.Cancel := true;
	tmpButton.Width := 140;}
	
	AutoForm_ArrangeButtonBottom();
	
	// For Cancel by esc 
	{tmpButton := TButton.Create(frm);
	tmpButton.ModalResult := mrCancel;}
	tmpButton.Cancel := true;
	{tmpButton.Top := -50;}
	
	updateAdvOptionsGUI();
	
	i := frm.ShowModal;
	// mrCancel = 2, mrYes = 6;
	
	// Save non auto fields 
	setSettingsString('config.externalEditorPath',fEditExtEditor.Text);
	
	updateMainGUI();
	finally
		AutoForm_endForm();
		frm.Free;
	end;
end;



{Event: Clear all caches}
procedure _buttonClearAllCaches();
var tmpStr:String;
begin
	tmpStr := sComplexSorterBasePath+'cache\conditionCheckCache.cache';
	if FileExists(tmpStr) then
		DeleteFile(tmpStr);
	tmpStr := sComplexSorterBasePath+'cache\dynamicPatcherRuleSetResults.cache';
	if FileExists(tmpStr) then
		DeleteFile(tmpStr);
	tmpStr := sComplexSorterBasePath+'cache\pluginScriptsResult.cache';
	if FileExists(tmpStr) then
		DeleteFile(tmpStr);
	tmpStr := sComplexSorterBasePath+'cache\keywords.cache';
	if FileExists(tmpStr) then
		DeleteFile(tmpStr);
	ShowMessage('All caches cleared.');
end;


{Open plugins configuration form}
procedure _buttonConfigurePlugin(Sender:TObject);
begin
	// AutoForm_SaveAutoOptions;
	CSPluginsGUI.ShowPluginOptions(Sender.HelpKeyword);
end;

	

{Starts the external text editor for a file}
procedure startEditor(path:String);
var 
	seResult:Integer;
begin
	try
		seResult := ShellExecute(0, Nil, getSettingsString('config.externalEditorPath','Notepad'), '"'+path+'"', '', SW_SHOWNORMAL);
		if  seResult = 2 then 
			ShowMessage('Executable couldn''t found:'+#10#13+getSettingsString('config.externalEditorPath','Notepad'));
	except
		on E: Exception do
		ShowMessage('Error: '+E.Message);
	end;
end;


function _ShowFormRecordTypeSelection(): Boolean;
var
	{frm: TForm;
	cbArray: Array[0..4351] of TCheckBox;
	sb: TScrollBox;
	i: Integer;
	modalResult : Integer;}
	lstAll, lstChecked, lstDescriptions: TStringList;
begin
	
	// Using new Checkboxes form	
	lstAll := TStringList.Create;
	lstAll.CommaText := getAllRecordsString();
	lstAll.Sort;
	lstChecked := TStringList.Create;
	lstChecked.CommaText := getSettingsString('config.sUseRecords', '');
	lstDescriptions := getRecordsDescriptions();
	
	if FormSimpleSelection.showCheckboxes(_('Record types'),_('Select record types to be processed'), lstAll, lstChecked, lstDescriptions) then begin
		Result := true;
		if (lstChecked.indexOf('INNR') = -1 ) and ( (lstChecked.indexOf('WEAP') > -1 ) or (lstChecked.indexOf('ARMO') > -1 ) ) then
				ShowMessage('Warning: Processing of WEAP and ARMO without INNR rules is not recommended and may lead to strange results.');
		setSettingsString('config.sUseRecords', lstChecked.CommaText);
		updateMainGUI();
		end;
	// Cleanup
	lstAll.Free;
	lstChecked.Free;
	lstDescriptions.Free;
	{Exit;
	
	
	frm := TForm.Create(nil);
	
	try
		AutoForm_setForm(frm);
		AutoForm_SetAutoPos(10, 20);
		frm.Width := 280;
		frm.Caption := _('Record types');
		sb := AutoForm_SetupScrollBox();
		
		// Title
		AutoForm_AddLabel(_('Select record types to be handled'),20).Font.Style := [fsBold];
		AutoForm_SetAutoPos(AutoForm_getAutoTop()+10, nil);
		
		// Lists
		lstAll := TStringList.Create;
		lstAll.CommaText := getAllRecordsString();
		lstAll.Sort;
		lstChecked := TStringList.Create;
		lstChecked.CommaText := getSettingsString('config.sUseRecords', '');
		lstDescriptions := getRecordsDescriptions();

		// All / None
		AutoForm_AddButton(AutoForm_getAutoTop(),20,30,100, 111,_('All'));
		AutoForm_AddButton(AutoForm_getAutoTop(),140,30,100, 112,_('None'));
		
		AutoForm_SetAutoPos(AutoForm_getAutoTop()+60,nil);
		
		// Checkboxes
		for i := 0 to lstAll.Count -1 do begin
			AutoForm_SaveAutoPos();
			cbArray[i] := AutoForm_AddCheckbox(lstAll[i], lstChecked.indexOf(lstAll[i]) > -1,'');
			if (lstDescriptions.values[lstAll[i]] <> '') then begin
				AutoForm_SetAutoPos(-1,100);
				AutoForm_AddLabel(lstDescriptions.values[lstAll[i]],30);
				AutoForm_SetAutoPos(nil,20);
			end;
			 
		end;
		
		// Buttons
		_ShowFormModConstructModalButtons(frm, sb, AutoForm_getAutoTop()+20);
		
		frm.Height := AutoForm_getAutoTop() + 120;
		
		lstChecked.Clear;
		modalResult := -1;
		while (modalResult <> mrOk) and (modalResult <> mrCancel) do begin
			modalResult := frm.ShowModal();
			if (modalResult = 111) or (modalResult = 112) then begin
				for i := 0 to lstAll.Count -1 do begin
					cbArray[i].Checked := modalResult = 111;
				end;
			end;
		end;
		if modalResult = mrOk then begin
			Result := true;
			for i := 0 to lstAll.Count -1 do begin
				if (cbArray[i].Checked)then
					lstChecked.Add(lstAll[i]);
			end;
			if (lstChecked.indexOf('INNR') = -1 ) and ( (lstChecked.indexOf('WEAP') > -1 ) or (lstChecked.indexOf('ARMO') > -1 ) ) then
				ShowMessage('Warning: Processing of WEAP and ARMO without INNR rules is not recommended and may lead to strange results.');
			setSettingsString('config.sUseRecords', lstChecked.CommaText);
			updateMainGUI();
			end;
	finally
		frm.Free;
		lstChecked.Free;
		lstAll.Free;
		lstDescriptions.Free;
	end;}
end;


function _ShowFormTagSetSelection(): Boolean;
var
	lstAll, tmpLst: TStringList;
	selected: Integer;
	i: Integer;
begin
	// Read tag sets
	lstAll := TStringList.Create;
	tmpLst := TStringList.Create;
	ScriptConfiguration.readTags();
	tagsIniFile.ReadSections(lstAll);
	tagsIniFileUser.ReadSections(tmpLst);
	
	for i := 0 to tmpLst.Count -1 do
		if lstAll.indexOf(tmpLst[i]) = -1 then
			lstAll.add(tmpLst[i]);
	
	// Show modal selection
	selected := FormSimpleSelection.show('Tag set', _('Select tag set'),lstAll, getSettingsString('config.sUseTagSet', 'FallUI'));
	if ( selected > -1 ) then begin
		setSettingsString('config.sUseTagSet', lstAll[selected]);
		updateMainGUI();
		end;
	lstAll.Free;
	tmpLst.Free;
end;


function _ShowFormTargetESPSelection(): Boolean;
var
	lstAll: TStringList;
	selected, i: Integer;
	f: IInterface;
	sFileName, preSelected: String;
begin
	// Read tag sets
	lstAll := TStringList.Create;
	
	for i := 0 to FileCount - 2 do begin
		f := FileByLoadOrder(i);
		sFileName := (GetFileName(f));
		if (GetAuthor(f) = 'R88_SimpleSorter') then
			lstAll.add(sFileName);
	end;
	
	if Assigned( mxPatchFile ) then
		preSelected := GetFileName(mxPatchFile)
	else if Assigned( FileByAuthor('R88_SimpleSorter') ) then
		preSelected := GetFileName(FileByAuthor('R88_SimpleSorter'))
	else
		preSelected := '';
	// Show modal selection
	selected := FormSimpleSelection.show('Target ESP', _('Select target ESP'),lstAll, preSelected);
	
	if ( selected > -1 ) then
		mxPatchFile := FileByName(lstAll[selected]);
	updateMainGUI();
end;


// Dialogue form for choosing which plugins to include in the patch. Taken from mteFunctions
function _ShowFormEspFilesSelection(): Boolean;
var
	i: Integer;
	lstAll, lstChecked, lstDescriptions: TStringList;
	sl: TStringList;
	f: IInterface;
begin

// Using new Checkboxes form	
	lstAll := TStringList.Create;
	//lstAll.CommaText := getAllRecordsString();
	//lstAll.Sort;
	
	for i := 0 to FileCount - 2 do begin
		f := FileByLoadOrder(i);
		if (GetAuthor(f) = 'R88_SimpleSorter') then
			Continue;
		lstAll.Add(GetFileName(f));
		end;
	
	lstChecked := TStringList.Create;
	lstChecked.CommaText := sFiles;
	lstDescriptions := nil;//getRecordsDescriptions();
	
	if FormSimpleSelection.showCheckboxes(_('File selection'),_('Select files to be processed'), lstAll, lstChecked, lstDescriptions) then begin
		Result := true;
		if (lstChecked.indexOf('INNR') = -1 ) and ( (lstChecked.indexOf('WEAP') > -1 ) or (lstChecked.indexOf('ARMO') > -1 ) ) then
				ShowMessage('Warning: Processing of WEAP and ARMO without INNR rules is not recommended and may lead to strange results.');
		sFiles := lstChecked.CommaText;
		updateMainGUI();
		end;
	// Cleanup
	lstAll.Free;
	lstChecked.Free;
	FreeAndNil(lstDescriptions);
	Exit;
{
	sl := TStringList.Create;
	sl.CommaText := sFiles;
	try
		Result := _MultipleFileSelect(sl, _('Select the files you would like to be included.'));
	if Result then
		sFiles := sl.CommaText;
		updateMainGUI();
	finally
		sl.Free;
	end;}
end;

{
function _MultipleFileSelect(var sl: TStringList; prompt: string): Boolean;
const
	spacing = 24;
var
	frm: TForm;
	pnl: TPanel;
	lastTop, contentHeight: Integer;
	cbArray: Array[0..4351] of TCheckBox;
	lbl, lbl2: TLabel;
	sb: TScrollBox;
	i: Integer;
	f: IInterface;
	sFileName: String;
begin
	Result := false;
	frm := TForm.Create(nil);
	try
		frm.Position := poScreenCenter;
		frm.Width := 300;
		frm.Height := 600;
		frm.BorderStyle := bsDialog;
		frm.Caption := _('::: PLUGIN SELECTION :::');
		// create scrollbox
		sb := TScrollBox.Create(frm);
		sb.Parent := frm;
		sb.Align := alTop;
		sb.Height := 500;
		// create label
		lbl := TLabel.Create(sb);
		lbl.Parent := sb;
		lbl.Caption := prompt;
		lbl.Font.Style := [fsBold];
		lbl.Left := 8;
		lbl.Top := 10;
		lbl.Width := 270;
		lbl.WordWrap := true;
		lbl2 := TLabel.Create(sb);
		lbl2.Parent := sb;
		//if bReset then
			lbl2.Caption := _('It is advised to keep all plugins selected unless certain plugins are causing errors.');
		lbl2.Font.Style := [fsItalic];
		lbl2.Left := 8;
		lbl2.Top := lbl.Top + lbl.Height + 12;
		lbl2.Width := 250;
		lbl2.WordWrap := true;
		lastTop := lbl2.Top + lbl2.Height + 12 - spacing;
		// create checkboxes
		for i := 0 to FileCount - 2 do begin
			f := FileByLoadOrder(i);
			sFileName := (GetFileName(f));
			if (GetAuthor(f) = 'R88_SimpleSorter') then
				Continue;
			cbArray[i] := TCheckBox.Create(sb);
			cbArray[i].Parent := sb;
			cbArray[i].Caption := Format(' [%s] %s', [IntToHex(i, 2), GetFileName(f)]);
			cbArray[i].Top := lastTop + spacing;
			cbArray[i].Width := 260;
			lastTop := lastTop + spacing;
			cbArray[i].Left := 12;
			cbArray[i].Checked := sl.IndexOf(GetFileName(f)) > -1;
			if (sFilename = 'ArmorKeywords.esm') and getSettingsBoolean('config.bAWKCR') then
				begin
					cbArray[i].Checked := true;
					cbArray[i].Enabled := False;
				end;
		end;
		contentHeight := spacing*(i + 2) + 150;
		if frm.Height > contentHeight then
			frm.Height := contentHeight;
		// create modal buttons
		_ShowFormModConstructModalButtons(frm, frm, frm.Height - 90);
		
		sl.Clear;
		if frm.ShowModal = mrOk then begin
			Result := true;
			for i := 0 to FileCount - 2 do begin
				f := FileByLoadOrder(i);
				sFileName := (GetFileName(f));
				if (GetAuthor(f) = 'R88_SimpleSorter') then
					Continue
				else if (cbArray[i].Checked) and (sl.IndexOf(GetFileName(f)) = -1) then
					sl.Add(GetFileName(f));
			end;
		end;
	finally
		frm.Free;
	end;
end;
}

procedure _ShowFormModConstructModalButtons(h, p: TObject; top: Integer);
var
	btnOk: TButton;
	btnCancel: TButton;
begin
	btnOk := TButton.Create(h);
	btnOk.Width := 100;
	btnOk.Height := 40;
	btnOk.Parent := p;
	btnOk.Caption := #10003+' '+_('Ok');;
	btnOk.ModalResult := mrOk;
	btnOk.Left := h.Width div 2 - btnOk.Width - 8;
	btnOk.Top := top;
	btnCancel := TButton.Create(h);
	btnCancel.Width := 100;
	btnCancel.Height := 40;
	btnCancel.Parent := p;
	btnCancel.Caption := #9747+' '+_('Cancel');
	btnCancel.ModalResult := mrCancel;
	btnCancel.Cancel := true;
	btnCancel.Left := btnOk.Left + btnOk.Width + 16;
	btnCancel.Top := btnOk.Top;
end;


{Shows a simple confirm window box}
function WindowConfirm(title, text:String):Boolean;
var
	frmWinConfirm: TForm;
begin
	try
		// Setup
		Result := false;
		frmWinConfirm := efStartForm(nil,400,100,title);
		efPadding(20,20);

		// Text
		efLabel(text,0,0,0,0,efCenter+efAutoHeight+efTopAddHeight);
		
		// Buttons
		_ShowFormModConstructModalButtons(frmWinConfirm,frmWinConfirm,efTop+40);
		
		frmWinConfirm.Height := efTop + 140;
		
		efEndSub();	
		// Show modal
		Result := frmWinConfirm.ShowModal() = mrOk;
		
	finally
		FreeAndNil(frmWinConfirm);
	end;
end;


{Shows a window prompt to enter a text}
function WindowPrompt(title, text:String; var value:String; xtraPanel:TPanel):Boolean;
var
	tlab: TLabel;
begin
	try
		// Setup
		Result := false;
		_winPromptFrm := efStartForm(nil,1000,210,title);
		efPadding(20,20);

		// Text
		tlab := efLabel(text,0,0,0,0,efCenter+efAutoHeight+efTopAddHeight);
		
		// Input
		_winPromptInput := ConstructEdit(_winPromptFrm, _winPromptFrm, efTop + 20, efLeft, 15, _winPromptFrm.Width - 20*2, value, '');
		_winPromptInput.OnKeyPress := _eventWinPromptKeyPress;
		efTopAdd(_winPromptInput.Height + 50);

		// Extra stuff
		if Assigned(xtraPanel) then begin
			xtraPanel.Parent := _winPromptFrm;
			xtraPanel.Top := efTop;
			efTopAdd(xtraPanel.Height + 20);
			end;

		
		// Buttons
		_ShowFormModConstructModalButtons(_winPromptFrm,_winPromptFrm,efTop);
		efTopAdd(100);
		_winPromptFrm.height := efTop;
		

		// Show modal
		if _winPromptFrm.ShowModal() = mrOk then begin
			value := _winPromptInput.Text;
			Result := true;
			end;
		
		efEndSub();
	
	finally
		FreeAndNil(xtraPanel);
		FreeAndNil(_winPromptFrm);
	end;
end;

{Set the input value in the window prompt}
procedure WindowPromptSetInputValue(value:String);
begin
	_winPromptInput.Text := value;
	// _winPromptInput.SelectAll();
	_winPromptFrm.ModalResult := mrOk;
end;

procedure _eventWinPromptKeyPress(Sender: TObject; var key: char);
begin
	if Assigned(_winPromptFrm) and (key = #13) then
		_winPromptFrm.ModalResult := mrOk;
end;


{Shows a EDID selection assistant }
function ShowFormEDIDSelection(selectedFile:String; selectedRecordType:String):String;
var 
	i, modalResult: Integer;
	tmpLst: TStringList;
	tmpStr, edid, fullNameOrEDID: String;
	f,grp, rec: IInterface;
begin
	// File selection
	if selectedFile = '' then begin 
		tmpLst := TStringList.Create;	
		tmpLst.CommaText := helper.getAllEspFilesString;
		
		// Show form
		modalResult := FormSimpleSelection.show('Select target ESP','Select target ESP', tmpLst,'');
		if modalResult > -1 then
			selectedFile := tmpLst[modalResult];
		tmpLst.Free;
		end;
		
	if selectedFile = '' then 
		Exit;
		
	// Record type selection
	f := FileByName(selectedFile);
	if selectedRecordType = 'ALL' then 
		selectedRecordType := '';
		
	if selectedRecordType = '' then begin
		
		tmpLst := helper.getRecordsDescriptions;
		tmpLst.Values['ALL'] := '';
		
		for i := tmpLst.Count -1 downto 0 do 
			if not Assigned(GroupBySignature(f, tmpLst.Names[i])) then 
				tmpLst.delete(i);
		if tmpLst.Count = 0 then begin 
			ShowMessage('The file has no possible target records.');
			Exit;
			end;
		// Show form
		modalResult := FormSimpleSelection.show('Select record type','File: '+selectedFile+#10#13+#10#13+'Select record type:', tmpLst,'');
		if modalResult > -1 then
			selectedRecordType := tmpLst.Names[modalResult];
		tmpLst.Free;
		end;

	if selectedRecordType = '' then 
		Exit;
		
	// EDID selection
	grp := GroupBySignature(f, selectedRecordType);
	tmpLst := TStringList.Create;
	
	for i := 0 to ElementCount(grp) -1 do begin
		rec := ElementByIndex(grp, i);
		edid := EditorId(rec);
		fullNameOrEDID := GetElementEditValues(rec,'FULL');
		if fullNameOrEDID = '' then 
			fullNameOrEDID := edid;
		tmpLst.values[edid] := fullNameOrEDID;
		end;
	if tmpLst.Count = 0 then begin 
		ShowMessage('The file '+selectedFile+' has no possible EDID''s for record type '+selectedRecordType+'.');
		Exit;
		end;
	modalResult := FormSimpleSelection.show('Select EDID','File: '+selectedFile+#10#13+'Record type: '+selectedRecordType+#10#13+#10#13+'Select EDID:', tmpLst,'');
	
	if modalResult > -1 then 
		Result := tmpLst.Names[modalResult];
	tmpLst.Free;
end;


procedure cleanup();
begin
	AutoForm.cleanup();
	btnCancel := nil;
	tLabelTagSet := nil;
	tLabelESPFiles := nil;
	tLabelESPFileCount := nil;
	tLabelUseRecords := nil;
	tLabelUseRecordCount := nil;
	tLabelTargetFile := nil;
end;

end.