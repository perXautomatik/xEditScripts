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
	PLUGIN_INDEX_STR_VISIBLE_DEFAULT = 9;
	PLUGIN_INDEX_STR_REQ_RECTYPES = 10;
	PLUGIN_INDEX_STR_REQ_FILES    = 11;
	PLUGIN_INDEX_STR_REQ_PLUGINS  = 12;
	_PLUGIN_INDEX_OBJ_PLUGIN_DATA = 13;
	PLUGIN_INDEX_OBJ_USERSETTINGS = 14;
	_PLUGIN_INDEX_MAX             = 14;

var
	pluginRegistry: TStringList;
	// Private
	_multiDataKeys: TStringList;
	_cacheAfterMatchPlugins: TStringList;
	_cachePluginReqsCheck: TStringList;
	_cachePluginReqsLastTags: String;
	
{Initializes the plugin system}
procedure init();
var
	i,j: Integer;
	tmpLst, lstTasks, plugin: TStringList;
	path, pluginId, tmpStr1, tmpStr2: String;
	pluginIni: TIniFile;
begin
	cleanup();
	
	// Register multiarray keys
	_multiDataKeys := TStringList.Create;
	_multiDataKeys.add('PluginRulesAfterMatch');
	_multiDataKeys.add('PluginRulesBeforeMain');
	_multiDataKeys.add('PluginRulesBeforeAll');
	_multiDataKeys.add('PluginAddInnrRules');
	_multiDataKeys.add('PluginReplaceInnrRules');
	_multiDataKeys.add('PluginScript');
	
	// Setup
	pluginRegistry := TStringList.Create;
	_cacheAfterMatchPlugins := TStringList.Create;
	_cachePluginReqsCheck := THashedStringList.Create;
	
	// Native special plugins
	
	// Read directory
	tmpLst := _readDirectories();
	
	for i := 0 to tmpLst.Count -1 do begin
		path := tmpLst[i];
		// Read
		pluginIni := TIniFile.Create(path);
		
		pluginId := pluginIni.ReadString('Plugin','id','');
		if pluginId = '' then begin
			AddMessage('Invalid plugin file: '+path);
			continue;
			end;
			
		
		if pluginRegistry.indexOf(pluginId) > -1 then begin 
			AddMessage('WARNING: Duplicate plugin id: '+pluginId);
			continue;
			end;
		
		// Read tasks
		if pluginIni.SectionExists('Tasks') then begin 
			lstTasks := TStringList.Create;
			pluginIni.ReadSectionValues('Tasks',lstTasks);
			for j := 0 to lstTasks.Count -1 do
				if SplitSimple(':',lstTasks.Names[j],tmpStr1,tmpStr2) then begin
					if tmpStr2 = 'name' then 
						Tasks.registerTask(tmpStr1, lstTasks.ValueFromIndex[j]);
					end;
				
			lstTasks.Free;
			end;

		// Create plugin and register data
		try
			plugin := _createPluginDataFromIniFile(pluginIni, path);
			if plugin.Values['type'] = 'pluginSpecial' then 
				pluginRegistry.insertObject(0,pluginId, plugin)
			else
				pluginRegistry.addObject(pluginId, plugin);
			AddMessage('Plugin registered: '+plugin.Values['name'] + ' (ID: '+pluginId+')');
		except
			on E: Exception 
				do ShowMessage('Plugin file "'+path+'" is not valid:'+#10#13+E.Message);
			continue;
		end;

		// Done
		pluginIni.Free;
		end;
	
	CSPluginScript.init();
	// Cleanup
	tmpLst.Free;
end;


{Adds the innr rules by all active plugins to the dynamic names registry}
procedure getInnrRulesByPlugins();
var
	i,j,index:Integer;
	plugin, multiDataLst: TStringList;
begin
	// List replacing function
	for i:= 0 to pluginRegistry.Count -1 do begin
		plugin := pluginRegistry.Objects[i];
		if (plugin.values['active'] = 'true') and (plugin.values['type'] = 'pluginRecordModifier' )
			and checkPluginRequirements(plugin.values['id']) then begin
			index := plugin.indexOf('PluginReplaceInnrRules');
			if index > -1 then begin
				multiDataLst := plugin.Objects[index];
				for j := 0 to multiDataLst.Count - 1 do
					INNRProcessing.replaceModNamingRules(multiDataLst[j],multiDataLst.Objects[j]);
				end
			end
		end;

	// List extending function
	for i:= 0 to pluginRegistry.Count -1 do begin
		plugin := pluginRegistry.Objects[i];
		if (plugin.values['active'] = 'true') and (plugin.values['type'] = 'pluginRecordModifier' )
			and checkPluginRequirements(plugin.values['id']) then begin
			index := plugin.indexOf('PluginAddInnrRules');
			if index > -1 then begin
				multiDataLst := plugin.Objects[index];
				for j := 0 to multiDataLst.Count - 1 do
					INNRProcessing.storeModNamingRules(multiDataLst[j],multiDataLst.Objects[j]);
				end
			end
		end;
end;

{Returns a rule set from all active plugins }
function getPluginRuleSets(taskIdent, ruleSectionPrefix, recordType:String):TStringList;
var
	i,index:Integer;
	plugin, ruleSetSectionRaw, amrProcRuleSetSection, tmpLst: TStringList;
	pluginId, ruleSetPrefix, intCacheKey: String;
begin
	// Cached?
	intCacheKey := taskIdent+':'+ruleSectionPrefix+':'+recordType;
	index := _cacheAfterMatchPlugins.indexOf(intCacheKey);
	if index > -1 then begin
		Result := _cacheAfterMatchPlugins.Objects[index];
		Exit;
		end;
	// Build
	Result := TStringList.Create;
	for i:= 0 to pluginRegistry.Count -1 do begin
		plugin := pluginRegistry.Objects[i];
		pluginId := plugin.values['id'];
		if (plugin.values['active'] = 'true') and (plugin.values['type'] = 'pluginRecordModifier' ) 
			and checkPluginRequirements(plugin.values['id']) then begin
			ruleSetSectionRaw := _getPluginMultiDataList(plugin, ruleSectionPrefix, 'TASK='+taskIdent+':'+recordType);
			if not Assigned(ruleSetSectionRaw) and (taskIdent = 'ItemSorterTags') then
				ruleSetSectionRaw := _getPluginMultiDataList(plugin, ruleSectionPrefix, recordType);
			if Assigned(ruleSetSectionRaw) then begin
				ruleSetPrefix := RULESETS_IDENTIFIER_PLUGIN_RULES+ruleSectionPrefix+':'+pluginId;
				// We need parsed rules here. Let CustomRuleSets do all necessary
				if not Assigned(CustomRuleSets.getProcessingRuleSetSection(taskIdent,ruleSetPrefix,recordType)) then begin
					tmpLst := TStringList.Create;
					tmpLst.Assign(ruleSetSectionRaw);
					_preparseShortPluginNotation(pluginId, plugin, tmpLst);
					// Add Processing set to registry
					CustomRuleSets.addProcessingRuleSetSection(taskIdent,ruleSetPrefix,recordType,tmpLst);
					// Add to known file list
					crsRuleSetIniFiles.Values[taskIdent+ruleSetPrefix] := plugin.ValueFromIndex[PLUGIN_INDEX_STR_PATH];
					tmpLst.Free;
					end;
				// Prefetch rules and store in list 
				amrProcRuleSetSection := CustomRuleSets.getProcessingRuleSetSection(taskIdent,ruleSetPrefix, recordType);
				if Assigned(amrProcRuleSetSection) then 
					Result.addObject(taskIdent+ruleSetPrefix+'>'+recordType,amrProcRuleSetSection);
				end;
			end;
		end
	_cacheAfterMatchPlugins.addObject(intCacheKey,Result);
end;

{Preparses the locale plugin script ruleset for short notations}
procedure _preparseShortPluginNotation(pluginId:String; plugin:TStringList; ruleSetSectionRaw:TStringList);
var 
	j,k: Integer;
	userSettings: TStringList;
	pluginScript, wholeRuleLine, sMustMatchBool, sLstText, sNewCondition: String;
	bFlagFoundNothing, bFlagContainSettings, bFlagContainScripts: Boolean;
	reg:TPerlRegEx;
begin
	// Find things
	sLstText := sLineBreak+ruleSetSectionRaw.Text+sLineBreak;
	bFlagContainSettings := Pos('$', sLstText) <> 0;
	bFlagContainScripts := Pos('PluginScript:', sLstText) <> 0;

	// Nothing todo?
	if not bFlagContainSettings and not bFlagContainScripts then 
		Exit;
	

	// Pre-evaluating simple bool switcher
	if bFlagContainSettings then begin
		while not bFlagFoundNothing do begin
			reg:= TPerlRegEx.Create;
			reg.Subject := sLstText;
			reg.RegEx := '('+sLineBreak+'|,)\s*((?:not )?)\$([a-zA-Z0-9_]+)\s*(?:equals true)?(,\s*|=)';
			if not reg.Match() then 
				bFlagFoundNothing := true
			else begin 
				if reg.Groups[2] <> '' then 
					sMustMatchBool := 'false'
				else sMustMatchBool := 'true';
				if getPluginUserSetting(pluginId, reg.Groups[3]) <> sMustMatchBool then // Always false -> drop rule
					sNewCondition := reg.Groups[1]+'FALSIFIED_RULE'+reg.Groups[4]
				else if reg.Groups[4] = '=' then // 2 x always true -> Simplify
					sNewCondition := reg.Groups[1] + '*=' // Adding * if we replaced a '='
				else
					sNewCondition := reg.Groups[1]; // ',' should be removed
				sLstText := StringReplace(sLstText,reg.Groups[0],sNewCondition,[rfReplaceAll]);
				reg.Free;
				end;
			end;
		
		// Remove falsified rules
		sLstText := PregReplace(sLineBreak+'[^\n\r]*FALSIFIED_RULE[^\n\r]*(?='+sLineBreak+')','',sLstText);
	
		// Replace short notations of $settings to processable form
		userSettings := plugin.Objects[PLUGIN_INDEX_OBJ_USERSETTINGS];
		for k := 0 to userSettings.Count -1 do
			if userSettings.Objects[k].values['basetype'] = 'setting' then
				sLstText := StringReplace(sLstText
					,'$'+userSettings[k],'SPECIAL:PluginSetting:'+pluginId+':'+userSettings[k],[rfReplaceAll]);
		end;

	// Allow short form PluginScript:*
	if bFlagContainScripts then
		sLstText := PregReplace('(?<!:)PluginScript:','SPECIAL:PluginScript:'+pluginId+':',sLstText);
			
	ruleSetSectionRaw.Text := Trim(sLstText);						

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
function applyPluginScript(const pluginIdAndScript:String; var saveRecord:Boolean; var sSetNewTagIdentByScript:String; 
	sTag:String; var madeModifications:Boolean):Boolean;
var
	tmpLst, plugin, pluginScript: TStringList;
	pluginId, pluginScriptName: String;
begin
	// Result = true for continue processing chain, false will apply sSetNewTagIdentByScript to item
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
				Result := CSPluginScript.applyScriptLines(pluginScript,pluginId,pluginIdAndScript,saveRecord,sSetNewTagIdentByScript,sTag, madeModifications);
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
	Result.add('active=False'{+BoolToStr(getSettingsBoolean('plugin.'+pluginId+'.active'))}); // PLUGIN_INDEX_STR_ACTIVE
	Result.add('activeDefault='+dataLst.values['activeDefault']); // PLUGIN_INDEX_STR_ACTIVE_DEFAULT
	// Store global default for plugin activeness
	scDefaults.values['plugin.'+pluginId+'.active'] := dataLst.values['activeDefault'] = 'true';
	Result.add('type='+dataLst.values['type']); // PLUGIN_INDEX_STR_TYPE
	Result.add('name='+dataLst.values['name']); // PLUGIN_INDEX_STR_NAME
	Result.add('desc='+dataLst.values['desc']); // PLUGIN_INDEX_STR_DESC
	Result.add('author='+dataLst.values['author']); // PLUGIN_INDEX_STR_AUTHOR
	Result.values['path'] := path; // PLUGIN_INDEX_STR_PATH
	Result.add('cachable='+dataLst.values['cachable']); // PLUGIN_INDEX_STR_CACHEABLE
	Result.add('visibleDefault='+dataLst.values['visibleDefault']); // PLUGIN_INDEX_STR_VISIBLE_DEFAULT
	// Store global default for plugin visibility
	scDefaults.values['plugin.'+pluginId+'.visible'] := dataLst.values['visibleDefault'] = 'true';

	// Store more 
	Result.add('requiredRecordTypes='+dataLst.values['requiredRecordTypes']); // PLUGIN_INDEX_STR_REQ_RECTYPES
	Result.add('requiredFiles='+dataLst.values['requiredFiles']); // PLUGIN_INDEX_STR_REQ_FILES
	Result.add('requiredPlugins='+dataLst.values['requiredPlugins']); // PLUGIN_INDEX_STR_REQ_PLUGINS
	
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

{Read plugin activness from settings}
procedure readPluginActiveFromSettings();
var 
	i: Integer;
begin
	for i:=0 to pluginRegistry.Count -1 do
		pluginRegistry.Objects[i].Values['active'] := BoolToStr(getSettingsBoolean('plugin.'+pluginRegistry.Objects[i].Values['id']+'.active'));
	_cachePluginReqsCheck.Clear();
end;


{Reads the plugin inis}
function _readDirectories():TStringList;
var 
	Info : TSearchRec;
	Info2 : TSearchRec; // Need second pointer, because the first cant be reseted...
	lst: TStringList;
	i: Integer;
begin

	lst := TStringList.Create;

	Result := TStringList.Create;
	// Search scripts folder
	FindFirst(sComplexSorterBasePath+'Plugins\*.ini',faAnyFile,Info);
	if Info.Name <> '' then begin
		// Result.add(sComplexSorterBasePath+'Plugins\'+Info.Name);
		lst.Values[Info.Name] := sComplexSorterBasePath+'Plugins\'+Info.Name;
		while FindNext(Info) = 0 do begin
			// Result.add(sComplexSorterBasePath+'Plugins\'+Info.Name);
			lst.Values[Info.Name] := sComplexSorterBasePath+'Plugins\'+Info.Name;
			end;
		end;

	// Search fo4 data folder 
	FindFirst(sComplexSorterFo4DataPath+'Plugins\*.ini',faAnyFile,Info2);
	if Info2.Name <> '' then begin
		// Result.add(sComplexSorterFo4DataPath+'Plugins\'+Info2.Name);
		if lst.Values[Info2.Name] <> '' then 
			AddMessage('WARNING: Conflicting plugin files:'+#10#13+' '+lst.Values[Info2.Name]+' (IGNORED)'+#10#13+' '+sComplexSorterFo4DataPath+'Plugins\'+Info2.Name+' (USED)');
			
		lst.Values[Info2.Name] := sComplexSorterFo4DataPath+'Plugins\'+Info2.Name;
		while FindNext(Info2) = 0 do begin
			if lst.Values[Info2.Name] <> '' then 
				AddMessage('WARNING: Conflicting plugin files:'+#10#13+' '+lst.Values[Info2.Name]+' (IGNORED)'+#10#13+' '+sComplexSorterFo4DataPath+'Plugins\'+Info2.Name+' (USED)');
			// Result.add(sComplexSorterFo4DataPath+'Plugins\'+Info2.Name);
			lst.Values[Info2.Name] := sComplexSorterFo4DataPath+'Plugins\'+Info2.Name;
			end;
		end;
	
	// Sorting plugins for names
	// AddMessage(lst.CommaText);
	lst.Sort();
	for i:= 0 to lst.Count -1 do 
		Result.Add(lst.ValueFromIndex[i]);
	lst.Free;
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

{Check requirements for plugin}
function checkPluginRequirements(pluginId:String):Boolean;
var 	
	plugin, tmpLst: TStringList;
	i: Integer;
begin
	// Clear cache? 
	if _cachePluginReqsLastTags <> lstUseRecordTypes.CommaText then begin
		_cachePluginReqsCheck.Clear();
		_cachePluginReqsLastTags := lstUseRecordTypes.CommaText;
		end;
	// Use cache? 
	if _cachePluginReqsCheck.indexOfName(pluginId) <> -1 then begin
		Result := _cachePluginReqsCheck.Values[pluginId];
		Exit;
		end;
		
	plugin := getPluginObj(pluginId);
	if not Assigned(plugin) then 
		Exit;
	Result := True;
	
	// Check required record types
	if checkPluginRequirementRecordTypes(pluginId) <> '' then 
		Result := false;

	// Check required files 
	if checkPluginRequirementFiles(pluginId) <> '' then 
		Result := false;
	
	// Check required files 
	if checkPluginRequirementPlugins(pluginId) <> '' then 
		Result := false;
	
	_cachePluginReqsCheck.Values[pluginId] := Result;
end;

{Check record types requirements for plugin}
function checkPluginRequirementRecordTypes(pluginId:String):String;
var 	
	plugin, tmpLst1, tmpLst2: TStringList;
	i, j: Integer;
	flagAllFound: Boolean;
begin
	plugin := getPluginObj(pluginId);
	if not Assigned(plugin) then 
		Exit;
	Result := '';
	
	// Check required record types
	if plugin.Values['requiredRecordTypes'] <> '' then begin 
		tmpLst1 := TStringList.Create;
		tmpLst1.StrictDelimiter := True;
		tmpLst1.CommaText := plugin.Values['requiredRecordTypes'];
		tmpLst2 := TStringList.Create;
		tmpLst2.Delimiter := '+';
		tmpLst2.StrictDelimiter := True;
		
		for i := 0 to tmpLst1.Count - 1 do begin
			tmpLst2.DelimitedText := tmpLst1[i];
			flagAllFound := true;
			for j := 0 to tmpLst2.Count - 1 do 
				if lstUseRecordTypes.indexOf(tmpLst2[j]) = -1 then 
					flagAllFound := false;
			if flagAllFound then begin 
				// One group is enough!
				Exit;
				end;
			end;
		tmpLst1.Free;
		tmpLst2.Free;
		
		Result := 'Uses record types: '+plugin.Values['requiredRecordTypes'];
		end;

end;

{Check files requirements for plugin}
function checkPluginRequirementFiles(pluginId:String):String;
var 	
	plugin, tmpLst1, tmpLst2: TStringList;
	i, j: Integer;
	flagAllFound: Boolean;
begin
	plugin := getPluginObj(pluginId);
	if not Assigned(plugin) then 
		Exit;
	Result := '';

	// Check required files 
	{if plugin.Values['requiredFiles'] <> '' then begin 
		tmpLst := TStringList.Create;
		tmpLst.StrictDelimiter := True;
		tmpLst.CommaText := plugin.Values['requiredFiles'];
		for i := 0 to tmpLst.Count - 1 do 
			if not Assigned(FileByName(tmpLst[i])) then 
				Result := Result + 'Missing file: '+tmpLst[i]+' ';
		tmpLst.Free;
		end;}
	// Check required record types
	if plugin.Values['requiredFiles'] <> '' then begin 
		tmpLst1 := TStringList.Create;
		tmpLst1.StrictDelimiter := True;
		tmpLst1.CommaText := plugin.Values['requiredFiles'];
		tmpLst2 := TStringList.Create;
		tmpLst2.Delimiter := '+';
		tmpLst2.StrictDelimiter := True;
		
		for i := 0 to tmpLst1.Count - 1 do begin
			tmpLst2.DelimitedText := tmpLst1[i];
			flagAllFound := true;
			for j := 0 to tmpLst2.Count - 1 do 
				if not Assigned(FileByName(tmpLst2[j])) then 
					flagAllFound := false;
			if flagAllFound then begin 
				// One group is enough!
				Exit;
				end;
			end;
		tmpLst1.Free;
		tmpLst2.Free;
		
		Result := 'Missing plugins: '+plugin.Values['requiredFiles'];
		end;

		
end;

{Check plugins requirements for plugin}
function checkPluginRequirementPlugins(pluginId:String):String;
var 	
	plugin,plugin2, tmpLst: TStringList;
	i: Integer;
begin
	plugin := getPluginObj(pluginId);
	if not Assigned(plugin) then 
		Exit;
	Result := '';

	// Check required files 
	if plugin.Values['requiredPlugins'] <> '' then begin 
		tmpLst := TStringList.Create;
		tmpLst.StrictDelimiter := True;
		tmpLst.CommaText := plugin.Values['requiredPlugins'];
		for i := 0 to tmpLst.Count - 1 do begin
			plugin2 := getPluginObj(tmpLst[i]);
			if not Assigned(plugin2) then 
				Result := Result + 'Missing plugin: '+tmpLst[i]+' '
			else if not plugin2.Values['active'] then
				Result := Result + 'Requires plugin: '+plugin2.Values['name']+' '
			end;
		tmpLst.Free;
		end;
		
end;

{Show in main gui?}
function getShowInMainGUI(pluginId:String):Boolean;
begin
	Result := ( getSettingsBoolean('plugin.'+pluginId+'.visible') 
			or  getSettingsBoolean('plugin.'+pluginId+'.active') )
			and (checkPluginRequirementFiles(pluginId)='');
end;

{Cleanup}
procedure cleanup();
var 
	i:Integer;
begin
	if Assigned(pluginRegistry) then
		for i := 0 to pluginRegistry.Count -1 do
			_cleanupPlugin(pluginRegistry.Objects[i]);
	FreeAndNil(pluginRegistry);
	if Assigned(_cacheAfterMatchPlugins) then
		for i := 0 to _cacheAfterMatchPlugins.Count -1 do
			_cacheAfterMatchPlugins.Objects[i].Free;
	FreeAndNil(_cacheAfterMatchPlugins);
	FreeAndNil(_cachePluginReqsCheck);
	FreeAndNil(_multiDataKeys);
	CSPluginScript.cleanup();
	cleanupCache();
end;

{Cleans the cache part for rulesets in plugins}
procedure cleanupCache();
var 
	i:Integer;
begin
	if Assigned(_cacheAfterMatchPlugins) then begin
		for i := 0 to _cacheAfterMatchPlugins.Count -1 do
			_cacheAfterMatchPlugins.Objects[i].Free;
		FreeAndNil(_cacheAfterMatchPlugins);
		_cacheAfterMatchPlugins := TStringList.Create;
		end;
end;

end.
