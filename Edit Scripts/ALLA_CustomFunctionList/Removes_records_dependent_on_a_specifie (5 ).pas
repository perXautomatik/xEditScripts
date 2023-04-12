
// Removes records dependent on a specified master
// Removes records dependent on a specified master
Procedure RemoveMastersAuto(inputPlugin, outputPlugin: IInterface);
var
	slTemp, slRemove: TStringList;
	tempRecord, tempelement: IInterface;
	tempString: String;
	debugMsg: Boolean;
	i, x, y: Integer;
begin
	// Begin debugMsg section
	debugMsg := false;

	// Initialize
	{Debug} if debugMsg then msg('[RemoveMastersAuto] RemoveMastersAuto( '+GetFileName(inputPlugin)+', '+GetFileName(outputPlugin)+' )');
	slTemp := TStringList.Create;
	slRemove := TStringList.Create;
	tempString := GetFileName(inputPlugin);

	//Work
	{Debug} if debugMsg then msg('[RemoveMastersAuto] for i := 0 to '+IntToStr(Pred(ec(outputPlugin)))+' do begin');
	for i := ec(outputPlugin) - 1 downto 0 do begin
		tempelement := ebi(outputPlugin, i);
		{Debug} if debugMsg then msg('[RemoveMastersAuto] for x := 0 to '+IntToStr(Pred(ec(tempelement)))+' do begin');
		for x := ec(tempelement) - 1 downto 0 do begin
			temprecord := ebi(tempelement, x);
			ReportRequiredMasters(tempRecord, slTemp, false, true);
			{Debug} if debugMsg then msgList('[RemoveMastersAuto] slTemp := ', slTemp, '');
			for y := slTemp.Count - 1 downto 0 do begin
				{Debug} if debugMsg then msg('[RemoveMastersAuto] if ( '+slTemp[y]+' = '+tempString+' ) then begin');
				if slTemp[y] = tempString then begin
					slRemove.addObject(EditorID(tempRecord), tempRecord);
					break;
				end;
			end;
		end;
	end;

	// Remove records
	for i := slRemove.count - 1 downto 0 do begin
		{Debug} if debugMsg then msg('[RemoveMastersAuto] Remove( '+slRemove[i]+' );');
		Remove(ote(slRemove.Objects[i]));
	end;
	
	// Finalize
	slTemp.clear;
	slRemove.clear;
	
	debugMsg := false;
// End debugMsg section
end;