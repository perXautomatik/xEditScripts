
////////////////////////////////////////////////////////////////////// TIER DETECTION //////////////////////////////////////////////////////////////////////////////////////
	// Replace EditorID with GameValue once tiers are assigned
	{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] Replace EditorID with GameValue');
	for i := 0 to slItem.Count-1 do
		slItem[i] := GetGameValue(ote(slItem.Objects[i]));
	// Checks the selected item against the tier list in order to assign the tier	 
	if Assigned(itemType) and Assigned(slItem) and (slItem.Count > 0) then begin
		// Assigns the relevant value (Armor/Damage/Value) of the selected record
		slItem.Sort;
		recordValue := GetGameValue(aRecord);
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] aRecord := '+EditorID(aRecord));
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] GameValueType := '+GetGameValueType(aRecord));
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] recordValue := '+IntToStr(recordValue));
		{Debug} if debugMsg then msgList('[Tier Detection] slItem := ', slItem, '');

		// Assigns Item Tier based on the relevant value
		{Debug} if debugMsg then for i := 0 to slItem.Count-1 do msg('tier detection stuff ' +slItem[i]);
		for i := 0 to slItem.Count-1 do begin
			{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] slItem.Count-1 := '+IntToStr(slItem.Count-1)+' i := '+IntToStr(i));
			// This checks the value of the selected record against the value of the next tier
			// Example: Iron Sword.  This checks if the damage value of the iron sword is less than i+1 (the next tier). 
			// The value of an iron sword is less than i+1 (steel). Therefore the sword is tier i (Iron). 
			// The length() part is due to how TStringLists sort.  They sort by the first digit first.  Example:  2,3,4,10,11,12 would sort as 10,11,12,2,3,4. 
			// If a sword is 1-9 damage it has length = 1 so it will skip 10, 11, 12, and then start checking at 2.
			// Min and max length are also useful for checking if the record value has fewer digits than the minimum or more than the maximum
			if (i+1 < slItem.count - 1) then begin
				{Debug} if debugMsg then msg('[GetTemplate] [Tier Detection] recordValue := '+IntToStr(recordValue)+' < StrToInt(slItem[i+1]) := '+slItem[i+1]);
				if (recordValue < (StrToInt(slItem[i+1]))) and (length(IntToStr(recordValue)) = Length(slItem[i])) then begin
					// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[i]))+' template');
					{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[i])));
					Result := ote(slItem.Objects[i]);
					Break;
				end else if (recordValue = StrToInt(slItem[i+1])) and (length(IntToStr(recordValue)) = Length(slItem[i+1])) then begin
					// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[i]))+' template');
					{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[i])));
					if slItem.Count-1 >= (i+1) then begin 
						Result := ote(slItem.Objects[i+1]);
					end else Result := ote(slItem.Objects[i]);
				end;
			end;
			// This checks the max and min length of the values in the TStringList.
			// Example: 9 damage sword.  But tier i is 8 damage and tier i+1 is 10 damage. 
			// In this case the section above won't assign the tier because 9 > 8 and length(9) =/= length(10).
			slItemMaxValue := Max(StrToInt(slItem[i]), slItemMaxValue);
			slItemMaxLength := Max(Length(slItem[i]), slItemMaxLength);
			slItemMinLength := Min(Length(slItem[i]), slItemMinLength);
		end;
	
		// Fringe cases for Item Tiers
		if not Assigned(Result) then begin
			msg('Not assigned');
		// For item values greater than i but length less than i+1.
			if (Length(recordValue) >= slItemMinLength) and (Length(recordValue) < slItemMaxLength) then begin
				for i := 0 to slItem.Count-1 do begin
					if Length(IntToStr(recordValue)) = Length(slItem[i]) then begin
						// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[i]))+' template');
						{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[i])));
						Result := ote(slItem.Objects[i]);
					end;
				end;
			// For item values greater than the maximum (Daedric/Dragonscale/GoldDiamond/etc.)
			end else if (recordValue >= slItemMaxValue) then begin
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[slItem.Count-1]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[slItem.Count-1])));
				if (slItem.Count-1 >= 0) then
					Result := ote(slItem.Objects[slItem.Count-1]);
			// For item values with fewer digits than the minimum (e.x. min armor is 10 but item armor is 1)
			end else if Length(IntToStr(recordValue)) < slItemMinLength then begin 
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[0]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[0])));
				if (slItem.Count-1 >= 0) then
					Result := ote(slItem.Objects[0]);
			// For item values with more digits than the maximum (e.x. max armor is 10 but item armor is 100)
			end else if Length(IntToStr(recordValue)) > slItemMaxLength then begin
				// msg('['+record_full+'] '+record_full+' assigned '+full(ote(slItem.Objects[slItem.Count-1]))+' template');
				{Debug} if debugMsg then msg('[GetTemplate] Result := '+EditorID(ote(slItem.Objects[slItem.Count-1])));
				if (slItem.Count-1 >= 0) then
					Result := ote(slItem.Objects[slItem.Count-1]);  
			end else msg('[ERROR] [GetTemplate] Game Value is out of bounds');  // This should not display under any circumstances
		end;   
	end;

	// Finalize
	if ProcessTime then begin
		stopTime := Time;
		addProcessTime('GetTemplate', TimeBtwn(startTime, stopTime));
	end;
	slKeywords.Free;
	slFiles.Free;
	slTemp.Free;
	slItem.Free;
	slBOD2.Free;
end;