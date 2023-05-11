
// Reduces a BOD2 to an associated BOD2
function AssociatedBOD2(aString: String): String;
var
	slTemp: TStringList;
	i: Integer;
begin
	slTemp := TStringList.Create;

	Result := aString;
	// Helmet
	slTemp.CommaText := '31, 41, 55, 130, 131, 141, 150, 230';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '30';
	// Body
	slTemp.CommaText := '38, 40, 46, 49, 52, 53, 54, 56';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '32';
	// Gauntlets
	slTemp.CommaText := '38, 58, 57, 59';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '37';	
	// Boots
	slTemp.CommaText := '34';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '33';						
	// Circlet
	slTemp.CommaText := '43, 142';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '42';
	// Necklace
	slTemp.CommaText := '44, 45, 47, 143';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '35';
	// Ring
	slTemp.CommaText := '48, 60';
	for i := 0 to slTemp.Count-1 do
		if (aString = slTemp[i]) then
			Result := '36';
		
	slTemp.Free;
end;