
{
   Shows a Yes/No box with the specified labels, and returns a boolean indicating 
   how the user closed the box.
}
{$REGION 'UIConfirm(asTitle, asText, asYes, asNo)'}
Function UIConfirm(asTitle: String; asText: String; asYes: String = 'Yes'; asNo: String = 'No'): Boolean;
Var
   uiDialog: TForm;
   uiContainer: TPanel;
   uiLabel: TLabel;
   uiButtonYes: TButton;
   uiButtonNo: TButton;
   iDialogPaddingX: Integer;
   iDialogPaddingY: Integer;
   iButtonWidth: Integer;
   iMaxWidth: Integer;
Begin
   iDialogPaddingX := 16;
   iDialogPaddingY := 8;
   Result := False;
   uiDialog := TForm.Create(nil);
   Try
      uiDialog.Caption := asTitle;
      uiDialog.Position := poScreenCenter;
      uiContainer := TPanel.Create(uiDialog);
      uiContainer.Parent := uiDialog;
      uiContainer.BevelOuter := bvNone;
      uiContainer.Align := alTop;
      uiContainer.Alignment := taLeftJustify;
      uiContainer.Height := 400;
      uiLabel := TLabel.Create(uiDialog);
      uiLabel.Parent := uiContainer;
      uiLabel.Left := iDialogPaddingX;
      uiLabel.Top := iDialogPaddingY;
      uiLabel.Caption := asText;
      uiButtonYes := TButton.Create(uiDialog);
      uiButtonYes.Parent := uiContainer;
      uiButtonYes.Caption := asYes;
      uiButtonYes.ModalResult := mrOk;
      uiButtonNo := TButton.Create(uiDialog);
      uiButtonNo.Parent := uiContainer;
      uiButtonNo.Caption := asNo;
      uiButtonNo.ModalResult := mrCancel;
      //
      // Finalize dimensions.
      //
      uiButtonYes.Top := uiLabel.Top + uiLabel.Height + iDialogPaddingY;
      uiButtonNo.Top := uiButtonYes.Top;
      //
      iButtonWidth := uiButtonYes.Width + 16 + uiButtonNo.Width;
      iMaxWidth := Max(uiLabel.Width, iButtonWidth);
      uiDialog.ClientWidth := iMaxWidth + iDialogPaddingX * 2;
      uiContainer.Height := uiButtonYes.Top + uiButtonYes.Height + iDialogPaddingY;
      uiDialog.ClientHeight := uiContainer.Height;
      uiButtonYes.Left := (iMaxWidth - iButtonWidth) / 2 + iDialogPaddingX;
      uiButtonNo.Left := uiButtonYes.Left + uiButtonYes.Width + 16;
      //
      // Show the dialog and act on the result.
      //
      Result := False;
      If uiDialog.ShowModal = mrOk Then Result := True;
   Finally
      uiDialog.Free;
   End;
End;
{$ENDREGION}