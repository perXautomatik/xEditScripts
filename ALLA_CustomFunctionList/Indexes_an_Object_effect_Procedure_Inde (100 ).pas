
// Indexes an Object effect
Procedure IndexObjEffect(aRecord: IInterface; BOD2List, aList: TStringList);
var
	slTemp, slBOD2, slFlagOutput, slEnchantmentSuffix, slTempList: TStringList;
	tempString, suffix, sortingSuffix: String;
	objEffect, tempRecord: IInterface;
	debugMsg, tempBoolean: Boolean;
	startTime, stopTime: TDateTime;
	i, x, y: Integer;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;
	slEnchantmentSuffix := TStringList.Create;
	slFlagOutput := TStringList.Create;
	slTempList := TStringList.Create;
	slBOD2 := TStringList.Create;
	slTemp := TStringList.Create;
	{Debug} if debugMsg then msgList('[IndexObjEffect] input BOD2 := ', BOD2List, '');

	// Function
	slTempList.CommaText := '35, 36, 42';
	for i := 0 to Pred(ec(gbs(aRecord, 'ENCH'))) do begin

		// Clear info from previous loops
		suffix := nil;
		slEnchantmentSuffix.Clear;
		slBOD2.Assign(BOD2List);
	
		// Skip invalid records
		tempRecord := WinningOverride(ebi(gbs(aRecord, 'ENCH'), i));
		if (EditorID(objEffect) = EditorID(tempRecord)) then Continue;
		objEffect := tempRecord;  {Debug} if debugMsg then msg('[IndexObjEffect] objEffect := '+EditorID(objEffect));
		tempBoolean := False;
		tempString := EditorID(objEffect);
		slTemp.CommaText := 'Nightingale, Chillrend, Frostmere, trap, Miraak, Base, Haknir';
		if SLWithinStr(tempString, slTemp) then
			Continue;
		slTemp.Clear;
	
		// Check for recognizable EditorID
		// Check for vanilla suffix
		for x := 1 to 6 do
			if StrEndsWith(tempString, '0'+IntToStr(x)) then
				tempBoolean := True;
		// Check for Sorting Mod prefix
		if not tempBoolean then
			if (Copy(tempString, 1, 2) = 'aa') then
				tempBoolean := True;
		// Check for Eldritch Magic Enchantments Prefix
		if not tempBoolean then
			if ContainsText(tempString, 'EldEnch') then
				tempBoolean := True;
		tempString := nil;
		if not tempBoolean then Continue;
	
		// Search objEffect references for matching BOD2 slot
		for x := 0 to Pred(rbc(objEffect)) do begin
			tempRecord := rbi(objEffect, x);
			// Store reference name for suffix determination
			if ContainsText(full(tempRecord), 'of ') then
				slEnchantmentSuffix.Add(StrPosCopy(full(tempRecord), 'of ', False));
			if (slBOD2.Count <= 0) then Continue;
			// {Debug} if debugMsg then msg('[IndexObjEffect] tempRecord := '+EditorID(tempRecord));
			if (sig(tempRecord) = 'ARMO') then begin
				// Get this record's BOD2
				slFlagOutput.Clear;
				slGetFlagValues(tempRecord, slFlagOutput, False);
				if not (slFlagOutput.Count > 0) then Continue;
				// Evaluate BOD2
				for y := 0 to slFlagOutput.Count-1 do begin
					// Add clothing type to BOD2
					if not slWithinStr(slFlagOutput[y], slTempList) then
						slFlagOutput[y] := Trim(slFlagOutput[y])+'-'+Trim(geev(tempRecord, GetElementType(tempRecord)+'\Armor Type'));
					// Add to this ObjEffect's BOD2 if not already present
					if not slContains(slTemp, slFlagOutput[y]) then
						slTemp.Add(slFlagOutput[y]);
				end;
			end else
				if not slContains(slTemp, sig(tempRecord)) then
					slTemp.Add(sig(tempRecord));
			// If detected BOD2 matches input BOD2 add to this record's list
			for y := 0 to slTemp.Count-1 do begin
				if slContains(slBOD2, slTemp[y]) then begin
					tempString := Trim(tempString+' '+slTemp[y]);
					slBOD2.Delete(slBOD2.IndexOf(slTemp[y]));
				end;
			end;
		end;
		{Debug} if debugMsg then msg('[IndexObjEffect] '+EditorID(objEffect)+' slBOD2 := '+tempString);
	
		// Create slIndex entry if objEffect has valid slots
		if (tempString <> '') then begin
			// Sorting Mod Stuff
			{ sortingSuffix := nil;
			if DoesFileExist('AnotherSortingMod_2017-SSE.esp') then							
				for z := 0 to slItemTiers.Count-1 do
					if (slItemTiers.Objects[z] = tempInteger) then
						sortingSuffix := slItemTiers[z]; }
			// Determine item suffix
			suffix := MostCommonString(slEnchantmentSuffix);
			// If there is no enchantment name then use the objEffect name
			if (suffix = '') then
				suffix := StrPosCopy(full(objEffect), 'of', False);
			if (sortingSuffix <> '') then
				suffix := suffix+' '+DecToRoman(StrToInt(sortingSuffix));
	
			// Make slIndex Entry
			{Debug} if debugMsg then msg('[IndexObjEffect] aList.AddObject('+Trim(tempString)+', '+EditorID(objEffect)+' );');
			aList.AddObject(suffix+'-//-'+tempString, objEffect);
		end;
		
	end;

	//Finalize
	{Debug} if debugMsg then msgList('[IndexObjEffect] aList := ', aList, '');
	stopTime := Time;
	if ProcessTime then addProcessTime('IndexObjEffect', TimeBtwn(startTime, stopTime));
	slEnchantmentSuffix.Free;
	slFlagOutput.Free;
	slTempList.Free;
	slBOD2.Free;
	slTemp.Free;
end;