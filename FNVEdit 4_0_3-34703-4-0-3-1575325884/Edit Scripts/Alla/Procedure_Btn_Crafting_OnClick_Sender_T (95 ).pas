
Procedure Btn_Crafting_OnClick(Sender: TObject);
var
	lblScaling: TLabel;
	ckScaling: TComboBox;
	debugMsg, tempBoolean: Boolean;
	btnOk, btnCancel: TButton;
	i, tempInteger: Integer;
	slTemp: TStringList;
	frm: TForm;
	tempObject: TObject;
begin
	// Begin debugMsg section
	debugMsg := false;

	// Initialize
	slTemp := TStringList.Create;

	// Get Sender Parameters
	{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Sender := '+Sender.Caption);
	frm := Sender.Parent;

	if not CaptionExists('Recipe Scaling: ', frm) then begin
		// Shift Components
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Shift Components Down');
		frm.Height := frm.Height + 44;
		TShift(Sender.Top+3, 44, frm, False);
		Sender.Caption := 'Confirm Crafting Recipe';

		// Enable Scaling Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Enable Scaling Label');
		lblScaling := TLabel.Create(frm);
		lblScaling.Parent := frm;
		lblScaling.Height := 24;
		lblScaling.Top := Sender.Top + 40;
		lblScaling.Left := Sender.Left;
		lblScaling.Caption := 'Recipe Scaling: ';

		// Enable Scaling
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Enable Scaling Check Box');
		ckScaling := TCheckBox.Create(frm);
		ckScaling.Parent := frm;
		ckScaling.Height := lblScaling.Height;
		ckScaling.Top := lblScaling.Top - 2;	
		ckScaling.Left := 465;
		ckScaling.Width := 80;
		if StrWithinSL('RecipeScaling', slGlobal) then begin
			for i := 0 to slGlobal.Count-1 do
				if ContainsText(slGlobal[i], 'RecipeScaling') then			
					ckScaling.Checked := StrToBool(StrPosCopy(slGlobal[i], '=', False));
		end else
			ckScaling.Checked := True;
	end else begin
		Sender.Caption := 'Configure Crafting Recipe';
		// Set Result
		tempObject := ComponentByTop(ComponentByCaption('Recipe Scaling: ', frm).Top - 2, frm);
		if StrWithinSL('RecipeScaling', slGlobal) then begin
			for i := 0 to slGlobal.Count-1 do begin
				if ContainsText(slGlobal[i], 'RecipeScaling') then begin			
					slGlobal[i] := 'RecipeScaling='+BoolToStr(tempObject.Checked);
					Break;
				end;
			end;
		end else
			slGlobal.Add('RecipeScaling='+BoolToStr(tempObject.Checked));
		// Free Components
		slTemp.CommaText := '"Recipe Scaling: "';
		for i := 0 to slTemp.Count-1 do begin
			tempObject := ComponentByCaption(slTemp[i], frm);
			tempInteger := tempObject.Top - 2;
			tempObject.Free;
			tempObject := ComponentByTop(tempInteger, frm);
			tempObject.Free;
		end;
		// Shift form
		TShift(Sender.Top+3, 44, frm, True);
		frm.Height := frm.Height - 44;
	end;

	// Finalize
	slTemp.Free;

	debugMsg := false;
	// End debugMsg section
end;