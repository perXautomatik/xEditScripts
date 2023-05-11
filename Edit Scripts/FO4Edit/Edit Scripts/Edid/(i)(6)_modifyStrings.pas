{
	Name: Perpetually Modified Strings
	Author: eventHandler
	Version: beta3

	You may not use any part of this script in any way to directly or indirectly monetize any mod and/or other software. Voluntary donations are fine and not subject to this restriction.

	Written in DelphiScript, which is an OLE scripting language dervied from Standard Pascal.
	See https://support.smartbear.com/viewarticle/71968/ for more on this obscure language.

	The GUI is based on syntax learned by examining "Asset brower.pas" included with XEdit 3.1.3.
	Reference sources include:
		http://www.creationkit.com/index.php?title=TES5Edit_Scripting_Functions

	Mods be free!

	Hotkey: Ctrl+M
}
unit aaa_modifyBulkStrings;

var
	doProcess: bool;	
	processCount: integer;
	frm: TForm;
	cmbContainer: TComboBox;
	btnAddSuffix, btnReplace, btnTrim, btnFront2Tail, btnTail2Front, btnClose: TButton;
	strEl, strAction, strInp, strSearch, strMessage: string;
	btnAddPrefix, btnAppTail, btnRemFront, btnRemTail, btnRepAll, btnRepFront, btnRepTail: TButton;
	panelMain, panelOpt: TPanel;
	lblNote1, lblNote2: TLabel;

	elementName: IInterface;
	edClipboard: TEdit;
	mInfo: TMemo;
//===========================================================================
{

}
function Initialize: integer;
begin
	doProcess := false;
	processCount := 0;
	strMessage := 'String processing canceled.';
	ShowBrowser;
	Result := 0;
	Exit
end;

//=====
function Process(e: IInterface): integer;
begin
	if doProcess then begin
		elementName := ElementByName(e, strEl);
		parseAction
	end;

	Result := 0;
	Exit
end;

//===== parseAction
{

}
procedure parseAction(e: IInterface);
begin
	

	AddMessage('Processing in ' + FullPath(e));
	if strAction = 'AddPrefix' then
		AddPrefix;
	if strAction = 'AddSuffix' then
		AddSuffix;
	if strAction = 'Replace' then
		Replace;
	if strAction = 'Tail2Front' then
		Tail2Front;
	if strAction = 'Front2Tail' then
		Front2Tail;
	if strAction = 'TrimTail' then
		TrimTail;
	if strAction = 'TrimFront' then
		TrimFront;
	if strAction = 'ReplaceFront' then
		ReplaceFront;
	if strAction = 'ReplaceTail' then
		ReplaceTail;
end;


//===========================================================================
{

}
//===== Front2Tail, Tail2Front

procedure Front2Tail;
begin
	if Assigned(elementName) then begin
		strPresent := GetEditValue(elementName);
		Delete(strPresent, 1, Length(strInp));
		SetEditValue(elementName, strPresent + strInp)
	end;
end;

//=====
procedure Tail2Front;
begin
	if Assigned(elementName) then begin
		strPresent := GetEditValue(elementName);
		Delete(strPresent, Length(strPresent) - Length(strInp) + 1, Length(strPresent));
		SetEditValue(elementName, strInp + strPresent)
	end;
end;




function Finalize: integer;
begin
	AddMessage(Format('%d records processed.', [processCount]));
end;


//===== AddPrefix, AddSuffix

procedure AddPrefix;
var
	elementName: IInterface;
	strPresent, strResult: string;
begin
	if Assigned(elementName) then begin
		elementName := ElementByName(e, strEl);
		strPresent := GetEditValue(elementName);
		Inc(processCount);
	
		SetEditValue(elementName, strInp + strPresent)

	end;
end;

//=====
procedure AddSufix;
var
	elementName: IInterface;
	strPresent, strResult: string;
begin
	if Assigned(elementName) then begin
	elementName := ElementByName(e, strEl);
	strPresent := GetEditValue(elementName);
	Inc(processCount);

		SetEditValue(elementName, strPresent + strInp)
	end;
end;


//===== TrimFront, TrimTail

