
// Finds the longest common substring
function LongestCommonString(aList: TStringList): String;
var
	i, x, y, z: Integer;
	tempString: String;
	slTemp: TStringList;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := false;

	// Initialize Local
	slTemp := TStringList.Create;

	//Function
	for i := 0 to aList.Count-1 do begin
		tempString := nil;
		slTemp.CommaText := aList[i];
		{Debug} if debugMsg then msgList('[LongestCommonString] slTemp := ', slTemp, '');
		for x := slTemp.Count-1 downto 0 do begin
			tempString := nil;
			for y := 0 to x do
				tempString := Trim(tempString+' '+slTemp[y]);
			for y := 0 to aList.Count-1 do begin
				{Debug} if debugMsg then msg('[LongestCommonString] ContainsText('+aList[y]+', '+tempString+' )');
				if ContainsText(aList[y], tempString) and (y <> i) then begin				
					if Assigned(Result) then begin
						if (Length(tempString) > Length(Result)) then
							Result := tempString;
					end else begin
						Result := tempString;
					end;
				end;
			end;
		end;
	end;

	if not Assigned(Result) then
		Result := aList[0];

	// Finalize Local
	slTemp.Free;

	debugMsg := false;
// End debugMsg section
end;