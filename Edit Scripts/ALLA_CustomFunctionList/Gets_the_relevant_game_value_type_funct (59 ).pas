

// Gets the relevant game value type
function GetGameValueType(inputRecord: IInterface): String;
var
  slTemp: TStringList;
  i: Integer;
begin
	// Initialize
  slTemp := TStringList.Create;

	//Function
  slTemp.CommaText := 'Circlet, Ring, Necklace';
  if sig(inputRecord) = 'ARMO' then begin
		for i := 0 to slTemp.Count-1 do begin
			if ContainsText(geev(inputRecord, 'FULL'), slTemp[i]) or ContainsText(ItemKeyword(inputRecord), slTemp[i]) or (ItemKeyword(inputRecord) = ('Clothing'+slTemp[i])) then begin
				Result := 'DATA\Value';
				Exit;
			end;
		end;
		Result := 'DNAM';
		Exit;
	end else begin
		Result := 'DATA\Damage';
		Exit;
	end;

	// Finalize
	slTemp.Free;
end;