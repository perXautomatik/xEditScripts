{

	version 1.0.1

	Automatically duplicates records (STAT, DOOR etc) with incrementation - renames names (EDID, FULL) by adding counter X (or XX or XXX) as suffix.
	Optional: creates COBJ and / or FLST, change model and texture file, replace MODS (Material swap) with MSWP record (if exist) - by one click.

	Hotkey: Ctrl+M
}

unit UserScript;

//uses mteFunctions;
uses mToolFunctions;


	
var
	i,j : integer;

	Start, Number: integer;
	
	SwapTemplate, NameTemplate, elCount, elCountSep, cobjPref, cobjSuff, listPref, copyPref : String;
	
	RenameName, RenameModel, RenameSwap, RenameSource, RenameOnlyEdid, CreateCobj, CreateCnam, CreateSwap, CreateList, ZeroMode, ReplaceMode, ReplacePref : boolean;
	
	formid, formidNew, edid, edidNew, full, fullNew, modl, modlNew, mods, snam, snamNew, cnam, cnamNew : String; 
	
	recToFind : String;
	recFound : Integer;
	
	modFile : IbwFile;
	
	frmMain : TForm;
	Page : TPageControl;
	Tab1, Tab2 : TTabSheet;
	grpData1, grpData2, grpData3, grpData4 : TGroupBox;
	Panel1, Panel2 : TPanel; 
	edtStart, edtCount, edtPref, edtSwap, edtCobjPref, edtCobjSuff, edtFlst : TEdit;
	edtComp: Array [0..50] of TEdit;
	ComboBNAM, ComboFNAM, ComboANAM, ComboYNAM, ComboZNAM : TComboBox;
	ListBNAM, ListFNAM, ListANAM, ListYNAM, ListZNAM, ListCMPO : TStringList;
	chkRenameSource, chkRenameName, chkRenameModel, chkRenameSwap, chkCreateCobj, chkCreateCnam, chkCreateSwap, chkCreateList, chkRenameEdid, chkReplacePref, chkRenameOnlyEdid, chkReplaceMode : TCheckBox;
	SampleSrc, SampleEdid, SampleFlst, SampleCobj, SampleName, InfoCobj, InfoNumber, infoSign : TStaticText;
	btnStart, btnExit: TButton;		
	
	processCount: integer;

	DenyS: TStringList;
	
const

	frmWidth = 860;
	frmWidthExt = 200;
	frmHeight = 440;
	frmHeightExt = 260;
	
	frmLOff = 20; 
	frmTOff = 35;
	frmBOff = 36;
	frmHOff = 160; // edit field from label
	
	frmVPad = 20;
	frmHPad = 20;
	frmFPad = 16;
	
	frmFieldWidth = 200;
	frmComboWidth = 300;
	frmGroupOffset = 540; // next group
	frmBorder = 16;

	frmBtnWidth = 130;
	frmBtnHeight = 30;
	frmBtnCount	= 23;
	
	frmTabHeight = 30;

	

	
function AllowSign (search, signature: string): boolean; // if not on the list (0) then allow to ...

begin

	if Pos(search, DenyS.Values[signature]) = 0 then Result := True else Result := False;

end;


function FormatCount(i: Integer): string; // Check THIS!

begin
	if IntToStr(edtCount.Text) < 100 then 
		Result := edtPref.Text + Format('%.2d', [i])
	else
		Result := edtPref.Text + Format('%.3d', [i]);
end;


procedure changeVis(Sender: TObject);

begin
	if Sender = chkCreateCobj then showCOBJ
	else begin
		
		if Sender = chkCreateList then begin 
			SampleFlst.Visible := not SampleFlst.Visible;
			showFileds (edtFlst, listPref);
			showFileds (edtCobjSuff, cobjSuff);
		end;
		if Sender = chkReplacePref then showFileds (edtFlst, listPref);
		if Sender = chkRenameSwap then begin
			showFileds (edtSwap, '');
			chkCreateSwap.Visible := not chkCreateSwap.Visible;
		end;
		if Sender = chkCreateCnam then begin
			if chkRenameSwap.Checked then showFileds (edtSwap, '');
			chkRenameModel.Visible := not chkRenameModel.Visible;
			chkRenameSwap.Visible := not chkRenameSwap.Visible;
		end;
		if Sender = chkRenameSource then chkRenameOnlyEdid.Visible := not chkRenameOnlyEdid.Visible;
	end;

	changeSample;

end;


procedure changeSample;

