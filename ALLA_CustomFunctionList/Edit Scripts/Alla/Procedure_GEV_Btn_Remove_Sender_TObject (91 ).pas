
Procedure GEV_Btn_Remove(Sender: TObject);
var
	lblRemovePlugin, lblDetectedFileText,lblDetectedFile: TLabel;
	btnAdd, btnOk, btnCancel, btnRemove: TButton;
	ddRemovePlugin: TComboBox;
	slTemp: TStringList;
	GEVfile: IInterface;
	frm_Remove: TForm;
	debugMsg: Boolean;
	GEVplugin: String;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	// Initialize
	slTemp := TStringList.Create;
	GEVplugin := ComponentByTop(ComponentByCaption('Output Plugin: ', Sender.Parent).Top-2, Sender.Parent).Caption;
	if not StrEndsWith(GEVplugin, '.esl') then AppendIfMissing(GEVplugin, '.esp');
	if DoesFileExist(GEVplugin) then begin
		GEVfile := FileByName(GEVplugin);
	end else begin
		msg('['+full(selectedRecord)+'] '+GEVplugin+' does not exist; Cannot use ''Remove'' on unspecified plugin');
		Exit;
	end;

	// Dialogue Box
	frm_Remove := TForm.Create(nil);
	while not ((frm_Remove.ModalResult = mrCancel) or (frm_Remove.ModalResult = mrOk)) do begin
		frm_Remove := TForm.Create(nil);
		try
			// Remove all previous TForm components
			btnOK := nil;
			btnCancel := nil;
			
			// Parent Form; Entire Box
			frm_Remove.Width := 850;
			frm_Remove.Height := 200;
			frm_Remove.Position := poScreenCenter;
			frm_Remove.Caption := 'Remove a Specified Master';

			// Currently Selected File Label
			lblDetectedFileText := TLabel.Create(frm_Remove);
			lblDetectedFileText.Parent := frm_Remove;
			lblDetectedFileText.Height := 24;
			lblDetectedFileText.Top := 68;
			lblDetectedFileText.Left := 60;
			lblDetectedFileText.Caption := 'Currently Selected File: ';
			frm_Remove.Height := frm_Remove.Height+lblDetectedFileText.Height+12;
		
			// Currently Selected File
			lblDetectedFile := TLabel.Create(frm_Remove);
			lblDetectedFile.Parent := frm_Remove;
			lblDetectedFile.Height := lblDetectedFileText.Height;
			lblDetectedFile.Top := lblDetectedFileText.Top;	
			lblDetectedFile.Left := lblDetectedFileText.Left+(9*Length(lblDetectedFileText.Caption))+85;
			lblDetectedFile.Caption := GEVplugin;
	
			// Remove Plugin label
			lblRemovePlugin := TLabel.Create(frm_Remove);
			lblRemovePlugin.Parent := frm_Remove;
			lblRemovePlugin.Height := lblDetectedFileText.Height;
			lblRemovePlugin.Top := lblDetectedFileText.Top+lblDetectedFileText.Height+24;
			lblRemovePlugin.Left := lblDetectedFileText.Left;
			lblRemovePlugin.Caption := 'Remove Plugin: ';
			frm_Remove.Height := frm_Remove.Height+lblRemovePlugin.Height+12;
		
			// Remove Plugin Drop Down
			ddRemovePlugin := TComboBox.Create(frm_Remove);
			ddRemovePlugin.Parent := frm_Remove;
			ddRemovePlugin.Height := lblRemovePlugin.Height;
			ddRemovePlugin.Top := lblRemovePlugin.Top - 2;	
			ddRemovePlugin.Left := lblRemovePlugin.Left+(9*Length(lblRemovePlugin.Caption))+36;
			ddRemovePlugin.Width := 480;
			for i := 0 to Pred(MasterCount(GEVfile)) do
				if not (StrEndsWith(GetFileName(MasterByIndex(GEVfile, i)), '.esm') or StrEndsWith(GetFileName(MasterByIndex(GEVfile, i)), '.exe') or slContains(slGlobal, GetFileName(MasterByIndex(GEVfile, i)))) then
					ddRemovePlugin.Items.Add(GetFileName(MasterByIndex(GEVfile, i)));

			// Add Button
			btnAdd := TButton.Create(frm_Remove);
			btnAdd.Parent := frm_Remove;
			btnAdd.Caption := 'Add';
			btnAdd.Left := ddRemovePlugin.Left+ddRemovePlugin.Width+8;
			btnAdd.Top := lblRemovePlugin.Top;
			btnAdd.Width := 100;
			btnAdd.ModalResult := mrRetry;
			btnAdd.OnClick := Btn_AddOrRemove_OnClick;
		
			// Items to be removed
			{Debug} if debugMsg then msgList('[GEV_Btn_Remove] slGlobal := ', slGlobal, '');
			for i := 0 to slGlobal.Count-1 do begin
				if DoesFileExist(slGlobal[i]) then begin
					// Remove Plugin label
					lblRemovePlugin := TLabel.Create(frm_Remove);
					lblRemovePlugin.Parent := frm_Remove;
					lblRemovePlugin.Height := 24;
					lblRemovePlugin.Top := slGlobal.Objects[i];
					lblRemovePlugin.Left := 188;
					lblRemovePlugin.Caption := slGlobal[i];
					frm_Remove.Height := frm_Remove.Height+lblRemovePlugin.Height+12;
				
					// Remove Button
					btnRemove := TButton.Create(frm_Remove);
					btnRemove.Parent := frm_Remove;
					btnRemove.Caption := 'Remove';
					btnRemove.Left := 80;
					btnRemove.Top := slGlobal.Objects[i];
					btnRemove.Width := 100;
					btnRemove.ModalResult := mrIgnore;
					btnRemove.OnClick := Btn_AddOrRemove_OnClick;
				end;
			end;
		
			// Ok Button
			btnOk := TButton.Create(frm_Remove);
			btnOk.Parent := frm_Remove;
			btnOk.Caption := 'OK';	
			btnOk.Left := (frm_Remove.Width div 2)-btnOk.Width-8;
			btnOk.Top := frm_Remove.Height-80;
			btnOk.ModalResult := mrOk;
	
			// Cancel Button
			btnCancel := TButton.Create(frm_Remove);
			btnCancel.Parent := frm_Remove;
			btnCancel.Caption := 'Cancel';
			btnCancel.Left := btnOk.Left+btnOk.Width+16;
			btnCancel.Top := btnOk.Top;
			btnCancel.ModalResult := mrCancel;
		
			if (frm_Remove.ShowModal = mrOk) then begin
				for i := 0 to slGlobal.Count-1 do begin
					if DoesFileExist(slGlobal[i]) then begin
					
						slTemp.Add(slGlobal[i]);
					end;
				end;
				for i := 0 to slTemp.Count-1 do
					if (slGlobal.IndexOf(slTemp[i]) >= 0) then
						slGlobal.Delete(slGlobal.IndexOf(slTemp[i]));
			end;
		finally
			frm_Remove.Free;
		end;
	end;

	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg Section
end;