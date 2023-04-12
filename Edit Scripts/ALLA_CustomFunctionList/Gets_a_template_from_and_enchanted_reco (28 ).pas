
// Gets a template from and enchanted record
function GetEnchTemplate(e: IInterface): IInterface;
var
	debugMsg: Boolean;
begin
	if ee(e, 'CNAM') then begin
		Result := LinksTo(ebs(e, 'CNAM'));
		Exit;
	end;
	if ee(e, 'TNAM') then begin
		Result := LinksTo(ebs(e, 'TNAM'));
		Exit;
	end;
end;