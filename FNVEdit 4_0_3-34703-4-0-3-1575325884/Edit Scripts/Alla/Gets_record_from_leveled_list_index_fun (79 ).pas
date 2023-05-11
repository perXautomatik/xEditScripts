

// Gets record from leveled list index
function LLebi(e: IInterface; i: Integer): IInterface;
var
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := false;
	{Debug} if debugMsg then msg('[LLebi] e := ' + EditorID(e));
	//{Debug} if debugMsg then msg('[LLebi] ebi := '+geev(ebi(ebp(e, 'Leveled List Entries'), i), 'LVLO\Reference'));
	{Debug} if debugMsg then msg('[LLebi] Result := '+EditorID(LinksTo(ebp(ebi(ebp(e, 'Leveled List Entries'), i), 'LVLO\Reference'))));
	Result := LinksTo(ebp(ebi(ebp(e, 'Leveled List Entries'), i), 'LVLO\Reference'));
	debugMsg := false;
// End debugMsg section
end;