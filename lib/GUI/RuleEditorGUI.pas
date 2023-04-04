{
	M8r98a4f2s Complex Item Sorter for FallUI - RuleEditorGUI module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Part of the GUI.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit RuleEditorGUI;
 	
const
	windowPadding = 25;
	WINFORM_WIDTH = 1345;
	WINFORM_HEIGHT = 800;
	COL1_WIDTH = 70;
	COL1b_WIDTH = 20;
	COL2_WIDTH = 30;
	COL3_WIDTH = 200; // Field
	COL4_WIDTH = 100;
	COL5_WIDTH = 200; // Value
	COL5b_WIDTH = 80; // Condition actions
	COL6_WIDTH = 170;
	COL7_WIDTH = 80; // Rule actions
	COLS_SPACING = 10;
	COLS_PADDING_SIDES = 10;
	
	STYLE_RULES_PADDLEFT = 20;
	TEXT_RULE_PREFIX = 'Rule ';

	// Colors
	SELECTION_BG_COLOR = clMenuHighlight;//$FF6666;
	SELECTION_FG_COLOR = clMenuText;//$FFFFFF;
	CELL_HIGHLIGHT_COLOR = $FFCCCC;
	TABLE_ALT_ROW_BG_COLOR1 = $E5E5E5;
	TABLE_ALT_ROW_BG_COLOR2 = $DDDDDD;
	TABLE_HOVER_ROW_BG_COLOR = $CCCCCC;
	TABLE_HEADER_BG_COLOR = $BBBBBB;
	TABLE_HEADER_FG_COLOR = clGray;
	RULES_HEADLINE_FG_TEXT = $333333;
	RULES_HEADLINE_BG_MAIN_EXIST = $FFCC44; //$CCCCCC
	RULES_HEADLINE_BG_MAIN_NOT_EXIST = $E8E8E8;
	RULES_HEADLINE_BG_USER = $11AA11;
	RULES_HEADLINE_BG_PREORNOT = $33AABB;
	

var
	frm2: TForm;

	// View options
	flagShowEmptyRules: Boolean;
	flagShowHelp: Boolean;
	lFoldedSections: TStringList;
	
	colsWidth: Integer;
	
	// Form elms
	tMainContent, tNaviMain, tNaviLeft: TScrollBox;
	columnHeader, rulesListOptionsPanel: TPanel;
	lastMarkedDragTarget,tabsRecordHeader: TLabel;
	saveButton, reloadButton, closeButton: TButton;

	// Current content location
	sNavCurrentMain,
	sNavCurrentSub,
	sNavCurrentRecordType: String;
	
	// Misc
	explEditElmsList: TStringList;
	lastTLabelPrevColor: Integer;
	lastBGTLabelPrevElm: TComponent;
	lastBGTLabelPrevColor: Integer;
	
implementation

procedure showRuleEditor(viewRulesetFullQualName:String);
var
	tmpLst: TStringList;	
begin
	try
	// Setup theme things	
	if getSettingsBoolean('config.bUseDarkTheme') then begin 
		// Pascal allows changing constants ... strange but okay...!
		//RULES_HEADLINE_FG_TEXT := $010203; // seems unchangable?!
		RULES_HEADLINE_BG_USER := $006600;
		RULES_HEADLINE_BG_MAIN_EXIST := $883333;
		RULES_HEADLINE_BG_PREORNOT := $336688;
		TABLE_ALT_ROW_BG_COLOR1 := $383838;
		TABLE_ALT_ROW_BG_COLOR2 := $444444;
		TABLE_HOVER_ROW_BG_COLOR := $555555;
		TABLE_HEADER_BG_COLOR := $555555;
		CELL_HIGHLIGHT_COLOR := $886666
		end;
	
	// Setup
	readTags();
	CustomRuleSets.init();
	sNavCurrentMain := 'By record type';
	sNavCurrentSub := '';
	
	// Start set
	sNavCurrentRecordType := 'ALCH';
	if viewRulesetFullQualName <> '' then begin
		tmpLst := Split('>',viewRulesetFullQualName);
		if tmpLst.Count = 2 then begin
			sNavCurrentRecordType := '';
			sNavCurrentMain := tmpLst[0];
			sNavCurrentSub := tmpLst[1];
			if ( sNavCurrentMain <> '' ) and ( sNavCurrentSub = '' ) then
				if ( customProcRuleSets.indexOf(sNavCurrentMain) > -1 ) then
					if customProcRuleSets.Objects[customProcRuleSets.indexOf(sNavCurrentMain)].Count > 0 then
						sNavCurrentSub := customProcRuleSets.Objects[customProcRuleSets.indexOf(sNavCurrentMain)].Strings[0];
			end;
		tmpLst.Free;
		end;

	// Build main layout
	_buildMainLayout();
	
	finally
		
	end;
end;


{Builds the main layout of Rule Editor}
procedure _buildMainLayout();
var
	tlab: TLabel;
	tmpButton: TButton;
	i,j: Integer;
	tmpLst,customRuleSet: TStringList;
	test:TCollection;
begin
	try
		
	// Setup
	tMainContent := nil;
	tNaviLeft := nil;
	tabsRecordHeader := nil;
	lFoldedSections := TStringList.Create;
	lFoldedSections.values['HEAD:Prefilter'] := '1';
	
	colsWidth := COL1_WIDTH+COL1b_WIDTH+COL2_WIDTH+COL3_WIDTH+COL4_WIDTH+COL5_WIDTH
		+COL5b_WIDTH+COL6_WIDTH+COL7_WIDTH+COLS_SPACING * 9 + COLS_PADDING_SIDES * 2;

	frm2 := efStartForm(nil,WINFORM_WIDTH,WINFORM_HEIGHT,'Processing Rules Editor');
		
	AutoForm_setForm(frm2);
	AutoForm_SetAutoPos(windowPadding, windowPadding);
	
	tlab := efLabel('Processing Rules Editor',windowPadding,10,300,0,efBold);
	tlab.Font.Size := 14 * getSettingsFloat('config.fTextFontScale', 1.0);
		
	// Column header
	//columnHeader := _buildRulesTableHeader(frm2);
	
	AutoForm_SetAutoPos(200-20,windowPadding);

	panel := frm2;
	
	saveButton := AutoForm_AddButtonBottom(nil, #10003+' '+_('&Save changes'));
	saveButton.TabOrder := 1;
	saveButton.OnClick := _eventSave;
	
	reloadButton := AutoForm_AddButtonBottom(nil, #10003+' '+_('Re&load rules from files'));
	reloadButton.TabOrder := 1;
	reloadButton.OnClick := _eventLoad;
	

	closeButton := AutoForm_AddButtonBottom(mrCancel, #9747+' '+_('&Close without save'));
	closeButton.TabOrder := 0;
	closeButton.Cancel := true;

	// Navigation and rules
	_redrawMainLayout();
	
	efEndSub();
	
	frm2.ShowModal;
		
		
	AutoForm_endForm();
	finally
		// FreeAndNil(tmpLst);
		tMainContent := nil;
		tNaviMain := nil;
		tNaviLeft := nil;
		tabsRecordHeader := nil;
		saveButton := nil;
		reloadButton := nil;
		closeButton := nil;
		columnHeader := nil;
		rulesListOptionsPanel := nil;
		lastMarkedDragTarget := nil;
		if Assigned(frm2) then
			frm2.Free;
		frm2 := nil;
		FreeAndNil(explEditElmsList);
		FreeAndNil(lFoldedSections);

	end;
end;


{Builds table header for rules list}
function _buildRulesTableHeader(efOwner:TForm):TPanel;
var tlab: TLabel;
begin
	// Setup
	Result := efStartPanel(efOwner,0,0,0,20);
	Result.BorderWidth := 0;
	Result.BevelWidth := 0;
	efLeft := 0;
	
	// Background
	tlab := TLabel.Create(Result);
	tlab.Parent := Result;
	tlab.Width := colsWidth;
	tlab.Height := Result.Height;
	tlab.Transparent := false;
	tlab.Color := TABLE_HEADER_BG_COLOR;

	// Columns
	efLeft := COLS_PADDING_SIDES;
	tlab := efLabel('Rule Nr.',0,0,COL1_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efLeftAdd(COLS_SPACING);
		
	tlab := efLabel('C.',0,0,COL1b_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	tlab.ShowHint := true;
	tlab.Hint := 'Condition Nr.';
	efLeftAdd(COLS_SPACING);
	
	tlab := efLabel('Not',0,0,COL2_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efLeftAdd(COLS_SPACING);
	
	tlab := efLabel('Record field',0,0,COL3_WIDTH,0,efLeftAddWidth+efBold+efRight);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efLeftAdd(COLS_SPACING);
	
	tlab := efLabel('Compare type',0,0,COL4_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efLeftAdd(COLS_SPACING);
	
	tlab := efLabel('Value',0,0,COL5_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efLeftAdd(COLS_SPACING);
	
	tlab := efLabel('C. Actions',0,0,COL5b_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efLeftAdd(COLS_SPACING+10);
	tlab.ShowHint := true;
	tlab.Hint := 'Condition actions';
	
	tlab := efLabel('TagIdent / final tag',0,0,COL6_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efLeftAdd(COLS_SPACING);
	
	tlab := efLabel('Actions',0,0,COL7_WIDTH,0,efLeftAddWidth+efBold);
	efApplyLabelColor(tlab, TABLE_HEADER_FG_COLOR);
	efEndSub();

end;

{Redraws navigation and rules}
procedure _redrawMainLayout();
var
	customRuleSet: TStringList;
	lastScrollTop: Integer;
	freeMes: TStringList;
	i, curTop: Integer;
begin
	
	try
	frm2.DisableAlign();
	frm2.Enabled := false;
	frm2.Cursor := -11; // Busy
	frm := frm2;
	panel := frm2;
	efStartSub(frm2,frm2);
	
	freeMes := TStringList.Create();

	// Navigation
	curTop := 50;
	freeMes.addObject('',tNaviMain);
	tNaviMain := _buildNavigationTop();
	tNaviMain.Top := curTop;
	curTop := curTop + tNaviMain.Height + 30;
	
	// Left navigation
	freeMes.addObject('',tNaviLeft);
	tNaviLeft       := _buildNavigationLeft();
	tNaviLeft.Left  := windowPadding;
	tNaviLeft.Top   := curTop;
	tNaviLeft.Width := 160;
	
	// Rules
	//freeMes.addObject('',tMainContent);
	if Assigned(tMainContent) then begin
		//lastScrollTop := tMainContent.GetClientScrollOffset.y;
		lastScrollTop := tMainContent.VertScrollBar.Position;
		tMainContent.VertScrollBar.Position := 0;
		end;
	
	// Main rules box
	tMainContent        := _buildMainContentSB();
	tMainContent.Left   := windowPadding + tNaviLeft.Width + 30;
	tMainContent.Top    := curTop;
	tMainContent.Width  := frm2.Width - tMainContent.Left -  windowPadding;
	tMainContent.Height := frm2.Height - tMainContent.Top - 120;
	
	tNaviLeft.Height := tMainContent.Height;
	
	{columnHeader.Top   := tMainContent.Top - 20;
	columnHeader.Left  := tMainContent.Left;
	columnHeader.Width := tMainContent.Width;}
	
	freeMes.addObject('',tabsRecordHeader);
	
	tabsRecordHeader := efLabel('Record type',tNaviLeft.Left+10,tNaviLeft.Top-20,200,20,efBold);
	if sNavCurrentMain <> 'By record type' then
		tabsRecordHeader.Text := 'Sections';
	
	// Show the new stuff
	tNaviMain.Visible := true;
	tNaviLeft.Visible := true;
	tMainContent.Visible := true;
	rulesListOptionsPanel.Parent := tMainContent;
	tMainContent.VertScrollBar.Position := lastScrollTop;
	
	// Update buttons
	saveButton.Enabled := crsModifiedRuleSets.Count > 0;
	if crsModifiedRuleSets.Count > 0 then
		closeButton.Text := #9747+' '+_('&Close without save')
	else
		closeButton.Text := #9747+' '+_('&Close');
		
	efEndSub();
	finally
		frm2.Enabled := true;
		frm2.EnableAlign();
		frm2.Cursor := 0; // Default
		// Clear old stuff
		if Assigned(freeMes) then begin
			for i:= freeMes.Count - 1 downto 0 do
				if Assigned(freeMes.Objects[i]) then begin
					freeMes.Objects[i].Free;
					end;
			freeMes.Free;
			end;
	end;
end;

function _buildGenericNavigation(owner:TForm; menuEntries:TStringList; menuEntrySelected:String):TScrollBox;
const
	menuEntryHeight = 25;
var
	i, lStyle: Integer;
	tlab, tDesc: TLabel;
	sb:TScrollBox;
	entryKey, entryName, entryDesc: String;
begin
	sb := TScrollBox.Create(frm2);
	Result := sb;
	efStartSub(sb,sb);
	sb.Left := windowPadding;
	sb.Width := frm2.Width - windowPadding * 2;
	sb.Top := windowPadding;
	sb.Visible := false;
	sb.Parent := frm2;
	sb.Height := 50;
	
	sb.HorzScrollBar.Visible := false;
	sb.VertScrollBar.Tracking := true;

	
	for i := 0 to menuEntries.Count -1 do begin
		entryKey := menuEntries.Names[i];
		entryName := menuEntries.ValueFromIndex[i];
		SplitSimple('~',entryName,entryName,entryDesc);
		lStyle := efNone;
		if AnsiStrLastChar(entryName) = '*' then
			lStyle := efBold;
		tlab := efLabel('  '+entryName,0,i*menuEntryHeight,1,20,lStyle);
		
		if entryDesc <> '' then begin
			tDesc := efLabel(entryDesc,50,i*menuEntryHeight,200,20,efNone);
			tDesc.Enabled := false;
			tDesc.color := SELECTION_BG_COLOR;
			end
		else
			tDesc := nil;
		
		tlab.Cursor := -21;
		tlab.Color := SELECTION_BG_COLOR;

		if entryKey = menuEntrySelected then begin
			tlab.Transparent := false;
			tlab.Font.Color := SELECTION_FG_COLOR;
			if Assigned(tDesc) then
				tDesc.Font.Color := SELECTION_FG_COLOR;
			end
		else begin
			tlab.Transparent := true;
			tlab.Font.Color := $333333;
			if Assigned(tDesc) then
				tDesc.Font.Color := $333333;
			end;
			
		if Pos('(New)',entryName) <> 0 then 
			efApplyLabelColor(tlab, clGray);
		// Layout
		tlab.Layout := tlCenter;
		tlab.Height := menuEntryHeight;

		// DESC
		if Assigned(tDesc) then begin
			tDesc.Layout := tlCenter;
			tDesc.Height := menuEntryHeight;
			end;
		
		//tlab.Width := Length(procRuleSetIdent) * 8;
		if sNavCurrentMain = 'By record type' then
			tlab.OnClick := _eventClickSetRecordType
		else
			tlab.OnClick := _eventClickSetSubIdent;
		tlab.Width := 200;
		
		end;
	
	efEndSub();
	sb.Parent := owner;

end;

{Builds the main left navigation}
function _buildNavigationLeft():TScrollBox;
var
	isModified, isModView, isNonExisting: Boolean;
	i,j,k: Integer;
	tmpLst, tmpLst2, menuEntries, scanLst, sectionsOfRuleSet, lstDescriptions: TStringList;
	tmpStr, menuEntrySelected, modName, procRuleSetIdent,procRuleSetSectionIdent, entryKey, entryName: String;
	
begin
	isModView := false;
	if ( Pos(RULESETS_IDENTIFIER_USER_MOD_RULES,sNavCurrentMain) = 1 ) then begin
		modName := Copy(sNavCurrentMain,Length(RULESETS_IDENTIFIER_USER_MOD_RULES)+1,200);
		isModView := true;
		end;
	if ( Pos(RULESETS_IDENTIFIER_MOD_RULES,sNavCurrentMain) = 1 ) then begin
		modName := Copy(sNavCurrentMain,Length(RULESETS_IDENTIFIER_MOD_RULES)+1,200);
		isModView := true;
		end;
	
	
	tmpLst := TStringList.Create;
	if sNavCurrentMain = 'By record type' then begin
		tmpLst.CommaText := getAllRecordsString();
		tmpLst.insert(0,'ALL');
		lstDescriptions := getRecordsDescriptions();
		end
	else begin
		scanLst := TStringList.Create;
		if isModView then begin
			scanLst.add(RULESETS_IDENTIFIER_USER_MOD_RULES + modName);
			scanLst.add(RULESETS_IDENTIFIER_MOD_RULES + modName);
			end
		else
			scanLst.add(sNavCurrentMain);
		// Add available sections of ruleset
		for k := 0 to scanLst.Count -1  do begin
			i := customProcRuleSets.indexOf(scanLst[k]);
			if i > -1 then begin
				sectionsOfRuleSet := customProcRuleSets.Objects[i];
				for j:= 0 to sectionsOfRuleSet.Count -1 do begin
					procRuleSetSectionIdent := sectionsOfRuleSet.Strings[j];
					if tmpLst.indexOf(procRuleSetSectionIdent) = -1 then
						tmpLst.add(procRuleSetSectionIdent);
					end;
				end;
			end;
		// Add not existing sections for creating
		tmpLst2 := TStringList.Create;
		tmpLst2.CommaText := getAllRecordsString();
		for k := 0 to tmpLst2.Count -1  do
			if tmpLst.indexOf(tmpLst2[k]) = -1 then
				if tmpLst2[k] <> 'INNR' then
					tmpLst.add('+'+tmpLst2[k]);
		tmpLst2.Free;
		end;
	
	menuEntries := TStringList.Create;
	
	for i:= 0 to tmpLst.Count -1 do begin
		entryKey := tmpLst[i];
		isNonExisting := false;
		entryName := entryKey;
		if Pos('+',entryKey) = 1 then begin 
			entryKey := Copy(entryKey,2,200);
			isNonExisting := true;
			entryName := '(New) ' + entryKey;
			end;
		isModified := false;
		if sNavCurrentMain <> 'By record type' then
			isModified := (crsModifiedRuleSets.values[RULESETS_IDENTIFIER_MAIN_RULES + '>' + entryKey] <> '')
				or (crsModifiedRuleSets.values[RULESETS_IDENTIFIER_USER_RULES + '>' + entryKey] <> '')
				or (crsModifiedRuleSets.values[RULESETS_IDENTIFIER_MAIN_RULES + '>prefilter:' + entryKey] <> '')
				or (crsModifiedRuleSets.values[RULESETS_IDENTIFIER_USER_RULES + '>prefilter:' + entryKey] <> '')
				or ( (sNavCurrentMain <> '') and (crsModifiedRuleSets.values[sNavCurrentMain + '>' + entryKey] <> '') )
				or ( (sNavCurrentMain <> '') and (crsModifiedRuleSets.values[sNavCurrentMain + '>prefilter:' + entryKey] <> '') )
		else for j := 0 to crsModifiedRuleSets.Count -1 do
			if StrEndsWith(crsModifiedRuleSets.Names[j],entryKey) then
				isModified := true;
		
		// Selected?
		if (sNavCurrentMain = 'By record type') and (sNavCurrentRecordType = entryKey)
			or (sNavCurrentMain <> 'By record type') and (sNavCurrentSub = entryKey) 
			then
			menuEntrySelected := entryKey;
			
		if isModified then
			entryName := entryName+'*';
			
		// Add menu entry
		if Assigned(lstDescriptions) then
			entryName := entryName+'~'+lstDescriptions.values[entryKey];
		menuEntries.values[entryKey] := entryName;
		end;
		
	Result := _buildGenericNavigation(frm2,menuEntries,menuEntrySelected);

	
	tmpLst.Free;
	menuEntries.Free;
	if Assigned(lstDescriptions) then lstDescriptions.Free;
	
end;


{Builds top navigation}
function _buildNavigationTop():TScrollBox;
var
	i,j, curLeft: Integer;
	tlab: TLabel;
	antiDoubleLst, tmpLst: TStringList;
	procRuleSetIdent,procRuleSetSectionIdent, showName: String;
	sb:TScrollBox;
begin
	antiDoubleLst := TStringList.Create;
	sb := TScrollBox.Create(frm2);
	Result := sb;
	sb.Visible := false;
	sb.Parent := frm2;
	// sb.Align := alTop;
	sb.Height := 50;
	
	sb.Left := windowPadding;
	sb.Width := frm2.Width - windowPadding * 2;
	sb.Top := 20;
	sb.VertScrollBar.Visible := false;
	sb.HorzScrollBar.Tracking := true;

	curLeft := 0;
	efStartSub(sb,sb);
	
	tmpLst := TStringList.Create;
	
	for i:= -1 to customProcRuleSets.Count -1 do begin
		if i = -1 then
			procRuleSetIdent := 'By record type'
		else
			procRuleSetIdent := customProcRuleSets[i];
		tmpLst.add(procRuleSetIdent);
		end;
		
	if tmpLst.indexOf(RULESETS_IDENTIFIER_USER_RULES) = -1 then 
		tmpLst.add(RULESETS_IDENTIFIER_USER_RULES);
	for i := 0 to tmpLst.Count -1 do begin
		procRuleSetIdent := tmpLst[i];
		showName := procRuleSetIdent;
		
		showName := StringReplace(showName, RULESETS_IDENTIFIER_USER_MOD_RULES,'',[rfReplaceAll]);
		showName := StringReplace(showName, RULESETS_IDENTIFIER_MOD_RULES,'',[rfReplaceAll]);
		if showName = RULESETS_IDENTIFIER_MAIN_RULES then
			showName := 'Main rules';
		if showName = RULESETS_IDENTIFIER_USER_RULES then
			showName := 'User rules';
		
		if antiDoubleLst.indexOf(showName) > -1 then
			continue;
		antiDoubleLst.add(showName);
		tlab := efLabel(showName,curLeft,0,100,26,efCursorHand+efCenter+efAutoWidth);
		
		tlab.Color := SELECTION_BG_COLOR;
		tlab.Transparent := sNavCurrentMain <> procRuleSetIdent;
		if sNavCurrentMain = procRuleSetIdent then
			efApplyLabelColor(tlab,clWhite);
		//tlab.Width := Length(procRuleSetIdent) * 8;
		tlab.Width := tlab.Width + 20;
		tlab.OnClick := _eventClickSetMainIdent;
		tlab.HelpKeyword := procRuleSetIdent;
		curLeft := curLeft + tlab.Width;
		end;
	if curLeft <= sb.Width then
		sb.Height := 30;
	efEndSub();
	tmpLst.Free;
	antiDoubleLst.Free;
end;



function _buildMainContentSB( ):TScrollBox;
var
	i,j,iCnt1,iCnt2: Integer;
	sb: TScrollBox;
	tlab, fHeadSectSummary: TLabel;
	tmpCheckbox: TCheckBox;
	tmpLst, customRuleSet, ruleSetsToShow, hideMes, freeMes, showMes:TStringList;
	recordType, tmpStr, ruleSetName, rulesetFullQualName, rulesetMainIdent, rulesetNameClean: String;
	flagSkipToNextHead: Boolean;
	fHelp, fRuleSet: TPanel;
begin
	recordType := sNavCurrentSub;
	if recordType = '' then
		recordType := sNavCurrentRecordType;
	// Setup
	//FreeAndNil(explEditElmsList);
	freeMes := TStringList.Create;
	hideMes := TStringList.Create;
	showMes := TStringList.Create;
	if not Assigned(explEditElmsList) then
		explEditElmsList := TStringList.Create;

	// Scrollbox
	if not Assigned(tMainContent) then begin
		tMainContent := TScrollBox.Create(frm2);
		tMainContent.Parent := nil;
		tMainContent.Visible := false;
		tMainContent.HorzScrollBar.Visible := false;
		tMainContent.VertScrollBar.Tracking := true;
		tMainContent.Parent := frm2;
		end;

	Result := tMainContent;
		
	// Options panel
	if not Assigned(rulesListOptionsPanel) then begin
		rulesListOptionsPanel := TPanel.Create(frm2);
		rulesListOptionsPanel.Width := 500;
		rulesListOptionsPanel.Height := 30;
		rulesListOptionsPanel.BorderWidth := 0;
		rulesListOptionsPanel.BevelWidth := 0;
		frm := rulesListOptionsPanel;
		tmpCheckbox := AutoForm_AddCheckbox('Show all possible rulesets',flagShowEmptyRules,'');
		tmpCheckbox.Name := 'cbShowAll';
		tmpCheckbox.Top := 10;
		tmpCheckbox.Left := 100 + STYLE_RULES_PADDLEFT;
		tmpCheckbox.Parent := rulesListOptionsPanel;
		tmpCheckbox.OnClick := _eventChangeShowEmptyRules;
		tmpCheckbox.Width := 200;

		tmpCheckbox := AutoForm_AddCheckbox('Show help',flagShowHelp,'');
		tmpCheckbox.Top := 10;
		tmpCheckbox.Left := STYLE_RULES_PADDLEFT;
		tmpCheckbox.Width := 95;
		tmpCheckbox.Parent := rulesListOptionsPanel;
		tmpCheckbox.OnClick := _eventChangeShowHelp;
		end;
	
	rulesListOptionsPanel.FindComponent('cbShowAll').Visible := sNavCurrentRecordType <> '';
	// Start
	efStartSub(tMainContent,tMainContent);
	efPadding(20,10);
	efTop := 10 + rulesListOptionsPanel.Height;

	// Remove unnamed childs
	for i := efOwner.ComponentCount -1 downto 0 do
		if efOwner.Components[i].Name = '' then
			freeMes.addObject('obj', efOwner.Components[i])
		else
			hideMes.addObject('obj',efOwner.Components[i]);

	// Help
	fHelp := tMainContent.FindComponent('helpPanel');
	if flagShowHelp then begin
		if not Assigned(fHelp) then begin
			fHelp := _buildHelpPanel();
			fHelp.Name := 'helpPanel';
			end;
		efTopAdd(fHelp.Height);
		end;
	if Assigned(fHelp) then begin
		fHelp.Visible := flagShowHelp;
		if hideMes.indexOfObject(fHelp) > -1 then
			hideMes.delete(hideMes.indexOfObject(fHelp));
		end;

	// Build list to show
	ruleSetsToShow := TStringList.Create;
	
	if sNavCurrentRecordType <> '' then begin
		// By record type view
		ruleSetsToShow.add('HEAD:Prefilter');
		ruleSetsToShow.add('USER prefilter rules|'+RULESETS_IDENTIFIER_USER_RULES+'|'+'prefilter:'+recordType);
		if recordType <> 'ALL' then
			ruleSetsToShow.add('USER prefilter rules for all record types|'+RULESETS_IDENTIFIER_USER_RULES+'|'+'prefilter:'+'ALL');
		ruleSetsToShow.add('MAIN prefilter rules|'+RULESETS_IDENTIFIER_MAIN_RULES+'|'+'prefilter:'+recordType);
		if recordType <> 'ALL' then
			ruleSetsToShow.add('MAIN prefilter rules for all record types|'+RULESETS_IDENTIFIER_MAIN_RULES+'|'+'prefilter:'+'ALL');
		ruleSetsToShow.add('HEAD:Processing rules');
		ruleSetsToShow.add('USER rules|'+RULESETS_IDENTIFIER_USER_RULES+'|'+recordType);
		if recordType <> 'ALL' then
			ruleSetsToShow.add('USER rules for all record types|'+RULESETS_IDENTIFIER_USER_RULES+'|'+recordType+'ALL');
		ruleSetsToShow.add('MAIN rules|'+RULESETS_IDENTIFIER_MAIN_RULES+'|'+recordType);
		if recordType <> 'ALL' then
			ruleSetsToShow.add('MAIN rules for all record types|'+RULESETS_IDENTIFIER_MAIN_RULES+'|'+recordType+'ALL');
		end
	else if sNavCurrentSub <> '' then begin
		if Pos(RULESETS_IDENTIFIER_MOD_RULES,sNavCurrentMain) = 1 then begin
			ruleSetsToShow.add('USER rules for mod|'+ StringReplace(sNavCurrentMain,RULESETS_IDENTIFIER_MOD_RULES,RULESETS_IDENTIFIER_USER_MOD_RULES,[rfReplaceAll])+'|'+sNavCurrentSub);
			ruleSetsToShow.add('MAIN rules for mod|'+ sNavCurrentMain+'|'+sNavCurrentSub);
			end
		else if Pos(RULESETS_IDENTIFIER_USER_MOD_RULES,sNavCurrentMain) = 1 then begin
			ruleSetsToShow.add('USER rules for mod|'+ sNavCurrentMain+'|'+sNavCurrentSub);
			ruleSetsToShow.add('MAIN rules for mod|'+ StringReplace(sNavCurrentMain,RULESETS_IDENTIFIER_USER_MOD_RULES,RULESETS_IDENTIFIER_MOD_RULES,[rfReplaceAll])+'|'+sNavCurrentSub);
			end
		else
			ruleSetsToShow.add('Ruleset view|'+ sNavCurrentMain+'|'+sNavCurrentSub);
		
		end;
	
	//efStartSub(efOwner, efParent);
	
	for i := 0 to ruleSetsToShow.Count -1 do begin
		
		// HEAD LINE
		if Pos('HEAD:',ruleSetsToShow[i]) = 1 then begin
		
			iCnt1 := 0;
			iCnt2 := 0;
			tmpStr := '[+]';
			flagSkipToNextHead := false;
			if lFoldedSections.values[ruleSetsToShow[i]] <> '' then begin
				flagSkipToNextHead := true;
				tmpStr := '[-]';
				end;
			
			tlab := efLabel('      '+tmpStr+' '+Copy(ruleSetsToShow[i],5+1,1000),-STYLE_RULES_PADDLEFT,0,0,30,efBold+efCursorHand+efHidden+efAutoWidth);
			fHeadSectSummary := efLabel('',tlab.Width+10,0,140,30,efNone);
			// fHeadSectSummary.Enabled := false;
			
			tlab.Width := colsWidth + STYLE_RULES_PADDLEFT * 2;

			tlab.color := RULES_HEADLINE_BG_PREORNOT;
			tlab.Transparent := false;
			
			// Togglebox
			_linkAction(tlab,'TOGGLE_FOLDED_HEAD',nil,0,ruleSetsToShow[i]);
			tlab.ShowHint := true;
			tlab.Hint := 'Click to fold/unfold';
			showMes.addObject('obj',tlab);
			
			// Link for foldeds
			efTopAdd(tlab.Height + 10);
			if lFoldedSections.values[ruleSetsToShow[i]] <> '' then begin
				tlab := efLabel('Show ruleset(s)',COLS_PADDING_SIDES,0,0,0,efNone+efBlue+efCursorHand+efTopAddHeight);
				_linkAction(tlab,'link|TOGGLE_FOLDED_HEAD',nil,0,ruleSetsToShow[i]);
				efTopAdd(10);
				end;

			efTopAdd(10);
			continue;
			end;
			

			
		// Ruleset
		tmpStr := ruleSetsToShow[i];
		tmpLst := Split('|', tmpStr);
		ruleSetName := tmpLst[0];
		rulesetMainIdent := tmpLst[1];
		customRuleSet := CustomRuleSets.getProcessingRuleSetSection({taskIdent}'',rulesetMainIdent,tmpLst[2]);
		rulesetFullQualName := rulesetMainIdent + '>' + tmpLst[2];
		rulesetNameClean := PregReplace('[^a-zA-Z0-9_]','_',rulesetFullQualName);
		tmpLst.Free;
		
		// Filter
		if not Assigned(customRuleSet) and not flagShowEmptyRules then
			if (Pos('USER',rulesetFullQualName) = 0) or (Pos('ALL',rulesetFullQualName) <> 0) then
				continue;

		// Counting
		if Assigned(customRuleSet) then begin
			Inc(iCnt1);
			iCnt2 := iCnt2 + customRuleSet.Count;
			if Assigned(fHeadSectSummary) then begin
				efApplyLabelText(fHeadSectSummary,'('+IntToStr(iCnt2)+' rules in '+IntToStr(iCnt1)+' rulesets)');
				efApplyLabelColor(fHeadSectSummary,RULES_HEADLINE_FG_TEXT);
				end;
			end;
		
		// Folded?
		if flagSkipToNextHead then
			continue;
		
		// Ini Link
		if sNavCurrentSub <> '' then 
			if crsRuleSetIniFiles.values[rulesetMainIdent] <> '' then begin
				tmpStr := crsRuleSetIniFiles.values[rulesetMainIdent];
				
				tmpStr := '' // StringReplace(tmpStr,sComplexSorterBasePath,'',[rfReplaceAll]);
					+ '' + ExtractFileName(ExtractFileDir(ExtractFileDir(ExtractFileDir(ExtractFileDir(tmpStr)))))
					+ '\' + ExtractFileName(ExtractFileDir(ExtractFileDir(ExtractFileDir(tmpStr))))
					+ '\' + ExtractFileName(ExtractFileDir(ExtractFileDir(tmpStr)))
					+ '\' + ExtractFileName(ExtractFileDir(tmpStr))
					+ '\' + ExtractFileName(tmpStr);
				tlab := efLabel('Definition file: '+ tmpStr,0,0,800,0,efTopAddHeight+efBlue+efCursorHand);
				_linkAction(tlab,'link|OPEN_INI_FILE',nil,0,crsRuleSetIniFiles.values[rulesetMainIdent]);
				end;
		
		
		
		efTopAdd(10);
		// Add Ruleset
		fRuleSet := tMainContent.FindComponent('ruleset_'+rulesetNameClean);
		// Marked for renewal?
		if Assigned(fRuleSet) then
			if fRuleSet.Cursor = -17 then begin
				fRuleSet.name := '';
				freeMes.addObject('obj',fRuleSet);
				fRuleSet := nil;
				end;
		// Create/update
		if not Assigned(fRuleSet) then begin
			fRuleSet := _buildRuleSet(fRuleSet,customRuleSet,ruleSetName,rulesetFullQualName);
			fRuleSet.Text := ' ';
			fRuleSet.Name := 'ruleset_'+rulesetNameClean;
			end
		else
			hideMes.delete(hideMes.indexOfObject(fRuleSet));


		showMes.addObject('obj',fRuleSet);
		fRuleSet.Top := efTop;
		efTopAdd(fRuleSet.Height);
		end;
		
		
	// Platz ans ende
	efLabel('',0,0,0,0,efNone);
	
	// Show new components
	for i := showMes.Count - 1 downto 0 do
		showMes.Objects[i].Show();

	// Hide unused components
	for i := hideMes.Count - 1 downto 0 do
		hideMes.Objects[i].Hide();
	
	// Free unneded components
	for i := freeMes.Count - 1 downto 0 do
		freeMes.Objects[i].Free();
	
	frm := frm2;
	efEndSub();
	hideMes.Free;
	freeMes.Free;
	showMes.Free;
end;

{build one ruleset head and list}
function _buildRuleSet(meExisting:TForm;customRuleSet:TStringList;ruleSetName,rulesetFullQualName:String):TPanel;
var
	i, iStyle: Integer;
	tlab, tlab2, tlab3, tBG: TLabel;
	tmpStr: String;
	fRulesTable: TPanel;
begin
	Result := efStartPanel(efOwner,0,0,colsWidth,0);
	Result.Visible := false;
	Result.BorderWidth := 0;
	Result.BevelWidth := 0;
	efLeft := STYLE_RULES_PADDLEFT;

	// BG for ruleset title
	tBG := efLabel('',0,0,colsWidth,30,efNone);
	if Pos('USER',ruleSetName) = 0 then
		if Assigned(customRuleSet) then // MAIN colors
			tBG.Color := RULES_HEADLINE_BG_MAIN_EXIST 
		else
			tBG.Color := RULES_HEADLINE_BG_MAIN_NOT_EXIST
	else
		tBG.Color := RULES_HEADLINE_BG_USER;
	tBG.Transparent := false;
	
	
	// Identifier (linkable?)
	iStyle := efItalic+efRight+efAutoWidth;
	if Assigned(customRuleSet) then begin
		tmpStr := '     ' + rulesetFullQualName+'   ';
		iStyle := iStyle + efCursorHand;
		end
	else
		tmpStr := '(empty) ' + rulesetFullQualName+'   ';
	
	if crsModifiedRuleSets.values[rulesetFullQualName] <> '' then begin
		iStyle := iStyle + efBold;
		tmpStr := ' **MODIFIED** ' + tmpStr;
		ruleSetName := '*'+ruleSetName;
		end;
	
	tlab := efLabel(tmpStr, colsWidth/2-STYLE_RULES_PADDLEFT,0,colsWidth/2,tBG.Height,iStyle);
	if Assigned(customRuleSet) then begin
		_linkAction(tlab,'ACTION_VIEW_RULESET:'+rulesetFullQualName,nil,-1,rulesetFullQualName);
		tlab.ShowHint := true;
		tlab.Hint := 'Click to view/edit only this ruleset';
		end
	else
		efApplyLabelColor(tlab,clGray);
			
	
	// Human readable name
	tlab := efLabel(ruleSetName,COLS_PADDING_SIDES,0,300,tBG.Height,efTopAddHeight+efBold);
	
	// Main rules
	if Assigned(customRuleSet) then begin
		fRulesTable := _buildRulesList(customRuleSet,rulesetFullQualName);
		efTopAdd(fRulesTable.Height);
		end;

	// Links: New rule
	tlab := efLabel('Add new rule',5,0,100,30,efTopAddHeight+efCursorHand+efBlue);
	if Assigned(customRuleSet) then
		_linkAction(tlab,'link|ACTION_NEW_RULE',customRuleSet,-1,rulesetFullQualName)
	else
		_linkAction(tlab,'link|ACTION_NEW_RULESET:'+rulesetFullQualName,nil,-1,rulesetFullQualName);
	
	efTopAdd(15);
	Result.Height := efTop;
	efEndSub;
	
end;



{Builds the help panel}
function _buildHelpPanel():TPanel;
var tlab, tlab2, tlab3: TLabel;
begin
	Result := efStartPanel(efOwner,0,0,colsWidth,0);
	Result.BorderWidth := 0;
	Result.BevelWidth := 0;
	efTopAdd(5);
	tlab2 := efLabel('',5,0,500,20,efNone);
	tlab3 := efLabel('',5,0,500,20,efNone);
	
	tlab := efLabel('Help',20,0,500,20,efTopAddHeight+efBold);
	tlab := efLabel('The processing rules determine the actions of Complex Sorter. '+#10+#13
		+'All records go through the entire ruleset for that record type. Beginning at the top, until a final rule is found.'+#10+#13
		+'Priority of rulesets:'+#10+#13
		+'  A) Prefilter > Processing rules'+#10+#13
		+'     Prefilter rules are applied before any other action is made. '
				+'If the prefilter decide to filter a record, the processing rules will never see that record. '+#10+#13
		+'  B) MODUSER > MOD > USER > MAIN'+#10+#13
		+'     USER rules have always higher priority than MAIN rules. The MOD specific rules have higher priority than MAIN rules. '+#10+#13
		+ ' C) [RECORD-TYPE] > [ALL] '+#10+#13
		+'     For one ruleset the specific record type rules have higher priority than the ALL rules.'+#10+#13
		+'Every rule have one or more conditions and one TagIdent. '+#10+#13
			+'  If ALL conditions of a rule match, the rule will apply:'+#10+#13
			+'    a) If the TagIdent is a special function, the function will be executed and the chain processing continues. '+#10+#13
			+'    b) If the TagIdent is a final tag, the record gets the tag and the processing ends.'+#10+#13
			+'    c) If the TagIdent is an empty string (e.g. ""), the record gets no tag and the processing ends.'+#10+#13
			+'Editing:'+#10+#13
			+'You can edit the rule parts by just clicking on the part.'+#10+#13
			+'Reorder the rules with drag and drop (only in the ruleset).'+#10+#13
			+'Add and remove rules and conditions with the action links.'
			//+#10+#13
		,20,0,1000,0,efTopAddHeight);
	tlab.Height := nil;
	tlab.WordWrap := true;
	efTopAdd(tlab.Height + 10);
	// Nice boxy
	tlab2.Left := tlab.Left - 5;
	tlab2.Top := tlab.Top - 5 - 20;
	tlab2.Width := tlab.Width + 10;
	tlab2.Height := tlab.Height + 10 + 20;
	tlab3.Left := tlab.Left - 4;
	tlab3.Top := tlab.Top - 4 - 20;
	tlab3.Width := tlab.Width + 8;
	tlab3.Height := tlab.Height + 8 + 20;
	tlab2.Color := TABLE_ALT_ROW_BG_COLOR2; //$AAAAAA;
	tlab3.Color := TABLE_ALT_ROW_BG_COLOR1; //$E1E1E1;
	tlab2.Transparent := false;
	tlab3.Transparent := false;
	Result.height := efTop;
	efEndSub();
end;

{Builds the list for one ruleset}
function _buildRulesList(customRuleSet:TStringList;rulesetFullQualName:String):TPanel;
const
	rowHeight = 25;
	rowPaddingHeight = 4;
var
	i,j, curleft, allLinesHeight, curLineHeight: Integer;
	tlab, tBG, cp0,cp1,cp2,cp3,cp4,cp5: TLabel;
	ruleLine, parsedCondition, conditionPacks, conditionPack: TStringList;
	tmpStr, ruleApplyTag: String;
	columnHeader2, linePanel, tmpPanel: TPanel;
begin

	Result := efStartPanel(efOwner,STYLE_RULES_PADDLEFT,0,colsWidth,0);
	Result.BorderWidth := 0;
	Result.BevelWidth := 0;
	// Column headesr
	if customRuleSet.Count > 0 then begin
		columnHeader2 := _buildRulesTableHeader(efParent);
		columnHeader2.top := efTop;
		columnHeader2.Width := colsWidth;
		efTopAdd(columnHeader2.Height);
		end;
	
	efTopAdd(rowPaddingHeight/2);
	
	for i:= 0 to customRuleSet.Count - 1 do begin
		conditionPacks := customRuleSet.Objects[i];
		ruleApplyTag  := customRuleSet.Strings[i];

		// Prepare rule panel
		linePanel := efStartPanel(Result,0,0,colsWidth,0);
		linePanel.Text := ' ';
		linePanel.Name := 'rule'+IntToStr(i);
		linePanel.BorderWidth := 0;
		linePanel.BevelWidth := 0;
		linePanel.OnMouseEnter := _eventBGOnMouseEnter;
		linePanel.OnMouseLeave := _eventBGOnMouseLeave;
		
		if i > 0 then
			efTopAdd(rowPaddingHeight)
		else
			efTopAdd(rowPaddingHeight/2);
		
		// Alternating bg
		tBG := efLabel(' ',0,0,0,0,efNone);
		tBG.Name := 'bg';
		if i mod 2 = 0 then
			tBG.Color := TABLE_ALT_ROW_BG_COLOR1
		else
			tBG.Color := TABLE_ALT_ROW_BG_COLOR2;
			
		// Conditions
		allLinesHeight := 0;
		for j := 0 to conditionPacks.Count-1 do begin
			conditionPack   := conditionPacks.Objects[j];
			parsedCondition := conditionPack.Objects[CONDITION_PACK_INDEX_OBJ_PARSED_RULES];
			curleft := COLS_PADDING_SIDES + COL1_WIDTH + COLS_SPACING;
			curLineHeight := rowHeight;
			
			// Seperator
			if j > 0 then begin
				tlab := TLabel.Create(efOwner);
				tlab.Parent := efParent;
				tlab.Left := curleft - COLS_PADDING_SIDES;
				tlab.Top := efTop-1;
				tlab.Width := COL1b_WIDTH + COL2_WIDTH + COL3_WIDTH + COL4_WIDTH + COL5_WIDTH+COL5b_WIDTH + COLS_SPACING * 5;
				//tlab.Height := 20 * conditionPacks.Count;
				tlab.Height := 1;
				tlab.Color := clSilver;//clSilver;
				tlab.Transparent := false;
				end;
			
			
			// Condition nr
			cp0 := efLabel(IntToStr(j+1),curleft,0,COL1b_WIDTH,0,efNone);
			// efApplyLabelColor(cp0, clGreen);
			curleft := curleft + COL1b_WIDTH + COLS_SPACING;
			
			// NOT
			tmpStr := '   ';
			//if conditionPack[CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR] = 'False' then
				tmpStr := 'not';
			cp1 := efLabel(tmpStr,curleft,0,COL2_WIDTH,rowHeight,efCenter);
			cp1.ShowHint := true;
			cp1.Hint := 'Toggle negation of condition';
			if conditionPack[CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR] = 'False' then
				efApplyLabelColor(cp1, clRed)
			else
				efApplyLabelColor(cp1, $CCCCCC);
			_linkAction(cp1,'ACTION_TOGGLE_NOT',conditionPack,0,rulesetFullQualName);
			curleft := curleft + COL2_WIDTH + COLS_SPACING;
					
			
			// Param 2
			cp2 := efLabel(parsedCondition[0],curleft,0,COL3_WIDTH,rowHeight,efRight+efAutoHeight);
			if curLineHeight < cp2.Height + rowPaddingHeight then
				curLineHeight := cp2.Height + rowPaddingHeight;
			
			curleft := curleft + COL3_WIDTH + COLS_SPACING;
			_linkAction(cp2,'ACTION_SET_VALUE',parsedCondition,0,rulesetFullQualName);
			
			// Param 3
			tmpStr := '';
			if parsedCondition.Count > 1 then
				tmpStr := parsedCondition[1];
			cp3 := efLabel(tmpStr,curleft,0,COL4_WIDTH,rowHeight,efCenter);
			curleft := curleft + COL4_WIDTH + COLS_SPACING;
			if parsedCondition.Count > 1 then
				_linkAction(cp3,'ACTION_SET_COMPARETYPE', parsedCondition,1,rulesetFullQualName);
			
			// Param 4
			tmpStr := '';
			if parsedCondition.Count > 2 then
				tmpStr := StringReplace(parsedCondition[2],'|',#10+#13,[rfReplaceAll]);
			cp4 := efLabel(tmpStr,curleft,0,COL5_WIDTH,rowHeight,efAutoHeight);
			cp4.ShowHint := true;
			cp4.Hint := StringReplace(tmpStr,'|',#448,[rfReplaceAll]);
			if curLineHeight < cp4.Height + rowPaddingHeight then
				curLineHeight := cp4.Height + rowPaddingHeight;
				
			if parsedCondition.Count > 2 then
				_linkAction(cp4,'ACTION_SET_VALUE',parsedCondition,2,rulesetFullQualName);
			curleft := curleft + COL5_WIDTH + COLS_SPACING;

			// Link: Add Condition
			if j = conditionPacks.Count -1 then begin
				cp5 := efLabel('Add',curleft+COL5b_WIDTH/2,curLineHeight-rowHeight,COL5b_WIDTH/2,rowHeight,efBlue+efCursorHand);
				cp5.ShowHint := true;
				cp5.Hint := 'Add condition to rule';
				_linkAction(cp5,'link|ACTION_ADD_CONDITION',conditionPacks,-1,rulesetFullQualName);
				end;
				
			// Link: Remove condition
			cp5 := efLabel('Del',curleft,0,COL5b_WIDTH/2,rowHeight,efBlue+efCursorHand);
			
			if conditionPacks.Count > 1 then begin
				_linkAction(cp5,'link|ACTION_REMOVE_CONDITION',conditionPacks,j,rulesetFullQualName);
				cp5.ShowHint := true;
				cp5.Hint := 'Delete condition';
				end
			else
				cp5.Text := '';
				
			curleft := curleft + COL5b_WIDTH + COLS_SPACING + 10;

			// Equalize height
			cp0.Height := curLineHeight;
			cp1.Height := curLineHeight;
			if cp2.Height < curLineHeight then
				cp2.Layout := tlCenter;
			cp2.Height := curLineHeight;
			cp3.Height := curLineHeight;
			if cp4.Height < curLineHeight then
				cp4.Layout := tlCenter;
			cp4.Height := curLineHeight;

			efTopAdd(curLineHeight);
			allLinesHeight := allLinesHeight + curLineHeight;
			end;

		// Draggable rule nr
		curleft := COLS_PADDING_SIDES;
		tlab := efLabel(TEXT_RULE_PREFIX+IntToStr(i+1),curleft,-allLinesHeight,COL1_WIDTH,allLinesHeight,efNone);
		 
		tlab.DragMode := dmAutomatic;
		tlab.ShowHint := true;
		tlab.Hint := 'Move per drag and drop';
		// tlab.DragCursor := -21;
		_linkAction(tlab,'DRAG_N_DROP',customRuleSet,0,rulesetFullQualName);
		tlab.OnStartDrag := _eventOnDragStart;
		tlab.OnEndDrag := _eventOnDragEnd;
		tlab.OnDragOver := _eventOnDragOver;
		tlab.OnDragDrop := _eventOnDragDrop;
		tlab.OnMouseEnter := _eventLabelOnMouseEnter;
		tlab.OnMouseLeave := _eventLabelOnMouseLeave;
		
		// TagIdent
		tmpStr := ruleApplyTag;
		curLeft := COLS_PADDING_SIDES+COL1_WIDTH+COL1b_WIDTH+COL2_WIDTH+COL3_WIDTH+COL4_WIDTH+COL5_WIDTH+COL5b_WIDTH+10+COLS_SPACING*7;
		tlab := efLabel(tmpStr,curLeft,-allLinesHeight,COL6_WIDTH,allLinesHeight,efNone);
		if Pos('prefilter:',rulesetFullQualName) = 0 then
			_linkAction(tlab,'ACTION_SET_TAGIDENT',customRuleSet,i,rulesetFullQualName)
		else
			_linkAction(tlab,'ACTION_SET_PREFILTER_TAGIDENT',customRuleSet,i,rulesetFullQualName);
		
		if Pos('SPECIAL:',tmpStr) = 0 then begin
			tmpStr := tagNames.values[tmpStr];
			tlab := efLabel(tmpStr,curLeft,-allLinesHeight,COL6_WIDTH,allLinesHeight,efRight);
			efApplyLabelColor(tlab,clTeal);
			tlab.Left := tlab.Left+COL6_WIDTH/2;
			tlab.Width := COL6_WIDTH/2;
			//_linkAction(tlab,'TO_PARENT',nil,0,'');
			end;

		// BG drunter
		if Assigned(tBG) then begin
			//tBG.Left := STYLE_RULES_PADDLEFT;
			tBG.Width := colsWidth;
			tBG.Top := tlab.Top-rowPaddingHeight/2;
			tBG.Height := allLinesHeight+rowPaddingHeight;
			tBG.Transparent := false;
			tBG.OnMouseEnter := _eventBGOnMouseEnter;
			tBG.OnMouseLeave := _eventBGOnMouseLeave;

			end;
			
		curleft := curleft + COL6_WIDTH + COLS_SPACING;

		tlab := efLabel('DEL',curleft+COL7_WIDTH/2,-allLinesHeight,COL7_WIDTH/2,allLinesHeight,efBlue+efCursorHand);
		tlab.ShowHint := true;
		tlab.Hint := 'Remove rule';
		_linkAction(tlab,'link|ACTION_REMOVE_RULE',customRuleSet,i,rulesetFullQualName);

		
		linePanel.Height := efTop;
		efEndSub();
		efTopAdd(linePanel.Height);
		
		end;
	//Result := efTop;
	Result.Height := efTop;
	efEndSub();
end;


{Links a TLabel to action}
procedure _linkAction(tlab:TLabel; action:String; storedObject:TObject; storedIndex:Integer; modifiedRulesetFullQualName:String );
var
	objIndex:Integer;
begin
	{if action = 'TO_PARENT' then begin
		tlab.OnClick := _eventUPEditActionOnClick;
		tlab.OnMouseEnter := _eventUPEditActionOnMouseEnter;
		tlab.OnMouseLeave := _eventUPEditActionOnMouseLeave;
		Exit;
		end;}
	objIndex := -1;
	if Assigned(storedObject) then begin
		objIndex := explEditElmsList.Count;
		explEditElmsList.addObject('lnk',storedObject);
		end;
	tlab.HelpKeyword := action+','+IntToStr(objIndex)+','+IntToStr(storedIndex)+','+modifiedRulesetFullQualName;
	tlab.OnClick := _eventEditAction;
	tlab.OnMouseEnter := _eventLabelOnMouseEnter;
	tlab.OnMouseLeave := _eventLabelOnMouseLeave;
end;

{procedure _eventUPEditActionOnClick(Sender:TObject); begin _eventEditAction(Sender.Parent); end;
procedure _eventUPEditActionOnMouseEnter(Sender:TObject); begin _eventLabelOnMouseEnter(Sender.Parent); end;
procedure _eventUPEditActionOnMouseLeave(Sender:TObject); begin _eventLabelOnMouseLeave(Sender.Parent); end;}

{Event navigation: set main ident (top)}
procedure _eventClickSetMainIdent(sender:TObject);
begin
	sNavCurrentMain := StringReplace(Trim(sender.HelpKeyword),'*','',[rfReplaceAll]);
	sNavCurrentSub := '';
	sNavCurrentRecordType := '';
	_redrawMainLayout();
end;


{Event navigation: set sub ident (left)}
procedure _eventClickSetSubIdent(sender:TObject);
begin
	sNavCurrentSub := StringReplace(Trim(sender.Text),'*','',[rfReplaceAll]);
	sNavCurrentSub := StringReplace(sNavCurrentSub,'(New) ','',[rfReplaceAll]);
	sNavCurrentRecordType := '';
	_redrawMainLayout();
end;


{Event navigation: set record for view (left)}
procedure _eventClickSetRecordType(sender:TObject);
begin
	sNavCurrentRecordType := StringReplace(Trim(sender.Text),'*','',[rfReplaceAll]);
	sNavCurrentMain := 'By record type';
	sNavCurrentSub := '';
	_redrawMainLayout();
end;


{Event: Edit a rule part}
procedure _eventEditAction(Sender: TObject);
var
	storedIndex: Integer;
	action, modifiedRulesetFullQualName: String;
	tmpLst,storedObject: TStringList;
begin
	try

	frm2.Enabled := false;
	tmpLst := Split(',',Sender.HelpKeyword);
	action := tmpLst[0];
	if Pos('|',action) <> 0 then
		action := Copy(action,Pos('|',action)+1,100);
	storedObject := nil;
	if StrToInt(tmpLst[1]) > -1 then
		storedObject := explEditElmsList.Objects[StrToInt(tmpLst[1])];
	storedIndex := StrToInt(tmpLst[2]);
	modifiedRulesetFullQualName := tmpLst[3];
	tmpLst.Free;
	_execAction(action, storedObject, storedIndex, modifiedRulesetFullQualName);
	finally
		frm2.Enabled := true
	end;
end;

{Executes a event action }
function _execAction(action:String; storedObject:TObject; storedIndex:Integer; modifiedRulesetFullQualName:String ):Boolean;
var
	i, selection: Integer;
	tmpStr, sTagIdent: String;
	tmpLst,compareTypes, conditionPacks, conditionPack, parsedCondition: TStringList;
	fPanel: TPanel;
begin
	
	// Action: Edit rule toggle not
	if action = 'ACTION_TOGGLE_NOT' then begin
		if storedObject.Strings[CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR] = 'True' then
			storedObject.Strings[CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR] := 'False'
		else
			storedObject.Strings[CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR] := 'True';
		crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
		end;
	
	// Action: Edit rule edit value
	if action = 'ACTION_SET_VALUE' then begin
		tmpStr := storedObject[storedIndex];
		if storedIndex = 0 then
			if _winShowRecElementInput(tmpStr) then begin
				storedObject[storedIndex] := tmpStr;
				crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
				end
			else
		else begin
			// Show Assistant for EDID 
			fPanel := nil;
			if (storedIndex = 2) then
				if (storedObject[0] = 'EDID') then 
					fPanel := _getFPanelForEdidAssistant(modifiedRulesetFullQualName);
			
			if WindowPrompt('Set value','Specify compare value:',tmpStr,fPanel) then begin
				storedObject[storedIndex] := tmpStr;
				crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
				end;
			//if Assigned(fPanel) then  fPanel.Free;
			end;
		end;
	
	// Action: Edit rule set TagIdent
	if (action = 'ACTION_SET_TAGIDENT') or (action = 'ACTION_SET_PREFILTER_TAGIDENT') then begin
		if _winSelectTagIdent(action = 'ACTION_SET_PREFILTER_TAGIDENT', storedObject.Strings[storedIndex],tmpStr) then begin
			storedObject.Strings[storedIndex] := tmpStr;
			crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
			end;
		end;
		
	// Action: Edit rule set ComparyType
	if action = 'ACTION_SET_COMPARETYPE' then begin
		compareTypes := TStringList.Create;
		compareTypes.CommaText := 'equals,exists,contains,beginsWith,numEquals,greaterThan,lessThan,hasFlag,hasOnlyFlags';
		tmpStr := storedObject[storedIndex];
		selection := FormSimpleSelection.show('Select compare type','',compareTypes,tmpStr);
		if selection > -1 then begin
			storedObject.Strings[1] := compareTypes[selection];
			crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
			end;
		compareTypes.Free;
	end;

	// Action: Go to ruleset view
	if Pos('ACTION_VIEW_RULESET:',action) = 1 then begin
		tmpLst := Split('>',Copy(action,Length('ACTION_VIEW_RULESET:')+1,1000));
		sNavCurrentRecordType := '';
		sNavCurrentMain := tmpLst[0];
		sNavCurrentSub := tmpLst[1];
		tmpLst.Free;
		end;
		
	// Action: Create new ruleset and first rule
	tmpStr := '';
	if Pos('ACTION_NEW_RULESET:',action) = 1 then begin
		tmpStr := _winPromptNewCondition(true, Pos('prefilter',modifiedRulesetFullQualName)>0);
		if tmpStr <> '' then begin
		//if WindowConfirm('Create new ruleset', 'Create new ruleset?') then begin
			tmpLst := Split('>',Copy(action,Length('ACTION_NEW_RULESET:')+1,1000));
			
			// Create new MAIN ruleset container
			if ( customProcRuleSets.indexOf(tmpLst[0]) = -1  ) then
				customProcRuleSets.addObject(tmpLst[0], TStringList.Create());

			// Create empty rules container - store in storedObject for next action
			storedObject := TStringList.Create();
			i := customProcRuleSets.indexOf(tmpLst[0]);
			if ( customProcRuleSets.Objects[i].indexOf(tmpLst[1]) = -1  ) then
				customProcRuleSets.Objects[i].addObject(tmpLst[1], storedObject);
			
			modifiedRulesetFullQualName := tmpLst[0]+'>'+tmpLst[1];
			crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
			tmpLst.Free;
			// Prepare next action
			action := 'ACTION_NEW_RULE';
		end;
	end;
	
	// Actions: Create new rule or condtion
	if (action = 'ACTION_NEW_RULE') or (action = 'ACTION_ADD_CONDITION')  then begin
		if tmpStr = '' then
			tmpStr := _winPromptNewCondition(action = 'ACTION_NEW_RULE', Pos('prefilter',modifiedRulesetFullQualName)>0);
		if tmpStr <> '' then begin
			// TagIdent?
			sTagIdent := 'TagIdent';
			if Pos('prefilter',modifiedRulesetFullQualName)>0 then
				sTagIdent := 'IGNORE';
			SplitSimple('=',tmpStr,tmpStr,sTagIdent);
			tmpStr := Trim(tmpStr);
			sTagIdent := Trim(sTagIdent);
			
			// Parse
			parsedCondition := parseParameters(tmpStr,true);
			// Create condition pack
			conditionPack := TStringList.Create;
			// NOT?
			if parsedCondition[0] = 'not' then begin
				conditionPack.add('False');
				parsedCondition.delete(0);
				end
			else
				conditionPack.add('True');
				
			conditionPack.addObject(parsedCondition.CommaText,parsedCondition);
			
			if action = 'ACTION_ADD_CONDITION' then
				conditionPacks := storedObject	// storedObject is conditionPacks
			else if action = 'ACTION_NEW_RULE' then begin
					conditionPacks := TStringList.Create; // storedObject is customRuleSet
					storedObject.addObject(sTagIdent, conditionPacks{List of conditionPacks});
				end;
			// Add new condition
			
			conditionPacks.addObject('cpack', conditionPack);
			crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
			end;
		end;

	// Action: Remove condition
	if action = 'ACTION_REMOVE_CONDITION' then
		if WindowConfirm('Confirm','Remove condition?') then begin
			conditionPacks := storedObject;
			CustomRuleSets.cleanupConditionPack(conditionPacks.Objects[storedIndex]);
			storedObject.delete(storedIndex);
			crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
			//conditionPacks.Free();
		end;

	// Action: Remove rule
	if action = 'ACTION_REMOVE_RULE' then
		if WindowConfirm('Confirm','Remove rule?') then begin
			
			conditionPacks := storedObject.Objects[storedIndex];
			for i := 0 to conditionPacks.Count -1 do
				CustomRuleSets.cleanupConditionPack(conditionPacks.Objects[i]);
			storedObject.delete(storedIndex);
			conditionPacks.Free();
			crsModifiedRuleSets.values[modifiedRulesetFullQualName] := '1';
			end;
	
	// Action: Set value for input box
	if action = 'SET_WIN_INPUT_VALUE' then begin
		WindowPromptSetInputValue(modifiedRulesetFullQualName);
		// no redraw
		Exit;
		end;
		
	// Action: Folding
	if action = 'TOGGLE_FOLDED_HEAD' then begin
		if lFoldedSections.values[modifiedRulesetFullQualName] = '' then
			lFoldedSections.values[modifiedRulesetFullQualName] := '1'
		else
			lFoldedSections.values[modifiedRulesetFullQualName] := '';
		end;
	
	// Action: Open Ini
	if action = 'OPEN_INI_FILE' then begin
		startEditor(modifiedRulesetFullQualName);
		Exit;
		end;
	
	// Clean ruleset for redraw
	tmpStr := PregReplace('[^a-zA-Z0-9_]','_',modifiedRulesetFullQualName);
	if Assigned(tMainContent) then
		if Assigned( tMainContent.FindComponent('ruleset_'+tmpStr) ) then
			//tMainContent.FindComponent('ruleset_'+tmpStr).Name := '';
				tMainContent.FindComponent('ruleset_'+tmpStr).Cursor := -17;
	
	_redrawMainLayout();
	
end;

{Prompt for EDID}
function _getFPanelForEdidAssistant(modifiedRulesetFullQualName:String):TPanel;
var
	fPanel: TPanel;
	fButton: TButton;
begin
	
	//fPanel := TPanel.Create(nil);
	fPanel := efStartPanel(nil,400,0,200,0);
	fPanel.BevelWidth := 0;
	fPanel.BorderWidth := 0;
	efPadding(10,10);
	fButton := TButton.Create(fPanel);
	fButton.Parent := fPanel;
	fButton.Caption := 'Select EDID';
	fButton.Width := 200;
	fButton.Height := 30;
	fButton.OnClick := _eventOpenEdidSelectionAssistant;
	fButton.HelpKeyword := modifiedRulesetFullQualName; // Needed just for selection simplification
	fPanel.Height := efTop + 10 + 20;
	efEndSub();
	//efStartPanel
	//fPanel
	Result := fPanel;
	// 
end;

{Event: Show EDID Assistant}
procedure _eventOpenEdidSelectionAssistant(Sender: TObject);
var 
	tmpStr: String;
begin
	tmpStr := openEdidSelectionAssistant(Sender.HelpKeyword);
	if tmpStr <> '' then begin
		WindowPromptSetInputValue(tmpStr);
		end;
end;

function openEdidSelectionAssistant(rulesetFullQualName:String):String;
var 
	tmpStr: String;
	tmpLst: TStringList;
	selectedFile, selectedRecordType: String;
begin
	if rulesetFullQualName <> '' then begin 
		tmpLst := Split('>', rulesetFullQualName);
		
		if tmpLst.Count = 2 then begin
			if tmpLst[1] <> '' then 
				selectedRecordType := tmpLst[1];
			tmpStr := '';
			if not BeginsWithExtract(RULESETS_IDENTIFIER_MOD_RULES,tmpLst[0], tmpStr) then
				BeginsWithExtract(RULESETS_IDENTIFIER_USER_MOD_RULES,tmpLst[0], tmpStr);
			if tmpStr <> '' then 
				selectedFile := crsModBaseNameToFullName.Values[tmpStr];
			end;
		tmpLst.Free;
		end;
	Result := ShowFormEDIDSelection(selectedFile,selectedRecordType);
end;


{Prompt for TagIdent selection}
function _winSelectTagIdent(const isPrefilter:Boolean; preSelected:String;var sResult:String):Boolean;
var
	tmpLst: TStringList;
	iSel: Integer;
	tmpStr: String;
begin
	tmpLst := TStringList.Create;
	if isPrefilter then begin
		tmpLst.add('IGNORE=Drop record - No further processing.');
		tmpLst.add('KEEP=Keep record. Will be further processed.');
		end
	else begin
		tmpLst.CommaText := tagNames.CommaText;

		tmpLst.add('title=Special TagIdent''s');
		tmpLst.add('=Abort ruleset');
		//tmpLst.add('SPECIAL:DeleteEndTag=Delete {{{endtags}}} from records name');
		//tmpLst.add('SPECIAL:AddComponentTags=Adds e.g. {{{Metal, Wood}}} at the end of the records name.');
		tmpLst.add('SPECIAL:FindCustomTag:[NamingRuleSet]=Start sub-call in naming rules.');
		tmpLst.add('SPECIAL:AddKeyword:[Keyword]=Add a keyword to the record');
		tmpLst.add('SPECIAL:RemoveINRD=Removes the INRD entry from the record.');
		end;
	if tmpLst.indexOfName(preSelected) > -1 then
		preSelected := tmpLst.Strings[tmpLst.indexOfName(preSelected)];
	Result := false;
	iSel := FormSimpleSelection.show('Select TagIdent', 'Select target TagIdent',tmpLst, preSelected);
	if iSel > -1 then begin
		sResult := tmpLst.Names[iSel];
		if sResult = 'SPECIAL:AddKeyword:[Keyword]' then begin
			if WindowPrompt('Keyword', 'Enter the keyword to add:',tmpStr,nil) then begin
				Result := true;
				sResult := StringReplace(sResult,'[Keyword]',tmpStr,[rfReplaceAll]);
				end;
			end
		else if sResult = 'SPECIAL:FindCustomTag:[NamingRuleSet]' then begin
			if WindowPrompt('NamingRuleSet', 'Enter naming ruleset:',tmpStr,nil) then begin
				Result := true;
				sResult := StringReplace(sResult,'[NamingRuleSet]',tmpStr,[rfReplaceAll]);
				end;
			end
		else			
			Result := true;
		end;
	tmpLst.Free;
end;

{Prompts for a new conditon}
function _winPromptNewCondition(fullRule, isPrefilter:Boolean):String;
var
	iSel: Integer;
	aMenuLst, aPresetsLst: TStringList;
begin
	aMenuLst := TStringList.Create;
	aPresetsLst := TStringList.Create;
	
	{aMenuLst.add('Rule with 1 parameter=Empty rule');
	aPresetsLst.add('""');

	aMenuLst.add('Rule with 2 parameters=Empty rule');
	aPresetsLst.add('"" ""');

	aMenuLst.add('Rule with 3 parameters=Empty rule');
	aPresetsLst.add('"" "" ""');}

	aMenuLst.add('title=Use Assistants');
	aPresetsLst.add('');
	aMenuLst.add('Rule Assistant=Create with new rule assistant');
	aPresetsLst.add('ASSISTANT');
	aMenuLst.add('Simple Item Tag=Tag one item directly (via EditorId)');
	aPresetsLst.add('ASSISTANT_SIMPLE_TAG');


	aMenuLst.add('title=Common presets');
	aPresetsLst.add('');
	
	aMenuLst.add('Full name=Matches a item by it''s name as it is visible in game');
	aPresetsLst.add('"FULL - Name" contains "Item name"');
	aMenuLst.add('EditorID=Matches a specific item by its EditorID');
	aPresetsLst.add('EDID equals "New compare value"');
	aMenuLst.add('Keyword=Matches a item by one or more keywords');
	aPresetsLst.add('KEYWORDS contains "Keyword"');
	aMenuLst.add('Field exists=Checks if a field exists');
	aPresetsLst.add('"CVPA - Components" exists');
	aMenuLst.add('Effect=Match by item effect');
	aPresetsLst.add('EFFECTS contains RestoreHealthFood');
	aMenuLst.add('Body slot=Match by used body item slot');
	aPresetsLst.add('BP hasFlag "47 - Eyes"');
	aMenuLst.add('Apply always=Apply always');
	aPresetsLst.add('*');
	iSel := FormSimpleSelection.show('Create new rule','Choose a rule preset. What do you want the rule to match?',aMenuLst,'');
	if iSel > -1 then
		Result := aPresetsLst[iSel];
	if Result = 'ASSISTANT' then
		Result := _winRuleAssistant(fullRule, isPrefilter,'');
	if Result = 'ASSISTANT_SIMPLE_TAG' then
		Result := _winRuleAssistant(fullRule, isPrefilter,'ASSISTANT_SIMPLE_TAG');
	aMenuLst.Free;
	aPresetsLst.Free;
end;


{Shows input for record field selection}
function _winShowRecElementInput(var sElmIdent:String):Boolean;
var
	i: Integer;
	tmpLst: TStringList;
	tlab: TLabel;
	fPresetsPanel: TPanel;
begin
	// Create preset panel for element field
	fPresetsPanel := efStartPanel(frm2,20,0,960,0);
	efPadding(10,10);
	tlab := efLabel('Commonly used',0,0,0,0,efTopAddHeight);
	efApplyLabelColor(tlab, clGray);
	tmpLst := TStringList.Create;
	tmpLst.add('*');
	tmpLst.add('EDID');
	tmpLst.add('FULL - Name');
	tmpLst.add('KEYWORDS');
	tmpLst.add('EFFECTS');
	tmpLst.add('PTRN');
	tmpLst.add('CVPA - Components');
	tmpLst.add('DATA - Data\Value');
	tmpLst.add('DATA - Data\Weight');
	tmpLst.add('_BREAK_');
	tmpLst.add('DNAM - Type');
	tmpLst.add('DNAM - Data\Animation Type');
	tmpLst.add('DNAM - Data\Flags');
	tmpLst.add('DNAM - Data\Value');
	tmpLst.add('DNAM - Data\Weight');
	tmpLst.add('_BREAK_');
	tmpLst.add('BOD2 - Biped Body Template\First Person Flags');
	tmpLst.add('BP:flagsCount');
	tmpLst.add('Model\MODL - Model Filename');
	tmpLst.add('INRD:link:EDID');
	tmpLst.add('_BREAK_');
	tmpLst.add('SPECIAL:IsArmor');
	tmpLst.add('SPECIAL:recordHasHumanRace');
	tmpLst.add('SPECIAL:MasterESP');
	// tmpLst.add('SPECIAL:PluginSetting:*');
	
	for i := 0 to tmpLst.Count -1 do begin
		if tmpLst[i] = '_BREAK_' then begin 
			efLeft := 10;
			efTopAdd(25);
			continue;
			end;
		tlab := efLabel('  '+tmpLst[i]+'  ',0,0,0,0,efLeftAddWidth+efAutoWidth);
		_linkAction(tlab,'SET_WIN_INPUT_VALUE',nil,0,Trim(tmpLst[i]));
		efLeftAdd( 10 );
		if efLeft > fPresetsPanel.Width then begin
			tlab.Left := 10;
			tlab.Top := tlab.Top + 25;
			efLeft := 10 + tlab.Width + 10;
			efTopAdd(25);
			end;
		end;
	tmpLst.Free;
	
	fPresetsPanel.Height := efTop + 10 + 20;
	efEndSub();
	
	// Record field
	Result := WindowPrompt('Record field', 'Specify the record field the rule should match. '+#10#13
		+ 'You can specify any possible record field by name or path.'+#10#13
		+ 'You can also use special match functions (e.g. SPECIAL:isArmor)', sElmIdent,fPresetsPanel);
end;

{Shows a nicely assistant for rule creation}
function _winRuleAssistant(fullRule, isPrefilter:Boolean; assistantType:String):String;
var
	i, iSel:Integer;
	tmpStr, sElmIdent, sCompareType, sCompareValue,sTagIdent, rule: String;
	tmpLst, lKnownStrings, lKnownNumbers: TStringList;
	isNumberMatch, isStringMatch: Boolean;
	tlab: TLabel;
	fPanel: TPanel;
begin
	try
	// Setup
	Result := '';
		
	if assistantType = 'ASSISTANT_SIMPLE_TAG' then 
		sElmIdent := 'EDID'
	else begin 
		// Step 1: Get Record field 
		sElmIdent := 'Record field';
		if not _winShowRecElementInput(sElmIdent) then
			Exit;
		end;
	
	rule := sElmIdent;
	if (Pos(' ', sElmIdent) <> 0) or (sElmIdent = '') then
		rule := getQuoted(sElmIdent);
	
	tmpLst := TStringList.Create;
	
	// Step 2: Compare type
	if (rule <> '*') and (Pos('SPECIAL:',sElmIdent) <> 1 ) then begin
		// select compare type
		if assistantType = 'ASSISTANT_SIMPLE_TAG' then 
			tmpLst.add('equals') // Just directly to this
		else if (sElmIdent = 'KEYWORDS') or (sElmIdent = 'EFFECTS') then
			tmpLst.add('contains')
		else if (Length(sElmIdent) > 4) and (Pos('Flags',sElmIdent) = (Length(sElmIdent) - 4))  then begin
			tmpLst.add('hasFlag');
			tmpLst.add('hasOnlyFlags');
			end
		else begin
			lKnownStrings := TStringList.Create();
			lKnownStrings.add('FULL - Name');
			lKnownStrings.add('EDID');
			lKnownStrings.add('PTRN');
			lKnownStrings.add('Model\MODL - Model Filename');
			lKnownStrings.add('INRD:link:EDID');
			lKnownStrings.add('DNAM - Data\Animation Type');
			lKnownNumbers := TStringList.Create();
			lKnownNumbers.add('INRD');
		
			isNumberMatch := lKnownNumbers.indexOf(sElmIdent) > -1;
			isStringMatch := lKnownStrings.indexOf(sElmIdent) > -1;
			if (not isNumberMatch) and (not isStringMatch) then begin
				if StrEndsWith(sElmIdent, '\Value') then
					isNumberMatch := true
				else if StrEndsWith(sElmIdent, '\Weight') then
					isNumberMatch := true;
				
				end;
				
			
			if not isNumberMatch then begin
				tmpLst.add('equals');
				tmpLst.add('contains');
				tmpLst.add('beginsWith');
				end;
			if not isStringMatch then begin
				tmpLst.add('numEquals');
				tmpLst.add('greaterThan');
				tmpLst.add('lessThan');
				end;
			tmpLst.add('exists');
		end;

		// Show selection
		if tmpLst.Count = 1 then
			sCompareType := tmpLst[0] // Only one there, take it directly			 
		else begin
			tmpLst.add('title=Negated');
			for i := 0 to tmpLst.Count - 2 do
				tmpLst.add('not '+tmpLst[i]);
			iSel := FormSimpleSelection.show('Compare type','Select the compare operation you like to perform on '+#10#13+#10#13+sElmIdent+'  [?]',tmpLst,'');
			if iSel > -1 then
				sCompareType := tmpLst[iSel]
			else Exit;
			end;
			
		if Pos('not ', sCompareType) = 1 then begin
			rule := 'not ' + rule;
			sCompareType := Copy(sCompareType,5,100);
			end;
		rule := rule + ' ' + sCompareType;
		
		// Step 3: Compare value
		if sCompareType <> 'exists' then begin
				
			// Compare value
			sCompareValue := 'Value';
			
			// Show Assistant for EDID
			fPanel := nil;
			
			if assistantType = 'ASSISTANT_SIMPLE_TAG' then begin
				if sNavCurrentRecordType <> '' then 
				tmpStr := openEdidSelectionAssistant(sNavCurrentMain+'>'+sNavCurrentRecordType)
				else tmpStr := openEdidSelectionAssistant(sNavCurrentMain+'>'+sNavCurrentSub);
				if tmpStr = '' then 
					Exit
				else sCompareValue := tmpStr;
				end
			else begin 
				if rule = 'EDID equals' then 
					if sNavCurrentRecordType <> '' then 
						fPanel := _getFPanelForEdidAssistant(sNavCurrentMain+'>'+sNavCurrentRecordType) // selectedMod>SelectedRecordType
					else fPanel := _getFPanelForEdidAssistant(sNavCurrentMain+'>'+sNavCurrentSub);
				
				if not WindowPrompt('Compare value', 'Specify the value which must be matched. '+#10#13+#10#13+sElmIdent+'  '+sCompareType+'  "[?]"'
					+ '', sCompareValue,fPanel) then
					Exit;
				end;
			if Pos(' ', sCompareValue) <> 0 then
				rule := rule + ' ' + getQuoted(sCompareValue)
			else
				rule := rule + ' ' + sCompareValue;
				
			end;
		end;
	
	// Step 4: TagIdent
	if fullRule then begin
		if _winSelectTagIdent(isPrefilter, '', sTagIdent) then begin
			rule := rule + ' = ' + sTagIdent;
			Result := rule;
			end;
		end;
	
	Result := rule;
	
	finally
		FreeAndNil(tmpLst);
		FreeAndNil(lKnownStrings);
		FreeAndNil(lKnownNumbers);
	end;
end;


{Event: Mouseover over a linked button or link label}
procedure _eventLabelOnMouseEnter(Sender: TObject);
var
	prevWidth: Integer;
	style, hex: String;
begin
	if Pos('|', Sender.HelpKeyword) > 0 then
		style := Copy(Sender.HelpKeyword,0,Pos('|',Sender.HelpKeyword)-1);
	
	prevWidth := Sender.Width;
    //Sender.Font.Color := clBlue;
	if style = 'link' then begin
		lastTLabelPrevColor := Sender.Font.Color;
		efApplyLabelColor(Sender,clBlue);
		efApplyLabelStyle(Sender,[fsUnderline]);
		end
	else begin
		if Sender.Transparent then begin
			lastTLabelPrevColor := -1;
			Sender.Color := CELL_HIGHLIGHT_COLOR;
			//Sender.Color := SELECTION_BG_COLOR;
			// efApplyLabelColor(Sender,clWhite);
			end
		else begin
			lastTLabelPrevColor := Sender.Color;
			hex := IntToHex(Sender.Color,6);
			Sender.Color :=  min(255,HexToInt(Copy(hex,1,2))*1.1)*256*256
				+min(255,HexToInt(Copy(hex,3,2))*1.1)*256
				+min(255,HexToInt(Copy(hex,5,2))*1.1);
			end;
		Sender.Transparent := false;
		end;
	Sender.Width := prevWidth;
	if Pos('rule',Sender.Parent.Name) = 1 then
		_eventBGOnMouseEnter(Sender.Parent);
	//Sender.Font.Style := Sender.Font.Style + [fsUnderline];
end;


{Event: Mouseout}
procedure _eventLabelOnMouseLeave(Sender: TObject);
var
	prevWidth: Integer;
	style: String;
begin
	if Pos('|', Sender.HelpKeyword) > 0 then
		style := Copy(Sender.HelpKeyword,0,Pos('|',Sender.HelpKeyword)-1);
	prevWidth := Sender.Width;
    //Sender.Font.Color := clBlack;
	if style = 'link' then begin
		efApplyLabelColor(Sender,lastTLabelPrevColor);
		efApplyLabelStyle(Sender,0);
		end
	else begin
		Sender.Color := lastTLabelPrevColor;
		Sender.Transparent := lastTLabelPrevColor = -1;
		end;
	Sender.Width := prevWidth;
	if Pos('rule',Sender.Parent.Name) = 1 then
		_eventBGOnMouseLeave(Sender.Parent);
	//Sender.Font.Style := Sender.Font.Style - [fsUnderline];
end;


{Event: Mouseover}
procedure _eventBGOnMouseLeave(Sender: TObject);
begin
	if Sender.Name = 'bg' then
		_eventBGOnMouseRestore();
	if Assigned(Sender.FindComponent('bg')) then
		_eventBGOnMouseLeave(Sender.FindComponent('bg'));
end;

{Event: Mouseout}
procedure _eventBGOnMouseEnter(Sender: TObject);
begin
	
	if Sender.Name = 'bg' then begin
		_eventBGOnMouseRestore();
		lastBGTLabelPrevColor := Sender.Color;
		lastBGTLabelPrevElm := Sender;
		Sender.Color := TABLE_HOVER_ROW_BG_COLOR;//$D5D5D5;
		
		end;
	if Assigned(Sender.FindComponent('bg')) then
		_eventBGOnMouseEnter(Sender.FindComponent('bg'));
end;

{Helper restores the bg color}
procedure _eventBGOnMouseRestore();
begin
	if Assigned(lastBGTLabelPrevElm) then
		lastBGTLabelPrevElm.Color := lastBGTLabelPrevColor;
	lastBGTLabelPrevElm := nil;
end;

{Event: Drag some item over another item}
procedure _eventOnDragOver(Sender: TObject;Source: TObject;X: Integer;Y: Integer;State: TDragState;var Accept: Boolean);
begin
	Accept := (Pos(TEXT_RULE_PREFIX,Sender.Text)>0) and (Sender <> Source)
		and (Sender.parent.parent = Source.parent.parent);
		//if Sender.parent.parent = Source.parent.parent then
	if Assigned(lastMarkedDragTarget) then begin
		lastMarkedDragTarget.Transparent := true;
		lastMarkedDragTarget := nil;
		end;
		
	If Accept then begin
		Sender.Color := $CCCCCC;
		Sender.Transparent := false;
		lastMarkedDragTarget := Sender;
		end;
end;

procedure _eventOnDragStart( Sender: TObject; var DragObject: TDragObject);
begin
	lastMarkedDragTarget := nil;
	Sender.Color := $AACCFF;
	Sender.Transparent := false;
	Sender.OnMouseEnter := nil;
	Sender.OnMouseLeave := nil;
end;

procedure _eventOnDragEnd(Sender: TObject;Target: TObject;X: Integer;Y: Integer);
begin
	
	if Assigned(lastMarkedDragTarget) then begin
		lastMarkedDragTarget.Transparent := true;
		lastMarkedDragTarget := nil;
		end;
	Sender.Transparent := true;
	Sender.OnMouseEnter := _eventLabelOnMouseEnter;
	Sender.OnMouseLeave := _eventLabelOnMouseLeave;
end;

procedure _eventOnDragDrop( Sender: TObject;Source: TObject; X: Integer; Y: Integer);
var fromIndex, toIndex:Integer;
	var tmpLst,storedObject: TStringList;
begin
	//try
	
		if (Pos(TEXT_RULE_PREFIX,Source.Text)>0) and (Pos(TEXT_RULE_PREFIX,Sender.Text)>0) then begin
			fromIndex := StrToInt(Copy(Source.Text,Pos(TEXT_RULE_PREFIX,Source.Text)+LENGTH(TEXT_RULE_PREFIX),10));
			toIndex := StrToInt(Copy(Sender.Text,Pos(TEXT_RULE_PREFIX,Sender.Text)+LENGTH(TEXT_RULE_PREFIX),10));
			if ( fromIndex > 0 ) and ( toIndex > 0 ) then begin
				fromIndex := fromIndex - 1;
				toIndex := toIndex - 1;
				tmpLst := TStringList.Create;
				tmpLst.CommaText := Source.HelpKeyword;
				storedObject := explEditElmsList.Objects[StrToInt(tmpLst[1])];
				tmpLst.Free;
				storedObject.Move(fromIndex,toIndex);
				// Invalidate ruleset
				Sender.parent.parent.parent.Cursor := -17;
				
				end;
			end;
	//except
	//end;
	
	_redrawMainLayout();
end;

procedure _eventChangeShowEmptyRules(Sender:TObject);
begin
	flagShowEmptyRules := not flagShowEmptyRules;
	_redrawMainLayout();
end;
procedure _eventChangeShowHelp(Sender:TObject);
begin
	flagShowHelp := not flagShowHelp;
	_redrawMainLayout();
end;


{Event: (Re)loading rules}
procedure _eventLoad();
begin
	CustomRuleSets.init();
	// Drop all cached rules lists and redraw
	_forceRedrawRulesets();
	_redrawMainLayout();
end;


{Forces the refresh of all rulesets}
procedure _forceRedrawRulesets;
var 
	i: Integer;
begin
	if Assigned(tMainContent) then
		for i := 0 to tMainContent.ComponentCount -1 do 
			if Pos('ruleset_', tMainContent.Components[i].Name) = 1 then 
				tMainContent.Components[i].Cursor := -17;
end;

{Event: Saving rules}
procedure _eventSave();
var
	i,j,k:Integer;
	isNewFile: Boolean;
	targetFile, rulesetFullQualName, rsMainIdent, rsSubIdent, ruleApplyTag, conditionString,
		fileBaseName, fileDirBaseName, backupFilePath: String;
	ini: TIniFile;
	tmpLst, customRuleSet, conditionPacks, conditionPack: TStringList;
begin
	
	isNewFile := false;
	for i := crsModifiedRuleSets.Count -1 downto 0 do begin
		rulesetFullQualName := crsModifiedRuleSets.Names[i];
		tmpLst := Split('>',rulesetFullQualName);
		rsMainIdent := tmpLst[0];
		rsSubIdent := tmpLst[1];
		tmpLst.Free;
		// Sure?
		if (Pos(RULESETS_IDENTIFIER_MAIN_RULES,rsMainIdent) = 1)
			or (Pos(RULESETS_IDENTIFIER_MOD_RULES,rsMainIdent) = 1) then begin
				if not WindowConfirm('Modify MAIN rules','Are you sure you want to modify the MAIN rule file?'
					+#10#13+'It is recommended to only use the USER rules. Those won''t get overwritten by an update and also always have higher priority.') then
					continue;
			end;
		
		targetFile := crsRuleSetIniFiles.values[rsMainIdent];
		if targetFile = '' then begin
			if rsMainIdent = RULESETS_IDENTIFIER_USER_RULES then
				targetFile := sComplexSorterBasePath+'Rules (User)\rules-processing.ini'
			else if Pos(RULESETS_IDENTIFIER_USER_MOD_RULES, rsMainIdent) = 1 then
				targetFile := sComplexSorterBasePath+'Rules (User)\'+Copy(rsMainIdent,Length(RULESETS_IDENTIFIER_USER_MOD_RULES)+1,300)+'.ini';
			if targetFile = '' then begin
				ShowMessage('Can''t determine target file for '+rsMainIdent+'>'+rsSubIdent+'... Please create the file manually first.');
				end;
			isNewFile := true;
			end;
		
		fileBaseName := ExtractFileName(targetFile);
		fileDirBaseName := ExtractFileName(ExtractFileDir(targetFile));
		backupFilePath := DateTimeToStr(Now)+'-'+fileDirBaseName+'-' + fileBaseName;
		// Sanitazion of filename
		backupFilePath := PregReplace('[^a-zA-Z0-9_\.\(\)]','-',backupFilePath);
		backupFilePath := sComplexSorterBasePath + 'Backup\'+backupFilePath;
		// Create backup folder if not exists (FileExist not working on WIN)
		CreateDir(sComplexSorterBasePath+'Backup');
		if not isNewFile then
			if not CopyFile(targetFile, backupFilePath,false) then begin
				if not WindowConfirm('Backup not possible','Could not write backup to: "'+backupFilePath+'". '+#10#13
					+'Save the file without backup?') then
					Exit;
				end;
		ini := TIniFile.Create(targetFile);
		
		// Clear section
		tmpLst := TStringList.Create;
		ini.ReadSection(rsSubIdent,tmpLst);
		for j := 0 to tmpLst.Count -1 do
			ini.DeleteKey(rsSubIdent,tmpLst[j]);
		tmpLst.Free;
		
		// Write new rules
		customRuleSet := CustomRuleSets.getProcessingRuleSetSection({taskIdent}'',rsMainIdent,rsSubIdent);
			
		for j:= 0 to customRuleSet.Count - 1 do begin
			conditionPacks  := customRuleSet.Objects[j];
			ruleApplyTag    := customRuleSet.Strings[j];
			conditionString := '';
			
			for k := 0 to conditionPacks.Count - 1 do begin
				conditionPack := conditionPacks.Objects[k];
				if k > 0 then
					conditionString := conditionString + ',';
				
				if conditionPack.Strings[CONDITION_PACK_INDEX_STR_IS_NOT_MATCHSTR] = 'False' then
					conditionString := conditionString + 'not ';
				tmpLst := TStringList.Create;
				tmpLst.CommaText := conditionPack.Objects[CONDITION_PACK_INDEX_OBJ_PARSED_RULES].CommaText;
				tmpLst.Delimiter := ' ';
				conditionString  := conditionString + tmpLst.DelimitedText;
				tmpLst.Free;
				end;
			ini.WriteString(rsSubIdent, conditionString, ruleApplyTag);
			end;
			
		ini.UpdateFile();
		ini.Free;
		crsModifiedRuleSets.delete(i);
		end;

	// Drop all cached rules lists and redraw
	_forceRedrawRulesets();
	_redrawMainLayout();
		
end;



end.