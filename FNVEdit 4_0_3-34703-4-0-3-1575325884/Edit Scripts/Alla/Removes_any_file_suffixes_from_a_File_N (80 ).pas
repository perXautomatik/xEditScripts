
// Removes any file suffixes from a File Name
function RemoveFileSuffix(inputString: String): String;
var
	slTemp: TStringList;
	debugMsg: Boolean;
	i: Integer;
begin
	// Begin debugMsg Section
	debugMsg := false;
	// Initialize
	{Debug} if debugMsg then msg('[RemoveFileSuffix] inputString := '+inputString);
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;

	// Function
	Result := inputString;
	slTemp.CommaText := '.esp, .esm, .exe, .esl';
	for i := 0 to slTemp.Count-1 do begin 
		{Debug} if debugMsg then msg('[RemoveFileSuffix] if StrEndsWith(inputString, '+slTemp[i]+') := '+BoolToStr(StrEndsWith(inputString, slTemp[i])));
		if StrEndsWith(inputString, slTemp[i]) then begin
			Result := RemoveFromEnd(inputString, slTemp[i]);
			{Debug} if debugMsg then msg('[RemoveFileSuffix] Result := '+inputString);
			Exit;
		end;
	end;

	// Finalize
	slTemp.Free;
	debugMsg := false;
	// End debugMsg Section
end;