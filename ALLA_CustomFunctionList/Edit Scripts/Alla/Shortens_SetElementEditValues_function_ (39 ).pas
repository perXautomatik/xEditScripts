

// Shortens SetElementEditValues
function seev(e: IInterface; v, s: String): String;
begin
  Result := SetElementEditValues(e, v, s);
end;

// Shortens SetElementNativeValues
Procedure senv(e: IInterface; s: String; i: Integer);
begin
	SetElementNativeValues(e, s, i);
end;

// Shortens ElementByName [mte functions]
function ebn(e: IInterface; n: string): IInterface;
begin
  Result := ElementByName(e, n);
end;

//Shortens ElementByPath [mte functions]
function ebp(e: IInterface; p: string): IInterface;
begin
  Result := ElementByPath(e, p);
end;

// Shortens ElementByIndex [mte functions]
function ebi(e: IInterface; i: integer): IInterface;
begin
  Result := ElementByIndex(e, i);
end;

// Shortens ElementBySignature
function ebs(e: IInterface; s: String): IInterface;
begin
	Result := ElementBySignature(e, s);
end;

// Shortens ElementCount
function ec(e: IInterface): Integer;
begin
	Result := ElementCount(e);
end;

// Shortens ReferencedByCount
function rfc(e: IInterface): Integer;
begin
	Result := ReferencedByCount(e);
end;

// Shortens ReferencedByIndex
function rbi(e: IInterface; int: Integer): IInterface;
begin
	Result := ReferencedByIndex(e, int);
end;

// Shortens GroupBySignature
function gbs(e: IInterface; s: String): IInterface;
begin
	Result := GroupBySignature(e, s);
end;

// Shortens Signature
function sig(e: IInterface): String;
begin
	Result := Signature(e);
end;

// Shortens ReferencedByCount
function rbc(e: IInterface): Integer;
begin
	Result := ReferencedByCount(e);
end;

// Shortens addMessage
Procedure msg(s: String);
begin
	addMessage(s);
end;

// Shortens ElementExists
function ee(e: IInterface; s: String): Boolean;
begin
	Result := ElementExists(e, s);
end;

// Shortens MainRecordByEditorID
function ebEDID(e: IInterface; s: String): IInterface;
begin
	Result := MainRecordByEditorID(e, s);
end;

// Shortens geev(e, 'FULL')
function full(e: IInterface): String;
begin
	Result := geev(e, 'FULL');
end;

// Shortens ObjectToElement
function ote(e: TObject): IInterface;
var
	startTime, stopTime: TDateTime;
begin
	startTime := Time;
	Result := ObjectToElement(e);
	stopTime := Time;
	if ProcessTime then
		addProcessTime('ObjectToElement', TimeBtwn(startTime, stopTime));
end;

// Shortens wbCopyElementToFile
Function CopyRecordToFile(aRecord, aFile: IInterface; aBoolean, bBoolean: Boolean): IInterface;
var
	startTime, stopTime: TDateTime;
begin
	startTime := Time;

	Result := wbCopyElementToFile(aRecord, aFile, aBoolean, bBoolean);
	stopTime := Time;
	if ProcessTime then addProcessTime('wbCopyElementToFile', TimeBtwn(startTime, stopTime));
end;