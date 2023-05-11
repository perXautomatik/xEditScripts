

function TimeBtwn(Start, Stop: TDateTime): Integer;
begin
	Result := ((3600*GetHours(Stop))+(60*GetMinutes(Stop))+GetSeconds(Stop))-((3600*GetHours(Start))+(60*GetMinutes(Start))+GetSeconds(Start));
end;