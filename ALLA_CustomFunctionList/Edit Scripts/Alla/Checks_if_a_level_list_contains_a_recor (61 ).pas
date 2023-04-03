

// Checks if a level list contains a record
function LLcontains(aLevelList, aRecord: IInterface): Boolean;
var
  debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg Section
  debugMsg := false;
  Result := False;
	{Debug} if debugMsg then msg('[LLcontains] LLcontains('+EditorID(aLevelList)+', '+EditorID(aRecord)+' );');
  for i := 0 to Pred(LLec(aLevelList)) do begin
		{Debug} if debugMsg then msg('[LLcontains] LLebi := '+EditorID(LLebi(aLevelList, i)));
		if ContainsText(EditorID(LLebi(aLevelList, i)), EditorID(aRecord)) then begin
			{Debug} if debugMsg then msg('[LLcontains] if '+EditorID(LLebi(aLevelList, i))+' = '+EditorID(aRecord)+' then begin');
			{Debug} if debugMsg then msg('[LLcontains] Result := True');
		  Result := True;
			Exit;
	  end;
  end;
	if debugMsg then msg('[LLcontains] Result := False');
	debugMsg := false;
// End debugMsg Section
end;