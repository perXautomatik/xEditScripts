

// Gets the relevant game value
function GetGameValue(aRecord: IInterface): String;
var
  slTemp: TStringList;
	debugMsg: Boolean;
  i: Integer;
begin
	// Initialize
	debugMsg := false;
  slTemp := TStringList.Create;
	{Debug} if debugMsg then msg('GetGameValue('+EditorID(aRecord)+' );');

	// Function
  slTemp.CommaText := 'Circlet, Ring, Necklace';
  if (sig(aRecord) = 'ARMO') then begin
		for i := 0 to slTemp.Count-1 do begin
			if ContainsText(full(aRecord), slTemp[i]) or ContainsText(ItemKeyword(aRecord), slTemp[i]) or HasKeyword(aRecord, ('Clothing'+slTemp[i])) then begin
				Result := geev(aRecord, 'DATA\Value');
				Exit
			end;
		end;
		Result := StrPosCopy(geev(aRecord, 'DNAM'), '.', True);
		Exit;
  end else if (sig(aRecord) = 'AMMO') then begin
		Result := StrPosCopy(geev(aRecord, 'DATA\Damage'), '.', True);
		Exit;
  end else begin
		Result := geev(aRecord, 'DATA\Damage');
		Exit;
	end;

	// Finalize
	slTemp.Free;
end;