
// Checks to see if a string ends with an entered substring [mte functions]
function StrEndsWith(s1, s2: String): Boolean;
var
  i, n1, n2: Integer;
begin
  Result := false;
  n1 := Length(s1);
  n2 := Length(s2);
  if (n1 < n2) then Exit;
  Result := (Copy(s1, n1-n2+1, n2) = s2);
end;