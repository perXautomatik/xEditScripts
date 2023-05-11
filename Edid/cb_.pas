{
	StringOps
	Hotkey: Ctrl+R
	
  This script will prepend or append supplied value to the EditorID field
  of every selected record.
  
  Doesn't modify records that already have the same prefix/suffix.
}
unit UserScript;

var
  DoPrepend: boolean;
  s: string;
	frmSearch: TForm;
	sElementPath: String;
	bProperCase: Boolean;
	bSentenceCase: Boolean;
	bModify: Boolean;
	sQuerySearch: String;
	sQueryReplace: String;
	sQueryPrefix: String;
	sQuerySuffix: String;
	bCaseSensitive: Boolean;
	frmModalResult: TModalResult;
	lblModifyOptions: TLabel;
	edElementPath: TEdit;
	edQuerySearch: TEdit;
	edQueryReplace: TEdit;
	rbProperCase: TRadioButton;
	rbSentenceCase: TRadioButton;
	rbModify: TRadioButton;
	edQueryPrefix: TEdit;
	edQuerySuffix: TEdit;
	btnExecute: TButton;
	btnClose: TButton;


function Initialize: Integer;
begin
	ShowSearchForm;

	if frmSearch.ModalResult = mrCancel then
		exit;
end;

function Process(e: IInterface): Integer;
var
	x: IInterface;
	i: Integer;
	sRecordID: String;
	sElementPathTemplate: String;
begin
	if frmSearch.ModalResult = mrCancel then
		exit;

	sRecordID := GetEditValue(GetElement(e, 'Record Header\FormID'));

	if ContainsText(sElementPath, '[*]') then begin
		sElementPathTemplate := sElementPath;

		// set up first child element
		sElementPath := StringReplace(sElementPathTemplate, '[*]', '[0]', [rfReplaceAll]);
		x := GetElement(e, sElementPath);

		if not Assigned(x) or not IsEditable(x) then
			exit;

		i := 0;
		repeat
			ExecuteExecuteExecute(x);
			AddMessage('Processed: ' + sRecordID + ' @ ' + sElementPath);

			// set up next child element
			Inc(i);
			sElementPath := StringReplace(sElementPathTemplate, '[*]', '[' + IntToStr(i) + ']', [rfReplaceAll]);
			x := GetElement(e, sElementPath);
		until not Assigned(x) or not IsEditable(x);

		sElementPath := sElementPathTemplate;
		exit;
	end;

	x := GetElement(e, sElementPath);

	if not Assigned(x) or not IsEditable(x) then
		exit;

	ExecuteExecuteExecute(x);
	AddMessage('Processed: ' + sRecordID);
end;

function Finalize: Integer;
begin
	frmSearch.Free;
end;

function ExecuteExecuteExecute(aElement: IInterface): Integer;
var
	sHaystack: String;
	bMatchFound: Boolean;
	bAddPrefix: Boolean;
	bAddSuffix: Boolean;
