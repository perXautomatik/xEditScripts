
// Remove invalid entries from containers (experimental)
Procedure removeErrors(aRecord: IInterface);
var
	tempRecord, tempElement, currentElement: IInterface;
	slProcess: TStringList;
	debugMsg: Boolean;
	i, x: Integer;
begin
	// Initialize
	debugMsg := false;
	slProcess := TStringList.Create;

	// Process
	for i := 0 to Pred(ec(aRecord)) do
		slProcess.AddObject(FullPath(ebi(aRecord, i)), ebi(aRecord, i));
	while (slProcess.Count > 0) do begin
		tempElement := ote(slProcess.Objects[0]);
		{Debug} if debugMsg then msg('[removeErrors] tempElement := '+Name(tempElement));
		for i := 0 to Pred(ec(tempElement)) do begin
			currentElement := ebi(tempElement, i);
			{Debug} if debugMsg then msg('[removeErrors] currentElement := '+Name(currentElement));
			{Debug} if debugMsg then msg('[removeErrors] if not ContainsText('+GetEditValue(currentElement)+', Error) then begin);');
			if not ContainsText(GetEditValue(currentElement), 'Error') then begin
				if (ec(currentElement) > 0) then begin
					{Debug} if debugMsg then msg('[removeErrors] slProcess.AddObject('+Name(currentElement)+' );');
					slProcess.AddObject(FullPath(currentElement), currentElement);
				end;
			end else begin
				if (Name(currentElement) = 'Item') then begin
					msg('[removeErrors] '+GetEditValue(currentElement)+' Removed from '+Name(aRecord));
					Remove(GetContainer(GetContainer(currentElement)));				
				end else begin
					msg('[removeErrors] '+GetEditValue(currentElement)+' Removed from '+Name(aRecord));
					Remove(currentElement);
				end;
			end;
		end;
		// {Debug} if debugMsg then msg('[removeErrors] slProcess.Delete('+slProcess[0]+' );');
		slProcess.Delete(0);
	end;

	// Finalize
	slProcess := TStringList.Create;
end;