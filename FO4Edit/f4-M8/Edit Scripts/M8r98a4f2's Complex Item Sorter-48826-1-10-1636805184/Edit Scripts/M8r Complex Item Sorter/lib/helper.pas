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
	reg.Free;
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
	reg.Free;
end;

{Splits a string by a fixed character}
function Split(const delimiter: Char; const str: string):TStringList;
begin
	Result := TStringList.create;
	Result.Delimiter       := delimiter;
	Result.StrictDelimiter := True; // Requires D2006 or newer.
	Result.DelimitedText   := str;
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
		if GetAuthor(f) = 'R88_SimpleSorter' then
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
	lst.add('ACTI');
	lst.add('ALCH');
	lst.add('AMMO');
	//lst.add('ARMA');
	lst.add('ARMO');
	lst.add('BOOK');
	lst.add('COBJ');
	lst.add('INNR');
	lst.add('KEYM');
	lst.add('LVLI');
	lst.add('MESG');
	lst.add('MISC');
	lst.add('NOTE');
	lst.add('NPC_');
	lst.add('QUST');
	lst.add('WEAP');
	
	Result := lst.CommaText;
	lst.free;
end;

function getRecordsDescriptions():TStringList;
begin
	Result := TStringList.Create;
	Result.values['ALL']  := 'All records';
	Result.values['ACTI'] := 'Activator';
	Result.values['ALCH'] := 'Ingestible';
	Result.values['AMMO'] := 'Ammunition';
	 //Result.values['ARMA'] := 'Armor Addon';
	Result.values['ARMO'] := 'Armor';
	Result.values['BOOK'] := 'Book';
	 Result.values['CMPO'] := 'Component';
	Result.values['COBJ'] := 'Constructible Object';
	Result.values['INNR'] := 'Instance Naming Rules';
	Result.values['KEYM'] := 'Keys';
	 Result.values['KYWD'] := 'Keywords';
	Result.values['LVLI'] := 'Leveled Item';
	Result.values['MESG'] := 'Messages';
	Result.values['MISC'] := 'Misc. Item';
	Result.values['NOTE'] := 'Note';
	Result.values['NPC_'] := 'Non-Player-Characters';
	Result.values['QUST'] := 'Quests';
	Result.values['WEAP'] := 'Weapon';
end;

{Get the default record types as string}
function getDefaultRecordsString:String;
begin
	Result := getAllRecordsString();
end;


{Returns the language code from Fallout4.ini}
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
	if times[timer] > 0 then
		AddMessage('   ..finished after '+measureTimeGetFormatted(timer)+'.');
	times[timer] := 0;
end;


{Returns the base name of a mod file without file extension}
function getBaseESPName(filename:String):String;
begin
	Result := StringReplace(StringReplace(StringReplace(filename,'.esp','',[rfReplaceAll]),'.esm','',[rfReplaceAll]),'.esl','',[rfReplaceAll]);
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

{Converts bool to string}
function BoolToStr(bool:Boolean):String;
begin
	if bool then
		Result := 'true'
	else 
		Result := 'false';
end;

{Convert hex to int}
function HexToInt(hex:String): Integer;
begin
  Result := StrToInt('$' + hex);
end;

{Read raw ini section. Skips empty lines.}
function loadIniSectionRaw(iniPath,sectionName:String):TStringList;
var
	lines: TStringList;
	i: Integer;
	flagInSection: Boolean;	
	line: String;
begin
	lines := TStringList.Create;
	lines.LoadFromFile(iniPath);
	Result := TStringList.Create;
	for i := 0 to Pred(lines.Count) do begin
		line := Trim(lines[i]);
		if line = '' then 
			continue;
		if Copy(line,1,1) = ';' then
			continue;
		if line = '['+sectionName+']' then begin
			flagInSection := true;
			continue;
			end;
		if not flagInSection then 
			continue;
		if Copy(line,1,1) = '[' then
			break;
		
		Result.Add(line);
		end;
	lines.Free;
end;

end.