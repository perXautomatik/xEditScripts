
function GetSeconds(aTime: TDateTime): Integer;
var
	tempString: String;
begin
	tempString := TimeToStr(aTime);
	Result := StrToInt(Trim(IntWithinStr(StrPosCopy(StrPosCopy(tempString, ':', False), ':', False))));
end;

function GetMinutes(aTime: TDateTime): Integer;
begin
	Result := StrToInt(Trim(StrPosCopy(StrPosCopy(TimeToStr(aTime), ':', False), ':', True)));
end;

function GetHours(aTime: TDateTime): Integer;
begin
	Result := StrToInt(Trim(StrPosCopy(TimeToStr(aTime), ':', True)));
end;