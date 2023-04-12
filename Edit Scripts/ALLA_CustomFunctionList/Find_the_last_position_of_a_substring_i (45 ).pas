

// find the last position of a substring in a string [mte Functions]
function rPos(aString, substr: string): integer;
var
  i: integer;
begin
  Result := -1;
  if (Length(aString) - Length(substr) < 0) then
   Exit;
  for i := Length(aString) - Length(substr) downto 1 do begin
    if (Copy(aString, i, Length(substr)) = substr) then begin
      Result := i;
      Break;
    end;
  end;
end;