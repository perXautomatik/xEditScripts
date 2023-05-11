

// Creates new COBJ record to make item temperable [SkyrimUtils]
function MakeTemperable(aRecord: IInterface; lightInteger, heavyInteger: Integer; aPlugin: IInterface): IInterface;
var
	recipeTemper, recipeCondition, tempRecord: IInterface;
	tempBoolean: Boolean;
	slTemp: TStringList;
	record_sig: String;
	debugMsg: Boolean;
	ki,e, i: Integer;
	keywords, keyword, ci: IInterface;
begin
// Begin debugMsg section
	debugMsg := false;

	// Initialize
	slTemp := TStringList.Create;

	// CHECK FOR PRE-EXISTING

	// Common function output
	{Debug} if debugMsg then msg('[MakeTemperable] MakeTemperable('+EditorID(aRecord)+', '+IntToStr(lightInteger)+', '+IntToStr(heavyInteger)+', '+GetFileName(aPlugin)+' );');
	record_sig := sig(aRecord);
	{Debug} if debugMsg then msg('[MakeTemperable] record_sig := '+record_sig);

  // Filter invalid records
	tempBoolean := False;
	if Assigned(ebp(aRecord, 'CNAM')) then
		tempBoolean := True;
	if not tempBoolean then
		if not ((record_sig = 'WEAP') or (record_sig = 'ARMO') or (record_sig = 'AMMO')) then
			tempBoolean := True;
	slTemp.CommaText := 'Circlet, Ring, Necklace';
	if not tempBoolean then
		if StrWithinSL(full(aRecord), slTemp) or StrWithinSL(EditorID(aRecord), slTemp) then
			tempBoolean := True;
	if not tempBoolean then
		for i := 0 to Pred(rbc(aRecord)) do
			if (sig(rbi(aRecord, i)) = 'COBJ') and ContainsText(EditorID(rbi(aRecord, i)), 'Temper') then
				tempBoolean := True;
	if not tempBoolean then
		if IsClothing(aRecord) then
			tempBoolean := True;
	if IsClothing(aRecord) then
		tempBoolean := True;
	if tempBoolean then begin
		slTemp.Free;
		Exit;
	end;
		
	// Add conditions
	{Debug} if debugMsg then msg('[MakeTemperable] Add conditions');
	recipeTemper := FindRecipe(false,HashedTemperList,aRecord, aPlugin);
	if assigned(recipeTemper) then begin
		{Debug} if debugMsg then msg('Recipe Found for: ' + Name(aRecord) + ' emptying');
		beginUpdate(recipeTemper);
		try
			for e := ElementCount(ElementByPath(recipeTemper, 'Items')) - 1 downto 0 do
			begin
				RemoveByIndex(ElementByPath(recipeTemper, 'Items'), e, false);
			end;
			for e := ElementCount(ElementByPath(recipeTemper, 'Conditions')) - 1 downto 0 do
			begin
				RemoveByIndex(ElementByPath(recipeTemper, 'Conditions'), e, false);
			end;
		finally endUpdate(recipeTemper);
		end;
	end;
	if not assigned(recipeTemper) then begin
		{Debug} if debugMsg then msg('No Recipe Found for: ' + Name(aRecord) + ' Generating new one');
		recipeTemper := CreateRecord(aPlugin,'COBJ');
		// add reference to the created object
		SetElementEditValues(recipeTemper, 'CNAM', Name(aRecord));
		// set Created Object Count
		SetElementEditValues(recipeTemper, 'NAM1', '1');
	end;
	Add(recipeTemper, 'Conditions', True);
	//RemoveInvalidEntries(recipeTemper);
	recipeCondition := ebp(recipeTemper, 'Conditions');
	BeginUpdate(recipeCondition);
	try
		seev(ebp(recipeCondition, 'Condition\CTDA'), 'Type', '00010000');
		seev(ebp(recipeCondition, 'Condition\CTDA'), 'Comparison Value', '1');
		seev(ebp(recipeCondition, 'Condition\CTDA'), 'Function', 'EPTemperingItemIsEnchanted');
		seev(ebp(recipeCondition, 'Condition\CTDA'), 'Run On', 'Subject');
		seev(ebp(recipeCondition, 'Condition\CTDA'), 'Parameter #3', '-1');
	finally
		EndUpdate(recipeCondition);
	end;
	AddPerkCondition(ebp(recipeTemper, 'Conditions'), GetRecordByFormID('0005218E')); // ArcaneBlacksmith
 
	{Debug} if debugMsg then msg('[MakeTemperable] if record_sig := '+record_sig+' = WEAP then begin');
	if (record_sig = 'WEAP') then begin
		seev(recipeTemper, 'BNAM', GetEditValue(GetRecordByFormID('00088108')));
			{Debug} if debugMsg then msg('[MakeTemperable] GetFileName(GetFile(aRecord)) := '+GetFileName(GetFile(aRecord)));
		seev(recipeTemper, 'EDID', 'TemperWeapon_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
	end;
	{Debug} if debugMsg then msg('[MakeTemperable] if record_sig := '+record_sig+' = ARMO then begin');
	if (record_sig = 'ARMO') then begin
		seev(recipeTemper, 'BNAM', GetEditValue(GetRecordByFormID('000ADB78')));
			{Debug} if debugMsg then msg('[MakeTemperable] GetFileName(GetFile(aRecord)) := '+GetFileName(GetFile(aRecord)));
		seev(recipeTemper, 'EDID', 'TemperArmor_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
	end;
	// Add valid combinations
	slTemp.Clear;
	// Weapon
	slTemp.AddObject('WeapMaterialIron', GetRecordByFormID('0005ACE4'));
	slTemp.AddObject('WeapMaterialSteel', GetRecordByFormID('0005ACE5'));
	slTemp.AddObject('WeapMaterialElven', GetRecordByFormID('0005ADA0'));
	slTemp.AddObject('WeapMaterialDwarven', GetRecordByFormID('000DB8A2'));
	slTemp.AddObject('WeapMaterialEbony', GetRecordByFormID('0005AD9D'));
	slTemp.AddObject('WeapMaterialDaedric', GetRecordByFormID('0005AD9D'));
	slTemp.AddObject('WeapMaterialWood', GetRecordByFormID('0006F993'));
	slTemp.AddObject('WeapMaterialSilver', GetRecordByFormID('0005ACE3'));
	slTemp.AddObject('WeapMaterialOrcish', GetRecordByFormID('0005AD99'));
	slTemp.AddObject('WeapMaterialGlass', GetRecordByFormID('0005ADA1'));
	slTemp.AddObject('WeapMaterialFalmer', GetRecordByFormID('0003AD57'));
	slTemp.AddObject('WeapMaterialFalmerHoned', GetRecordByFormID('0003AD57'));
	slTemp.AddObject('DLC1WeapMaterialDragonbone', GetRecordByFormID('0003ADA4'));
	slTemp.AddObject('DLC2WeaponMaterialStalhrim', GetRecordByFormID('0402B06B'));
	// Armor
	slTemp.AddObject('ArmorMaterialIron', GetRecordByFormID('0005ACE4'));
	slTemp.AddObject('ArmorMaterialStudded', GetRecordByFormID('0005ACE4'));
	slTemp.AddObject('ArmorMaterialElven', GetRecordByFormID('0005AD9F'));
	slTemp.AddObject('DLC2ArmorMaterialChitinLight', GetRecordByFormID('0402B04E'));
	slTemp.AddObject('DLC2ArmorMaterialChitinHeavy', GetRecordByFormID('0402B04E'));
	slTemp.AddObject('DLC1ArmorMaterielFalmerHeavy', GetRecordByFormID('0003AD57'));
	slTemp.AddObject('DLC1ArmorMaterielFalmerHeavyOriginal', GetRecordByFormID('0003AD57'));
	slTemp.AddObject('DLC1ArmorMaterialFalmerHardened', GetRecordByFormID('0402B06B'));
	slTemp.AddObject('DLC2ArmorMaterialBonemoldLight', GetRecordByFormID('0401CD7C'));
	slTemp.AddObject('DLC2ArmorMaterialBonemoldHeavy', GetRecordByFormID('0401CD7C'));
	slTemp.AddObject('ArmorMaterialScaled', GetRecordByFormID('0005AD93'));
	slTemp.AddObject('ArmorMaterialIronBanded', GetRecordByFormID('0005AD93'));
	slTemp.AddObject('DLC2ArmorMaterialStalhrimLight', GetRecordByFormID('0402B06B'));
	slTemp.AddObject('DLC2ArmorMaterialStalhrimHeavy', GetRecordByFormID('0402B06B'));
	slTemp.AddObject('DLC2ArmorMaterialNordicLight', GetRecordByFormID('0005ADA0'));
	slTemp.AddObject('DLC2ArmorMaterialNordicHeavy', GetRecordByFormID('0005ADA0'));
	slTemp.AddObject('ArmorMaterialElvenGilded', GetRecordByFormID('0005ADA0'));
	slTemp.AddObject('ArmorMaterialHide', GetRecordByFormID('000DB5D2'));
	slTemp.AddObject('ArmorMaterialLeather', GetRecordByFormID('000DB5D2'));
	slTemp.AddObject('DLC2ArmorMaterialMoragTong', GetRecordByFormID('000DB5D2'));
	slTemp.AddObject('ArmorMaterialSilver', GetRecordByFormID('0005ACE3'));
	slTemp.AddObject('ArmorMaterialGlass', GetRecordByFormID('0005ADA1'));
	slTemp.AddObject('ArmorMaterialEbony', GetRecordByFormID('0005AD9D'));
	slTemp.AddObject('ArmorMaterialDaedric', GetRecordByFormID('0005AD9D'));
	slTemp.AddObject('ArmorMaterialDwarven', GetRecordByFormID('000DB8A2'));
	slTemp.AddObject('ArmorMaterialDragonscale', GetRecordByFormID('0003ADA3'));
	slTemp.AddObject('ArmorMaterialDragonplate', GetRecordByFormID('0003ADA4'));
	slTemp.AddObject('ArmorMaterialSteel', GetRecordByFormID('0005ACE5'));
	slTemp.AddObject('ArmorMaterialImperialHeavy', GetRecordByFormID('0005ACE5'));
	slTemp.AddObject('ArmorMaterialImperialLight', GetRecordByFormID('0005ACE5'));
	slTemp.AddObject('ArmorMaterialSteelPlate', GetRecordByFormID('0005ACE5'));
	slTemp.AddObject('ArmorMaterialStormcloak', GetRecordByFormID('0005ACE5'));
	slTemp.AddObject('ArmorMaterialImperialStudded', GetRecordByFormID('0005ACE5'));
	slTemp.AddObject('DLC1ArmorMaterialDawnguard', GetRecordByFormID('0005ACE5'));
	// Detect value
	if slTemp.Count > 0 then begin
		Add(recipeTemper, 'items', true);
		for i := 0 to slTemp.Count-1 do begin
			{Debug} if debugMsg then msg('[MakeTemperable] if HasKeyword('+EditorID(aRecord)+', '+slTemp[i]+' ) then begin');
			if HasKeyword(aRecord, slTemp[i]) then begin
				{Debug} if debugMsg then msg('[MakeTemperable] addItem('+EditorID(recipeTemper)+', '+EditorID(ote(slTemp.Objects[i]))+', 1);');
				addItem(recipeTemper, ote(slTemp.Objects[i]), 1);
			end;
		end;
	end else begin
		msg('[ERROR] [MakeTemperable] Keyword list did not generate');
		//Remove(recipeTemper);
		Exit;
	end;
	removeInvalidEntries(recipeTemper);
	{
	// If a vanilla keyword is not detected
	if (geev(recipeTemper, 'COCT') = '') then begin
		tempRecord := GetTemplate(aRecord);
		for i := 0 to slTemp.Count-1 do begin
			if debugMsg then msg('[MakeTemperable] if HasKeyword('+EditorID(tempRecord)+', '+slTemp[i]+' ) then begin');
			if HasKeyword(tempRecord, slTemp[i]) then begin
				if debugMsg then msg('[MakeTemperable] addItem('+EditorID(recipeTemper)+', '+EditorID(ote(slTemp.Objects[i]))+', 1);');
				if ee(aRecord, 'BOD2') then begin
					if debugMsg then msg('[MakeTemperable] if (geev(aRecord, BOD2\Armor Type) := '+geev(aRecord, 'BOD2\Armor Type')+' = Heavy Armor ) then begin');
					if (geev(aRecord, 'BOD2\Armor Type') = 'Heavy Armor') then begin
						addItem(recipeTemper, ote(slTemp.Objects[i]), heavyInteger);
					end else if (geev(aRecord, 'BOD2\Armor Type') = 'Light Armor') then
						addItem(recipeTemper, ote(slTemp.Objects[i]), lightInteger);
				end else if ee(aRecord, 'DNAM\Skill') or ee(aRecord, 'DNAM\Animation Type') then begin
					if (geev(aRecord, 'DNAM\Skill') =  'Two Handed') or ContainsText(geev(aRecord, 'DNAM\Animation Type'), 'TwoHand') then begin
						addItem(recipeTemper, ote(slTemp.Objects[i]), heavyInteger);
					end else
						addItem(recipeTemper, ote(slTemp.Objects[i]), lightInteger);
				end else
					addItem(recipeTemper, ote(slTemp.Objects[i]), lightInteger);
			end;
		end;	
	end;
	}
	//above is where an unknown is found something to get it a temper recipe

	if GetElementEditValues(recipeTemper, 'COCT') = '' then begin
		{debug} if debugmsg then msg('[MakeTemperable] there was no vanilla keyword useable for a temper recipe');
		Keywords := ElementByPath(aRecord, 'KWDA');
		for ki := 0 to elementcount(keywords) - 1 do begin
			keyword := ElementByIndex(Keywords, ki);
			if materiallist.indexof(EDitorID(keyword)) > 0 then begin
				{debug} if debugmsg then msg('found valid keyword in ini');
			
				CurrentMaterials := materiallist.objects[materiallist.indexof(EDitorID(keyword))];
				ci := objecttoelement(currentmaterials.objects[0]);
				if not EditorID(ci) = 'LeatherStrips' then YggAdditem(recipeitems, ci, 1)
				else YggAdditem(recipeitems, ObjectToElement(currentmaterials.objects[1]), 1);
			
			end;
		end;
	end;

	{Debug} if debugMsg then msg('[makeTemperable] Result := '+EditorID(recipeTemper));
	Result := recipeTemper;

	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg section
end;