begin
	sHaystack := GetEditValue(aElement);

	if not (Length(sHaystack) > 0) then
		exit;

	if bProperCase then begin
		SetEditValue(aElement, ProperCase(sHaystack));
		exit;
	end;

	if bSentenceCase then begin
		SetEditValue(aElement, SentenceCase(sHaystack));
		exit;
	end;

	if not bModify then
		exit;

	if Length(sQuerySearch) > 0 then begin
		if bCaseSensitive then
			bMatchFound := ContainsStr(sHaystack, sQuerySearch)
		else
			bMatchFound := ContainsText(sHaystack, sQuerySearch);

		if bMatchFound then begin
			sHaystack := GetEditValue(aElement);

			if bCaseSensitive then
				sHaystack := StringReplace(sHaystack, sQuerySearch, sQueryReplace, [rfReplaceAll])
			else
				sHaystack := StringReplace(sHaystack, sQuerySearch, sQueryReplace, [rfReplaceAll, rfIgnoreCase]);

			// handle special tokens
			sHaystack := StringReplace(sHaystack, '#13', #13, [rfReplaceAll]);
			sHaystack := StringReplace(sHaystack, '#10', #10, [rfReplaceAll]);
			sHaystack := StringReplace(sHaystack, '#9', #9, [rfReplaceAll]);

			SetEditValue(aElement, sHaystack);
		end;
	end;

	bAddPrefix := Length(sQueryPrefix) > 0;
	bAddSuffix := Length(sQuerySuffix) > 0;

	if bAddPrefix or bAddSuffix then begin
		// ensure we're working with latest haystack
		sHaystack := GetEditValue(aElement);

		// we don't care about prefix/suffix case sensitivity
		if bAddPrefix then
			if not StartsText(sQueryPrefix, sHayStack) then
				sHaystack := Insert(sQueryPrefix, sHaystack, 0);

		if bAddSuffix then
			if not EndsText(sQuerySuffix, sHaystack) then
				sHaystack := Insert(sQuerySuffix, sHaystack, Length(sHaystack) + 1);

		SetEditValue(aElement, sHaystack);
	end;
end;

function GetChar(const aText: String; aPosition: Integer): Char;
begin
	Result := Copy(aText, aPosition, 1);
end;

procedure SetChar(var aText: String; aPosition: Integer; aChar: Char);
var
	sHead, sTail: String;
begin
	sHead := Copy(aText, 1, aPosition - 1);
	sTail := Copy(aText, aPosition + 1, Length(aText));
	aText := sHead + aChar + sTail;
end;

function InStringList(const aText: String; const aList: TStringList): Boolean;
begin
	Result := (aList.IndexOf(aText) <> -1);
end;

function SentenceCase(const aText: String): String;
begin
	Result := '';
	if aText <> '' then
		Result := UpCase(aText[1]) + Copy(LowerCase(aText), 2, Length(aText));
end;

function ProperCase(const aText: String): String;
var
	slResults: TStringList;
	slLowerCase: TStringList;
	slUpperCase: TStringList;
	i, dp: Integer;
	rs, tmp: String;
begin
	slLowerCase := TStringList.Create;
	slUpperCase := TStringList.Create;

	slLowerCase.CommaText := ' a , an , the , and , but , or , nor , at , by , for , from , in , into , of , off , on , onto , out , over , up , with , to , as ';
	slUpperCase.CommaText := ' fx , npc ';

	slResults := TStringList.Create;
	slResults.Delimiter := ' ';
	slResults.DelimitedText := aText;

	for i := 0 to Pred(slResults.Count) do begin
		tmp := slResults[i];

		tmp := SentenceCase(tmp);

		if InStringList(tmp, slLowerCase) and i <> 0 then
			tmp := LowerCase(tmp);

		if InStringList(tmp, slUpperCase) and i <> 0 then
			tmp := UpperCase(tmp);

		if GetChar(tmp, 1) = '(' then
			SetChar(tmp, 2, UpperCase(GetChar(tmp, 2)));

		if GetChar(tmp, 1) = '<' then
			SetChar(tmp, 2, UpperCase(GetChar(tmp, 2)));

		if GetChar(tmp, 1) = '=' then
			SetChar(tmp, 2, UpperCase(GetChar(tmp, 2)));

		if Pos('-', tmp) > 0 then begin
			dp := Pos('-', tmp);
			if GetChar(tmp, dp + 1) <> ' ' then
				SetChar(tmp, dp + 1, UpperCase(GetChar(tmp, dp + 1)));
		end;

		slResults[i] := tmp;
	end;

	Result := slResults.DelimitedText;

	slResults.Free;
	slLowerCase.Free;
	slUpperCase.Free;
end;

function GetElement(const aElement: IInterface; const aPath: String): IInterface;
begin
	if Pos('[', aPath) > 0 then
		Result := ElementByIP(aElement, aPath)
	else if Pos('\', aPath) > 0 then
		Result := ElementByPath(aElement, aPath)
	else if CompareStr(aPath, Uppercase(aPath)) = 0 then
		Result := ElementBySignature(aElement, aPath)
	else
		Result := ElementByName(aElement, aPath);
end;

function ElementByIP(aElement: IInterface; aIndexedPath: String): IInterface;
var
	i, index, startPos: Integer;
	path: TStringList;
begin
	aIndexedPath := StringReplace(aIndexedPath, '/', '\', [rfReplaceAll]);

	path := TStringList.Create;
	path.Delimiter := '\';
	path.StrictDelimiter := true;
	path.DelimitedText := aIndexedPath;

	for i := 0 to Pred(path.count) do begin
		startPos := Pos('[', path[i]);

		if not (startPos > 0) then begin
			aElement := ElementByPath(aElement, path[i]);
			continue;
		end;

		index := StrToInt(MidStr(path[i], startPos+1, Pos(']', path[i])-2));

		aElement := ElementByIndex(aElement, index);
	end;

	Result := aElement;
end;

procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if Key = VK_ESCAPE then
		btnClose.Click
	else if Key = VK_RETURN then
		btnExecute.Click;
end;

procedure btnExecuteClick(Sender: TObject);
begin
	sElementPath := edElementPath.Text;
	sQuerySearch := edQuerySearch.Text;
	sQueryReplace := edQueryReplace.Text;
	sQueryPrefix := edQueryPrefix.Text;
	sQuerySuffix := edQuerySuffix.Text;
	bProperCase := rbProperCase.Checked;
	bSentenceCase := rbSentenceCase.Checked;
	bModify := rbModify.Checked;
	bCaseSensitive := CompareStr(sQuerySearch, LowerCase(sQueryReplace)) <> 0;
end;

procedure rbProperCaseClick(Sender: TObject);
begin
	rbSentenceCase.Checked := False;
	rbModify.Checked := False;

	edQuerySearch.Enabled := False;
	edQueryReplace.Enabled := False;
	edQueryPrefix.Enabled := False;
	edQuerySuffix.Enabled := False;

	lblModifyOptions.Caption := 'Modify Options (disabled)';
end;

procedure rbSentenceCaseClick(Sender: TObject);
begin
	rbProperCase.Checked := False;
	rbModify.Checked := False;

	edQuerySearch.Enabled := False;
	edQueryReplace.Enabled := False;
	edQueryPrefix.Enabled := False;
	edQuerySuffix.Enabled := False;

	lblModifyOptions.Caption := 'Modify Options (disabled)';
end;

procedure rbModifyClick(Sender: TObject);
begin
	rbProperCase.Checked := False;
	rbSentenceCase.Checked := False;

	edQuerySearch.Enabled := True;
	edQueryReplace.Enabled := True;
	edQueryPrefix.Enabled := True;
	edQuerySuffix.Enabled := True;

	lblModifyOptions.Caption := 'Modify Options (enabled)';
end;

procedure ShowSearchForm;
var
	lblElementPath: TLabel;
	lblBatchOperation: TLabel;
	lblQuerySearch: TLabel;
	lblQueryReplace: TLabel;
	lblQueryPrefix: TLabel;
	lblQuerySuffix: TLabel;
	ini: TMemIniFile;
	iniDefaultElementPath: String;
	iniDefaultQuerySearch: String;
	iniDefaultQueryReplace: String;
	iniDefaultQueryPrefix: String;
	iniDefaultQuerySuffix: String;
	iniDefaultProperCase: Boolean;
	iniDefaultSentenceCase: Boolean;
	iniDefaultModify: Boolean;
	scaleFactor: Double;
begin
	ini := TMemIniFile.Create(wbScriptsPath + 'StringOps.ini');
	iniDefaultElementPath := ini.ReadString('Settings', 'ElementPath', 'FULL');
	iniDefaultQuerySearch := ini.ReadString('Settings', 'QuerySearch', '');
	iniDefaultQueryReplace := ini.ReadString('Settings', 'QueryReplace', '');
	iniDefaultQueryPrefix := ini.ReadString('Settings', 'QueryPrefix', '');
	iniDefaultQuerySuffix := ini.ReadString('Settings', 'QuerySuffix', '');
	iniDefaultProperCase := ini.ReadBool('Settings', 'ProperCase', False);
	iniDefaultSentenceCase := ini.ReadBool('Settings', 'SentenceCase', False);
	iniDefaultModify := ini.ReadBool('Settings', 'Modify', True);

	scaleFactor := Screen.PixelsPerInch / 96;

	frmSearch := TForm.Create(nil);

	try
		lblElementPath := TLabel.Create(frmSearch);
		lblQuerySearch := TLabel.Create(frmSearch);
		lblQueryReplace := TLabel.Create(frmSearch);
		lblBatchOperation := TLabel.Create(frmSearch);
		lblModifyOptions := TLabel.Create(frmSearch);
		lblQueryPrefix := TLabel.Create(frmSearch);
		lblQuerySuffix := TLabel.Create(frmSearch);
		edElementPath := TEdit.Create(frmSearch);
		edQuerySearch := TEdit.Create(frmSearch);
		edQueryReplace := TEdit.Create(frmSearch);
		btnExecute := TButton.Create(frmSearch);
		btnClose := TButton.Create(frmSearch);
		rbProperCase := TRadioButton.Create(frmSearch);
		rbSentenceCase := TRadioButton.Create(frmSearch);
		rbModify := TRadioButton.Create(frmSearch);
		edQueryPrefix := TEdit.Create(frmSearch);
		edQuerySuffix := TEdit.Create(frmSearch);

		frmSearch.Name := 'frmSearch';
		frmSearch.BorderStyle := bsDialog;
		frmSearch.Caption := 'StringOps by fireundubh';
		frmSearch.ClientHeight := 284 * scaleFactor;
		frmSearch.ClientWidth := 274 * scaleFactor;
		frmSearch.Color := clBtnFace;
		frmSearch.KeyPreview := True;
		frmSearch.OnKeyDown := FormKeyDown;
		frmSearch.Position := poScreenCenter;

		lblElementPath.Name := 'lblElementPath';
		lblElementPath.Parent := frmSearch;
		lblElementPath.Left := 16 * scaleFactor;
		lblElementPath.Top := 12 * scaleFactor;
		lblElementPath.Width := 63 * scaleFactor;
		lblElementPath.Height := 13 * scaleFactor;
		lblElementPath.Alignment := taRightJustify;
		lblElementPath.Caption := 'Element path';

		lblQuerySearch.Name := 'lblQuerySearch';
		lblQuerySearch.Parent := frmSearch;
		lblQuerySearch.Left := 32 * scaleFactor;
		lblQuerySearch.Top := 124 * scaleFactor;
		lblQuerySearch.Width := 47 * scaleFactor;
		lblQuerySearch.Height := 13 * scaleFactor;
		lblQuerySearch.Alignment := taRightJustify;
		lblQuerySearch.Caption := 'Find what';

		lblQueryReplace.Name := 'lblQueryReplace';
		lblQueryReplace.Parent := frmSearch;
		lblQueryReplace.Left := 18 * scaleFactor;
		lblQueryReplace.Top := 156 * scaleFactor;
		lblQueryReplace.Width := 61 * scaleFactor;
		lblQueryReplace.Height := 13 * scaleFactor;
		lblQueryReplace.Alignment := taRightJustify;
		lblQueryReplace.Caption := 'Replace with';

		lblBatchOperation.Name := 'lblBatchOperation';
		lblBatchOperation.Parent := frmSearch;
		lblBatchOperation.Left := 8 * scaleFactor;
		lblBatchOperation.Top := 40 * scaleFactor;
		lblBatchOperation.Width := 94 * scaleFactor;
		lblBatchOperation.Height := 13 * scaleFactor;
		lblBatchOperation.Caption := 'Select Operation';

		lblModifyOptions.Name := 'lblModifyOptions';
		lblModifyOptions.Parent := frmSearch;
		lblModifyOptions.Left := 8 * scaleFactor;
		lblModifyOptions.Top := 96 * scaleFactor;
		lblModifyOptions.Width := 159 * scaleFactor;
		lblModifyOptions.Height := 13 * scaleFactor;
		lblModifyOptions.Caption := 'Modify Options (enabled)';

		lblQueryPrefix.Name := 'lblQueryPrefix';
		lblQueryPrefix.Parent := frmSearch;
		lblQueryPrefix.Left := 29 * scaleFactor;
		lblQueryPrefix.Top := 187 * scaleFactor;
		lblQueryPrefix.Width := 50 * scaleFactor;
		lblQueryPrefix.Height := 13 * scaleFactor;
		lblQueryPrefix.Alignment := taRightJustify;
		lblQueryPrefix.Caption := 'Add prefix';

		lblQuerySuffix.Name := 'lblQuerySuffix';
		lblQuerySuffix.Parent := frmSearch;
		lblQuerySuffix.Left := 30 * scaleFactor;
		lblQuerySuffix.Top := 220 * scaleFactor;
		lblQuerySuffix.Width := 49 * scaleFactor;
		lblQuerySuffix.Height := 13 * scaleFactor;
		lblQuerySuffix.Alignment := taRightJustify;
		lblQuerySuffix.Caption := 'Add suffix';

		edElementPath.Name := 'edElementPath';
		edElementPath.Parent := frmSearch;
		edElementPath.Left := 85 * scaleFactor;
		edElementPath.Top := 8 * scaleFactor;
		edElementPath.Width := 180 * scaleFactor;
		edElementPath.Height := 21 * scaleFactor;
		edElementPath.TabOrder := 0;
		edElementPath.Text := iniDefaultElementPath;

		rbProperCase.Name := 'rbProperCase';
		rbProperCase.Parent := frmSearch;
		rbProperCase.Left := 8 * scaleFactor;
		rbProperCase.Top := 60 * scaleFactor;
		rbProperCase.Width := 80 * scaleFactor;
		rbProperCase.Height := 17 * scaleFactor;
		rbProperCase.Caption := 'Proper Case';
		rbProperCase.Checked := iniDefaultProperCase;
		rbProperCase.TabOrder := 1;
		rbProperCase.OnClick := rbProperCaseClick;

		rbSentenceCase.Name := 'rbSentenceCase';
		rbSentenceCase.Parent := frmSearch;
		rbSentenceCase.Left := 102 * scaleFactor;
		rbSentenceCase.Top := 60 * scaleFactor;
		rbSentenceCase.Width := 91 * scaleFactor;
		rbSentenceCase.Height := 17 * scaleFactor;
		rbSentenceCase.Caption := 'Sentence Case';
		rbSentenceCase.Checked := iniDefaultSentenceCase;
		rbSentenceCase.TabOrder := 2;
		rbSentenceCase.OnClick := rbSentenceCaseClick;

		rbModify.Name := 'rbModify';
		rbModify.Parent := frmSearch;
		rbModify.Left := 210 * scaleFactor;
		rbModify.Top := 60 * scaleFactor;
		rbModify.Width := 49 * scaleFactor;
		rbModify.Height := 17 * scaleFactor;
		rbModify.Caption := 'Modify';
		rbModify.Checked := iniDefaultModify;
		rbModify.TabOrder := 3;
		rbModify.OnClick := rbModifyClick;

		edQuerySearch.Name := 'edQuerySearch';
		edQuerySearch.Parent := frmSearch;
		edQuerySearch.Left := 85 * scaleFactor;
		edQuerySearch.Top := 120 * scaleFactor;
		edQuerySearch.Width := 180 * scaleFactor;
		edQuerySearch.Height := 21 * scaleFactor;
		edQuerySearch.TabOrder := 4;
		edQuerySearch.Text := iniDefaultQuerySearch;

		edQueryReplace.Name := 'edQueryReplace';
		edQueryReplace.Parent := frmSearch;
		edQueryReplace.Left := 85 * scaleFactor;
		edQueryReplace.Top := 152 * scaleFactor;
		edQueryReplace.Width := 180 * scaleFactor;
		edQueryReplace.Height := 21 * scaleFactor;
		edQueryReplace.TabOrder := 5;
		edQueryReplace.Text := iniDefaultQueryReplace;

		edQueryPrefix.Name := 'edQueryPrefix';
		edQueryPrefix.Parent := frmSearch;
		edQueryPrefix.Left := 85 * scaleFactor;
		edQueryPrefix.Top := 184 * scaleFactor;
		edQueryPrefix.Width := 180 * scaleFactor;
		edQueryPrefix.Height := 21 * scaleFactor;
		edQueryPrefix.TabOrder := 6;
		edQueryPrefix.Text := iniDefaultQueryPrefix;

		edQuerySuffix.Name := 'edQuerySuffix';
		edQuerySuffix.Parent := frmSearch;
		edQuerySuffix.Left := 85 * scaleFactor;
		edQuerySuffix.Top := 216 * scaleFactor;
		edQuerySuffix.Width := 180 * scaleFactor;
		edQuerySuffix.Height := 21 * scaleFactor;
		edQuerySuffix.TabOrder := 7;
		edQuerySuffix.Text := iniDefaultQuerySuffix;

		btnExecute.Name := 'btnExecute';
		btnExecute.Parent := frmSearch;
		btnExecute.Left := 191 * scaleFactor;
		btnExecute.Top := 251 * scaleFactor;
		btnExecute.Width := 75 * scaleFactor;
		btnExecute.Height := 25 * scaleFactor;
		btnExecute.Caption := 'Execute';
		btnExecute.TabOrder := 8;
		btnExecute.OnClick := btnExecuteClick;
		btnExecute.ModalResult := mrOk;

		btnClose.Name := 'btnClose';
		btnClose.Parent := frmSearch;
		btnClose.Left := 110 * scaleFactor;
		btnClose.Top := 252 * scaleFactor;
		btnClose.Width := 75 * scaleFactor;
		btnClose.Height := 25 * scaleFactor;
		btnClose.Caption := 'Close';
		btnClose.TabOrder := 9;
		btnClose.ModalResult := mrCancel;

		frmSearch.ShowModal;
	finally
		ini.WriteString('Settings', 'ElementPath', edElementPath.Text);
		ini.WriteString('Settings', 'QuerySearch', edQuerySearch.Text);
		ini.WriteString('Settings', 'QueryReplace', edQueryReplace.Text);
		ini.WriteString('Settings', 'QueryPrefix', edQueryPrefix.Text);
		ini.WriteString('Settings', 'QuerySuffix', edQuerySuffix.Text);
		ini.WriteBool('Settings', 'ProperCase', rbProperCase.Checked);
		ini.WriteBool('Settings', 'SentenceCase', rbSentenceCase.Checked);
		ini.WriteBool('Settings', 'Modify', rbModify.Checked);

		try
			ini.UpdateFile;
		except
			AddMessage('Cannot save settings, no write access to ' + ini.FileName);
		end;

		ini.Free;
	end;
end;

end.


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



//=====
procedure evtClickBtnAddSuffix(Sender: TObject);
begin
	panelMain.Hide;
	btnAddPrefix.Show;
	btnAppTail.Show;
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
procedure cmbContainerOnChange(Sender: TObject);
begin
	strEl := cmbContainer.Text;
end;


//===========================================================================
{

}
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


//=====
procedure evtClickBtnTrim(Sender: TObject);
begin
	panelMain.Hide;
	btnRemFront.Show;
	btnRemTail.Show;
end;


//===== on key down event handler for form
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if Key = VK_ESCAPE then
		TForm(Sender).ModalResult := mrOk;
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

function Finalize: integer;
begin
	AddMessage(Format('%d records processed.', [processCount]));
end;
end.

//===========================================================================
{
	Always use tabs when indenting, and remember: Only YOU can prevent chaotic text alignment with untold bytes wasted on white space!

	Use Notepad++ and choose your own tab width for personal preference! Standard tab width is four fixed-width spaces. That is the only correct width, and what any civilized person will use.

	I take full (posthumous) responsibility if you blow up the planet using my scripts, but not for more mundane annoyances. I apologize in advance to everyone affected by the world blowing up.

	No lawsuits allowed against me. You've been warned!
}

