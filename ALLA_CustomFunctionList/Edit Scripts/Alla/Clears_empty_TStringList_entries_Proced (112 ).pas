

// Clears empty TStringList entries
Procedure slClearEmptyStrings(aList: TStringList);
var
	slTemp: TStringList;
	i: Integer;
begin
	// Initialize
	slTemp := TStringList.Create;

	// Process
	for i := 0 to aList.Count-1 do
		if (aList[i] = '') then
			slTemp.Add(aList[i]);
	for i := 0 to slTemp.Count-1 do
		if (aList.IndexOf(slTemp[i]) >= 0) then
			aList.Delete(aList.IndexOf(slTemp[i]));

	// Finalize
	slTemp.Free;
end;