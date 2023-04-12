
function IsFemaleOnly(aRecord: IInterface): Boolean;
begin
	Result := False;
	if not (Length(geev(aRecord, 'Male world model\MOD2')) > 0) then
		Result := True;
	if not (Length(geev(LinksTo(ebp(aRecord, 'Armature\MODL')), 'Male world model\MOD2')) > 0) then
		Result := True;
end;