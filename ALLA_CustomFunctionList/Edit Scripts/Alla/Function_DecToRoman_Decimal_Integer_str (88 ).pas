
function DecToRoman(Decimal: Integer): string;
var
	slNumbers, slRomans: TStringList;
	i: Integer;
begin
	// Initialize
	slNumbers := TStringList.Create;
	slRomans := TStringList.Create;

	slNumbers.CommaText := '1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000';
	slRomans.CommaText := 'I, IV, V, IX, X, XL, L, XC, C, CD, D, CM, M';
	Result := '';
	for i := 12 downto 0 do begin
		while (Decimal >= slNumbers[i]) do begin
			Decimal := Decimal - slNumbers[i];
			Result := Result + slRomans[i];
		end;
	end;

	// Finalization
	slNumbers.Free;
	slRomans.Free;
end;