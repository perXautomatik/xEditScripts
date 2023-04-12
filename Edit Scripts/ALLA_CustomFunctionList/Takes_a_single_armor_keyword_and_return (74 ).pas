
// Takes a single armor keyword and returns a list of all keywords related to it
Procedure slFuzzyItem(aString: String; aList: TStringList);
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
	for i := 0 to slTemp.Count-1 do if aString = slHelmet[i] then
		if not slContains(aList, slHelmet[i]) then
			aList.Add(slHelmet[i]);
	slTemp.CommaText := 'Bracers, Gloves, Gauntlets';
	for i := 0 to slTemp.Count-1 do if aString = slGauntlets[i] then
		if not slContains(aList, slGauntlets[i]) then
			aList.Add(slGauntlets[i]);
	slTemp.CommaText := 'Boots, Shoes';
	for i := 0 to slTemp.Count-1 do if aString = slBoots[i] then
		if not slContains(aList, slBoots[i]) then
			aList.Add(slBoots[i]);
	slTemp.CommaText := 'Cuirass, Armor';
	for i := 0 to slTemp.Count-1 do if aString = slCuirass[i] then
		if not slContains(aList, slCuirass[i]) then
			aList.Add(slCuirass[i]);
	slTemp.CommaText := 'Shield, Buckler';
	for i := 0 to slTemp.Count-1 do if aString = slShield[i] then
		if not slContains(aList, slShield[i]) then
			aList.Add(slShield[i]);
	{Debug} if debugMsg then msgList('[slFuzzyItem] Result := ', aList, '');

	// '30, 32, 33, 37, 39'; // 30 - Head, 32 - Body, 33 - Gauntlers, 37 - Feet, 39 - Shield
	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg Section
end;