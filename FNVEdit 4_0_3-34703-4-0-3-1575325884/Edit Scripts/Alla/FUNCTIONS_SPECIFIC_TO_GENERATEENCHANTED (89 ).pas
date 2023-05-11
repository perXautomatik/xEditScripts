

// [FUNCTIONS SPECIFIC TO GENERATEENCHANTEDVERSIONSAUTO]
Procedure Btn_Bulk_OnClick(Sender: TObject);
var
	lblAddPlugin, lblDetectedFileText, lblHelp: TLabel;
	tempComponent, btnAdd, btnOk, btnCancel, btnRemove: TButton;
	ddAddPlugin, ddDetectedFile: TComboBox;
	slTemp, slFiles: TStringList;
	ALLAfile, tempFile, tempRecord: IInterface;
	frm: TForm;
	debugMsg: Boolean;
	ALLAplugin: String;
	i, x, y: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	// Initialize
	slFiles := TStringList.Create;
	slTemp := TStringList.Create;
	frm := Sender.Parent;
	tempComponent := AssociatedComponent('Output Plugin: ', Sender.Parent);
	ALLAplugin := tempComponent.Caption;
	if not StrEndsWith(ALLAplugin, '.esl') or StrEndsWith(ALLAplugin, '.exe') or StrEndsWith(ALLAplugin, '.exe') then AppendIfMissing(ALLAplugin, '.esp');
	if DoesFileExist(ALLAplugin) then begin
		ALLAfile := FileByName(ALLAplugin);
	end else begin
		if MessageDlg('Create a new plugin named '+ALLAplugin+' [YES] or cancel [NO]?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
			AddNewFileName(ALLAplugin);
		end else
			Exit;		
	end;

	// Dialogue Box
	frm := TForm.Create(nil);
	try
		// Remove all previous TForm components
		btnOK := nil;
		btnCancel := nil;
		
		// Parent Form; Entire Box
		frm.Width := 850;
		frm.Height := 200;
		frm.Position := poScreenCenter;
		frm.Caption := 'Process Plugins in Bulk';

		// Currently Selected File Label
		lblDetectedFileText := TLabel.Create(frm);
		lblDetectedFileText.Parent := frm;
		lblDetectedFileText.Height := 24;
		lblDetectedFileText.Top := 68;
		lblDetectedFileText.Left := 60;
		lblDetectedFileText.Caption := 'Output File: ';
		frm.Height := frm.Height+lblDetectedFileText.Height+12;
	
		// Currently Selected File
		ddDetectedFile := TComboBox.Create(frm);
		ddDetectedFile.Parent := frm;
		ddDetectedFile.Height := lblDetectedFileText.Height;
		ddDetectedFile.Top := lblDetectedFileText.Top;	
		ddDetectedFile.Left := 205;
		ddDetectedFile.Width := 480;
		ddDetectedFile.Items.Add(ALLAplugin);
		ddDetectedFile.ItemIndex := 0;

		// Add Plugin Label
		lblAddPlugin := TLabel.Create(frm);
		lblAddPlugin.Parent := frm;
		lblAddPlugin.Height := lblDetectedFileText.Height;
		lblAddPlugin.Top := lblDetectedFileText.Top+lblDetectedFileText.Height+24;
		lblAddPlugin.Left := lblDetectedFileText.Left;
		lblAddPlugin.Caption := 'Add Plugin: ';
		frm.Height := frm.Height+lblAddPlugin.Height+12;
	
		// Add Plugin Drop Down
		ddAddPlugin := TComboBox.Create(frm);
		ddAddPlugin.Parent := frm;
		ddAddPlugin.Height := lblAddPlugin.Height;
		ddAddPlugin.Top := lblAddPlugin.Top - 2;	
		ddAddPlugin.Left := ddDetectedFile.Left;
		ddAddPlugin.Width := 480;
		for i := 0 to FileCount-1 do
			if not (StrEndsWith(GetFileName(FileByIndex(i)), '.exe') or slContains(slGlobal, GetFileName(FileByIndex(i)))) then
				ddAddPlugin.Items.Add(GetFileName(FileByIndex(i)));
		ddAddPlugin.AutoComplete := True;

		// Add Button
		btnAdd := TButton.Create(frm);
		btnAdd.Parent := frm;
		btnAdd.Caption := 'Add';
		btnAdd.Left := ddAddPlugin.Left+ddAddPlugin.Width+8;
		btnAdd.Top := lblAddPlugin.Top;
		btnAdd.Width := 100;
		btnAdd.OnClick := Btn_AddOrRemove_OnClick;
	
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
		// Displays a help message
		if (frm.ModalResult = mrOk) and (ddAddPlugin.Text <> '') and not CaptionExists('Remove', frm) then begin
			lblHelp := TLabel.Create(frm);
			lblHelp.Parent := frm;
			lblHelp.Height := 24;
			lblHelp.Top := btnAdd.Top + btnAdd.Height + 8;
			lblHelp.Left := btnAdd.Left - 50;
			lblHelp.Caption := 'USE ADD BUTTON';
			frm.ShowModal;
		end;
		if (frm.ModalResult = mrOk) then begin
			// If list is empty
			if not CaptionExists('Remove', frm) then Exit;
			// Output		
			for i := 0 to slGlobal.Count-1 do
				if ContainsText(slGlobal[i], 'Original') or ContainsText(slGlobal[i], 'Template') then
					slTemp.Add(slGlobal[i]);
			for i := 0 to slTemp.Count-1 do
				if (slGlobal.IndexOf(slTemp[i]) >= 0) then
					slGlobal.Delete(slGlobal.IndexOf(slTemp[i]));
			slFiles.Assign(slGlobal);
			// Sender.Parent.Visible := False;
			tempComponent.Caption := ddDetectedFile.Text;
			slTemp.CommaText := 'ARMO, AMMO, WEAP';
			{Debug} if debugMsg then msgList('[ELLR_Bulk_OnClick] slFiles := ', slFiles, '');
			for i := 0 to slFiles.Count-1 do begin
				{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] if DoesFileExist('+slFiles[i]+' ) := '+BoolToStr(DoesFileExist(slFiles[i]))+' then begin');
				if DoesFileExist(slFiles[i]) then begin
					tempFile := FileByName(slFiles[i]);
					{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] tempFile := '+GetFileName(tempFile));
					{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] for x := 0 to slTemp.Count-1 := '+IntToStr(slTemp.Count-1)+' do begin');
					for x := 0 to slTemp.Count-1 do begin
						{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] for y := 0 to Pred(ec(gbs('+GetFileName(tempFile)+', '+slTemp[x]+' ))) := '+IntToStr(Pred(ec(gbs(ote(slFiles.Objects[i]), slTemp[x]))))+' do begin');	
						for y := 0 to Pred(ec(gbs(tempFile, slTemp[x]))) do begin
							{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] tempRecord := ebi(gbs('+GetFileName(tempFile)+', '+slTemp[x]'+), '+IntToStr(x)+' );');
							tempRecord := ebi(gbs(tempFile, slTemp[x]), y);
							if not (Length(EditorID(tempRecord)) > 0) then Continue;
							{Debug} if debugMsg then msg('[ELLR_Bulk_OnClick] tempRecord := '+EditorID(tempRecord));
							if not slContains(slGlobal, EditorID(tempRecord)) then begin
								slGlobal.AddObject(EditorID(tempRecord)+'Original', tempRecord);
								slGlobal.AddObject(EditorID(tempRecord)+'Template', GetTemplate(tempRecord));
							end;
						end;
					end;
				end;
			end;
			{Debug} if debugMsg then msgList('[ELLR_Bulk_OnClick] slGlobal := ', slGlobal, '');
			Sender.Parent.ModalResult := mrOk;
		end else begin
			tempComponent.Caption := ddDetectedFile.Text;
			slTemp.Clear;
			for i := 0 to slGlobal.Count-1 do
				if DoesFileExist(slGlobal[i]) then
					slTemp.Add(slGlobal[i]);
			for i := 0 to slTemp.Count-1 do
				if (slGlobal.IndexOf(slTemp[i]) >= 0) then
					slGlobal.Delete(slGlobal.IndexOf(slTemp[i]));	
		end;
	finally
		frm.Free;
	end;

	// Finalize
	slFiles.Free;
	slTemp.Free;

	debugMsg := false;
// End debugMsg Section
end;