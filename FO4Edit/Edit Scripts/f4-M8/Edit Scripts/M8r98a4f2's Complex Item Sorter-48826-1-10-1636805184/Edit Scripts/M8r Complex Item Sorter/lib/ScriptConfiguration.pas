{
	M8r98a4f2s Complex Item Sorter for FallUI - ScriptConfiguration
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Module for storing and saving user settings
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit ScriptConfiguration;

var
	_scSettingsFilePath, _scSettingsIniSection: String;
	_scStorageToSaveValues,_scStorageToSaveType: THashedStringList;
	tagNames: THashedStringList;
	scDefaults: TStringList;


{unit init}
procedure init(setSection:String);
begin
	cleanup();
	_scSettingsFilePath := sComplexSorterBasePath+'Rules (User)\settings.ini';
	//_scSettingsFilePath := setConfigurationFile;
	_scSettingsIniSection := setSection;
	_scStorageToSaveValues := THashedStringList.Create;
	_scStorageToSaveType := THashedStringList.Create;
end;


function _getCleanSettingsKey(key:String):String;
begin
	Result := StringReplace(key, '=', '_MASKED_%EQUALS$_', [rfReplaceAll]);
end;

function hasSettingsBoolean(key:String):Boolean;
var 
	ini: TIniFile;
begin
	if _scStorageToSaveType.values[key] = 'Boolean' then begin
		Result := true;
		Exit;
		end;
	
	try
	ini := TIniFile.Create(_scSettingsFilePath);
	Result := ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key));
	finally
		ini.Free;	
	end;
end;


function getSettingsBoolean(key:String):Boolean;
var 
	ini: TIniFile;
begin
	if _scStorageToSaveType.values[key] = 'Boolean' then begin
		Result := _scStorageToSaveValues.values[key] = 'true';
		Exit;
		end;
		
	Result := false;
	if Assigned(scDefaults) then 
		if scDefaults.values[key] <> '' then 
			Result := scDefaults.values[key];		
		
	try
	ini := TIniFile.Create(_scSettingsFilePath);
	if ( ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key)) ) then 
		Result := ini.ReadBool(_scSettingsIniSection,_getCleanSettingsKey(key), Result);
	finally
		ini.Free;	
	end;
end;


function getSettingsInteger(key:String; default:Integer):Integer;
var 
	ini: TIniFile;
begin
	if _scStorageToSaveType.values[key] = 'Integer' then begin
		Result := StrToInt(_scStorageToSaveValues.values[key]);
		Exit;
		end;
	Result := default;
	try
	ini := TIniFile.Create(_scSettingsFilePath);
	if ( ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key)) ) then 
		Result := ini.ReadFloat(_scSettingsIniSection,_getCleanSettingsKey(key), default);
	finally
		ini.Free;	
	end;
end;


function getSettingsFloat(key:String; default:Real):Real;
var 
	ini: TIniFile;
begin
	if _scStorageToSaveType.values[key] = 'Float' then begin
		Result := StrToFloat(_scStorageToSaveValues.values[key]);
		Exit;
		end;
	Result := default;
	try
	ini := TIniFile.Create(_scSettingsFilePath);
	if ( ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key)) ) then 
		Result := ini.ReadFloat(_scSettingsIniSection,_getCleanSettingsKey(key), default);
	finally
		ini.Free;	
	end;
end;

function getSettingsString(key:String; default:String):String;
var 
	ini: TIniFile;
begin
	if _scStorageToSaveType.values[key] = 'String' then begin
		Result := _scStorageToSaveValues.values[key];
		Exit;
		end;
	Result := default;
	try
	ini := TIniFile.Create(_scSettingsFilePath);
	Result := ini.ReadString(_scSettingsIniSection, _getCleanSettingsKey(key), 'MISSING');
	if ( Result = 'MISSING' ) then begin			
		// ini.WriteString(_scSettingsIniSection, _getCleanSettingsKey(key), default);
		Result := default;
		end
	finally
		ini.Free;	
	end;
end;


procedure setSettingsBoolean(key:String; value:Boolean);
var 
	ini: TIniFile;
begin
	ini := TIniFile.Create(_scSettingsFilePath);
	try
		if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key)) ) or ( getSettingsBoolean(key) <> value) then	begin
			_scStorageToSaveType.values[key] := 'Boolean';
			if value then
				_scStorageToSaveValues.values[key] := 'true'
			else
				_scStorageToSaveValues.values[key] := 'false';
			end;
	finally
		ini.Free;	
	end;
end;


procedure setSettingsInteger(key:String; value:Integer);
var 
	ini: TIniFile;
begin
	ini := TIniFile.Create(_scSettingsFilePath);
	try
	if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key)) ) or ( getSettingsInteger(key,0) <> value) then begin
		_scStorageToSaveType.values[key] := 'Integer';
		_scStorageToSaveValues.values[key] := IntToStr(value);
		end;
	finally
		ini.Free;	
	end;
end;

procedure setSettingsFloat(key:String; value:Real);
var 
	ini: TIniFile;
begin
	ini := TIniFile.Create(_scSettingsFilePath);
	try
	if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key)) ) or ( getSettingsFloat(key,0) <> value) then begin
		_scStorageToSaveType.values[key] := 'Float';
		_scStorageToSaveValues.values[key] := FloatToStr(value);
		end;
	finally
		ini.Free;	
	end;
end;

procedure setSettingsString(key:String; value:String);
var 
	ini: TIniFile;
begin
	ini := TIniFile.Create(_scSettingsFilePath);
	try
	if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(key)) ) or ( getSettingsString(key,'') <> value) then begin
		_scStorageToSaveType.values[key] := 'String';
		_scStorageToSaveValues.values[key] := value;
		end;
	finally
		ini.Free;	
	end;
