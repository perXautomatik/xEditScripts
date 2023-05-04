{
	M8r98a4f2s Complex Item Sorter for FallUI - GUI module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Part of the GUI.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit FormSimpleSelection;

var
	// Private
	_gui_fss_scrollbox: TScrollBox;
	_gui_fss_options: TStringList;
	_gui_fss_entries: TStringList;
	_gui_fss_flagSpecialView: Boolean;
	_gui_fss_flagUpdateInProgress: Boolean;
	_gui_fss_preSelected: String;
	_gui_fss_lastSearch: String;
	_gui_fss_formType: String;
	_gui_fss_preSelectedList: TStringList;
	_gui_fss_maxLeftColWidth,_gui_fss_maxRightColWidth: Integer;
	_frmSimpleSel:TForm;
	

implementation

{Shows a simple selection form with multiple single choice buttons }
function show(title,text:String;options:TStringList;preSelected:String):Integer;
begin
	Result := _showMultiple('buttons',title,text,options,preSelected,nil,nil);
end;

{Shows a form with multiple checkboxes}
function showCheckboxes(title,text:String;options:TStringList;preSelectedList, descriptionsList:TStringList):Boolean;
begin
	if _showMultiple('checkboxes',title,text,options,'',preSelectedList,descriptionsList) = 1 then 
		Result := true;
end;

{Displays a simple selection window for multiple options and cancel button}
function _showMultiple(const formType, const title,const text:String;options:TStringList;preSelected:String;preSelectedList,descriptionsList:TStringList):Integer;
var
	i, tmpInt, iFrom, iTo: Integer;
	modalResult : Integer;
	tButton : TButton;
	tlab: TLabel;
	searchEdit,fRangeFrom,fRangeTo: TEdit;
	entry, tmpLst: TStringList;
begin
	try
		fRangeFrom := nil;
		fRangeTo := nil;
		_gui_fss_formType := formType;
		_gui_fss_flagSpecialView := Pos('TagIdent',title) > 0;
		_gui_fss_options := options;
		_gui_fss_entries := TStringList.Create;
		_gui_fss_preSelected := preSelected;
		if Assigned(preSelectedList) then begin
			_gui_fss_preSelectedList := THashedStringList.Create;
			_gui_fss_preSelectedList.CommaText := preSelectedList.CommaText;
			end;
		// Special view with right text?
		if options.Count > 1 then
			if (Pos('=',options[0]) > 0) and (Pos('=',options[1]) > 0) then
				_gui_fss_flagSpecialView := true;
				
		// Setup
		_frmSimpleSel := efStartForm(nil,320,320,title);
		_gui_fss_maxLeftColWidth := 0;
		_gui_fss_maxRightColWidth := 0;
		if ( formType = 'buttons' ) then
			if not _gui_fss_flagSpecialView then
				_gui_fss_maxLeftColWidth := 240
			else
				_gui_fss_maxLeftColWidth := 150;
				
		
		
		// Preprocess entries and find texts width
		if _gui_fss_options.Count > 0 then
			for i := 0 to _gui_fss_options.Count -1 do begin
				entry := TStringList.Create;
				_gui_fss_entries.addObject('entry'+IntToStr(i),entry);
				if _gui_fss_flagSpecialView then
					entry.Values['key'] := _gui_fss_options.Names[i]
				else 
					entry.Values['key'] := _gui_fss_options[i];
				
				if ( formType = 'buttons' ) then begin 
					entry.Values['text'] := entry.Values['key'];
					if _gui_fss_flagSpecialView then
						entry.Values['textRight'] := _gui_fss_options.ValueFromIndex[i];
					end;
					
				if ( formType = 'checkboxes' ) then begin
					if _gui_fss_options.ValueFromIndex[i] <> '' then 
						entry.Values['text'] := _gui_fss_options.ValueFromIndex[i]
					else 
						entry.Values['text'] := entry.Values['key'];
					if Assigned(descriptionsList) then
						entry.Values['textRight'] := descriptionsList.Values[entry.Values['key']];
					end;
				
				// measure text widths
				
				tlab := TLabel.Create(_frmSimpleSel);
				tlab.Text := entry.Values['text'];
				_gui_fss_maxLeftColWidth := Max(_gui_fss_maxLeftColWidth, tlab.Width + 30);
				tlab.Free;
				
				if entry.Values['textRight'] <> '' then begin					
					tlab := TLabel.Create(_frmSimpleSel);
					tlab.Text := entry.Values['textRight'];
					_gui_fss_maxRightColWidth := Max(_gui_fss_maxRightColWidth, tlab.Width + 20);
					tlab.Free;
					end;
				end;
				
		// Min sizes
		if ( formType = 'checkboxes' ) then 
			_gui_fss_maxLeftColWidth := Max(_gui_fss_maxLeftColWidth,240 - ( _gui_fss_maxRightColWidth));
		
		// Determine form size
		_frmSimpleSel.Width := 50 +20 + _gui_fss_maxLeftColWidth;
		if _gui_fss_maxRightColWidth > 0 then 
			_frmSimpleSel.Width := _frmSimpleSel.Width + 20 + _gui_fss_maxRightColWidth;
		
		efPadding(25,25);

		AutoForm_StartSub(_frmSimpleSel, _frmSimpleSel);
		AutoForm_setForm(_frmSimpleSel);
		AutoForm_SetAutoPos(10, 20);

		// Add content text
		if text <> '' then begin 
			tlab := efLabel(text,0,0,0,0,efAutoHeight+efTopAddHeight);
			AutoForm_AddAutoTop(efTop+10);
			end;

		// Add search box
		if options.count > 20 then begin 
			tlab := efLabel('Search:',0,10,0,0,efAutoWidth);
			
			searchEdit := ConstructEdit(efOwner, efParent, efTop+10, tlab.Left+tlab.Width+6, 20, 240 , '', '');
			efApplyLabelColor(tlab, clGray);
			searchEdit.TextHint := 'Search';
			searchEdit.OnKeyUp := _ShowFormSSEventsearchKeyPress;
			searchEdit.TabOrder := 0;
			_frmSimpleSel.ActiveControl  := searchEdit;
			AutoForm_AddAutoTop(30);
			efTop := efTop + 30;
			end;

		// Add all/none
		if formType = 'checkboxes' then begin 
			
			if title = 'Record types' then begin
				AutoForm_AddButton(AutoForm_getAutoTop()-10,35,30,80, 101, _('All') );
				AutoForm_AddButton(AutoForm_getAutoTop()-10,125,30,80, 103, _('Standard') );
				AutoForm_AddButton(AutoForm_getAutoTop()-10,215,30,80, 102, _('None') );
				end
			else begin
				tmpInt := 0;
				if options.count > 20 then begin 
					fRangeFrom := ConstructEdit(efOwner, efParent, efTop+10+3, 20, 20, 40 , '', '');
					fRangeFrom.Text := 1;
					fRangeTo := ConstructEdit(efOwner, efParent, efTop+10+3, 20+40+10, 20, 40 , '', '');
					fRangeTo.Text := options.count;
					fRangeFrom.ShowHint := true;
					fRangeFrom.Hint := 'Set the range where the all/none buttons will be applied';
					fRangeTo.ShowHint := true;
					fRangeTo.Hint := 'Set the range where the all/none buttons will be applied';
					efLabel('-',20+18,15,0,0,efAutoWidth);
					efLabel(':',20+40+10+15,15,0,0,efAutoWidth);
					tmpInt := 60;
					end;
				AutoForm_AddButton(AutoForm_getAutoTop()-10,65 + tmpInt,30,80, 101, _('All') );
				AutoForm_AddButton(AutoForm_getAutoTop()-10,155 + tmpInt,30,80, 102, _('None') );
				end;
			AutoForm_AddAutoTop(30);
			end;
			
		// Entries
		_gui_fss_scrollbox := AutoForm_SetupScrollBox();
		_gui_fss_scrollbox.Align := alNone;
		_gui_fss_scrollbox.Top := AutoForm_GetAutoTop;
		_gui_fss_scrollbox.Width := _frmSimpleSel.Width-5;
		_updateEntries('');
		frm := _frmSimpleSel;
		_gui_fss_scrollbox.Height := AutoForm_GetAutoTop + 5;
		
		// Scrollable?
		if _gui_fss_scrollbox.Height > 500 then begin
			_gui_fss_scrollbox.Height := 500;
			_gui_fss_scrollbox.Left := -2;
			_gui_fss_scrollbox.Width := _gui_fss_scrollbox.Width + 2;
			end
		else begin
			_gui_fss_scrollbox.BevelWidth := 0;
			_gui_fss_scrollbox.BorderStyle := bsNone;
			end;
		
		AutoForm_SetAutoPos(_gui_fss_scrollbox.Top + _gui_fss_scrollbox.Height + 20,nil);
					
		panel := _frmSimpleSel;
		efEndSub();
		
		// Cancel button 
		tButton := AutoForm_AddButton(AutoForm_getAutoTop(),30,50,240, mrCancel, #9747+' '+_('Cancel') );
		tButton.Cancel := true;
		tButton.Left := (_frmSimpleSel.Width - tButton.Width -10) / 2;
		tButton.tabOrder := 0;
		
		// OK Button
		if _gui_fss_formType = 'checkboxes' then begin 
			tButton.Width := 120;
			tButton.Left := (_frmSimpleSel.Width - (tButton.Width*2 + 30) - 10) / 2 + tButton.Width + 30;
			tButton := AutoForm_AddButton(AutoForm_getAutoTop(),30,50,240, mrOk, #10003+' '+_('Ok') );
			tButton.Width := 120;
			tButton.Left := (_frmSimpleSel.Width - (tButton.Width*2 + 30) - 10) / 2;
			tButton.tabOrder := 0;			
			end;
		
		// Final height
		_frmSimpleSel.Height := AutoForm_getAutoTop() + 100;
		
		// Show form
		Result := -1;
		modalResult := -1;
		while (modalResult <> mrOk) and (modalResult <> mrCancel) do begin
			modalResult := _frmSimpleSel.ShowModal();
			// Result for mode buttons
			if _gui_fss_formType = 'buttons' then 
				if (modalResult >= 200) then begin
					Result := modalResult - 200;
					modalResult := mrOk;
					Exit;
					end;
			// Result for mode checkboxes
			if _gui_fss_formType = 'checkboxes' then begin 
				// Select all/none 
				if ( modalResult = 101 ) or ( modalResult = 102 ) then begin
					iFrom := 0;
					iTo := _gui_fss_options.Count -1;
					if Assigned(fRangeFrom) then begin
						iFrom := max(iFrom, StrToInt(fRangeFrom.Text) - 1);
						iTo := min(iTo, StrToInt(fRangeTo.Text) - 1);
						end;
					for i := iFrom to iTo do 
						_gui_fss_scrollbox.FindComponent('frmChk_Opt'+IntToStr(i)).Checked := ( modalResult = 101 );
					end;
				// Special: Default record types
				if ( modalResult = 103 ) then begin
					tmpLst := TStringList.Create;
					tmpLst.CommaText := helper.getDefaultRecordsString();
					for i := 0 to _gui_fss_options.Count -1 do 
						_gui_fss_scrollbox.FindComponent('frmChk_Opt'+IntToStr(i)).Checked 
							:= tmpLst.indexOf(_gui_fss_scrollbox.FindComponent('frmChk_Opt'+IntToStr(i)).HelpKeyword) > -1;
					tmpLst.Free;
					end;

				// Ok
				if modalResult = mrOk then begin
					preSelectedList.Clear();
					Result := 1;
					for i := 0 to _gui_fss_options.Count -1 do 
						if _gui_fss_scrollbox.FindComponent('frmChk_Opt'+IntToStr(i)).Checked then 
							preSelectedList.append(_gui_fss_scrollbox.FindComponent('frmChk_Opt'+IntToStr(i)).HelpKeyword);
					Exit;
					end;
				end
			end;
	finally
		AutoForm_EndForm();
		AutoForm_EndSub();
		_frmSimpleSel.Free;
		efEndSub();
		for i:= 0 to _gui_fss_entries.Count -1 do 
			_gui_fss_entries.Objects[i].Free;
		_gui_fss_entries.Free;
	end;
end;


{Draws and updates the entries for selection}
procedure _updateEntries(searchString:String);
var 
	tButton : TButton;
	tlab: TLabel;
	i, lastScrollTop, posY, entryHeight: Integer;
	freeMes, entry: TStringList;
begin
	_gui_fss_lastSearch := searchString;
	// Prevent pointe exceptions with multiple events
	if _gui_fss_flagUpdateInProgress then 
		Exit;
	_gui_fss_flagUpdateInProgress := true;

	// Disable form
	_frmSimpleSel.DisableAlign();
	_frmSimpleSel.Enabled := false;
	_frmSimpleSel.Cursor := -11; // Busy
	lastScrollTop := _gui_fss_scrollbox.VertScrollBar.Position;
	_gui_fss_scrollbox.Visible := false;
	_gui_fss_scrollbox.VertScrollBar.Position := 0;
	
	// Clear all
	freeMes := TStringList.Create;
	for i := _gui_fss_scrollbox.ComponentCount - 1  downto 0 do 
		freeMes.addObject('obj', _gui_fss_scrollbox.Components[i]);
	
	// Setup
	frm := _gui_fss_scrollbox;
	panel := _gui_fss_scrollbox;
	AutoForm_SetAutoPos(25,nil);
	efStartSub(_gui_fss_scrollbox,_gui_fss_scrollbox);
	efPadding(25,25);
	
	// For each option 
	posY := 10;
	for i := 0 to _gui_fss_options.Count -1 do begin

		entry := _gui_fss_entries.Objects[i];
			
		AutoForm_SetAutoPos(posY,nil);
				
		// Special: Inline-Title
		if _gui_fss_options.Names[i] = 'title' then begin
			AutoForm_AddAutoTop(10);
			tlab := AutoForm_AddLabel(_gui_fss_options.ValueFromIndex[i],20);
			tlab.font.Style := [fsBold];
			entryHeight := 30;
			posY := posY + entryHeight;	
			Continue;
			end;
			
		// Add the choice 
		if _gui_fss_formType = 'checkboxes' then begin 
			tButton := _gui_fss_scrollbox.FindComponent('frmChk_Opt'+IntToStr(i));
			if Assigned(tButton) then 
				freeMes.delete(freeMes.indexOfObject(tButton))
			else begin
				tButton := AutoForm_AddCheckbox(entry.Values['text'],false,'' );
				tButton.Width := _gui_fss_maxLeftColWidth;
				tButton.name := 'frmChk_Opt'+IntToStr(i);
				tButton.HelpKeyword := entry.Values['key'];
				end;
			tButton.Top := posY;
			entryHeight := 25;
			if Assigned(_gui_fss_preSelectedList) then 
				tButton.Checked := _gui_fss_preSelectedList.indexOf(entry.Values['key']) > -1;
			end
		else if _gui_fss_formType = 'buttons' then begin 
			tButton := AutoForm_AddButton(AutoForm_getAutoTop(),30,25,_gui_fss_maxLeftColWidth, 200+i,entry.Values['text'] );
			// Special: One-Button = big
			if _gui_fss_options.Count = 1 then
				tButton.Height := 50;

			// Mark selected
			if ( _gui_fss_preSelected = entry.Values['key'] ) then
				tButton.Font.Style := [fsBold];
			tButton.Top := posY;
			entryHeight := tButton.Height + 5;
			end;

		// Consider search
		if searchString <> '' then 
			if Pos(LowerCase(searchString),LowerCase(_gui_fss_options[i])) = 0 then begin
				tButton.visible := false;
				continue;
				end;
		tButton.visible := true;
			
			
		// Special view: Add description text to the right
		if entry.Values['textRight'] <> '' then begin
			if _gui_fss_flagSpecialView then begin
				if tButton.Caption = '' then begin
					tButton.Top := tButton.Top + 15;
					posY := posY + 15;
					AutoForm_SetAutoPos(posY,nil);
					end;
				tButton.Height := 25;
				end;
			efTop := PosY;
			tlab := efLabel(entry.Values['textRight'],_gui_fss_maxLeftColWidth+20,0,0,16,efAutoWidth);
			if _gui_fss_formType = 'buttons' then 
				tlab.Top :=  tlab.Top + 3;
			end;
			
		posY := posY + entryHeight;	
		
	end;

	// Add some space to bottom
	AutoForm_SetAutoPos(posY,nil);
	AutoForm_AddLabel(' ',10);

	// Cleanup
	panel := _gui_fss_scrollbox;
	if Assigned(_gui_fss_preSelectedList) then
		FreeAndNil(_gui_fss_preSelectedList);
	
	// Free old now (prevents flickering)
	for i := freeMes.Count - 1  downto 0 do 
		freeMes.Objects[i].Free;
	freeMes.Free;
	
	// Adjust position again
	_gui_fss_scrollbox.VertScrollBar.Position := lastScrollTop;
	
	// Enable form again
	_frmSimpleSel.EnableAlign();
	_frmSimpleSel.Enabled := true;
	_frmSimpleSel.Cursor := 0; // Default
	_gui_fss_scrollbox.Visible := true;
	_gui_fss_flagUpdateInProgress := false;
end;

{Event keypress on search}
procedure _ShowFormSSEventsearchKeyPress(Sender: TObject);
begin
	if _gui_fss_lastSearch <> Sender.Text then
		_updateEntries(Sender.Text);
end;

// procedure _ShowFormSS


procedure cleanup();
begin
end;

end.