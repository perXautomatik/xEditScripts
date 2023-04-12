
Procedure GEV_GeneralSettings;
var
	lblpercent, lblEnchantmentMultiplier, lblEnchantmentPercent, lblAllowUnenchanting, lblAddtoLL: TLabel;
	lblChance, lblDetectedItem, lblDetectedItemText, lblGEVfile, ckPercent, ckAllowUnenchanting, ckAddtoLL: TCheckBox;
	btnOk, btnCancel, btnAdvanced, btnRemove, btnItemTierLevels, btnBulk, btnPatch: TButton;
	ddChance, ddEnchantmentMultiplier, ddGEVfile, ddAddtoLL: TComboBox;
	debugMsg, tempBoolean: Boolean;
	frm: TForm;
	i: integer;
begin
	// Begin debugMsg Section
	debugMsg := false;

	// Initialize Local
	if not Assigned(slGlobal) then slGlobal := TStringList.Create;

	frm := TForm.Create(nil);
	try
		// Parent Form; Entire Box
		frm.Width := 650;
		frm.Height := 180;
		frm.Position := poScreenCenter;
		frm.Caption := 'Generate Enchanted Versions Settings';

		// Currently Selected Item Label
		lblDetectedItemText := TLabel.Create(frm);
		lblDetectedItemText.Parent := frm;
		lblDetectedItemText.Height := 24;
		lblDetectedItemText.Top := 80;
		lblDetectedItemText.Left := 60;
		lblDetectedItemText.Caption := 'Currently Selected Item: ';
		frm.Height := frm.Height+lblDetectedItemText.Height + 18;

		// Currently Selected Item
		lblDetectedItem := TLabel.Create(frm);
		lblDetectedItem.Parent := frm;
		lblDetectedItem.Height := lblDetectedItemText.Height;
		lblDetectedItem.Top := lblDetectedItemText.Top;	
		lblDetectedItem.Left := lblDetectedItemText.Left + (10*Length(lblDetectedItemText.Caption));
		lblDetectedItem.Caption := full(selectedRecord);

		// Output Plugin Label
		lblGEVfile := TLabel.Create(frm);
		lblGEVfile.Parent := frm;
		lblGEVfile.Height := lblDetectedItemText.Height;
		lblGEVfile.Top := lblDetectedItemText.Top + lblDetectedItemText.Height + 18;
		lblGEVfile.Left := lblDetectedItemText.Left;	
		lblGEVfile.Caption := 'Output Plugin: ';
		frm.Height := frm.Height+lblGEVfile.Height + 18;

		// Output Plugin Edit Box
		ddGEVfile := TComboBox.Create(frm);
		ddGEVfile.Parent := frm;
		ddGEVfile.Height := lblDetectedItemText.Height;
		ddGEVfile.Top := lblGEVfile.Top - 2;	
		ddGEVfile.Left := lblGEVfile.Left + (9*Length(lblGEVfile.Caption)) + 36;
		ddGEVfile.Width := 280;
		if slContains(slGlobal, 'GEVfile') then
			ddGEVfile.Items.Add(GetFileName(ote(GetObject('GEVfile', slGlobal))))
		else
			ddGEVfile.Items.Add(defaultOutputPlugin);
		ddGEVfile.ItemIndex := 0;

		// Item Tier Levels
		btnItemTierLevels := TButton.Create(frm);
		btnItemTierLevels.Parent := frm;
		btnItemTierLevels.Top := lblGEVfile.Top + lblGEVfile.Height + 18;
		btnItemTierLevels.Height := 24;
		btnItemTierLevels.Left := lblGEVfile.Left + 10*Length(btnItemTierLevels.Caption);
		btnItemTierLevels.Caption := 'Configure Tiers';
		btnItemTierLevels.Width := 450;
		frm.Height := frm.Height + btnItemTierLevels.Height + 18;
		btnItemTierLevels.OnClick := Btn_ItemTierLevels_OnClick;

		// Replace in Leveled List Label
		lblAddtoLL := TLabel.Create(frm);
		lblAddtoLL.Parent := frm;
		lblAddtoLL.Height := lblDetectedItemText.Height;
		lblAddtoLL.Top := btnItemTierLevels.Top + btnItemTierLevels.Height + 18;;
		lblAddtoLL.Left := lblGEVfile.Left;
		lblAddtoLL.Caption := 'Replace in Leveled Lists: ';
		frm.Height := frm.Height+lblAddtoLL.Height + 18;

		// Replace in Leveled List Check Box
		ckAddtoLL := TCheckBox.Create(frm);
		ckAddtoLL.Parent := frm;
		ckAddtoLL.Height := lblAddtoLL.Height;
		ckAddtoLL.Left := 485;
		ckAddtoLL.Top := lblAddtoLL.Top;
		if slContains(slGlobal, 'ReplaceInLeveledList') then
			ckAddtoLL.Checked := Boolean(GetObject('ReplaceInLeveledList', slGlobal))
		else
			ckAddtoLL.Checked := True;

		// Allow Unenchanting Label
		lblAllowUnenchanting := TLabel.Create(frm);
		lblAllowUnenchanting.Parent := frm;
		lblAllowUnenchanting.Height := 24;
		lblAllowUnenchanting.Top := lblAddtoLL.Top+lblAddtoLL.Height + 18;	
		lblAllowUnenchanting.Left := lblGEVfile.Left;
		lblAllowUnenchanting.Caption := 'Allow Unenchanting: ';
		frm.Height := frm.Height + lblAllowUnenchanting.Height + 18;

		// Allow Unenchanting Check Box
		ckAllowUnenchanting := TCheckBox.Create(frm);
		ckAllowUnenchanting.Parent := frm;
		ckAllowUnenchanting.Height := 24;
		ckAllowUnenchanting.Top := lblAllowUnenchanting.Top;
		ckAllowUnenchanting.Left := ckAddtoLL.Left;
		if slContains(slGlobal, 'AllowDisenchanting') then
			ckAllowUnenchanting.Checked := Boolean(GetObject('AllowDisenchanting', slGlobal))
		else
			ckAllowUnenchanting.Checked := True;

		// Percent Chance Label
		lblChance := TLabel.Create(frm);
		lblChance.Parent := frm;
		lblChance.Left := lblGEVfile.Left;
		lblChance.Top := lblAllowUnenchanting.Top + lblAllowUnenchanting.Height + 18;
		lblChance.Caption := 'Use Percent Chance: ';
		frm.Height := frm.Height+lblChance.Height + 8;

		// Percent Chance Check Box
		ckPercent := TCheckBox.Create(frm);
		ckPercent.Parent := frm;
		ckPercent.Height := lblGEVfile.Height;
		ckPercent.Left := ckAddtoLL.Left;
		ckPercent.Top := lblChance.Top;
		if slContains(slGlobal, 'ChanceBoolean') then
			ckPercent.Checked := Boolean(GetObject('ChanceBoolean', slGlobal))
		else
			ckPercent.Checked := True;

		// Generate Enchanted Versions % Chance Label
		lblpercent := TLabel.Create(frm);
		lblpercent.Parent := frm;
		lblpercent.Height := ddGEVfile.Height;
		lblpercent.Left := ckPercent.Left + 20;
		lblpercent.Top := lblChance.Top;
		lblpercent.Caption := '%';

		// Generate Enchanted Versions % Chance Edit Box
		ddChance := TComboBox.Create(frm);
		ddChance.Parent := frm;
		ddChance.Height := lblpercent.Height;
		ddChance.Left := lblpercent.Left + 25;
		ddChance.Top := lblChance.Top - 3;
		ddChance.Width := 80;
		if slContains(slGlobal, 'ChanceMultiplier') then
			ddChance.Items.Add(IntToStr(Integer(slGlobal.Objects[slGlobal.IndexOf('ChanceMultiplier')])))
		else
			ddChance.Items.Add('10');
		ddChance.ItemIndex := 0;

		// Enchantment Multiplier Label
		lblEnchantmentMultiplier := TLabel.Create(frm);
		lblEnchantmentMultiplier.Parent := frm;
		lblEnchantmentMultiplier.Left := lblGEVfile.Left;
		lblEnchantmentMultiplier.Top := lblChance.Top+lblChance.Height + 18;
		lblEnchantmentMultiplier.Caption := 'Enchantment Strength: ';
		frm.Height := frm.Height + lblEnchantmentMultiplier.Height + 18;

		// Enchantment Multiplier Edit Box
		ddEnchantmentMultiplier := TComboBox.Create(frm);
		ddEnchantmentMultiplier.Parent := frm;
		ddEnchantmentMultiplier.Height := lblEnchantmentMultiplier.Height;
		ddEnchantmentMultiplier.Left := ddChance.Left;
		ddEnchantmentMultiplier.Top := lblEnchantmentMultiplier.Top - 1;
		ddEnchantmentMultiplier.Width := ddChance.Width;
		if slContains(slGlobal, 'EnchMultiplier') then
			ddEnchantmentMultiplier.Items.Add(IntToStr(Integer(slGlobal.Objects[slGlobal.IndexOf('EnchMultiplier')])))
		else
			ddEnchantmentMultiplier.Items.Add('100');
		ddChance.ItemIndex := 0;
		ddEnchantmentMultiplier.ItemIndex := 0;

		// Generate Enchanted Versions % Chance Label
		lblEnchantmentPercent := TLabel.Create(frm);
		lblEnchantmentPercent.Parent := frm;
		lblEnchantmentPercent.Height := ddEnchantmentMultiplier.Height;
		lblEnchantmentPercent.Left := lblpercent.Left;
		lblEnchantmentPercent.Top := ddEnchantmentMultiplier.Top + 4;
		lblEnchantmentPercent.Caption := '%';

		if StrWithinSL('NoButtons', slGlobal) then begin
			frm.Height := frm.Height-50;
			TShift(0, 50, frm, True);
		end else begin
			// Remove Button
			btnRemove := TButton.Create(frm);
			btnRemove.Parent := frm;
			btnRemove.Caption := 'Remove';
			btnRemove.Left := lblGEVfile.Left;
			btnRemove.Top := 20;
			btnRemove.Width := 100;
			btnRemove.OnClick := GEV_Btn_Remove;

			// Patch Button
			btnPatch := TButton.Create(frm);
			btnPatch.Parent := frm;
			btnPatch.Caption := 'Patch';
			btnPatch.Left := 285;
			btnPatch.Top := 20;
			btnPatch.Width := 100;
			btnPatch.OnClick := ELLR_Btn_Patch;

			// Bulk Button
			btnBulk := TButton.Create(frm);
			btnBulk.Parent := frm;
			btnBulk.Caption := 'Bulk';
			btnBulk.Left := frm.Width - 150;
			btnBulk.Top := 20;
			btnBulk.Width := 100;
			btnBulk.OnClick := Btn_Bulk_OnClick;
		end;

		// Ok Button
		btnOk := TButton.Create(frm);
		btnOk.Parent := frm;
		btnOk.Caption := 'Ok';
		btnOk.ModalResult := mrOk;
		btnOk.Left := (frm.Width div 2)-btnOk.Width - 8;
		btnOk.Top := frm.Height - 80;

		// Cancel Button
		btnCancel := TButton.Create(frm);
		btnCancel.Parent := frm;
		btnCancel.Caption := 'Cancel';
		btnCancel.ModalResult := mrCancel;
		btnCancel.Left := btnOk.Left + btnOk.Width + 16;
		btnCancel.Top := btnOk.Top;

		// What happens when Ok is pressed
		frm.ShowModal;
		if (frm.ModalResult = mrOk) then begin
			if not StrEndsWith(ddGEVfile.Caption, '.esl') then AppendIfMissing(ddGEVfile.Caption, '.esp');		
			SetObject('CancelAll', False, slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] CancelAll := '+BoolToStr(Boolean(GetObject('CancelAll', slGlobal))));
			SetObject('GEVfile', FileByName(ddGEVfile.Caption), slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] GEVfile := '+GetFileName(ote(GetObject('GEVfile', slGlobal))));
			SetObject('ChanceBoolean', ckPercent.Checked, slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] ChanceBoolean := '+BoolToStr(Boolean(GetObject('ChanceBoolean', slGlobal))));
			SetObject('ReplaceInLeveledList', ckAddtoLL.Checked, slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] ReplaceInLeveledList := '+BoolToStr(Boolean(GetObject('ReplaceInLeveledList', slGlobal))));
			SetObject('ChanceMultiplier', StrToInt(ddChance.Text), slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] ChanceMultiplier := '+IntToStr(Integer(GetObject('ChanceMultiplier', slGlobal))));
			SetObject('AllowDisenchanting', ckAllowUnenchanting.Checked, slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] AllowDisenchanting := '+BoolToStr(Boolean(GetObject('AllowDisenchanting', slGlobal))));
			SetObject('EnchMultiplier', StrToInt(ddEnchantmentMultiplier.Text), slGlobal);
			{Debug} if debugMsg then msg('[GEV_GeneralSettings] EnchMultiplier := '+IntToStr(Integer(GetObject('EnchMultiplier', slGlobal))));
		end;
	finally
		frm.Free;
	end;

	debugMsg := false;
	// End debugMsg Section
end;