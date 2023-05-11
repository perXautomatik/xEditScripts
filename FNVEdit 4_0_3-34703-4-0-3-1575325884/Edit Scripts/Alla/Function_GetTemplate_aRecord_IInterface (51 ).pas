

function GetTemplate(aRecord: IInterface): IInterface;
var
	i, x, y, recordValue, slItemMaxValue, slItemMaxLength, slItemMinLength: Integer;
	tempRecord, record_sig, record_edid, record_full: IInterface;
	debugMsg, tempBoolean, ExitFunction: Boolean;
	slTemp, slItem, slBOD2, slFiles, slKeywords: TStringList;
	startTime, stopTime: TDateTime;
	tempString, itemType: String;
begin
	// Initialize
	debugMsg := true;
	if ProcessTime then
		startTime := Time;

	// Initialize
	{Debug} if debugMsg then msg('[GetTemplate] GetTemplate('+EditorID(aRecord)+' );');
	slKeywords := TStringList.Create;
	slFiles := TStringList.Create;
	slTemp := TStringList.Create;
	slItem := TStringList.Create;
	slBOD2 := TStringList.Create;

	// Common function output
	record_sig := sig(aRecord);
	record_edid := EditorID(aRecord);
	record_full := full(aRecord);

	// Detect existing plugins
	slTemp.CommaText := 'Skyrim.esm, Dawnguard.esm, Hearthfires.esm, Dragonborn.esm';
	for i := 0 to slTemp.Count-1 do
		if DoesFileExist(Trim(slTemp[i])) then
			slFiles.AddObject(Trim(slTemp[i]), FileByName(slTemp[i]));
	{Debug} if debugmsg then msg('checked vanilla files');
	// {Debug} if debugMsg then msgList('[GetTemplate] slFiles := ', slFiles, '');
	// {Debug} if debugMsg then for i := 0 to slFiles.Count-1 do msg('[GetTemplate] slFiles.Objects['+IntToStr(i)+'] := '+GetFileName(ote(slFiles.Objects[i])));

	// This section filters clothing items
	slKeywordList(aRecord, slKeywords);
	if StrWithinSL('Clothing', slKeywords) then begin
		if debugMsg then msg('filtering clothing');
		if hasKeyword(aRecord, 'fine') OR containsText(LowerCase(full(aRecord)), 'fine') then begin
			slTemp.CommaText := 'ArmorClothing, VendorItemClothing, ClothingBody';
			for i := 0 to slTemp.Count-1 do begin
				if HasKeyword(aRecord, slTemp[i]) then begin
					slItem.CommaText := '00086991, 000CEE80';
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
					exit;
				end;
			end;
			slTemp.Clear;
			slTemp.CommaText := 'ClothingHead';
			for i := 0 to slTemp.Count-1 do begin
				if HasKeyword(aRecord, slTemp[i]) then begin
					slItem.CommaText := '000CEE84';	
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
					exit;
				end;
			end;
			slTemp.Clear;
			slTemp.CommaText := 'ClothingHands';
			for i := 0 to slTemp.Count-1 do begin
				if HasKeyword(aRecord, slTemp[i]) then begin
					Result := GetRecordByFormID('000261C1');
					exit;
				end;
			end;
			slTemp.Clear;
			slTemp.CommaText := 'ClothingFeet';
			for i := 0 to slTemp.Count-1 do begin
				if HasKeyword(aRecord, slTemp[i]) then begin
					slItem.CommaText := '00086993, 000CEE82';
					Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
					exit;
				end;
			end;
		end;
		slTemp.Clear;
		//Randomize; //why is this here?
		slTemp.CommaText := 'ArmorClothing, VendorItemClothing, ClothingBody';
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, slTemp[i]) then begin
				slItem.CommaText := '0001BE1A, 000209A6, 000261C0, 0003452E';
				Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
			end;
		end;
		slTemp.CommaText := 'ClothingHead';
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, slTemp[i]) then begin
				slItem.CommaText := '00017696, 000330B3, 000209AA, 000330BC';		
				Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
			end;
		end;
		slTemp.CommaText := 'ClothingHands';
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, slTemp[i]) then begin
				Result := GetRecordByFormID('000261C1');
			end;
		end;
		slTemp.CommaText := 'ClothingFeet';
		for i := 0 to slTemp.Count-1 do begin
			if HasKeyword(aRecord, slTemp[i]) then begin
				slItem.CommaText := '0001BE1B, 000209A5, 000261BD, 0003452F';
				Result := GetRecordByFormID(slItem[Random(slItem.Count)]);
			end;
		end;
	end;