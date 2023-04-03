{
	M8r98a4f2s Complex Item Sorter for FallUI - Helper functions
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Random helper functions.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}
unit helper;

var
  times: Array[0..10] of Float;

implementation

{preg_replace like function}
function pregReplace(pattern:String;replacement:String;subject:String ):String;
var
  reg:TPerlRegEx;
begin
	reg:= TPerlRegEx.Create;
	reg.Subject := subject;
	reg.RegEx := pattern;
	reg.Replacement := replacement;
	if ( reg.Match()) then
		reg.ReplaceAll();
	Result := reg.Subject;
end;

{preg_match like function}
function pregMatch(pattern:String;subject:String ):Boolean;
var
  reg:TPerlRegEx;
begin
	reg:= TPerlRegEx.Create;
	reg.Subject := subject;
	reg.RegEx := pattern;
	Result := reg.Match();
end;

{Splits a string by a fixed character}
function Split(const Delimiter: Char; const Str: string):TStringList;
begin
	Result := TStringList.create;
	Result.Clear;
	Result.Delimiter       := Delimiter;
	Result.StrictDelimiter := True; // Requires D2006 or newer.
	Result.DelimitedText   := Str;
end;

{Simple string splitter by a fixed char in two strings. Returns true if the delimiter is found.
	Supports usage of same var for str and outStr1, but not for str and outStr2!}
function SplitSimple(const delimiter:Char; const str:String; var outStr1,var outStr2:String):Boolean;
var
	iPos: Integer;
begin
	iPos := Pos(delimiter,str);
	if iPos <> 0 then begin
		Result := true;
		outStr2 := Copy(str,iPos+1,length(str)-iPos);
		outStr1 := Copy(str,1,iPos-1);
		Exit;
		end;
	Result := false;
	outStr1 := str;
end;

{Simple string splitter by a fixed char in two strings. Returns true if the delimiter is found.
	Supports usage of same var for str and outStr2, but not for str and outStr1!}
function SplitSimpleExtract(const delimiter:Char; const str:String; var outStr1,var outStr2:String):Boolean;
var
	iPos: Integer;
begin
	iPos := Pos(delimiter,str);
	if iPos <> 0 then begin
		Result := true;
		outStr1 := Copy(str,1,iPos-1);
		outStr2 := Copy(str,iPos+1,length(str)-iPos);
		Exit;
		end;
	Result := false;
	outStr1 := str;
end;

{Returns all esp files merged as string}
function getAllEspFilesString:String;
var
	i:Integer;
	f: IInterface;
	lst: TStringList;
begin
	lst := TStringList.Create;
  
	for i := 0 to FileCount - 2 do begin
		f := FileByLoadOrder(i);
	if (GetAuthor(f) = 'R88_SimpleSorter') then
		Continue;
	lst.add(GetFileName(f));
	end;
	Result := lst.CommaText;
	lst.free;
end;


{Get all possible record types as string}
function getAllRecordsString:String;
var
	lst: TStringList;
begin
	lst := TStringList.Create;
	//lst.add('KYWD');
	lst.add('ALCH');
	lst.add('AMMO');
	lst.add('ARMO');
	lst.add('BOOK');
	lst.add('COBJ');
	lst.add('INNR');
	lst.add('KEYM');
	lst.add('LVLI');
	lst.add('MISC');
	lst.add('NOTE');
	lst.add('QUST');
	lst.add('WEAP');

	Result := lst.CommaText;
	lst.free;
end;


{Get the default record types as string}
function getDefaultRecordsString:String;
var
	lst: TStringList;
begin
	lst := TStringList.Create;
	//lst.add('KYWD');
	lst.add('ALCH');
	lst.add('AMMO');
	lst.add('ARMO');
	lst.add('BOOK');
	lst.add('INNR');
	lst.add('KEYM');
	lst.add('LVLI');
	lst.add('MISC');
	lst.add('NOTE');
	lst.add('WEAP');

	Result := lst.CommaText;
	lst.free;
end;

