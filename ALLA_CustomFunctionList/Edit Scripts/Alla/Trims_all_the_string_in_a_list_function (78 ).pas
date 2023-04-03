

// Trims all the string in a list
function TrimList(aList: TStringList): TStringList;
var
	debugMsg: Boolean;
	i: Integer;
begin
	for i := 0 to aList.Count-1 do
		aList[i] := Trim(aList[i]);
	Result := aList;
end;

// Gets ElementCount of the Leveled List Entries
function LLec(e: IInterface): Integer;
begin
	Result := ec(ebp(e, 'Leveled List Entries'));
end;