
////////////////////////////////////////////////////////////////////// ASSEMBLE OTFT FROM VANILLA ENTRIES - OUTFIT GENERATION /////////////////////////////////////////////////////////////////////////////
// Begin debugMsg section
	debugMsg := false;
					// Create and fill a level list for the outfit if one does not exist
					// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Create and fill a level list for the outfit');
					tempString := ('LLOutfit_'+RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(MasterOrSelf(tempRecord)))))+'_'+RemoveSpaces(CommonString));
					tempLevelList := ebEDID(gbs(aPlugin, 'LVLI'), tempString);
					{Debug} if debugMsg and Assigned(tempLevelList) then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] tempLevelList already exists; tempLevelList := '+EditorID(tempLevelList));
					if not Assigned(tempLevelList) then begin
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] tempLevelList unassigned; Creating '+tempString);
						slTemp.CommaText := '"Use All"');
						tempLevelList := createLeveledList(aPlugin, tempString, slTemp, 0);
						{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Begin vanilla outfit generation; slTempObject := ', slTempObject, '');
						for y := 0 to slTempObject.Count-1 do begin
							tempRecord := ote(slTempObject.Objects[y]);
							Record_edid := slTempObject[y];
							// Check to see if the record was used in a previous loop
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check to see if the record was used in a previous loop');
							if slContains(slBlacklist, slTempObject[y]) then Continue;
							// Check if a subLevelList is needed
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if a subLevelList is needed for '+Record_edid);
							sl1.Clear;
							sl2.Clear;
							tempBoolean := False;
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] slGetFlagValues('+slTempObject[y]+', '+GetElementType+' , ''First Person Flags''), sl1, False);');
							slGetFlagValues(tempRecord, sl1, False);
							{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] sl1 := ', sl1, '');
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for items that don''t use a primary or vanilla slot');
							// Check for items that don't use a primary or vanilla slot; All of these items get subLevelLists in order to implement a percent chance none
							sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
							for z := 0 to sl2.Count-1 do
								if slContains(sl1, sl2[z]) then
									tempBoolean := True;
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Primary slot check := '+BoolToStr(tempBoolean));
							// Check for common primary slot keywords; This is primarily for to account for mods that change the slot layout of helmets for compatability reasons
							sl2.CommaText := 'Boots, Helmet, Shield, Cuirass, Gauntlets, Shield, Hands, Head, Body, Gloves, Bracers, Ring, Robes, Hood, Mask';
							for z := 0 to sl2.Count-1 do
								if ContainsText(Record_edid, sl2[z]) or ContainsText(full(tempRecord), sl2[z]) then
									tempBoolean := True;
							tempBoolean := Flip(tempBoolean);
							// Check for subLevelLists' slots						
							if not tempBoolean then begin
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for subLevelLists'' slots');
								for z := 0 to Pred(LLec(tempLevelList)) do begin
									if (Signature(LLebi(tempLevelList, z)) = 'LVLI') then begin
										for a := 0 to sl1.Count-1 do begin
											if ContainsText(EditorID(LLebi(tempLevelList, z)), sl1[a]) then begin
												tempBoolean := True;
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] subLevelList check := '+BoolToStr(tempBoolean));
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] ContainsText('+EditorID(LLebi(tempLevelList, z))+', '+sl1[a]+' )');
												Break;
											end;
										end;
									end;
								end;
							end;						
							// Check for items that use the same slot					
							if not tempBoolean then begin
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for items that use the same slot');
								for z := 0 to slTempObject.Count-1 do begin
									if (z = y) then Continue;
									sl2.Clear;							
									slGetFlagValues(tempRecord, sl2, False);
									// {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] sl1 := ', sl1, '');
									// {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] sl2 := ', sl2, '');
									for a := 0 to sl1.Count-1 do begin
										if slContains(sl2, sl1[a]) then begin
											tempBoolean := True;
											{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] same slot check := '+BoolToStr(tempBoolean));
											// {Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slContains(',sl2, ', '+sl1[a]+' )');
											Break;
										end;
									end;
								end;
							end;
							// Create subLevelList
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Create subLevelList for '+slTempObject[y]+' := '+BoolToStr(tempBoolean));
							if tempBoolean then begin
								// Get pre-existing list or create a new one
								String1 := nil;
								for z := 0 to sl1.Count-1 do
										String1 := Trim(String1+' '+sl1[z]);
								// Check for pre-existing subLevelList
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check for pre-existing subLevelList');
								subLevelList := ebEDID(gbs(aPlugin, 'LVLI'), ('LLOutfit_'+RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(MasterOrSelf(tempRecord)))))+'_'+RemoveSpaces(CommonString)+'_SubList_(BOD2: '+String1+')'));
								if Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Pre-existing sublist '+EditorID(subLevelList)+' detected; if not LLcontains('+EditorID(tempLevelList)+', '+Record_edid+' ) := '+BoolToStr(LLcontains(tempLevelList, tempRecord))+' then begin');
									if not LLcontains(subLevelList, tempRecord) then begin
										addToLeveledList(subLevelList, tempRecord, 1);
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList('+EditorID(tempLevelList)+', '+slTempObject[y]+', 1);');										
									end;
									// Blacklist used items
									if not slContains(slBlacklist, Record_edid) then
										slBlackList.Add(Record_edid);
								end;
								// Create subLevelList if not already assigned
								if not Assigned(subLevelList) then begin
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Creating new subLevelList');
									slTemp.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count"';
									subLevelList := createLeveledList(aPlugin, ('LLOutfit_'+RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile((MasterOrSelf(tempRecord))))))+'_'+RemoveSpaces(CommonString)+'_SubList_(BOD2: '+String1+')'), slTemp, 0);
									{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList('+EditorID(subLevelList)+', '+Record_edid+', 1);');
									addToLeveledList(subLevelList, tempRecord, 1);
									// Items in non-primary or non-vanilla slots get an 80 percent chance none; This should include scarves, necklaces, etc.
									sl2.Clear;
									sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
									tempBoolean := False;
									for z := 0 to sl2.Count-1 do
										if ContainsText(String1, sl2[z]) then
											tempBoolean := True;
									// Check for common primary slot keywords; This is primarily for to account for mods that change the slot layout of helmets for compatability reasons
									sl2.CommaText := 'Boots, Helmet, Shield, Cuirass, Gauntlets, Shield, Hands, Head, Body, Gloves, Bracers, Ring, Robes, Hood, Mask';
									for z := 0 to sl2.Count-1 do
										if ContainsText(Record_edid, sl2[z]) or ContainsText(full(tempRecord), sl2[z]) then
											tempBoolean := True;
									if not tempBoolean then
										senv(subLevelList, 'LVLD', 80); // Percent chance none
									// Blacklist used items
									if not slContains(slBlackList, Record_edid) then
										slBlackList.Add(Record_edid);									
								end;
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Identify Records by BOD2');
								// Identify Records by BOD2			
								for z := 0 to slTempObject.Count-1 do begin
									tempElement := ote(slTempObject.Objects[z]);
									sl2.Clear;						
									slGetFlagValues(tempElement, sl2, False);
									tempInteger := 0;
									for a := 0 to sl1.Count-1 do begin
										for b := 0 to sl2.Count-1 do begin
											if ContainsText(sl2[b], sl1[a]) then begin
												// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] ContainsText('+sl2[b]+', '+sl1[a]+' )');
												Inc(tempInteger);											
											end;
										end;
									end;
									if (tempInteger = sl1.Count) then begin
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] if not LLcontains('+EditorID(subLevelList)+', '+slTempObject[z]+' ) := '+BoolToStr(LLcontains(subLevelList, tempElement))+' then begin');
										if not LLcontains(subLevelList, tempElement) then begin
											{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList('+EditorID(subLevelList)+', '+slTempObject[z]+', 1);');
											addToLeveledList(subLevelList, tempElement, 1);
										end;
										// Blacklist used items
										if not slContains(slBlackList, slTempObject[z]) then
											slBlackList.Add(slTempObject[z]);
									end;
								end;						
								// Check if the leveled list contains a template for an enchanted list
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if the leveled list contains a template for an enchanted list');
								for a := 0 to slEnchantedList.Count-1 do begin
									for b := 0 to Pred(LLec(subLevelList)) do begin
										tempElement := ote(slEnchantedList.Objects[a]);
										if ee(LLebi(tempElement, 0), 'CNAM') then begin
											if (EditorID(LinksTo(ebs(LLebi(tempElement, 0), 'CNAM'))) = EditorID(LLebi(subLevelList, b))) then begin
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace('+EditorID(subLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[a]+' );');
												if not LLcontains(tempLevelList, tempElement) then
													LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
											end;
										end else if ee(LLebi(tempElement, 0), 'TNAM') then begin
											if (EditorID(LinksTo(ebs(LLebi(tempElement, 0), 'TNAM'))) = EditorID(LLebi(subLevelList, b))) then begin
												{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace('+EditorID(subLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[a]+' );');
												if not LLcontains(tempLevelList, tempElement) then
													LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
											end;
										end;
									end;
								end;
								// Check if another leveled list also covers the same BOD2 parts
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if another leveled list also covers the same BOD2 parts');
								tempBoolean := False;
								for z := 0 to Pred(LLec(tempLevelList)) do begin
									if (Signature(LLebi(tempLevelList, z)) = 'LVLI') then begin
										for a := 0 to sl1.Count-1 do begin
											if ContainsText(EditorID(LLebi(tempLevelList, z)), sl1[a]) then begin
												String1 := StrPosCopy(EditorID(LLebi(tempLevelList, z)), '(', False);
												String1 := StrPosCopy(String1, ')', True);
												sl2.CommaText := String1;
												if (sl1.Count < sl2.Count) then begin
													if not LLcontains(LLebi(tempLevelList, z), subLevelList) then begin
														addToLeveledList(LLebi(tempLevelList, z), subLevelList, 1);
														tempBoolean := True;
														// Removes duplicate elements in the leveled list one level above
														// Example: A sublist for slot 40 is created and contains all items that occupy slot 40.  There is already a list in tempLevelList for items with slot 40 and slot 42.
														// This removes items that have slot bot slot 40 and slot 42, leaving only slot 40 items in the sublist
														for b := 0 to Pred(LLec(tempLevelList)) do
															if LLcontains(subLevelList, LLebi(tempLevelList, b)) then
																LLremove(subLevelList, LLebi(tempLevelList, b));
														// Sub-sublists don't need a percent chance none
														if ElementExists(subLevelList, 'LVLD') then
															Remove(ebs(subLevelList, 'LVLD'));
													end;
												end else if (sl1.Count > sl2.Count) then begin
													LLreplace(tempLevelList, LLebi(tempLevelList, z), subLevelList);
													if not LLcontains(subLevelList, LLebi(tempLevelList, z)) then begin
														{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] addToLeveledList('+EditorID(subLevelList)+', '+EditorID(LLebi(tempLevelList, z))+', 1);');
														addToLeveledList(subLevelList, LLebi(tempLevelList, z), 1);
														tempBoolean := True;
														// Removes duplicate elements in the leveled list one level above
														for b := 0 to Pred(LLec(subLevelList)) do
															if LLcontains(tempLevelList, LLebi(tempLevelList, b)) then
																LLremove(tempLevelList, LLebi(tempLevelList, b));
														// Sub-sublists don't need a percent chance none
														if ElementExists(tempLevelList, 'LVLD') then
															Remove(ebs(TempLevelList, 'LVLD'));															
													end;
												end;
											end;
										end;
									end;
								end;
								if not tempBoolean and not LLcontains(tempLevelList, subLevelList) then
									addToLeveledList(tempLevelList, subLevelList, 1);
							end else begin
								if not LLcontains(tempLevelList, tempRecord) then
									addToLeveledList(tempLevelList, tempRecord, 1);
								// Blacklist used items
								if not slContains(slBlackList, slTempObject[y]) then
									slBlacklist.Add(slTempObject[y]);
							end;
						end;
						// Check if the leveled list contains a template for an enchanted list
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if the leveled list contains a template for an enchanted list');
						for z := 0 to slEnchantedList.Count-1 do begin
							for a := 0 to Pred(LLec(tempLevelList)) do begin
								tempElement := ote(slEnchantedList.Objects[z]);
								if ee(LLebi(tempElement, 0), 'CNAM') then begin
									if EditorID(LinksTo(ebs(LLebi(tempElement, 0), 'CNAM'))) = EditorID(LLebi(subLevelList, b)) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace('+EditorID(tempLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[z]+' );');
										if not LLcontains(tempLevelList, tempElement)) then
											LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
									end;
								end else if ee(LLebi(tempElement, 0), 'TNAM') then begin
									if EditorID(LinksTo(ebs(LLebi(tempElement, 0), 'TNAM'))) = EditorID(LLebi(subLevelList, b)) then begin
										{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLreplace('+EditorID(tempLevelList)+', '+EditorID(LLebi(subLevelList, b))+', '+slEnchantedList[z]+' );');
										if not LLcontains(tempLevelList, tempElement) then
											LLreplace(tempLevelList, LLebi(subLevelList, b), tempElement);
									end;
								end;
							end;
						end;
						// Remove outfits with no primary vanilla BOD2 slots
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check '+EditorID(tempLevelList)+' for primary vanilla BOD2 slots');
						tempBoolean := False;
						for z := 0 to Pred(LLec(tempLevelList)) do begin
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] LLebi(tempLevelList, z) := '+EditorID(LLebi(tempLevelList, z)));
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] sig(LLebi(tempLevelList, z)) := '+sig(LLebi(tempLevelList, z)));
							if (sig(LLebi(tempLevelList, z)) = 'LVLI') then begin
								// Check sublist
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check if '+EditorID(tempLevelList)+' sublist '+EditorID(LLebi(tempLevelList, z))+' is a script sublist');
								// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] if ContainsText(EditorID('+EditorID(LLebi(tempLevelList, z))+', ''BOD2'') then begin');
								if ContainsText(EditorID(LLebi(tempLevelList, z)), 'BOD2') or ContainsText(EditorID(LLebi(tempLevelList, z)), 'Ench') then begin
									sl1.Clear;
									tempString := Trim(StrPosCopy(EditorID(Llebi(tempLevelList, z)), ':', False));
									tempString := Trim(StrPosCopy(tempString, ')', True));
									sl1.CommaText := tempString;
									sl2.Clear;
									sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
									// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
									if (sl1.Count > 0) then begin
										for a := 0 to sl1.Count-1 do
											if slContains(sl2, sl1[a]) then
												tempBoolean := True;
									end else begin
										msg('[ERROR] '+EditorID(LLebi(tempLevelList, z))+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation]');
										tempBoolean := True;
									end;
								end;
							end else begin
								// Check normal item
								{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Check '+EditorID(tempLevelList)+' for a normal item');
								sl1.Clear;						
								slGetFlagValues(LLebi(tempLevelList, z), sl1, False);
								sl2.CommaText := '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
								// This 'if' prevents tempLevelList deletion if the BOD2 list doesn't generate correctly
								if (sl1.Count > 0) then begin
									for a := 0 to sl1.Count-1 do
										if slContains(sl2, sl1[a]) then
											tempBoolean := True;
								end else begin
									msg('[ERROR] '+EditorID(LLebi(tempLevelList, z))+' expected BOD2 did not generate correctly - [AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation]');
									tempBoolean := True;
								end;
							end;
						end;
						if not tempBoolean then begin
							sl1.Clear;
							{Debug} if debugMsg then for z := 0 to Pred(LLec(tempLevelList)) do sl1.Add(EditorID(LLebi(tempLevelList, z)));
							{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] '+EditorID(tempLevelList)+' := ', sl1, '');
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] Remove('+EditorID(tempLevelList)+' )');
							Remove(tempLevelList);
							Continue;
						end else begin
							{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries - Outfit Generation] '+EditorID(tempLevelList)+' does contain primary vanilla BOD2 slots');
						end;					
					end;
	debugMsg := false;
// End debugMsg section