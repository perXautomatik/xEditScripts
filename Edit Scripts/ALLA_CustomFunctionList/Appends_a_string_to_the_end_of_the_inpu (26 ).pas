
// Appends a string to the end of the input string if it's not already there (from mte functions)
function AppendIfMissing(s1, s2: String): String;
begin
  Result := s1;
  if not StrEndsWith(s1, s2) then Result := s1 + s2;
end;