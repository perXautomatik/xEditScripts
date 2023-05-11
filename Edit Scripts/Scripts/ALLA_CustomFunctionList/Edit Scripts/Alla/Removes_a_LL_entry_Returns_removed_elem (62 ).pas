
// Removes a LL entry; Returns removed element
function LLremove(aLevelList, aRecord): IInterface;
var
	debugMsg: Boolean;
	i: Integer;
begin
	for i := 0 to Pred(LLec(aLevelList)) do begin
		if ContainsText(LLebi(aLevelList, i), EditorID(aRecord)) then begin
			Result := LLebi(aLevelList, i);
			Remove(ebi(ebp(aLevelList, 'Leveled List Entries'), i));
		end;
	end;
end;