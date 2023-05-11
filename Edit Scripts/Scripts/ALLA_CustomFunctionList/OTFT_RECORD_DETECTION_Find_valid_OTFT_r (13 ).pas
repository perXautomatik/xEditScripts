
////////////////////////////////////////////////////////////////////// OTFT RECORD DETECTION ///////////////////////////////////////////////////////////////////////////////////////
	// Find valid OTFT records
  {Debug} if debugMsg then msg('[AddToOutfitAuto] Begin OTFT Record Detection');
  {Debug} if debugMsg then msg('[AddToOutfitAuto] for i := 0 to Pred(rbc(masterRecord)) :='+IntToStr(Pred(rbc(masterRecord)))+' do begin');
  for i := 0 to Pred(rbc(masterRecord)) do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] LVLIrecord := '+EditorID(rbi(masterRecord, i)));
    slTempObject.Clear;
		LVLIrecord := rbi(masterRecord, i); {Debug} if debugMsg then msg('[AddToOutfitAuto] if (sig(LVLIrecord) := '+sig(LVLIrecord)+'= ''LVLI'') then begin');
		if (sig(LVLIrecord) = 'LVLI') then begin
			// Check for outfits that reference a list of items of a specific type (e.g. Boots, Gauntlets)
			while (sig(LVLIrecord) = 'LVLI') do begin		
				{Debug} if debugMsg then msg('[AddToOutfitAuto] for x := 0 to Pred(rbc(LVLIrecord)) := '+IntToStr(Pred(rbc(LVLIrecord)))+' do begin');
				for x := 0 to Pred(rbc(LVLIrecord)) do begin {Debug} if debugMsg then msg('[AddToOutfitAuto] OTFTrecord := rbi(LVLIrecord, x) := '+EditorID(rbi(LVLIrecord, x))+';');
					OTFTrecord := rbi(LVLIrecord, x); {Debug} if debugMsg then msg('[AddToOutfitAuto] if IsWinningOVerride(OTFTrecord) := '+BoolToStr(IsWinningOVerride(OTFTrecord))+' and (sig(OTFTrecord) := '+sig(OTFTrecord)+' = ''OTFT'') and ContainsText(EditorID(OTFTrecord), ''Armor'') := '+BoolToStr(ContainsText(EditorID(OTFTrecord), 'Armor'))+' then begin');
					if (sig(OTFTrecord) = 'OTFT') then begin
						if not IsWinningOverride(OTFTrecord) then Continue;
						// Check if OTFT references LVLI or is referenced more than once (to exclude outfits specifically for a single NPC)
						tempBoolean := False;
						if (rbc(OTFTrecord) > 1) then tempBoolean := True;
						if not tempBoolean then
							for y := 0 to Pred(ec(ebp(OTFTrecord, 'INAM'))) do
								if (sig(ebi(ebp(OTFTrecord, 'INAM'), y)) = 'LVLI') then
									tempBoolean := True;
						if tempBoolean and (sig(OTFTrecord) = 'OTFT') then
							if not slContains(slOutfit, EditorID(OTFTrecord)) then
								slOutfit.AddObject(EditorID(OTFTrecord), OTFTrecord);
					end else if (sig(LVLIrecord) = 'LVLI') then begin
						slTempObject.AddObject(EditorID(OTFTrecord), OTFTrecord);
					end;
				end;
				if (slTempObject.Count > 0) then begin
					LVLIrecord := ote(slTempObject.Objects[0]);
					slTempObject.Delete(0);
				end else begin
					Break;
				end;
			end;
		end else begin
			OTFTrecord := rbi(masterRecord, i); {Debug} if debugMsg then msg('[AddToOutfitAuto] if (sig(OTFTrecord) := '+sig(OTFTrecord)+'= ''LVLI'') then begin');
			if IsWinningOverride(OTFTrecord) and (sig(OTFTrecord) = 'OTFT') then
				if not slContains(slOutfit, EditorID(OTFTrecord)) then
					slOutfit.AddObject(EditorID(OTFTrecord), OTFTrecord);
		end;
  end;