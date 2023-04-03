
// Removes spaces from a string
function RemoveSpaces(inputString: String): String;
var
  debugMsg: Boolean;
  tempString: String;
begin
// Begin debugMsg Section
  debugMsg := false; {Debug} if debugMsg then msg('[RemoveSpaces] Trim(inputString := '+inputString+')');
  Trim(inputString); {Debug} if debugMsg then msg('[RemoveSpaces] tempString := inputString);');
  while (rPos(inputString, ' ') > 0) do begin
    {Debug} if debugMsg then msg('[RemoveSpaces] while (rPos(inputString, ' ') := '+IntToStr(rPos(inputString, ' '))+' > 0) do begin');
    {Debug} if debugMsg then msg('[RemoveSpaces] inputString := '+inputString);
		{Debug} if debugMsg then msg('[RemoveSpaces] tempString := '+tempString);
    Delete(inputString, rPos(inputString, ' '), 1);
  end;
	{Debug} if debugMsg then msg('Result := '+inputString);
  Result := inputString;
  debugMsg := false;
// End debugMsg Section
end;