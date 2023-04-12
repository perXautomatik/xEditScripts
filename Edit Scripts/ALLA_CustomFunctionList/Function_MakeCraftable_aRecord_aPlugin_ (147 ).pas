
function MakeCraftable(aRecord, aPlugin: IInterface): IInterface;
var
	recipeCraft, recipeCondition, recipeConditions, recipeItem, recipeItems, keywords: IInterface;
	amountOfMainComponent, ki, amountOfAdditionalComponent, e: integer;
	debugMsg: boolean;
begin
	debugMsg := false;

	recipeCraft := FindRecipe(false,HashedList,aRecord, aPlugin);
	if assigned(recipeCraft) then begin
		{Debug} if debugMsg then msg('Recipe Found for: ' + Name(aRecord) + ' emptying');
		beginUpdate(recipeCraft);
		try
			for e := ElementCount(ElementByPath(recipeCraft, 'Items')) - 1 downto 0 do
			begin
				RemoveByIndex(ElementByPath(recipeCraft, 'Items'), e, false);
			end;
			for e := ElementCount(ElementByPath(recipeCraft, 'Conditions')) - 1 downto 0 do
			begin
				RemoveByIndex(ElementByPath(recipeCraft, 'Conditions'), e, false);
			end;
		finally endUpdate(recipeCraft);
		end;
	end;
	if not assigned(RecipeCraft) then begin
		{Debug} if debugMsg then msg('No Recipe Found for: ' + Name(aRecord) + ' Generating new one');
		recipeCraft := CreateRecord(aPlugin,'COBJ');
		// add reference to the created object
		SetElementEditValues(recipeCraft, 'CNAM', Name(aRecord));
		// set Created Object Count
		SetElementEditValues(recipeCraft, 'NAM1', '1');
	end;

	//{Debug} if debugMsg then msg('checkpoint');
	//recipeCraft := FindCraftingRecipe;
	// add required items list
	Add(recipeCraft, 'items', true);
	// get reference to required items list inside recipe
	recipeItems := ElementByPath(recipeCraft, 'items');
	// trying to figure out propper requirements amount 
	if hasKeyword(aRecord, 'ArmorHeavy') then
	begin //if it is heavy armor, base the amount of materials on the weight
	{debug} if debugmsg then msg('recipe is for heavy');
		amountOfMainComponent := 0;
		if assigned(recipeItems) and assigned(aRecord) then
			amountOfMainComponent := MaterialAmountHeavy(amountOfMainComponent, amountOfAdditionalComponent, recipeItems, aRecord);
		amountOfAdditionalComponent := ceil(2);
		Keywords := ElementByPath(aRecord, 'KWDA');
	end else if hasKeyword(aRecord, 'ArmorLight') then
	begin //Light armor is based on rating
		{debug} if debugmsg then msg('recipe is for light');
		AmountOfMainComponent := materialAmountLight(amountOfMainComponent,AmountOfAdditionalComponent,RecipeItems,aRecord);
		amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfMainComponent < 1 then amountOfMainComponent := 1;
		if amountOfMainComponent > 10 then amountOfMainComponent := 10;
		if amountOfAdditionalComponent > 15 then amountOfAdditionalComponent := 15;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		Keywords := ElementByPath(aRecord, 'KWDA');
	end else if hasKeyword(aRecord, 'ArmorClothing') then
	begin //clothing
	//uses -1.4ln(x/10)+10 for value to get amount
		{Debug} if debugMsg then msg(Name(aRecord) + ' is Clothing');
		if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 42 then
		begin
			amountOfMainComponent := 5;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 173 then
		begin
			amountOfMainComponent := 4;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 730 then
		begin
			amountOfMainComponent := 3;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 3020 then
		begin
			amountOfMainComponent := 2;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) > 3020 then amountOfMainComponent := 1;
	
		//uses -2.5ln(-x+51)+10 for weight to get a second amount and add to first.
		if StrToFloat(GetElementEditValues(aRecord, 'DATA\Weight')) >= 50 then
		begin
			amountOfMainComponent := amountOfMainComponent + 5;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Weight')) > 48 then
		begin
			amountOfMainComponent := amountOfMainComponent + 4;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Weight')) > 46 then
		begin
			amountOfMainComponent := amountOfMainComponent + 3;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Weight')) > 40 then
		begin
			amountOfMainComponent := amountOfMainComponent + 2;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Weight')) > 26 then
		begin
			amountOfMainComponent := amountOfMainComponent + 1;
		end else amountOfMainComponent := amountOfMainComponent + 0;
			amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfMainComponent < 1 then amountOfMainComponent := 1;
	
	end else if hasKeyword(aRecord, 'ArmorJewelry') then
	begin //jewelry
		{Debug} if debugMsg then msg(Name(aRecord) + ' is Jewelry');
		if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 42 then
		begin
			amountOfMainComponent := 5;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 173 then
		begin
			amountOfMainComponent := 4;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 730 then
		begin
			amountOfMainComponent := 3;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) < 3020 then
		begin
			amountOfMainComponent := 2;
		end else if StrToFloat(GetElementEditValues(aRecord, 'DATA\Value')) > 3020 then amountOfMainComponent := 1;
		amountOfAdditionalComponent := floor(StrToFloat(GetElementEditValues(aRecord, 'DATA\Weight')) * 0.2 / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfMainComponent < 1 then amountOfMainComponent := 1;

		YggAdditem(recipeItems, getRecordByFormID('0005AD9E'), amountOfMainComponent); // gold
		Keywords := ElementByPath(aRecord, 'KWDA');
	
	end else begin
		{debug} if debugmsg then msg(name(aRecord) + ' is not clothing, jewelry, or armor');
		AmountOfMainComponent := 3;
		AmountOfAdditionalComponent := 2;
		Keywords := ElementByPath(aRecord, 'KWDA');
	
	end;
	
	for ki := 0 to ElementCount(Keywords) - 1 do
	begin
		{Debug} if debugMsg then msg('makcraftable ' +GetEditValue(ElementByIndex(Keywords, ki)));
		MatByKYWD(EditorID(LinksTo(ElementByIndex(Keywords, ki))), RecipeItems, AmountOfMainComponent);
	end;

	// set EditorID for recipe
	if pos('ARMO', signature(aRecord)) > 0 then SetElementEditValues(recipeCraft, 'EDID', 'RecipeArmor' + GetElementEditValues(aRecord, 'EDID'));
	if pos('AMMO', signature(aRecord)) > 0 then SetElementEditValues(recipeCraft, 'EDID', 'RecipeAmmo' + GetElementEditValues(aRecord, 'EDID'));
	if pos('WEAP', signature(aRecord)) > 0 then SetElementEditValues(recipeCraft, 'EDID', 'RecipeWeapon' + GetElementEditValues(aRecord, 'EDID'));

	// add reference to the workbench keyword
	Workbench(amountOfMainComponent, amountOfAdditionalComponent, recipeCraft, recipeCondition, recipeConditions, recipeItem, recipeItems,aRecord);

	// remove nil record in items requirements, if any
	removeInvalidEntries(recipeCraft);

	if GetElementEditValues(recipeCraft, 'COCT') = '' then begin
		{Debug} if debugMsg then msg('no item requirements was specified for - ' + Name(aRecord));
		remove(recipeCraft);
		//YggAdditem(recipeItems, getRecordByFormID('0005AD9E'), 10); // gold
	end	else if not assigned(ElementByPath(recipeCraft, 'COCT')) then begin
		{Debug} if debugMsg then msg('no item requirements was specified for - ' + Name(aRecord));
		remove(recipeCraft);
		//YggAdditem(recipeItems, getRecordByFormID('0005AD9E'), 10); // gold
	end else if not assigned(ElementByPath(recipeCraft, 'Items')) then begin
		{Debug} if debugMsg then msg('no item requirements was specified for - ' + Name(aRecord));
		remove(recipeCraft);
		//YggAdditem(recipeItems, getRecordByFormID('0005AD9E'), 10); // gold
	end else if ElementCount(ElementByPath(recipeCraft, 'Items')) < 1 then begin
		{Debug} if debugMsg then msg('no item requirements was specified for - ' + Name(aRecord));
		remove(recipeCraft);
		//YggAdditem(recipeItems, getRecordByFormID('0005AD9E'), 10); // gold
	end;
end;