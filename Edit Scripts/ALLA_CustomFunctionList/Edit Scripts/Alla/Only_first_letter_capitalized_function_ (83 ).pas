
// Only first letter capitalized
function StrCapFirst(str: String): String;
var
	str, format_str : string;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[StrCapFirst] '+Uppercase(Copy(str, 1 ,1))+Lowercase(Copy(str, 2, Length(str))));
	Result:= Uppercase(Copy(str, 1 ,1))+Lowercase(Copy(str, 2, Length(str)));

	debugMsg := false;
// End debugMsg section
end;