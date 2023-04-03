

//stuff below this is probably added by yggdrasil75
function AddMasterBySignature(Sig: String; patch: IInterface): integer;
var
	i: integer;
	temp: IInterface;
	debugMsg: Boolean;
begin
	debugMsg := false;
    {Debug} if debugmsg then msg('Adding Masters with ' + sig);
    for i := 0 to fileCount - 1 do
    begin
        temp := FileByIndex(i);
        if pos(GetFileName(Patch), GetFileName(temp)) < 1 then
        begin
            if HasGroup(temp, sig) then
            begin
                AddMasterIfMissing(Patch, GetFileName(temp));
            end;
        end;
    end;
end;