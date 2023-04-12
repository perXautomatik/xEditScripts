
function tryStrToFloat(item: string; default: double): double;
var
	debugMsg: boolean;
begin
	debugMsg := false;

	if not item = null then begin
	{Debug} if debugMsg then msg('trystrtofloat ' + item);
		//result := StrToFloat(item);
		{Debug} if debugMsg then msg('string ' + item + ' is being processed');
		if length(item) = 0 then
		begin
			//LogMessage(1, 'item ' + name(CurrentItem) + ' is missing required data');
			result := default;
		end else result := StrToFloat(item);
	end else result := StrToFloat(item);
end;