

// Gets an Enchantment Amount from the level
function GetEnchAmount(aLevel: Integer): Integer;
var
	debugMsg: Boolean;
begin
	// Initialize
	debugMsg := false;
	{Debug} if debugMsg then msg('[GetEnchAmount] GetEnchAmount('+IntToStr(aLevel)+' );');

	// Process
	case aLevel of
		 1..9: Result := 500;
		10..19: Result := 1000;
		20..29: Result := 1500;
		30..34: Result := 2000;
		35..39: Result := 2500;
		40..100: Result := 3000;
	else msg('[GetEnchAmount] '+IntToStr(aLevel)+' not recognized');
	end;
	{Debug} if debugMsg then msg('[GetEnchAmount] Result := '+IntToStr(Result));
end;