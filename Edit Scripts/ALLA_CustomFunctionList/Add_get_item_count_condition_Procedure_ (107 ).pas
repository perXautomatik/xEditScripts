

// Add get item count condition
Procedure AddItemCondition(aRecord, aItem: IInterface; aCount: String);
var
  conditions, condition: IInterface;
	debugMsg: Boolean;
begin
	debugMsg := false;

	{Debug} if debugMsg then msg('[AddItemCondition] AddItemCondition('+EditorID(aRecord)+', '+EditorID(aItem)+', '+aCount+');');
  conditions := ebp(aRecord, 'Conditions');
	{Debug} if debugMsg then msg('[AddItemCondition] if not Assigned(conditions) :='+BoolToStr(Assigned(conditions))+' then begin');
  if not Assigned(conditions) then begin
    Add(aRecord, 'Conditions', True);
    conditions := ebp(aRecord, 'Conditions');
    condition := ebp(ebi(conditions, 0), 'CTDA');
  end else
    condition := ebp(ElementAssign(conditions, HighInteger, nil, False), 'CTDA');
	BeginUpdate(condition);
	try
		seev(condition, 'Type', '11000000'); // Greater than or equal to
		seev(condition, 'Comparison Value', aCount+'.0');
		seev(condition, 'Function', 'GetItemCount');
		seev(condition, 'Inventory Object', ShortName(aItem));
	finally
		EndUpdate(condition);
	end;
end;