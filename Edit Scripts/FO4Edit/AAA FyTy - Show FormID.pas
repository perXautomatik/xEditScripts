unit userscript;

function Initialize: integer;
begin

end;


function Process(e: IInterface): integer;
begin
  AddMessage('Processing: ' + FullPath(e) + ' ' + IntToStr(FormID(e)) + '.' + IntToStr(FixedFormID(e)) + '.' + IntToHex(FormID(e), 8) + '.' + IntToHex(FixedFormID(e), 8));
end;


function Finalize: integer;
begin

end;

end.
