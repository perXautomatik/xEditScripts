

function MakeBreakdown(aRecord, aPlugin: IInterface): IInterface;
var
	cobj, items, item, recipeRecord, tempRecord: IInterface;
	i, tempInteger, count, LeatherCount, x, hc, rc: integer;
	debugMsg, tempBoolean: Boolean;
	slTemp, slItem: TStringList;
  edid: string;
begin
// Begin debugMsg section
	debugMsg := false;

	// Initialize
	{Debug} if debugMsg then msgList('[MakeBreakdown] slGlobal := ', slGlobal, '');
	{Debug} if debugMsg then msg('[MakeBreakdown] MakeBreakdown('+EditorID(aRecord)+', '+GetFileName(aPlugin)+' );');
	slTemp := TStringList.Create;
	slItem := TStringList.Create;

	// Load crafting recipe or skip records that already have a breakdown recipe
	for i := 0 to Pred(rbc(aRecord)) do begin
		tempRecord := rbi(aRecord, i);
		if (sig(tempRecord) = 'COBJ') then begin
			if ContainsText(EditorID(tempRecord), 'Recipe') then begin
				{Debug} if debugMsg then msg('[MakeBreakdown] Crafting recipe: '+EditorID(tempRecord));
				cobj := tempRecord;
			end else if ContainsText(EditorID(tempRecord), 'Breakdown') then begin
				{Debug} if debugMsg then msg('[MakeBreakdown] Breakdown already exists: '+EditorID(tempRecord));
				slTemp.Free;
				slItem.Free;
				Exit;
			end;
		end;
	end;

	// Skip invalid records
	{Debug} if debugMsg then msg('[MakeBreakdown] Skip invalid records');
	tempBoolean := False;
	if not Assigned(cobj) then
		tempBoolean := True;
	if not Boolean(GetObject('BreakdownEnchanted', slGlobal)) then
		if Assigned(ebp(cobj, 'EITM')) then
			tempBoolean := True;
	if not Boolean(GetObject('BreakdownDaedric', slGlobal)) then
		if HasItem(cobj, 'DaedraHeart') then
			tempBoolean := True;
	if not Boolean(GetObject('BreakdownDLC', slGlobal)) then begin
		slTemp.CommaText := 'DragonBone, DragonScales, DLC2ChitinPlate, ChaurusChitin, BoneMeal';
		for i := 0 to slTemp.Count-1 do
			if HasItem(cobj, slTemp[i]) then
				tempBoolean := True;
	end;
	if tempBoolean then begin
		slTemp.Free;
		slItem.Free;
		Exit;
	end;

	// Common Function Output
	{Debug} if debugMsg then msg('[MakeBreakdown] Common Function Output');
	items := ebp(cobj, 'Items');
	LeatherCount := 0;

	// Process ingredients
	{Debug} if debugMsg then msg('[MakeBreakdown] Process ingredients');
	for i := 0 to Pred(ec(items)) do begin
		item := LinksTo(ebp(ebi(items, i), 'CNTO - Item\Item'));
		count := geev(ebi(items, i), 'CNTO - Item\Count');	
		edid := EditorID(item);
		{Debug} if debugMsg then msg('[MakeBreakdown] edid := '+edid);
		{Debug} if debugMsg then msg('[MakeBreakdown] count := '+IntToStr(count));
		// if (edid = 'LeatherStrips') then Continue; // Why shouldn't leather strips be copied?
		slTemp.CommaText := 'ingot, bone, scale, chitin, stalhrim';
		for x := 0 to slTemp.Count-1 do
			if ContainsText(edid, slTemp[x]) then
				slItem.AddObject(Name(item), count);
		if (edid = 'Leather01') then
			LeatherCount := count;
	end;
	{Debug} if debugMsg then msgList('[MakeBreakdown] slItem := ', slItem, '');
	{Debug} if debugMsg then msg('[MakeBreakdown] LeatherCount := '+IntToStr(LeatherCount));

	// Create breakdown recipeRecord at smelter or tanning rack
	{Debug} if debugMsg then msg('[MakeBreakdown] Create breakdown recipeRecord at smelter or tanning rack');
	if (slItem.Count > 0) then begin
		// Create at smelter
		{Debug} if debugMsg then msg('[MakeBreakdown] Create at smelter');
		if (slItem.Count = 1) and (Integer(slItem.Objects[0]) = 1) then begin
			// Skip making breakdown recipeRecord, can't produce less than 1 ingot
			{Debug} if debugMsg then msg('[MakeBreakdown] Skip making breakdown recipeRecord, can''t produce less than 1 ingot');
		end else begin		
			recipeRecord := Add(gbs(aPlugin, 'COBJ'), 'COBJ', True); {Debug} if debugMsg then msg('[MakeBreakdown] Make breakdown recipeRecord');	
			slTemp.CommaText := 'EDID, COCT, Items, CNAM, BNAM, NAM1'; {Debug} if debugMsg then msg('[MakeBreakdown] Add elements');
			BeginUpdate(recipeRecord);
			try
				for i := 0 to slTemp.Count-1 do
					Add(recipeRecord, slTemp[i], True);
				seev(recipeRecord, 'EDID', 'Breakdown'+StrCapFirst(sig(aRecord))+'_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
				senv(recipeRecord, 'BNAM', $000A5CCE); // CraftingSmelter
			finally
				EndUpdate(recipeRecord);
			end;
			AddGetItemCountCondition(recipeRecord, ShortName(aRecord), Boolean(GetObject('BreakdownEquipped', slGlobal)));
			// Add items
			{Debug} if debugMsg then msg('[MakeBreakdown] Add items');
			items := ebp(recipeRecord, 'Items');
			item := ebi(items, 0);
			seev(item, 'CNTO - Item\Item', ShortName(aRecord));
			seev(item, 'CNTO - Item\Count', 1);
			seev(recipeRecord, 'COCT', 1);
			// Set created object stuff
			hc := 0;
			x := -1;
			for i := 0 to slItem.Count-1 do begin
				// Skip single items
				// if (Integer(slItem.Objects[i])-1 <= 0) then Continue;
				// Use first Item subelement or create new one
				if (Integer(slItem.Objects[i]) >= hc) then begin
					hc := Integer();
					x := i;
				end;
			end;
			if (x > -1) then begin
				seev(recipeRecord, 'CNAM', slItem[x]);
				tempInteger := Integer(slItem.Objects[x])-1;
				if (tempInteger = 0) then
					tempInteger := 1;
				seev(recipeRecord, 'NAM1', tempInteger);
			end else begin
				{Debug} if debugMsg then msg('[MakeBreakdown] Remove(recipeRecord)');
				Remove(recipeRecord);
			end;
			Inc(rc);
		end;
	end else if (LeatherCount > 0) then begin {Debug} if debugMsg then msg('[MakeBreakdown] Create at tanning rack');
		recipeRecord := Add(gbs(aPlugin, 'COBJ'), 'COBJ', True);
		slTemp.CommaText := 'EDID, COCT, Items, CNAM, BNAM, NAM1';
		BeginUpdate(recipeRecord);
		try
			for i := 0 to slTemp.Count-1 do
				Add(recipeRecord, slTemp[i], True);
			seev(recipeRecord, 'EDID', 'Breakdown'+StrCapFirst(sig(aRecord))+'_'+Trim(RemoveSpaces(RemoveFileSuffix(GetFileName(GetFile(aRecord)))))+'_'+Trim(EditorID(aRecord)));
			senv(recipeRecord, 'BNAM', $0007866A); // CraftingTanningRack
			AddGetItemCountCondition(recipeRecord, ShortName(aRecord), Boolean(GetObject('BreakdownEquipped', slGlobal)));
			// Add items to recipeRecord
			items := ebp(recipeRecord, 'Items');
			item := ebi(items, 0);
			seev(item, 'CNTO - Item\Item', ShortName(aRecord));
			seev(item, 'CNTO - Item\Count', 1);
			seev(recipeRecord, 'COCT', 1);
			// Set created object stuff
			senv(recipeRecord, 'CNAM', $000800E4); // LeatherStrips
			seev(recipeRecord, 'NAM1', 2);
		finally
			EndUpdate(recipeRecord);
		end;
		Inc(rc);
  end;

	// Finalize
	slTemp.Free;
	slItem.Free;

	debugMsg := false;
// End debugMsg section
end;