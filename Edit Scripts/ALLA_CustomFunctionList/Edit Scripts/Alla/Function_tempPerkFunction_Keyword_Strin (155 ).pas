
function tempPerkFunction(Keyword: String; RecipeItems: IInterface; AmountOfMainComponent: integer): integer;
var
	CurrentMaterials: IInterface;
	a: integer;
begin
	if TempPerkListExtra.IndexOf(Keyword) < 0 then exit;
	YggAddPerkCondition(recipeitems, ObjectToElement(TempPerkListExtra.Objects[TempPerkListExtra.IndexOf(Keyword)]));
end;