begin
	
	SampleEdid.Text := 'new EDID: ' + NameTemplate;
	if (StrToInt(edtCount.Text) > 0) then
		 SampleEdid.Text := SampleEdid.Text + FormatCount(StrToInt(edtStart.Text) + StrToInt(edtCount.Text) - 1)
	else 
		if chkRenameSource.Checked then
			SampleEdid.Text := SampleEdid.Text + FormatCount(0);
	
	SampleFlst.Text := 'new FLST: ' + edtFlst.text + NameTemplate;

	if Assigned(edtCobjPref) then begin
		SampleCobj.Text := 'new COBJ: ' + edtCobjPref.text + NameTemplate;
		if chkCreateList.Checked then
			 SampleCobj.Text := SampleCobj.Text + edtCobjSuff.Text
		else
			if (StrToInt(edtCount.Text) > 0) then 
				SampleCobj.Text := SampleCobj.Text + FormatCount(StrToInt(edtStart.Text) + StrToInt(edtCount.Text) - 1)
			else
				if chkRenameSource.Checked then
					SampleCobj.Text := SampleCobj.Text + FormatCount(0);
	end;	

	if chkReplacePref.Checked then SampleCobj.Text := 'new COBJ: ' + StringReplace (edtCobjPref.text + NameTemplate + FormatCount(StrToInt(edtStart.Text) + StrToInt(edtCount.Text) - 1), edtFlst.Text, '', [rfIgnoreCase]);
	
end;


procedure changeValues;

begin
	checkValuesRange(edtStart, 1, 999);
	checkValuesRange(edtCount, 0, 999);
	changeSample;
end;


procedure showCOBJ; 

begin
	if chkCreateCobj.Checked then
		frmMain.Height := frmHeight + frmHeightExt
	else
		frmMain.Height := frmHeight;

	showFileds(edtCobjPref, cobjPref);
	Tab2.TabVisible := not Tab2.TabVisible;
	Panel2.Visible := not Panel2.Visible;
	SampleCobj.Visible := not SampleCobj.Visible;
end;


procedure ShowForm(signature: string);

var 
	i, column, rows, bLeft, bTop: integer;