procedure TrimFront;
var
strTest: string;
begin
	if Assigned(elementName) then begin
		strPresent := GetEditValue(elementName);
		strTest := strPresent;
		Delete(strTest, Length(strInp) + 1, Length(strPresent));
		if AnsiCompareText(strTest, strInp) = 0 then begin
			Delete(strPresent, 1, Length(strInp));
			SetEditValue(elementName, strPresent)
		end;
	end;
end;

//=====
procedure TrimTail;
var
strTest: string;
begin
	if Assigned(elementName) then begin
		strPresent := GetEditValue(elementName);
		strTest := strPresent;
		Delete(strTest, 1, Length(strPresent) - Length(strInp));
		if AnsiCompareText(strTest, strInp) = 0 then begin
			Delete(strPresent, Length(strPresent) - Length(strInp) + 1, Length(strPresent));
			SetEditValue(elementName, strPresent)
		end;
	end;
end;

//===== Replace, ReplaceFront, ReplaceTail
procedure Replace;
var
	elementName: IInterface;
	strPresent, strResult: string;
begin
	if Assigned(elementName) then begin
	elementName := ElementByName(e, strEl);
	strPresent := GetEditValue(elementName);
	Inc(processCount);

	strResult := StringReplace(strPresent, strSearch, strInp, [rfReplace]);
	if not SameText(strResult, strPresent) then begin
			SetEditValue(elementName, strResult)
	end;
end;



//=====
procedure ReplaceFront;
begin
	if Assigned(elementName) then begin
		strPresent := GetEditValue(elementName);
		Delete(strPresent, 1, Length(strInp));
		SetEditValue(elementName, strInp + strPresent)
	end;
end;

//=====
procedure ReplaceTail;
begin
	if Assigned(elementName) then begin
		strPresent := GetEditValue(elementName);
		Delete(strPresent, Length(strPresent) - Length(strInp) + 1, Length(strPresent));
		SetEditValue(elementName, strPresent + strInp)
	end;

//===== on key down event handler for form
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if Key = VK_ESCAPE then
		TForm(Sender).ModalResult := mrOk;
end;


//=====
procedure evtClickBtnAddSuffix(Sender: TObject);
begin
	panelMain.Hide;
	btnAddPrefix.Show;
	btnAppTail.Show;
end;




//=====
procedure evtClickBtnTrim(Sender: TObject);
begin
	panelMain.Hide;
	btnRemFront.Show;
	btnRemTail.Show;
end;

//=====
procedure evtClickBtnReplace(Sender: TObject);
begin
	panelMain.Hide;
	btnRepAll.Show;
	btnRepFront.Show;
	btnRepTail.Show;
end;


//=====
procedure evtClickBtnFront2Tail(Sender: TObject);
begin
	strAction := 'Front2Tail';
	GetInput('Swap');
	doProcess := true;
end;

//=====
procedure evtClickBtnTail2Front(Sender: TObject);
begin
	strAction := 'Tail2Front';
	GetInput('Swap');
	doProcess := true;
end;

//===========================================================================
{

}

//=====
procedure evtClickBtnAddPrefix(Sender: TObject);
begin
	strAction := 'AddPrefix';
	GetInput('Addfix');
	doProcess := true;
	btnAddPrefix.Hide;
	btnAppTail.Hide;
	panelMain.Show;
end;



//=====
procedure evtClickBtnAddSuffix(Sender: TObject);
begin
	strAction := 'AddSuffix';
	GetInput('Addfix');
	doProcess := true;
	btnAddPrefix.Hide;
	btnAppTail.Hide;
	panelMain.Show;
end;


end;




//=====
procedure evtClickBtnRemFront(Sender: TObject);
begin
	strAction := 'TrimFront';
	GetInput('Trim');
	doProcess := true;
	btnRemFront.Hide;
	btnRemTail.Hide;
	panelMain.Show;
end;

//=====
procedure evtClickBtnRemTail(Sender: TObject);
begin
	strAction := 'TrimTail';
	GetInput('Trim');
	doProcess := true;
	btnRemFront.Hide;
	btnRemTail.Hide;
	panelMain.Show;
end;

//=====
procedure evtClickBtnRepAll(Sender: TObject);
begin
	strAction := 'Replace';
	GetInput('Replace');
	doProcess := true;
	btnRepAll.Hide;
	btnRepFront.Hide;
	btnRepTail.Hide;
	panelMain.Show;
