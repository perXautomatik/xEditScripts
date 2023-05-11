

// Reverses a string.
function ReverseString(var s: string): string;
var
  i: integer;
begin
   Result := '';
   for i := Length(s) downto 1 do begin
     Result := Result + Copy(s, i, 1);
   end;
end;