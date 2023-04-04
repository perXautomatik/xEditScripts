{
	ONLY USE IF YOU KNOW WHAT THIS DOES!

	Name: MISC-2-STAT
	Author: eventHandler
	Version: alpha1

	Automatically create new STAT record using existing MISC record as template to fill in:
	OBND - Object Bounds, with six sub-elements (X1, Y1, Z1, X2, Y2, Z2)
	MODL - Model Filename

	Using MISC fields, generate derived:
	EDID - Editor ID
	FULL - Name

	Fallout4 Version: 1.2
	Verify the values in CreateRecord() when using a new version of the game esm file.
}
unit zzz_misc2stat;

// global to unit
var newRecord: IInterface;
var newFormID, oldFormID: Cardinal;
var pluginIndex: string;


function Initialize: integer;

begin
	pluginIndex := InputBox('Enter', 'Input existing plugin index (the 2 numbers/letters in [], to the left of the name):', '');
	if pluginIndex = '' then begin
		Result := 1;
		Exit;
	end;

	pluginIndex := IntToStr(1 + StrToInt64(pluginIndex));
	newFormID := 0;
	Result := 0;
end;


function Process(curRecord: IInterface): integer;
var
	newEDID: IInterface;
	newFULL: IInterface;
	newOBND: IInterface;
	newMODL: IInterface;

	curEDID: IInterface;
	curFULL: IInterface;
	curOBND: IInterface;
	curMODL: IInterface;

	str, strFront, strTail, strFormID: string;

begin
	AddMessage('Processing: ' + Name(curRecord));

	curEDID := ElementByName(curRecord, 'EDID - Editor ID');
	curFULL := ElementByName(curRecord, 'FULL - Name');
	curOBND := ElementByName(curRecord, 'OBND - Object Bounds');
	curMODL := ElementByPath(curRecord, 'Model\MODL - Model Filename');

	newRecord := CreateRecord(curRecord);
	if not Assigned(newRecord) then begin
		AddMessage('Failed to create record: ' + GetEditValue(curEDID))
		Result := 1;
		exit;
	end;

	strFront := '';
	strTail := '';

	newEDID := ElementByName(newRecord, 'EDID - Editor ID');
	newFULL := ElementByName(newRecord, 'FULL - Name');
	newOBND := ElementByName(newRecord, 'OBND - Object Bounds');
	newMODL := ElementByPath(newRecord, 'Model\MODL - Model Filename');
	SetEditValue(newEDID, strFront + GetEditValue(curEDID) + strTail);
	SetEditValue(newFULL, strFront + GetEditValue(curFULL) + strTail);
	SetEditValue(newMODL, GetEditValue(curMODL));
	SetEditValue(newOBND, GetEditValue(curOBND));

	str := 'OBND - Object Bounds\';
	SetEditValue((ElementByPath(newRecord, str + 'X1')), GetEditValue(ElementByPath(curRecord, str + 'X1')));
	SetEditValue((ElementByPath(newRecord, str + 'Y1')), GetEditValue(ElementByPath(curRecord, str + 'Y1')));
	SetEditValue((ElementByPath(newRecord, str + 'Z1')), GetEditValue(ElementByPath(curRecord, str + 'Z1')));
	SetEditValue((ElementByPath(newRecord, str + 'X2')), GetEditValue(ElementByPath(curRecord, str + 'X2')));
	SetEditValue((ElementByPath(newRecord, str + 'Y2')), GetEditValue(ElementByPath(curRecord, str + 'Y2')));
	SetEditValue((ElementByPath(newRecord, str + 'Z2')), GetEditValue(ElementByPath(curRecord, str + 'Z2')));

	//AddMessage('Created Record: ' + GetEditValue(newEDID));

	//Result := 0;
	exit;
end;


function CreateRecord(curRecord: IInterface): IInterface;
var
	baseRecord: IInterface;
	str: string;
begin
	// $001A6E2E is the FormID of an existing STAT record type to copy from the base Fallout4.esm
	// If this item changes, it may need to be updated appropriately.
	// I don't know a better way to create a valid STAT record.
	// The value is good as of patch 1.2
	baseRecord := RecordByFormID(FileByIndex(0), $001A6E2E, True);

	//AddMessage('pluginIndex: ' + pluginIndex);
	newRecord := wbCopyElementToFile(baseRecord, FileByIndex(StrToInt64(pluginIndex)), True, True);
	Result := newRecord;

	if not Assigned(newRecord) then begin
		AddMessage('Failed to copy base record as template: ' + GetEditValue(curEDID));
		Exit;
	end;
end;

end.
