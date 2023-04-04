{
	M8r98a4f2s Complex Item Sorter for FallUI - EasyForm
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Part of the GUI.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit EasyForm;

const
	// Bit options for labels
	efNone = 0;
	efUNUSED = 1;
	efBold = 2;
	efItalic = 4;
	efTopAddHeight = 8;
	efCursorHand = 16;
	efBlue = 32;
	efCenter = 64;
	efRight = 128;
	efAutoWidth = 256;
	efAutoHeight = 512;
	efLeftAddWidth = 1024;
	efHidden = 2048;

var
	ef_isInited: Boolean;
	efSubStack,efPosStack: TStringList;
	efOwner, efParent: TForm;
	// Auto positioning of items
	efLeft, efTop: Integer;
	// Auto padding
	_efPaddingWidth, _efPaddingHeight: Integer;

implementation

{Init the module (automatic)}
procedure init();
begin
	if ef_isInited then
		Exit;
	efPosStack := TStringList.Create;
	efSubStack := TStringList.Create;
	ef_isInited := true;
end;

{Starts a form section}
function efStartForm(efOwner:TForm;width,height:Integer;caption:String):TForm;
begin
	Result := TForm.Create(efOwner);

	Result.Caption := caption;
	Result.Width := width;
	Result.Height := height;
	Result.BorderStyle := bsDialog;
	Result.Position := poScreenCenter;
	Result.DoubleBuffered := true;
	// Start sub section
	efStartSub(Result,Result);
end;

{Starts a panel sub section}
function efStartPanel(efOwner:TForm;left,top,width,height:Integer):TPanel;
begin
	if (left = 0 ) and (width = 0) then begin
		left := _efPaddingWidth;
		width := efParent.Width - _efPaddingWidth * 2;
		end;
	if top = 0 then
		top := efTop;
	Result := TPanel.Create(efOwner);
	Result.Left := left;
	Result.Top := top;
	Result.Width := width;
	Result.Height := height;
	Result.Parent := efOwner;
	
	efStartSub(Result, Result);
end;

{Starts a sub section for drawing and modifying components}
procedure efStartSub(newFrm, newPanel:TObject);
begin
	init();
	efSubStack.addObject('frmObj',efOwner);
	efSubStack.addObject('panelObj',efParent);
	efSubStack.add(IntToStr(efLeft));
	efSubStack.add(IntToStr(efTop));
	efSubStack.add(IntToStr(_efPaddingWidth));
	efSubStack.add(IntToStr(_efPaddingHeight));
	efOwner := newFrm;
	efParent := newPanel;
	_efPaddingWidth := 0;
	_efPaddingHeight := 0;
	efLeft := _efPaddingWidth;
	efTop := _efPaddingHeight;
end;

{Ends the sub section}
procedure efEndSub();
begin
	_efPaddingHeight := StrToInt(efSubStack[efSubStack.Count-1]);
	efSubStack.delete(efSubStack.Count-1);
	_efPaddingWidth := StrToInt(efSubStack[efSubStack.Count-1]);
	efSubStack.delete(efSubStack.Count-1);
	efTop := StrToInt(efSubStack[efSubStack.Count-1]);
	efSubStack.delete(efSubStack.Count-1);
	efLeft := StrToInt(efSubStack[efSubStack.Count-1]);
	efSubStack.delete(efSubStack.Count-1);
	efParent := efSubStack.Objects[efSubStack.Count-1];
	efSubStack.delete(efSubStack.Count-1);
	efOwner := efSubStack.Objects[efSubStack.Count-1];
	efSubStack.delete(efSubStack.Count-1);
end;

{Save current draw position}
procedure efSavePos;
begin
	efPosStack.add(IntToStr(efLeft));
	efPosStack.add(IntToStr(efTop));
end;

{Restores current draw position}
procedure efRestorePos;
begin
	eftop := StrToInt(efPosStack.Objects[efPosStack.Count-1]);
	efPosStack.delete(efPosStack.Count-1);
	efLeft := StrToInt(efPosStack.Objects[efPosStack.Count-1]);
	efPosStack.delete(efPosStack.Count-1);
end;


{Adjust the auto padding}
procedure efPadding(const paddingWidth,paddingHeight:Integer);
begin
	efLeft := efLeft + (paddingWidth - _efPaddingWidth);
	efTop := efTop + (paddingHeight - _efPaddingHeight);
	_efPaddingWidth := paddingWidth;
	_efPaddingHeight := paddingHeight;
end;

{Makes a easy TLabel object}
function efLabel(const text:String;left, top, width, height,options:Integer):TLabel;
begin
	// Prerequisites
	if not Assigned(efOwner) then
		raise Exception.Create('no efOwner set!');

		// Params
	left := left + efLeft;
	top := top + efTop;
	if height = 0 then height := 20;
	if width = 0 then width := efParent.Width - left*2;

	// Build
	Result := TLabel.Create(efOwner);
	Result.Text := text;
	if (options and (1 shl 40)) <>0 then begin // efAutoWidth
		{Result.Font.Style := [fsUnderline];
		Result.Font.Style := [];}
		if (options and (1 shl 39)) <>0 then
			left := left + (width - Result.Width);
		width := Result.Width;
		end;
	if (options and (1 shl 33)) <>0 then // efBold
		Result.Font.Style := Result.Font.Style + [fsBold];
	if (options and (1 shl 34)) <>0 then // efItalic
		Result.Font.Style := Result.Font.Style + [fsItalic];
	if (options and (1 shl 37)) <>0 then // efBlue
		Result.Font.Color := $FF9977;//clBlue;
	if (options and (1 shl 38)) <>0 then // efCenter
		Result.Alignment := taCenter
	else if (options and (1 shl 39)) <>0 then // efRight
		Result.Alignment := taRightJustify;
	if (options and (1 shl 36)) <>0 then // efCursorHand
		Result.Cursor := -21;

	// Layout
	Result.Left := left;
	Result.Top := top;
	Result.WordWrap := false;
	Result.Width := width;
	Result.Height := height;
	
	if (options and (1 shl 41)) <>0 then begin // efAutoHeight
		Result.Height := nil;
		Result.Layout := tlTop;
		Result.WordWrap := true;
		Result.Width := width;
		Result.Left := left;
		end
	else
		Result.Layout := tlCenter;


	if (options and (1 shl 35)) <>0 then // efTopAddHeight
		efTop := efTop + Result.Height;
	if (options and (1 shl 42)) <>0 then // efLeftAddWidth
		efLeft := efLeft + width;
	if (options and (1 shl 43)) <>0 then // efHidden
		Result.Visible := false;
	Result.Parent := efParent;
end;

{Creates a easy Panel}
function efPanel(left,top,width,height:Integer):TPanel;
begin
	// Prerequisites
	if not Assigned(efOwner) then
		raise Exception.Create('no efOwner set!');
	// Params
	left := left + efLeft;
	top := top + efTop;
	if width = 0 then
		width := efParent.Width - left * 2 - 16;

	Result := TPanel.Create(efOwner);
	
	Result.Left   := left;
	Result.Top    := top;
	Result.Width  := width;
	Result.Height := height;
	Result.Parent := efParent;

end;

{Adds a fixed amount to the drawing position Top value}
procedure efTopAdd(amount:Integer);
begin
	efTop := efTop + amount;
end;

{Adds a fixed amount to the drawing position Left value}
procedure efLeftAdd(amount:Integer);
begin
	efLeft := efLeft + amount;
end;

{Applies a color to a TLabel without changing all other things}
procedure efApplyLabelColor(tlab:TLabel;color:TColor);
var
	prevAlignment:TAlignment;
	prevLayout:TTextLayout;
	prevHeight, prevWidth,prevLeft,prevTop:Integer;
begin
	prevAlignment := tlab.Alignment;
	prevLayout := tlab.Layout;
	prevHeight := tlab.Height;
	prevWidth := tlab.Width;
	prevLeft := tlab.Left;
	prevTop := tlab.top;
	
	tlab.Font.Color := color;
	
	tlab.Height := prevHeight;
	tlab.Width := prevWidth;
	tlab.Top := prevTop;
	tlab.Left := prevLeft;
	tlab.Layout := prevLayout;
	tlab.Alignment := prevAlignment;

end;


{Applies a color to a TLabel without changing all other things}
procedure efApplyLabelText(tlab:TLabel;text:String);
var
	prevAlignment:TAlignment;
	prevLayout:TTextLayout;
	prevHeight, prevWidth,prevLeft,prevTop:Integer;
begin
	prevAlignment := tlab.Alignment;
	prevLayout := tlab.Layout;
	prevHeight := tlab.Height;
	prevWidth := tlab.Width;
	prevLeft := tlab.Left;
	prevTop := tlab.top;
	
	tlab.Text := text;
	
	tlab.Height := prevHeight;
	tlab.Width := prevWidth;
	tlab.Top := prevTop;
	tlab.Left := prevLeft;
	tlab.Layout := prevLayout;
	tlab.Alignment := prevAlignment;

end;


{Applies a color to a TLabel without changing all other things}
procedure efApplyLabelStyle(tlab:TLabel;style:Variant);
var
	prevAlignment:TAlignment;
	prevLayout:TTextLayout;
	prevHeight, prevWidth,prevLeft,prevTop:Integer;
begin
	prevAlignment := tlab.Alignment;
	prevLayout := tlab.Layout;
	prevHeight := tlab.Height;
	prevWidth := tlab.Width;
	prevLeft := tlab.Left;
	prevTop := tlab.top;
	
	tlab.Font.Style := style;
	
	tlab.Height := prevHeight;
	tlab.Width := prevWidth;
	tlab.Top := prevTop;
	tlab.Left := prevLeft;
	tlab.Layout := prevLayout;
	tlab.Alignment := prevAlignment;

end;


{Cleanup}
procedure cleanup();
var i:Integer;
begin
	if Assigned(efSubStack) then
		for i := 0 to efSubStack.Count -1 do
			efSubStack.Objects[i] := nil;
	FreeAndNil(efSubStack);
	FreeAndNil(efPosStack);
	ef_isInited := false;
	efOwner := nil;
	efParent := nil;
end;

end.