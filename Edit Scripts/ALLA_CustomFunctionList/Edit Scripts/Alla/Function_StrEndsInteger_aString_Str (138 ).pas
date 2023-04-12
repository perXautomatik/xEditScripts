

function StrEndsWithInteger(aString: String): Boolean;
var
	slTemp: TStringList;
	debugMsg: Boolean;
	i: Integer;
begin
	// Begin debugMsg section
	debugMsg := false;

	slTemp := TStringList.Create;
	slTemp.CommaText := '0, 1, 2, 3, 4, 5, 6, 7, 8, 9';
	Result := True;
	for i := 0 to slTemp.Count-1 do begin
		if StrEndsWith(aString, slTemp[i]) then begin
			slTemp.Free;
			Exit;
		end;
	end;
	Result := False;
	slTemp.Free;
end;