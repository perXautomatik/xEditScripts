unit mToolFunctions;



Function BoolToStr(value: boolean): string;

begin
  if value then  Result := 'True' else Result := 'False';
end;


Procedure AddMessageB (value: boolean);

begin
	AddMessage(BoolToStr(value));
end;


Procedure AddMessageI (value: Integer);

begin
	AddMessage(IntToStr(value));
end;


function StringReplaceLast(source, Str, subStr: string;): string;

begin

	Result := ReverseString(StringReplace(ReverseString(source), ReverseString(Str), ReverseString(subStr), [rfIgnoreCase]));

end;



// IInterface

function Sign(rec: IInterface; sign: string): boolean;

begin

	If Signature(rec) = sign then Result := true else Result := false;

end;


function findRecordByValue (searchFile: IbwFile; recToFind: string; sign: string; path: string;): Integer; // finds record by string value in path in signature group - returns Form ID, e.g string in FULL

var 
	listRecords: IInterface;
	i: integer;
	el: string;

begin
	listRecords: = GroupBySignature(searchFile, sign);
	
	for i := 0 to Pred(ElementCount(listRecords)) do begin
		el: = GetEditValue(ElementByPath(ElementByIndex(listRecords, i), path));
		
		if  el = recToFind then begin
			Result := FixedFormID(ElementByIndex(listRecords, i));
			//AddMessage('Found:   ' + EditorID(ElementByIndex(listRecords, i)) + '     ' + el + '    id: ' + IntToStr(Result));
			Break;
		end
	end;

	//if Result = 0 then AddMessage(recToFind + ' not found');
end;


function findRecord (searchFile: IbwFile; recToFind, signature: string;): Integer; // finds record by EditorID value in signature group - returns Form ID

var el: IInterface;

begin
	el := MainRecordByEditorID(GroupBySignature(searchFile, signature), recToFind);
	Result := FixedFormID(el);
{
	if Result = 0 then
		AddMessage(recToFind + ' not found')
	else
		AddMessage('Found:   ' + EditorID(el) + '     ' + IntToStr(Result));
}
end;


function RecordExist (searchFile: IbwFile; recToFind, signature: string;): boolean; // checks if record exist by EditorID value in signature group - returns true or false

var el: IInterface;

begin
	el := MainRecordByEditorID(GroupBySignature(searchFile, signature), recToFind);
	if Assigned(el) then Result := True else Result := False;
end;


function loadRecords (searchFile: IbwFile; signature: string; pattern: string;): TStringList;  // loads Names (EDID + "DisplayName" + [Signature:hex FormID]) to StringList.

var 
	el, listRecords: IInterface;
	listRec: TStringList; 
	i: integer;

begin
	listRecords: = GroupBySignature(searchFile, signature);
	listRec := TStringList.Create;

	for i := 0 to Pred(ElementCount(listRecords)) do begin
		el: = ElementByIndex(listRecords, i);
		if  (Pos (pattern, GetEditValue(ElementByPath(el, 'EDID'))) > 0) or (pattern='') then begin
			listRec.Add(Name(el));
			//AddMessage('Found:   ' + GetEditValue(el) + '     ' + Name(el) + '    id: ' + IntToStr(GetNativeValue(el)));
		end;
	end;

	Result := listRec;
end;


function loadNames (searchFile: IbwFile; signature: string; pattern: string;): TStringList;  // loads DisplayNames (FULL) to StringList.

var 
	el, listRecords: IInterface;
	i: integer;
	listRec: TStringList; 

begin
	listRecords: = GroupBySignature(searchFile, signature);
	listRec := TStringList.Create;
	ListRec.Sorted := True;

	for i := 0 to Pred(ElementCount(listRecords)) do begin
		el: = ElementByIndex(listRecords, i);
		if  (Pos (pattern, GetEditValue(ElementByPath(el, 'EDID'))) > 0) or (pattern='') then begin
			listRec.Add(DisplayName(el));
			//AddMessage('Found:   ' + GetEditValue(el) + '     ' + BaseName(el) + '    id: ' + IntToStr(GetNativeValue(el)));
		end;
	end;

	Result := listRec;
end;


// IInterface end



// DIALOG BOX FUNCTIONS


procedure KeyAction(Sender: TObject; var Key: Word;);
begin
  if Key = VK_ESCAPE then
    TObject(Sender).ModalResult := mrCancel;
end;


function PosTag (field: TObject;): Integer;

begin

	for i :=  GetParentForm(field).ComponentCount - 1 downto 0 do 
		if  GetParentForm(field).Components[i].Tag = field.Tag then Result := i;
		
end;


function showFileds(field: TObject; value: String): boolean; // show / hide field - only fields with label, value = default

var pos: integer;

begin
	pos := PosTag(field);

	field.Visible := not field.Visible;
	GetParentForm(field).Components[pos-1].Visible := not GetParentForm(field).Components[pos-1].Visible; // for label
	
	if field.Visible then field.Text := value else field.Text := '';