begin
	
	frmMain := TForm.Create(nil);
	try
		frmMain.Width := frmWidth;
		frmMain.Height := frmHeight;
		frmMain.Position := poDesigned;
		frmMain.KeyPreview := true;
		frmMain.ShowHint := true;
		frmMain.Caption := 'Multi Increment Tool';
		frmMain.OnKeyDown := KeyAction;
		frmMain.Top := (Screen.Height - frmHeight - frmHeightExt) / 2;
		frmMain.Left := (Screen.Width - frmWidth) / 2;
				
		Page := TPageControl.Create(frmMain);
		Page.Parent := frmMain;
		Page.Align := alTop;
		Page.TabHeight := frmTabHeight;
		//Page.Width := frmWidth;
		Page.Height := frmHeight - frmTabHeight - frmBtnHeight - 2*frmBorder - 8;

		Tab1 := CreateTab(Page, 'MAIN OPTION');
		Tab2 := CreateTab(Page, 'FVPA Components');
		Tab2.TabVisible := False;
		
		Panel2 := CreatePanel(frmBorder + 4, Page.Height + frmBorder, frmWidth - 2*frmBorder, frmHeightExt - frmBorder, frmMain, frmMain,''); // Panel for COBJ;
		Panel2.Visible := False;
			
		
	// TAB1
	
		grpData1 := CreateGroup(frmBorder, frmBorder, frmGroupOffset - 2*frmBorder, Page.Height - 2*frmBorder - frmTabHeight - 10, frmMain, Tab1, '   DATA INPUT   ');

		
			CreateLabel(frmLOff, frmTOff, frmMain, grpData1, 'Start from:');

			edtStart := CreateInputVal(frmLOff + 190, frmTOff - 4, 24, frmBtnCount, frmMain, grpData1, Start, 151);
			edtStart.OnChange := changeValues;
			edtStart.hint := 'You can use bigger value, e.g start from 10, 100, etc.';
	
			CreateLabel(frmLOff, frmTOff + frmFPad*2, frmMain, grpData1, 'Number of new records*:');

			edtCount := CreateInputVal(frmLOff + 190, frmTOff + frmFPad*2 - 4, 24, frmBtnCount, frmMain, grpData1, Number, 152);
			edtCount.OnChange := changeValues;
			edtCount.hint := 'Maks value is 999. If you leave "0", the record source doesn''t change and there will be no incrementing,'#13'but creates an constructible object (COBJ) or/and FormID list (FLST) with one element (if option checked).';
		
			frmMain.ActiveControl := edtCount;
			
			CreateLabel(frmLOff, frmTOff + frmFPad*4, frmMain, grpData1, 'Counter separator:');

			edtPref := CreateInput(frmLOff + 190, frmTOff + frmFPad*4 - 4, 24, frmMain, grpData1);
			edtPref.Text := elCountSep;
			edtPref.OnChange := changeSample;
			edtPref.Alignment := taCenter;
			edtPref.hint := 'Connector between the name (EDID, file name, etc.) and the counter (e.g. "_" will result "RecordName_01").'#13'Don''t works with FULL (inserts a space).';
		
			edtFlst := CreateInputLabel(frmLOff, frmTOff + frmFPad*5 + frmVPad, frmFieldWidth, frmHOff, frmMain, grpData1, 'FLST (FormID) EDID prefix:', 2);
			edtFlst.OnChange := changeSample;
	
			edtSwap := CreateInputLabel(frmLOff, frmTOff + frmFPad*7 + frmVPad, frmFieldWidth, frmHOff, frmMain, grpData1, 'Material Swap template:', 1);
			edtSwap.hint := 'Name of source record MSWP (Material Swap) for Model/MODS replacement (e.g. MyNewMaterialSwap). Use this if MSWP records are created already or creating option below is checked.".'#13'If you leave this field blank, the script will try to find itself a new record to swap, if the element MODS is present in the source record.';

			chkCreateSwap := CreateCheckBox(frmLOff + frmHOff, frmTOff + frmVPad*8, frmFieldWidth, frmMain, grpData1, CreateSwap, ' create MSWP records');
			chkCreateSwap.hint := 'Creates new MSWP records from the element MODS if present. You can use "Swap template" if new EditorID are needed.';
			chkCreateSwap.Visible := False;
	
			InfoNumber := CreateStaticText (frmLOff, frmTOff + frmVPad*10 + 10, frmMain, grpData1, '*leave "0" to create constructible object/list (if option checked) without source changes.');
			InfoNumber.Font.Size := 7;
			//InfoNumber.Font.Color := clGray;
			

		grpData2 := CreateGroup(frmGroupOffset, frmBorder, Tab1.Width - frmGroupOffset - frmBorder, Page.Height - 2*frmBorder - frmTabHeight - 10, frmMain, Tab1, '   OPTIONS   ');

			
			CreateLabel(frmLOff, frmTOff - 4, frmMain, grpData2, 'Elements to apply the change:');

			chkRenameEdid := CreateCheckBox(frmLOff, frmTOff + frmVPad*1, grpData2.Width - 2*frmLOff, frmMain, grpData2, True, ' EDID - EditorID (default)');
			chkRenameEdid.State := cbGrayed;
			chkRenameEdid.Enabled := False;
			
			chkRenameName := CreateCheckBox(frmLOff, frmTOff + frmVPad*2, grpData2.Width - 2*frmLOff, frmMain, grpData2, RenameName, ' FULL - Name');

			chkRenameModel := CreateCheckBox(frmLOff, frmTOff + frmVPad*3, grpData2.Width - 2*frmLOff, frmMain, grpData2, RenameModel, ' Model\MODL - M&odel Filename or SNAM'); // Material Substitutions\Substitution\SNAM
			chkRenameModel.hint := 'Renames .nif extension in "Model\MODL - Model Filename" by adding counter at the end (e.g FileName.nif to FileName01.nif).'#13'For Material Substitutions (SNAM) by addind counter at the end (e.g FileName.bgsm to FileName01.bgsm).';

			chkRenameSwap := CreateCheckBox(frmLOff, frmTOff + frmVPad*4, grpData2.Width - 2*frmLOff, frmMain, grpData2, RenameSwap, ' Model\MODS - M&aterial Swap');  
			chkRenameSwap.hint := 'Replaces material if exists on MSWP group records (e.g. MyMaterialSwap to MyMaterialSwap01) in "Model\MODS - Material Swap.'#13'You need to create this records in MSWP first before use this option or use "create SWAP" checkbox when it appear in SWAP option.';
			chkRenameSwap.OnClick := changeVis;
			
			chkCreateList := CreateCheckBox(frmLOff, frmTOff + frmVPad*5 + 9, grpData2.Width - 2*frmLOff, frmMain, grpData2, CreateList, 'create &FLST (recipe list)');
			chkCreateList.hint := 'Creates Recipe and adds new counted records to FormID list (FLST).'#13'If "create COBJ" is checked, adds this list as CNAM element to this new COBJ record.'#13'If COBJ for source record exist - replace old CNAM with new FLST list.';
			chkCreateList.OnClick := changeVis;

			chkCreateCobj := CreateCheckBox(frmLOff, frmTOff + frmVPad*6 + 9, grpData2.Width - 2*frmLOff, frmMain, grpData2, CreateCobj, 'create &COBJ (constructible object/s)');
			chkCreateCobj.hint := 'If COBJ for source record exists, then all elements are copying to new increment records, such as: '#13'components (FVPA), YNAM, ZNAM, BNAM, FNAM (Category), but can are replaced if new values are given from this form.'#13'If "create FLST" is checked, creates one COBJ record (if it doesn''t exist already) for all new increment records and apply recipe as CNAM record.'#13'If not checked, creates COBJ record for any new increment record.';
			chkCreateCobj.OnClick := changeVis;

			chkCreateCnam := CreateCheckBox(frmLOff, frmTOff + frmVPad*6 + 9, grpData2.Width - 2*frmLOff, frmMain, grpData2, CreateCnam, 'create new records from CNAM');
			chkCreateCnam.hint := 'Founds record from CNAM element and creates new incremental records for it (e.g. new STAT or FLST),'#13'for each new COBJ record, if it doesn''t exist. Also with elements "Model" change (if option checked).';
			chkCreateCnam.Visible := False;
			chkCreateCnam.OnClick := changeVis;

			chkReplaceMode := CreateCheckBox(frmLOff, frmTOff + frmVPad*8, grpData2.Width - 2*frmLOff, frmMain, grpData2, ReplaceMode, ' replace if new incremental record exists');
			chkReplaceMode.hint := 'If checked, replaces all values in record if exists already, also Form ID lists in FLST records.'#13'If not, old records are renamed, and new itmes are added to an existing Form ID lists.';
	
			chkRenameSource := CreateCheckBox(frmLOff, frmTOff + frmVPad*9, grpData2.Width - 2*frmLOff, frmMain, grpData2, RenameSource, ' add "&0" counter to source record');
			chkRenameSource.hint := 'Renames source record by adding 0 (or 00 or 000) as suffix.';
			chkRenameSource.OnClick := changeVis;
	
			chkRenameOnlyEdid := CreateCheckBox(frmLOff, frmTOff + frmVPad*10, grpData2.Width - 2*frmLOff, frmMain, grpData2, RenameOnlyEdid, ' "0" only for EDID and FULL');
			chkRenameOnlyEdid.hint := 'Disables other elements to change as Model or Material Swap for "0" counter.';
			chkRenameOnlyEdid.Visible := False;
	

	// COBJ GROUP
	
		grpData3 := CreateGroup(0, 0, frmGroupOffset - 2*frmBorder, frmHeightExt - frmBorder, frmMain, Panel2, '  Constructible object parameters  ');

			edtCobjPref := CreateInputLabel(frmLOff, frmTOff, frmFieldWidth, frmHOff, frmMain, grpData3, 'COBJ prefix:', 3);
			edtCobjPref.Text := cobjPref;
			edtCobjPref.OnChange := changeSample;
			
			edtCobjSuff := CreateInputLabel(frmLOff + frmFieldWidth + frmHOff + 15, frmTOff, 45, 40, frmMain, grpData3, 'suffix:', 4);
			edtCobjSuff.Text := cobjSuff;
			edtCobjSuff.OnChange := changeSample;
			
			ComboBNAM := CreateComboBoxLabel(frmLOff, edtCobjPref.Top + 2*frmFPad + 3, frmComboWidth, frmHOff, frmMain, grpData3, 'BNAM - Workbench KYWD:', ListBNAM.Text, 11);
			ComboFNAM := CreateComboBoxLabel(frmLOff, ComboBNAM.Top + 2*frmFPad, frmComboWidth, frmHOff, frmMain, grpData3, 'FNAM - Category:', ListFNAM.Text, 12);
			ComboANAM := CreateComboBoxLabel(frmLOff, ComboFNAM.Top + 2*frmFPad, frmComboWidth, frmHOff, frmMain, grpData3, 'ANAM - Menu Art:', ListANAM.Text, 13);
			ComboYNAM := CreateComboBoxLabel(frmLOff, ComboANAM.Top + 2*frmFPad, frmComboWidth, frmHOff, frmMain, grpData3, 'YNAM - Pick Up Sound:', ListYNAM.Text, 14);
			ComboZNAM := CreateComboBoxLabel(frmLOff, ComboYNAM.Top + 2*frmFPad, frmComboWidth, frmHOff, frmMain, grpData3, 'ZNAM - Put Down Sound:', ListZNAM.Text, 15);

			infoCobj := CreateStaticText(frmGroupOffset, frmTOff - frmFPad, frmMain, Panel2, 'If you want to create component elements (FVPA) for COBJ record, go to the "FVPA Components" tab.'); 
			infoCobj.Width := grpData2.Width - 2*frmLOff;
			infoCobj.Height := 60;

			infoSign := CreateStaticText(frmGroupOffset, frmTOff - frmFPad, frmMain, frmMain, 'Selected record signature is ' + signature); 
			infoSign.Left := frmMain.Width - 210;
			infoSign.Top := 11;
			infoSign.Alignment := taRightJustify;


	// TAB2 - CMPO / FVPA (components from resources) 
  
		grpData4 := CreateGroup(frmBorder, frmBorder, Tab2.Width - 2*frmBorder, Page.Height - 2*frmBorder - frmTabHeight - 10, frmMain, Tab2, '   COMPONENTS   ');  // ALCH? MISC?

			rows: = 8;
			column: = 1;
					
			for i := 1 to ListCMPO.Count do begin
				
				bLeft := frmLOff + (column - 1) * 192;
				bTop := frmTOff + (i - rows*(column-1) - 1) * (frmFPad - 2) * 2 -6;
				
				CreateLabel(bLeft + 90, bTop + 4, frmMain, grpData4, ListCMPO[i-1]);
				edtComp[i] := CreateInputVal(bLeft + 30, bTop, 24, frmBtnCount, frmMain, grpData4, 0, i + 100);
				
				if rows * column / i = 1  then Inc(column);
		
			end;

	
	// TAB3 - CMPO / FVPA (componenets form alch / misc /etc) -> TO DO?
 		
		
	// BOTTOM PANEL
	
		Panel1 := CreatePanel(0, 0, 0, frmBtnHeight + 2*frmBorder, frmMain, frmMain, 'bottom');
		
			SampleEdid := CreateStaticText(frmLOff + 2, 14, frmMain, Panel1, 'source: ' + NameTemplate); 
			SampleEdid.Font.Size := 7;
			SampleFlst := CreateStaticText(frmLOff + 2, frmFPad + 10, frmMain, Panel1, NameTemplate); 
			SampleFlst.Font.Size := 7;
			SampleFlst.Visible := False;
			SampleCobj := CreateStaticText(frmLOff + 2, frmFPad*2 + 6, frmMain, Panel1, NameTemplate); 	
			SampleCobj.Font.Size := 7;
			SampleCobj.Visible := False;
			
			btnStart := CreateButton(Panel1.Width - frmBorder*2 - frmBtnWidth*2 - 4, frmBorder, frmBtnWidth, frmBtnHeight, frmMain, Panel1, '&Start');
			btnExit := CreateButton(Panel1.Width - frmBorder - frmBtnWidth - 4, frmBorder, frmBtnWidth, frmBtnHeight, frmMain, Panel1, 'E&xit without changes');
			btnStart.ModalResult := mrOk;
			btnExit.ModalResult := mrCancel;


	// OTHER

		chkReplacePref := CreateCheckBox(frmGroupOffset, infoCobj.Height + frmFPad*2, grpData2.Width - 2*frmLOff, frmMain, Panel2, false, ' replace EditorID prefix from FLST');
		chkReplacePref.hint := 'Replace prefix from source record EditorID to COBJ prefix';
		chkReplacePref.OnClick := changeVis;
		chkReplacePref.Visible := False;
		
		if signature = 'FLST' then begin
			chkCreateList.Visible := False;
			chkReplacePref.Visible := True;
			chkRenameSwap.Visible := False;
			chkRenameModel.Visible := False;
		end;
		
		if signature = 'KYWD' then begin
			chkCreateList.Visible := False;
			chkCreateCobj.Visible := False;
			chkRenameSwap.Visible := False;
			chkRenameModel.Visible := False;
		end;
		
		if signature = 'COBJ' then begin
			chkRenameName.Visible := False;
			chkCreateList.Visible := False;
			chkCreateCobj.Visible := False;
			chkRenameModel.Visible := False;
			chkRenameSwap.Visible := False;
			chkRenameModel.hint := 'Option for "creates new record from CNAM" checked. Replaces "MODL - Model FileName" for created records.';
			chkRenameSwap.hint := 'Option for "creates new record from CNAM" checked. Replaces "MODS - Material Swap" for created records.';
			chkCreateCnam.Visible := True;
		end;
		
		if signature = 'MSWP' then begin
			chkCreateList.Visible := False;
			chkCreateCobj.Visible := False;
			chkRenameName.Visible := False;
			chkRenameSwap.Visible := False;
		end;
			
		
		showFileds (edtSwap, '');
		showFileds (edtFlst, listPref);
		showFileds (edtCobjSuff, cobjSuff);
		showFileds (edtCobjPref, cobjPref);
		
		changeSample;
		
		frmMain.ShowModal;
				
	finally
		
	end;
	
		
