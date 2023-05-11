
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - PRE-CHECK ////////////////////////////////////////////////////////////////////////////////
// Begin debugMsg Section
      debugMsg := false;		
			// Checks for integer-keyword pairs (e.g. Shield20 becomes 20=Shield)
			// This checks each OTFT item for an integer-keyword pair (e.g. Shield20 becomes 20=Shield)
			slTemp.Clear;
			slpair.Clear;		
			slTemp.CommaText := 'Bracers, Helmet, Hood, Crown, Shield, Buckler, Cuirass, Greaves, Boots, Gloves, Gauntlets';
			tempBoolean := False;
			for x := 0 to Pred(ec(ebp(OTFTcopy, 'INAM'))) do begin
				tempRecord := LinksTo(ebi(ebp(OTFTcopy, 'INAM'), x)); {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] tempRecord := '+EditorID(tempRecord));
				{Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if sig('+EditorID(tempRecord)+' ) := '+sig(tempRecord)+' = ''LVLI'' then begin');
				if (sig(tempRecord) = 'LVLI') then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if (IntWithinStr(EditorID(tempRecord)) := '+IntToStr(IntWithinStr(EditorID(tempRecord)))+' ) <> -1) then begin');
					if (IntWithinStr(EditorID(tempRecord)) <> -1) then begin
						for y := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if ContainsText('+EditorID(tempRecord)+', '+slTemp[y]+' ) then begin');
							if ContainsText(EditorID(tempRecord), slTemp[y]) then begin
								for z := 0 to slpair.Count-1 do
								  if slpair.Names[z] = slTemp[y] then
									  tempBoolean := True;
							  if not tempBoolean then begin
								  slpair.Add(slAddValue(IntToStr(IntWithinStr(EditorID(tempRecord))), slTemp[y]));							
									{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Pre-Check] slpair := ', slpair, '');
								end;
							end;
						end;
					end;
				end;
			end;
			// This checks the OTFT EditorID for an integer-keyword pair
			if (IntWithinStr(EditorID(OTFTcopy)) <> -1) then begin
				for y := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if (IntWithinStr(EditorID(OTFTcopy) := '+IntToStr(IntWithinStr(EditorID(OTFTcopy)))+' <> -1) then begin');
					if (IntWithinStr(EditorID(OTFTcopy)) <> -1) then begin {Debug} if debugMsg then msg('[AddToOutfitAuto] [Pre-Check] if ContainsText('+EditorID(OTFTcopy)+', '+slTemp[y]+' ) then begin');
						if ContainsText(EditorID(OTFTcopy), slTemp[y]) then begin
							for z := 0 to slpair.Count-1 do
								if slpair.Names[z] = slTemp[y] then
									tempBoolean := True;
							if not tempBoolean then begin
								slpair.Add(slAddValue(IntToStr(IntWithinStr(EditorID(OTFTcopy))), slTemp[y]));	
								{Debug} if debugMsg then msgList('[AddToOutfitAuto] [Pre-Check] slpair := ', slpair, '');
							end;
						end;
					end;
				end;		
			end;