function getRecordsDescriptions():TStringList;
begin
	Result := TStringList.Create;
	Result.values['ALL']  := 'All records';
	Result.values['ALCH'] := 'Ingestible';
	Result.values['AMMO'] := 'Ammunition';
	Result.values['ARMA'] := 'Armor Addon';
	Result.values['ARMO'] := 'Armor';
	Result.values['BOOK'] := 'Book';
	Result.values['CMPO'] := 'Component';
	Result.values['COBJ'] := 'Constructible Object';
	Result.values['INNR'] := 'Instance Naming Rules';
	Result.values['KEYM'] := 'Keys';
	Result.values['KYWD'] := 'Keywords';
	Result.values['LVLI'] := 'Leveled Item';
	Result.values['MISC'] := 'Misc. Item';
	Result.values['NOTE'] := 'Note';
	Result.values['WEAP'] := 'Weapon';
	Result.values['QUST'] := 'Quests';
end;

procedure d(e:IInterface;msg:String);
var
	cFormId,cFormIdFixed, cFormIdLO: cardinal;
	sig, strEditorId, strFullName: String;
begin
	if ( msg = '' ) then
		msg := '** ITEM:  ';
	if not Assigned(e) then begin
		msg := msg + 'NO RECORD.';
		AddMessage(msg);
		exit;
	end;
	cFormId := FormId(e);
	cFormIdFixed := FixedFormId(e);
	cFormIdLO := GetLoadOrderFormID(e);
	strEditorId := EditorId(e);
	
	strFullName := 'NO_FULLNAME';
	try
		// AddMessage(ElementType(e));
		if Assigned(GetElementEditValues(e, 'FULL - Name')) then
			strFullName := GetElementEditValues(e, 'FULL - Name');
	except
	end;
	sig := 'NO_SIGNATURE';
	try
		sig := GetElementEditValues(e, 'Record Header\Signature');
	except
	end;
	
	if Assigned(sig) then
		msg := msg +' '+sig;
	if Assigned(cFormId) then
		msg := msg +' FormId: '+IntToHex(cFormId,8);
	if Assigned(cFormIdFixed) then
		msg := msg +' -Fix: '+IntToHex(cFormIdFixed,8);
	if Assigned(cFormIdFixed) then
		msg := msg +' -LO: '+IntToHex(cFormIdLO,8);
	if Assigned(strEditorId) then
		msg := msg +' EditorId: '+strEditorId;
	if Assigned(strFullName) then
		msg := msg +' FullName: '+strFullName;
	AddMessage( msg );
end;

function etToString(et: TwbElementType): string;
begin
  case Ord(et) of
    Ord(etFile): Result := 'etFile';
    Ord(etMainRecord): Result := 'etMainRecord';
    Ord(etGroupRecord): Result := 'etGroupRecord';
    Ord(etSubRecord): Result := 'etSubRecord';
    Ord(etSubRecordStruct): Result := 'etSubRecordStruct';
    Ord(etSubRecordArray): Result := 'etSubRecordArray';
    Ord(etSubRecordUnion): Result := 'etSubRecordUnion';
    Ord(etArray): Result := 'etArray';
    Ord(etStruct): Result := 'etStruct';
    Ord(etValue): Result := 'etValue';
    Ord(etFlag): Result := 'etFlag';
    Ord(etStringListTerminator): Result := 'etStringListTerminator';
    Ord(etUnion): Result := 'etUnion';
  end;
end;

function getEditorId(rec:IInterface): String;
begin
	Result := GetElementEditValues(rec, 'EDID - Editor ID');
end;


function getFallout4LanguageCode:string;
var
	ini: TIniFile;
begin;
	ini := TIniFile.Create(DataPath+'/../Fallout4_Default.ini');
	try
		Result := ini.ReadString('General', 'sLanguage', 'en');
		// Result := 'en';
	finally
		FreeAndNil(ini);
	end;
end;

function measureTimeGetCurrentTime():Float;
var
	h,m,s,ms: Word;
begin
  DecodeTime(Now,h,m,s,ms);
  Result := s + ms/1000 + m*60 + h*60 * 60;
end;

procedure measureTimeStart(timer:Integer);
begin
	times[timer] := measureTimeGetCurrentTime();
end;

function measureTimeGetFormatted(timer:Integer):String;
var
	diff: Float;
begin
	diff := measureTimeGetCurrentTime()-times[timer];
	Result := FloatToStr(Round(diff*10)/10)+'s';
end;

procedure measureTimeDefaultAfter(timer:Integer);
begin
	AddMessage('   ..finished after '+measureTimeGetFormatted(timer)+'.');
end;


