{
	M8r98a4f2s Complex Item Sorter for FallUI - AutoForm
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Part of the GUI.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}
unit AutoForm;

const
	heightPerLine = 25;
	spaceBetweenLines = 10;
	AF_OPT_FULL_WIDTH = 1;
	AF_OPT_BOLD = 2;

var
	frm,
	panel: TForm;
	
	curAutoWidth,
	autoTop,
	autoLeft,
	optionGroupWidth,
	optionGroupPadding: Integer;
	
	// Private
	_afIsInited: Boolean;
	
	_afPreAutoGroupLeft,
	_afPreAutoGroupTop,
	_afSavedAutoTop,
	_afSavedAutoLeft: Integer;
	
	_afButtons: TStringList;
	
	_afCurAutoGroup: TGroupBox;
	
	_afAutoOptionKeys,
	_afSubStack,
	_afFormStack: TStringList;

implementation

procedure init();
begin
	if _afIsInited then
		Exit;
	_afSubStack := TStringList.Create;
	_afFormStack := TStringList.Create;
	_afIsInited := true;
end;

procedure AutoForm_StartSub(newFrm, newPanel:TObject);
begin
	init();
	_afSubStack.addObject('frmObj',frm);
	_afSubStack.addObject('panelObj',panel);
	_afSubStack.add(IntToStr(autoTop));
	_afSubStack.add(IntToStr(autoLeft));
	frm := newFrm;
	panel := newPanel;
end;

procedure AutoForm_EndSub();
begin
	
	autoLeft := StrToInt(_afSubStack[_afSubStack.Count-1]);
	_afSubStack.delete(_afSubStack.Count-1);
	autoTop := StrToInt(_afSubStack[_afSubStack.Count-1]);
	_afSubStack.delete(_afSubStack.Count-1);
	panel := _afSubStack.Objects[_afSubStack.Count-1];
	_afSubStack.delete(_afSubStack.Count-1);
	frm := _afSubStack.Objects[_afSubStack.Count-1];
	_afSubStack.delete(_afSubStack.Count-1);
end;

procedure AutoForm_setForm(setFrm:TForm);
begin
	init();
	// Save previous
	_afFormStack.addObject('buttons',_afButtons);
	//_afFormStack.add(IntToStr(curAutoOptionsSum));
	_afFormStack.addObject('obj',frm);
	_afFormStack.addObject('obj',panel);
	_afFormStack.addObject('obj',_afAutoOptionKeys);

	// New 
	frm := setFrm;
	panel := setFrm;
	if frm.BorderStyle <> bsDialog then begin
		frm.BorderStyle := bsDialog;	
		frm.Position := poScreenCenter;
		end;
	
	// Reset
	_afButtons := TStringList.Create;
	_afAutoOptionKeys := TStringList.Create
	
end;

procedure AutoForm_endForm;
begin
	FreeAndNil(_afAutoOptionKeys);
	FreeAndNil(_afButtons);
	
	// Restore previous
	_afAutoOptionKeys := _afFormStack.Objects[_afFormStack.Count-1];
	_afFormStack.delete(_afFormStack.Count-1);
	panel := _afFormStack.Objects[_afFormStack.Count-1];
	_afFormStack.delete(_afFormStack.Count-1);
	frm := _afFormStack.Objects[_afFormStack.Count-1];
	_afFormStack.delete(_afFormStack.Count-1);
	//curAutoOptionsSum := StrToInt(_afFormStack[_afFormStack.Count-1]);
	//_afFormStack.delete(_afFormStack.Count-1);
	_afButtons := _afFormStack.Objects[_afFormStack.Count-1];
	_afFormStack.delete(_afFormStack.Count-1);
	
end;

procedure AutoForm_SetAutoPos(setAutoTop, setAutoLeft: Integer);
begin
	if Assigned(setAutoTop) then
		if setAutoTop = -1 then
			autoTop := _afSavedAutoTop
		else autoTop := setAutoTop;
	if Assigned(setAutoLeft) then
		if setAutoLeft = -1 then
			autoLeft := _afSavedAutoLeft
		else autoLeft := setAutoLeft;
end;

procedure AutoForm_AddAutoTop(add:Integer);
begin
	AutoForm_SetAutoPos(AutoForm_GetAutoTop()+add, nil);
end;

function AutoForm_GetAutoTop:Integer;
begin
	Result := autoTop;
end;

function AutoForm_GetAutoLeft:Integer;
begin
	Result := autoLeft;
end;

procedure AutoForm_SaveAutoPos();
begin
	_afSavedAutoTop := autoTop;
	_afSavedAutoLeft := autoLeft;
end;

function AutoForm_AddLabel(title:String; height:Integer):TLabel;
begin
	Result := ConstructLabel(frm, panel, autoTop, autoLeft, height, frm.Width - autoLeft - 20, title, '');
	Result.font.size := Result.font.size * getSettingsFloat('config.fTextFontScale', 1.0);
	autoTop := autoTop + height{ + spaceBetweenLines};
	// Result.WordWrap := true;
	if curAutoWidth >0 then
		Result.Width := curAutoWidth;
