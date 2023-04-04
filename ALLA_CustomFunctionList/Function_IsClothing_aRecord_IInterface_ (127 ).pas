
function IsClothing(aRecord: IInterface): Boolean;
var
	tempString: String;
begin
	Result := False;
	if not (sig(aRecord) = 'ARMO') then
		Exit;
	if ee(aRecord, 'BODT') then begin
		tempString := 'BODT';
	end else
		tempString := 'BOD2';
	if (geev(aRecord, tempString+'\Armor Type') = 'Clothing') then begin
		Result := True;
		Exit;
	end;
	if ContainsText(EditorID(aRecord), 'Clothing') then begin
		Result := True;
		Exit;
	end;
	if textInKeyword(aRecord, 'clothing', false) then result := true;
	if ee(aRecord, 'DNAM') then begin
		if (genv(aRecord, 'DNAM') = 0) then begin
			Result := True;
			Exit;
		end;
	end else
	Result := True;
end;