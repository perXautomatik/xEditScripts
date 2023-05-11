{
  Find exterior cell by X,Y grid coordinates.
  
  Hotkey: Ctrl+Shift+F
}
unit userscript;
uses: 'universalHelperFunctions'

  
procedure OptionsForm;
var
  frm: TForm;
  btnOk, btnCancel: TButton;
  lbWorld: TListBox;
  edX, edY: TLabeledEdit;
  lbl1, lbl2: TLabel;
begin
  frm := TForm.Create(nil);
  try
    frm.Caption := 'Find cell in worldspace';
    frm.Width := 220;
    frm.Height := 500;
    frm.Position := poScreenCenter;
    frm.BorderStyle := bsDialog;
    frm.KeyPreview := True;
    frm.OnKeyDown := FormKeyDown;
    
    edX := TLabeledEdit.Create(frm);
    edX.Parent := frm;
    edX.LabelPosition := lpLeft;
    edX.EditLabel.Caption := 'X:';
    edX.Left := 24;
    edX.Top := 8;
    edX.Width := 40;

    edY := TLabeledEdit.Create(frm);
    edY.Parent := frm;
    edY.LabelPosition := lpLeft;
    edY.EditLabel.Caption := 'Y:';
    edY.Left := edX.Left + 70;
    edY.Top := edX.Top;
    edY.Width := edX.Width;

    lbWorld := TListBox.Create(frm);
    lbWorld.Parent := frm;
    lbWorld.Left := 8;
    lbWorld.Top := 36;
    lbWorld.Width := 200;
    lbWorld.Height := 400;
    
    FillWorldspaces(lbWorld.Items);
    if lbWorld.Items.Count > 0 then begin
      if (wbGameMode = gmTES4) or (wbGameMode = gmTES5) then lbWorld.ItemIndex := lbWorld.Items.IndexOf('Tamriel') else
      if wbGameMode = gmFO3 then lbWorld.ItemIndex := lbWorld.Items.IndexOf('Wasteland') else
      if wbGameMode = gmFNV then lbWorld.ItemIndex := lbWorld.Items.IndexOf('WastelandNV') else
        lbWorld.ItemIndex := 0;
    end;

    btnOk := TButton.Create(frm);
    btnOk.Parent := frm;
    btnOk.Caption := 'OK';
    btnOk.ModalResult := mrOk;
    btnOk.Left := 24;
    btnOk.Top := 442;
    
    btnCancel := TButton.Create(frm);
    btnCancel.Parent := frm;
    btnCancel.Caption := 'Cancel';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Left := btnOk.Left + btnOk.Width + 16;
    btnCancel.Top := btnOk.Top;
    
    if frm.ShowModal = mrOk then begin
     if (lbWorld.ItemIndex <> -1) and (Trim(edX.Text) <> '') and (Trim(edY.Text) <> '') then
       FindCell(lbWorld.Items[lbWorld.ItemIndex], edX.Text, edY.Text);
    end;
  finally
    frm.Free;
  end;
end;

function Initialize: Integer;
begin
  OptionsForm;
  Result := 1;
end;

end.