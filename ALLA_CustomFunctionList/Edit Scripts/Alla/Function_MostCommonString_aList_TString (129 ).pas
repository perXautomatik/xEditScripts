

function MostCommonString(aList: TStringList): String;
var
	i, x, tempInteger, Count: Integer;
	slTemp: TStringList;
	debugMsg: Boolean;
begin
	// Begin debugMsg Section
	debugMsg := false;

	// Initialize
	if debugMsg then msgList('[MostCommonString] MostCommonString(', aList, ');');
	slTemp := TStringList.Create;

	// Process
	tempInteger := 0;
	for i := 0 to aList.Count-1 do begin
		if slContains(slTemp, aList[i]) then Continue;
		Count := 0;
		for x := 0 to aList.Count-1 do
			if (aList[x] = aList[i]) and (x <> i) then
				Inc(Count);
		if (Count > tempInteger) and (Count > 1) then begin
			Result := aList[i];
			tempInteger := Count;
		end;
		slTemp.Add(aList[i]);
	end;

	// Finalize
	if debugMsg then msg('[MostCommonString] Result := '+Result);
	slTemp.Free;

	debugMsg := false;
	// End debugMsg Section
end;