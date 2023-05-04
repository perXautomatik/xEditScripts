unit AutoForm;

const
	heightPerLine = 25;
	spaceBetweenLines = 10;
	AF_OPT_FULL_WIDTH = 1;
	AF_OPT_BOLD = 2;

var
	af_isInited: Boolean;
	frm: TForm;
	panel: TForm;
	autoTop, autoLeft: Integer;
	savedAutoTop, savedAutoLeft: Integer;
	buttons: Array[0..100] of TButton;
	curButtonSum: Integer;
	//autoOptionCheckboxes: Array[0..100] of TCheckBox;
	
	autoOptionKeys: TStringList;
	curAutoOptionsSum: Integer;
	curAutoGroup: TGroupBox;
	curAutoWidth, preAutoGroupLeft, preAutoGroupTop: Integer;
	optionGroupWidth: Integer;
	optionGroupPadding: Integer;
	afSubStack: TStringList;
	afFormStack: TStringList;

implementation

procedure init();
begin
	if af_isInited then
		Exit;
	afSubStack := TStringList.Create;
	afFormStack := TStringList.Create;
	af_isInited := true;
end;

procedure AutoForm_StartSub(newFrm, newPanel:TObject);
begin
	init();
	afSubStack.addObject('frmObj',frm);
	afSubStack.addObject('panelObj',panel);
	afSubStack.add(IntToStr(autoTop));
	afSubStack.add(IntToStr(autoLeft));
	frm := newFrm;
	panel := newPanel;
end;

procedure AutoForm_EndSub();
begin
	
	autoLeft := StrToInt(afSubStack[afSubStack.Count-1]);
	afSubStack.delete(afSubStack.Count-1);
	autoTop := StrToInt(afSubStack[afSubStack.Count-1]);
	afSubStack.delete(afSubStack.Count-1);
	panel := afSubStack.Objects[afSubStack.Count-1];
	afSubStack.delete(afSubStack.Count-1);
	frm := afSubStack.Objects[afSubStack.Count-1];
	afSubStack.delete(afSubStack.Count-1);
end;

procedure AutoForm_setForm(setFrm:TForm);
begin
	init();
	// Save previous
	afFormStack.add(IntToStr(curButtonSum));
	afFormStack.add(IntToStr(curAutoOptionsSum));
	afFormStack.addObject('obj',frm);
	afFormStack.addObject('obj',panel);
	afFormStack.addObject('obj',autoOptionKeys);

	// New 
	frm := setFrm;
	panel := setFrm;
	frm.BorderStyle := bsDialog;
	frm.Position := poScreenCenter;
	
	// Reset
	curButtonSum := 0;
	curAutoOptionsSum := 0;
	autoOptionKeys := TStringList.Create
	
end;

procedure AutoForm_endForm;
begin
	FreeAndNil(autoOptionKeys);
	
	// Restore previous
	autoOptionKeys := afFormStack.Objects[afFormStack.Count-1];
	afFormStack.delete(afFormStack.Count-1);
	panel := afFormStack.Objects[afFormStack.Count-1];
	afFormStack.delete(afFormStack.Count-1);
	frm := afFormStack.Objects[afFormStack.Count-1];
	afFormStack.delete(afFormStack.Count-1);
	curAutoOptionsSum := StrToInt(afFormStack[afFormStack.Count-1]);
	afFormStack.delete(afFormStack.Count-1);
	curButtonSum := StrToInt(afFormStack[afFormStack.Count-1]);
	afFormStack.delete(afFormStack.Count-1);
	
end;

procedure AutoForm_SetAutoPos(setAutoTop, setAutoLeft: Integer);
begin
	if Assigned(setAutoTop) then
		if setAutoTop = -1 then
			autoTop := savedAutoTop
		else autoTop := setAutoTop;
	if Assigned(setAutoLeft) then
		if setAutoLeft = -1 then
			autoLeft := savedAutoLeft
		else autoLeft := setAutoLeft;
end;

procedure AutoForm_AddAutoTop(add:Integer);
begin
	AutoForm_SetAutoPos(AutoForm_GetAutoTop()+add, nil);
end;

function AutoForm_getAutoTop:Integer;
begin
	Result := autoTop;
end;

function AutoForm_GetAutoLeft:Integer;
begin
	Result := autoLeft;
end;

procedure AutoForm_SaveAutoPos();
begin
	savedAutoTop := autoTop;
	savedAutoLeft := autoLeft;
end;

function AutoForm_AddLabel(title:String; height:Integer):TLabel;
begin
	Result := ConstructLabel(frm, panel, autoTop, autoLeft, height, frm.Width - autoLeft - 20, title, '');
	autoTop := autoTop + height{ + spaceBetweenLines};
	// Result.WordWrap := true;
	if curAutoWidth >0 then
		Result.Width := curAutoWidth;
end;