{returns the base name of a mod file without file extension}
function getBaseESPName(filename:String):String;
begin
	Result := StringReplace(filename,'.esp','',[rfReplaceAll]);
	Result := StringReplace(Result,'.esm','',[rfReplaceAll]);
	Result := StringReplace(Result,'.esl','',[rfReplaceAll]);
end;

{Parses a parameter string into its parts}
function parseParameters(str: String;removeQuotes:Boolean):TStringList;
var
	n,iPos1,iPos2,iPos3: Integer;
begin
	Result := TStringList.Create();
	str := Trim(str);
	n := 0;
	while true do begin
		if str = '' then
			exit;
		
		if ( Length(str) > 1 ) and (str[1] = '"' ) then begin
			//str := Copy(str,2, Length(str)-1);
			//iPos2 := Pos('"',str);
			
			iPos2 := Pos('"',Copy(str,2, Length(str)-1));
			// Skip '""'
			while Copy(str,iPos2+2,1) = '"' do begin
				// Find next quote after '""'
				iPos3 := Pos('"',Copy(str,iPos2+3, Length(str)));
				if iPos3 <> 0 then
					iPos2 := iPos2 + iPos3 + 1
				else
					raise Exception.Create('Invalid string escaping syntax for "'+str'"');
				end;
					
					
			if ( iPos2 > 0 ) then begin
				if removeQuotes then
					Result.add(Copy(str,2,iPos2-1))
				else
					Result.add(Copy(str,1,iPos2+1));
				if length(str) - 1 > iPos2 then
					str := Copy(str,iPos2+3, Length(str)-1-iPos2)
				else str := '';
				end
			else begin
				raise Exception.Create('<parseParameters> Invalid syntax in "'+str+'"');
				Exit;
				end;
			end
		else begin
			iPos1 := Pos(' ', str);
			iPos2 := Pos('"', str);
			// Process parts with quoted string not on first position
			if (iPos2 <> 0) and (iPos2 < iPos1) then begin
				// Find matching second quoted (iPos3 is a offset to iPos2)
				iPos3 := Pos('"',Copy(str,iPos2+1,1000));
				if iPos3 <> 0 then begin
					iPos3 := iPos3 + iPos2; // Pos of second "
					// Find next ' '
					iPos1 := Pos(' ', Copy(str,iPos3+1,1000));
					if iPos1 <> 0 then
						iPos1 := iPos1 + iPos3;
					end;
				end;
			if iPos1 > 0 then begin
				Result.add(Copy(str,1,iPos1-1));
				str := Copy(str,iPos1+1, Length(str)-iPos1);
				end
			else begin
				Result.add(str);
				exit;
				end;
			
			end;
		// Safety first
		Inc(n);
		if n > 100 then
			raise Exception.Create('Error: Parameter overflow.');

		end;
end;

{Test if a string begins with a needle, and if true returns true and extract the string after}
function BeginsWithExtract(const needle:String;const haystack:String;var outAfterNeedle:String):Boolean;
var
	index:Integer;
begin
	index := Pos(needle,haystack);
	if index <> 1 then
		Exit;
	outAfterNeedle := Copy(haystack,length(needle)+1,1000);
	Result := true;
end;

{Tests if a string is a valid number}
function IsNumber(str:String):Boolean;
var
	i:Integer;
begin
	Result := PregMatch('(^\d+(?:\.\d+)?$)',str);
	{if str <> '' then begin
		Result := true;
		for i := 0 to Length(str) do
			
		end;}
end;

{Dumps a value}
procedure d(mixed:Variant);
var i:Integer;
begin
	try
		for i := 0 to mixed.Count -1 do
			AddMessage('(list) '+IntToStr(i)+': '+mixed[i]);
		Exit;
	except end;
	try
		AddMessage('(number) '+FloatToStr(mixed));
		Exit;
	except end;
	try
		if ( mixed = true ) then
			AddMessage('(bool): TRUE')
			else AddMessage('(bool): FALSE');
		Exit;
	except end;
	try
		AddMessage('(string)' + mixed);
	except end;
end;

{Converts bool to string}
function BoolToStr(bool:Boolean):String;
begin
	if bool then
		Result := 'true'
	else 
		Result := 'false';
end;

{Converts bool to string}
function StrToBool(str:String):Boolean;
begin
	Result := str = 'true';
end;

{Convert hex to int}
function hexToInt(hex:String): Integer;
begin
  Result:=StrToInt('$' + hex);
end;




end.