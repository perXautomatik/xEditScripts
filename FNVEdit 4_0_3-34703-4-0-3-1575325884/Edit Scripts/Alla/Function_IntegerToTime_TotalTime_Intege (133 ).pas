

function IntegerToTime(TotalTime: Integer): String;
var
	TimeInteger, Hours, Minutes, Seconds: Integer;
	stringHours, stringMinutes, stringSeconds: String;
	tempString: String;
begin
	TimeInteger := TotalTime;
	// Hours
	while (TimeInteger > 3600) do begin
		TimeInteger := TimeInteger-3600;
		Hours := Hours + 1;
	end;
	if (Hours <= 0) then begin
		stringHours := '00';
	end else if (Hours < 10) then
		stringHours := '0'+IntToStr(Hours)
	else
		stringHours := IntToStr(Hours);
	// Minutes
	while (TimeInteger > 60) do begin
		 TimeInteger := TimeInteger - 60;
		 Minutes := Minutes + 1;
	end;
	if (Minutes <= 0) then begin
		stringMinutes := '00';
	end else if (Minutes < 10) then
		stringMinutes := '0'+IntToStr(Minutes)
	else
		stringMinutes := IntToStr(Minutes);
	// Seconds
	if (TimeInteger <= 0) then begin
		stringSeconds := '00';
	end else if (TimeInteger < 10) then
		stringSeconds := '0'+IntToStr(TimeInteger)
	else
		stringSeconds := IntToStr(TimeInteger);
	Result := stringHours+':'+stringMinutes+':'+stringSeconds;
end;

Procedure addProcessTime(aFunctionName: String; aTime: Integer);
begin
	SetObject(aFunctionName, Integer(GetObject(aFunctionName, slProcessTime))+aTime, slProcessTime);
end;