end;

function AutoForm_AddCheckbox(title:String;checked:Boolean;hint:String):TCheckBox;
begin
    Result := ConstructCheckbox(frm, panel, autoTop, autoLeft, Length(title)*15{150}, title, cbChecked, hint);
	Result.font.size := Result.font.size * getSettingsFloat('config.fTextFontScale', 1.0);
	Result.Checked := checked;
	autoTop := autoTop + 15 + spaceBetweenLines;
	if curAutoWidth > 0 then
		Result.Width := curAutoWidth;
	
end;

function AutoForm_AddCheckboxAutoOption(optionKey, title:String):TCheckBox;
var 
	sName: String;
begin
	// Use old checkbox to prevent missing pointer error
	sName := 'AutoFormAutoOption_'+PregReplace('[^a-zA-Z0-9_]','',optionKey);
	Result := frm.FindComponent(sName);
	if not Assigned(Result) then begin
		Result := ConstructCheckbox(frm, panel, autoTop, autoLeft, Length(title)*15{150}, title, cbChecked, '');
		Result.Name := sName;
		Result.OnClick := _eventClickAutoOptionCheckBox;
		end
	else begin
		//Result.Owner := frm;
		if Result.Parent <> panel then
			Result.Parent := panel;
		if Result.Left <> autoLeft then
			Result.Left := autoLeft;
		if Result.Top <> autoTop then
			Result.Top := autoTop;
		Result.OnClick := nil; // Prevent event by setting checked ...
		if Result.Checked <> cbChecked then
			Result.Checked := cbChecked;
		Result.OnClick := _eventClickAutoOptionCheckBox;
		end;	
		//frm.FindComponent(sName).Free;
	if Result.Caption <> title then
		Result.Caption := title;
	if Result.Checked <> getSettingsBoolean(optionKey) then
		Result.Checked := getSettingsBoolean(optionKey);
	autoTop := autoTop + 15 + spaceBetweenLines;
	if _afAutoOptionKeys.indexOf(optionKey) <> -1 then
		_afAutoOptionKeys.Delete(_afAutoOptionKeys.indexOf(optionKey));
	_afAutoOptionKeys.addObject(optionKey, Result);
	if curAutoWidth > 0 then
		Result.Width := curAutoWidth - 12;
end;

procedure _eventClickAutoOptionCheckBox(Sender: TObject);
var
	i: Integer;
begin
	for i := 0 to _afAutoOptionKeys.Count - 1 do 
		if _afAutoOptionKeys.Objects[i] = Sender then 
			setSettingsBoolean(_afAutoOptionKeys[i], _afAutoOptionKeys.Objects[i].Checked);
end;

{Updates the check status of auto option boxes}
procedure AutoForm_UpdateCheckboxesAutoOption();
var
	i: Integer;
begin
	if Assigned(_afAutoOptionKeys) then
		for i := 0 to _afAutoOptionKeys.Count-1 do
			//if ScriptConfiguration.hasSettingsBoolean(_afAutoOptionKeys[i]) then begin
				if Assigned(_afAutoOptionKeys.Objects[i]) then
					_afAutoOptionKeys.Objects[i].Checked := getSettingsBoolean(_afAutoOptionKeys[i]);
			//	end
end;

function AutoForm_AddButton( top,left,height,width, modalResult: Integer; caption:String):TButton;
begin
	Result := TButton.Create(frm);
	//if not Assigned(constructedObjects) then  constructedObjects := TList.create();
	Result.font.size := Result.font.size * getSettingsFloat('config.fTextFontScale', 1.0);
	//constructedObjects.add(Result);
    Result.Parent := panel;
	
	if not Assigned(width) then
		width := Length(caption)*7+height; // height as "padding"
	Result.Width := width;
	Result.Height := height;
    Result.Top := top;
    Result.Left := left;
    Result.Caption := caption;
    Result.ModalResult := modalResult;
end;

function AutoForm_AddButtonBottom( modalResult: Integer; caption:String):TButton;
begin
	Result := TButton.Create(frm);
	Result.font.size := Result.font.size * getSettingsFloat('config.fTextFontScale', 1.0);
	_afButtons.AddObject('',Result);
	
	Result.Width := Length(caption)*7+50;
	Result.Height := 40;
    Result.Parent := panel;
    
    Result.Caption := caption;
    Result.ModalResult := modalResult;
	if Result.ModalResult = mrCancel then
		Result.Cancel := true;
		
	AutoForm_ArrangeButtonBottom();
end;

procedure AutoForm_ArrangeButtonBottom();
var
	freeSpace,i: Integer;
	buttonSumWidth : Integer;
	buttonsTmpWidth: Integer;
