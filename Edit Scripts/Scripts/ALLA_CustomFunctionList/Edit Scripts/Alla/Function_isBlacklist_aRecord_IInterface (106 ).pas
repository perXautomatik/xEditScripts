
function isBlacklist(aRecord: IInterface): boolean;
var
	slTemp: TStringList;
	counter, i: integer;
	word: string;
begin
	counter := 0;
	if not assigned(DisKeyword) then IniBlacklist;
	for i := DisKeyword.Count - 1 downto 0 do
		if HasKeyword(aRecord, DisKeyword[i]) then counter := 1;
	if not assigned(disWord) then IniBlacklist;
	word := LowerCase(EditorID(aRecord));
	for i := disWord.count - 1 downto 0 do
		if ContainsText(word, disWord[i]) then counter := 1;

	word := LowerCase(name(aRecord));
	for i := disWord.count - 1 downto 0 do
		if ContainsText(word, disWord[i]) then counter := 1;

	if disallowNP then begin
		if IntToStr(GetElementNativeValues(aRecord, 'Record Header\Record Flags\Non-Playable')) < 0 then counter := 1;
		if IntToStr(GetElementNativeValues(aRecord, 'DATA\Flags\Non-Playable')) < 0 then counter := 1;
	end;

	if ignoreEmpty then if not Assigned(elementbypath(aRecord, 'FULL - Name')) then counter := 1;
	if not IsWinningOVerride(aRecord) then counter := 1;
	if counter = 0 then result := true else result := false;
end;