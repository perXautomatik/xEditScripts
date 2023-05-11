
// Reduces a list of armor keywords into a single armor keyword
function GetFuzzyItem(aString: String): String;
var
	slTemp: TStringList;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg Section
  debugMsg := false;

	// Initialize
	{Debug} if debugMsg then msg('[slFuzzyItem] inputString := '+aString);
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;

	// Function
	slTemp.CommaText := 'Helmet, Crown, Helm, Hood, Mask, Circlet, Headdress';
	for i := 0 to slTemp.Count-1 do if aString = slHelmet[i] then begin
		Result := 'Helmet';
		slTemp.Free;
		Exit;
	end;
	slTemp.CommaText := 'Bracers, Gloves, Gauntlets, claws';
	for i := 0 to slTemp.Count-1 do if aString = slGauntlets[i] then begin
		Result := 'Gauntlets';
 		slTemp.Free;
		Exit;
	end;
	slTemp.CommaText := 'Boots, Shoes';
	for i := 0 to slTemp.Count-1 do if aString = slBoots[i] then begin
		Result := 'Boots';
		slTemp.Free;
		Exit;
	end; 
	slTemp.CommaText := 'Cuirass, Armor';
	for i := 0 to slTemp.Count-1 do if aString = slCuirass[i] then begin
		Result := 'Cuirass';
		slTemp.Free;
		Exit;
	end;
	slTemp.CommaText := 'Shield, Buckler';
	for i := 0 to slTemp.Count-1 do if aString = slShield[i] then begin
		Result := 'Shield';
		slTemp.Free;
		Exit;
	end;
	{Debug} if debugMsg then msgList('[slFuzzyItem] Result := ', aList, '');

	// Finalize
	if Assigned(slTemp) then slTemp.Free;

	debugMsg := false;
// End debugMsg Section
end;