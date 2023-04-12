

// This is just a ghetto way of replacing all the items with a single leveled list; Returns the first element in the list
function RefreshList(aRecord: IInterface; aString: String): IInterface;
var
  debugMsg: Boolean;
begin
// Begin debugMsg Section
  debugMsg := false;

	{Debug} if debugMsg then msg('[AddToOutfitAuto] Remove(ebp('+geev(aRecord, 'EditorID')+', '''+aString+'''));');
	Remove(ebp(aRecord, aString));
	{Debug} if debugMsg then msg('[AddToOutfitAuto] Add('+GetFileName(aRecord)+', '''+aString+''', True);');
	Add(aRecord, aString, True);
	Result := ebi(ebp(aRecord, aString), 0);

	debugMsg := false;
// End debugMsg Section
end;