//	Page.Refresh;	// TO DO find active frm
	Result:= field.Visible;
end;


function CountAdd (Sender: TObject): Integer; // change integer in TEdit.text value for + / - button

var 
	inc: ShortInt;
	pos, value: integer;

begin
	pos := PosTag(Sender);
	
	if Sender.caption = '+' then inc := 1;
	if Sender.caption = '-' then inc := -1;

	try value := StrToInt(GetParentForm(Sender).Components[pos - inc].Text) + inc; except value := 0; end;
	if value < 0 then value := 0;
	
	GetParentForm(Sender).Components[pos - inc].Text := IntToStr(value);			
end;


procedure checkValuesRange (field: TEdit; min, max: integer); // keeps the range of integer values in a string;

begin
	try
	  StrToInt(field.Text);
	except
	  field.Text := min;
	end;

	if StrToInt(field.Text) < min then field.Text := min;
	if StrToInt(field.Text) > max then field.Text := max;
end;	


// DIALOG BOX FUNCTIONS END


// DIALOG BOX ELEMENTS


function CreatePanel(x, y, w, h: Integer; frm, prnt: TObject; align: String): TPanel;

begin
	Result := TPanel.Create(frm);
	Result.Parent := prnt;
	if align='left' then Result.Align := alLeft;
	if align='right' then Result.Align := alRight;
	if align='top' then Result.Align := alTop;
	if align='bottom' then Result.Align := alBottom;
    Result.Left := x;
    Result.Top := y;
    Result.Width := w;
    Result.Height := h;
	Result.BevelOuter := bvNone;
end; 


function CreateTab(prnt: TObject; caption: String): TTabSheet;

begin
	Result := TTabSheet.Create(prnt);
	Result.PageControl := prnt;
	Result.Parent := prnt;
	Result.Caption := '   ' + caption + '   ';
	Result.Margins.Left := 0;
	Result.Margins.Top := 0;			
	Result.Margins.Bottom := 0;			
	Result.Margins.Right := 0;	
	Result.Cursor := -21;
end;


function CreateGroup(x, y, w, h: Integer; frm, prnt: TObject; caption: String): TGroupBox;

begin
    Result := TGroupBox.Create(frm);
    Result.Parent := prnt;
    Result.Left := x;
    Result.Top := y;
    Result.Width := w;
    Result.Height := h;
	Result.Caption := caption;
end;


function CreateLabel(x, y: Integer; frm, prnt: TObject; caption: String): TEdit;

var lblText: TLabel;	

begin
	lblText := TLabel.create(frm);
	lblText.Parent := prnt;
	lblText.Caption := caption;
	lblText.Left := x;
	lblText.Top := y;
	Result := lblText;
end;


function CreateInput(x, y, w: Integer; frm, prnt: TObject): TEdit;

begin
	Result := TEdit.create(frm);
	Result.Parent := prnt;
	Result.Width := w;
//	Result.Font.Style := 1;
	Result.Left := x;
	Result.Top := y;
end;


function CreateComboBox(x, y, w: Integer; frm, prnt: TObject;): TComboBox;

begin
	Result := TComboBox.Create(frm);
    Result.Parent := prnt;
	Result.Left := x;
	Result.Top := y;
	Result.Width := w;
end;


function CreateCheckBox(x, y, w: Integer; frm, prnt: TObject; option: boolean; caption: String): TCheckBox;

begin
	Result := TCheckBox.Create(frm);
	Result.Parent := prnt;
	Result.Left := x;
	Result.Top := y;
	Result.Width := w;
	Result.Checked := option;
	Result.Caption := caption;
end;


function CreateRadioBGroup(x, y, w, h: Integer; frm, prnt: TObject; caption: String): TRadioGroup;

begin
    Result := TRadioGroup.Create(frm);
    Result.Parent := prnt;
    Result.Left := x;
    Result.Top := y;
    Result.Width := w;
    Result.Height := h;
	Result.Caption := caption;
end;


function CreateRadioButton(x, y: Integer; frm, prnt: TObject; option: boolean; caption: String): TRadioButton;

begin
	Result := TRadioButton.Create(frm);
	Result.Parent := prnt;
	Result.Left := x;
	Result.Top := y;
	Result.Checked := option;
	Result.Caption := caption;
end;


function CreateStaticText(x, y: Integer; frm, prnt: TObject; sText: String): TStaticText;

begin
	Result := TStaticText.Create(frm);
	Result.Parent := prnt;
	Result.Left := x;
	Result.Top := y;
	Result.Text := sText; 
end;


function CreateButton(x, y, w, h: Integer; frm, prnt: TObject; caption: String): TButton;

begin
	Result := TButton.Create(frm);
	Result.Parent := prnt;
	Result.Left := x;
	Result.Top := y;
	Result.Width := w;
	Result.Height := h;
	Result.Caption := caption;
	Result.Cursor := -21;
end;


