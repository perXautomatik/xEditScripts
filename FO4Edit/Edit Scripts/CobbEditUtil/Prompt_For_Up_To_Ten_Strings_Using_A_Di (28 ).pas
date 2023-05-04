
{
   Prompt for up to ten strings using a dialog box; you can specify labels for 
   each string.
}
{$REGION 'PromptForStrings(asTitle, aslLabels)'}
Function PromptForStrings(asTitle: String; aslLabels: TStringList): TStringList;
Var
   iStringCount: Integer;
   uiDialog: TForm;
   uiDialogContent: TObject;
   uiDialogContentPanel: TPanel;
   iDialogHeight: Integer;
   iDialogPaddingX: Integer;
   iDialogPaddingY: Integer;
   sLabels: Array[0..9] of String;
   iCurrentY: Integer;
   uiLabels: Array[0..9] of TLabel;
   uiInputs: Array[0..9] of TEdit;
   iLabelWidth: Integer;
   iInputWidth: Integer;
   uiButtonOkay: TButton;
   uiButtonCancel: TButton;
   iButtonWidth: Integer;
   iMaxWidth: Integer;
   iIterator: Integer;
Begin
   iStringCount := Min(aslLabels.Count - 1, 9);
   iDialogPaddingX := 16;
   iDialogPaddingY :=  8;
   Result := TStringList.Create;
   uiDialog := TForm.Create(nil);
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
      iCurrentY := iDialogPaddingY;
      For iIterator := 0 To iStringCount Do Begin
         uiLabels[iIterator] := TLabel.Create(uiDialog);
         uiLabels[iIterator].Parent := uiDialogContentPanel;
         uiLabels[iIterator].Left := iDialogPaddingX;
         uiLabels[iIterator].Top := iCurrentY;
         uiLabels[iIterator].WordWrap := True;
         uiLabels[iIterator].Constraints.MinWidth := 250;
         uiLabels[iIterator].Constraints.MaxWidth := 600;
         uiLabels[iIterator].Constraints.MaxHeight := 9000;
         uiLabels[iIterator].Caption := aslLabels[iIterator];
	 //
         uiInputs[iIterator] := TEdit.Create(uiDialog);
         uiInputs[iIterator].Parent := uiDialogContentPanel;
         uiInputs[iIterator].Left := iDialogPaddingX;
         uiInputs[iIterator].Top := uiLabels[iIterator].Top + uiLabels[iIterator].Height + iDialogPaddingY;
         uiInputs[iIterator].Text := '';
	 //
	 iCurrentY := uiInputs[iIterator].Top + uiInputs[iIterator].Height + iDialogPaddingY;
      End;
      //
      uiButtonOkay := TButton.Create(uiDialog);
      uiButtonOkay.Parent := uiDialogContentPanel;
      uiButtonOkay.Caption := 'OK';
      uiButtonOkay.Default := True;
      uiButtonOkay.ModalResult := mrOk;
      uiButtonOkay.Top := uiInputs[iStringCount].Top + uiInputs[iStringCount].Height + iDialogPaddingY;
      uiButtonCancel := TButton.Create(uiDialog);
      uiButtonCancel.Parent := uiDialogContentPanel;
      uiButtonCancel.Caption := 'Cancel';
      uiButtonCancel.ModalResult := mrCancel;
      uiButtonCancel.Top := uiButtonOkay.Top;
      //
      // Finalize container dimensions, and center the buttons.
      //
      iLabelWidth := 0;
      iInputWidth := 0;
      For iIterator := 0 To iStringCount Do Begin
         iLabelWidth := Max(iLabelWidth, uiLabels[iIterator].Width);
         iInputWidth := Max(iInputWidth, uiInputs[iIterator].Width);
      End;
      uiDialogContentPanel.Height := uiButtonCancel.Top + uiButtonCancel.Height + iDialogPaddingY;
      uiDialog.ClientHeight := uiDialogContentPanel.Height;
      iButtonWidth := uiButtonOkay.Width + iDialogPaddingX + uiButtonCancel.Width;
      iMaxWidth := Max(Max(iLabelWidth, iInputWidth), iButtonWidth);
      For iIterator := 0 To iStringCount Do Begin
         uiLabels[iIterator].Width := iMaxWidth;
         uiInputs[iIterator].Width := iMaxWidth;
      End;
      uiButtonOkay.Left := (iMaxWidth - iButtonWidth) / 2 + iDialogPaddingX;
      uiButtonCancel.Left := uiButtonOkay.Left + uiButtonOkay.Width + iDialogPaddingX;
      uiDialog.ClientWidth := iMaxWidth + (iDialogPaddingX * 2);
      uiDialogContentPanel.Width := uiDialog.ClientWidth;
      //
      // Show the dialog and act on the result.
      //
      If uiDialog.ShowModal = mrOk Then Begin
         For iIterator := 0 To iStringCount Do Result.Add(uiInputs[iIterator].Text);
      End;
   Finally
      uiDialog.Free;
   End;
End;
{$ENDREGION}