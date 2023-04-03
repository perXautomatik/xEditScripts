
function GetElementType(aRecord: IInterface): String;
var
	debugMsg: Boolean;
begin
	debugMsg := false;

	{Debug} if debugMsg then msg('[GetElementType] GetElementType('+EditorID(aRecord)+' );');
	{Debug} if debugMsg then msg('[GetElementType] sig('+EditorID(aRecord)+' := '+sig(aRecord));
	if (sig(aRecord) = 'ARMO') then begin
		if ee(aRecord, 'BODT') then begin
			Result := 'BODT';
		end else
			Result := 'BOD2';
	end else if (sig(aRecord) = 'LVLI') then
		Result := 'LVLF';
end;