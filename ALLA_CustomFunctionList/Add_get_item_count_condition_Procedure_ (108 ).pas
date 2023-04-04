
// Add get item count condition
Procedure AddGetItemCountCondition(rec: IInterface; s: string; aBoolean: Boolean);
var
  conditions, condition: IInterface;
begin
	conditions := ebp(rec, 'Conditions');
	if not Assigned(conditions) then begin
		Add(rec, 'Conditions', True);
		conditions := ebp(rec, 'Conditions');
		condition := ebp(ebi(conditions, 0), 'CTDA');
	end else
		condition := ebp(ElementAssign(conditions, HighInteger, nil, False), 'CTDA');
		BeginUpdate(condition);
		try
			seev(condition, 'Type', '11000000'); // Greater than or equal to
			seev(condition, 'Comparison Value', '1.0');
			seev(condition, 'Function', 'GetItemCount');
			seev(condition, 'Inventory Object', s);
		finally
			EndUpdate(condition);
	end;
	if aBoolean then begin
		condition := ebp(ElementAssign(conditions, HighInteger, nil, False), 'CTDA');
		BeginUpdate(condition);
		try
			seev(condition, 'Type', '10010000'); // Equal to / OR
			seev(condition, 'Comparison Value', '0.0');
			seev(condition, 'Function', 'GetEquipped');
			seev(condition, 'Inventory Object', s);
		finally
			EndUpdate(condition);
		end;
		condition := ebp(ElementAssign(conditions, HighInteger, nil, False), 'CTDA');
		BeginUpdate(condition);
		try
			seev(condition, 'Type', '11000000'); // Greater than or equal to
			seev(condition, 'Comparison Value', '2.0');
			seev(condition, 'Function', 'GetItemCount');
			seev(condition, 'Inventory Object', s);
		finally
			EndUpdate(condition);
		end;
	end;
end;