
function FindRecipe(Create: boolean; List:TStringList; aRecord, Patch: IInterface): IInterface;
var
	recipeCraft: IInterface;
	debugMsg: boolean;
begin
	debugMsg := false;

	if List.IndexOf(LowerCase(EditorID(WinningOverride(aRecord)))) >= 0 then
	begin
		result := wbCopyElementToFile(ObjectToElement(List.Objects[List.IndexOf(EditorID(aRecord))]), Patch, false, true);
	end else
	begin
		if create then
		begin
			recipeCraft := YggcreateRecord('COBJ');
			{Debug} if debugMsg then msg('No Recipe Found');

			// add reference to the created object
			SetElementEditValues(recipeCraft, 'CNAM', Name(aRecord));
			// set Created Object Count
			SetElementEditValues(recipeCraft, 'NAM1', '1');
			Result := recipeCraft;
		end;
	end;
end;