

// Caption Exists on TForm element
function CaptionExists(aString: String; aForm: TObject): Boolean;
var
	Form: TForm;
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	Result := False;
	for i := aForm.ComponentCount-1 downto 0 do begin
		{Debug} if debugMsg then msg('[CaptionExists] if ('+aForm.Components[i].Caption+' = '+aString+' ) then begin');
		if (aForm.Components[i].Caption = aString) then begin
			Result := True;
		end;
	end;
	{Debug} if debugMsg then msg('[CaptionExists] Result := '+BoolToStr(Result));

	debugMsg := false;
// End debugMsg section
end;