end;


function Initialize: integer;
begin

	ClearMessages();
	AddMessage(#13);

// CONFIG
	
	Start := 1;
	Number := 0;
	SwapTemplate := ''; 
	cobjPref := 'workshop_co_';
	cobjSuff := '_FLST';
	listPref := 'workshopRecipe_';
	elCountSep := ''; 

	NameTemplate := 'MySourceFile';

	RenameName := True;
	RenameModel := False;
	RenameSwap := False;
	RenameSource := False; //changes to 00 + adds to FLST
	RenameOnlyEdid := False; // if Model / Swap = true then disable changes for 00 -> TO DO

	CreateCobj := False;
	CreateList := False;
	CreateCnam := False;
	CreateSwap := False;

	ReplaceMode := True;
	copyPref := 'mt_bak_';

	DenyS := TStringList.Create; // which records type (contained signatures in string lists below) are allowed to creating new record in signature group ['XXXX']
	
	DenyS.Values['COBJ']:= 'COBJ,KYWD';  	// a new record in the COBJ group can't be created from records with this signatures
	DenyS.Values['FLST']:= 'COBJ,KYWD,FLST'; 			
	
	// like STAT - check cobj i flst // ADDN / ALCH (ingestible) / AMMO / ANIO / ARTO / FLOR / KEYM / MISC / MSTT 
	
// CONFIG END

	processCount := 0;
	
end;


procedure SetNewValues(newRec: IInterface);

var el: IInterface;

begin

	SetEditorID(newRec, edidNew);

	if RenameName then begin
		SetElementEditValues(newRec, 'NAME', fullNew);		
	end;
	
//	if RenameModel or (RenameSource and not RenameOnlyEdid) then begin
	if RenameModel then begin
		snam := GetEditValue(ElementByPath(newRec, 'Material Substitutions\Substitution\SNAM')); // MSWP or sound (DOOR)
		modl := GetEditValue(ElementByPath(newRec, 'Model\MODL - Model Filename')); // some
		modlNew := StringReplaceLast(modl, '.nif', elCount + '.nif');
		snamNew := StringReplaceLast(snam, '.bgsm', elCount + '.bgsm');
		SetElementEditValues(newRec, 'Model\MODL - Model Filename', modlNew);		
		SetElementEditValues(newRec, 'Material Substitutions\Substitution\SNAM', snamNew);		
	end;
	
//	if RenameSwap or (RenameSource and not RenameOnlyEdid) then begin
	if RenameSwap then begin
			
		if SwapTemplate = '' then
			recToFind := EditorID(LinksTo(ElementByPath(newRec, 'Model\MODS - Material Swap'))) + elCount 
		else
			recToFind := SwapTemplate + elCount;
		
		recFound := findRecord(modFile, recToFind, 'MSWP');

		if (recFound = 0) and ElementExists(newRec, 'Model\MODS - Material Swap') and CreateSwap then begin  // TO DO - check for 00 rename?
			el := wbCopyElementToFile(LinksTo(ElementByPath(newRec, 'Model\MODS - Material Swap')), modFile, True, True);
			SetEditorID(el, recToFind);
			SetElementEditValues(el, 'Material Substitutions\Substitution\SNAM', StringReplaceLast(GetEditValue(ElementByPath(el, 'Material Substitutions\Substitution\SNAM')), '.bgsm', elCount + '.bgsm'));		
			recFound := FixedFormID(el);
		end;
		
		if recFound <> 0 then begin
			if not Assigned(ElementByPath(newRec, 'Model\MODS - Material Swap')) then ElementAssign(ElementByPath(newRec, 'MODEL'), 3, Nil, false);
			SetElementNativeValues(newRec, 'Model\MODS - Material Swap', recFound);
		end;

	end;

end;


function Process(e: IInterface): integer;
var
	newRec, newListElm, newList, newCobj, el: IInterface;
	cobjEdid: string;
		
begin
	
	//ShowValues (e);	

	if GetEditValue(e) = '' then begin
		alert ('No record selected');
		Exit;
		end;
	
	modFile := GetFile(e);
	
	if 	processCount = 0 then begin
	
		NameTemplate := GetEditValue(ElementBySignature(e, 'EDID'));
			
		ListBNAM := TStringList.Create;
		ListBNAM.Sorted := True;
		ListBNAM := loadRecords (FileByLoadOrder(0), 'KYWD', 'WorkshopWorkbench');

		ListFNAM := TStringList.Create;
		ListFNAM := loadRecords (modFile, 'KYWD', '');

		ListANAM := TStringList.Create;
		ListANAM := loadRecords (modFile, 'ARTO', '');

		ListYNAM := TStringList.Create;
		ListYNAM := loadRecords (FileByLoadOrder(0), 'SNDR', 'PickUp');

		ListZNAM := TStringList.Create;
		ListZNAM := loadRecords (FileByLoadOrder(0), 'SNDR', 'PutDown');

		ListCMPO := TStringList.Create;
		ListCMPO := loadNames (FileByLoadOrder(0), 'CMPO', '');

		ShowForm(Signature(e));
		
	end;

	Inc (processCount);

	Start := StrToInt(edtStart.Text);
	Number := StrToInt(edtCount.Text);
	SwapTemplate := edtSwap.Text; 
	cobjPref := edtCobjPref.Text;
	cobjSuff : = edtCobjSuff.Text;
	listPref := edtFlst.Text;
	elCountSep := edtPref.Text; 
	
	CreateCobj := chkCreateCobj.Checked;
	CreateList := chkCreateList.Checked;
	CreateCnam := chkCreateCnam.Checked;
	CreateSwap := chkCreateSwap.Checked;
	
	if Number = 0 then begin
		ZeroMode := True;
		Start := 1;
		Number := 1; 
		RenameName := False;
	end
	else
		begin
		ZeroMode := False;
		RenameName := chkRenameName.Checked;
		RenameModel := chkRenameModel.Checked;
		RenameSwap := chkRenameSwap.Checked;
		RenameSource := chkRenameSource.Checked; 
		RenameOnlyEdid := chkRenameOnlyEdid.Checked;
		ReplaceMode := chkReplaceMode.Checked;
	end;

	
	if frmMain.ModalResult = mrOk then begin

		if (Start > 0) and (Start + Number < 1000) then begin 

			formid := GetEditValue(e); // all
			edid := EditorID(e); // all
			full := DisplayName(e);  // some

			AddMessage('Source:   ' + formid + '   ' + edid + '   ' + BaseName(e));
			AddMessage(#13);
	
		// FLST part 1 (create)

			if CreateList then
				if AllowSign(Signature(e),'FLST') then begin
			
					if not Assigned(GroupBySignature(modFile, 'FLST')) then Add(modFile, 'FLST', true);   
				
					recFound := findRecord(modFile, listPref + edid, 'FLST');
				
					if recFound = 0 then
						newList := Add(GroupBySignature(modFile, 'FLST'), 'FLST', True)
					else
						if ReplaceMode then begin
							Remove(RecordByFormID(modFile, recFound, True));
							newList := Add(GroupBySignature(modFile, 'FLST'), 'FLST', True);
							SetLoadOrderFormID(newList, recFound);
						end
						else begin
							newList := wbCopyElementToFile(RecordByFormID(modFile, recFound, True), modFile, True, True);
							SetEditorID(RecordByFormID(modFile, recFound, True), 'mt_bak_' + listPref + edid); // what if cobj exists before this? //
						end;
							
					SetEditorID(newList, listPref + edid);
					SetElementEditValues(newList, 'FULL', full);
				end
				else
					AddMessage ('Selected record is on the deny list for this signature: ' + DenyS.Values['FLST'] + ' - FormID list (FLST) not created');

		// FLST part 1 END

		
			if RenameSource then Inc(Number); // one count more for 0

			for i := Start to Pred(Number+Start) do begin

		// CREATING NEW RECORD
			
				if not (ZeroMode) then begin
					
					if (RenameSource) and (i = Pred(Number+Start)) then
						elCount := FormatCount(0)
					else
						elCount := FormatCount(i);

					edidNew := edid + elCount;
					fullNew := full + ' ' + StringReplaceLast(elCount, elCountSep, '');

					recFound := findRecord(modFile, edidNew, Signature(e));
						
					if recFound <> 0 then 
						if ReplaceMode then begin
							Remove(RecordByFormID(modFile, recFound, True));
						end
						else
							SetEditorID(RecordByFormID(modFile, recFound, True), 'mt_bak_' + edidNew);
							
					if (RenameSource) and (i = Pred(Number+Start)) then
						newRec := e
					else begin
						newRec := wbCopyElementToFile(e, modFile, True, True);
						if (recFound <> 0) and ReplaceMode then SetLoadOrderFormID(newRec, recFound);
					end;

					SetNewValues(newRec);
			
					if Sign(e,'COBJ') and ElementExists(e, 'CNAM') then begin // CNAM for COBJ	
		
						recToFind := EditorID(LinksTo(ElementByPath(e, 'CNAM'))) + elCount; 
						recFound := findRecord(modFile, recToFind, Signature(LinksTo(ElementByPath(e, 'CNAM'))));
						
						if (recFound = 0) and CreateCnam then begin
							el := wbCopyElementToFile(LinksTo(ElementByPath(e, 'CNAM')), modFile, True, True);
							edidNew := recToFind;
							fullNew := DisplayName(el) + ' ' + StringReplaceLast(elCount, elCountSep, '');
							SetNewValues(el);
							recFound := FixedFormID(el);
							end;
				
						SetElementNativeValues(newRec, 'CNAM', recFound);
					end;	
					
				
				end
				else begin
					newRec := e;
				end;
		
		// CREATING NEW RECORD END

		// FLST part 2 (new records adding to FLST)
		
				if (CreateList not AllowSign(Signature(e),'FLST')) then CreateList := False;
				
				if CreateList then begin
		
					newListElm := ElementByPath(newList, 'FormIDs'); 

					if not Assigned(newListElm) then begin 
						newListElm := Add(newList, 'FormIDs', true);

//						if (RenameSource) and (i = Start) then	begin
//						SetEditValue (ElementByPath(newList, 'FormIDs\LNAM'), formid); 
//							SetEditValue (ElementAssign(newListElm, HighInteger, nil, false), GetEditValue(newRec));
//						end
//						else

						SetEditValue (ElementByPath(newList, 'FormIDs\LNAM'), GetEditValue(newRec));
					
					end
					else 
						if not (RenameSource and (i = Pred(Number+Start))) then // if not exists TO DO (?) //
							SetEditValue (ElementAssign(newListElm, HighInteger, nil, false), GetEditValue(newRec))
						else begin
							ReverseElements (newListElm);		
							SetEditValue (ElementAssign(newListElm, HighInteger, nil, false), formid);
							ReverseElements (newListElm);		
						end;

				end; 


		// FLST part 2 END

		// COBJ
				if CreateCobj then
					if AllowSign(Signature(e),'COBJ') then begin
						if (CreateList and (i=Start)) or (not CreateList) then begin

							if not Assigned(GroupBySignature(modFile, 'COBJ')) then Add(modFile, 'COBJ', true);
													
							if CreateList then 
								cobjEdid := cobjPref + edid + cobjSuff
							else
								cobjEdid := cobjPref + edid;

							recFound := findRecord(modFile, cobjEdid, 'COBJ');

							if recFound = 0 then 
								newCobj := Add(GroupBySignature(modFile, 'COBJ'), 'COBJ', True)
							else begin
								if (RenameSource and (i = Pred(Number+Start)) or CreateList) then
									newCobj := RecordByFormID(modFile,recFound,true)
								else 
									if ReplaceMode then begin
										Remove(RecordByFormID(modFile, recFound, True));
										newCobj := Add(GroupBySignature(modFile, 'COBJ'), 'COBJ', True);
										SetLoadOrderFormID(newCobj, recFound);
									end
									else				
									begin
										newCobj := wbCopyElementToFile(RecordByFormID(modFile,recFound,false), modFile, True, True);
										SetEditorID(RecordByFormID(modFile, recFound, True), 'mt_bak_' + cobjEdid);									
									end;
							end;
							
							if Sign(e,'FLST') then edidNew := StringReplace(edid, listPref , '', [rfIgnoreCase]) else edidNew := edid;
							
							if CreateList then begin
								SetElementEditValues(newCobj, 'EDID', cobjPref + edidNew + cobjSuff);
								SetElementNativeValues(newCobj, 'CNAM', FixedFormID(newList));  
							end
							else begin
								SetElementEditValues(newCobj, 'EDID', cobjPref + edidNew + elCount);
								SetElementNativeValues(newCobj, 'CNAM', FixedFormID(newRec));
							end;
							
							if ComboBNAM.ItemIndex <> -1 then SetElementEditValues(newCobj, 'BNAM', ListBNAM[ComboBNAM.ItemIndex]);
							if ComboFNAM.ItemIndex <> -1 then begin
								if not Assigned(ElementBySignature(newCobj, 'FNAM')) then Add(newCObj, 'FNAM', true);
								SetElementEditValues(newCobj, 'FNAM\Keyword', ListFNAM[ComboFNAM.ItemIndex]);
							end;
							if ComboANAM.ItemIndex <> -1 then SetElementEditValues(newCobj, 'ANAM', ListANAM[ComboANAM.ItemIndex]);
							if ComboYNAM.ItemIndex <> -1 then SetElementEditValues(newCobj, 'YNAM', ListYNAM[ComboYNAM.ItemIndex]);
							if ComboZNAM.ItemIndex <> -1 then SetElementEditValues(newCobj, 'ZNAM', ListZNAM[ComboZNAM.ItemIndex]);

							if not Assigned(ElementBySignature(newCobj, 'INTV')) then Add(newCObj, 'INTV', true);
							SetElementEditValues(newCobj, 'INTV\Created Object Count', '1');

					// Components
							
							if ListCMPO.Count > 0 then begin 
							
								if Assigned(ElementByPath(newCobj, 'FVPA')) then RemoveElement(newCobj,'FVPA');
								
								for j:=1 to ListCMPO.Count do 
									if StrToInt (edtComp[j].Text) > 0 then begin
										recFound := findRecordByValue(FileByLoadOrder(0), ListCMPO[j-1], 'CMPO', 'FULL');
										if not Assigned(ElementByPath(newCobj, 'FVPA')) then begin	
											Add(newCobj, 'FVPA', true);
											el := ElementByPath(newCObj, 'FVPA\Component');
										end
										else begin
											el := ElementAssign(ElementByPath(newCobj, 'FVPA'), HighInteger, nil, false);
										end;
										SetElementNativeValues(el, 'Component', recFound);
										SetElementEditValues(el, 'Count', StrToInt(edtComp[j].Text));
									end;
							
							end;
					
					// Component end
					
						end;
					end
					else
						AddMessage ('Selected record is on the deny list for this signature:  ' + DenyS.Values['COBJ'] + ' - constructible object (COBJ) not created');
					
		// COBJ END

		// LOG
		
				if not ZeroMode then AddMessage('New record created:   ' + edid + elCount + '     ' + full + ' ' + StringReplaceLast(elCount, elCountSep, ''));	
				if CreateList and AllowSign(Signature(e),'FLST') then 
					if processCount = 0 then AddMessage('New FLST / FormID list record:   ' + listPref + edid);
				if CreateCobj and AllowSign(Signature(e),'COBJ') then
					if not CreateList then 
						AddMessage('New COBJ record:   ' + cobjPref + edid + elCount)
					else
						if processCount = 0 then AddMessage('New COBJ record:   ' + cobjPref + edid + cobjSuff);
					
				AddMessage(#13);
					
			end;

			AddMessage('-------------------------------------------------------------------------------');
			AddMessage(#13);

		end
		else
			AddMessage('The value (last record number) must be max 999, now is ' + IntToStr(Start + Number));
			
	end
	else begin

		AddMessage('Exit without changes...');
		Exit;

	end;
	
end;

function Finalize: integer;
begin
	
	frmMain.Free;

	AddMessage('End processing data. Records count: ' + IntToStr(processCount));
	
end;

end.
