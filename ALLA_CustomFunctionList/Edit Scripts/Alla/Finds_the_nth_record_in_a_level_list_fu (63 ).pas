

// Finds the nth record in a level list
function IndexOfLL(aLevelList, aRecord): Integer;
var
  debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg Section
  debugMsg := false;
  Result := False;
  for i := 0 to Pred(LLec(aLevelList)) do begin
	  if debugMsg then msg('[IndexOfLL] if '+geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference')+', '+ShortName(aRecord)+' then begin');
	  if ContainsText(geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'), EditorID(aRecord)) then begin
		  Result := i;
			Exit;
	  end;
  end;
	debugMsg := false;
// End debugMsg Section
end;