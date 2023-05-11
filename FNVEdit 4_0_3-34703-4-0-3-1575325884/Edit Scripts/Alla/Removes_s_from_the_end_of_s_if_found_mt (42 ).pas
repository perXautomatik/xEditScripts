
// Removes s1 from the end of s2, if found [mte functions]
function RemoveFromEnd(s1, s2: string): string;
begin
  Result := s1;
  if StrEndsWith(s1, s2) then Result := Copy(s1, 1, Length(s1) - Length(s2)); 
end;