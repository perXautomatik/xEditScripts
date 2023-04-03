
{$REGION 'PromptForEnum(asTitle, asLabel, aslOptions, out aiValue)'}
Function PromptForEnum(asTitle: String; asLabel: String; aslOptions: TStringList; var aiValue: Integer): Boolean;
Var
   uiDialog: TForm;
   uiDialogContent: TObject;
   uiDialogContentPanel: TPanel;
   iDialogHeight: Integer;
   iDialogPaddingX: Integer;
   iDialogPaddingY: Integer;
   uiLabel: TLabel;
   uiInput: TComboBox;
   uiButtonOkay: TButton;
   uiButtonCancel: TButton;
   iButtonWidth: Integer;
   iMaxWidth: Integer;
   iTemporary: Integer;
Begin
   iDialogPaddingX := 16;
   iDialogPaddingY :=  8;
   uiDialog := TForm.Create(nil);
   Result := False;
   Try
      uiDialog.Caption := asTitle;
      uiDialog.Position := poScreenCenter;
      uiDialogContentPanel := TPanel.Create(uiDialog);
      uiDialogContentPanel.Parent := uiDialog;
      uiDialogContentPanel.BevelOuter := bvNone;
      uiDialogContentPanel.Align := alTop;
      uiDialogContentPanel.Alignment := taLeftJustify;
      uiDialogContentPanel.Height := 400;
      //
      uiLabel := TLabel.Create(uiDialog);
      uiLabel.Parent := uiDialogContentPanel;
      uiLabel.Left := iDialogPaddingX;
      uiLabel.Top := iDialogPaddingY;
      uiLabel.WordWrap := True;
      uiLabel.Constraints.MinWidth := 250;
      uiLabel.Constraints.MaxWidth := 600;
      uiLabel.Constraints.MaxHeight := 9000;
      uiLabel.Caption := asLabel;
      //
      uiInput := TComboBox.Create(uiDialog);
      uiInput.Parent := uiDialogContentPanel;
      uiInput.Style := csDropDownList;
      uiInput.Left := iDialogPaddingX;
      uiInput.Top := uiLabel.Top + uiLabel.Height + iDialogPaddingY;
      uiInput.Items.Clear;
      For iTemporary := 0 To aslOptions.Count - 1 Do Begin
         uiInput.Items.Add(aslOptions[iTemporary]);
      End;
      uiInput.ItemIndex := 0;
      //
      uiButtonOkay := TButton.Create(uiDialog);
      uiButtonOkay.Parent := uiDialogContentPanel;
      uiButtonOkay.Caption := 'OK';
      uiButtonOkay.Default := True;
      uiButtonOkay.ModalResult := mrOk;
      uiButtonOkay.Top := uiInput.Top + uiInput.Height + iDialogPaddingY;
      uiButtonCancel := TButton.Create(uiDialog);
      uiButtonCancel.Parent := uiDialogContentPanel;
      uiButtonCancel.Caption := 'Cancel';
      uiButtonCancel.ModalResult := mrCancel;
      uiButtonCancel.Top := uiButtonOkay.Top;
      //
      // Finalize container dimensions, and center the buttons.
      //
      uiDialogContentPanel.Height := uiButtonCancel.Top + uiButtonCancel.Height + iDialogPaddingY;
      uiDialog.ClientHeight := uiDialogContentPanel.Height;
      iButtonWidth := uiButtonOkay.Width + iDialogPaddingX + uiButtonCancel.Width;
      iMaxWidth := Max(uiLabel.Width, uiInput.Width);
      uiLabel.Width := iMaxWidth;
      uiInput.Width := iMaxWidth;
      uiButtonOkay.Left := (iMaxWidth - iButtonWidth) / 2 + iDialogPaddingX;
      uiButtonCancel.Left := uiButtonOkay.Left + uiButtonOkay.Width + iDialogPaddingX;
      uiDialog.ClientWidth := iMaxWidth + (iDialogPaddingX * 2);
      uiDialogContentPanel.Width := uiDialog.ClientWidth;
      //
      // Show the dialog and act on the result.
      //
      If uiDialog.ShowModal = mrOk Then Begin
	 aiValue := uiInput.ItemIndex;
         Result := True;
      End;
   Finally
      uiDialog.Free;
   End;
End;
{$ENDREGION}