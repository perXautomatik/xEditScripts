
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - NO/WITHOUT ////////////////////////////////////////////////////////////////////////////////
			end else if ContainsText(EditorID(OTFTcopy), 'No') or ContainsText(EditorID(OTFTcopy), 'without') then begin
				// Check for a keyword with the OTFT 'EDID'
				// Get a list of all keywords related to the keyword detected
				slTemp.CommaText := 'Mask, Bracers, Helmet, Hood, Crown, Shield, Buckler, Cuirass, Greaves, Boots, Gloves, Gauntlets';
				for x := 0 to slTemp.Count-1 do begin
					if ContainsText(EditorID(OTFTcopy), slTemp[x]) then begin
					  tempString := slTemp[x];
						slFuzzyItem(slTemp[x], slTemp);
						Break;
					end;
				end;
				// Checking FULL, EditorID, and Keywords for relevant item types
				OTFTitem := RefreshList(OTFTcopy, 'INAM');
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] No/Without OTFT detected');
				for y := 0 to Pred(LLec(inputRecord)) do begin				
					LLentry := LLebi(inputRecord, y);
					tempBoolean := False;
					for z := 0 to slTemp.Count-1 do begin
						if ContainsText(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
						if ContainsText(full(LLentry), slTemp[z]) then tempBoolean := True;
						if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
					end;
					if tempBoolean then begin
						tempInteger := y;
						Break;
					end;
				end;
				if tempBoolean then begin
					tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
					SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_No'+tempString);
					Remove(ebi(ebp(inputRecord, 'Leveled List Entries'), tempInteger));
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] addToLeveledList('+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					addToLeveledList(masterLevelList, tempLevelList, 1);
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end else begin
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [No/Without] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end;