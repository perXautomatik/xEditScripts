{
	M8r98a4f2s Complex Item Sorter for FallUI - CSPluginSystem module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Handler for Plugins.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit CSPluginSystem;

uses 'M8r Complex Item Sorter\lib\CSPluginScript';

const
	// Fixed offset in plugin data
	PLUGIN_INDEX_STR_ID           = 0;
	PLUGIN_INDEX_STR_ACTIVE       = 1;
	PLUGIN_INDEX_STR_ACTIVE_DEFAULT=2;
	PLUGIN_INDEX_STR_TYPE         = 3;
	PLUGIN_INDEX_STR_NAME         = 4;
	PLUGIN_INDEX_STR_DESC         = 5;
	PLUGIN_INDEX_STR_AUTHOR       = 6;
	PLUGIN_INDEX_STR_PATH         = 7;
	PLUGIN_INDEX_STR_CACHEABLE    = 8;
	_PLUGIN_INDEX_OBJ_PLUGIN_DATA = 9;
	PLUGIN_INDEX_OBJ_USERSETTINGS = 10;
	_PLUGIN_INDEX_MAX             = 10;

var
	pluginRegistry: TStringList;
	_multiDataKeys: TStringList;
	_cacheAfterMatchPlugins: TStringList;
	
{Initializes the plugin system}
procedure init();
var
	i,j: Integer;
	tmpLst: TStringList;
	path, pluginId, pluginName: String;
	pluginIni: TIniFile;
begin
	//cleanup();
	
	// Register multiarray keys
	_multiDataKeys := TStringList.Create;
	_multiDataKeys.add('PluginRulesAfterMatch');
	_multiDataKeys.add('PluginScript');
	
	// Setup
	pluginRegistry := TStringList.Create;
	_cacheAfterMatchPlugins := TStringList.Create;
	
	// Read directory
	// CreateOleObject();
	tmpLst := _readDirectory();
	for i := 0 to tmpLst.Count -1 do begin
		path := sComplexSorterBasePath+'Plugins\'+tmpLst[i];
		// Read
		pluginIni := TIniFile.Create(path);
		
		pluginId := pluginIni.ReadString('Plugin','id','');
		pluginName := pluginIni.ReadString('Plugin','name','');

		// Register data
		try
			pluginRegistry.addObject(pluginId, _createPluginDataFromIniFile(pluginIni, path));
		except
			on E: Exception 
				do ShowMessage('Plugin file "'+path+'" is not valid:'+#10#13+E.Message);
			continue;
		end;

		// Done
		pluginIni.Free;
		AddMessage('Plugin registered: '+pluginName + ' (ID: '+pluginId+')');
		end;
		
	CSPluginScript.init();
end;


{Returns all active plugins after-match-rules}
function getPluginRuleSetsWithAfterMatchRules(recordType:String):TStringList;
var
	i,index:Integer;
	plugin, ruleSetSectionRaw, amrProcRuleSetSection: TStringList;
	pluginId: String;
begin
	// Cached?
	index := _cacheAfterMatchPlugins.indexOf(recordType);
	if index > -1 then begin
		Result := _cacheAfterMatchPlugins.Objects[index];
		Exit;
		end;

	// Build
	Result := TStringList.Create;
	for i:= 0 to pluginRegistry.Count -1 do begin
		plugin := pluginRegistry.Objects[i];
		pluginId := plugin.values['id'];
		if (plugin.values['active'] = 'true') and (plugin.values['type'] = 'pluginRecordModifier' ) then begin
			ruleSetSectionRaw := _getPluginMultiDataList(plugin, 'PluginRulesAfterMatch', recordType);
			if Assigned(ruleSetSectionRaw) then begin
				// We need parsed rules here. Let CustomRuleSets do all necessary
				if not Assigned(CustomRuleSets.getCustomProcessingRuleSet('PLUGIN_'+pluginId,recordType)) then begin
					_preparseShortPluginNotation(pluginId, plugin, ruleSetSectionRaw);
					// Add Processing set to registry
					CustomRuleSets.addProcessingRuleSetSection('PLUGIN_'+pluginId,recordType,ruleSetSectionRaw);
					end;
				// Prefetch rules and store in list 
				amrProcRuleSetSection := CustomRuleSets.getCustomProcessingRuleSet('PLUGIN_'+pluginId, recordType);
				if Assigned(amrProcRuleSetSection) then 
					Result.addObject('PLUGIN_'+pluginId+'>'+recordType,amrProcRuleSetSection);
				end;
			end;
		end
	_cacheAfterMatchPlugins.addObject(recordType,Result);
end;

{Preparses the locale plugin script ruleset for short notations}
procedure _preparseShortPluginNotation(pluginId:String; plugin:TStringList; ruleSetSectionRaw:TStringList);
var 
	j,k: Integer;
	userSettings: TStringList;
	pluginScript, wholeRuleLine: String;
begin
	// Allow easier notations in local scripts 
	for j := 0 to ruleSetSectionRaw.Count -1 do begin
		// Allow short form PluginScript:*
		if BeginsWithExtract('PluginScript:',ruleSetSectionRaw.ValueFromIndex[j],pluginScript) then
			ruleSetSectionRaw.ValueFromIndex[j] := 'SPECIAL:PluginScript:'+pluginId+':'+pluginScript;
		// Allow short notation of locale plugin settings as $settingName
		if Pos('$',ruleSetSectionRaw[j]) <> 0 then begin
			userSettings := plugin.Objects[PLUGIN_INDEX_OBJ_USERSETTINGS];
			wholeRuleLine := ruleSetSectionRaw[j];
			for k := 0 to userSettings.Count -1 do
				if userSettings.Objects[k].values['basetype'] = 'setting' then 
					wholeRuleLine := StringReplace(wholeRuleLine
						,'$'+userSettings[k],'SPECIAL:PluginSetting:'+pluginId+':'+userSettings[k],[rfReplaceAll]);
			ruleSetSectionRaw[j] := wholeRuleLine;
			end;
		end;
						

end;

{Returns the registered plugins multidata list}
function _getPluginMultiDataList(plugin:TStringList;const multiDataKey:String;const sectionKey:String):TStringList;
var
	index, index2: Integer;
	multiDataLst: TStringList;
begin
	Result := nil;
	index := plugin.indexOf(multiDataKey);
	if index > -1 then begin
		multiDataLst := plugin.Objects[index];
		index2 := multiDataLst.indexOf(sectionKey);
		if index2 > -1 then
			Result := multiDataLst.Objects[index2];
		end;
end;

{Returns a plugin}
function getPluginObj(const pluginId:String):TStringList;
var index:Integer;
begin
	index := pluginRegistry.indexOf(pluginId);
	if ( index > -1 ) then
		Result := pluginRegistry.Objects[index]
	else
		AddMessage('Unknown plugin: '+pluginId);
end;


{Returns a user setting of a plugin as string}
function getPluginUserSetting(const pluginId:String;const settingName:String):String;
var
	usIndex:Integer;
	plugin, settingConfig, userSettings:TStringList;
begin
	plugin := getPluginObj(pluginId);
	if Assigned(plugin) then begin
		userSettings := plugin.Objects[PLUGIN_INDEX_OBJ_USERSETTINGS];
		usIndex := userSettings.indexOf(settingName);
		if usIndex = -1 then
			AddMessage('Warning: Unknown user setting "'+settingName+'" for plugin "'+pluginId+'".')
		else begin
			settingConfig := userSettings.Objects[usIndex];
			Result := settingConfig.values['default'];
			if settingConfig.values['type'] = 'bool' then begin
				if getSettingsBoolean('plugin.'+pluginId+'.'+settingName) then
					Result := 'true'
				else
					Result := 'false';
				end
			else if settingConfig.values['type'] = 'int' then
				Result := IntToStr(getSettingsInteger('plugin.'+pluginId+'.'+settingName,StrToInt(settingConfig.values['default'])))
			else if settingConfig.values['type'] = 'float' then
				Result := FloatToStr(getSettingsFloat('plugin.'+pluginId+'.'+settingName,StrToFloat(settingConfig.values['default'])))
			else if settingConfig.values['type'] = 'string' then
				Result := getSettingsString('plugin.'+pluginId+'.'+settingName,settingConfig.values['default'])
			else
				AddMessage('Unknown plugin user setting type "'+settingConfig.values['type']+'" for plugin "'+pluginId+'"');
			end;
		end;
end;


{Returns all possible user settings as merged string}
function _getPluginUserSettingsMerged(const pluginId:String):String;
var
	i:Integer;
	plugin, userSettings: TStringList;
begin
	plugin := getPluginObj(pluginId);
	if Assigned(plugin) then begin
		userSettings := plugin.Objects[PLUGIN_INDEX_OBJ_USERSETTINGS];
		for i := 0 to userSettings.Count -1 do begin
			if userSettings.Objects[i].values['basetype'] = 'setting' then
				Result := Result + getPluginUserSetting(pluginId,userSettings[i]) + ',';
			end;
		end;
end;


{Constructs and adds a validation string for the cache system. Returns if cachable as bool}
function addPluginCacheValidationStr(const pluginId:String;const pluginScriptName:String;var addToStr:String):Boolean;
var
	plugin: TStringList;
	cacheValStr: String;
begin
	plugin:= getPluginObj(pluginId);
	if Assigned(plugin) then
		if plugin.values['cachable'] = 'true' then begin
			cacheValStr := plugin.values['cacheValStr']; 
			// Cache in plugin storage
			if cacheValStr = '' then begin
				cacheValStr := '|ps:'+pluginId+':' // + pluginScriptName have no impact yet
					+ _getPluginUserSettingsMerged(pluginId)
					+ _getPluginCRC32(pluginId);
				plugin.values['cacheValStr'] := cacheValStr;
				// AddMessage('cachevalstr for '+pluginId+'>'+pluginScriptName+': '+cacheValStr);
				end;
			addToStr := addToStr + cacheValStr;
			Result := true;
			end;
end;


{Returns the crc32 checksum of plugin definition file}
function _getPluginCRC32(const pluginId:String):String;
var plugin: TStringList;
begin
	plugin := getPluginObj(pluginId);
	if Assigned(plugin) then begin
		Result := wbCRC32File(plugin.values['path']);
	end;
end;

{Returns the definitions of user settings in parsed form}
function _parseUserSettingDefinitions(const pluginId:String; userSettingsRaw:TStringList):TStringList;
var
	i,j,iPosm, iIndex: Integer;
	settingKey,settingPropName,sRawValue,tmpStr: String;
	formElms, userSettings, settingConfig,tmpLst:TStringList;
begin
	Result := TStringList.Create;
	formElms := TStringList.Create;
	userSettings := TStringList.Create;
	for i := 0 to userSettingsRaw.Count -1 do begin
		sRawValue := userSettingsRaw.ValueFromIndex[i];
		if not SplitSimple(':',userSettingsRaw.Names[i],settingKey,settingPropName) then begin
			if userSettings.indexOf(settingKey) > -1 then
				raise Exception.Create('Invalid plugin file');
			settingConfig := TStringList.Create;
			userSettings.addObject(settingKey, settingConfig);
			if BeginsWithExtract('form:',sRawValue,tmpStr) then
				settingConfig.values['basetype'] := 'form'
			else if BeginsWithExtract('setting:',sRawValue,tmpStr) then
				settingConfig.values['basetype'] := 'setting'
			else
				raise Exception.Create('Invalid plugin file syntax: "'+sRawValue+'" - type setting invalid');
			// Fill quick props
			tmpLst := Split(':', tmpStr);
			if tmpLst.Count > 0 then
				settingConfig.values['type'] := tmpLst[0];

			// Quick config for settings
			if settingConfig.values['basetype'] = 'setting' then begin 
				if tmpLst.Count > 1 then
					settingConfig.values['default'] := tmpLst[1];
				if tmpLst.Count > 2 then
					settingConfig.values['name'] := tmpLst[2];
				if tmpLst.Count > 3 then
					settingConfig.values['hint'] := tmpLst[3];
				end;
			
			// Quick config for form elements
			if settingConfig.values['basetype'] = 'form' then begin 
				if tmpLst.Count > 1 then
					settingConfig.values['text'] := tmpLst[1];
				end;
			tmpLst.Free;

			end
		else begin
			iIndex := userSettings.indexOf(settingKey);
			if iIndex = -1 then
				raise Exception.Create('Invalid plugin file syntax at "'+sRawValue+'" - invalid setting declaration/order');
			userSettings.Objects[iIndex].values[settingPropName] := sRawValue;
			end;
		end;
	// Set default booleans 
	for i := 0 to userSettings.Count -1 do
		if userSettings.Objects[i].Values['type'] = 'bool' then
			scDefaults.values['plugin.'+pluginId+'.'+userSettings[i]] := userSettings.Objects[i].values['default'] = 'true';

	Result := userSettings;
end;


{Returns the plugin scripts MultiDataList item}
function getPluginScripts(const pluginId:String ):TStringList;
var 	
	plugin: TStringList;
begin
	plugin := getPluginObj(pluginId);
	if Assigned(plugin) then begin
		if plugin.indexOf('PluginScript') > -1 then 			
			Result := plugin.Objects[plugin.indexOf('PluginScript')];
		end;
end;

{Apply a plugin script}
function applyPluginScript(const pluginIdAndScript:String; var saveRecord:Boolean; var ruleApplyTag:String; 
	sTag:String; var madeModifications:Boolean):Boolean;
var
	tmpLst, plugin, pluginScript: TStringList;
	pluginId, pluginScriptName: String;
begin
	// Result = true for continue processing chain, false will apply ruleApplyTag to item
	Result := true;
	tmpLst := Split(':', pluginIdAndScript);
	pluginId := tmpLst[0];
	pluginScriptName := tmpLst[1];
	tmpLst.Free;
	
	plugin := getPluginObj(pluginId);
	if Assigned(plugin) then begin
		// Get script
		pluginScript := _getPluginMultiDataList(plugin, 'PluginScript', pluginScriptName);
		if not Assigned(pluginScript) then
			AddMessage('Warning: Unknown script "'+pluginScriptName+'" for plugin "'+pluginId+'"')
		else begin
			try
				// Execute
				Result := CSPluginScript.applyScriptLines(pluginScript,pluginId,pluginIdAndScript,saveRecord,ruleApplyTag,sTag, madeModifications);
			except
				on E: Exception do
					AddMessage('Error while running plugin "'+pluginId+'" script "'+pluginScriptName+'": '+E.Message);
				end;
			end
		end;
end;

{Reads ini data into list structure}
function _createPluginDataFromIniFile(pluginIni:TIniFile;path:String):TStringList;
var
	i,j: Integer;
	tmpLst1,tmpLst2, dataLst, parsedSectionRules: TStringList;
	pluginId, sectionName, secName, multiDataKey: String;
begin
	tmpLst1 := TStringList.Create;
	Result := TStringList.Create;
	pluginId := pluginIni.ReadString('Plugin','id','');

	// Basic data
	dataLst := TStringList.Create;
	pluginIni.readSectionValues('Plugin', dataLst);
	
	// Store generics:
	Result.add('id='+pluginId); // PLUGIN_INDEX_STR_ID
	Result.add('active='+BoolToStr(getSettingsBoolean('plugin.'+pluginId+'.active'))); // PLUGIN_INDEX_STR_ACTIVE
	Result.add('activeDefault='+dataLst.values['activeDefault']); // PLUGIN_INDEX_STR_ACTIVE_DEFAULT
	scDefaults.values['plugin.'+pluginId+'.active'] := dataLst.values['activeDefault'] = 'true';
	Result.add('type='+dataLst.values['type']); // PLUGIN_INDEX_STR_TYPE
	Result.add('name='+dataLst.values['name']); // PLUGIN_INDEX_STR_NAME
	Result.add('desc='+dataLst.values['desc']); // PLUGIN_INDEX_STR_DESC
	Result.add('author='+dataLst.values['author']); // PLUGIN_INDEX_STR_AUTHOR
	Result.values['path'] := path; // PLUGIN_INDEX_STR_PATH
	Result.add('cachable='+dataLst.values['cachable']); // PLUGIN_INDEX_STR_CACHEABLE
	
	// Store simple data lists
	Result.addObject('Plugin', dataLst); // _PLUGIN_INDEX_OBJ_PLUGIN_DATA

	dataLst := TStringList.Create;
	pluginIni.readSectionValues('PluginSettings', dataLst);
	Result.addObject('PluginSettings', _parseUserSettingDefinitions(pluginId, dataLst)); // PLUGIN_INDEX_OBJ_USERSETTINGS
	dataLst.Free;

	// Store multi data lists
	pluginIni.ReadSections(tmpLst1);

	for j := 0 to tmpLst1.Count -1 do begin
		sectionName := tmpLst1[j];
		for i := 0 to _multiDataKeys.Count -1 do begin
			multiDataKey := _multiDataKeys[i];
			if Pos(multiDataKey+':',sectionName) = 1 then begin
				secName := Copy(sectionName,Length(multiDataKey+':')+1,1000);
				if Result.indexOf(multiDataKey) = -1 then
					Result.addObject(multiDataKey, TStringList.Create);
				tmpLst2 := TStringList.Create;
				pluginIni.ReadSectionValues(sectionName, tmpLst2);
				Result.Objects[Result.indexOf(multiDataKey)].addObject(secName, tmpLst2);
				end;
			end;
		end;
	tmpLst1.Free;
end;

{Reads the plugin inis}
function _readDirectory():TStringList;
var Info : TSearchRec;
begin
	Result := TStringList.Create;
	
	FindFirst(sComplexSorterBasePath+'Plugins\*.ini',faAnyFile,Info);
	if Info.Name <> '' then begin
		Result.add(Info.Name);
		while FindNext(Info) = 0 do begin
			Result.add(Info.Name);
			end;
		end;
End;

{cleanup plugin data}
procedure _cleanupPlugin(plugin:TStringList);
var
	i,j,index: Integer;
	multiDataKey: String;
	multiDataLst: TStringList;
begin
	// Reverse order for clearing

	// Clear simple data lists
	for i := 0 to plugin.Objects[PLUGIN_INDEX_OBJ_USERSETTINGS].Count -1 do
		plugin.Objects[PLUGIN_INDEX_OBJ_USERSETTINGS].Objects[i].Free;
	plugin.Objects[PLUGIN_INDEX_OBJ_USERSETTINGS].Free;
	plugin.Objects[_PLUGIN_INDEX_OBJ_PLUGIN_DATA].Free;
	
	// Clear multi data lists
	for i := 0 to _multiDataKeys.Count -1 do begin
		multiDataKey := _multiDataKeys[i];
		index := plugin.indexOf(multiDataKey);
		if index > -1 then begin
			multiDataLst := plugin.Objects[index];
			for j := 0 to multiDataLst.Count -1 do
				multiDataLst.Objects[j].Free;
			multiDataLst.Free;
			plugin.delete(index);
			end;
		end;
	
	
	if plugin.indexOfName('cacheValStr') > -1 then 
		plugin.delete( plugin.indexOfName('cacheValStr') );
		
	// Check and clear fixed slots alltogether
	if plugin.Count <> _PLUGIN_INDEX_MAX + 1 then
		AddMessage('Plugin is still dirty!');
	plugin.Free;
	
end;

{Cleanup}
procedure cleanup();
var i:Integer;
begin
	if Assigned(pluginRegistry) then
		for i := 0 to pluginRegistry.Count -1 do
			_cleanupPlugin(pluginRegistry.Objects[i]);
	FreeAndNil(pluginRegistry);
	if Assigned(_cacheAfterMatchPlugins) then
		for i := 0 to _cacheAfterMatchPlugins.Count -1 do
			_cacheAfterMatchPlugins.Objects[i].Free;
	FreeAndNil(_cacheAfterMatchPlugins);
	FreeAndNil(_multiDataKeys);
	CSPluginScript.cleanup();
end;

end.
