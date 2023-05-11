
function Workbench(amountOfMainComponent, amountOfAdditionalComponent: integer; recipeCraft, recipeCondition, recipeConditions, recipeItem, recipeItems, aRecord: IInterface): IInterface;
var
	debugMsg: boolean;
begin
	debugMsg := false;

	if signature(aRecord) = 'ARMO' then
	begin
		if HasKeyword(aRecord, 'ArmorClothing') then SetElementEditValues(recipeCraft, 'BNAM', GetEditValue(getRecordByFormID('0007866A'))) //tanning rack for clothing
		else SetElementEditValues(recipeCraft, 'BNAM', GetEditValue(getRecordByFormID('00088105'))); //forge
	end;
	if signature(aRecord) = 'AMMO' then SetElementEditValues(recipeCraft, 'BNAM', GetEditValue(getRecordByFormID('00088108'))); //Sharpening wheel
	if signature(aRecord) = 'WEAP' then SetElementEditValues(recipeCraft, 'BNAM', GetEditValue(getRecordByFormID('00088105'))); //forge
	{Debug} if debugMsg then msg('Finished Tailoring');
end;