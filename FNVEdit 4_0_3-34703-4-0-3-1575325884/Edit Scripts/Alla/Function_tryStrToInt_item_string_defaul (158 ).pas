
function tryStrToInt(item: string; default: integer): integer;
var
	debugMsg: boolean;
begin
	debugMsg := false;

	//result := StrToInt(item);
	if length(item) = 0 then
	begin
		{Debug} if debugMsg then msg('item ' + name(CurrentItem) + ' is missing required data');
		result := default;
	end else result := StrToFloat(item);
end;