begin
	// Arrange all buttons
	buttonSumWidth := 0;
	for i := 0 to _afButtons.Count-1 do begin
		buttonSumWidth := buttonSumWidth + _afButtons.Objects[i].Width;
	end;
	freeSpace := frm.Width - buttonSumWidth;
	if freeSpace < 0 then freeSpace := 0;
	buttonsTmpWidth := 0;
	for i := 0 to _afButtons.Count-1 do begin
		_afButtons.Objects[i].Left := buttonsTmpWidth + ( freeSpace div (_afButtons.Count+1) ) * (i+1);
		_afButtons.Objects[i].Top := frm.Height - 100;
		buttonsTmpWidth := buttonsTmpWidth + _afButtons.Objects[i].Width;
	end;
	
end;

function AutoForm_SetupScrollBox():TScrollBox;
begin
	Result := TScrollBox.Create(frm);
	//if not Assigned(constructedObjects) then  constructedObjects := TList.create();
	//constructedObjects.add(Result);
	Result.Parent := frm;
	Result.Align := alTop;
	Result.Height := 500;
	Result.HorzScrollBar.Visible := false;
	Result.VertScrollBar.Tracking := true;
	
	panel := Result;
end;

function AutoForm_AddLink(prevComp:TCheckBox;title:String; options:Integer):TLabel;
var halfFormWidth,prevAutoTop,formWidth: Integer;
begin
	//AutoForm_SaveAutoPos();
	prevAutoTop := AutoForm_GetAutoTop();
	
	formWidth := curAutoWidth;
	halfFormWidth := formWidth / 2;
	Result := AutoForm_AddLabel(title,20);
	if Assigned(prevComp) then begin
		prevComp.Width := halfFormWidth;
		Result.Top := prevComp.Top;
		Result.Alignment := taRightJustify;
		Result.Left := prevComp.Left + halfFormWidth;
		Result.Width := halfFormWidth-16;
		if (options and (1 shl 32)) <>0 then begin // AF_OPT_FULL_WIDTH
			Result.Width := curAutoWidth-16;
			Result.Left := prevComp.Left;
			end;
		end
	else begin
		Result.Left := AutoForm_GetAutoLeft;
		Result.Width := halfFormWidth;
		if curAutoWidth > 0 then
			Result.Width := curAutoWidth;
		end;
	Result.Font.Color := clNavy;
	if (options and (1 shl 33)) <>0 then // AF_OPT_BOLD
		Result.Font.Style := [fsBold];
	Result.Cursor := -21;
	Result.onMouseEnter := eventLabelOnMouseEnter;
	Result.onMouseLeave := eventLabelOnMouseLeave;
	if Assigned(prevComp) then
		AutoForm_SetAutoPos(prevAutoTop,nil);
end;

function AutoForm_BeginGroup(compName, title:String):TGroupBox;
begin
	_afPreAutoGroupTop := AutoForm_GetAutoTop;
	_afPreAutoGroupLeft:= AutoForm_GetAutoLeft;
	if compName <> '' then
		Result := frm.FindComponent(compName);
	if not Assigned(Result) then begin
		Result := ConstructGroup(frm, frm,AutoForm_GetAutoTop, AutoForm_GetAutoLeft, 1,optionGroupWidth,title, '');
		Result.Name := compName;
		Result.font.size := Result.font.size * getSettingsFloat('config.fTextFontScale', 1.0);
		end;
	_afCurAutoGroup := Result;
	AutoForm_SetAutoPos(optionGroupPadding+14,optionGroupPadding);
	curAutoWidth := optionGroupWidth - optionGroupPadding * 2;
	panel := _afCurAutoGroup;
end;

procedure AutoForm_EndGroup();
begin
	_afCurAutoGroup.Height := AutoForm_GetAutoTop + optionGroupPadding;
	curAutoWidth := 0;
	panel := frm;
	
	AutoForm_SetAutoPos(_afPreAutoGroupTop + _afCurAutoGroup.Height + 30,_afPreAutoGroupLeft);
end;

// On Mouse Enter
procedure eventLabelOnMouseEnter(Sender: TObject);
begin
    Sender.Font.Color := clBlue;
	Sender.Font.Style := Sender.Font.Style + [fsUnderline];
end;

procedure eventLabelOnMouseLeave(Sender: TObject);
begin
    Sender.Font.Color := clNavy;
	if (Sender.Text = '?') or (Sender.Text = 'Help') then 
		Sender.Font.Color := $AAAAAA;
	Sender.Font.Style := Sender.Font.Style - [fsUnderline];
end;


procedure cleanup();
	var i:Integer;
begin
	//if Assigned(panel) then panel.Free;
	//if Assigned(frm) then frm.Free;
	if Assigned(_afAutoOptionKeys) then FreeAndNil(_afAutoOptionKeys);
	
	{if Assigned(constructedObjects) then begin
		for i := constructedObjects.Count -1 downto 0 do
			if Assigned(constructedObjects[i]) then
				constructedObjects[i].Free;
		end;}
	if Assigned(_afSubStack) then
		while _afSubStack.Count > 0 do 
			AutoForm_EndSub;
	if Assigned(_afFormStack) then
		while _afFormStack.Count > 0 do 
			AutoForm_EndForm;
	
	FreeAndNil(_afSubStack);
	FreeAndNil(_afFormStack);
	FreeAndNil(_afButtons);
end;

end.