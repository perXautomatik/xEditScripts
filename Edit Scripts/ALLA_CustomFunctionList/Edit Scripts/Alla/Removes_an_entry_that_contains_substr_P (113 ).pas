
// Removes an entry that contains substr
Procedure slDeleteString(s: String; aList: TStringList);
var
	i, tempInteger: Integer;
	slTemp: TStringList;
begin
	// Initialize
	slTemp := TStringList.Create;

	// Process
	if StrWithinSL(s, aList) then begin
		for i := 0 to aList.Count-1 do
			if ContainsText(aList[i], s) then
				slTemp.Add(aList[i]);
		for i := 0 to slTemp.Count-1 do
			if (aList.IndexOf(slTemp[i]) >= 0) then
				aList.Delete(aList.IndexOf(slTemp[i]));
	end;

	// Finalize
	slTemp.Free;
end;