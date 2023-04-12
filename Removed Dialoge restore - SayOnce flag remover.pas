{
   Removes 'Say Once' flag from INFO records
}
unit UserScript;

const
	sPath = 'ENAM\Flags\Say Once';
	
var
	Count: Integer;

function Process(e: IInterface): integer;
var
  m: IInterface;
begin

	if Signature(e) <> 'INFO' then Exit;
	
	if ElementExists(e, sPath) then
		begin
			m := Master(e);
			
			// This is an override and master doesn't have flag
			if Assigned(m) and not ElementExists(m, sPath) then
				begin
					SetElementEditValues(e, sPath, 0);				
					AddMessage('Processed: ' + Name(e));
					Inc(Count);					
				end;
		end;
end;
  
function Finalize: integer;
begin
  AddMessage('Flags removed: ' + IntToStr(Count));
end;

end.