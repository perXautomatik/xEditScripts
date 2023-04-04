unit ScriptConfiguration;

var
	configurationFile, section: String;
	storageToSaveValues,storageToSaveType: THashedStringList;
	tagNames: TStringList;
	scDefaults: TStringList;
	
procedure init(setConfigurationFile:String; setSection:String);
begin
	configurationFile := setConfigurationFile;
	section := setSection;
	storageToSaveValues := THashedStringList.Create;
	storageToSaveType := THashedStringList.Create;
end;

function getCleanSettingsKey(key:String):String;
begin
	Result := StringReplace(key, '=', '_MASKED_%EQUALS$_', [rfReplaceAll]);
end;

function hasSettingsBoolean(key:String):Boolean;
var 
	ini: TIniFile;
begin
	if storageToSaveType.values[key] = 'Boolean' then begin
		Result := true;
		Exit;
		end;
	
	try
	ini := TIniFile.Create(configurationFile);
	Result := ini.ValueExists(section, getCleanSettingsKey(key));
	finally
		ini.Free;	
	end;
end;


function getSettingsBoolean(key:String):Boolean;
var 
	ini: TIniFile;
begin
	if storageToSaveType.values[key] = 'Boolean' then begin
		Result := storageToSaveValues.values[key] = 'true';
		Exit;
		end;
		
	Result := false;
	if Assigned(scDefaults) then 
		if scDefaults.values[key] <> '' then 
			Result := scDefaults.values[key];		
		
	try
	ini := TIniFile.Create(configurationFile);
	if ( ini.ValueExists(section, getCleanSettingsKey(key)) ) then 
		Result := ini.ReadBool(section,getCleanSettingsKey(key), Result);
	finally
		ini.Free;	
	end;
end;


function getSettingsInteger(key:String; default:Integer):Integer;
var 
	ini: TIniFile;
begin
	if storageToSaveType.values[key] = 'Integer' then begin
		Result := StrToInt(storageToSaveValues.values[key]);
		Exit;
		end;
	Result := default;
	try
	ini := TIniFile.Create(configurationFile);
	if ( ini.ValueExists(section, getCleanSettingsKey(key)) ) then 
		Result := ini.ReadFloat(section,getCleanSettingsKey(key), default);
	finally
		ini.Free;	
	end;
end;


function getSettingsFloat(key:String; default:Real):Real;
var 
	ini: TIniFile;
begin
	if storageToSaveType.values[key] = 'Float' then begin
		Result := StrToFloat(storageToSaveValues.values[key]);
		Exit;
		end;
	Result := default;
	try
	ini := TIniFile.Create(configurationFile);
	if ( ini.ValueExists(section, getCleanSettingsKey(key)) ) then 
		Result := ini.ReadFloat(section,getCleanSettingsKey(key), default);
	finally
		ini.Free;	
	end;
end;

function getSettingsString(key:String; default:String):String;
var 
	ini: TIniFile;
begin
	if storageToSaveType.values[key] = 'String' then begin
		Result := storageToSaveValues.values[key];
		Exit;
		end;
	Result := default;
	try
	ini := TIniFile.Create(configurationFile);
	Result := ini.ReadString(section, getCleanSettingsKey(key), 'MISSING');
	if ( Result = 'MISSING' ) then begin			
		// ini.WriteString(section, getCleanSettingsKey(key), default);
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
	ini := TIniFile.Create(configurationFile);
	try
		if ( not ini.ValueExists(section, getCleanSettingsKey(key)) ) or ( getSettingsBoolean(key) <> value) then	begin
			storageToSaveType.values[key] := 'Boolean';
			if value then
				storageToSaveValues.values[key] := 'true'
			else
				storageToSaveValues.values[key] := 'false';
			end;
	finally
		ini.Free;	
	end;
end;


procedure setSettingsInteger(key:String; value:Integer);
var 
	ini: TIniFile;
begin
	ini := TIniFile.Create(configurationFile);
	try
	if ( not ini.ValueExists(section, getCleanSettingsKey(key)) ) or ( getSettingsInteger(key,0) <> value) then begin
		storageToSaveType.values[key] := 'Integer';
		storageToSaveValues.values[key] := IntToStr(value);
		end;
	finally
		ini.Free;	
	end;
end;

procedure setSettingsFloat(key:String; value:Real);
var 
	ini: TIniFile;
begin
	ini := TIniFile.Create(configurationFile);
	try
	if ( not ini.ValueExists(section, getCleanSettingsKey(key)) ) or ( getSettingsFloat(key,0) <> value) then begin
		storageToSaveType.values[key] := 'Float';
		storageToSaveValues.values[key] := FloatToStr(value);
		end;
	finally
		ini.Free;	
	end;
end;

procedure setSettingsString(key:String; value:String);
var 
	ini: TIniFile;
begin
	ini := TIniFile.Create(configurationFile);
	try
	if ( not ini.ValueExists(section, getCleanSettingsKey(key)) ) or ( getSettingsString(key,'') <> value) then begin
		storageToSaveType.values[key] := 'String';
		storageToSaveValues.values[key] := value;
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
	ini := TIniFile.Create(configurationFile);
	try

	for i:= 0 to storageToSaveType.Count - 1 do begin
		valKey := storageToSaveType.Names[i];
		valType := storageToSaveType.Values[valKey];
		valValStr := storageToSaveValues.Values[valKey];
		if valType = 'Boolean' then begin
			if ( not ini.ValueExists(section, getCleanSettingsKey(valKey)) ) or ( ini.ReadBool(section,valKey,false) <> (valValStr = 'true') ) then
				ini.WriteBool(section, getCleanSettingsKey(valKey), valValStr = 'true');
			end
		else if valType = 'Integer' then begin
			if ( not ini.ValueExists(section, getCleanSettingsKey(valKey)) ) or ( ini.ReadFloat(section,valKey,0) <> StrToInt(valValStr)) then
				ini.WriteFloat(section, getCleanSettingsKey(valKey), StrToInt(valValStr));
			end
		else if valType = 'Float' then begin
			if ( not ini.ValueExists(section, getCleanSettingsKey(valKey)) ) or ( ini.ReadFloat(section,valKey,0) <> StrToFloat(valValStr)) then
				ini.WriteFloat(section, getCleanSettingsKey(valKey), StrToFloat(valValStr));
			end
		else if valType = 'String' then begin
			if ( not ini.ValueExists(section, getCleanSettingsKey(valKey)) ) or ( ini.ReadString(section,valKey,'') <> valValStr) then
				ini.WriteString(section, getCleanSettingsKey(valKey), valValStr);
			end
		else AddMessage('<ScriptConfiguration> Unknown settings type for '+valKey+': '+valType);
		end;
		
	finally
		ini.Free;	
	end;
end;

procedure readTags();
var 
	tmpLst: TStringList;
	i: Integer;
begin
	FreeAndNil(tagNames);
	tagNames := TStringList.Create;
	tmpLst := TStringList.Create;
	tagsIniFile.ReadSectionValues(getSettingsString('config.sUseTagSet', 'FallUI'), tagNames);
	tagsIniFileUser.ReadSectionValues(getSettingsString('config.sUseTagSet', 'FallUI'), tmpLst);
	for i := 0 to tmpLst.Count -1 do 
		tagNames.values[tmpLst.Names[i]] := tmpLst.ValueFromIndex[i];
	tmpLst.Free;
end;


procedure cleanup();
begin
	if Assigned(storageToSaveValues) then storageToSaveValues.Free;
	if Assigned(storageToSaveType) then storageToSaveType.Free;
	if Assigned(tagNames) then FreeAndNil(tagNames);
end;

end.
