
////////////////////////////////////////////////////////////////////// ASSEMBLE OTFT FROM VANILLA ENTRIES - RECORD IDENTIFICATION /////////////////////////////////////////////////////////////////////////////
// Begin debugMsg Section
	debugMsg := false;
			slEnchantedList.Clear;
			slBlacklist.Clear;
			slLevelList.Clear;
			slItem.Clear;
			slTemp.Clear;
			// Check if OTFT contains LVLI
			tempBoolean := False;
			// Checks if OTFT has a LVLI to be processed
			for x := 0 to Pred(ec(ebp(OTFTcopy, 'INAM'))) do begin
				if (sig(LinksTo(ebi(ebp(OTFTcopy, 'INAM'), x))) = 'LVLI') then begin
					tempBoolean := True;
					Break;
				end;
			end;
			{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] '+EditorID(OTFTcopy)+' contains LVLI := '+BoolToStr(tempBoolean));
			// Get a complete list of all items and enchanted sets
			{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Get a complete list of all items and enchanted sets');
			if tempBoolean then begin
				for x := 0 to Pred(ec(ebp(OTFTcopy, 'INAM'))) do begin
					// Commonly used functions; This is just to reduce the number of complicated functions that are called (and therefore reduce processing time)
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Commonly used functions');
					tempRecord := WinningOverride(LinksTo(ebi(ebp(OTFTcopy, 'INAM'), x)));
					Record_edid := EditorID(tempRecord);
					// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+EditorID(tempRecord));
					tempBoolean := False;
					// Check lists for an identical item
					if slContains(slEnchantedList, Record_edid) or slContains(slLevelList, Record_edid) or slContains(slItem, Record_edid) then
						tempBoolean := True;
					// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] ItemAlreadyAdded := '+BoolToStr(tempBoolean));
					if not tempBoolean then begin
						if (sig(tempRecord) = 'LVLI') then begin
							if ContainsText(EditorID(tempRecord), 'Ench') then begin							
								if not slContains(slEnchantedList, Record_edid) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slEnchantedList.Add('+EditorID(tempRecord)+' );');
									slEnchantedList.AddObject(Record_edid, tempRecord);
								end;
							end else begin
								if not slContains(slLevelList, Record_edid) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slTemp.Add(EditorID('+EditorID(tempRecord)+' ));');
									slLevelList.AddObject(Record_edid, tempRecord);
								end;
							end;
						end else begin
							if not slContains(slItem, Record_edid) then begin
								// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem.Add(EditorID('+EditorID(tempRecord)+' ));');
								slItem.AddObject(Record_edid, tempRecord);
							end;
						end;
					end;
					// Leveled lists are often nested multiple times. This 'while' loop adds all their entries to a single list
					{Debug} if debugMsg and (slLevelList.Count > 0) then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Leveled lists are often nested multiple times. This ''while'' loop adds all their entries to a single list');
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slLevelList := ', slLevelList, '');
					while (slLevelList.Count > 0) do begin										
						for y := 0 to Pred(LLec(ote(slLevelList.Objects[0]))) do begin
							tempRecord := WinningOverride(LLebi(ote(slLevelList.Objects[0]), y));
							Record_edid := EditorID(tempRecord);
							if not (Length(EditorID(tempRecord)) > 0) then Continue;
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+Record_edid);
							if (sig(tempRecord) = 'LVLI') then begin
								if ContainsText(EditorID(tempRecord), 'Ench') then begin
									if not slContains(slEnchantedList, Record_edid) then begin
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slEnchantedList.Add(EditorID('+Record_edid+' ));');
										slEnchantedList.AddObject(Record_edid, tempRecord);
									end;
								end else begin
									if not slContains(slLevelList, Record_edid) then begin
										// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slTempObject.Add(EditorID('+Record_edid+' ));');
										slTempObject.AddObject(Record_edid, tempRecord);
									end;
								end;
							end else begin
								if not slContains(slItem, Record_edid) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem.Add(EditorID('+Record_edid+' ));');
									slItem.AddObject(Record_edid, tempRecord);
								end;
							end;
						end;
						// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slLevelList.Delete('+slLevelList[0]+' );');
						slLevelList.Delete(0);
						if (slLevelList.Count = 0) then begin
						  for z := 0 to slTempObject.Count-1 do begin
								if not slContains(slLevelList, slTempObject[z]) then begin
									// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slLevelList.Add('+slTempObject[z]+' );');
									slLevelList.AddObject(slTempObject[z], ote(slTempObject.Objects[z]));
								end;
							end;
							slTempObject.Clear;
						end;
						if (slLevelList.Count = -1) then Break;
					end;				
				end;
				// If there are enchanted lists, replace them with a 'template' record.  For the sake of simplicity it will be replaced with the enchanted list later
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] If there are enchanted lists, make sure the original record is in the items list.  For the sake of simplicity it will be replaced with the enchanted list later');
				for x := 0 to slEnchantedList.Count-1 do begin
					// Grab the template for the enchanted list.  These are also nested often
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+EditorID(WinningOverride(ote(slEnchantedList.Objects[x]))));
					tempRecord := WinningOverride(ote(slEnchantedList.Objects[x]));
					while (sig(tempRecord) = 'LVLI') do begin
						tempRecord := LLebi(tempRecord, 0);
						{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] tempRecord := '+EditorID(tempRecord));
					end;
					// Check the list for the template item
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Check the list for the template item');
					if not slContains(slItem, EditorID(GetEnchTemplate(tempRecord))) then begin
						// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem.Add('+EditorID(tempRecord)+' );');
						slItem.AddObject(EditorID(GetEnchTemplate(tempRecord)), GetEnchTemplate(tempRecord));
					end;
				end;
				// This is the main section where similiar items are added to an outfit
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] This is the main section where similiar items are added to an outfit');
				{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slItem := ', slItem, '');
				for x := 0 to slItem.Count-1 do begin			
					slStringList.Clear;
					// Exclude entries already added to lists by this script
					if slContains(slBlacklist, slItem[x]) then Continue
					// Delete common junk words
					slTemp.CommaText := 'Mask, Bracers, Armor, Helmet, Hood, Crown, Shield, Buckler, Cuirass, Greaves, Boots, Gloves, Gauntlets, Hood';
					slStringList.CommaText := full(WinningOverride(ote(slItem.Objects[x])));
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slStringList := ', slStringList, '');			
					for y := 0 to slTemp.Count-1 do
						if slContains(slStringList, slTemp[y]) then
							slStringList.Delete(slStringList.IndexOf(slTemp[y]));				
					if slStringList.Count = 0 then Continue;
					slTempObject.Clear;
					// Search all slItem records for similiar words to the current record with decreasing levels of precision
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Search all slItem records for similiar words to the current record with decreasing levels of precision');
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slStringList := ', slStringList, '');
					for y := 0 to slStringList.Count-1 do begin
						CommonString := nil;
						for z := slStringList.Count-1 downto 0 do begin
							CommonString := Trim(CommonString+' '+slStringList[z]);
							// {Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] [Decreasing Precision] CommonString := '+CommonString);
						end;
						for z := 0 to slItem.Count-1 do
							if ContainsText(full(ote(slItem.Objects[z])), CommonString) then
								if not (z = x) then
									if not slContains(slTempObject, slItem[z]) then
										slTempObject.AddObject(slItem[z], slItem.Objects[z]);
						if (slTempObject.Count > 1) then Break;
					end;
					if not (slTempObject.Count > 1) then Continue;
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] Decreasing Precision Output := '+CommonString);
					{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Assemble OTFT From Vanilla Entries] slTempObject := ', slTempObject, '');
	debugMsg := false;
// End debugMsg section