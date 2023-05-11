
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - INTEGER ////////////////////////////////////////////////////////////////////////////////
			if (slPair.Count > 0) then begin {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Integer] slpair := ', slPair, '');
				// This is checking the input level list for keywords similiar to the identified keyword
				// This is ghetto fuzzy logic.  Example: If the pre-check identifies 'Gauntlets' then this
				// section would check the input record for entries containing 'Gauntlets, Gloves';			
				tempBoolean := False;
				{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Integer] slpair := ', slpair, '');
				for x := 0 to slpair.Count-1 do begin		
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Integer] slFuzzyItem('+slpair.Names[x]+', ', slTemp, ' )');
					// Check for inputRecord for all keywords related to the keyword detected in the OTFT 'EditorID' or 'INAM' items
					slTemp.Clear;
					slFuzzyItem(slpair.Names[x], slTemp); {Debug} if debugMsg and (x = 0) then msgList('[AddToOutfitAuto] [Integer] slTemp := ', slTemp, '');
					tempLevelList := nil;
					for y := 0 to Pred(LLec(inputRecord)) do begin
						tempRecord := LLebi(inputRecord, y); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] tempRecord := '+EditorID(tempRecord));
						for z := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] if ContainsText('+EditorID(tempRecord)+', '+slTemp[z]+' ) or ContainsText('+full(tempRecord)+', '+slTemp[z]+' ) or HasKeyword('+EditorID(tempRecord)+', Armor'+slTemp[z]+' ) or HasKeyword('+EditorID(tempRecord)+', Clothing'+slTemp[z]+' ) then begin');
							if ContainsText(EditorID(tempRecord), slTemp[z]) or ContainsText(full(tempRecord), slTemp[z]) or HasKeyword(tempRecord, 'Armor'+slTemp[z]) or HasKeyword(tempRecord, 'Clothing'+slTemp[z]) then begin
							  // If more than one integer-keyword pair is detected we need to account for both (e.g. Shield20Helmet50
							  tempString := nil;
								for a := 0 to slpair.Count-1 do
									tempString := tempString+slpair.Names[a]+slpair.ValueFromIndex[a]; {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] tempString := '+tempString);
								// Check if aPlugin already has an identically named variant of inputRecord
								// The result needs to be true for any combination of slpair entries
								// Example: Either Gauntlets50Helmet50 or Helmet50Gauntlets50 will return true
								if not Assigned(tempLevelList) then begin
									for a := 0 to Pred(ec(gbs(aPlugin, 'LVLI'))) do begin
										tempInteger := 0;
										for b := 0 to slpair.Count-1 do
											if ContainsText(EditorID(ebi(gbs(aPlugin, 'LVLI'), a)), EditorID(inputRecord)) and ContainsText(EditorID(ebi(gbs(aPlugin, 'LVLI'), a)), slpair.Names[b]+slpair.ValueFromIndex[b]) then
												Inc(tempInteger);
										if (tempInteger = slpair.Count) then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] Pre-existing variant of inputRecord detected: '+EditorID(ebi(gbs(aPlugin, 'LVLI'), a)));								 
											tempLevelList := ebi(gbs(aPlugin, 'LVLI'), a);
											Break;
										end;
									end;
								end else if debugMsg then msg('[AddToOutfitAuto] [Integer] tempLevelList already assigned');
								// Create a new level list if a pre-existing one is not detected; This is a variant of inputRecord, NOT the sublist
								if not Assigned(tempLevelList) then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] '+EditorID(inputRecord)+' variant not detected; Creating '+EditorID(inputRecord)+'_'+tempString+' level list');						
									tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
									SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_'+tempString);
								end;
								// Check if aPlugin already has an identically named sublist
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] Checking for pre-existing '+(EditorID(inputRecord)+'_Sublist_'+slpair.Names[x]+slPair.ValueFromIndex[x])+' subLevelList');
								subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (EditorID(inputRecord)+'_SubList_'+slpair.Names[x]+slPair.ValueFromIndex[x]));
								// Add subLevelList to tempLevelList if not already added
								if Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] if not LLcontains('+EditorID(tempLevelList)+', '+EditorID(subLevelList)+' ) := '+BoolToStr(LLcontains(tempLevelList, subLevelList))+' then begin');
									if not LLcontains(tempLevelList, subLevelList) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] addToLeveledList('+EditorID(tempLevelList)+', '+EditorID(subLevelList)+', 1);');
										addToLeveledList(tempLevelList, subLevelList, 1);
									end;
								end;
								// Create a new sub level list if a pre-existing one is not detected
								if not Assigned(subLevelList) then begin
									slTemp.CommaText := '"Use All"');
									subLevelList := createLeveledList(aPlugin, (EditorID(inputRecord)+'_SubList_'+slpair.Names[x]+slPair.ValueFromIndex[x]), slTemp, (100-StrToInt(slpair.ValueFromIndex[x])));
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] addToLeveledList('+EditorID(subLevelList)+', '+EditorID(tempRecord)+', 1);');
									addToLeveledList(subLevelList, tempRecord, 1);
							  end;
								if Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] if not LLcontains('+EditorID(tempLevelList)+', '+EditorID(subLevelList)+' ) := '+BoolToStr(LLcontains(tempLevelList, subLevelList))+' then begin');
									if not LLcontains(tempLevelList, subLevelList) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] LLreplace('+EditorID(tempLevelList)+', '+EditorID(tempRecord)+', '+EditorID(subLevelList)+' );');
										LLreplace(tempLevelList, tempRecord, subLevelList);
									end;
								end;
							end;
						end;
					end;
				end;			
				OTFTitem := RefreshList(OTFTcopy, 'INAM'); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] Refreshing '+EditorID(OTFTcopy)+' ''INAM'' Element');
				// Add the finished variant of the inputRecord level list to the OTFT
				if Assigned(tempLevelList) then begin
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] LLreplace('+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+');');
					LLreplace(masterLevelList, inputRecord, tempLevelList);
					SetEditValue(OTFTitem, ShortName(masterLevelList)); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Integer] SetEditValue('+GetEditValue(OTFTitem)+', ShortName('+EditorID(tempLevelList)+' ) := '+ShortName(tempLevelList)+' )');
				end else
					msg('[AddToOutfitAuto] [ERROR] tempLevelList output not generated for: '+EditorID(OTFTcopy));