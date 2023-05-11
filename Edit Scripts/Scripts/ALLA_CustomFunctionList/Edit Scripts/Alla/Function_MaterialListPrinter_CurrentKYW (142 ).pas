
function MaterialListPrinter(CurrentKYWDName: string): integer;
var
	invalidStuff, ValidSignatures, Output, Input, TempList: TStringList;
	EDID,TempSig: String;
	item, CurrentKYWD, CurrentItem, CurrentReference: IInterface;
	itemIndex, RecipeCount, k, a, i, l, LimitIndex: Integer;
	y, amount, limit: double;
	debugMsg: boolean;
begin
	debugMsg := false;

	ValidSignatures := TStringList.Create;
	ValidSignatures.DelimitedText := 'AMMO,ARMO,WEAP';
	invalidStuff := tstringlist.Create;
	InvalidStuff.DelimitedText := 'ARMO,AMMO,WEAP,SLGM,BOOK';
	input := TStringList.Create;
	Output := TStringList.Create;
	CurrentKYWD := TrueRecordByEDID(CurrentKYWDName);
	if not Assigned(CurrentKYWD) then exit;
	RecipeCount := 0;
	for k := referencedByCount(CurrentKYWD) - 1 downto 0 do
	begin
		{Debug} if debugMsg then msg('Cycle ' + IntToStr(k) + ' for kywd ' + currentKYWDName);
		CurrentItem := ReferencedByIndex(CurrentKYWD, k);
		TempSig := Signature(CurrentItem);
		if ValidSignatures.IndexOf(TempSig) < 0 then continue;
		if not isBlacklist(CurrentItem) then continue;
		{Debug} if debugMsg then msg('Passed Signature');
		for a := ReferencedByCount(CurrentItem) - 1 downto 0 do
		begin
			{Debug} if debugMsg then msg('Recipe Search ' + IntToStr(a));
			CurrentReference := ReferencedByIndex(CurrentItem, a);
			if not pos('COBJ', signature(CurrentReference)) > 0 then continue;
			{Debug} if debugMsg then msg('it is a recipe');
			if not equals(CurrentItem, LinksTo(ElementByPath(CurrentReference, 'CNAM'))) then continue;
			{Debug} if debugMsg then msg('item is output');
			if not IsWinningOverride(CurrentReference) then continue;
			if length(GetElementEditValues(CurrentReference, 'COCT')) = 0 then continue
			else l := tryStrToInt(GetElementEditValues(CurrentReference, 'COCT'), 0) - 1;
			{Debug} if debugMsg then msg('standard recipe limitations');
			TempList := TStringList.Create;
			for i := l downto 0 do
			begin
				item := LinksTo(ElementByIndex(ElementByIndex(ElementByIndex(ElementByPath(CurrentReference, 'Items'), i), 0), 0));
				if invalidStuff.IndexOf(signature(item)) >= 0 then continue;
				EDID := EditorID(item);
				ItemIndex := Input.IndexOf(EDID);
				{Debug} if debugMsg then msg('matlistprinter ' +IntToStr(TempList.Count));
				if ItemIndex < 0 then
				begin
					TempList.Add(EDID);
					TempList.Add(IntToStr(1));
					TempList.Add(IntToStr(1));
					TempList.Objects[0] := item;
					ItemIndex := Input.AddObject(EDID, TempList);
				end else TempList.Assign(Input.Objects[ItemIndex]);
				TempList.strings[1] := IntToStr(tryStrToInt(TempList.strings[1], 0) + 1);
				TempList.strings[2] := IntToStr(tryStrToInt(TempList.strings[2], 0) + tryStrToInt(GetEditValue(ElementByIndex(ElementByIndex(ElementByIndex(ElementByPath(CurrentReference, 'Items'), i), 0), 1)), 0));
				Input.Objects[ItemIndex] := TempList;
			end;
			RecipeCount := RecipeCount + 1;
		end;
	end;
	Limit := 0;
	for a := Input.Count - 1 downto 0 do
	begin
		TempList := input.objects[a];
		if length(TempList.strings[1]) = 0 then
		begin
			input.Delete[a];
			continue;
		end;
		if length(TempList.Strings[2]) = 0 then
		begin
			input.Delete[a];
			continue;
		end;
		if tryStrToInt(TempList.strings[1], 0) < (recipeCount / 2) then input.Delete(a);
		if not tryStrToFloat(tryStrToInt(TempList.Strings[1], 0) / tryStrToInt(TempList.strings[2], 1), 1) > Limit then continue;
		Limit := tryStrToInt(TempList.Strings[1], 0) / tryStrToInt(TempList.Strings[2], 1);
		LimitIndex := a;
	end;
	if limit > 0 then y := 1 / limit
	else y := 1;

	for a := input.count - 1 downto 0 do
	begin
		TempList := input.objects[a];
		if TempList.count < 0 then continue;
		item := ObjectToElement(TempList.Objects[0]);
		Edid := TempList.strings[0];
		if tryStrToInt(TempList.Strings[2], 0) > 0 then
		amount := StrToFloat(TempList.Strings[1]) / StrToFloat(TempList.Strings[2])
		else continue;
		if amount = 0.0 then continue;
		output.add('i' + signature(item) + ':' + GetFileName(GetFile(MasterOrSelf(item))) + '|' + EDID + '=' + FloatToStr(Amount * y));
	end;
	if ContainsText('Clothing',CurrentKYWDName) then begin
		if output.length < 1 then
		begin
			output.add('iMISC:Skyrim.esm|RuinsLinenPile01=1.0');
		end;
	end;
	input.free;
	ini.WriteString('Crafting', CurrentKYWDName, output.commatext);
	ini.UpdateFile;
	output.free;
end;