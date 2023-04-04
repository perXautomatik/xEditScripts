
// Copies string preceding [TRUE] or following [FALSE] as string
function StrPosCopy(inputString: String; findString: String; inputBoolean: Boolean): String;
var
 debugMsg: Boolean;
begin
// Begin debugMsg Section
  debugMsg := false;
  {Debug} if debugMsg then msg('[StrPosCopy] if ContainsText(inputString := '+inputString+', findString := '+findString+') then begin');
  if ContainsText(inputString, findString) then begin
    {Debug} if debugMsg then msg('[StrPosCopy] if not inputBoolean := '+BoolToStr(inputBoolean)+' then');
    if not inputBoolean then begin
	  Result := Copy(inputString, (ItPos(findString, inputString, 1)+length(findString)), (length(inputString)-ItPos(findstring, inputstring, 1)));
	  {Debug} if debugMsg then msg('[StrPosCopy] Copy(inputString := '+inputString+', (ItPos(findString := '+findString+' inputString := '+inputString+', 1)+length(findString) := '+IntToStr(length(findString))+') := '+IntToStr(ItPos(findString, inputString, 1))+', (length(inputString) := '+IntToStr(length(inputString))+' - ItPos(findstring, inputString, 1)) := '+IntToStr(ItPos(findstring, inputstring, 1))+')');
	  {Debug} if debugMsg then msg('[StrPosCopy] Result := '+Copy(inputString, (ItPos(findString, inputString, 1)+length(findString)), (length(inputString)-ItPos(findstring, inputstring, 1))));
	end;
    {Debug} if debugMsg then msg('[StrPosCopy] if inputBoolean := '+BoolToStr(inputBoolean)+' then');   
	if inputBoolean then begin
	  Result := Copy(inputString, 0, (ItPos(findString, inputString, 1)-1));
	  {Debug} if debugMsg then msg('[StrPosCopy] Copy(inputString := '+inputString+', 0, (ItPos(findString, inputString, 1)-1 := '+IntToStr(ItPos(findString, inputString, 1)-1)+'));');
	  {Debug} if debugMsg then msg('[StrPosCopy] Result := '+Copy(inputString, 0, (ItPos(findString, inputString, 1)-1)));
	end;
  end else Result := Trim(inputString);
  debugMsg := false;
// End debugMsg Section
end;