function AutoForm_AddCheckbox(title:String;checked:Boolean;hint:String):TCheckBox;
begin
    Result := ConstructCheckbox(frm, panel, autoTop, autoLeft, Length(title)*15{150}, title, cbChecked, hint);
	Result.Checked := checked;
	autoTop := autoTop + 15 + spaceBetweenLines;
	if curAutoWidth > 0 then
		Result.Width := curAutoWidth;
	
end;

function AutoForm_AddCheckboxAutoOption(optionKey, title:String; default: Boolean):TCheckBox;
begin
    Result := ConstructCheckbox(frm, panel, autoTop, autoLeft, Length(title)*15{150}, title, cbChecked, '');
	Result.Checked := getSettingsBoolean(optionKey);
	autoTop := autoTop + 15 + spaceBetweenLines;
	// autoOptionCheckboxes[curAutoOptionsSum] := Result;
	autoOptionKeys.addObject(optionKey, Result);
	curAutoOptionsSum := curAutoOptionsSum + 1;
	if curAutoWidth > 0 then
		Result.Width := curAutoWidth - 12;
	Result.OnClick := _eventClickAutoOptionCheckBox;
end;

procedure _eventClickAutoOptionCheckBox(Sender: TObject);
var
	i: Integer;
begin
	for i := 0 to autoOptionKeys.Count - 1 do 
		if autoOptionKeys.Objects[i] = Sender then 
			setSettingsBoolean(autoOptionKeys[i], autoOptionKeys.Objects[i].Checked);
end;

{Updates the check status of auto option boxes}
procedure AutoForm_UpdateCheckboxesAutoOption();
var
	i: Integer;
begin
	if Assigned(autoOptionKeys) and curAutoOptionsSum > 0 then
		for i := 0 to curAutoOptionsSum-1 do
			if ScriptConfiguration.hasSettingsBoolean(autoOptionKeys[i]) then 
				autoOptionKeys.Objects[i].Checked := getSettingsBoolean(autoOptionKeys[i]);
end;

function AutoForm_AddButton( top,left,height,width, modalResult: Integer; caption:String):TButton;
begin
	Result := TButton.Create(frm);
	//if not Assigned(constructedObjects) then  constructedObjects := TList.create();

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
	//if not Assigned(constructedObjects) then  constructedObjects := TList.create();
	//constructedObjects.add(Result);
	buttons[curButtonSum] := Result;
	curButtonSum := curButtonSum +1;
	
	Result.Width := Length(caption)*7+50;
	Result.Height := 40;
    Result.Parent := panel;
    Result.Top := frm.Height - 100;
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
	for i := 0 to curButtonSum-1 do begin
		buttonSumWidth := buttonSumWidth + buttons[i].Width;
	end;
	freeSpace := frm.Width - buttonSumWidth;
	if freeSpace < 0 then freeSpace := 0;
	buttonsTmpWidth := 0;
	for i := 0 to curButtonSum-1 do begin
		buttons[i].Left := buttonsTmpWidth + ( freeSpace div (curButtonSum+1) ) * (i+1);
		buttonsTmpWidth := buttonsTmpWidth + buttons[i].Width;
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

function AutoForm_BeginGroup(title:String):TGroupBox;
begin
	preAutoGroupTop := AutoForm_GetAutoTop;
	preAutoGroupLeft:= AutoForm_GetAutoLeft;
	Result := ConstructGroup(frm, frm,AutoForm_GetAutoTop, AutoForm_GetAutoLeft, 1,optionGroupWidth,title, '');
	curAutoGroup := Result;
	AutoForm_SetAutoPos(optionGroupPadding+14,optionGroupPadding);
	curAutoWidth := optionGroupWidth - optionGroupPadding * 2;
	panel := curAutoGroup;
end;

procedure AutoForm_EndGroup();
begin
	curAutoGroup.Height := AutoForm_GetAutoTop + optionGroupPadding;
	curAutoWidth := 0;
	panel := frm;
	
	AutoForm_SetAutoPos(preAutoGroupTop + curAutoGroup.Height + 30,preAutoGroupLeft);
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
	Sender.Font.Style := Sender.Font.Style - [fsUnderline];
end;


procedure cleanup();
	var i:Integer;
begin
	//if Assigned(panel) then panel.Free;
	//if Assigned(frm) then frm.Free;
	if Assigned(autoOptionKeys) then FreeAndNil(autoOptionKeys);
	
	{if Assigned(constructedObjects) then begin
		for i := constructedObjects.Count -1 downto 0 do
			if Assigned(constructedObjects[i]) then
				constructedObjects[i].Free;
		end;}
	if Assigned(afSubStack) then
		while afSubStack.Count > 0 do 
			AutoForm_EndSub;
	if Assigned(afFormStack) then
		while afFormStack.Count > 0 do 
			AutoForm_EndForm;
	
	FreeAndNil(afSubStack);
	FreeAndNil(afFormStack);
end;

end.