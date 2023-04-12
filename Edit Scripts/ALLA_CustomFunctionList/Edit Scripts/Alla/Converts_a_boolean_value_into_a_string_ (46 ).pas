

// Converts a boolean value into a string [mte Functions]
function BoolToStr(b: boolean): string;
begin
  if b then
    Result := 'True'
  else
    Result := 'False';
end;

// Converts string to boolean
function StrToBool(s: String): Boolean;
begin
	if ContainsText(s, 'True') then
		Result := True
	else
		Result := False;
end;