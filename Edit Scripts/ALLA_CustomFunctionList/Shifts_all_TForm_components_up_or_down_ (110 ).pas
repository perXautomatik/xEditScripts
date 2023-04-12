
// Shifts all TForm components up or down
Procedure TShift(aInteger, bInteger: Integer; aForm: TForm; aBoolean: Boolean);
var
	debugMsg: Boolean;
	i: Integer;
begin
	for i := 0 to aForm.ComponentCount-1 do begin
		if (aForm.Components[i].Top >= aInteger) then begin
			if aBoolean then begin
				aForm.Components[i].Top := aForm.Components[i].Top - bInteger;
			end else begin
				aForm.Components[i].Top := aForm.Components[i].Top + bInteger;
			end;
		end;
	end;
end;