end;

//=====
procedure evtClickBtnRepFront(Sender: TObject);
begin
	strAction := 'ReplaceFront';
	GetInput('Replace');
	doProcess := true;
	btnRepAll.Hide;
	btnRepFront.Hide;
	btnRepTail.Hide;
	panelMain.Show;
end;

//=====
procedure evtClickBtnRepTail(Sender: TObject);
begin
	strAction := 'ReplaceTail';
	GetInput('Replace');
	doProcess := true;
	btnRepAll.Hide;
	btnRepFront.Hide;
	btnRepTail.Hide;
	panelMain.Show;
end;




//=====
procedure cmbContainerOnChange(Sender: TObject);
begin
	strEl := cmbContainer.Text;
end;


//=====
{

}
procedure ShowBrowser;
var
	i, tOff, lOff, vPad, hPad, btnWidth, btnHeight: integer;
begin
	tOff := 48;
	lOff := 24;
	vPad := 8;
	hPad := 8;
	btnWidth := 180;
	frm := TForm.Create(nil);
	try
		frm.Caption := 'Modify Strings';
		frm.Width := 900;
		frm.Height := 480;
		frm.Position := poScreenCenter;
		frm.KeyPreview := True;
		panelMain.OnKeyDown := FormKeyDown;

		panelMain := TPanel.Create(frm);
		panelMain.Parent := frm;
		panelMain.Width := frm.Width;
		panelMain.Height := frm.Height;
		panelMain.Top := frm.Top;
		panelMain.Left := frm.Left;
		panelMain.Anchors := [akRight, akBottom];

		btnReplace := TButton.Create(panelMain);
		btnReplace.Parent := panelMain;
		btnReplace.Top := btnTrim.Top + btnTrim.Height + vPad;
		btnReplace.Left := lOff;
		btnReplace.Width := btnWidth;
		btnReplace.Caption := 'Replace';
		btnReplace.Anchors := [akRight, akBottom];
		btnReplace.OnClick := evtClickBtnReplace;

		btnAddSuffix := TButton.Create(panelMain);
		btnAddSuffix.Parent := panelMain;
		btnAddSuffix.Top := tOff;
		btnAddSuffix.Left := lOff;
		btnAddSuffix.Width := btnWidth;
		btnAddSuffix.Caption := 'Add Suffix';
		btnAddSuffix.Anchors := [akRight, akBottom];
		btnAddSuffix.OnClick := evtClickBtnAddSuffix;

		btnAddPrefix := TButton.Create(panelMain);
		btnAddPrefix.Parent := panelMain;
		btnAddPrefix.Left := lOff + btnWidth*2 + hPad*2;
		btnAddPrefix.Top := tOff;
		btnAddPrefix.Width := btnWidth;
		btnAddPrefix.Caption := 'Add Prefix';
		btnAddPrefix.Anchors := [akRight, akBottom];
		btnAddPrefix.OnClick := evtClickBtnAddPrefix;
		btnAddPrefix.Visible := False;
		btnAddPrefix.ModalResult := mrOk;

		cmbContainer := TComboBox.Create(panelMain);
		cmbContainer.Parent := panelMain;
		cmbContainer.Style := csDropDownList;
		//cmbContainer.DropDownCount := 32;
		cmbContainer.Anchors := [akTop, akRight];
		cmbContainer.OnChange := cmbContainerOnChange;
		cmbContainer.Top := tOff/6;
		cmbContainer.Left := panelMain.Width/2 + btnWidth;
		cmbContainer.Width := panelMain.Width - cmbContainer.Left - lOff;
		// Add editor fields you want to alter with the script here
		// All
		cmbContainer.Items.Add('EDID - Editor ID');
		cmbContainer.Items.Add('ONAM - Short Name');
		cmbContainer.Items.Add('FULL - Name');
		cmbContainer.Items.Add('DESC - Description');
		cmbContainer.Items.Add('DATA - Weight');
		// 
		cmbContainer.Items.Add('Ownership');
		cmbContainer.Items.Add('XCNT - Item Count');
		cmbContainer.Items.Add('XCHG - Charge');
		cmbContainer.Items.Add('XLRL - Location Reference');
		cmbContainer.Items.Add('CNAM - Created Object');
		cmbContainer.Items.Add('BNAM - Workbench Keyword');
		cmbContainer.Items.Add('YNAM - Sound - Pick Up');
		cmbContainer.Items.Add('ZNAM - Sound - Drop');
		cmbContainer.Items.Add('CRIF - Crime faction');
		cmbContainer.Items.Add('DOFT - Default outfit');
		cmbContainer.Items.Add('RNAM - Race');
		cmbContainer.Items.Add('CNAM - Class');
		cmbContainer.Items.Add('ATKR - Attack Race');
		cmbContainer.Items.Add('ZNAM - Combat Style');
		cmbContainer.Items.Add('HCLF - Hair Color');
		cmbContainer.Items.Add('FTST - Head texture');
		cmbContainer.Items.Add('VTCK - Voice');
		cmbContainer.Items.Add('EAMT - Enchantment Amount');
		cmbContainer.Items.Add('ZNAM - Music');
		cmbContainer.Items.Add('NAM2 - Water');
		cmbContainer.Items.Add('LTMP - Interior Lighting');
		cmbContainer.Items.Add('LTMP - Lighting Template');
		cmbContainer.Items.Add('XEZN - Encounter Zone');
		cmbContainer.Items.Add('XLCN - Location');
		cmbContainer.Items.Add('ETYP - Equipment Type');
		cmbContainer.Items.Add('XIS2 - Ignored by Sandbox');
		cmbContainer.Items.Add('XLOC - Lock Data');
		cmbContainer.Items.Add('XSCL - Scale');
		cmbContainer.Items.Add('XLIB - Leveled Item Base Object');
		cmbContainer.Items.Add('XLCN - Persistent Location');
		cmbContainer.Items.Add('XSPC - Spawn Container');
		cmbContainer.Items.Add('XNDP - Navigation Door Link');
		cmbContainer.Items.Add('XRDS - Radius');
		cmbContainer.Items.Add('XCIM - Image Space');
		cmbContainer.Items.Add('XCMO - Music Type');
		cmbContainer.Items.Add('XCAS - Acoustic Space');
		cmbContainer.Items.Add('XCLW - Water Height');
		cmbContainer.Items.Add('WNAM - Water Type');
		cmbContainer.Items.Add('VNAM - Sound - Activation');
		cmbContainer.Items.Add('RNAM - Activate Text Override');

		cmbContainer.Items.Add('KWDA - Keywords\Keyword');

		cmbContainer.Items.Add('ENIT - Effect Data\Value');
		cmbContainer.Items.Add('ENIT - Effect Data\Addiction');
		cmbContainer.Items.Add('ENIT - Effect Data\Addiction Chance');
		cmbContainer.Items.Add('ENIT - Effect Data\Sound - Consume'); 

		cmbContainer.Items.Add('Effects\Effect\EFID - Base Effect');
		cmbContainer.Items.Add('Effects\Effect\EFIT\Magnitude');
		cmbContainer.Items.Add('Effects\Effect\EFIT\Area');
		cmbContainer.Items.Add('Effects\Effect\EFIT\Duration'); 

		cmbContainer.Items.Add('DATA - Position/Rotation');
		cmbContainer.Items.Add('DATA - Position/Rotation\Position');
		cmbContainer.Items.Add('DATA - Position/Rotation\Position\X');
		cmbContainer.Items.Add('DATA - Position/Rotation\Position\Y');
		cmbContainer.Items.Add('DATA - Position/Rotation\Position\Z');
		cmbContainer.Items.Add('DATA - Position/Rotation\Rotation');
		cmbContainer.Items.Add('DATA - Position/Rotation\Rotation\X');
		cmbContainer.Items.Add('DATA - Position/Rotation\Rotation\Y');
		cmbContainer.Items.Add('DATA - Position/Rotation\Rotation\Z'); 
		//for i := 0 to Pred(slContainers.Count) do
			//cmbContainer.Items.Add(SimpleName(slContainers[i]));
		cmbContainer.ItemIndex := 0;

		lblNote2 := TLabel.Create(panelMain);
		lblNote2.Parent := panelMain;
		lblNote2.Top := cmbContainer.Top + cmbContainer.Height + vPad;
		lblNote2.Left := cmbContainer.Left;
		lblNote2.Anchors := [akRight, akBottom];
		lblNote2.Caption := 'WARNING: Currently no safeguards to ensure'#13'the records being modified have the selected field'#13'from this drop down list! It is YOUR responsibility'#13'to pick valid options for the records being modified.'#13#13'ONLY REPLACE ALL should be used on any'#13'non-string element. Most elements are non-string!'#13#13'Records missing the element selected will be skipped.';


		btnTrim := TButton.Create(panelMain);
		btnTrim.Parent := panelMain;
		btnTrim.Top := btnAddSuffix.Top + btnAddSuffix.Height + vPad;
		btnTrim.Left := lOff;
		btnTrim.Width := btnWidth;
		btnTrim.Caption := 'Trim from existing entry.';
		btnTrim.Anchors := [akRight, akBottom];
		btnTrim.OnClick := evtClickBtnTrim;

		btnFront2Tail := TButton.Create(panelMain);
		btnFront2Tail.Parent := panelMain;
		btnFront2Tail.Top := tOff;
		btnFront2Tail.Left := lOff + btnWidth + hPad;
		btnFront2Tail.Width := btnWidth;
		btnFront2Tail.Caption := 'Front2Tail';
		btnFront2Tail.Anchors := [akRight, akBottom];
		btnFront2Tail.OnClick := evtClickBtnFront2Tail;

		btnTail2Front := TButton.Create(panelMain);
		btnTail2Front.Parent := panelMain;
		btnTail2Front.Top := btnFront2Tail.Top + btnFront2Tail.Height + vPad;
		btnTail2Front.Left := lOff + btnWidth + hPad;
		btnTail2Front.Width := btnWidth;
		btnTail2Front.Caption := 'Tail2Front';
		btnTail2Front.Anchors := [akRight, akBottom];
		btnTail2Front.OnClick := evtClickBtnTail2Front;

		btnAppTail := TButton.Create(panelMain);
		btnAppTail.Parent := panelMain;
		btnAppTail.Top := btnAddPrefix.Top + btnAddPrefix.Height + vPad;
		btnAppTail.Left := lOff + btnWidth*2 + hPad*2;
		btnAppTail.Width := btnWidth;
		btnAppTail.Caption := 'AddSuffix Tail';
		btnAppTail.Anchors := [akRight, akBottom];
		btnAppTail.OnClick := evtClickBtnAddSuffix;
		btnAppTail.Visible := False;

		btnRemFront := TButton.Create(panelMain);
		btnRemFront.Parent := panelMain;
		btnRemFront.Top := tOff;
		btnRemFront.Left := lOff + btnWidth*2 + hPad*2;
		btnRemFront.Width := btnWidth;
		btnRemFront.Caption := 'Trim Front';
		btnRemFront.Anchors := [akRight, akBottom];
		btnRemFront.OnClick := evtClickBtnRemFront;
		btnRemFront.Visible := False;

		btnRemTail := TButton.Create(panelMain);
		btnRemTail.Parent := panelMain;
		btnRemTail.Top := btnRemFront.Top + btnRemFront.Height + vPad;
		btnRemTail.Left := lOff + btnWidth*2 + hPad*2;
		btnRemTail.Width := btnWidth;
		btnRemTail.Caption := 'Trim Tail';
		btnRemTail.Anchors := [akRight, akBottom];
		btnRemTail.OnClick := evtClickBtnRemTail;
		btnRemTail.Visible := False;

		btnRepAll := TButton.Create(panelMain);
		btnRepAll.Parent := panelMain;
		btnRepAll.Top := tOff;
		btnRepAll.Left := lOff + btnWidth*2 + hPad*2;
		btnRepAll.Width := btnWidth;
		btnRepAll.Caption := 'Replace All';
		btnRepAll.Anchors := [akRight, akBottom];
		btnRepAll.OnClick := evtClickBtnRepAll;
		btnRepAll.Visible := False;

		btnRepFront := TButton.Create(panelMain);
		btnRepFront.Parent := panelMain;
		btnRepFront.Top := btnRepAll.Top + btnRepAll.Height + vPad;
		btnRepFront.Left := lOff + btnWidth*2 + hPad*2;
		btnRepFront.Width := btnWidth;
		btnRepFront.Caption := 'Replace Front';
		btnRepFront.Anchors := [akRight, akBottom];
		btnRepFront.OnClick := evtClickBtnRepFront;
		btnRepFront.Visible := False;

		btnRepTail := TButton.Create(panelMain);
		btnRepTail.Parent := panelMain;
		btnRepTail.Top := btnRepFront.Top + btnRepFront.Height + vPad;
		btnRepTail.Left := lOff + btnWidth*2 + hPad*2;
		btnRepTail.Width := btnWidth;
		btnRepTail.Caption := 'Replace Tail';
		btnRepTail.Anchors := [akRight, akBottom];
		btnRepTail.OnClick := evtClickBtnRepTail;
		btnRepTail.Visible := False;

		btnClose := TButton.Create(panelMain);
		btnClose.Parent := panelMain;
		btnClose.Top := btnReplace.Top + btnReplace.Height + vPad;
		btnClose.Left := lOff;
		btnClose.Width := btnWidth;
		btnClose.Caption := 'Close';
		btnClose.Anchors := [akRight, akBottom];
		btnClose.ModalResult := mrOk;

		// invisible edit field used to copy to clipboard
		edClipboard := TEdit.Create(panelMain);
		edClipboard.Parent := panelMain;
		edClipboard.Visible := False;

		mInfo := TMemo.Create(panelMain);
		mInfo.Parent := panelMain;
		mInfo.Top := btnClose.Top + btnClose.Height + vPad*8;
		mInfo.Left := lOff;
		mInfo.Width := panelMain.Width - lOff*2;
		mInfo.Height := 180;
		mInfo.Anchors := [akLeft, akRight, akBottom];
		mInfo.ScrollBars := ssVertical;
		mInfo.ReadOnly := True;

		lblNote1 := TLabel.Create(panelMain);
		lblNote1.Parent := panelMain;
		lblNote1.Top := mInfo.Top + mInfo.Height + vPad;
		lblNote1.Left := lOff + btnWidth/2;
		lblNote1.Anchors := [akRight, akBottom];
		lblNote1.Caption := 'Notes: *Replace front/tail only replaces the same # of characters used as input,'#13'      it does NOT actually compare the front/tail to the input being replaced.'#13'*Trim DOES compare input and skips non-matches (case insensitive).'#13'*Tail2Front/Front2Tail really just swap text the length of the input for now.';


		strEl := cmbContainer.Text;
		btnAddSuffix.ModalResult := mrOk;
		btnReplace.ModalResult := mrOk;
		frm.ShowModal;
	finally
		frm.Free;
	end;
