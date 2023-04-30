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

var
	// Private
	_csgLabelTagSet, 
	_csgLabelESPFiles,
	_csgLabelESPFileCount,
	_csgLabelUseRecords,
	_csgLabelMode,
	_csgLabelModLink,
	_csgLabelProfile,
	_csgLabelUseRecordCount, 
	_csgLabelTargetFile: TLabel;
	_csgBtnCancel: TButton;
	_csgWinPromptFrm: TForm;
	_csgWinPromptInput: TEdit;
	_csgMainFrm: TForm;
	_csgTmpLastTestedRecordFile,
	_csgTmpLastTestedRecordRecType,
	_csgTmpLastTestedRecordEdid: String;
	

implementation

{ Translation function }
function _(identifier: String): String;
var
	ini: TIniFile;
	filename: String;
	identifierClean: String;
begin
	// No real interest in translations ... so dropped.
	Result := identifier;
	exit;
end;

{Main GUI}
function ShowFormMainMenu():Integer;
const
	groupStdWidth = 330;
	groupSpacingBetween = 20;
	windowPadding = 25;
var
	i, iPressedButton: Integer;
begin
	try

	Result := -1;
	while Result = -1 do begin

		if not Assigned(_csgMainFrm) then 
			_csgMainFrm := TForm.Create(nil);

		_drawFormMainMenu();
			
		if bCPAutoStartGen then 
			iPressedButton := mrYes
		else 
			iPressedButton := frm.ShowModal;
			
		AutoForm_endForm();
		FreeAndNil(_csgMainFrm);

		if (iPressedButton = mrYes) and ( Pos('INNR',getSettingsString('config.sUseRecords', '')) <> 0 )
			and not Assigned(r88SimpleSorterInnrEsp) then
			if not WindowConfirm('No R88_SimpleSorter.esp', 
				'You have selected INNR processing, but R88_SimpleSorter.esp is not available.'+#10#13+'Continue anyway?') then
				iPressedButton := mrCancel;
		
		//Result := -1;
		if iPressedButton = 1337 then
			Result := -1 // Just reload 
		else if iPressedButton = mrYes then
			Result := 1 // Generate
		else Result := 0; // Exit
		//Result := iPressedButton = mrYes; // mrCancel = 2, mrYes = 6;
			
		if Result = 1 then begin

			// Update plugins active status
			CSPluginSystem.readPluginActiveFromSettings();
			
			bReset := getSettingsBoolean('config.bResetRecords');
					
			end;
		end;
	
	
	finally
		FreeAndNil(_csgMainFrm);		
	end;
end;

// Sets layout for Main Options Form
function _drawFormMainMenu():Integer;
const
	heightPerLine = 25;
	groupStdWidth = 330;
	groupSpacingBetween = 20;
	windowPadding = 25;
var
	i, j, iEspBoxHeight: integer;
	tmpStr: String;
	plugin, lstPrcTasks: TStringList;
	frm: TForm;
	tLabel, tmpLabel: TLabel;
	tmpCheckbox: TCheckBox;
	tmpButton: TButton;
	tmpGroup, tgPlugins: TGroup;
	fImage: TImage;
	logoPicture: TPicture;
begin
	
	frm := _csgMainFrm;
	frm.DoubleBuffered := True;
	_csgMainFrm.Caption := 'M8r Complex Item Sorter ('+COMPLEX_SORTER_INTVERSION+')';
	_csgMainFrm.Width := windowPadding*2+(groupStdWidth+groupSpacingBetween)*2-groupSpacingBetween;

	//frm.OnKeyPress := eventKeyPress;
	
	AutoForm_setForm(frm);
	AutoForm_SetAutoPos(windowPadding, windowPadding);
	optionGroupWidth := groupStdWidth;
	optionGroupPadding := 15;

	logoPicture := TPicture.Create;
	logoPicture.LoadFromFile(sComplexSorterBasePath+'images\logo.png');
	
	fImage := frm.FindComponent('logo');
	if not Assigned(fImage) then begin 
		fImage := TImage.Create(frm);
		fImage.Picture := logoPicture;
		fImage.Name := 'logo';
		
		fImage.Parent := frm;
		fImage.Left := 15;
		fImage.Top := 20;
		fImage.Width := frm.Width;
		fImage.Height := fImage.Height;
		end;
	
	AutoForm_SetAutoPos(120, nil);

	// Mode
	AutoForm_BeginGroup('','Settings profile');
	
	// Help 
	_addHelpButton('Settings profile'+#13
		+#13
		+'Allows you to save all Complex Sorter menu settings as named profiles. '+#13
		+'This includes all menu settings like mode, input files, record types, output file, advanced options, active plugins and plugin settings.'+#13
		+'Note: Does NOT include the processing rules itself.'+#13
		);
		
	_csgLabelProfile := AutoForm_AddLabel('{...}', 36);
	_csgLabelProfile.Font.Style := [fsBold];
	tmpLabel := AutoForm_AddLink(_csgLabelProfile,'Save', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
	tmpLabel.OnClick := saveSettings;
	tmpLabel := AutoForm_AddLink(_csgLabelProfile,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
	tmpLabel.OnClick := _ShowFormChangeProfile;
	tmpLabel.Width := tmpLabel.Width - 50;
	//tmpLabel.Left := tmpLabel.Left - 0;
	_csgLabelProfile.Width := 420;
	AutoForm_AddAutoTop(-18);
	AutoForm_EndGroup();

	
	// Mode
	AutoForm_BeginGroup('','Mode');

	// Help 
	_addHelpButton('Mode'+#13
		+#13
		+'This selects the basis processing mode for Complex Sorter. There are two options: '+#13
		+#13
		+'Purge / New'+#13
		+'This mode will purge all selected records (matching the selected record types - and only those) before the processing starts.'+#13
		+'This is the safest but slowest method to create/update your patch.'+#13
		+''+#13
		+'Add / Update'+#13
		+'This mode will basically leave existing records. It will check which records have changed, and then remove only changed ones, so only this ones will be renewed. Also new records will be added.'+#13
		+'The add/update mode can speed up the processing speed considerably.'+#13
		+'Complex Sorter will try to pre-select all new/changed input files (since the last generation) when you select this mode.'+#13
		+'Note: This mode will NEVER remove any records.'+#13
		);
		
	_csgLabelMode := AutoForm_AddLabel('{...}', 36);
	
	_csgLabelMode.Font.Style := [fsBold];
	_csgLabelModLink := AutoForm_AddLink(_csgLabelMode,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
	_csgLabelModLink.OnClick := _ShowFormChangeMode;
	_csgLabelMode.Width := 420;
	AutoForm_AddAutoTop(-18);
	AutoForm_EndGroup();
	
	// Count plugins

	
	
	// Section: INPUT
	AutoForm_BeginGroup('','Input ESPs');

	// Help 
	_addHelpButton('Input ESPs'+#13
		+#13
		+'Select the input files which should be processed by Complex Sorter.'+#13
		+#13
		+'All records (matching the selected record types) in the selected files will be processed. '+#13
		+'If a record is a overwrite, the previous records (and possible later overwrites) in other files will be considered too. This works on a per-record-base, so no other records will be added through this.'+#13
		+'Note: For overwrites, the records master file will be added to the master list, even if the master file is not selected for processing (this is due to how the way records work).'+#13
		);
		
	//tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bEspFilesAutoAll',_('Select all ESP files on restart'));

	// ESP
	_csgLabelESPFileCount := AutoForm_AddLabel('{...}', 20);
	//_csgLabelESPFiles := AutoForm_AddLabel('{...}', 20+pluginRegistry.Count*25+8);
	{iEspBoxHeight := 20+_countVisiblePlugins()*25-60-46+20;
	if iEspBoxHeight < 40 then
		iEspBoxHeight := 40;}
	//_csgLabelESPFiles := AutoForm_AddLabel('{...}', iEspBoxHeight);
	_csgLabelESPFiles := AutoForm_AddLabel('{...}', 40);
	_csgLabelESPFiles.Font.Size := 6;
	_csgLabelESPFiles.Font.Style := [fsBold];

	// Link: Change
	AutoForm_AddLink(_csgLabelESPFileCount,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD).OnClick := _ShowFormEspFilesSelection;
	
	AutoForm_EndGroup();
	
	// Tags for scan
	tmpGroup := AutoForm_BeginGroup('','Record types');
	tmpGroup.Name := 'GroupRecordTypes';	

	// Help 
	_addHelpButton('Record types'+#13
		+#13
		+'Select the record types which should be processed by Complex Sorter.'+#13
		+'Unselected record types wont be changed. '+#13
		+#13
		+'Tip: You can simply do partial updates by selecting only one or a few record types (even for purge/new mode).'#13
		);
	
	_csgLabelUseRecordCount := AutoForm_AddLabel('{...}', 20);
	_csgLabelUseRecords := AutoForm_AddLabel('{...}', 36);
	_csgLabelUseRecords.Width := 320;
	_csgLabelUseRecords.Font.Style := [fsBold];
	
	// Link: Change
	tmpLabel := AutoForm_AddLink(_csgLabelUseRecordCount,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
	tmpLabel.OnClick := _ShowFormRecordTypeSelection;
	// tmpLabel.Left := tmpLabel.Left - 20;
	//tmpLabel.Width := tmpLabel.Width - 30;
	

	AutoForm_EndGroup();

	
	// Section: Processing
	AutoForm_SetAutoPos(120, windowPadding+(groupStdWidth+groupSpacingBetween)*1);

	AutoForm_BeginGroup('','Processing rules');

	// Help 
	_addHelpButton('Processing rules'+#13
		+#13
		+'The processing rules define how the whole processing works. Those rules define what records should be processed, how they should be processed, and which tag they should get.'+#13
		+'You can change any rule to your liking. And of course you can add custom rules.'+#13
		+#13
		+'Note: The processing rules section is a bit more technical. '
		+#13
		+'For most uses, the default rules will cover most items (vanilla+modded) quite well. So if you are not so experienced, you can safely just ignore this section.'+#13
		+#13
		+'You can find simple Howto''s and a detailed description of the processing rules on the Complex Sorter Nexusmods page.'+#13
		);
	
	AutoForm_SaveAutoPos();
	AutoForm_AddLink(nil,'Open Processing Rules Editor', AF_OPT_BOLD).onClick := _buttonEditRulesGUI;
	AutoForm_AddLink(nil,'Open/add rules for mod', AF_OPT_BOLD).onClick := _buttonEditRulesGUIMod;
	AutoForm_AddLink(nil,'Test rules', AF_OPT_BOLD).onClick := _buttonDiagnostics;
	AutoForm_SetAutoPos(nil,-1);
	
	AutoForm_EndGroup();

	// Plugins group
	tgPlugins := _drawPluginBoxContent();

	AutoForm_SetAutoPos(tgPlugins.Top + tgPlugins.height+30,nil);
		
	{tmpGroup := AutoForm_BeginGroup('','Tasks');
	
	// Help 
	_addHelpButton('Tasks'+#13
		+#13
		+'Tasks bundles processing rules to groups, which can be separately enabled or disabled. '+#13
		+'The default task is "Item sorter tags", which is possible the one you want. But you can also disable it, and for example use CS to move recipes only.'+#13
		);
	lstPrcTasks := Tasks.getProcessingTasks();
	for i := 0 to lstPrcTasks.Count - 1 do begin
		tmpCheckbox := AutoForm_AddCheckboxAutoOption('task.'+lstPrcTasks.Names[i]+'.active',lstPrcTasks.ValueFromIndex[i]);
		end;
		
	AutoForm_EndGroup();}
	
	// Section: Output
	tmpGroup := AutoForm_BeginGroup('','Output ESP');
	tmpGroup.Name := 'GroupOutputESP';

	// Help 
	_addHelpButton('Output ESP'+#13
		+#13
		+'This specifies the output esp, where all generated record patches will be stored as overwrites.'+#13
		+''+#13
		+'If the specified file does not exist, it will be created.'+#13
		+''+#13
		+'Note: Your output ESP should always be the latest in your load order. If not it may lead to unpredictable results.'+#13
		);
		
	
	_csgLabelTargetFile := AutoForm_AddLabel('{...}',20);
	_csgLabelTargetFile.Font.Style := [fsBold];
	_csgLabelTargetFile.WordWrap := false;

//	if Assigned(FileByAuthor('R88_SimpleSorter')) then begin
		tLabel := AutoForm_AddLink(_csgLabelTargetFile,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
		tLabel.OnClick := _ShowFormChangeOutputESPFilename;
//		end;
	_csgLabelTargetFile.Width := 230;

	AutoForm_EndGroup();
	
	// Update values (set height for buttons)
	updateMainGUI(false);
	
	// Finalize form
	tmpButton := AutoForm_AddButtonBottom(mrYes,#10003+' '+_('Generate Patch'));
	tmpButton.TabOrder := 0;
	tmpButton.Width := 180;
	
	tmpButton := AutoForm_AddButtonBottom(nil, #9776+' '+_('Advanced Options'));
	tmpButton.TabOrder := 2;
	tmpButton.OnClick := _buttonShowAdvOptions;
	tmpButton.Width := 180;
	
	_csgBtnCancel := AutoForm_AddButtonBottom(mrCancel, #9747+' '+_('Cancel'));
	_csgBtnCancel.TabOrder := 1;
	_csgBtnCancel.Cancel := true;
	
	_csgBtnCancel.Width := 180;
	
	AutoForm_ArrangeButtonBottom();
	
end;


{Updates dynamic entries in main GUI}
procedure updateMainGUI(updatePlugins:Boolean);
var
	iMaxAutoTop: Integer;
	mxFile: IInterface;
	tmpLst1, tmpLst2: TStringList;
	tgPlugins: TGroupBox;
begin
	//frm := _csgMainFrm;
	
	if updatePlugins then
		_drawPluginBoxContent();

	// ESP files
	_csgLabelESPFiles.Text := pregReplace(',',', ',sFiles);
	tmpLst1 := Split(',',sFiles);
	tmpLst2 := Split(',',getAllEspFilesString());
	_csgLabelESPFileCount.Text := 'Selected: '+ IntToStr(tmpLst1.Count) + ' / '+	IntToStr(tmpLst2.Count) +'';
	tmpLst1.Free;
	tmpLst2.Free;
	
	// Records
	tmpLst1 := Split(',',getSettingsString('config.sUseRecords', ''));
	tmpLst2 := Split(',',getAllRecordsString());
	_csgLabelUseRecordCount.Text := _('Selected: ') + ' '+ IntToStr(tmpLst1.Count) + ' / '+	IntToStr(tmpLst2.Count)+'';
	_csgLabelUseRecords.Text := pregReplace(',',', ',getSettingsString('config.sUseRecords', ''));
	//_csgLabelModLink.Visible := not getSettingsBoolean('config.bProcModeAuto');
	
	tmpLst1.Free;
	tmpLst2.Free;
	
	if getSettingsBoolean('config.bResetRecords') then
		_csgLabelMode.Text := 'Purge / New'
	else 
		_csgLabelMode.Text := 'Add / Update';
		
	_csgLabelProfile.Text := getCurrentSettingsProfileName();
	if _csgLabelProfile.Text = 'Settings' then 
		_csgLabelProfile.Text := 'Default';

	// Output file
	mxFile := FileByAuthor('R88_SimpleSorter');
	if Assigned(mxPatchFile) then
		_csgLabelTargetFile.Text := GetFileName(mxPatchFile)
	else if Assigned(mxFile) then
		_csgLabelTargetFile.Text := GetFileName(mxFile)
	else
		_csgLabelTargetFile.Text := 'M8r Complex Sorter.esp';
			
	// Adjust layout
	tgPlugins := frm.FindComponent('GroupPlugins');
	_csgLabelESPFiles.height := Max(40,40 +tgPlugins.height-190 );
	_csgLabelESPFiles.Parent.height := _csgLabelESPFiles.height+64;
	_csgLabelUseRecords.Parent.Top := _csgLabelESPFiles.Parent.Top + _csgLabelESPFiles.Parent.Height + 30;
	_csgLabelTargetFile.Parent.Top := tgPlugins.Top + tgPlugins.Height + 30;

	iMaxAutoTop := Max(
		{left}IntToStr(frm.FindComponent('GroupRecordTypes').top+frm.FindComponent('GroupRecordTypes').height+30),
		{right}IntToStr(frm.FindComponent('GroupOutputESP').top+frm.FindComponent('GroupOutputESP').height+30)
	);
	
	// Height change?
	if frm.Height <> iMaxAutoTop + 100 then
		frm.Height := iMaxAutoTop + 100;

	// Position bottom buttons
	AutoForm_ArrangeButtonBottom();

	// Checkboxes
	AutoForm_UpdateCheckboxesAutoOption();
end;

{(Re-)draws plugin group box}
function _drawPluginBoxContent():TGroupBox;
var
	i, iHiddenCnt: Integer;
	tmpGroup, prevGroup: TGroupBox;
	tmpCheckbox, tmpOldCheckbox: TCheckBox;
	tLabel: TLabel;
	plugin, lstHideMes: TStringList;
begin
	lstHideMes := TStringList.Create;
	// Double calls? pascal what are you doing?!
	{if assigned(frm.FindComponent('GroupPluginsPrev')) then exit;
	prevGroup := frm.FindComponent('GroupPlugins');
	if Assigned(prevGroup) then
		prevGroup.Name := 'GroupPluginsPrev';}
	//prevGroup := frm.FindComponent('GroupPlugins');
	tmpGroup := AutoForm_BeginGroup('GroupPlugins','Plugins');
	// Prevent double call
	if not tmpGroup.Enabled then 
		Exit;
	//tmpGroup.Enabled := False;
	//tmpGroup.Parent := nil; // Prevent flickering

	// Clean for reuse
	for i := tmpGroup.ControlCount-1 downto 0 do
		if tmpGroup.Controls[i].Name = '' then
			tmpGroup.Controls[i].Free
		else  // Mark for maybe-hiding
			lstHideMes.AddObject(tmpGroup.Controls[i].Name+'=True',tmpGroup.Controls[i]);

	// Help 
	_addHelpButton('Plugins'+#13
		+#13
		+'Plugins can do and change a wide range of things. Read the plugin description to know what each one specifically do.'+#13
		+''+#13
		+'Note: Some plugins processed special record types, which will be noted in the plugin description (like Radio Tags needs ACTI and MESG selected so it can add tags)'+#13
		);
	
	curAutoWidth := 210 + 12;
	for i := 0 to pluginRegistry.Count -1 do begin
		plugin := CSPluginSystem.getPluginObj(pluginRegistry[i]);
		if not CSPluginSystem.getShowInMainGUI(plugin.values['id']) then begin
			Inc(iHiddenCnt);
			continue;
			end;
		//tmpOldCheckbox := frm.FindComponent('PluginCheckbox_'+plugin.values['id']);
		// Note: Checkboxes will be reused by AutoForm
		
		tmpCheckbox := AutoForm_AddCheckboxAutoOption('plugin.'+plugin.values['id']+'.active',plugin.values['name']);
		tmpCheckbox.OnClick := _eventOverwriteClickAutoOptionCheckBox;
		lstHideMes.Values[tmpCheckbox.Name] := false;
		// Use old checkbox to prevent missing pointer error
		{if Assigned( tmpOldCheckbox ) then begin
			tmpOldCheckbox.Parent := tmpCheckbox.Parent;
			tmpOldCheckbox.Owner := tmpCheckbox.Owner;
			tmpOldCheckbox.Top := tmpCheckbox.Top;
			tmpOldCheckbox.Left := tmpCheckbox.Left;
			end;}
		//tmpCheckbox.Width := 210;//curAutoWidth / 2;
		//tmpCheckbox.Name := 'PluginCheckbox_'+plugin.values['id'];
		tmpCheckbox.Enabled := CSPluginSystem.checkPluginRequirements(plugin.values['id']);
		// Extend onchange
		if plugin.Values['type'] = 'pluginSpecial' then 
			tmpCheckbox.Font.Style := [fsBold];
		if not tmpCheckbox.Enabled then begin
			// tmpCheckbox.Font.Style := [fsStrikeOut];
			//tmpCheckbox.Visible := False;
			//tLabel := AutoForm_AddLabel(tmpCheckbox.Caption,0); tLabel.Font.Color := $AAAAAA;
			tLabel := AutoForm_AddLabel('',0);
			tLabel.Top := tmpCheckbox.Top;
			tLabel.Left := tmpCheckbox.Left + 19;
			tLabel.Width := tmpCheckbox.Width;
			tLabel.ShowHint := true;
			if CSPluginSystem.checkPluginRequirementPlugins(plugin.values['id']) <> '' then begin
				tLabel.Hint := CSPluginSystem.checkPluginRequirementPlugins(plugin.values['id']);
				tLabel.HelpKeyword := plugin.values['requiredPlugins'];
				tLabel.OnClick := _addMissingPluginsForPlugin;
				end
			else if CSPluginSystem.checkPluginRequirementRecordTypes(plugin.values['id']) <> '' then begin
				tLabel.Hint := 'Only for record types: '+plugin.values['requiredRecordTypes'];
				tLabel.HelpKeyword := plugin.values['requiredRecordTypes'];
				tLabel.OnClick := _addMissingRecordTypesForPlugin;
				end;
			end;

		tLabel := frm.FindComponent('PluginGroup_ConfPluginLink'+plugin.values['id']);
		if not Assigned(tLabel) then begin
			tLabel := AutoForm_AddLink(tmpCheckbox,'Configure', AF_OPT_BOLD);
			// Restore width
			tmpCheckbox.Width := 210;//curAutoWidth / 2;
			tLabel.Name := 'PluginGroup_ConfPluginLink'+plugin.values['id'];
			tLabel.HelpKeyword := plugin.values['id'];
			//tLabel.Left := tLabel.Left + tLabel.Width / 2;
			tLabel.Left := tmpCheckbox.Left + 210+10;
			tLabel.onClick := _buttonConfigurePlugin;
			//tLabel.Width := tLabel.Width / 2;
			tLabel.Width := 70;
			end
		else if tLabel.Top <> tmpCheckbox.Top then 
			tLabel.Top := tmpCheckbox.Top;
		lstHideMes.Values[tLabel.Name] := false;
		// tmpCheckbox.Width :=  tmpCheckbox.Width + tLabel.Width / 2;
		
		end;
		
	tLabel := AutoForm_AddLabel('(Hidden: '+IntToStr(iHiddenCnt)+')',20);
	tLabel.Left := 110;
	tLabel.Font.Color := $AAAAAA;
	AutoForm_AddAutoTop(-20);
	AutoForm_AddLink(nil,'More plugins', AF_OPT_BOLD).onClick := {CSPluginsGUI.}ShowPluginVisibilityForm;
	
	AutoForm_EndGroup();
		
	//tmpGroup.Parent := panel;
	{if Assigned(prevGroup) then begin 
		tmpGroup.top := prevGroup.top;
		tmpGroup.left := prevGroup.left;
		prevGroup.Free;
		end;}
	for i := 0 to lstHideMes.Count-1 do 
		if lstHideMes.ValueFromIndex[i] = 'True' then 
			lstHideMes.Objects[i].Hide;
		
	tmpGroup.Enabled := True;
	Result := tmpGroup;
	lstHideMes.Free;
end;

procedure _eventOverwriteClickAutoOptionCheckBox(Sender: TObject);
begin
	AutoForm._eventClickAutoOptionCheckBox(Sender);
	CSPluginSystem.readPluginActiveFromSettings();
	updateMainGUI(true);
end;


{Dialog: Add new output patch file}
procedure _showFormAddNewTargetPatchFile();
var 
	prevMXFile:IInterface;
begin
	prevMXFile := mxPatchFile;
	mxPatchFile := AddNewFile;
	if Assigned(mxPatchFile) then begin
		SetAuthor(mxPatchFile, 'R88_SimpleSorter');
		if Assigned(mxPatchFile) and ( getFileName(mxPatchFile) <> '' ) then 
			setSettingsString('config.sTargetESPPatchFile',getFileName(mxPatchFile));
		end
	else 
		mxPatchFile := prevMXFile;
	updateMainGUI(false);
end;


{Updates dynamic entries in options GUI}
procedure updateAdvOptionsGUI();
begin
			
	// Tag set
	_csgLabelTagSet.Text := getSettingsString('config.sUseTagSet', 'FallUI');

end;

procedure _buttonEditTags();
begin
	startEditor(sComplexSorterBasePath+'Rules (Default)\tags.ini');
end;

procedure _buttonEditRulesINNR();
begin
	startEditor(getDynamicNamingRulesIniPath());
end;

{Show diagnostic tools}
procedure _buttonDiagnostics();
var 
	options: TStringList;
	retVal:Integer;
	selectedFile, selectedRecordType, editorId:String;
begin
	options := TStringList.Create;
	options.CommaText := sFiles;
	// Option for select last tested record
	if _csgTmpLastTestedRecordFile <> '' then 
		options.Insert(0,'[Last record: ' + _csgTmpLastTestedRecordEdid+']');
	
	retVal := FormSimpleSelection.show('Select mod','',options,'');
	if retVal > -1 then begin		
		if (_csgTmpLastTestedRecordFile <> '') and (retVal = 0) then begin 
			Diagnostics.showGenericDiagnostic(_csgTmpLastTestedRecordFile,_csgTmpLastTestedRecordRecType,_csgTmpLastTestedRecordEdid);
			Exit;
			end;
		selectedFile := options[retVal];
		selectedRecordType := ShowAssistantFormRecordTypeSelection(selectedFile);
		if selectedRecordType <> '' then begin 
			editorId := ShowFormEDIDSelection(selectedFile,selectedRecordType);
			if editorId <> '' then begin
				_csgTmpLastTestedRecordFile := selectedFile;
				_csgTmpLastTestedRecordRecType := selectedRecordType;
				_csgTmpLastTestedRecordEdid := editorId;
				Diagnostics.showGenericDiagnostic(selectedFile,selectedRecordType,editorId);
				end;
			end;
	end;
	options.Free;
end;

procedure _buttonEditRulesGUI();
begin
	RuleEditorGUI.showRuleEditor('');
	ResetFormMainMenu();
end;

{Show form for editing a user rules file for a specific esp}
procedure _buttonEditRulesGUIMod();
var espFilesLabels, tmpLst2, espFilesBasenames: TStringList;
	j,retVal:Integer;
	tmpStr: String;
begin
	// Custom mod rules selection
	espFilesLabels := TStringList.Create;
	tmpLst2 := TStringList.Create;
	espFilesBasenames := TStringList.Create;
	tmpLst2.CommaText := sFiles;
	for j := 0 to tmpLst2.Count -1 do
		if FileExists(sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst2[j])+'.ini') then begin
			espFilesBasenames.add(getBaseESPName(tmpLst2[j]));
			espFilesLabels.add( tmpLst2[j] );
			end;
	for j := 0 to tmpLst2.Count -1 do
		if not FileExists(sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(tmpLst2[j])+'.ini') then begin
			espFilesBasenames.add(getBaseESPName(tmpLst2[j]));
			espFilesLabels.add('[New] ' + tmpLst2[j] );
			end;
	tmpLst2.Free;
	if espFilesLabels.Count = 0 then
		ShowMessage('No custom user rules for your current ESP files selection.')
	else begin
		retVal := FormSimpleSelection.show('Select mod','',espFilesLabels,'');
		if retVal > -1 then begin
			tmpStr := sComplexSorterBasePath+'Rules (User)\'+getBaseESPName(espFilesBasenames[retVal])+'.ini';

			// Create new user rule file on demand
			if not FileExists(tmpStr) then
				CopyFile(sComplexSorterBasePath+'Rules (User)\.dummy.custom-mod.ini', tmpStr,false);

			// Start rule editor
			RuleEditorGUI.showRuleEditor(RULESETS_IDENTIFIER_USER_MOD_RULES+getBaseESPName(espFilesBasenames[retVal])+'>'+'');
			ResetFormMainMenu();
			end;
		end;
	espFilesLabels.Free;
	espFilesBasenames.Free;
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
const
	heightPerLine = 25;
	groupStdWidth = 330;
	groupSpacingBetween = 20;
	windowPadding = 25;
var
	tFormAdvOpts: TForm;
	tLabel: TLabel;
	tmpCheckbox: TCheckBox;
	tmpButton: TButton;
	tmpGroup: TGroupBox; // TGroup
	fEditExtEditor,fEditFontScale,fEditMaxMasters: TEdit;
	i, j, maxHeight: integer;
	tmpStr: String;
begin
	tFormAdvOpts := TForm.Create(nil);
	try
	maxHeight := 0;
	//frm.OnKeyPress := eventKeyPress;
	tFormAdvOpts.Caption := 'Advanced Options';
	tFormAdvOpts.Width := windowPadding*2+(groupStdWidth+groupSpacingBetween)*2-groupSpacingBetween;
	
	AutoForm_setForm(tFormAdvOpts);
	AutoForm_SetAutoPos(windowPadding, windowPadding);
	optionGroupWidth := groupStdWidth;
	optionGroupPadding := 15;
		
	AutoForm_SetAutoPos(100, nil);
	
	// Section: Processing
	AutoForm_SetAutoPos(windowPadding, windowPadding+(groupStdWidth+groupSpacingBetween)*0);

	AutoForm_BeginGroup('','Tag set');

	// Help 
	_addHelpButton('Tag set'+#13
		+#13
		+'The output tag set defines which final tags should be used. '+#13
		+'So this decides, if you get FallUI Item Sorter tags, or Ruddy88 tags or VIS-G tags in your output file.'+#13
		+#13
		+'You can change and add tags to existing tag sets via the TagIdent mapping. And you can even create whole new tag sets if you like. Just add a new [Section] to the file.'+#13
		);
		
	_csgLabelTagSet:= AutoForm_AddLabel('{...}',20);
	_csgLabelTagSet.Font.Style := [fsBold];
	
	tLabel := AutoForm_AddLink(_csgLabelTagSet,'Change', AF_OPT_FULL_WIDTH+AF_OPT_BOLD);
	tLabel.onClick := _ShowFormTagSetSelection;
	// tLabel.Width := groupStdWidth;

	AutoForm_EndGroup();
	
	AutoForm_BeginGroup('','TagIdent mapping');
	
	// Help 
	_addHelpButton('TagIdent mapping'+#13
		+#13
		+'This defines which tags to use for each output tag set.'+#13
		+#13
		+'All rules are defined to have a TagIdent as target, so it isnt bound to a specific tag set. After the rules found the TagIdent, the mapping will find the final [Tag] for the TagIdent (depending on your choosen output tag set).'+#13
		+#13
		+'It is basically a list, which for example say "neck" should be "[Neck]" in FallUI Item Sorter and "neck" should be "[5a Necklace]" for VIS-G.'+#13
		);
	
	AutoForm_SaveAutoPos();
	AutoForm_AddLink(nil,'View default tags', 0).onClick := _buttonEditTags;
	AutoForm_SetAutoPos(-1,AutoForm_GetAutoLeft()+140);
	AutoForm_AddLink(nil,'Edit USER''s tags', AF_OPT_BOLD).onClick := _buttonEditTagsUser;
	AutoForm_SetAutoPos(nil,-1);
	
	AutoForm_EndGroup();
	
	

	tmpGroup := AutoForm_BeginGroup('','Advanced');
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bTranslateINNR',_('Translate R88_SimpleSorter.esp INNR'));
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Try to translate all INNR-Tags to your current language.');
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bIncludeR88InnrRules',_('Include all R88 INNR records'));
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Includes all INNR rules from R88 INNR esp, so the resulting esp is complete and independent from R88_SimpleSorter.esp');
	
	if not Assigned(r88SimpleSorterInnrEsp) then
		AutoForm_AddLabel('Warning: No R88 INNR Tag ESP found!',15);

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bEspFilesAutoAll',_('Select all ESP files for purge mode on restart'));
		
	// iMaxMastersPerFile
	AutoForm_AddLabel('Max masters per output file',15);
	fEditMaxMasters := ConstructEdit(tFormAdvOpts, tmpGroup, AutoForm_GetAutoTop, AutoForm_GetAutoLeft, 15
			, groupStdWidth - 20*2, IntToStr(getSettingsInteger('config.iMaxMastersPerFile', StrToInt(scDefaults.values['config.iMaxMastersPerFile']) )), 
			'Tries to keep masters per output patch file to max this settings. If reached, a new file will be created. Note: Due to actions like added keywords this isn''t exact. So don''t go up to 253.');
	AutoForm_AddAutoTop(fEditMaxMasters.Height+10);
	fEditMaxMasters.Width := 60;

		
	AutoForm_EndGroup();

	
	tmpGroup := AutoForm_BeginGroup('','Miscellaneous');

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseDarkTheme',_('Dark theme active'));
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Uses colors suitable for dark color theme. Use this if you use the dark theme from FO4Edit.');
	
	AutoForm_AddLabel('External editor',15);
	fEditExtEditor := ConstructEdit(tFormAdvOpts, tmpGroup, AutoForm_GetAutoTop, AutoForm_GetAutoLeft, 15
			, groupStdWidth - 20*2, getSettingsString('config.externalEditorPath','Notepad'), 'Configures the external editor for opening ini and configuration files.');
	AutoForm_AddAutoTop(fEditExtEditor.Height+10);

	AutoForm_AddLabel('Scale font size',15);
	fEditFontScale := ConstructEdit(tFormAdvOpts, tmpGroup, AutoForm_GetAutoTop, AutoForm_GetAutoLeft, 15
			, groupStdWidth - 20*2, FloatToStr(getSettingsFloat('config.fTextFontScale', 1.0)), 
			'Scales font size. Possible fix for problems on high resolution displays.');
	AutoForm_AddAutoTop(fEditFontScale.Height+10);
	fEditFontScale.Width := 60;

	AutoForm_EndGroup();
	
	maxHeight := Max(maxHeight, AutoForm_GetAutoTop);
	// COLUMN 2 
	AutoForm_SetAutoPos(windowPadding, windowPadding+(groupStdWidth+groupSpacingBetween)*1);

	
	AutoForm_BeginGroup('','INNR and heuristic');

	//AutoForm_AddButton(AutoForm_GetAutoTop(), AutoForm_GetAutoLeft(),30,nil,nil,#9636+' '+_('Edit dynamic naming rules'))
	//	.OnClick := _buttonEditRulesINNR;
	tLabel := AutoForm_AddLink(nil,'Edit dynamic naming rules', 0);
	tLabel.OnClick := _buttonEditRulesINNR;
	tLabel.Width := 280;

	AutoForm_AddAutoTop(10);
	AutoForm_AddCheckboxAutoOption('config.bHeuristicInjectRulesToWeaponsINNR',_('Inject naming rules to weapons INRD>INNR'));
	AutoForm_AddCheckboxAutoOption('config.bHeuristicAddTagsToWeapons',_('Apply heuristic tags to weapons without INRD'));
	AutoForm_AddCheckboxAutoOption('config.bHeuristicAddTagsToWeaponsTemplates',_('Apply heuristic tags to unique weapon templates'));
	AutoForm_AddCheckboxAutoOption('config.bHeuristicAddTagsToApparel',_('Apply heuristic tags to apparel'));
	AutoForm_AddCheckboxAutoOption('config.bHeuristicInjectInnrKeywordTags',_('Inject automatic INNR keyword tags'));
	
	AutoForm_EndGroup();
	
	
	AutoForm_BeginGroup('','Performance');

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCacheKeywords',_('Keywords cache'));
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Caches keyword FormID''s. '+#10#13+'Must be manually purged if you use custom mod keywords and change their position in load order.';
	tLabel := AutoForm_AddLink(tmpCheckbox,'Clear all caches', 0);
	tLabel.OnClick := _buttonClearAllCaches;

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCacheProcSetResult',_('Proccessing rules cache'));
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Caches the result of rules for records. '+#10#13+'Integrated validation system for changed records.';

	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCacheConditionCheck',_('Condition check cache (Read hint)'));
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Caches condition checks for records. '+#10#13+'Integrated validation system for changed records.'
		+ #10#13 +'Only useful if you change rules very often. Slower if rules are mostly unchanged.';
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bUseCachePluginScript','Plugin cache');
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := _('Caches plugin script results.'+#10#13+'Uses invalidation system for detecting changes to plugin or plugin settings.');
	
	tmpCheckbox := AutoForm_AddCheckboxAutoOption('config.bGatherStatistics',_('Gather statistics (Read hint)'));
	tmpCheckbox.ShowHint := true;
	tmpCheckbox.Hint := 'Lowers the performance. IMPORTANT: Needs processing rules cache to be deactivated.';
	
	AutoForm_EndGroup();

	maxHeight := Max(maxHeight, AutoForm_GetAutoTop);

	// Finalize form
	tFormAdvOpts.Height := maxHeight + 100;
	
	tmpButton := AutoForm_AddButtonBottom(mrYes,#10003+' '+_('Ok'));
	tmpButton.TabOrder := 0;
	tmpButton.Width := 140;
	
	{tmpButton := AutoForm_AddButtonBottom(mrCancel, #9747+' '+_('Cancel'));
	tmpButton.TabOrder := 1;
	tmpButton.Cancel := true;
	tmpButton.Width := 140;}
	
	AutoForm_ArrangeButtonBottom();
	
	// For Cancel by esc 
	{tmpButton := TButton.Create(tFormAdvOpts);
	tmpButton.ModalResult := mrCancel;}
	tmpButton.Cancel := true;
	{tmpButton.Top := -50;}
	
	updateAdvOptionsGUI();
	
	i := tFormAdvOpts.ShowModal;
	AutoForm_endForm();
	// mrCancel = 2, mrYes = 6;
	
	// Save non auto fields 
	setSettingsString('config.externalEditorPath',fEditExtEditor.Text);
	setSettingsFloat('config.fTextFontScale',StrToFloat(fEditFontScale.Text));
	setSettingsInteger('config.iMaxMastersPerFile',StrToInt(fEditMaxMasters.Text));
	
	updateMainGUI(true);
	finally
		FreeAndNil(tFormAdvOpts);
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
	CSPluginsGUI.ShowPluginOptions(Sender.HelpKeyword,true);
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


{Adds a help button to a group box}
procedure _addHelpButton(helpText:String);
var 
	tmpLabel: TLabel;
begin
	AutoForm_SaveAutoPos();
	tmpLabel := AutoForm_AddLink(nil,'Help', 0);
	tmpLabel.Left := tmpLabel.Left + tmpLabel.Width - 30 + 2;
	tmpLabel.Width := 30;
	tmpLabel.Top := tmpLabel.Top - 20;
	tmpLabel.Font.Color := $AAAAAA;
	tmpLabel.OnClick := _ShowFormRecordTypeHelp;
	tmpLabel.HelpKeyword := helpText;
	AutoForm_SetAutoPos(-1,-1);
end;

{Help for record type selection}
procedure _ShowFormRecordTypeHelp(Sender:TObject);
begin
	ShowMessage(Sender.HelpKeyword);
end;

procedure _addMissingRecordTypesForPlugin(Sender:TObject);
var
	i: Integer;
	tmpLst: TStringList;
begin
	if WindowConfirm('Add record types?', 'Add record types for this plugin?'+#13+#13+'Record types: '+Sender.HelpKeyword) then begin
		tmpLst := TStringList.Create;
		tmpLst.Sorted := True;
		tmpLst.Duplicates := dupIgnore;
		tmpLst.CommaText := StringReplace(Sender.HelpKeyword,'+',',',[rfReplaceAll]);
		tmpLst.AddStrings(lstUseRecordTypes);
		setSettingsString('config.sUseRecords', tmpLst.CommaText);
		lstUseRecordTypes.CommaText := getSettingsString('config.sUseRecords', '');
		updateMainGUI(true);
		tmpLst.Free;
		end;
end;

procedure _addMissingPluginsForPlugin(Sender:TObject);
var
	i: Integer;
	tmpLst,plugin: TStringList;
begin
	plugin := CSPluginSystem.getPluginObj(Sender.HelpKeyword);
	if not Assigned(plugin) then begin
		ShowMessage('Plugin "'+Sender.HelpKeyword+'" not installed.');
		Exit;
		end;
	if WindowConfirm('Activate plugin?', 'Activate required plugin(s) for this plugin?'+#13+#13+'Required plugin(s): '+plugin.Values['name']) then begin
		SetSettingsBoolean('plugin.'+plugin.values['id']+'.active', true);
		CSPluginSystem.readPluginActiveFromSettings();
		updateMainGUI(false);
		end;
end;

{Shows the form to select record types}
function _ShowFormRecordTypeSelection(): Boolean;
var
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
		if (lstChecked.indexOf('INNR') = -1 ) and ( (lstChecked.indexOf('WEAP') > -1 ) or (lstChecked.indexOf('ARMO') > -1 ) or (lstChecked.indexOf('LVLI') > -1 ) ) then
				ShowMessage('Warning: Processing of WEAP, LVLI and ARMO without INNR rules is not recommended and may lead to strange results.');
		setSettingsString('config.sUseRecords', lstChecked.CommaText);
		lstUseRecordTypes.CommaText := getSettingsString('config.sUseRecords', '');
		updateMainGUI(true);
		//ComplexSorterGUI.ResetFormMainMenu();
		end;
	// Cleanup
	lstAll.Free;
	lstChecked.Free;
	lstDescriptions.Free;
	
end;


procedure _ShowFormTagSetSelection();
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
	// Add FO4-Data tags.ini tag sets
	tagsIniFileData.ReadSections(tmpLst);
	for i := 0 to tmpLst.Count -1 do
		if lstAll.indexOf(tmpLst[i]) = -1 then
			lstAll.add(tmpLst[i]);

	// Add user tags.ini tag sets
	tagsIniFileUser.ReadSections(tmpLst);
	for i := 0 to tmpLst.Count -1 do
		if lstAll.indexOf(tmpLst[i]) = -1 then
			lstAll.add(tmpLst[i]);
	
	// Show modal selection
	selected := FormSimpleSelection.show('Tag set', _('Select tag set'),lstAll, getSettingsString('config.sUseTagSet', 'FallUI'));
	if ( selected > -1 ) then begin
		setSettingsString('config.sUseTagSet', lstAll[selected]);
		updateAdvOptionsGUI();
		end;
	lstAll.Free;
	tmpLst.Free;
end;

procedure _ShowFormChangeMode;
begin
	setSettingsBoolean('config.bResetRecords', not getSettingsBoolean('config.bResetRecords'));
	updateSFiles();
	updateMainGUI(false);
end;


procedure _ShowFormChangeProfile;
var
	lstAll, tmpLst: TStringList;
	selected: Integer;
	i: Integer;
	newProfileName: String;
begin
	// setSettingsBoolean('config.bResetRecords', not getSettingsBoolean('config.bResetRecords'));
	lstAll := ScriptConfiguration.getAvailableSettingsProfiles();
	for i := 0 to lstAll.Count - 1 do 
		if lstAll[i] = 'Settings' then 
			lstAll[i] := 'Default';
	
	lstAll.Add('title=Actions');
	lstAll.Add('New profile');
	if lstAll.Count > 2 then
		lstAll.Add('Delete profile');
	selected := FormSimpleSelection.show('Settings profile', 
		_('Select settings profile. The profile contains all GUI settings.'+#13+#10
			+'Note: The profiles doesn''t contain processing rules, dynamic names or tags.'),lstAll, ScriptConfiguration.getCurrentSettingsProfileName());
	if ( selected > -1 ) then begin
		newProfileName := lstAll[selected];
		if newProfileName = 'Delete profile' then begin
			if lstAll.indexOf('Default') > -1 then
				lstAll.delete(lstAll.indexOf('Default'));
			lstAll.delete(lstAll.indexOf('title=Actions'));
			lstAll.delete(lstAll.indexOf('New profile'));
			lstAll.delete(lstAll.indexOf('Delete profile'));
			if lstAll.indexOf(ScriptConfiguration.getCurrentSettingsProfileName()) > -1 then
				lstAll.delete(lstAll.indexOf(ScriptConfiguration.getCurrentSettingsProfileName()));
			selected := FormSimpleSelection.show('Delete settings profile', 
				_('Select settings profile for deletion.'),lstAll, '');
			if selected > -1 then
				if WindowConfirm('Delete profile', 'Delete profile '+lstAll[selected]+'?') then begin
					ScriptConfiguration.deleteSettingsProfile(lstAll[selected]);
					ShowMessage('Profile deleted!');
					end;
			
			lstAll.Free;
			Exit;
			end;
		if newProfileName = 'Default' then 
			newProfileName := 'Settings';
		if newProfileName = 'New profile' then begin
			newProfileName := 'Name of new profile';
			if ( WindowPrompt('New settings profile name','',newProfileName,nil) ) then begin
				If WindowConfirm('Copy current settings?','Do you want to copy the current settings to the new profile?') then
					ScriptConfiguration.copySettingsProfile(ScriptConfiguration.getCurrentSettingsProfileName(),newProfileName);
				ScriptConfiguration.setCurrentSettingsProfileName(newProfileName);
				loadSettingsProfile();
				ScriptConfiguration.saveSettings();
				end;
			end
		else if newProfileName <> ScriptConfiguration.getCurrentSettingsProfileName() then begin
			ScriptConfiguration.setCurrentSettingsProfileName(newProfileName);
			loadSettingsProfile();
			end;
			
		// Update
		//updateSFiles();
		updateMainGUI(true);
		//ComplexSorterGUI.ResetFormMainMenu();
		end;

	
	lstAll.Free;
end;



{
procedure _eventToggleProcModeAuto;
begin

	setSettingsBoolean('config.bProcModeAuto', not getSettingsBoolean('config.bProcModeAuto'));
	if getSettingsBoolean('config.bProcModeAuto') then 
		updateProcModeAuto();
	updateMainGUI();
end;
}




function _ShowFormChangeOutputESPFilename(): Boolean;
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
		if (GetAuthor(f) = 'R88_SimpleSorter') then begin
			if lstAll.Count = 0 then
				lstAll.add('title=Existing files');
			lstAll.add(sFileName);
			end;
	end;
	lstAll.add('title=Actions');
	lstAll.add(#9734+' New ESP');
	
	if Assigned( mxPatchFile ) then
		preSelected := GetFileName(mxPatchFile)
	else if Assigned( FileByAuthor('R88_SimpleSorter') ) then
		preSelected := GetFileName(FileByAuthor('R88_SimpleSorter'))
	else
		preSelected := '';
		
	{tLabel := AutoForm_AddLink(nil,#9734+' New ESP', 0);
	tLabel.Alignment := taRightJustify;
	tLabel.Top := _csgLabelTargetFile.Top+24;
	tLabel.Left := tLabel.Left-16;
	tLabel.OnClick := _ShowFormAddNewTargetPatchFile;}
		

		
	// Show modal selection
	selected := FormSimpleSelection.show('Output ESP', 'Select output ESP',lstAll, preSelected);
	
	if selected = lstAll.Count-1 then 
		_ShowFormAddNewTargetPatchFile
	else if ( selected > -1 ) then begin
		mxPatchFile := FileByName(lstAll[selected]);
		if Assigned(mxPatchFile) and ( getFileName(mxPatchFile) <> '' ) then
			_setOutputEspFilename(getFileName(mxPatchFile));
			
		end
	updateMainGUI(false);
end;

{Set a new output filename}
procedure _setOutputEspFilename(newOutputFilename:String);
var 
	i, count: Integer;
	allRecordTypes, foundRecordTypes: TStringList;
begin
	setSettingsString('config.sTargetESPPatchFile',newOutputFilename);
	// Test for included record types 
	allRecordTypes := helper.getRecordsDescriptions();
	foundRecordTypes := TStringList.Create;
	foundRecordTypes.Delimiter := #13;

	// Search record types 
	for i:= 0 to allRecordTypes.Count -1 do 
		if allRecordTypes[i] <> 'ALL' then
			if (Pos('_'+allRecordTypes.Names[i],newOutputFilename) > 0) or (Pos(allRecordTypes.Names[i]+'_',newOutputFilename) > 0) then 
				foundRecordTypes.Add(allRecordTypes.Names[i]);

	// Found something?
	if foundRecordTypes.Count > 0 then 
		if ( WindowConfirm('Adjust record types','The selected output filename contains record types.'
				+#13+#13+'Do you want to change the selected record types to those?'
				+#13+#13+'New record types would be:'+#13+foundRecordTypes.DelimitedText
				) ) then begin
			setSettingsString('config.sUseRecords', foundRecordTypes.CommaText);
			lstUseRecordTypes.CommaText := getSettingsString('config.sUseRecords', '');
			end;

	// Cleanup
	allRecordTypes.Free;
	foundRecordTypes.Free;
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
		// Show warning if use weap or armo without innr
		if (lstChecked.indexOf('INNR') = -1 ) and ( (lstChecked.indexOf('WEAP') > -1 ) or (lstChecked.indexOf('ARMO') > -1 ) ) then
				ShowMessage('Warning: Processing of WEAP and ARMO without INNR rules is not recommended and may lead to strange results.');
		// Set new files
		sFiles := lstChecked.CommaText;

		// Store setting
		if getSettingsBoolean('config.bResetRecords') then
			setSettingsString('config.sUseESPFiles',sFiles)
		else 
			setSettingsString('config.sUseESPFilesUpdate',sFiles);
		updateMainGUI(false);
		end;
	// Cleanup
	lstAll.Free;
	lstChecked.Free;
	FreeAndNil(lstDescriptions);
end;


procedure _ShowFormModConstructModalButtons(h, p: TObject; top: Integer);
var
	btnOk: TButton;
	_csgBtnCancel: TButton;
begin
	btnOk := TButton.Create(h);
	btnOk.Width := 100;
	btnOk.Height := 40;
	btnOk.Parent := p;
	btnOk.Caption := #10003+' '+_('Ok');;
	btnOk.ModalResult := mrOk;
	btnOk.Left := h.Width div 2 - btnOk.Width - 8;
	btnOk.Top := top;
	_csgBtnCancel := TButton.Create(h);
	_csgBtnCancel.Width := 100;
	_csgBtnCancel.Height := 40;
	_csgBtnCancel.Parent := p;
	_csgBtnCancel.Caption := #9747+' '+_('Cancel');
	_csgBtnCancel.ModalResult := mrCancel;
	_csgBtnCancel.Cancel := true;
	_csgBtnCancel.Left := btnOk.Left + btnOk.Width + 16;
	_csgBtnCancel.Top := btnOk.Top;
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
		_csgWinPromptFrm := efStartForm(nil,1000,210,title);
		efPadding(20,20);

		// Text
		tlab := efLabel(text,0,0,0,0,efCenter+efAutoHeight+efTopAddHeight);
		
		// Input
		_csgWinPromptInput := ConstructEdit(_csgWinPromptFrm, _csgWinPromptFrm, efTop + 20, efLeft, 15, _csgWinPromptFrm.Width - 20*2, value, '');
		_csgWinPromptInput.OnKeyPress := _eventWinPromptKeyPress;
		efTopAdd(_csgWinPromptInput.Height + 50);

		// Extra stuff
		if Assigned(xtraPanel) then begin
			xtraPanel.Parent := _csgWinPromptFrm;
			xtraPanel.Top := efTop;
			efTopAdd(xtraPanel.Height + 20);
			end;

		
		// Buttons
		_ShowFormModConstructModalButtons(_csgWinPromptFrm,_csgWinPromptFrm,efTop);
		efTopAdd(100);
		_csgWinPromptFrm.height := efTop;
		

		// Show modal
		if _csgWinPromptFrm.ShowModal() = mrOk then begin
			value := _csgWinPromptInput.Text;
			Result := true;
			end;
		
		efEndSub();
	
	finally
		FreeAndNil(xtraPanel);
		FreeAndNil(_csgWinPromptFrm);
	end;
end;

{Set the input value in the window prompt}
procedure WindowPromptSetInputValue(value:String);
begin
	_csgWinPromptInput.Text := value;
	// _csgWinPromptInput.SelectAll();
	_csgWinPromptFrm.ModalResult := mrOk;
end;

procedure _eventWinPromptKeyPress(Sender: TObject; var key: char);
begin
	if Assigned(_csgWinPromptFrm) and (key = #13) then
		_csgWinPromptFrm.ModalResult := mrOk;
end;

{Shows a record type selection assistant}
function ShowAssistantFormRecordTypeSelection(selectedFile:String):String;
var 
	i, modalResult: Integer;
	tmpLst: TStringList;
	f: IInterface;
begin
	tmpLst := helper.getRecordsDescriptions;
	tmpLst.Values['ALL'] := '';
	f := FileByName(selectedFile);

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
		Result := tmpLst.Names[modalResult];
	tmpLst.Free;
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
		
	if selectedRecordType = '' then 
		selectedRecordType := ShowAssistantFormRecordTypeSelection(selectedFile);
	
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
		
	// Show dialog
	modalResult := FormSimpleSelection.show('Select EDID','File: '+selectedFile+#10#13+'Record type: '+selectedRecordType+#10#13+#10#13+'Select EDID:', tmpLst,'');
	
	if modalResult > -1 then 
		Result := tmpLst.Names[modalResult];
	tmpLst.Free;
end;

{Restarts the main gui menu}
procedure ResetFormMainMenu();
begin
	_csgMainFrm.modalResult := 1337;
end;

{Cleanup unit}
procedure cleanup();
begin
	AutoForm.cleanup();
	_csgBtnCancel := nil;
	_csgLabelTagSet := nil;
	_csgLabelESPFiles := nil;
	_csgLabelESPFileCount := nil;
	_csgLabelUseRecords := nil;
	_csgLabelMode := nil;
	_csgLabelUseRecordCount := nil;
	_csgLabelTargetFile := nil;
end;

end.