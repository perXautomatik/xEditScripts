
function GetPrimarySlot(aRecord: IInterface): String;
var
	slTemp, slBOD2: TStringList;
	debugMsg: Boolean;
	i: Integer;
begin
	// Initialize
	debugMsg := false;
	{Debug} if debugMsg then msg('[GetPrimarySlot] GetPrimarySlot('+EditorID(aRecord)+' );');
	Result := '00';
	slBOD2 := TStringList.Create;
	slTemp := TStringList.Create;

	// Process
	slGetFlagValues(aRecord, slBOD2, False);
	{Debug} if debugMsg then msgList('[GetPrimarySlot] slGetFlagValues := ', slBOD2, '');
	slTemp.CommaText := '30, 32, 33, 35, 36, 37, 39, 42';
	for i := 0 to slTemp.Count-1 do begin
		if slContains(slBOD2, slTemp[i]) then begin
			Result := slTemp[i];
			Break;
		end;
	end;
	{Debug} if debugMsg then msg('[GetPrimarySlot] Result := '+Result);

	// Finalize
	slBOD2.Free;
	slTemp.Free;
end;