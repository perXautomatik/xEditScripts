
function MatByKYWD(Keyword: String; RecipeItems: IInterface; AmountOfMainComponent: integer): integer;
var
	CurrentMaterials: tstringlist;
	a: integer;
	debugMsg: boolean;
begin
	debugMsg := false;

	if MaterialList.IndexOf(keyword) < 0 then exit;
	{Debug} if debugMsg then msg('work');
	CurrentMaterials := MaterialList.Objects[materiallist.indexof(keyword)];
	for a := CurrentMaterials.count - 1 downto 0 do
	begin
		{Debug} if debugMsg then msg('work 2');
		if pos('Perk', CurrentMaterials.strings[a]) > 0 then
		begin
			{Debug} if debugMsg then msg('work 3 perk');
			//YggAddPerkCondition(recipeitems, ObjectToElement(CurrentMaterials.Objects[a]));
		end else
		begin
			{Debug} if debugMsg then msg('MatByKYWD: '+Name(ObjectToElement(CurrentMaterials.objects[a])));
			YggAdditem(RecipeItems, ObjectToElement(CurrentMaterials.objects[a]), ceil(StrToFloat(CurrentMaterials.strings[a]) * AmountOfMainComponent * (random(1) + 0.5)));
		end;
		tempPerkFunction(Keyword, RecipeItems, AmountOfMainComponent);
	end;
end;