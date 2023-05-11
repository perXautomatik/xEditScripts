

Procedure Btn_Temper_OnClick(Sender: TObject);
var
	lblTemperLight, lblTemperHeavy: TLabel;
	ddTemperLight, ddTemperHeavy: TComboBox;
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

	slTemp.CommaText := '"# of Ingots - Light/One-Handed: ", "# of Ingots - Heavy/Two-Handed: "';
	if not CaptionExists(slTemp[0], frm) then begin
		// Shift Components Down
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Shift Components Down');
		frm.Height := frm.Height + slTemp.Count*44;
		TShift(Sender.Top+3, slTemp.Count*44, frm, False);
		Sender.Caption := 'Confirm Temper Recipe';
		// Temper Light Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Light Label');
		lblTemperLight := TLabel.Create(frm);
		lblTemperLight.Parent := frm;
		lblTemperLight.Height := 24;
		lblTemperLight.Top := Sender.Top+Sender.Height + 18;
		lblTemperLight.Left := Sender.Left;
		lblTemperLight.Caption := '# of Ingots - Light/One-Handed: ';
	
		// Temper Light Drop Down
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Light Drop Down');
		ddTemperLight := TComboBox.Create(frm);
		ddTemperLight.Parent := frm;
		ddTemperLight.Height := lblTemperLight.Height;
		ddTemperLight.Top := lblTemperLight.Top - 2;	
		ddTemperLight.Left := 450;
		ddTemperLight.Width := 80;
		if slContains(slGlobal, 'TemperLight') then begin
			ddTemperLight.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('TemperLight')]));
		end else begin
			ddTemperLight.Items.Add(IntToStr(defaultTemperLight));
		end;
		ddTemperLight.ItemIndex := 0;
	
		// Temper Heavy Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Heavy Label');
		lblTemperHeavy := TLabel.Create(frm);
		lblTemperHeavy.Parent := frm;
		lblTemperHeavy.Height := lblTemperLight.Height;
		lblTemperHeavy.Top := lblTemperLight.Top + lblTemperLight.Height + 18;
		lblTemperHeavy.Left := lblTemperLight.Left;
		lblTemperHeavy.Caption := '# of Ingots - Heavy/Two-Handed: ';
	
		// Temper Heavy Drop Down
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Temper Heavy Drop Down');
		ddTemperHeavy := TComboBox.Create(frm);
		ddTemperHeavy.Parent := frm;
		ddTemperHeavy.Height := lblTemperHeavy.Height;
		ddTemperHeavy.Top := lblTemperHeavy.Top - 2;	
		ddTemperHeavy.Left := ddTemperLight.Left;
		ddTemperHeavy.Width := ddTemperLight.Width;
		if slContains(slGlobal, 'TemperHeavy') then begin
			ddTemperHeavy.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('TemperHeavy')]));
		end else begin
			ddTemperHeavy.Items.Add(IntToStr(defaultTemperHeavy));
		end;
		ddTemperHeavy.ItemIndex := 0;
	end else begin
		Sender.Caption := 'Configure Temper Recipe';
		// Set Result
		if slContains(slGlobal, 'TemperLight') then begin
			slGlobal.Objects[slGlobal.IndexOf('TemperLight')] := StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Light/One-Handed: ', frm).Top - 2, frm).Text);
		end else
			slGlobal.AddObject('TemperLight', StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Light/One-Handed: ', frm).Top - 2, frm).Text));
		if slContains(slGlobal, 'TemperHeavy') then begin
			slGlobal.Objects[slGlobal.IndexOf('TemperHeavy')] := StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Heavy/Two-Handed: ', frm).Top - 2, frm).Text);
		end else
			slGlobal.AddObject('TemperHeavy', StrToInt(ComponentByTop(ComponentByCaption('# of Ingots - Heavy/Two-Handed: ', frm).Top - 2, frm).Text));
		// Free Components
		for i := 0 to slTemp.Count-1 do begin
			tempObject := ComponentByCaption(slTemp[i], frm);
			tempInteger := tempObject.Top - 2;
			tempObject.Free;
			tempObject := ComponentByTop(tempInteger, frm);
			tempObject.Free;
		end;
		// Shift form
		TShift(Sender.Top+3, slTemp.Count*44, frm, True);
		frm.Height := frm.Height - slTemp.Count*44;
	end;

	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg section
end;