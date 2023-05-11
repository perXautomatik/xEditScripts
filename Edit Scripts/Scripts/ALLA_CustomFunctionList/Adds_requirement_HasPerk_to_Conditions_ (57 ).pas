
// Adds requirement 'HasPerk' to Conditions list [SkyrimUtils]
function addPerkCondition(aList: IInterface; aPerk: IInterface): IInterface;
var
  newCondition, tempRecord: IInterface;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := false;
  if not (Name(aList) = 'Conditions') then begin
    if sig(aList) = 'COBJ' then begin // record itself was provided
      tempRecord := ebp(aList, 'Conditions');
      if not Assigned(tempRecord) then begin
        Add(aList, 'Conditions', True);
        aList := ebp(aList, 'Conditions');
        newCondition := ebi(aList, 0); // xEdit will create dummy condition if new list was added
      end else
        aList := tempRecord;
    end;
  end;
  if not Assigned(newCondition) then
    newCondition := ElementAssign(aList, HighInteger, nil, false);
  // set type to Equal to
  SetElementEditValues(newCondition, 'CTDA - \Type', '10000000');
  // set some needed properties
	SetElementEditValues(ebp(newCondition, 'CTDA'), 'Type', '10000000');
	SetElementEditValues(ebp(newCondition, 'CTDA'), 'Comparison Value', '1');
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Function', 'HasPerk');
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Perk', GetEditValue(aPerk));
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Run On', 'Subject');
  SetElementEditValues(ebp(newCondition, 'CTDA'), 'Parameter #3', '-1');
  removeInvalidEntries(aList);
  Result := newCondition;
	debugMsg := false;
// End debugMsg section
end;