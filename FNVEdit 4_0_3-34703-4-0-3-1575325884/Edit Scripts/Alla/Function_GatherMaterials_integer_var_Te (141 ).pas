

function GatherMaterials: integer;
var
	TempList: TStringList;
	FileIndex, GroupIndex, f: integer;
	CurrentFile, CurrentGroup, CurrentKYWD: IInterface;
begin
	MaterialList := TStringList.Create;
	MaterialList.Sorted := true;
	MaterialList.Duplicates := dupIgnore;
	MaterialList.NameValueSeparator := ';';
	for FileIndex := 0 to FileCount - 1 do
	begin
		CurrentFile := FileByIndex(FileIndex);
		if HasGroup(CurrentFile, 'KYWD') then
		begin
			CurrentGroup := GroupBySignature(CurrentFile, 'KYWD');
			for GroupIndex := 0 to ElementCount(CurrentGroup) - 1 do
			begin
				CurrentKYWD := EditorID(ElementByIndex(CurrentGroup, GroupIndex));
				if pos('material', LowerCase(CurrentKYWD)) > 0 then
				begin
					MaterialList.Add(CurrentKYWD);
				end else if pos('materiel', LowerCase(CurrentKYWD)) > 0 then
				begin
					MaterialList.Add(CurrentKYWD);
				end else if pos('clothing', LowerCase(CurrentKYWD)) > 0 then
				begin
					MaterialList.Add(CurrentKYWD);
				end;
			end;
		end;
	end;
	TempList := TStringList.Create;
	TempList.DelimitedText := Ini.ReadString('Crafting', 'sKYWDList', '');
	if firstRun then
	begin
		for f := 0 to TempList.count - 1 do
		begin
			MaterialListPrinter(TempList.strings[f]);
		end;
	end;
	IniToMatList;
	for f := MaterialList.count - 1 downto 0 do
	begin
		if TempList.indexof(MaterialList.strings[f]) < 0 then MaterialListPrinter(MaterialList.strings[f]);
	end;
	MaterialList.AddStrings(TempList);
	TempList.Free;
	TempList.Clear;
	Ini.WriteString('Crafting', 'sKYWDList', MaterialList.CommaText);
	Ini.UpdateFile;
end;