function ButtonCount(x, y, size: Integer; frm, prnt: TObject; caption: String; tag: Integer): TButton;

begin
	Result := CreateButton(x, y, size, size, frm, prnt, caption);
	Result.Tag := tag;
	Result.OnClick := CountAdd; 
	Result.ModalResult := false;
end;


function CreateInputVal(x, y, w, size: Integer; frm, prnt: TObject; default: String; tag: Integer): TEdit;

begin
	ButtonCount(x - size - 5, y - (size - 23)/2 - 1, size, frm, prnt, '-', tag);
	Result := CreateInput(x, y, w, frm, prnt);
	Result.Text := default;
	Result.Alignment := taCenter;
	ButtonCount(x + w + 5, y - (size - 23)/2 - 1, size, frm, prnt, '+', tag + 100);
end;


function CreateInputLabel(x, y, w, xOff: Integer; frm, prnt: TObject; caption: String; tagName: Integer;): TEdit; // input with label + tag / name, xOff = 0 -> label over field

var lblText: TLabel;	

begin
	if xOff = 0 then 
		lblText := CreateLabel(x, y - 17, frm, prnt, caption)  // label over field
	else 
		lblText := CreateLabel(x, y + 4, frm, prnt, caption);  // label on the left 
	lblText.Name := 'lbl' + IntToStr(tagName);
		
	Result := CreateInput(x + xOff, y, w, frm, prnt);
	Result.Tag := tagName;
end;


function CreateComboBoxLabel(x, y, w, xOff: Integer; frm, prnt: TObject; caption: String; list: String; tagName: Integer;): TComboBox; // combobox with label, xOff = 0 -> label over field

var lblText: TLabel;	

begin
	if xOff = 0 then 
		lblText := CreateLabel(x, y - 17, frm, prnt, caption)  // label over box
	else 
		lblText := CreateLabel(x, y + 4, frm, prnt, caption);  // label on the left 
	lblText.Name := 'lbl' + IntToStr(tagName);
		
	Result := CreateComboBox(x + xOff, y, w, frm, prnt);
	Result.Tag := tagName;
	Result.Items.Text := list;	
end;


// DIALOG BOX ELEMENTS END




// HELP

procedure ShowValues(e: IInterface);

var el: IInterface;

begin

	if Assigned(e) then begin

		AddMessage ('Name: ' + Name(e));			
		AddMessage ('ShortName: ' + ShortName(e));			
		AddMessage ('Signature: ' + Signature(e));			
		AddMessage ('Path: ' + Path(e));			
		AddMessage ('FullPath: ' + FullPath(e));			
		AddMessage ('DisplayName: ' + DisplayName(e));			
		AddMessage ('EnumValues: ' + EnumValues(e));			
		AddMessage ('Edit value: ' + GetEditValue(e));
		AddMessage ('Fixed to hex: ' + IntToHex(FixedFormID(e),8));
		AddMessage ('Native value: ' + IntToStr(GetNativeValue(e)));
		AddMessage ('Editor ID: ' + EditorID(e));
		AddMessage ('Form ID: ' + FormID(e));
		AddMessage ('Fixed form ID: ' + IntToStr(FixedFormID(e)));
		AddMessage ('Display name: ' + DisplayName(e));
		AddMessage ('Edit value / by path (Model\MODS): ' + GetEditValue(ElementByPath(e, 'Model\MODS - Material Swap')));
		AddMessage ('Edit value / by sign (EDID): ' + GetEditValue(ElementBySignature(e, 'EDID')));
		AddMessage ('Edit values for EDID: ' + GetElementEditValues(e,'EDID'));
		if Assigned(ElementByPath(e, 'Model\MODS - Material Swap')) then AddMessage ('native val / by path: ' + IntToStr(GetNativeValue(ElementByPath(e, 'Model\MODS - Material Swap'))));
		AddMessage ('Baserecord edit value: ' + GetEditValue(ElementByPath(e, 'Model\MODS - Material Swap')));
		AddMessage ('El. count: ' + IntToStr(ElementCount(e)));
		AddMessage ('By Index: ' + GetEditValue(ElementByIndex(e,1)));

		AddMessage(#13);
		el: = GetContainer(ElementByPath(e, 'EDID'));
		AddMessage ('container: ' + name(el));
		
		AddMessage(#13);
		el := LinksTo (ElementByPath(e, 'Model\MODS - Material Swap'));
		AddMessage ('links to edit value: ' + GetEditValue(el));
		if Assigned(ElementByPath(e, 'Model\MODS - Material Swap')) then AddMessage ('links to native value" ' + IntToStr(GetNativeValue(el)));
		AddMessage ('links to el by sign: ' + GetEditValue(ElementBySignature(el, 'EDID')));

		if (ElementExists(e,'Model\MODS - Material Swap')) then AddMessage ('THERE I''M');
		
		end	
	else

		AddMessage ('Nil');

	AddMessage(#13);
	AddMessage(#13);

end;


end.
