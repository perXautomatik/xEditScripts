{
  Sometime mods are released for another language, or author accidently
  edited some records and they got saved with a different language.
  This script will copy FULL and DESC subrecords from master to restore original names.
}
unit UserScript;

function Process(e: IInterface): integer;
var 
orginalName: string;
  m: IInterface;
begin
  if not ElementExists(e, 'FULL') and not ElementExists(e, 'EDID') then
    Exit;

  // get master record
  m := Master(e);
  
  // no master - nothing to restore
  if not Assigned(m) then
    Exit;
  
  // if record overrides several masters, then get the last one
  if OverrideCount(m) > 1 then
    m := OverrideByIndex(m, OverrideCount(m) - 2);

  orginalName:= GetElementEditValues(m, 'FULL');
  SetElementEditValues(e, 'FULL', namePrefix + ' ' + orginalName);
end;

end.