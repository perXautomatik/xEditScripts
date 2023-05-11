

Procedure GenderOnlyArmor(aString: String; aRecord, aPlugin: IInterface);
var
	tempRecord, tempElement, copyRecord, armorAddonRecord, armorAddonCopy, templateRecord, templateAddonRecord, Races: IInterface;
	slTemp: TStringList;
	debugMsg, LoadOrder: Boolean;
	i: Integer;
begin
	// Initialize
	debugMsg := false;
	LoadOrder := False;
	aRecord := WinningOverride(aRecord);
	slTemp := TStringList.Create;
	{Debug} if debugMsg then msg('[GenderOnlyArmor] GenderOnlyArmor('+aString+', '+EditorID(aRecord)+', '+GetFileName(aPlugin)+' );');
	if not ((aString = 'Male') or (aString = 'Female')) then begin
		msg('[GenderOnlyArmor] '+aString+' not ''Male'' or ''Female''');
		Exit;
	end;
	if (GetPrimarySlot(aRecord) = '00') then Exit;
	templateRecord := ote(GetObject(EditorID(aRecord)+'Template', slGlobal));
	copyRecord := aRecord; {Debug} if debugMsg then msg('[GenderOnlyArmor] copyRecord := '+EditorID(aRecord));
	armorAddonRecord := LinksTo(ebp(aRecord, 'Armature\MODL')); {Debug} if debugMsg then msg('[GenderOnlyArmor] armorAddonRecord := '+EditorID(armorAddonRecord));
	if (GetLoadOrder(GetFile(aRecord)) = GetLoadOrder(aPlugin)) then
		LoadOrder := True; // Specifies if an Override is generated

	// Process
	{Debug} if debugMsg then msg('[GenderOnlyArmor] if ContainsText(aString, Female) then begin := '+BoolToStr(ContainsText(aString, 'Female')));
	if (aString = 'Male') then begin
		{Debug} if debugMsg then msg('[GenderOnlyArmor] Male-Only Armor Detected');
		// Worn Armor (Armor Addon)
		if not (Length(geev(armorAddonRecord, 'Female world model\MOD3')) > 0) then begin
			if not LoadOrder then
				armorAddonRecord := CopyRecordToFile(LinksTo(ebp(aRecord, 'Armature\MODL')), aPlugin, False, True);
			Add(armorAddonRecord, 'Female world model', True);
			Add(armorAddonRecord, 'Female world model\MOD3', True);
			seev(armorAddonRecord, 'Female world model\MOD3', geev(WinningOverride(templateRecord), 'Female world model\MOD3'));
			if not (Length(geev(armorAddonRecord, 'Female world model\MOD3')) > 0) then
				seev(armorAddonRecord, 'Female world model\MOD3', geev(WinningOverride(templateRecord), 'Male world model\MOD2'));
		end;
		// Remove ElderRace
		for i := 0 to Pred(ec(ebp(armorAddonRecord, 'Additional Races'))) do begin
			if ContainsText(GetEditValue(ebi(ebp(armorAddonRecord, 'Additional Races'), i)), 'ElderRace') then begin
				armorAddonCopy := ebEDID(gbs(aPlugin, 'ARMO'), EditorID(armorAddonRecord));
				if not Assigned(armorAddonCopy) then
					armorAddonCopy := CopyRecordToFile(armorAddonRecord, aPlugin, False, True);
				{Debug} if debugMsg then msg('[GenderOnlyArmor] GetEditValue(ebi(ebp(armorAddonCopy, 'Additional Races'), i)) := '+GetEditValue(ebi(ebp(armorAddonCopy, 'Additional Races'), i)));
				slTemp.Add(GetEditValue(ebi(ebp(armorAddonCopy, 'Additional Races'), i)));
				Remove(ebi(ebp(armorAddonCopy, 'Additional Races'), i));
			end;
		end;
		// Ground Armor
		if not (Length(geev(aRecord, 'Female world model\MOD4')) > 0) then begin
			if not LoadOrder then
				copyRecord := CopyRecordToFile(aRecord, aPlugin, False, True);
			Add(copyRecord, 'Female world model', True);
			Add(copyRecord, 'Female world model\MOD4', True);
			seev(copyRecord, 'Female world model\MOD4', geev(WinningOverride(templateRecord), 'Female world model\MOD4'));
			if not (Length(geev(copyRecord, 'Female world model\MOD4')) > 0) then
				seev(copyRecord, 'Female world model\MOD4', geev(WinningOverride(templateRecord), 'Male world model\MOD2'));
		end;
	end else if ContainsText(aString, 'Female') then begin
		{Debug} if debugMsg then msg('[GenderOnlyArmor] Female-Only Armor Detected');
		// Worn Armor (Armor Addon)
		if not (Length(geev(armorAddonRecord, 'Male world model\MOD2')) > 0) then begin {Debug} if debugMsg then msg('[GenderOnlyArmor] Worn Armor Begin');
			if not LoadOrder then
				armorAddonRecord := CopyRecordToFile(LinksTo(ebp(aRecord, 'Armature\MODL')), aPlugin, False, True);
			Add(armorAddonRecord, 'Male world model', True);
			Add(armorAddonRecord, 'Male world model\MOD2', True);
			seev(armorAddonRecord, 'Male world model\MOD2', geev(LinksTo(ebp(WinningOverride(templateRecord), 'Armature\MODL')), 'Male world model\MOD2'));
		end;
		// Remove ElderRace
		for i := 0 to Pred(ec(ebp(armorAddonRecord, 'Additional Races'))) do begin
			if ContainsText(GetEditValue(ebi(ebp(armorAddonRecord, 'Additional Races'), i)), 'ElderRace') then begin
				armorAddonCopy := ebEDID(gbs(aPlugin, 'ARMO'), EditorID(armorAddonRecord));
				if not Assigned(armorAddonCopy) then
					armorAddonCopy := CopyRecordToFile(armorAddonRecord, aPlugin, False, True);
				{Debug} if debugMsg then msg('[GenderOnlyArmor] GetEditValue(ebi(ebp(armorAddonCopy, ''Additional Races''), i)) := '+GetEditValue(ebi(ebp(armorAddonCopy, 'Additional Races'), i)));
				slTemp.Add(GetEditValue(ebi(ebp(armorAddonCopy, 'Additional Races'), i)));
				Remove(ebi(ebp(armorAddonCopy, 'Additional Races'), i));
			end;
		end;
		// Ground Armor
		{Debug} if debugMsg then msg('[GenderOnlyArmor] geev(aRecord, Male world model\MOD2) := '+geev(aRecord, 'Male world model\MOD2'));	
		if not (Length(geev(aRecord, 'Male world model\MOD2')) > 0) then begin
			if not LoadOrder then
				copyRecord := CopyRecordToFile(aRecord, aPlugin, False, True);
			Add(copyRecord, 'Male world model', True);
			Add(copyRecord, 'Male world model\MOD2', True);
			seev(copyRecord, 'Male world model\MOD2', geev(WinningOverride(templateRecord), 'Male world model\MOD2'));
		end;
	end else
		msg('[GenderOnlyArmor] aString := '+aString+' does not contain ''Male'' or ''Female''');
	
		// Create a new Armor Addon for ElderRace
		if (slTemp.Count > 0) then begin
			{Debug} if debugMsg then msg('[GenderOnlyArmor] Create a new Armor Addon for ElderRace');
			{Debug} if debugMsg then msgList('[GenderOnlyArmor] slTemp := ', slTemp, '');
			templateAddonRecord := CopyRecordToFile(LinksTo(ebp(templateRecord, 'Armature\MODL')), aPlugin, True, True);
			seev(templateAddonRecord, 'EDID', EditorID(armorAddonRecord)+'_OldPeople');
			{Debug} if debugMsg then msg('[GenderOnlyArmor] templateAddonRecord := '+EditorID(templateAddonRecord));
			RefreshList(templateAddonRecord, 'Additional Races');
			for i := 0 to slTemp.Count-1 do begin
				tempElement := ElementAssign(ebp(templateAddonRecord, 'Additional Races'), HighInteger, nil, False);
				SetEditValue(tempElement, slTemp[i]);
			end;
			RemoveInvalidEntries(templateAddonRecord);
		if not (GetLoadOrder(GetFile(copyRecord)) = GetLoadOrder(aPlugin)) then
			copyRecord := CopyRecordToFile(aRecord, aPlugin, False, True);
			tempElement := ElementAssign(ebp(copyRecord, 'Armature'), HighInteger, nil, False);
			SetEditValue(tempElement, Name(templateAddonRecord));		
		end;
	
		// Finalize
		slTemp.Free;
end;