
Procedure Btn_Breakdown_OnClick(Sender: TObject);
var
	lblEquipped, lblEnchanted, lblDaedric, lblChitin: TLabel;
	ckEquipped, ckEnchanted, ckDaedric, ckChitin: TComboBox;
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
	{Debug} if debugMsg then msgList('[Btn_Temper_OnClick] slGlobal := ', slGlobal, '');
	frm := Sender.Parent;

	if not CaptionExists('Breakdown Equipped: ', frm) then begin
		// Shift Components
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Shift Components Down');
		frm.Height := frm.Height + 172;
		TShift(Sender.Top+3, 172, frm, False);
		Sender.Caption := 'Confirm Breakdown Recipe';
	
		// Breakdown Equipped Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Equipped Label');
		lblEquipped := TLabel.Create(frm);
		lblEquipped.Parent := frm;
		lblEquipped.Height := 24;
		lblEquipped.Top := Sender.Top + Sender.Height + 18;
		lblEquipped.Left := Sender.Left;
		lblEquipped.Caption := 'Breakdown Equipped: ';
	
		// Breakdown Equipped Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Equipped Check Box');
		ckEquipped := TCheckBox.Create(frm);
		ckEquipped.Parent := frm;
		ckEquipped.Height := lblEquipped.Height;
		ckEquipped.Top := lblEquipped.Top - 2;	
		ckEquipped.Left := 465;
		ckEquipped.Width := 80;
		if slContains(slGlobal, 'BreakdownEquipped') then begin
			ckEquipped.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownEquipped')]);
		end else
			ckEquipped.Checked := False;
	
		// Breakdown Enchanted Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Enchanted Label');
		lblEnchanted := TLabel.Create(frm);
		lblEnchanted.Parent := frm;
		lblEnchanted.Height := lblEquipped.Height;
		lblEnchanted.Top := lblEquipped.Top + lblEquipped.Height + 18;
		lblEnchanted.Left := lblEquipped.Left;
		lblEnchanted.Caption := 'Breakdown Enchanted: ';
	
		// Breakdown Enchanted Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Enchanted Check Box');
		ckEnchanted := TCheckBox.Create(frm);
		ckEnchanted.Parent := frm;
		ckEnchanted.Height := lblEnchanted.Height;
		ckEnchanted.Top := lblEnchanted.Top - 2;	
		ckEnchanted.Left := ckEquipped.Left;
		ckEnchanted.Width := ckEquipped.Width;
		if slContains(slGlobal, 'BreakdownEnchanted') then begin	
			ckEnchanted.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownEnchanted')]);
		end else
			ckEnchanted.Checked := False;

		// Breakdown Daedric Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Daedric Label');
		lblDaedric := TLabel.Create(frm);
		lblDaedric.Parent := frm;
		lblDaedric.Height := lblEnchanted.Height;
		lblDaedric.Top := lblEnchanted.Top + lblEnchanted.Height + 18;
		lblDaedric.Left := lblEnchanted.Left;
		lblDaedric.Caption := 'Breakdown Daedric: ';
	
		// Breakdown Daedric Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown Daedric Check Box');
		ckDaedric := TCheckBox.Create(frm);
		ckDaedric.Parent := frm;
		ckDaedric.Height := lblDaedric.Height;
		ckDaedric.Top := lblDaedric.Top - 2;	
		ckDaedric.Left := ckEquipped.Left;
		ckDaedric.Width := ckEquipped.Width;
		if slContains(slGlobal, 'BreakdownDaedric') then begin	
			ckDaedric.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownDaedric')]);
		end else
			ckDaedric.Checked := True;
	
		// Breakdown DLC Label
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown DLC Label');
		lblChitin := TLabel.Create(frm);
		lblChitin.Parent := frm;
		lblChitin.Height := lblDaedric.Height;
		lblChitin.Top := lblDaedric.Top + lblDaedric.Height + 18;
		lblChitin.Left := lblDaedric.Left;
		lblChitin.Caption := 'Breakdown DLC: ';
	
		// Breakdown DLC Check Box
		{Debug} if debugMsg then msg('[Btn_Temper_OnClick] Breakdown DLC Check Box');
		ckChitin := TCheckBox.Create(frm);
		ckChitin.Parent := frm;
		ckChitin.Height := lblChitin.Height;
		ckChitin.Top := lblChitin.Top - 2;	
		ckChitin.Left := ckEquipped.Left;
		ckChitin.Width := ckEquipped.Width;
		if slContains(slGlobal, 'BreakdownDLC') then begin	
			ckChitin.Checked := Boolean(slGlobal.Objects[slGlobal.IndexOf('BreakdownDLC')]);
		end else
			ckChitin.Checked := True;
	end else begin
		// Set result
		tempObject := ComponentByTop(ComponentByCaption('Breakdown Equipped: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownEquipped') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownEquipped')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownEquipped', tempObject.Checked);
		tempObject := ComponentByTop(ComponentByCaption('Breakdown Enchanted: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownEnchanted') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownEnchanted')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownEnchanted', tempObject.Checked);
		tempObject := ComponentByTop(ComponentByCaption('Breakdown Daedric: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownDaedric') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownDaedric')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownDaedric', tempObject.Checked);
		tempObject := ComponentByTop(ComponentByCaption('Breakdown DLC: ', frm).Top - 2, frm);
		if slContains(slGlobal, 'BreakdownDLC') then begin
			slGlobal.Objects[slGlobal.IndexOf('BreakdownDLC')] := tempObject.Checked;
		end else
			slGlobal.AddObject('BreakdownDLC', tempObject.Checked);
		{Debug} if debugMsg then msgList('[Btn_Temper_OnClick] slGlobal := ', slGlobal, '');
		// Free Components
		slTemp.CommaText := '"Breakdown Equipped: ", "Breakdown Enchanted: ", "Breakdown DLC: ", "Breakdown Daedric: ';
		for i := 0 to slTemp.Count-1 do begin
			tempObject := ComponentByCaption(slTemp[i], frm);
			tempInteger := tempObject.Top - 2;
			tempObject.Free;
			tempObject := ComponentByTop(tempInteger, frm);
			tempObject.Free;
		end;
		// Shift form
		Sender.Caption := 'Configure Breakdown Recipe';
		TShift(Sender.Top+3, 172, frm, True);
		frm.Height := frm.Height - 172;
	end;

	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg section
end;