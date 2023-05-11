

// Checks if a string contains integers and then returns those integers
function IntWithinStr(aString: String): Integer;
var
  debugMsg: Boolean;
  i, x, tempInteger: Integer;
  slTemp, slItem: TStringList;
  tempString: String;
begin
// Begin debugMsg Section
  debugMsg := false;
	// Initialize
  if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
  if not Assigned(slItem) then slItem := TStringList.Create else slItem.Clear;

	// Function
  slTemp.CommaText := '0, 1, 2, 3, 4, 5, 6, 7, 8, 9';
  for i := 1 to Length(aString) do begin
    tempString := Copy(aString, i, 1);
		// {Debug} if debugMsg then msg('[IntWithinStr] tempString := '+tempString);
		for x := 0 to slTemp.Count-1 do begin
			if (tempString = slTemp[x]) then begin {Debug} if debugMsg then msg('[IntWithinStr] '+tempString+' = '+slTemp[x]);
				if (slItem.Count = 0) then begin {Debug} if debugMsg then msg('[IntWithinStr] slItem.Count-1 = 0');
					slItem.Add(tempString); {Debug} if debugMsg then msg('[IntWithinStr] slItem.Add('+tempString+' );');
					tempInteger := i; {Debug} if debugMsg then msg('[IntWithinStr] tempInteger := '+IntToStr(tempInteger));
				end else begin {Debug} if debugMsg then msg('[IntWithinStr] slItem.Count-1 <> 0');
				  {Debug} if debugMsg then msg('[IntWithinStr] if not ('+IntToStr(i)+' - '+IntToStr(tempInteger)+' > 1) then begin');
					if not (i-tempInteger > 1) then begin {Debug} if debugMsg then msg('[IntWithinStr] slItem.Add('+tempString+' );');
						slItem.Add(tempString); {Debug} if debugMsg then msg('[IntWithinStr] if not '+IntToStr(i)+' - '+IntToStr(tempInteger)+' > 1) then begin');
						tempInteger := i; {Debug} if debugMsg then msg('[IntWithinStr] tempInteger := '+IntToStr(i));
					end;
				end;
			end;
		end;
  end;
	{Debug} if debugMsg then msg('[IntWithinStr] if not slItem.Count := '+IntToStr(slItem.Count)+' = 0 then begin');
	tempString := nil;
  if not (slItem.Count = 0) then begin
    for i := 0 to slItem.Count-1 do begin
		  {Debug} if debugMsg then msg('[IntWithinStr] tempString := '+tempString+' + '+slItem[i]);
      tempString := tempString+slItem[i];
		end;
		if (length(tempString) > 0) then
			Result := StrToInt(tempString);
		{Debug} if debugMsg then msg('[IntWithinStr] Result := '+IntToStr(Result));
  end else Result := -1;

	// Finalize
  slTemp.Free;
  slItem.Free;
	debugMsg := false;
// End debugMsg Section
end;