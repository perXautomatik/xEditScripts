
function IniProcess: integer;
var
	TalkToUser: integer;
begin
	firstRun := true;
	Ini := TMemIniFile.Create(ScriptsPath + 'ALLA.ini');
	firstRun := Ini.ReadBool('Defaults', 'UpdateINI', true);
	Ini.WriteBool('Defaults', 'UpdateINI', false);
	Ini.UpdateFile;
end;