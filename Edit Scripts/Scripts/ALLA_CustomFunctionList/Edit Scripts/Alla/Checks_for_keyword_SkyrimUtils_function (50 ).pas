
// Checks for keyword [SkyrimUtils]
function HasKeyword(aRecord: IInterface; aString: String): boolean;
var
  tempRecord: IInterface;
	debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

  Result := False;
  tempRecord := ebp(aRecord, 'KWDA');
  for i := 0 to Pred(ec(tempRecord)) do begin
		{Debug} if debugMsg then msg('[HasKeyword] if ('+EditorID(LinksTo(ebi(tempRecord, i)))+' = '+aString+' ) then begin');
    if (EditorID(LinksTo(ebi(tempRecord, i))) = aString) then begin
			{Debug} if debugMsg then msg('[HasKeyword] Result := True');
      Result := True;
      Break;
    end;
  end;

	debugMsg := false;
// End debugMsg section
end;

// Gets a keyword list [SkyrimUtils]
Procedure slKeywordList(aRecord: IInterface; out aList: TStringList);
var
  tempRecord: IInterface;
	debugMsg: Boolean;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;
	if debugmsg then msg('slKeywordList start');
	tempRecord := ebp(aRecord, 'KWDA');
	if not assigned(aList) then aList := TStringList.Create;
	for i := 0 to ec(tempRecord)-1 do
		aList.Add(EditorID(LinksTo(ebi(tempRecord, i))));
	if debugmsg then msg('slKeywordList complete');
	debugMsg := false;
// End debugMsg section
end;

// Adds keyword [SkyrimUtils]
function AddKeyword(itemRecord: IInterface; keyword: IInterface): integer;
var
  keywordRef: IInterface;
begin
  // don't edit records, which already have this keyword
  if not HasKeyword(itemRecord, EditorID(keyword)) then begin
    // get all keyword entries of provided record
    keywordRef := ElementByName(itemRecord, 'KWDA');

    // record doesn't have any keywords
    if not Assigned(keywordRef) then begin
      Add(itemRecord, 'KWDA', true);
    end;
    // add new record in keywords list
    keywordRef := ElementAssign(ebp(itemRecord, 'KWDA'), HighInteger, nil, false);
    // set provided keyword to the new entry
    SetEditValue(keywordRef, GetEditValue(keyword));
  end;
end;