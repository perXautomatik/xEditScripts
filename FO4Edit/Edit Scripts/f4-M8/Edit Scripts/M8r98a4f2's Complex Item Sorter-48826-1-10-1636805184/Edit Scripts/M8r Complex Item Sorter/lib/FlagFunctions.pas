unit FlagFunctions;

var
	// Private
	_ffQuickFlagCheckActive: Boolean;
	_ffQuickFlagCheckList: TStringList;
	_ffQuickFlagCheckCard: Cardinal;
	_ffQuickFlagCheckRec: IInterface;
	
implementation

{Tests a cardinal for a bit index}
function isBitTrue(iCard: Cardinal; bitIndex: Byte): Boolean;
begin
	Result:= (iCard and (1 shl bitIndex)) <>0;
end;


{Returns if a given entry has a flag}
function hasFlag(e:IInterface; flagName:string):Boolean;
var
	lstTmp: TStringList;
	iCard: Cardinal;
begin;
	lstTmp := TStringList.Create;
	lstTmp.Text := FlagValues(e);
	iCard := GetNativeValue(e);
	Result := isBitTrue(iCard,lstTmp.indexOf(flagName));
	lstTmp.Free;
end;

{initialises the quick checking}
procedure startQuickFlagCheck(e:IInterface);
begin
	if not Assigned(e) then begin
		cleanup();
		Exit;
		end;
	// Faster cleanup
	if _ffQuickFlagCheckActive then 
		_ffQuickFlagCheckList.Clear()
	else
		_ffQuickFlagCheckList := TStringList.Create;
	_ffQuickFlagCheckActive := True;
	_ffQuickFlagCheckRec := e;
	_ffQuickFlagCheckList.Text := FlagValues(e);
	_ffQuickFlagCheckCard := GetNativeValue(e);
end;

{quick version for hasFlag}
function quickHasFlag(flagName:string):Boolean;
begin
	if _ffQuickFlagCheckActive then
		Result := (_ffQuickFlagCheckCard and (1 shl _ffQuickFlagCheckList.indexOf(flagName))) <> 0;
end;


{Checks if e has all flags defined via flagsCSV.
 @param flagsCSV String - Comma separated flags, e.g.: '30 - Hair Top,46 - Headband'}
function hasFlags(e:IInterface; flagsCSV:String):Boolean;
var
	flags: TStringList;
begin
	flags := Split(',',flagsCSV);
	Result := matchingFlags(e, flagsCSV) = flags.Count;
	flags.Free;
end;

{Checks if all flags are set}
function quickHasFlags(flagsCSV:String):Boolean;
var
	flags: TStringList;
begin
	flags := Split(',',flagsCSV);
	Result := quickMatchingFlags(flagsCSV) = flags.Count;
	flags.Free;
end;

{Returns the count of matching flags of e and flags defined via flagsCSV.
 @param flagsCSV String - Comma separated flags, e.g.: '30 - Hair Top,46 - Headband'}
function matchingFlags(e:IInterface; flagsCSV:String):Integer;
var
	lstTmp,flags: TStringList;
	f: Cardinal;
	i: Integer;
begin
	flags := Split(',',flagsCSV);
	lstTmp := TStringList.Create;
	lstTmp.Text := FlagValues(e);
	f := GetNativeValue(e);
	for i := 0 to flags.count-1 do begin
		if isBitTrue(f,lstTmp.indexOf(flags[i])) then
			Result := Result + 1;
	end;
	lstTmp.Free;
	flags.Free;
end;

{quick version for matchingFlags}
function quickMatchingFlags(flagsCSV:String):Integer;
var
	flags: TStringList;
	i: Integer;
begin
	if not _ffQuickFlagCheckActive then
		Exit;
	flags := Split(',',flagsCSV);
	for i := 0 to flags.count-1 do
		if isBitTrue(_ffQuickFlagCheckCard,_ffQuickFlagCheckList.indexOf(flags[i])) then
			Inc(Result);
	flags.Free;
end;

{Returns a comma separated string list of all flags set in e.
 @param flagsCSV String - Comma separated flags, e.g.: '30 - Hair Top,46 - Headband'}
function getSettedFlagsAsString(e:IInterface):String;
var
	lstTmp: TStringList;
	lstResult: TStringList;
	iCard: Cardinal;
	i: Integer;
begin
	lstTmp := TStringList.Create;
	lstResult := TStringList.Create;
	lstTmp.Text := FlagValues(e);
	iCard := GetNativeValue(e);
	
	for i := 0 to lstTmp.count-1 do
		if isBitTrue(iCard,i) then
			lstResult.append(lstTmp[i]);
	
	Result := lstResult.CommaText;
	lstTmp.Free;
	lstResult.Free;
end;

{quick version for getSettedFlagsAsString}
function quickGetSettedFlagsCount():Integer;
begin
	if _ffQuickFlagCheckActive then
		Result := Length(StringReplace(GetEditValue(_ffQuickFlagCheckRec), '0', '', [rfReplaceAll]));
end;

{Cleanup unit}
procedure cleanup;
begin
	if not _ffQuickFlagCheckActive then
		Exit;
	_ffQuickFlagCheckList.Free;
	_ffQuickFlagCheckList := nil;
	_ffQuickFlagCheckActive := False;

end;

end.