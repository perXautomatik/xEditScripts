
function StrToOrd(aString: String): Int64;
var
	i, aLength: Integer;
begin
	aLength := Length(aString);
	if (aLength > 9) then
		aString := Copy(aString, 1, 9);
	for i := 0 to aLength do
		Result := Result * 100 + ord(Copy(aString , i , 1));
end;