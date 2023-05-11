

// Replaces aRecord with bRecord in aLevelList; Adds bRecord to aLevelList if aRecord is not detected; Returns true if replaced, false if added
function LLreplace(aLevelList, aRecord, bRecord: IInterface): Boolean;
var
  debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg Section
  debugMsg := false;

  Result := False;
  for i := 0 to Pred(LLec(aLevelList)) do begin
		{Debug} if debugMsg then msg('[LLreplace] '+geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'));
	  if ContainsText(geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'), EditorID(aRecord)) then begin
			{Debug} if debugMsg then msg('[LLreplace] SetEditValue('+geev(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference')+', '+ShortName(bRecord)+');');
			SetEditValue(ebp(ebi(ebp(aLevelList, 'Leveled List Entries'), i), 'LVLO\Reference'), ShortName(bRecord));
			{Debug} if debugMsg then msg('[LLreplace] '+EditorID(LLebi(aLevelList, i))+' = '+EditorID(aRecord));
			Exit;
	  end;
  end;
	// addToLeveledList(aLevelList, bRecord, 1);
	// {Debug} if debugMsg then msg('[LLreplace] addToLeveledList('+EditorID(aLevelList)+', '+EditorID(bRecord)+', 1);');

	debugMsg := false;
// End debugMsg Section
end;