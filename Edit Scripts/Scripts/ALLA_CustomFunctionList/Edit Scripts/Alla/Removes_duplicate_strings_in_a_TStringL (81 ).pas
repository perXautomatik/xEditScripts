

// Removes duplicate strings in a TStringList
Procedure slRemoveDuplicates(aList: TStringList);
var
	i: Integer;
	slTemp: TStringList;
begin
	// Initialize
	slTemp := TStringList.Create;

	// Function
	for i := 0 to aList.Count-1 do
		if not slContains(slTemp, aList[i]) then
			slTemp.Add(aList[i]);
	if (slTemp.Count > 0) then begin
		aList.Assign(slTemp);
	end;
	
	// Finalize
	slTemp.Free;
end;