
// Finds a TForm element by name
function ComponentByTop(aTop: Integer; aForm: TObject): TObject;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	for i := aForm.ComponentCount-1 downto 0 do begin
		if (aForm.Components[i].Top = aTop) then begin
			Result := aForm.Components[i];
			Exit;
		end;
	end;

	debugMsg := false;
// End debugMsg Section
end;