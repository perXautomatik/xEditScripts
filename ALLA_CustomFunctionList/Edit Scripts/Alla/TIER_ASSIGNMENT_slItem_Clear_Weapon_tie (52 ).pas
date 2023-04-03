
////////////////////////////////////////////////////////////////////// TIER ASSIGNMENT ////////////////////////////////////////////////////////////////////////////////////////////
	slItem.Clear;
	// Weapon tier detection
	itemType := GetItemType(aRecord);
	if (record_sig = 'WEAP') or (record_sig = 'AMMO') then begin
		{Debug} if debugMsg then msg('['+record_full+'] Begin Weapon Detection');
		// Get selected record type
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] itemType := '+itemType);
		// Assign tiers
		{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] Assign Tiers');
		if (itemType = 'Bow') then begin
			slTemp.CommaText := 'Long, Orcish, Dwarven, Elven, Glass, Ebony, Daedric, Dragonbone';
		end else
			slTemp.CommaText := 'Iron, Steel, Orcish, Dwarven, Elven, Glass, Ebony, Daedric, Dragonbone';
		for i := 0 to slTemp.Count-1 do begin
			for x := 0 to slFiles.Count-1 do begin
				{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := ebEDID(gbs('+GetFileName(ote(slFiles.Objects[x]))+', WEAP ), '+slTemp[i]+itemType+' );');
				tempRecord := ebEDID(gbs(ote(slFiles.Objects[x]), record_sig), slTemp[i]+itemType);
				if not Assigned(tempRecord) then
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[x]), record_sig), 'DLC1'+slTemp[i]+itemType);
				if not Assigned(tempRecord) then
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[x]), record_sig), 'DLC2'+slTemp[i]+itemType);
				if Assigned(tempRecord) then Break;
			end;
			if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
				slItem.AddObject(EditorID(tempRecord), tempRecord);
		end;
	end;
	// Armor tier detection
	if (record_sig = 'ARMO') then begin {Debug} if debugMsg then msg('['+record_full+'] Begin Armor Detection');
	// Get selected record type
		// Assign tiers
		{Debug} if debugMsg then msg('[GetTemplate] Assign Tiers');
		slTemp.CommaText := 'Necklace, Ring, Circlet';
		if not slContains(slTemp, itemType) then begin
			tempString := nil;
			if ee(aRecord, 'BODT') then begin
				tempString := 'BODT';
			end else
				tempString := 'BOD2';
			{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] geev('+EditorID(aRecord)+', BOD2\Armor Type) := '+geev(aRecord, 'BOD2\Armor Type'));
			if (geev(aRecord, tempString+'\Armor Type') = 'Clothing') then begin {Debug} if debugMsg then msg('[TIER ASSIGNMENT] Begin Clothing Detection');
				if (itemType = 'Cuirass') then begin
					if ContainsText(full(aRecord), 'Fine') then begin
						slItem.CommaText := '00086991, 000CEE80';
					end else
						slItem.CommaText := '0001BE1A, 000209A6, 000261C0, 0003452E';
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
				end else if (itemType = 'Helmet') then begin
					if ContainsText(full(aRecord), 'Fine') then begin
						slItem.CommaText := '000CEE84';
					end else
						slItem.CommaText := '00017696, 000330B3, 000209AA, 000330BC';		
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
				end else if (itemType = 'Gauntlets') then begin
					Result := GetRecordByFormID('000261C1');
				end else if (itemType = 'Boots') then begin
					if ContainsText(full(aRecord), 'Fine') then begin
						slItem.CommaText := '00086993, 000CEE82';
					end else
						slItem.CommaText := '0001BE1B, 000209A5, 000261BD, 0003452F';
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
				end else if (itemType = 'Necklace') then begin
					Result := GetRecordByFormID('0009171B');
				end else if (itemType = 'Ring') then begin
					Result := GetRecordByFormID('000877AB');
				end else if (itemType = 'Circlet') then begin
					Result := GetRecordByFormID('000166FF');
				end;
				slTemp.Free;
				slItem.Free;
				slBOD2.Free;
				Exit;
			end else if (geev(aRecord, tempString+'\Armor Type') = 'Light Armor') then begin {Debug} if debugMsg then msg('[TIER ASSIGNMENT] Begin Light Armor Detection');
				slTemp.CommaText := 'Hide, Leather, Elven, Scaled, Glass, Dragonscale';
				for i := 0 to slTemp.Count-1 do begin
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := ebEDID(gbs(Skyrim.esm, ARMO), Armor'+slTemp[i]+itemType+' );');
					tempRecord := MainRecordByEditorID(gbs(ote(slFiles.Objects[0]), 'ARMO'), ('Armor'+slTemp[i]+itemType));
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := '+EditorID(tempRecord));
					if (EditorID(tempRecord) <> '') and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), tempRecord);
				end;
			end else if (geev(aRecord, tempString+'\Armor Type') = 'Heavy Armor') then begin {Debug} if debugMsg then msg('[TIER ASSIGNMENT] Begin Heavy Armor Detection');
				slTemp.CommaText := 'Iron, Steel, SteelPlate, Dwarven, Orcish, Ebony, Dragonplate, Daedric';
				for i := 0 to slTemp.Count-1 do begin
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := ebEDID(gbs(Skyrim.esm, ARMO), Armor'+slTemp[i]+itemType+' );');
					if not (slTemp[i] = 'Steel') then begin
						tempRecord := MainRecordByEditorID(gbs(ote(slFiles.Objects[0]), 'ARMO'), ('Armor'+slTemp[i]+itemType));
					end else begin
						tempRecord := MainRecordByEditorID(gbs(ote(slFiles.Objects[0]), 'ARMO'), ('Armor'+slTemp[i]+itemType+'A'));
					end;
					{Debug} if debugMsg then msg('[GetTemplate] [Tier Assignment] tempRecord := '+EditorID(tempRecord));
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), tempRecord);
				end;				
			end;
		end else begin
			if (itemType = 'Circlet') then begin
				for i := 1 to 10 do begin
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[0]), 'ARMO'), 'ClothesCirclet0'+IntToStr(i));
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), tempRecord);
				end;
			end else if (itemType = 'Necklace') then begin
				slTemp.CommaText := 'Gold, GoldDiamond, GoldGems, GoldRuby, Silver, SilverEmerald, SilverGems, SilverSapphire';
				for i := 0 to slTemp.Count-1 do begin
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[0]), 'ARMO'), 'JewelryNecklace'+slTemp[i]);
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), tempRecord);
				end;
			end else if (itemType = 'Ring') then begin
				slTemp.CommaText := 'Gold, GoldDiamond, GoldEmerald, GoldSapphire, Silver, SilverAmethyst, SilverGarnet, SilverRuby';
				for i := 0 to slTemp.Count-1 do begin
					tempRecord := ebEDID(gbs(ote(slFiles.Objects[0]), 'ARMO'), 'JewelryRing'+slTemp[i]);
					if Assigned(tempRecord) and not slContains(slItem, EditorID(tempRecord)) then
						slItem.AddObject(EditorID(tempRecord), tempRecord);
				end;
			end;
		end;
	end;
	{Debug} if debugMsg then msgList('[Tier Assignment] slItem := ', slItem, '');