
// This function will allow you to find the position of a substring in a string. If the iteration of the substring isn't found -1 is returned.
function ItPos(substr: String; str: String; it: Integer): Integer;
var
  debugMsg: Boolean;
  i, found: integer;
begin
// Begin debugMsg Section
  debugMsg := false;
  {Debug} if debugMsg then msg('[ItPos] substr := '+substr);
  {Debug} if debugMsg then msg('[ItPos] str := '+str);
  {Debug} if debugMsg then msg('[ItPos] it := '+IntToStr(it));
  {Debug} if debugMsg then msg('[ItPos] Result := -1');
  Result := -1;
  //msg('Called ItPos('+substr+', '+str+', '+IntToStr(it)+')');
  if it = 0 then exit;
  found := 0;
  for i := 1 to Length(str) do begin
    //msg('    Scanned substring: '+Copy(str, i, Length(substr)));
    if (Copy(str, i, Length(substr)) = substr) then Inc(found);
    if found = it then begin
      Result := i;
      Break;
    end;
  end;
  debugMsg := false;
// End debugMsg Section
end;