end;

procedure saveSettings();
var 
	ini: TIniFile;
	i:Integer;
	valKey,valType, valValStr:String;
begin
	ini := TIniFile.Create(_scSettingsFilePath);
	try

	for i:= 0 to _scStorageToSaveType.Count - 1 do begin
		valKey := _scStorageToSaveType.Names[i];
		valType := _scStorageToSaveType.Values[valKey];
		valValStr := _scStorageToSaveValues.Values[valKey];
		if valType = 'Boolean' then begin
			if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(valKey)) ) or ( ini.ReadBool(_scSettingsIniSection,valKey,false) <> (valValStr = 'true') ) then
				ini.WriteBool(_scSettingsIniSection, _getCleanSettingsKey(valKey), valValStr = 'true');
			end
		else if valType = 'Integer' then begin
			if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(valKey)) ) or ( ini.ReadFloat(_scSettingsIniSection,valKey,0) <> StrToInt(valValStr)) then
				ini.WriteFloat(_scSettingsIniSection, _getCleanSettingsKey(valKey), StrToInt(valValStr));
			end
		else if valType = 'Float' then begin
			if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(valKey)) ) or ( ini.ReadFloat(_scSettingsIniSection,valKey,0) <> StrToFloat(valValStr)) then
				ini.WriteFloat(_scSettingsIniSection, _getCleanSettingsKey(valKey), StrToFloat(valValStr));
			end
		else if valType = 'String' then begin
			if ( not ini.ValueExists(_scSettingsIniSection, _getCleanSettingsKey(valKey)) ) or ( ini.ReadString(_scSettingsIniSection,valKey,'') <> valValStr) then
				ini.WriteString(_scSettingsIniSection, _getCleanSettingsKey(valKey), '"'+valValStr+'"');
			end
		else AddMessage('<ScriptConfiguration> Unknown settings type for '+valKey+': '+valType);
		end;
		
	finally
		ini.Free;	
	end;
end;


{Reads the TagIdent's final tags from ini}
procedure readTags();
var 
	tmpLst: TStringList;
	i: Integer;
begin
	FreeAndNil(tagNames);
	tagNames := THashedStringList.Create;
	tmpLst := TStringList.Create;
	tagsIniFile.ReadSectionValues(getSettingsString('config.sUseTagSet', 'FallUI'), tagNames);
	// Append FO4 data tags to the list
	tagsIniFileData.ReadSectionValues(getSettingsString('config.sUseTagSet', 'FallUI'), tmpLst);
	for i := 0 to tmpLst.Count -1 do 
		tagNames.values[tmpLst.Names[i]] := tmpLst.ValueFromIndex[i];
	// Append user tags to the list
	tagsIniFileUser.ReadSectionValues(getSettingsString('config.sUseTagSet', 'FallUI'), tmpLst);
	for i := 0 to tmpLst.Count -1 do 
		tagNames.values[tmpLst.Names[i]] := tmpLst.ValueFromIndex[i];
	tmpLst.Free;
end;

{Get the current settings profile name}
function getCurrentSettingsProfileName():String;
var 
	ini: TIniFile;	
begin
	ini := TIniFile.Create(sComplexSorterBasePath+'Rules (User)\settings.ini');
	Result := 'Settings';
	if ( ini.ValueExists('CS_Global','SettingsProfile') ) then begin
		Result := ini.ReadString('CS_Global', 'SettingsProfile', 'Settings');
		end;
	ini.Free;
end;

{Set the current settings profile name}
procedure setCurrentSettingsProfileName(newProfileName:String);
var 
	ini: TIniFile;	
begin
	ini := TIniFile.Create(sComplexSorterBasePath+'Rules (User)\settings.ini');
	ini.WriteString('CS_Global', 'SettingsProfile', newProfileName);
	ini.Free;
end;

{Copy a settings profile from source to target profile}
procedure copySettingsProfile(srcProfileName:String; trgProfileName:String);
var
	ini: TIniFile;	
	tmpLst: TStringList;
	i: Integer;
begin
	ini := TIniFile.Create(sComplexSorterBasePath+'Rules (User)\settings.ini');
	tmpLst := TStringList.Create;
	ini.ReadSectionValues(srcProfileName, tmpLst);
	for i := 0 to tmpLst.Count -1 do 
		ini.WriteString(trgProfileName,tmpLst.Names[i],tmpLst.ValueFromIndex[i]);
	// Cleanup
	tmpLst.Free;
	ini.Free;
end;

{Deletes a settings profile}
procedure deleteSettingsProfile(profileName:String);
var
	ini: TIniFile;	
begin
	ini := TIniFile.Create(sComplexSorterBasePath+'Rules (User)\settings.ini');
	ini.EraseSection(profileName);
	ini.Free;
end;

function getAvailableSettingsProfiles():TStringList;
var
	ini: TIniFile;
	i: Integer;
begin
	Result := TStringList.Create;
	ini := TIniFile.Create(_scSettingsFilePath);
	ini.ReadSections(Result);
	for i:=Result.Count - 1 downto 0 do 
		if Result[i] = 'CS_Global' then 
			Result.delete(i);
	ini.Free;
end;


{unit cleanup}
procedure cleanup();
begin
	if Assigned(_scStorageToSaveValues) then
		FreeAndNil(_scStorageToSaveValues);
	if Assigned(_scStorageToSaveType) then
		FreeAndNil(_scStorageToSaveType);
	if Assigned(tagNames) then
		FreeAndNil(tagNames);
end;

end.
