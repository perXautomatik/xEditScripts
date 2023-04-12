
//extracts the specified integer (Natural Numbers only) from an input; returns -1 if no suitable number is not found
// O(10n) time complexity n =input string length
function extractInts(inputString: string; intToPull: integer): integer;//tested and works
const
    ints = '1234567890';
var
    i, j, currentInt: integer;
    flag1, flag2 : boolean;
	resultString : string;
begin
    resultString := '';
    CurrentInt := 0;
    flag1 := true;
    flag2 := true;
    for i := 0 to (length(inputString) - 1) do
    begin
        j := 0;
        while j < 10 do
        begin
            if copy(inputString, i+1, 1) = copy(ints, j+1, 1) then
            begin
                 if flag1 then currentInt := currentInt + 1;
                 if (currentInt = intToPull) then resultString := resultString + copy(inputString, i+1, 1);
                 flag1 := false;
                 flag2 := false;
                 break;
            end;
            j := j + 1;
        end;
        if flag2 then flag1 := true;
        flag2 := true;
    end;
	if not (resultString = '') then result := StrToInt(resultString)
	else result := -1
end;