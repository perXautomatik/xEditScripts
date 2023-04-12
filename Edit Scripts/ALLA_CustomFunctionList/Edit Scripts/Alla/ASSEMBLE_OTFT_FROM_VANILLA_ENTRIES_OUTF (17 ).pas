
////////////////////////////////////////////////////////////////////// ASSEMBLE OTFT FROM VANILLA ENTRIES - OUTFIT VARIATIONS /////////////////////////////////////////////////////////////////////////////
// Begin debugMsg section
	debugMsg := false;
					if Assigned(tempLevelList) then begin
						// If an outfit Master list requires additional BOD2 slots, make a variant of tempLevelList
						for z := 0 to Pred(ec(ebs(OTFTcopy, 'INAM'))) do begin
							sl1.Clear;
							sl2.Clear;
							tempRecord := WinningOverride(LinksTo(ebi(ebp(OTFTcopy, 'INAM'), z)));
							// Get a list of expected BOD2 slots
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Get a list of expected BOD2 slots for '+EditorID(tempRecord));
							if (sig(tempRecord) = 'LVLI') then begin
								for a := 0 to Pred(LLec(tempRecord)) do begin
									if (sig(LLebi(tempRecord, a)) = 'LVLI') then begin
										sl2.AddObject(EditorID(LLebi(tempRecord, z)), LLebi(tempRecord, z));
									end else begin
										slGetFlagValues(LLebi(tempRecord, a), sl1, False);
									end;
								end;
								// This is a recursive check for nested leveled lists
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] This is a recursive check for nested leveled lists');
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] sl2.Count := '+IntToStr(sl2.Count));
								if (sl2.Count > 0) then begin
									While (sl2.Count > 0) do begin
										tempElement := ote(sl2.Objects[0]);
										if (LLec(tempElement) = 0) then begin
											sl2.Delete(0);
											Continue;
										end;
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] for a := 0 to '+IntToStr(Pred(LLec(tempElement)))+' do begin');
										for a := 0 to Pred(LLec(tempElement)) do begin
											// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] if ('+sig(LLebi(tempElement, a))+' = ''LVLI'') then begin');
											if (sig(LLebi(tempElement, a)) = 'LVLI') then begin
												// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] if not slContains(sl1, '+EditorID(LLebi(tempElement, a))+' ) then');
												if not slContains(sl1, EditorID(LLebi(tempElement, a))) then begin
													// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] sl2.Add('+EditorID(LLebi(tempElement, a))+' );');
													sl2.AddObject(EditorID(LLebi(tempElement, a)), LLebi(tempElement, a));
												end;
											end else begin
												slGetFlagValues(LLebi(tempElement, a), sl1, False);										
											end;
										end;
										sl2.Delete(0);
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] sl2.Delete('+sl2[0]+' )');
									end;
								end;
							end else begin
								sl1.Clear;	
								slGetFlagValues(tempRecord, sl1, False);
							end;
							// Check to see if the outfit contains any item or sublist covering these BOD2 slots
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check to see if the outfit contains any item or sublist covering these BOD2 slots');
							if (sl1.Count > 0) then begin
								tempBoolean := False;
								for z := 0 to Pred(LLec(tempLevelList)) do begin
									if (sig(LLebi(tempLevelList, z)) = 'LVLI') then begin
										// Check sublist
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check if '+EditorID(tempLevelList)+' sublist '+EditorID(LLebi(tempLevelList, z))+' is a script sublist');
										if ContainsText(EditorID(LLebi(tempLevelList, z)), 'BOD2') then begin
											sl2.Clear;
											tempString := Trim(StrPosCopy(EditorID(Llebi(tempLevelList, z)), ':', False));
											tempString := Trim(StrPosCopy(tempString, ')', True));										
											sl2.CommaText := tempString;
											// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
											if (sl1.Count > 0) then begin
												for a := 0 to sl1.Count-1 do
													if slContains(sl2, sl1[a]) then
														tempBoolean := True;
											end else begin
												msg('[ERROR] '+EditorID(tempRecord)+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations]');
												tempBoolean := True;
											end;
											{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check '+EditorID(LLebi(tempLevelList, z))+' sublist for ', sl1, ' := '+BoolToStr(tempBoolean));									
										// Check enchanted list
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check if '+EditorID(LLebi(tempLevelList, z))+' is an enchanted list');
										end;
									end else begin
										// Check normal item
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Check normal item');
										sl2.Clear;						
										slGetFlagValues(LLebi(tempLevelList, z), sl2, False);
										{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Checking for '+EditorID(tempRecord)+' BOD2 sl1 := ', sl1, '');
										{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] Checking for '+EditorID(LLebi(tempLevelList, z))+' BOD2 sl2 := ', sl2, '');
										// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
										if (sl1.Count > 0) then begin
											for a := 0 to sl1.Count-1 do
												if slContains(sl2, sl1[a]) then
													tempBoolean := True;
										end else begin
											msg('[ERROR] '+EditorID(tempRecord)+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations]');
											tempBoolean := True;
										end;
									end;
								end;
								// If the generated outfit does not cover all the BOD2 slots the master outfit contains, create a copy and use that instead
								// Example: Leather outfits often generate with only a cuirass. 
								// In this case, if an outfit consists of LItemBanditHelmet, LItemBanditCuirass, and LItemBanditBoots (a common setup)
								// a variant of the leveled list with just the leather cuirass would generate containing the leather cuirass, LItemBanditHelmet, and LItemBanditBoots
								if not tempBoolean then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Variations] if StrEndsWith('+EditorID(tempLevelList)+', '+EditorID(OTFTcopy)+' ) then begin');
									if StrEndsWith(EditorID(tempLevelList), EditorID(OTFTcopy)) then begin
										subLevellist := tempLevelList
									end else begin
										subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), EditorID(tempLevelList)+'_'+EditorID(OTFTcopy));
									end;
									if not Assigned(subLevelList) then begin
										subLevelList := CopyRecordToFile(tempLevelList, aPlugin, True, True);
										SetElementEditValues(subLevelList, 'EDID', EditorID(tempLevelList)+'_'+EditorID(OTFTcopy));
									end;
									if Assigned(subLevelList) then
										tempLevelList := subLevelList;
									if not LLcontains(tempLevelList, tempRecord) then
										addToLeveledList(tempLevelList, tempRecord, 1);
								end;
							end;
						end;
						// Add tempLevelList to masterLevelList if it is not already present
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] if not LLcontains('+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+' ) := '+BoolToStr(LLcontains(masterLevelList, tempLevelList))+' then begin');
						if not LLcontains(masterLevelList, tempLevelList) then begin
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList('+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
							addToLeveledList(masterLevelList, tempLevelList, 1);
						end;
					end;
					// Blacklist used items
					if not slContains(slBlacklist, slItem[x]) then
						slBlacklist.Add(slItem[x]);				
				end;
			end;
      debugMsg := false;
// End debugMsg Section