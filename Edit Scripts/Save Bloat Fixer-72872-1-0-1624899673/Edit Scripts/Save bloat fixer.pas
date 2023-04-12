unit userscript;

function Process(e: IInterface): Integer;
begin
  if GetElementNativeValues(e, 'Record Header\Record Flags\Unknown 23') <> 1 then
    SetElementNativeValues(e, 'Record Header\Record Flags\Unknown 23', 1);
end;

end.
