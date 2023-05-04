unit FlagFunctions;

var
	quickFlagCheckActive: Boolean;
	quickFlagCheckList: TStringList;
	quickFlagCheckCard: Cardinal;
	quickFlagCheckRec: IInterface;
	
implementation

function isBitTrue(f: Cardinal; bitIndex: Byte): Boolean;
begin
	Result:= (f and (1 shl bitIndex)) <>0;
end;


function hasFlag(e:IInterface; flagName:string):Boolean;
var
	sl: TStringList;
	f: Cardinal;
begin;
	sl := TStringList.Create;
	sl.Clear;
	sl.Text := FlagValues(e);
	f := GetNativeValue(e);
	Result := isBitTrue(f,sl.indexOf(flagName));
	sl.Free;
end;

procedure startQuickFlagCheck(e:IInterface);
begin
	endQuickFlagCheck();
	if not Assigned(e) then
		Exit;
	quickFlagCheckActive := true;
	quickFlagCheckList := TStringList.Create;
	// quickFlagCheckList.Clear;
	quickFlagCheckRec := e;
	quickFlagCheckList.Text := FlagValues(e);
	quickFlagCheckCard := GetNativeValue(e);
end;

function quickHasFlag(flagName:string):Boolean;
begin
	// Result := isBitTrue(quickFlagCheckCard,quickFlagCheckList.indexOf(flagName));
	if Assigned(quickFlagCheckList) then
		Result := (quickFlagCheckCard and (1 shl quickFlagCheckList.indexOf(flagName))) <>0
	else Result := false;
end;


procedure endQuickFlagCheck();
begin
	if quickFlagCheckActive and Assigned(quickFlagCheckList) then
		quickFlagCheckList.Free;
	quickFlagCheckCard := 0;
	quickFlagCheckActive := false;
end;


{**
 * Checks if e has all flags defined via flagsCSV.
 * @param flagsCSV String - Comma separated flags, e.g.: '30 - Hair Top,46 - Headband'
 *}
function hasFlags(e:IInterface; flagsCSV:String):Boolean;
var
	flags: TStringList;
begin
	flags := Split(',',flagsCSV);
	Result := matchingFlags(e, flagsCSV) = flags.Count;
	flags.Free;
end;

{
	Checks if all flags are set
}
function quickHasFlags(flagsCSV:String):Boolean;
var
	flags: TStringList;
begin
	flags := Split(',',flagsCSV);
	Result := quickMatchingFlags(flagsCSV) = flags.Count;
	flags.Free;
end;

{**
 * Returns the count of matching flags of e and flags defined via flagsCSV.
 * @param flagsCSV String - Comma separated flags, e.g.: '30 - Hair Top,46 - Headband'
 *}
function matchingFlags(e:IInterface; flagsCSV:String):Integer;
var
	sl,flags: TStringList;
	f: Cardinal;
	i: Integer;
begin
	flags := Split(',',flagsCSV);
	sl := TStringList.Create;
	sl.Text := FlagValues(e);
	f := GetNativeValue(e);
	Result := 0;
	for i := 0 to flags.count-1 do begin
		if isBitTrue(f,sl.indexOf(flags[i])) then
			Result := Result + 1;
	end;
	sl.Free;
	flags.Free;
end;

function quickMatchingFlags(flagsCSV:String):Integer;
var
	flags: TStringList;
	i: Integer;
begin
	Result := 0;
	if not quickFlagCheckActive then
		Exit;
	flags := Split(',',flagsCSV);
	for i := 0 to flags.count-1 do begin
		if isBitTrue(quickFlagCheckCard,quickFlagCheckList.indexOf(flags[i])) then
			Inc(Result);
	end;
	flags.Free;
end;

{**
 * Returns a comma separated string list of all flags set in e.
 * @param flagsCSV String - Comma separated flags, e.g.: '30 - Hair Top,46 - Headband'
 *}
function getSettedFlagsAsString(e:IInterface):String;
var
	sl: TStringList;
	slResult: TStringList;
	f: Cardinal;
	i: Integer;
begin
	sl := TStringList.Create;
	slResult := TStringList.Create;
	sl.Text := FlagValues(e);
	f := GetNativeValue(e);
	
	for i := 0 to sl.count-1 do
		if isBitTrue(f,i) then
			slResult.add(sl[i]);
	
	sl.Free;
	Result := slResult.CommaText;
	slResult.Free;
end;

function quickGetSettedFlagsCount():Integer;
begin
	if quickFlagCheckActive then
		Result := LENGTH(StringReplace(GetEditValue(quickFlagCheckRec), '0', '', [rfReplaceAll]))
	else
		Result := 0;
end;

end.