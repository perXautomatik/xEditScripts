
Procedure ELLR_Btn_Patch(Sender: TObject);
var
	tempFile, tempRecord, tempElement: IInterface;
	lbl_FileA_Add, lbl_FileA_From, lbl_FileB_To: TLabel;
	dd_Patch, dd_FileA, dd_FileA_Plugin, dd_FileB_Plugin: TComboBox;
	btnOk, btnCancel: TButton;
	slTemp: TStringList;
	debugMsg: Boolean;
	i, x: Integer;
	frm: TForm;
begin
// Begin debugMsg section
	debugMsg := false;

	// Initialize
	slTemp := TStringList.Create;

	// Dialogue Box
	frm := TForm.Create(nil);
	try
		// Parent Form
		frm.Width := 1680;
		frm.Height := 200;
		frm.Position := poScreenCenter;
		frm.Caption := 'Patch Two Specific Files';

		// File A add caption
		lbl_FileA_Add := TLabel.Create(frm);
		lbl_FileA_Add.Parent := frm;
		lbl_FileA_Add.Height := 24;
		lbl_FileA_Add.Top := 68;
		lbl_FileA_Add.Left := 60;
		lbl_FileA_Add.Caption := 'Add';

		// Items or Enchantments Drop Down
		dd_FileA := TComboBox.Create(frm);
		dd_FileA.Parent := frm;
		dd_FileA.Height := 24;
		dd_FileA.Top := lbl_FileA_Add.Top - 2;	
		dd_FileA.Left := lbl_FileA_Add.Left+(10*Length(lbl_FileA_Add.Caption))+20;
		dd_FileA.Width := 180;
		dd_FileA.Items.Add('Items');
		dd_FileA.Items.Add('Enchantments');
		dd_FileA.ItemIndex := 0;
		dd_FileA.OnClick := ELLR_OnClick_Patch_ddFileA;
	
		// File A from caption
		lbl_FileA_From := TLabel.Create(frm);
		lbl_FileA_From.Parent := frm;
		lbl_FileA_From.Height := 24;
		lbl_FileA_From.Top := lbl_FileA_Add.Top;
		lbl_FileA_From.Left := dd_FileA.Left+dd_FileA.Width+8;
		lbl_FileA_From.Caption := 'from: ';	
	
		// FileA Plugin Drop Down
		dd_FileA_Plugin := TComboBox.Create(frm);
		dd_FileA_Plugin.Parent := frm;
		dd_FileA_Plugin.Height := 24;
		dd_FileA_Plugin.Top := lbl_FileA_Add.Top - 2;	
		dd_FileA_Plugin.Left := lbl_FileA_From.Left+(10*Length(lbl_FileA_From.Caption));
		dd_FileA_Plugin.Width := 500;
		for i := 0 to Pred(FileCount) do
			dd_FileA_Plugin.Items.Add(GetFileName(FileByIndex(i)));
		dd_FileA_Plugin.AutoComplete := True;
		dd_FileA_Plugin.Sorted := True;

		// File B Variable Label
		lbl_FileB_To := TLabel.Create(frm);
		lbl_FileB_To.Parent := frm;
		lbl_FileB_To.Height := 24;
		lbl_FileB_To.Top := dd_FileA.Top + 1;
		lbl_FileB_To.Left := dd_FileA_Plugin.Left+dd_FileA_Plugin.Width+8;
		lbl_FileB_To.Caption := 'to Leveled Lists from: ';
	
		// File B Plugin Drop Down
		dd_FileB_Plugin := TComboBox.Create(frm);
		dd_FileB_Plugin.Parent := frm;
		dd_FileB_Plugin.Height := 24;
		dd_FileB_Plugin.Top := dd_FileA.Top - 1;	
		dd_FileB_Plugin.Left := lbl_FileB_To.Left+(10*Length(lbl_FileB_To.Caption) - 20);
		dd_FileB_Plugin.Width := dd_FileA_Plugin.Width;
		for i := 0 to Pred(FileCount) do
			dd_FileB_Plugin.Items.Add(GetFileName(FileByIndex(i)));
		dd_FileB_Plugin.AutoComplete := True;
		dd_FileB_Plugin.Sorted := True;
	
		// Ok Button
		btnOk := TButton.Create(frm);
		btnOk.Parent := frm;
		btnOk.Caption := 'Ok';	
		btnOk.Left := (frm.Width div 2)-btnOk.Width-8;
		btnOk.Top := frm.Height-80;
		btnOk.ModalResult := mrOk;

		// Cancel Button
		btnCancel := TButton.Create(frm);
		btnCancel.Parent := frm;
		btnCancel.Caption := 'Cancel';
		btnCancel.Left := btnOk.Left+btnOk.Width+16;
		btnCancel.Top := btnOk.Top;
		btnCancel.ModalResult := mrCancel;
	
		frm.ShowModal;
		if (frm.ModalResult = mrOk) then begin
			if DoesFileExist(dd_FileA_Plugin.Text) and DoesFileExist(dd_FileB_Plugin.Text) then begin
				// Sender.Parent.Visible := False;
				slGlobal.Clear;
				if not DoesFileExist('Patch_'+dd_FileA_Plugin.Text+'_'+dd_FileB_Plugin.Text) then begin
					SetObject('ALLAfile', AddNewFileName('Patch_'+dd_FileA_Plugin.Text+'_'+dd_FileB_Plugin.Text), slGlobal);
				end else
					SetObject('ALLAfile', FileByName('Patch_'+dd_FileA_Plugin.Text+'_'+dd_FileB_Plugin.Text), slGlobal);
				{Debug} if debugMsg then msg('[ELLR_Btn_Patch] ALLAfile := '+GetFileName(ote(GetObject('ALLAfile', slGlobal))));
				SetObject('Patch', FileByName(dd_FileB_Plugin.Text), slGlobal);
				slTemp.CommaText := 'AMMO, ARMO, WEAP';
				tempFile := FileByName(dd_FileA_Plugin.Text);
				for i := 0 to slTemp.Count-1 do begin
					tempElement := gbs(tempFile, slTemp[i]);
					for x := 0 to Pred(ec(tempElement)) do begin
						tempRecord := ebi(tempElement, x);
						if not (Length(EditorID(tempRecord)) > 0) then Continue
						SetObject(EditorID(tempRecord)+'Original', tempRecord, slGlobal);
						SetObject(EditorID(tempRecord)+'Template', GetTemplate(tempRecord), slGlobal);
					end;
				end;			
			end;
			{Debug} if debugMsg then msgList('[ELLR_Btn_Patch] slGlobal := ', slGlobal, '');
			Sender.Parent.ModalResult := mrRetry;
		end;
	finally
		frm.Free;
	end;

	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg section
end;
