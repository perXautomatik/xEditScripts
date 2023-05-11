
// Removes invalid entries from containers and recipe items, from Leveled lists, npcs and spells [SkyrimUtils]
Procedure removeInvalidEntries(aRecord: IInterface);
var
	record_sig, refName, countname: String;
	aList, tempRecord: IInterface;
	i, aList_ec: integer;
	debugMsg: Boolean;
begin
	// Initialize
	debugMsg := false;

	// Process
	record_sig := sig(aRecord);
	// Assign areas to look through given signature
	if (record_sig = 'CONT') or (record_sig = 'COBJ') then begin
		aList := ElementByName(aRecord, 'Items');
		refName := 'CNTO\Item';
		countname := 'COCT';
	end else if (record_sig = 'LVLI') or (record_sig = 'LVLN') or (record_sig = 'LVSP') then begin
		aList := ElementByName(aRecord, 'Leveled List Entries');
		refName := 'LVLO\Reference';
		countname := 'LLCT';
	end else if (record_sig = 'OTFT') then begin
		aList := ElementByName(aRecord, 'INAM');
		refName := 'item';
	end else if (record_sig = 'ARMA') then begin
		aList := ebp(aRecord, 'Additional Races');
	end;
	if not Assigned(aList) then
		Exit;
	aList_ec := ec(aList);
	for i := aList_ec-1 downto 0 do begin
		tempRecord := ebi(aList, i);
		{Debug} if debugMsg then msg('[removeInvalidEntries] aList tempRecord := '+GetEditValue(tempRecord));
		if (refName <> '') then begin
			if (Check(ebp(tempRecord, refName)) <> '') then
				Remove(tempRecord);
		end else begin
			if (GetEditValue(tempRecord) = 'NULL - Null Reference [00000000]') then
				Remove(tempRecord);
		end;
	end;
	if Assigned(countname) then begin
		if (aList_ec <> ec(aList)) then begin
			aList_ec := ec(aList);
			if (aList_ec > 0) then
				senv(aRecord, countname, aList_ec)
			else
				RemoveElement(aRecord, countname);
		end;
	end;
end;