

function MaterialAmountHeavy(amountOfMainComponent, amountOfAdditionalComponent: integer; recipeItems, aRecord: IInterface): integer;
var
	temp: Double;
begin
	temp := StrToFloat(GetElementEditValues(aRecord, 'DATA\Weight'));
	if hasKeyword(aRecord, 'ArmorCuirass') then
	begin
		amountOfMainComponent := floor(temp * 0.3);
		if amountOfMainComponent < 10 then amountOfMainComponent := 10;
		if amountOfMainComponent > 15 then amountOfMainComponent := 15;
		amountOfAdditionalComponent := floor(amountOfMainComponent / 5);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfAdditionalComponent > 3 then amountOfAdditionalComponent := 3;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		YggAdditem(recipeItems, getRecordByFormID('0005ACE4'), amountOfAdditionalComponent); // IngotIron
	end else if hasKeyword(aRecord, 'ArmorBoots') then
	begin
		amountOfMainComponent := ceil(temp * 0.7);
		if amountOfMainComponent < 3 then amountOfMainComponent := 3;
		if amountOfMainComponent > 7 then amountOfMainComponent := 7;
		amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfAdditionalComponent > 3 then amountOfAdditionalComponent := 3;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		YggAdditem(recipeItems, getRecordByFormID('0005ACE4'), amountOfAdditionalComponent); // IngotIron
	end else if hasKeyword(aRecord, 'ArmorGauntlets') then
	begin
		amountOfMainComponent := floor(temp * 0.7);
		if amountOfMainComponent < 4 then amountOfMainComponent := 4;
		if amountOfMainComponent > 7 then amountOfMainComponent := 7;
		amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfAdditionalComponent > 3 then amountOfAdditionalComponent := 3;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		YggAdditem(recipeItems, getRecordByFormID('0005ACE4'), amountOfAdditionalComponent); // IngotIron
	end else if hasKeyword(aRecord, 'ArmorHelmet') then
	begin
		amountOfMainComponent := ceil(temp * 0.3);
		if amountOfMainComponent < 2 then amountOfMainComponent := 2;
		if amountOfMainComponent > 5 then amountOfMainComponent := 5;
		amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfAdditionalComponent > 3 then amountOfAdditionalComponent := 3;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		YggAdditem(recipeItems, getRecordByFormID('0005ACE4'), amountOfAdditionalComponent); // IngotIron
	end else if hasKeyword(aRecord, 'ArmorPants') then
	begin
		amountOfMainComponent := floor(temp * 0.7);
		if amountOfMainComponent < 3 then amountOfMainComponent := 3;
		if amountOfMainComponent > 8 then amountOfMainComponent := 8;
		amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfAdditionalComponent > 3 then amountOfAdditionalComponent := 3;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		YggAdditem(recipeItems, getRecordByFormID('0005ACE4'), amountOfAdditionalComponent); // IngotIron
	end else if hasKeyword(aRecord, 'ArmorUnderwear') then
	begin
		amountOfMainComponent := 1;
	end else if hasKeyword(aRecord, 'ArmorUnderwearTop') then
	begin
		amountOfMainComponent := 2;
	end else if hasKeyword(aRecord, 'ArmorShirt') then
	begin
		amountOfMainComponent := floor(temp * 0.7);
		if amountOfMainComponent < 3 then amountOfMainComponent := 3;
		if amountOfMainComponent > 8 then amountOfMainComponent := 8;
		amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfAdditionalComponent > 3 then amountOfAdditionalComponent := 3;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		YggAdditem(recipeItems, getRecordByFormID('0005ACE4'), amountOfAdditionalComponent); // IngotIron
	end else
	begin
		amountOfMainComponent := ceil(random(5));
		if amountOfMainComponent < 1 then amountOfMainComponent := 1;
		if amountOfMainComponent > 5 then amountOfMainComponent := 5;
		amountOfAdditionalComponent := floor(amountOfMainComponent / 3);
		if amountOfAdditionalComponent < 1 then amountOfAdditionalComponent := 1;
		if amountOfAdditionalComponent > 3 then amountOfAdditionalComponent := 3;
		YggAdditem(recipeItems, getRecordByFormID('000800E4'), amountOfAdditionalComponent); // LeatherStrips
		YggAdditem(recipeItems, getRecordByFormID('0005ACE4'), amountOfAdditionalComponent); // IngotIron
	end;
	result := amountOfMainComponent;
end;