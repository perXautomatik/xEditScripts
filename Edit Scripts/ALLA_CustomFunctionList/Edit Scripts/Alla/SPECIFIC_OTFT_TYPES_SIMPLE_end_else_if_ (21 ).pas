
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - SIMPLE ////////////////////////////////////////////////////////////////////////////////
			end else if ContainsText(EditorID(OTFTcopy), 'Simple') then begin
				OTFTitem := RefreshList(OTFTcopy, 'INAM');
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] Simple OTFT detected');
				tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
				SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_Simple');
				Remove(ebp(tempLevelList, 'Leveled List Entries'));
				Add(tempLevelList, 'Leveled List Entries', True);
				RemoveInvalidEntries(tempLevelList);
				// Checking FULL, EditorID, and Keywords for relevant item types
				for y := 0 to Pred(LLec(inputRecord)) do begin
					LLentry := LLebi(inputRecord, y);
					slTemp.CommaText := 'Helm, Hood, Head, Boots, Shoes, Feet';
					tempBoolean := False;
					for z := 0 to slTemp.Count-1 do begin
						if ContainsText(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
						if ContainsText(full(LLentry), slTemp[z]) then tempBoolean := True;
						if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
					end;
					if tempBoolean then addToLeveledList(tempLevelList, LLentry, 1);
				end;
			end else if ContainsText(EditorID(OTFTrecord), 'Bandit') then begin
				OTFTitem := RefreshList(OTFTcopy, 'INAM');
				{Debug} if debugMsg then msg('[AddToOutfitAuto] Bandit OTFT detected');
				// Checking FULL, EDID, and Keywords for relevant item types
				for y := 0 to Pred(LLec(inputRecord)) do begin
					LLentry := LLebi(inputRecord, y);
					slTemp.CommaText := 'Gloves, Gauntlets, Hands';
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
					SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_Gauntlets50');
					subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(inputRecord)+'_SubList_Gauntlets50');
					if not Assigned(subLevelList) then
						slTemp.CommaText := '"Use All"');
						subLevelList := createLeveledList(aPlugin, EditorID(inputRecord)+'_SubList_Gauntlets50', slTemp, 50);
					if not LLcontains(subLevelList, LLebi(inputRecord, tempInteger) then begin
						{Debug} if debugMsg then msg('[AddToOutfitAuto] addToLeveledList('+EditorID(subLevelList)+', '+EditorID(LLebi(inputRecord, tempInteger))+', 1);');
						addToLeveledList(subLevelList, LLebi(inputRecord, tempInteger), 1);
					end;
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] addToLeveledList('+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					addToLeveledList(masterLevelList, tempLevelList, 1);
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end else begin
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Simple] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					SetEditValue(OTFTitem, ShortName(masterLevelList));
				end;