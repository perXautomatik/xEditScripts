

// Check a records Flags for aFlag
function FlagCheck(aRecord: IInterface; aFlag: String): Boolean;
var
  debugMsg: Boolean;
begin
  Result := False;
	if ee(aRecord, 'LVLF') then // If this record has a 'Flags' section
	  if ee(ebp(aRecord, 'LVLF'), aFlag) then // If this record has the flag, 'aFlag'
		  Result := GetElementNativeValues(ebp(aRecord, 'LVLF'), aFlag); // Return an integer value for this flag.  IIRC it's a binary for Flag on/off
end;