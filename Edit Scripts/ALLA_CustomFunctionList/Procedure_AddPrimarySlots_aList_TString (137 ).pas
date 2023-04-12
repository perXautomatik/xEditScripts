

Procedure AddPrimarySlots(aList: TStringList);
var
	tempString: String;
	i: Integer;
begin
	for i := 0 to aList.Count-1 do begin // Associate current item with a primary slot
		tempString := AssociatedBOD2(aList[i]);
		if not slContains(aList, tempString) then
			aList.Add(tempString);
	end;
end;