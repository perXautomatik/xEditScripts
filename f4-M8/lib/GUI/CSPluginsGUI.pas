{
	M8r98a4f2s Complex Item Sorter for FallUI - CSPluginsGUI
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Part of the GUI.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit CSPluginsGUI;

const
	windowPadding = 25;
	SELECTION_COLOR = $FF6666;

var
	_frmPlugin: TForm;
	_fSettingsPanel: TPanel;
	_cbPluginActive: TCheckBox;
	_pg_currentPlugin: TStringList;

implementation

{Shows configuration form for a registered plugin}
procedure ShowPluginOptions(pluginId:String);
var
	i,j, iWidth, iWidthSettingNameMax, iWidthSettingInputMax:Integer;
	settingName, tmpStr: String;
	userChoosenModalOption: Integer;
	tmpLst,userSettings, settingConfig: TStringList;
	tmpButton: TButton;
	tlab: TLabel;
	tmpCheckbox: TCheckBox;
	edit: TEdit;
	plugin, checkboxes, editInts,editFloats, editStrings: TStringList;
begin
	try

	// Find plugin
	plugin := CSPluginSystem.getPluginObj(pluginId);
	if not Assigned(plugin) then begin
		ShowMessage('Unknown plugin: '+pluginId);
		Exit;
		end;
	_pg_currentPlugin := plugin;
	
	// Setup
	checkboxes := TStringList.Create;
	editInts := TStringList.Create;
	editFloats := TStringList.Create;
	editStrings := TStringList.Create;
	
	userSettings := plugin.Objects[CSPluginSystem.PLUGIN_INDEX_OBJ_USERSETTINGS];
	
	// Determine max label width
	iWidthSettingNameMax := 100;
	iWidthSettingInputMax := 50;
	for i := 0 to userSettings.Count -1 do begin
		settingName := userSettings[i];
		settingConfig := userSettings.Objects[i];
		tlab := TLabel.Create(_frmPlugin);
		tlab.Text := settingName;
		iWidthSettingNameMax := Max(iWidthSettingNameMax, tlab.Width);
		tlab.Free;
		if settingConfig.values['type'] = 'string' then
			iWidthSettingInputMax := 200;
		end;
		
	_frmPlugin := efStartForm(nil,120+iWidthSettingNameMax+iWidthSettingInputMax,310, 'Plugin settings - '+plugin.values['name']);
	efPadding(25,25);
	
	
	// show general infos
	tlab := efLabel(plugin.values['name'],0,0,0,20,efBold);
	
	// Show Edit link 
	tlab := efLabel('Edit plugin',0,0,0,20,efRight+efBlue+efCursorHand+efTopAddHeight+efAutoWidth);
	tlab.OnClick := _eventOpenPluginINI;
	efTopAdd(10);
	
	
	if plugin.values['desc'] <> '' then begin
		tlab := efLabel(plugin.values['desc'],0,0,0,0,efAutoHeight+efTopAddHeight);
		efTopAdd(10);
		end;

	if plugin.values['author'] <> '' then begin
		tlab := efLabel('Author: '+plugin.values['author'],0,0,0,0,efAutoHeight+efTopAddHeight+efItalic);
		efTopAdd(10);
		end;

		
	// General plugin active 
	efTopAdd(20);
	tlab := efLabel('Plugin status',0,0,0,20,efBold+efTopAddHeight);
	efTopAdd(10);
	
	AutoForm_StartSub(_frmPlugin, _frmPlugin);
	AutoForm_setForm(_frmPlugin);
	AutoForm_SetAutoPos(efTop, 25);
	
	_cbPluginActive :=  AutoForm_AddCheckbox(' Plugin enabled'
					, getSettingsBoolean('plugin.'+plugin.values['id']+'.active'), 'Enable plugin');

	_cbPluginActive.OnClick := _eventPluginActiveClick;
	efTopAdd(_cbPluginActive.Height);
		
		
	efTopAdd(20);
	
	AutoForm_SetAutoPos(efTop, 25);

	//efPadding(0,0);
	_fSettingsPanel := efStartPanel(_frmPlugin,0,0,0,0);
	_fSettingsPanel.BevelWidth := 0;
	_fSettingsPanel.BorderWidth := 0;
	tlab := efLabel('Plugin settings',0,0,0,20,efBold+efTopAddHeight);

	AutoForm_StartSub(_fSettingsPanel,_fSettingsPanel);
	efTopAdd(10);
	AutoForm_SetAutoPos(efTop, 1);
	efTop := 10;
		
	// Display settings
	for i := 0 to userSettings.Count -1 do begin
		settingName := userSettings[i];
		settingConfig := userSettings.Objects[i];
		
		// Add setting to form
		if settingConfig.values['basetype'] = 'setting' then begin
			if settingConfig.values['type'] = 'bool' then begin
				
				tmpCheckbox := AutoForm_AddCheckbox(' '+settingConfig.values['name']
					, getSettingsBoolean('plugin.'+pluginId+'.'+settingName),settingConfig.values['hint']);
				checkboxes.addObject(settingName, tmpCheckbox);
				//  AutoForm_AddAutoTop(5);
				end
			else if (settingConfig.values['type'] = 'int') or (settingConfig.values['type'] = 'float')
				or (settingConfig.values['type'] = 'string')then begin
				// Label
				tlab := AutoForm_AddLabel(settingConfig.values['name'], 20);
				if settingConfig.values['hint'] <> '' then begin
					tlab.ShowHint := true;
					tlab.Hint := settingConfig.values['hint'];
					end;
				// Value
				iWidth := 50;
				if (settingConfig.values['type'] = 'int') then
					tmpStr := IntToStr(getSettingsInteger('plugin.'+pluginId+'.'+settingName,StrToInt(settingConfig.values['default'])))
				else if (settingConfig.values['type'] = 'float') then
					tmpStr := FloatToStr(getSettingsFloat('plugin.'+pluginId+'.'+settingName,StrToFloat(settingConfig.values['default'])))
				else begin
					tmpStr := getSettingsString('plugin.'+pluginId+'.'+settingName,settingConfig.values['default']);
					iWidth := 200;
					end;
				// Input
				edit := ConstructEdit(_fSettingsPanel, _fSettingsPanel, tlab.Top - 3, tlab.Left + iWidthSettingNameMax+30, 50, iWidth,tmpStr, settingConfig.values['hint']);
				tmpStr := PregReplace('[^a-zA-Z0-9_]','-',settingName);
				edit.Name := 'editPluginUserSetting_'+tmpStr;
				edit.OnKeyPress := _eventEditOnKeyPress;
				
				if (settingConfig.values['type'] = 'int') then
					editInts.addObject(settingName, edit)
				else if (settingConfig.values['type'] = 'float') then
					editFloats.addObject(settingName, edit)
				else
					editStrings.addObject(settingName, edit);
					
				// Reset
				tlab := efLabel('STD',edit.Left + edit.Width + 10, edit.Top, 40,20,efNone+efCursorHand+efBlue);
				tlab.OnClick := _eventOnClickResetSetting;
				tlab.HelpKeyword := tmpStr+'|'+settingConfig.values['default'];
				tlab.ShowHint := true;
				tlab.Hint := 'Reset to default value: ' + settingConfig.values['default'];
				AutoForm_AddAutoTop(10);

				end
			else begin
				AddMessage('Unknown setting type: '+settingConfig.values['type']);
				AutoForm_AddLabel('Unknown setting type: '+settingConfig.values['type'],20);
				end
				
			end
		else if settingConfig.values['basetype'] = 'form' then begin
			if settingConfig.values['type'] = 'text' then begin
				
				tlab := efLabel(settingConfig.values['text'],AutoForm_GetAutoLeft,AutoForm_GetAutoTop,0,0,efAutoHeight);
				if settingConfig.values['hint'] <> '' then begin
					tlab.ShowHint := true;
					tlab.Hint := settingConfig.values['hint'];
					end;
				{//tlab.Font.Style := [fsBold];
				tlab.Width := _frmPlugin.Width-20;
				// tlab.Left := 10;
				tlab.Height := nil;
				tlab.Layout := tlTop;
				tlab.AutoSize := true;
				tlab.WordWrap := true;
				tlab.Width := _frmPlugin.Width-20;}
				
				AutoForm_SetAutoPos(AutoForm_getAutoTop()+tlab.Height+8, nil);
				end
			else
				AddMessage('Unknown form type: '+settingConfig.values['type']);
			AutoForm_AddAutoTop(10);
			end
		else begin
			tlab := AutoForm_AddLabel(settingName+' - Unsupported settings type: '+settingConfig.values['type'],20);
			AddMessage('Warning: Unknown user settings type: "'+settingConfig.values['type']+'" ');
			end;
		
		end;
	
	_fSettingsPanel.Height := AutoForm_GetAutoTop;
	efEndSub();
	AutoForm_EndSub;
	frm := _frmPlugin;
	panel := _frmPlugin;
	efTopAdd(_fSettingsPanel.Height);
	
	AutoForm_SetAutoPos(efTop,25);
	
	_frmPlugin.Height := AutoForm_getAutoTop() + 120 ;
	AutoForm_AddButtonBottom(mrYes,#10003+' '+_('Ok'));
	AutoForm_AddButtonBottom(mrCancel, #9747+' '+_('Cancel')).Cancel := true;
	
	// Show modal form
	_eventPluginActiveClick(_cbPluginActive);
	userChoosenModalOption := _frmPlugin.ShowModal;
	if userChoosenModalOption <> mrCancel then begin
		//Save
		setSettingsBoolean('plugin.'+plugin.values['id']+'.active', _cbPluginActive.checked);
		
		for i := 0 to checkboxes.Count -1 do
			setSettingsBoolean('plugin.'+pluginId+'.'+checkboxes[i],checkboxes.Objects[i].checked);
		
		for i := 0 to editInts.Count -1 do
			setSettingsInteger('plugin.'+pluginId+'.'+editInts[i],StrToInt(editInts.Objects[i].Text));

		for i := 0 to editFloats.Count -1 do
			setSettingsFloat('plugin.'+pluginId+'.'+editFloats[i],StrToFloat(editFloats.Objects[i].Text));
					
		for i := 0 to editStrings.Count -1 do
			setSettingsString('plugin.'+pluginId+'.'+editStrings[i],editStrings.Objects[i].Text);
					
		ScriptConfiguration.saveSettings();
		
		
	end;
	

	finally
		FreeAndNil(_frmPlugin);
		FreeAndNil(checkboxes);
		FreeAndNil(editFloats);
		FreeAndNil(editStrings);
		FreeAndNil(editInts);
		AutoForm_EndSub();
		AutoForm_endForm();
		efEndSub();
		ComplexSorterGUI.updateMainGUI();
	end;
end;

{Event: Press enter on input form}
procedure _eventEditOnKeyPress(Sender: TObject; var key: char);
begin
	if Assigned(_frmPlugin) and (key = #13) then
		_frmPlugin.ModalResult := mrOk;
end;

{Event: Activate/deactive plugin}
procedure _eventPluginActiveClick(Sender: TObject);
var 
	i: Integer;
begin
	_fSettingsPanel.Enabled := _cbPluginActive.Checked;
	for i := 0 to _fSettingsPanel.ComponentCount - 1 do 
		_fSettingsPanel.Components[i].Enabled := _cbPluginActive.Checked;
	
end;


{Event: open plugin ini}
procedure _eventOpenPluginINI(Sender: TObject);
begin
	ComplexSorterGUI.startEditor(_pg_currentPlugin.Values['path']);
end;

{Event: Reset plugin user setting}
procedure _eventOnClickResetSetting(Sender: TObject);
var
	settingNameClean, defaultValue: String;
begin
	if SplitSimple('|',Sender.HelpKeyword,settingNameClean,defaultValue) then begin
		Sender.parent.FindComponent('editPluginUserSetting_'+settingNameClean).Text := defaultValue;
		Sender.parent.FindComponent('editPluginUserSetting_'+settingNameClean).SelectAll();
		end;
end;


end.