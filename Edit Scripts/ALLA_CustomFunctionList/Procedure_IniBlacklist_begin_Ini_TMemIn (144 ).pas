
procedure IniBlacklist;
begin
	Ini := TMemIniFile.Create(ScriptsPath + 'ALLA.ini');
		disWord := TStringList.Create;
	if Ini.readString('blacklist', 'disallowedWords', '1') = '1' then begin
		disWord.add('skin');
		Ini.WriteString('blacklist', 'disallowedWords', disWord.CommaText);
	end else disWord.DelimitedText := Ini.ReadString('blacklist', 'disallowedWords', '1');
	if Ini.ReadBool('blacklist', 'disallownonplayable', true) then begin
		Ini.WriteBool('blacklist', 'disallownonplayable', true);
		DisallowNP := Ini.ReadBool('blacklist', 'disallownonplayable', true);
	end;
		DisKeyword := TStringList.Create;
	if Ini.ReadString('blacklist', 'disallowedKeywords', '1') = '1' then begin
		DisKeyword.add('DisallowEnchanting');
		DisKeyword.add('unique');
		DisKeyword.add('noCraft');
		DisKeyword.add('Dummy');
		Ini.WriteString('blacklist', 'disallowedKeywords', DisKeyword.CommaText);
	end else DisKeyword.DelimitedText := Ini.Readstring('blacklist', 'disallowedKeywords', '1');
	if Ini.readBool('blacklist', 'ignoreEmpty', true) then begin
		Ini.WriteBool('blacklist', 'ignoreEmpty', true);
		ignoreEmpty := Ini.ReadBool('blacklist', 'ignoreEmpty', true);
	end;
	Ini.UpdateFile;
end;