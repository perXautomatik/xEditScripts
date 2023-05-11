
function GetEnchLevel(objEffect: IInterface; slItemTiers: TStringList): Integer;
var
	debugMsg, tempBoolean: Boolean;
	tempString: String;
	i: Integer;
begin
	// Initialize
	debugMsg := false;
	{Debug} if debugMsg then msgList('[GetEnchLevel] GetEnchLevel('+EditorID(objEffect)+', ', slItemTiers, ' );');
	{Debug} if debugMsg then for i := 0 to slItemTiers.Count-1 do msg('[GetEnchLevel] slItemTiers['+IntToStr(i+1)+'] := '+IntToStr(Integer(slItemTiers.Objects[i]))+';');
	Result := -1;

	// Process
	tempString := Copy(EditorID(objEffect), Length(EditorID(objEffect))-1, 2);
	{Debug} if debugMsg then msg('[GetEnchLevel] tempString := '+tempString);
	if slContains(slItemTiers, tempString) then begin
		Result := Integer(slItemTiers.Objects[slItemTiers.IndexOf(tempString)]);
	// This is specifically for 'More Interesting Loot' enchantments
	end else if (Copy(EditorID(objEffect), 1, 2) = 'aa') then begin
		tempString := EditorID(objEffect);
		if (Length(IntToStr(IntWithinStr(tempString))) = 1) then begin
			for i := 1 to 6 do begin
				if slContains(slItemTiers, '0'+IntToStr(i)) then begin
					Result := slItemTiers.Objects[slItemTiers.IndexOf('0'+IntToStr(i))]
				end else
					Result := slItemTiers.Objects[slItemTiers.Count-1];
			end;
		end else if (IntWithinStr(tempString) = 10) then begin
			Result := slItemTiers.Objects[0];
		end else if (IntWithinStr(tempString) > 50) and (IntWithinStr(tempString) < 100) then begin
			Result := slItemTiers.Objects[slItemTiers.Count-1];
		end else if (IntWithinStr(tempString) > 100) and (IntWithinStr(tempString) <= 200) then begin
				if ContainsText(tempString, 'Greater') then begin
					Result := slItemTiers.Objects[slItemTiers.Count-1];
				end else
					Result := slItemTiers.Objects[(slItemTiers.Count div 2)];
		end else begin
			Result := IntWithinStr(tempString);
		end;
	end;
	{Debug} if debugMsg then msg('[GetEnchLevel] Result := '+IntToStr(Result)+';');
	if (Result = 0) then
		Result := 1;
end;