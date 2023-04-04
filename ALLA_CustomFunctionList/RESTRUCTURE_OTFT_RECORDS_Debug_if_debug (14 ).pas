
////////////////////////////////////////////////////////////////////// RESTRUCTURE OTFT RECORDS ///////////////////////////////////////////////////////////////////////////////////
    {Debug} if debugMsg then msg('[AddToOutfitAuto] FormID Detection Complete; Restructuring OTFT records');
    {Debug} if debugMsg then msgList('[AddToOutfitAuto] slOutfit := ', slOutfit, '');
		if not (slOutfit.Count > 0) then Continue;
    for i := 0 to slOutfit.Count-1 do begin
			OTFTcopy := nil;
			OTFTrecord := WinningOverride(ote(slOutfit.Objects[i])); {Debug} if debugMsg then msg('[AddToOutfitAuto] OTFTrecord := '+EditorID(OTFTrecord));
			OTFTrecord_edid := EditorID(OTFTrecord);
			// Add Masters
		
			OTFTitems := ebp(OTFTrecord, 'INAM');
			// Check for a previous script run
			if (ec(OTFTitems) = 1) and (sig(LinksTo(ebi(OTFTitems, 0))) = 'LVLI') then begin		
				{Debug} if debugMsg then msg('[AddToOutfitAuto] if tempInteger = 1 end else begin');
				masterLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (OTFTrecord_edid+'_Master'));
				// This is for outfits with a single level list that can be used in a new masterLevelList
				if not Assigned(masterLevelList) then begin
					slTemp.CommaText := '"Use All"');
					masterLevelList := createLeveledList(aPlugin, OTFTrecord_edid+'_Master', slTemp, 0);	
					vanillaLevelList := LinksTo(ebi(OTFTitems, 0));
					for y := 0 to 3 do
						addToLeveledList(masterLevelList, vanillaLevelList, 1);
					addToLeveledList(masterLevelList, inputRecord, 1);
				end;
			// This section restructures the outfit if this is the first time the script is editing this outfit
			end else begin
				// Preps the leveled lists
				{Debug} if debugMsg then msg('[AddToOutfitAuto] Creating a new vanillaLevelList and masterLevelList if not already present');
				// Check if aPlugin already has a leveled list created for vanillaLevelList
				vanillaLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (OTFTrecord_edid+'_Original'));
				{Debug} if debugMsg and Assigned(vanillaLevelList) then msg('[AddToOutfitAuto] Pre-existing vanillaLevelList := '+EditorID(vanillaLevelList))
				{Debug}	else if debugMsg and not Assigned(vanillaLevelList) then msg('[AddToOutfitAuto] Pre-existing vanillaLevelList not detected');
				if not Assigned(vanillaLevelList) then begin
					if (ec(OTFTitems) > 1) then begin
						slTemp.CommaText := '"Use All"');
						vanillaLevelList := createLeveledList(aPlugin, OTFTrecord_edid+'_Original', slTemp, 0);
						for y := 0 to Pred(ec(OTFTitems)) do
							addToLeveledList(vanillaLevelList, LinksTo(ebi(OTFTitems, y)), 1);	
					end else
						vanillaLevelList := ebi(OTFTitems, 0);
				end;
				// Create masterlevellist if not already present
				masterLevelList := ebEDID(gbs(aPlugin, 'LVLI'), (OTFTrecord_edid+'_Master'));
				{Debug} if debugMsg and Assigned(masterLevelList) then msg('[AddToOutfitAuto] Pre-existing masterLevelList := '+EditorID(masterLevelList))
				{Debug}	else if debugMsg and not Assigned(masterLevelList) then msg('[AddToOutfitAuto] Pre-existing masterLevelList not detected');	
				if not Assigned(masterLevelList) then begin
					slTemp.CommaText := '"Use All"');
					masterLevelList := createLeveledList(aPlugin, OTFTrecord_edid+'_Master', slTemp, 0);
					for y := 0 to 3 do
						addToLeveledList(masterLevelList, vanillaLevelList, 1);		 
				end;
				{Debug} if debugMsg then msg('[AddToOutfitAuto] if not LLcontains('+EditorID(masterLevellist)+', '+EditorID(inputRecord)+' ) := '+BoolToStr(LLcontains(masterLevelList, inputRecord))+' then begin');
				if not LLcontains(masterLevelList, inputRecord) then begin
					addToLeveledList(masterLevelList, inputRecord, 1);
					{Debug} if debugMsg then msg('[AddToOutfitAuto] addToLeveledList('+EditorID(masterLevelList)+', '+EditorID(inputRecord)+', 1);');
				end;
			end;
			// This finishes restructuring the outfit so that new armor sets can be added as a whole set instead of piece by piece
			{Debug} if debugMsg then msg('[AddToOutfitAuto] if HasGroup(aPlugin, ''OTFT'') := '+BoolToStr(HasGroup(aPlugin, 'OTFT'))+' then');
			OTFTcopy := ebEDID(gbs(aPlugin, 'OTFT'), OTFTrecord_edid);
			{Debug} if debugMsg then msg('[AddToOutfitAuto] if not Assigned(OTFTcopy) := '+BoolToStr(Assigned(OTFTcopy))+' then begin');
			// If there is not already an override of OTFTcopy in aPlugin then create one
			if not Assigned(OTFTcopy) then begin
				{Debug} if debugMsg then msg('[AddToOutfitAuto] OTFTcopy := CopyRecordToFile('+OTFTrecord_edid+', '+GetFileName(aPlugin)+', False, True)');
				OTFTcopy := CopyRecordToFile(OTFTrecord, aPlugin, False, True);
			end;
  debugMsg := false;
// End debugMsg Section