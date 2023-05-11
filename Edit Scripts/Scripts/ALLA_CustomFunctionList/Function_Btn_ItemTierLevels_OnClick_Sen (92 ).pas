

Function Btn_ItemTierLevels_OnClick(Sender: TObject): TStringList;
var
	lblTier01, lblTier02, lblTier03, lblTier04, lblTier05, lblTier06: TLabel;
	ddTier01, ddTier02, ddTier03, ddTier04, ddTier05, ddTier06: TComboBox;
	debugMsg, tempBoolean: Boolean;
	btnOk, btnCancel: TButton;
	i, tempInteger: Integer;
	frm: TForm;
	tempObject: TObject;
begin
	// Get Sender Parameters
	frm := Sender.Parent;

	if not CaptionExists('Tier 01 appears at level: ', frm) then begin
		Sender.Caption := 'Confirm Tiers';
		// Shift Components Down
		{Debug} if debugMsg then msg('[Btn_ItemTierLevels_OnClick] Shift Components Down');
		frm.Height := frm.Height + 262;
		for i := 0 to frm.ComponentCount-1 do begin
			tempObject := nil;
			if (frm.Components[i].Top > Sender.Top) then begin
				tempObject :=	frm.Components[i];
				tempInteger := tempObject.Top;
				if Assigned(tempObject) then begin
					tempObject.Top := tempObject.Top + 262;
				end;
			end;
		end;	
		// Tier 01 Label
		lblTier01 := TLabel.Create(frm);
		lblTier01.Parent := frm;
		lblTier01.Height := 24;
		lblTier01.Top := Sender.Top+Sender.Height + 18;
		lblTier01.Left := Sender.Left;
		lblTier01.Caption := 'Tier 01 appears at level: ';
	
		// Tier 01 Drop Down
		ddTier01 := TComboBox.Create(frm);
		ddTier01.Parent := frm;
		ddTier01.Height := lblTier01.Height;
		ddTier01.Top := lblTier01.Top - 2;	
		ddTier01.Left := 530;
		ddTier01.Width := 80;
		if slContains(slGlobal, 'ItemTier01') then begin
			ddTier01.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier01')]));
		end else begin
			ddTier01.Items.Add(IntToStr(defaultItemTier01));
		end;
		ddTier01.ItemIndex := 0;
	
		// Tier 02 Label
		lblTier02 := TLabel.Create(frm);
		lblTier02.Parent := frm;
		lblTier02.Height := lblTier01.Height;
		lblTier02.Top := lblTier01.Top+lblTier01.Height + 18;
		lblTier02.Left := lblTier01.Left;
		lblTier02.Caption := 'Tier 02 appears at level: ';
	
		// Tier 02 Drop Down
		ddTier02 := TComboBox.Create(frm);
		ddTier02.Parent := frm;
		ddTier02.Height := lblTier02.Height;
		ddTier02.Top := lblTier02.Top - 2;	
		ddTier02.Left := ddTier01.Left;
		ddTier02.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier02') then begin
			ddTier02.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier02')]));
		end else begin
			ddTier02.Items.Add(IntToStr(defaultItemTier02));
		end;
		ddTier02.ItemIndex := 0;
	
		// Tier 03 Label
		lblTier03 := TLabel.Create(frm);
		lblTier03.Parent := frm;
		lblTier03.Height := lblTier02.Height;
		lblTier03.Top := lblTier02.Top+lblTier02.Height + 18;
		lblTier03.Left := lblTier02.Left;
		lblTier03.Caption := 'Tier 03 appears at level: ';
	
		// Tier 03 Drop Down
		ddTier03 := TComboBox.Create(frm);
		ddTier03.Parent := frm;
		ddTier03.Height := lblTier03.Height;
		ddTier03.Top := lblTier03.Top - 2;	
		ddTier03.Left := ddTier01.Left;
		ddTier03.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier03') then begin
			ddTier03.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier03')]));
		end else begin
			ddTier03.Items.Add(IntToStr(defaultItemTier03));
		end;
		ddTier03.ItemIndex := 0;
	
		// Tier 04 Label
		lblTier04 := TLabel.Create(frm);
		lblTier04.Parent := frm;
		lblTier04.Height := lblTier03.Height;
		lblTier04.Top := lblTier03.Top+lblTier03.Height + 18;
		lblTier04.Left := lblTier03.Left;
		lblTier04.Caption := 'Tier 04 appears at level: ';
	
		// Tier 04 Drop Down
		ddTier04 := TComboBox.Create(frm);
		ddTier04.Parent := frm;
		ddTier04.Height := lblTier04.Height;
		ddTier04.Top := lblTier04.Top - 2;	
		ddTier04.Left := ddTier01.Left;
		ddTier04.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier04') then begin
			ddTier04.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier04')]));
		end else begin
			ddTier04.Items.Add(IntToStr(defaultItemTier04));
		end;
		ddTier04.ItemIndex := 0;
	
		// Tier 05 Label
		lblTier05 := TLabel.Create(frm);
		lblTier05.Parent := frm;
		lblTier05.Height := lblTier04.Height;
		lblTier05.Top := lblTier04.Top+lblTier04.Height + 18;
		lblTier05.Left := lblTier04.Left;
		lblTier05.Caption := 'Tier 05 appears at level: ';
	
		// Tier 05 Drop Down
		ddTier05 := TComboBox.Create(frm);
		ddTier05.Parent := frm;
		ddTier05.Height := lblTier05.Height;
		ddTier05.Top := lblTier05.Top - 2;	
		ddTier05.Left := ddTier01.Left;
		ddTier05.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier05') then begin
			ddTier05.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier05')]));
		end else begin
			ddTier05.Items.Add(IntToStr(defaultItemTier05));
		end;
		ddTier05.ItemIndex := 0;
	
		// Tier 06 Label
		lblTier06 := TLabel.Create(frm);
		lblTier06.Parent := frm;
		lblTier06.Height := lblTier05.Height;
		lblTier06.Top := lblTier05.Top+lblTier05.Height + 18;
		lblTier06.Left := lblTier05.Left;
		lblTier06.Caption := 'Tier 06 appears at level: ';
	
		// Tier 06 Drop Down
		ddTier06 := TComboBox.Create(frm);
		ddTier06.Parent := frm;
		ddTier06.Height := lblTier06.Height;
		ddTier06.Top := lblTier06.Top-2;	
		ddTier06.Left := ddTier01.Left;
		ddTier06.Width := ddTier01.Width;
		if slContains(slGlobal, 'ItemTier06') then begin
			ddTier06.Items.Add(IntToStr(slGlobal.Objects[slGlobal.IndexOf('ItemTier06')]));
		end else begin
			ddTier06.Items.Add(IntToStr(defaultItemTier06));
		end;
		ddTier06.ItemIndex := 0;	
	end else begin
		Sender.Caption := 'Configure Tiers';
		for i := 1 to 6 do begin
			if CaptionExists('Tier 0'+IntToStr(i)+' appears at level: ', frm) then begin
				tempObject := ComponentByTop(ComponentByCaption('Tier 0'+IntToStr(i)+' appears at level: ', frm).Top-2, frm);
				if (IntWithinStr(tempObject.Text) > 0) then begin
					if not slContains(slGlobal, 'ItemTier0'+IntToStr(i)) then begin
						slGlobal.AddObject('ItemTier0'+IntToStr(i), IntWithinStr(tempObject.Text));
					end else begin
						slGlobal.Objects[slGlobal.IndexOf('ItemTier0'+IntToStr(i))] := IntWithinStr(tempObject.Text);
					end;
				end;
			end;
			tempObject := ComponentByCaption(('Tier 0'+IntToStr(i)+' appears at level: '), frm);
			tempInteger := tempObject.Top;
			if Assigned(tempObject) then
				tempObject.Free;
			tempObject := ComponentByTop(tempInteger-2, frm);
			if Assigned(tempObject) then
				tempObject.Free;
		end;
		// Shift Components Up
		{Debug} if debugMsg then msg('[Btn_ItemTierLevels_OnClick] Shift Components Up');
		frm.Height := frm.Height - 262;
		for i := 0 to frm.ComponentCount-1 do begin
			tempObject := nil;
			if (frm.Components[i].Top > Sender.Top) then begin
				tempObject :=	frm.Components[i];
				tempInteger := tempObject.Top;
				if Assigned(tempObject) then begin
					tempObject.Top := tempObject.Top - 262;
				end;
			end;
		end;	
	end;
end;