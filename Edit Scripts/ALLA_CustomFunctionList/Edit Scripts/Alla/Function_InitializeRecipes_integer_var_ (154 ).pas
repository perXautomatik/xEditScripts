
function InitializeRecipes: integer;
var
	f, r: integer;
	BNAM, currentFile, CurrentGroup, CurrentItem: IInterface;
	StationEDID,temp: string;
	debugmsg: boolean;
begin
	debugMsg := false;

	Recipes := TStringList.Create;
	Recipes.Duplicates := dupIgnore;
	Recipes.Sorted;

	for f := FileCount - 1 downto 0 do
	begin
		currentFile := FileByIndex(f);
		if HasGroup(currentFile, 'COBJ') then
		begin
			CurrentGroup := GroupBySignature(currentFile, 'COBJ');
			for r := ElementCount(CurrentGroup) - 1 downto 0 do
			begin
				CurrentItem := ElementByIndex(CurrentGroup, r);
				BNAM := LinksTo(ElementByPath(CurrentItem, 'BNAM'));
				temp := LowerCase(EditorID(WinningOverride(LinksTo(ElementByPath(CurrentItem, 'CNAM')))));
				StationEDID := LowerCase(EditorID(BNAM));
				if IsWinningOverride(CurrentItem) then
				begin
					if not (ContainsText(StationEDID,'armortable')) and not (ContainsText(StationEDID,'sharpening')) and (ContainsText(StationEDID,'forge') OR (ContainsText(StationEDID,'skyforge'))) and not (ContainsText(StationEDID,'cook')) then begin
						Recipes.AddObject(temp, CurrentItem);
						if debugmsg then msg('adding recipe ' + name(CurrentItem));
					end else if (StationEDID = 'Smelter') then begin
						Items := ElementByPath(CurrentItem, 'Items');
						for i := ElementCount(Items) - 1 downto 0 do begin
							Item := WinningOverride(LinksTo(ElementByPath(ElementByIndex(Items, i), 'CNTO\Item')));
							sigItem := Signature(Item);
						end;
					end;
				end;
			end;
		end else
		begin
			continue;
		end;
	end;
	HashedList := THashedStringList.Create;
	HashedList.Assign(Recipes);
	//temper
	Recipes := TStringList.Create;
	Recipes.Duplicates := dupIgnore;
	Recipes.Sorted;

	for f := FileCount - 1 downto 0 do
	begin
		currentFile := FileByIndex(f);
		if HasGroup(currentFile, 'COBJ') then
		begin
			CurrentGroup := GroupBySignature(currentFile, 'COBJ');
			for r := ElementCount(CurrentGroup) - 1 downto 0 do
			begin
				CurrentItem := ElementByIndex(CurrentGroup, r);
				BNAM := LinksTo(ElementByPath(CurrentItem, 'BNAM'));
				temp := LowerCase(EditorID(WinningOverride(LinksTo(ElementByPath(CurrentItem, 'CNAM')))));
				StationEDID := LowerCase(EditorID(BNAM));
				if IsWinningOverride(CurrentItem) then
				begin
					if (ContainsText(StationEDID,'armortable')) or (ContainsText(StationEDID,'sharpening')) and not (ContainsText(StationEDID,'cook')) then begin
						Recipes.AddObject(temp, CurrentItem);
						if debugmsg then msg('adding recipe ' + name(CurrentItem));
					end else if (StationEDID = 'Smelter') then begin
						Items := ElementByPath(CurrentItem, 'Items');
						for i := ElementCount(Items) - 1 downto 0 do begin
							Item := WinningOverride(LinksTo(ElementByPath(ElementByIndex(Items, i), 'CNTO\Item')));
							sigItem := Signature(Item);
						end;
					end;
				end;
			end;
		end else
		begin
			continue;
		end;
	end;
	HashedTemperList := THashedStringList.Create;
	HashedTemperList.Assign(Recipes);
end;