
// Gets an item type for slFuzzyItem
function GetItemType(aRecord: IInterface): String;
var
	debugMsg: Boolean;
	slTemp, slBOD2: TStringList;
	i: Integer;
begin
// End debugMsg section
	debugMsg := false;

	// Initialize
	{Debug} if debugMsg then msg('[GetItemType] GetItemType('+EditorID(aRecord)+' );');
	slTemp := TStringList.Create;
	slBOD2 := TStringList.Create;

	// Function
	if (sig(aRecord) = 'WEAP') then begin
		slTemp.CommaText := 'Sword, Bow, WarAxe, Dagger, Greatsword, Mace, Warhammer, Battleaxe';
		// Prioritize keywords
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, 'WeapType'+slTemp[i]) then begin
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Check edid/full for keywords
		for i := 0 to slTemp.Count-1 do begin
			if ContainsText(full(aRecord), slTemp[i]) or ContainsText(EditorID(aRecord), slTemp[i]) then begin
				// Exception for the string 'Sword' being within the string 'Greatsword'
				if (slTemp[i] = 'Sword') then
					if ContainsText(full(aRecord), 'Greatsword') or ContainsText(EditorID(aRecord), 'Greatsword') then
						Continue;
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Broad Default values based on skill/animation style
		if ContainsText(GetEditValue(ebp(ebs(aRecord, 'DNAM'), 'Animation Type')), 'TwoHand') or ContainsText(GetEditValue(ebp(ebs(aRecord, 'DNAM'), 'Skill')), 'TwoHand') then begin
			Result := slTemp[slTemp.Count-1];
		end else if ContainsText(GetEditValue(ebp(ebs(aRecord, 'DNAM'), 'Animation Type')), 'Bow') or ContainsText(GetEditValue(ebp(ebs(aRecord, 'DNAM'), 'Skill')), 'Archery') then begin
			Result := slTemp[1];
		end else begin
			Result := slTemp[0];
		end;
	end else if (sig(aRecord) = 'AMMO') then begin
		// Get selected record type
		slTemp.CommaText := 'Arrow, Bolt';
		// Prioritize keywords
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, 'WeapType'+slTemp[i]) then begin
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Check edid/full for keywords
		for i := 0 to slTemp.Count-1 do begin
			if ContainsText(full(aRecord), slTemp[i]) or ContainsText(EditorID(aRecord), slTemp[i]) then begin
				Result := slTemp[i];
				if debugMsg then msg('[GetItemType] '+Result+' Detected');
				slTemp.Free;
				slBOD2.Free;
				Exit;
			end;
		end;
		// Broad default value
		Result := slTemp[0];
	end else if (sig(aRecord) = 'ARMO') then begin
		// '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
		slGetFlagValues(aRecord, slBOD2, False);
		{Debug} if debugMsg then msgList('[Tier Assignment] slBOD2 := ', slBOD2, '');
		slTemp.CommaText := '30, 32, 33, 37, 39, 35, 36, 42'; // 30 - Head, 32 - Body, 33 - Gauntlets, 37 - Feet, 39 - Shield, 35 - Necklace, 36 - Ring, 42 - Circlet
		// For vanilla slots
		for i := 0 to slTemp.Count-1 do begin
			if slContains(slBOD2, slTemp[i]) then begin
				// This 'if' covers certain mods that change helmet BOD2
				if (slTemp[i] = '42') then
					if Assigned(ebp(aRecord, 'DNAM')) then
						if (geev(aRecord, 'DNAM') > 0) then
							Result := '30';
				if not Assigned(Result) then
					Result := slTemp[i];
				Break;
			end;
		end;
		// Non-vanilla slots prioritize keywords
		if debugMsg then msg('[GetItemType] Non-vanilla slots prioritize keywords');
		if (Result = '') then begin
			{Debug} if debugMsg then msg('[GetTemplate] Check Keywords');
			for i := 0 to Pred(ec(ebp(aRecord, 'KWDA'))) do begin
				{Debug} if debugMsg then msg('[GetTemplate] Keyword := '+GetEditValue(ebi(ebp(aRecord, 'KWDA'), i)));
				Result := KeywordToBOD2(GetEditValue(ebi(ebp(aRecord, 'KWDA'), i)));
				if (Result <> '') then Break;
			end;
		end;
		// Default BOD2 for items without keywords
		if debugMsg then msg('[GetItemType] Default BOD2 for items without keywords');
		if (Result = '') then begin
			{Debug} if debugMsg then msg('[GetTemplate] Check Non-Vanilla BOD2');
			// Helmet
			slTemp.CommaText := '31, 41, 55, 130, 131, 141, 150, 230';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '30';
			// Body
			slTemp.CommaText := '38, 40, 46, 49, 52, 53, 54, 56';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '32';
			// Gauntlets
			slTemp.CommaText := '38, 58, 57, 59';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '37';	
			// Boots
			slTemp.CommaText := '34';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '33';						
			// Circlet
			slTemp.CommaText := '43, 142';
			for i := 0 to slTemp.Count-1 do begin
				if slContains(slBOD2, slTemp[i]) then begin
					Result := '42';
					if Assigned(ebp(aRecord, 'DNAM')) then
						if (geev(aRecord, 'DNAM') > 0) then
							Result := '30';
				end;
			end;
			// Necklace
			slTemp.CommaText := '44, 45, 47, 143';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '35';
			// Ring
			slTemp.CommaText := '48, 60';
			for i := 0 to slTemp.Count-1 do
				if slContains(slBOD2, slTemp[i]) then
					Result := '36';
		end;
		// Convert BOD2 to EditorID
		{Debug} if debugMsg then msg('[GetTemplate] Convert BOD2 to EditorID');
		slTemp.CommaText := '30-Helmet, 32-Cuirass, 33-Gauntlets, 37-Boots, 39-Shield, 35-Necklace, 36-Ring, 42-Circlet'; // 30 - Head, 32 - Body, 33 - Gauntlets, 37 - Feet, 39 - Shield, 35 - Necklace, 36 - Ring, 42 - Circlet
		for i := 0 to slTemp.Count-1 do begin
			if ContainsText(slTemp[i], Result) then begin
				Result := StrPosCopy(slTemp[i], '-', False);
				// msg('['+full(aRecord)+'] '+Result+' Detected');
				Break;
			end;
		end;	
	end;
		
	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg section
end;