end;

procedure GetInput(strAction: string);
var
strIn: string;
begin
	if strAction = 'Addfix' then begin
	if not InputQuery(strAction, 'String to add as fix: ', strInp) then begin
			Result := 1;
		AddMessage(strMessage);
			Exit
		end;
	end;


	if strAction = 'Replace' then begin
		if not InputQuery('Done', 'Type here what to set as the replacement text:', strInp) then begin
			Result := 1;
		AddMessage(strMessage);
			Exit
		end;
	end;

	if strAction = 'Swap' then begin
		if not InputQuery(strAction, 'Type here what to swap:', strInp) then begin
			Result := 1;
		AddMessage(strMessage);
			Exit
		end;
	end;
	
	if strAction = 'Trim' then begin
		if not InputQuery(strAction, 'Type here what to remove: ', strInp) then begin
			Result := 1;
			AddMessage('Invalid input while collecting trim text.');
			Exit
		end;
	end;
end;

//===========================================================================
{

}

end.

//===========================================================================
{
	Always use tabs when indenting, and remember: Only YOU can prevent chaotic text alignment with untold bytes wasted on white space!

	Use Notepad++ and choose your own tab width for personal preference! Standard tab width is four fixed-width spaces. That is the only correct width, and what any civilized person will use.

	I take full (posthumous) responsibility if you blow up the planet using my scripts, but not for more mundane annoyances. I apologize in advance to everyone affected by the world blowing up.

	No lawsuits allowed against me. You've been warned!
}
