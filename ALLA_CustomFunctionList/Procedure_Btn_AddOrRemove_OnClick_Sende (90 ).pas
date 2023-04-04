
Procedure Btn_AddOrRemove_OnClick(Sender: TObject);
var
	btnAdd, btnRemove, btnOk, btnCancel: TButton;
	tempBoolean, debugMsg: Boolean;
	lblPlugin: TLabel;
	i, tempInteger: Integer;
	tempPlugin: String;
	GEVfile: IInterface;
	frm: TForm;
begin
// Begin debugMsg section
	debugMsg := false;

	// Grab values from parent form
	frm := Sender.Parent;
	if CaptionExists('Remove Plugin: ', frm) then begin
		tempPlugin := AssociatedComponent('Remove Plugin: ', frm).Caption;
		{Debug} if debugMsg then msg('[Btn_AddOrRemove_OnClick] tempPlugin := '+tempPlugin);
	end else if CaptionExists('Add Plugin: ', frm) then begin
		tempPlugin := AssociatedComponent('Add Plugin: ', frm).Caption;
		{Debug} if debugMsg then msg('[Btn_AddOrRemove_OnClick] tempPlugin := '+tempPlugin);
	end;

	// Manipulate static list of added values
	{Debug} if debugMsg then msg('[Btn_AddOrRemove_OnClick] TLabel(Sender).Caption := '+TLabel(Sender).Caption);
	if (TLabel(Sender).Caption = 'Add') then begin
		tempBoolean := False;
		for i := 0 to frm.ComponentCount-1 do
			if (frm.Components[i].Top >= 160) and (frm.Components[i].Caption = tempPlugin) then
				tempBoolean := True;
		if not tempBoolean and DoesFileExist(tempPlugin) then begin
			// Expand form
			frm.Height := frm.Height+36;
			// Shift existing components down
			TShift(160, 36, frm, False);
			// Remove Button
			btnRemove := TButton.Create(frm);
			btnRemove.Parent := frm;
			btnRemove.Caption := 'Remove';
			btnRemove.Left := 70;
			btnRemove.Top := 160;
			btnRemove.Width := 100;
			btnRemove.OnClick := Btn_AddOrRemove_OnClick;		
			// Remove Plugin label
			lblPlugin := TLabel.Create(frm);
			lblPlugin.Parent := frm;
			lblPlugin.Height := 24;
			lblPlugin.Top := btnRemove.Top + 2;
			lblPlugin.Left := 205;
			lblPlugin.Caption := tempPlugin;
		end;
		slGlobal.Add(tempPlugin);
	end else if (TLabel(Sender).Caption = 'Remove') then begin
		slGlobal.Delete(slGlobal.IndexOf(ComponentByTop(Sender.Top + 2, frm).Caption));
		ComponentByTop(Sender.Top + 2, frm).Free;
		Sender.Visible := False;
		// Shift existing components up
		TShift(Sender.Top, 36, frm, True);
		// Shrink form
		frm.Height := frm.Height-36;	
	end;
end;