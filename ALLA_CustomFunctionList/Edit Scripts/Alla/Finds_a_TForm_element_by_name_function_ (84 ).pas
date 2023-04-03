
// Finds a TForm element by name
function ComponentByCaption(aString: String; aForm: TForm): TObject;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[ComponentByCaption] aString := '+aString);
	for i := aForm.ComponentCount-1 downto 0 do begin
		if (aForm.Components[i].Caption = aString) then begin
			Result := aForm.Components[i];
			Exit;
		end;
	end;

	debugMsg := false;
// End debugMsg Section
end;