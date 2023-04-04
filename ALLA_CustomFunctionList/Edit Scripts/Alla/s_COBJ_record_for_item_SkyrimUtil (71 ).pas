

// Creates COBJ record for item [SkyrimUtils]
function createRecipe(aRecord, aPlugin: IInterface): IInterface;
var
	recipe: IInterface;
begin
	recipe := createRecord(aPlugin, 'COBJ');
	SetElementEditValues(recipe, 'CNAM', Name(aRecord));
	SetElementEditValues(recipe, 'NAM1', '1');
	Add(aRecord, 'items', True);
	Result := recipe;
end;