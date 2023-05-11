
function FinalCharacter(aString: String): String;
begin
	Result := RightStr(aString, 1);
end;

function RemoveFinalCharacter(aString: String): String;
var
	debugMsg: Boolean;
begin
	Result := Copy(aString, 0, Length(aString)-1);
end;