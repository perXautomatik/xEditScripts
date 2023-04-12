

// Returns the BOD2 slot associated with the keyword
function KeywordToBOD2(aKeyword: String): String;
var
	slTemp: TStringList;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg Section
	debugMsg := false;

	// Initialize
	slTemp := TStringList.Create;

	// Function
	{Debug} if debugMsg then msg('[KeywordToBOD2] KeywordToBOD2('+aKeyword+' );');
	slTemp.CommaText := 'ArmorHelmet, ClothingHead';
	if slContains(slTemp, aKeyword) then
		Result := '30';
	slTemp.CommaText := 'ArmorCuirass, ClothingBody';
	if slContains(slTemp, aKeyword) then
		Result := '32';
	slTemp.CommaText := 'ArmorGauntlets, ClothingHands';
	if slContains(slTemp, aKeyword) then
		Result := '33';
	slTemp.CommaText := 'ArmorBoots, ClothingFeet';
	if slContains(slTemp, aKeyword) then
		Result := '37';
	slTemp.CommaText := 'ArmorShield';
	if slContains(slTemp, aKeyword) then
		Result := '39';
	slTemp.CommaText := 'ClothingCirclet';
	if slContains(slTemp, aKeyword) then
		Result := '42';
	slTemp.CommaText := 'ClothingRing';
	if slContains(slTemp, aKeyword) then
		Result := '36';
	slTemp.CommaText := 'ClothingNecklace';
	if slContains(slTemp, aKeyword) then
		Result := '35';
	{Debug} if debugMsg then msg('[KeywordToBOD2] Result := '+Result);

	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg Section
end;