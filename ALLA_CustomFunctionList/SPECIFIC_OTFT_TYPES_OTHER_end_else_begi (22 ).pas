
////////////////////////////////////////////////////////////////////// SPECIFIC OTFT TYPES - OTHER ////////////////////////////////////////////////////////////////////////////////			
			end else begin
			{Debug} if debugMsg then msg('[AddToOutfitAuto] [Other] Other OTFT detected; SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+' );');
			slTemp.CommaText := 'Shield, Buckler';
			tempBoolean := False;
			for y := 0 to Pred(ec(ebp(OTFTrecord, 'INAM'))) do begin
				for z := 0 to slTemp.Count-1 do begin
					if ContainsText(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
					if ContainsText(full(LLentry), slTemp[z]) then tempBoolean := True;
					if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
				end;
				if tempBoolean then tempInteger := y;
			end;
			OTFTitem := RefreshList(OTFTcopy, 'INAM');
			if tempBoolean then begin
				tempBoolean := False;
				for y := 0 to Pred(LLec(inputRecord)) do begin
					tempRecord := LLebi(inputRecord, y);
					for z := 0 to slTemp.Count-1 do begin
						if ContainsText(EditorID(LLentry), slTemp[z]) then tempBoolean := True;
						if ContainsText(full(LLentry), slTemp[z]) then tempBoolean := True;
						if HasKeyword(LLentry, 'Armor'+slTemp[z]) or HasKeyword(LLentry, 'Clothing'+slTemp[z]) then tempBoolean := True;
					end;
				end;
				if tempBoolean then begin
					tempLevelList := CopyRecordToFile(inputRecord, aPlugin, True, True);
					SetElementEditValues(tempLevelList, 'EDID', EditorID(inputRecord)+'_NoShield');
					RemoveElement(ebi(ebp(tempLevelList, 'Leveled List Entries'), tempInteger));
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Other] addToLeveledList('+EditorID(masterLevelList)+', '+EditorID(tempLevelList)+', 1);');
					{Debug} if debugMsg then msg('[AddToOutfitAuto] [Other] SetEditValue('+GetEditValue(ebi(ebp(OTFTcopy, 'INAM'), 0))+', '+ShortName(masterLevelList)+' );');
					addToLeveledList(masterLevelList, tempLevelList, 1);
					SetEditValue(OTFTitem, ShortName(masterLevelList));	   
				end else SetEditValue(OTFTitem, ShortName(masterLevelList));
			end else SetEditValue(OTFTitem, ShortName(masterLevelList));	
	  end;
	end;

	// Finalize
	if Assigned(slEnchantedList) then slEnchantedList.Free;
	if Assigned(slStringList) then slStringList.Free;
	if Assigned(slTempObject) then slTempObject.Free;
	if Assigned(slBlacklist) then slBlacklist.Free;
	if Assigned(slLevelList) then slLevelList.Free;
	if Assigned(slOutfit) then slOutfit.Free;
	if Assigned(slItem) then slItem.Free;
	if Assigned(slTemp) then slTemp.Free;
	if Assigned(slpair) then slpair.Free;
	if Assigned(sl1) then sl1.Free;
	if Assigned(sl2) then sl2.Free;

  debugMsg := false;
// End debugMsg Section
end;