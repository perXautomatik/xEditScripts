{
	Purpose: Automatic Bash Tag Generation
	Games: FO3/FNV/TES4/TES5
	Author: fireundubh <fireundubh@gmail.com>
	Version: 1.5.1.1

	Description: This script detects up to 58 bash tags in FO3, FNV, TES4, and TES5 plugins.
	Tags can be automatically added to the Description in the File Header. Wrye Bash/Flash can
	then use these tags to help you create more intelligent bashed patches.

	Requires mteFunctions:
	https://github.com/matortheeternal/TES5EditScripts/blob/master/trunk/Edit%20Scripts/mteFunctions.pas

	Credits:
	- zilav (BASH tags autodetection.pas v1.0)
	- matortheeternal (mteFunctions.pas)

	Testers:
	- alt3rn1ty
	- Arthmoor
	- InsanePlumber
	- matortheeternal
	- Sharlikran
	- zilav
}

unit BashTagsDetector;

uses mteFunctions;

var
	f: IwbFile;
	slTags: TStringList;
	fn, tag, game: string;
	optionSelected: integer;

// ******************************************************************
// FUNCTIONS
// ******************************************************************

// ==================================================================
// Returns True if the flags set are different and False if not
function CompareFlagsEx(x, y: IInterface; p, f: string): boolean;
begin
	Result := (HasFlag(GetElement(x, p), f) <> HasFlag(GetElement(y, p), f)); // Comparison: <>
end;

// ==================================================================
// Returns True if any two flags are set and False if not
function CompareFlagsOr(x, y: IInterface; p, f: string): boolean;
begin
	Result := (HasFlag(GetElement(x, p), f) or HasFlag(GetElement(y, p), f)); // Comparison: or
end;

// ==================================================================
// Returns True if the set flags are different and False if not
function CompareKeys(x, y: IInterface; debug: boolean): boolean;
var
	sx, sy: string;
begin
	if (ConflictAllString(ContainingMainRecord(x)) = 'caUnknown')
	or (ConflictAllString(ContainingMainRecord(x)) = 'caOnlyOne')
	or (ConflictAllString(ContainingMainRecord(x)) = 'caNoConflict') then begin
		Result := false;
		exit;
	end;

	sx := SortKeyEx(x);
	sy := SortKeyEx(y);

	if IsEmptyKey(sx) and IsEmptyKey(sy) then exit;

	Result := sx <> sy;

	// double check with lowercase values
	if Lowercase(sx) = Lowercase(sy) then
		Result := false;

	if Result and debug then begin
		PrintDebugE(x, y, '[CompareKeys] ' + tag);
	end;
end;

// ==================================================================
// Returns True if the native values are different and False if not
function CompareNativeValues(x, y: IInterface; s: string): boolean;
begin
	Result := (GetNativeValue(GetElement(x, s)) <> GetNativeValue(GetElement(y, s)));
end;

// ==================================================================
// Universal ElementBy
function GetElement(x: IInterface; s: string): IInterface;
begin
	if (pos('[', s) > 0) then
		Result := ElementByIP(x, s)
	else if (pos('\', s) > 0) then
		Result := ElementByPath(x, s)
	else if (s = Uppercase(s)) then
		Result := ElementBySignature(x, s)
	else
		Result := ElementByName(x, s);
end;

// ==================================================================
// Get element from list by some value
function GetElementByValue(el: IInterface; smth, somevalue: string): IInterface;
var
	i: integer;
	entry: IInterface;
begin
	Result := nil;
	for i := 0 to ElementCount(el) - 1 do begin
		entry := ElementByIndex(el, i);
		if geev(entry, smth) = somevalue then begin
			Result := entry;
			exit;
		end;
	end;
end;

// ==================================================================
// Retrieve a string between two expressions
function GetSubstring(input, expr1, expr2: string): string;
var
	pos1, pos2, len: integer;
begin
  pos1 := ItPos(expr1, input, 1) + length(expr1);
  pos2 := ItPos(expr2, input, 1);
  len := pos2 - pos1;
  Result := Copy(input, pos1, len);
end;

// ==================================================================
// Generate a list from the differences between list1 and list2
// -- list1: existing tags, for example
// -- list2: suggested tags, for example
function GetDiffList(list1, list2: TStringList): string;
var
	i, j: integer;
begin
	for i := list1.Count - 1 downto 0 do begin
		for j := list2.Count - 1 downto 0 do begin
			if list2[j] = list1[i] then
				list2.Delete(j);
		end;
	end;
	Result := list2.CommaText;
end;

// ==================================================================
// Return True if specific flag is set and False if not
function HasFlag(f: IInterface; s: string): boolean;
var
	flags, templateFlags, cellFlags, recordFlags: TStringList;
	i: integer;
begin
	// create flag lists
	flags := TStringList.Create;
	templateFlags := TStringList.Create;
	cellFlags := TStringList.Create;
	recordFlags := TStringList.Create;

	// assign flag lists
	templateFlags.DelimitedText := '"Use Traits=1", "Use Stats=2", "Use Factions=4", "Use Spell List=8", "Use Actor Effect List=8", "Use AI Data=16", "Use AI Packages=32", "Use Model/Animation=64", "Use Base Data=128", "Use Inventory=256", "Use Script=512", "Use Def Pack List=1024", "Use Attack Data=2048", "Use Keywords=4096"';
	cellFlags.DelimitedText := '"Is Interior Cell=1", "Has Water=2", "Behave Like Exterior=128", "Use Sky Lighting=256"';
	recordFlags.DelimitedText := '"ESM=1", "Deleted=32", "Border Region=64", "Turn Off Fire=128", "Casts Shadows=512", "Persistent Reference=1024", "Initially Disabled=2048", "Ignored=4096", "Visible When Distant=32768", "Dangerous=131072", "Compressed=262144", "Cant Wait=524288"';

	// merge flag lists
	flags.AddStrings(templateFlags);
	flags.AddStrings(cellFlags);
	flags.AddStrings(recordFlags);

	// find index
	i := StrToInt(lowercase(flags.Values[s]));

	// free flag lists
	flags.Free;
	templateFlags.Free;
	cellFlags.Free;
	recordFlags.Free;

	// return result
	Result := (GetNativeValue(f) and i > 0);
end;

// ==================================================================
// Returns True if the string contains only zeroes and False if not
function IsEmptyKey(s: string): boolean;
var
	i: integer;
begin
	for i := 1 to length(s) do begin
		if s[i] = '1' then begin
			Result := false;
			exit;
		end;
		Result := true;
	end;
end;

// ==================================================================
// Returns True if the x FormID is in the y list of FormIDs to ignore
// z is the file that contains the FormIDs to ignore
function InIgnoreList(x, y: string): boolean;
var
	formids: TStringList;
	i: integer;
begin
	formids := TStringList.Create;
	formids.DelimitedText := y;
	i := formids.IndexOf(x);
	formids.Free;
	Result := (i > -1);
end;

// ==================================================================
// Returns True if the x signature is in the y list of signatures
function InSignatureList(x, y: string): boolean;
var
	signatures: TStringList;
	i: integer;
begin
	signatures := TStringList.Create;
	signatures.DelimitedText := y;
	i := signatures.IndexOf(x);
	signatures.Free;
	Result := (i > -1);
end;

// ==================================================================
// Output bad tag messages to log
function GenerateTagOutput(tags: TStringList; singular, plural, nothing: string): integer;
begin
	if (tags.Count = 1) then
		AddMessage(IntToStr(tags.Count) + ' ' + singular);
	if (tags.Count > 1) then
		AddMessage(IntToStr(tags.Count) + ' ' + plural);
	if (tags.Count > 0) then begin
		AddMessage(Format('{{BASH:%s}}', [tags.DelimitedText]) + #13#10);
	end else begin
		AddMessage(nothing + #13#10);
	end;
end;

// ==================================================================
// Better SortKey
function SortKeyEx(e: IInterface): string;
var
	i: integer;
begin
	Result := GetEditValue(e);

	// manipulate result for model paths - sometimes the same paths have different cases
	if (pos('.nif', Lowercase(Result)) > 0) then
		Result := Lowercase(GetEditValue(e));

	for i := 0 to ElementCount(e) - 1 do begin
		if (pos('unknown', Lowercase(Name(ElementByIndex(e, i)))) > 0)
		or (pos('unused', Lowercase(Name(ElementByIndex(e, i)))) > 0) then
			exit;
		if (Result <> '') then
			Result := Result + ';' + SortKeyEx(ElementByIndex(e, i))
		else
			Result := SortKeyEx(ElementByIndex(e, i));
	end;
end;

// ==================================================================
// Check if the tag already exists
function TagExists(t: string): boolean;
begin
	Result := (slTags.IndexOf(t) <> -1);
end;

// ******************************************************************
// PROCEDURES
// ******************************************************************

// ==================================================================
// Add the tag if the tag does not exist
procedure AddTag(t: string);
begin
	if not TagExists(t) then slTags.Add(t);
end;

// ==================================================================
// Evaluate
// Determines whether two elements are different and suggests tags
// Not to be used when you need to know how two elements differ
procedure Evaluate(x, y: IInterface; tag: string; debug: boolean);
var
	i, j, k, l, m: integer;
	ex, ey: IInterface;
begin
	// Exit if the tag already exists
	if TagExists(tag) then exit;

	// exit if element is unknown or a flags element
	if (pos('unknown', Lowercase(Path(x))) > 0)
	or (pos('unused', Lowercase(Path(x))) > 0)
	or (pos('flags', Lowercase(Path(x))) > 0)
	or (pos('unknown', Lowercase(Path(y))) > 0)
	or (pos('unused', Lowercase(Path(y))) > 0)
	or (pos('flags', Lowercase(Path(y))) > 0) then
		exit;

	// Suggest tag if one element exists while the other does not
	if Assigned(x) <> Assigned(y) then begin
		if debug then PrintDebugE(x, y, '[Assigned] ' + tag);
		AddTag(tag);
		exit;
	end;

	// exit if the first element does not exist
	if not Assigned(x) then
		exit;

	// Suggest tag if the two elements are different
	if ElementCount(x) <> ElementCount(y) then begin
		if debug then PrintDebugE(x, y, '[ElementCount] ' + tag);
		AddTag(tag);
		exit;
	end else

	// suggest tag if the edit values of the two elements are different
	if Lowercase(GetEditValue(x)) <> Lowercase(GetEditValue(y)) then begin
		if debug then PrintDebugE(x, y, '[GetEditValue] ' + tag);
		AddTag(tag);
		exit;
	end else

	// compare any number of elements with CompareKeys
	if CompareKeys(x, y, debug) <> 0 then AddTag(tag);
end;

// ==================================================================
// EvaluateEx
procedure EvaluateEx(x, y: IInterface; z: string; tag: string; debug: boolean);
begin
	Evaluate(GetElement(x, z), GetElement(y, z), tag, debug);
end;

// ==================================================================
// Actors.ACBS
procedure CheckActorsACBS(e, m: IInterface; debug: boolean);
var
	f, fm: IInterface;
begin
	// define tag
	tag := 'Actors.ACBS';

	// exit if the tag exists
	if TagExists(tag) then exit;

	// assign ACBS elements
	f := GetElement(e, 'ACBS');
	fm := GetElement(m, 'ACBS');

	// evaluate Flags if the Use Base Data flag is not set
	if (wbGameMode = gmTES4) then begin
		if CompareKeys(GetElement(f, 'Flags'), GetElement(fm, 'Flags'), debug) then begin
			AddTag(tag);
			exit;
		end;
	end else begin
		if not CompareFlagsOr(f, fm, 'Template Flags', 'Use Base Data') then begin
			if CompareKeys(GetElement(f, 'Flags'), GetElement(fm, 'Flags'), debug) then begin
				AddTag(tag);
				exit;
			end;
		end;
	end;

	// evaluate properties
	EvaluateEx(f, fm, 'Fatigue', tag, debug);
	EvaluateEx(f, fm, 'Level', tag, debug);
	EvaluateEx(f, fm, 'Calc min', tag, debug);
	EvaluateEx(f, fm, 'Calc max', tag, debug);
	EvaluateEx(f, fm, 'Speed Multiplier', tag, debug);
	EvaluateEx(e,  m, 'DATA\Base Health', tag, debug);

	// evaluate Barter Gold if the Use AI Data flag is not set
	if (wbGameMode = gmTES4) then begin
		EvaluateEx(f, fm, 'Barter gold', tag, debug);
	end else begin
		if not CompareFlagsOr(f, fm, 'Template Flags', 'Use AI Data') then
			EvaluateEx(f, fm, 'Barter gold', tag, debug);
	end;
end;

// ==================================================================
// Actors.AIData
procedure CheckActorsAIData(e, m: IInterface; debug: boolean);
var
	a, am: IInterface;
begin
	// define tag
	tag := 'Actors.AIData';

	// exit if tag exists
	if TagExists(tag) then exit;

	// assign AIDT elements
	a := GetElement(e, 'AIDT');
	am := GetElement(m, 'AIDT');

	// evaluate AIDT properties
	EvaluateEx(a, am, 'Aggression', tag, debug);
	EvaluateEx(a, am, 'Confidence', tag, debug);
	EvaluateEx(a, am, 'Energy level', tag, debug);
	EvaluateEx(a, am, 'Responsibility', tag, debug);
	EvaluateEx(a, am, 'Teaches', tag, debug);
	EvaluateEx(a, am, 'Maximum training level', tag, debug);

	// v1.3.3: check flags for Buys/Sells and Services
	if CompareNativeValues(a, am, 'Buys/Sells and Services') then begin
		if debug then PrintDebugE(a, am, '[CompareNativeValues] ' + tag);
		AddTag(tag);
	end;
end;

// ==================================================================
// Actors.AIPackages
procedure CheckActorsAIPackages(e, m: IInterface; debug: boolean);
begin
	// define tag
	tag := 'Actors.AIPackages';

	// exit if tag exists
	if TagExists(tag) then exit;

	// evaluate Packages property
	EvaluateEx(e, m, 'Packages', tag, debug);
end;

// ==================================================================
// Factions
procedure CheckActorsFactions(e, m: IInterface; debug: boolean);
var
	f, fm: IInterface;
begin
	// define tag
	tag := 'Factions';

	// exit if tag exists
	if TagExists(tag) then exit;

	// assign Factions properties
	f := GetElement(e, 'Factions');
	fm := GetElement(m, 'Factions');

	// add tag if the Factions properties differ
	if Assigned(f) <> Assigned(fm) then begin
		if debug then PrintDebugE(e, m, '[Assigned] ' + tag);
		AddTag(tag);
		exit;
	end;

	// exit if the Factions property in the control record does not exist
	if not Assigned(f) then exit;

	// evaluate Factions properties
	if CompareKeys(f, fm, debug) then AddTag(tag);
end;

// ==================================================================
// Actors.Skeleton
procedure CheckActorsSkeleton(e, m: IInterface; debug: boolean);
var
	x, y: IInterface;
begin
	// define tag
	tag := 'Actors.Skeleton';

	// exit if tag exists
	if TagExists(tag) then exit;

	// assign Model elements
	x := GetElement(e, 'Model');
	y := GetElement(m, 'Model');

	// exit if the Model property does not exist in the control record
	if not Assigned(x) then exit;

	// evaluate properties
	EvaluateEx(x, y, 'MODL', tag, debug);
	EvaluateEx(x, y, 'MODB', tag, debug);
	EvaluateEx(x, y, 'MODT', tag, debug);
end;

// ==================================================================
// Actors.Stats
procedure CheckActorsStats(e, m: IInterface; debug: boolean);
var
	d, dm: IInterface;
	sig: string;
begin
	// define tag
	tag := 'Actors.Stats';

	// exit if tag exists
	if TagExists(tag) then exit;

	// get record signature
	sig := Signature(e);

	// assign DATA elements
	d := GetElement(e, 'DATA');
	dm := GetElement(m, 'DATA');

	// evaluate CREA properties
	if (sig = 'CREA') then begin
		EvaluateEx(d, dm, 'Health', tag, debug);
		EvaluateEx(d, dm, 'Combat Skill', tag, debug);
		EvaluateEx(d, dm, 'Magic Skill', tag, debug);
		EvaluateEx(d, dm, 'Stealth Skill', tag, debug);
		EvaluateEx(d, dm, 'Attributes', tag, debug);
	end;

	// evaluate NPC_ properties
	if (sig = 'NPC_') then begin
		EvaluateEx(d, dm, 'Base Health', tag, debug);
		EvaluateEx(d, dm, 'Attributes', tag, debug);
		EvaluateEx(e, m, 'DNAM\Skill Values', tag, debug);
		EvaluateEx(e, m, 'DNAM\Skill Offsets', tag, debug);
	end;
end;

// ==================================================================
// C.Climate
procedure CheckCellClimate(e, m: IInterface; debug: boolean);
var
	d, dm: IInterface;
begin
	// define tag
	tag := 'C.Climate';

	// exit if tag exists
	if TagExists(tag) then exit;

	// add tag if the Behave Like Exterior flag is set ine one record but not the other
	if CompareFlagsEx(e, m, 'DATA', 'Behave Like Exterior') then begin
		if debug then PrintDebugE(e, m, '[CompareFlagsEx] ' + tag);
		AddTag(tag);
		exit;
	end;

	// evaluate additional property
	EvaluateEx(e, m , 'XCCM', tag, debug);
end;


// ==================================================================
// C.RecordFlags
procedure CheckCellRecordFlags(e, m: IInterface; debug: boolean);
var
	sig: string;
	f, fm, rf, rfm: IInterface;
begin
	// define tag
	tag := 'C.RecordFlags';
	sig := Signature(e);

	// exit if tag exists
	if TagExists(tag) then exit;

	// set Record Flags elements
	rf := GetElement(e, 'Record Header\Record Flags');
	rfm := GetElement(m, 'Record Header\Record Flags');

	// compare Record Flags elements
	if CompareKeys(rf, rfm, debug) then begin
		if debug then PrintDebugE(rf, rfm, '[CompareKeys] ' + tag);
		AddTag(tag);
	end;
end;

// ==================================================================
// C.SkyLighting
procedure CheckCellSkyLighting(e, m: IInterface; debug: boolean);
begin
	// define tag
	tag := 'C.SkyLighting';

	// exit if tag exists
	if TagExists(tag) then exit;

	// add tag if the Behave Like Exterior flag is set ine one record but not the other
	if CompareFlagsEx(e, m, 'DATA', 'Use Sky Lighting') then begin
		if debug then PrintDebugE(e, m, '[CompareFlagsEx] ' + tag);
		AddTag(tag);
		exit;
	end;
end;

// ==================================================================
// C.Water
procedure CheckCellWater(e, m: IInterface; debug: boolean);
begin
	// define tag
	tag := 'C.Water';

	// exit if tag exists
	if TagExists(tag) then exit;

	// add tag if Has Water flag is set in one record but not the other
	if CompareFlagsEx(e, m, 'DATA', 'Has Water') then begin
		if debug then PrintDebugE(e, m, '[CompareFlagsEx] ' + tag);
		AddTag(tag);
		exit;
	end;

	// exit if Is Interior Cell is set in either record
	if CompareFlagsOr(e, m, 'DATA', 'Is Interior Cell') then exit;

	// evaluate properties
	EvaluateEx(e, m, 'XCLW', tag, debug);
	EvaluateEx(e, m, 'XCWT', tag, debug);
end;

// ==================================================================
// Delev, Relev
procedure CheckDelevRelev(e, m: IInterface; debug: boolean);
var
	i, matched: integer;
	entries, entriesmaster: IInterface; // leveled list entries
	ent, entm: IInterface; // leveled list entry
	coed, coedm: IInterface; // extra data
	s1, s2: string; // sortkeys for extra data, sortkey is a compact text representation of element's values
begin
	// nothing to do if already tagged
	if TagExists('Delev') and TagExists('Relev') then exit;

	// get Leveled List Entries
	entries := GetElement(e, 'Leveled List Entries');
	entriesmaster := GetElement(m, 'Leveled List Entries');

	if not Assigned(entries) or not Assigned(entriesmaster) then
		exit;

	// count matched on reference entries
	matched := 0;
	// iterate through all entries
	for i := 0 to ElementCount(entries) - 1 do begin
		ent := ElementByIndex(entries, i);
		// find the same entry in master
		entm := GetElementByValue(entriesmaster, 'LVLO\Reference', geev(ent, 'LVLO\Reference'));

		if Assigned(entm) then begin
			Inc(matched);

			if CompareNativeValues(ent, entm, 'LVLO\Level') or CompareNativeValues(ent, entm, 'LVLO\Count') then begin
				if debug then PrintDebugE(ent, entm, '[CompareNativeValues] ' + 'Relev');
				AddTag('Relev');
				exit;
			end;

			// Relev check for changed level, count, extra data
			if not (wbGameMode = gmTES4) then begin
				coed := GetElement(ent, 'COED');
				coedm := GetElement(entm, 'COED');
				if Assigned(coed) then
					s1 := SortKeyEx(coed) else s1 := '';
				if Assigned(coedm) then
					s2 := SortKeyEx(coedm) else s2 := '';
				if (s1 <> s2) then begin
					if debug then PrintDebugE(ent, entm, '[SortKeyEx] ' + 'Relev');
					AddTag('Relev');
					exit;
				end;
			end;
		end;
	end;

	// if number of matched entries less than in master list
	if matched < ElementCount(entriesmaster) then begin
		if debug then PrintDebugE(entries, entriesmaster, '[ElementCount] ' + 'Delev');
		AddTag('Delev');
		exit;
	end;
end;

// ==================================================================
// Destructible
procedure CheckDestructible(e, m: IInterface; debug: boolean);
var
	d, dm, df, dfm, dd, dmd: IInterface;
begin
	// define tag
	tag := 'Destructible';

	// exit if tag exists
	if TagExists(tag) then exit;

	// assign Destructable elements
	d := GetElement(e, 'Destructable');
	dm := GetElement(m, 'Destructable');

	if Assigned(d) <> Assigned (dm) then begin
		if debug then PrintDebugE(d, dm, '[Assigned] ' + tag);
		AddTag(tag);
		exit;
	end;

	dd := GetElement(d, 'DEST');
	dmd := GetElement(dm, 'DEST');

	// evaluate Destructable properties
	EvaluateEx(dd, dmd, 'Health', tag, debug);
	EvaluateEx(dd, dmd, 'Count', tag, debug);
	EvaluateEx(d, dm, 'Stages', tag, debug);

	// assign Destructable flags
	if not (wbGameMode = gmTES5) then begin
		df := GetElement(dd, 'Flags');
		dfm := GetElement(dmd, 'Flags');
		if Assigned(df) or Assigned(dfm) then begin
			// add tag if Destructable flags exist in one record
			if Assigned(df) <> Assigned(dfm) then begin
				if debug then PrintDebugE(df, dfm, '[Assigned] ' + tag);
				AddTag(tag);
				exit;
			end;
			// evaluate Destructable flags
			if CompareKeys(df, dfm, debug) then AddTag(tag);
		end;
	end;
end;

// ==================================================================
// Graphics
procedure CheckGraphics(e, m: IInterface; debug: boolean);
var
	icon, iconm, modl, modlm, fpf, fpfm, gf, gfm, bpf, bpfm, rf, rfm: IInterface;
	sig: string;
	i: integer;
begin
	// define tag
	tag := 'Graphics';

	// exit if tag exists
	if TagExists(tag) then exit;

	// get signature of control record
	sig := Signature(e);

	// evaluate Icon properties
	if InSignatureList(sig, 'ALCH, AMMO, APPA, BOOK, BSGN, CLAS, INGR, KEYM, LIGH, LSCR, LTEX, MGEF, MISC, REGN, SGST, SLGM, TREE, WEAP') then
		EvaluateEx(e, m, 'Icon', tag, debug);

	// evaluate Model properties
	if InSignatureList(sig, 'ACTI, ALCH, AMMO, APPA, BOOK, DOOR, FLOR, FURN, GRAS, INGR, KEYM, LIGH, MGEF, MISC, SGST, SLGM, STAT, TREE, WEAP') then
		EvaluateEx(e, m, 'Model', tag, debug);

	// evaluate ARMO properties
	if (sig = 'ARMO') then begin
		// Shared
		EvaluateEx(e, m, 'Male world model', tag, debug);
		EvaluateEx(e, m, 'Female world model', tag, debug);

		// ARMO - Oblivion
		if (wbGameMode = gmTES4) then begin
			// evaluate Icon properties
			EvaluateEx(e, m, 'Icon', tag, debug);
			EvaluateEx(e, m, 'Icon 2 (female)', tag, debug);

			// assign First Person Flags elements
			fpf := GetElement(e, 'BODT\First Person Flags');
			if not Assigned(fpf) then exit;
			fpfm := GetElement(m, 'BODT\First Person Flags');

			// evaluate First Person Flags
			if CompareKeys(fpf, fpfm, debug) then begin
				AddTag(tag);
				exit;
			end;

			// assign General Flags elements
			gf := GetElement(e, 'BODT\General Flags');
			if not Assigned(gf) then exit;
			gfm := GetElement(m, 'BODT\General Flags');

			// evaluate General Flags
			if CompareKeys(gf, gfm, debug) then begin
				AddTag(tag);
				exit;
			end;
		end;

		// ARMO - FO3, FNV
		if (wbGameMode = gmFO3) or (wbGameMode = gmFNV) then begin
			// evaluate Icon properties
			EvaluateEx(e, m, 'ICON', tag, debug);
			EvaluateEx(e, m, 'ICO2', tag, debug);

			// assign First Person Flags elements
			fpf := GetElement(e, 'BMDT\Biped Flags');
			if not Assigned(fpf) then exit;
			fpfm := GetElement(m, 'BMDT\Biped Flags');

			// evaluate First Person Flags
			if CompareKeys(fpf, fpfm, debug) then begin
				AddTag(tag);
				exit;
			end;

			// assign General Flags elements
			gf := GetElement(e, 'BMDT\General Flags');
			if not Assigned(gf) then exit;
			gfm := GetElement(m, 'BMDT\General Flags');

			// evaluate General Flags
			if CompareKeys(gf, gfm, debug) then begin
				AddTag(tag);
				exit;
			end;
		end;

		// ARMO - TES5
		if (wbGameMode = gmTES5) then begin
			// evaluate Icon properties
			EvaluateEx(e, m, 'Icon', tag, debug);
			EvaluateEx(e, m, 'Icon 2 (female)', tag, debug);

			// evaluate Biped Model properties
			EvaluateEx(e, m, 'Male world model', tag, debug);
			EvaluateEx(e, m, 'Female world model', tag, debug);

			// assign First Person Flags elements
			fpf := GetElement(e, 'BOD2\First Person Flags');
			if not Assigned(fpf) then exit;
			fpfm := GetElement(m, 'BOD2\First Person Flags');

			// evaluate First Person Flags
			if CompareKeys(fpf, fpfm, debug) then begin
				AddTag(tag);
				exit;
			end;

			// assign General Flags elements
			gf := GetElement(e, 'BOD2\General Flags');
			if not Assigned(gf) then exit;
			gfm := GetElement(m, 'BOD2\General Flags');

			// evaluate General Flags
			if CompareKeys(gf, gfm, debug) then begin
				AddTag(tag);
				exit;
			end;
		end;
	end;

	// evaluate CREA properties
	if (sig ='CREA') then begin
		EvaluateEx(e, m, 'NIFZ', tag, debug);
		EvaluateEx(e, m, 'NIFT', tag, debug);
	end;

	// evaluate EFSH properties
	if (sig = 'EFSH') then begin
		// evaluate Record Flags
		rf := GetElement(e, 'Record Header\Record Flags');
		rfm := GetElement(m, 'Record Header\Record Flags');

		if CompareKeys(rf, rfm, debug) then begin
			AddTag(tag);
			exit;
		end;

		// evaluate Icon properties
		EvaluateEx(e, m, 'ICON', tag, debug);
		EvaluateEx(e, m, 'ICO2', tag, debug);

		// evaluate other properties
		EvaluateEx(e, m, 'NAM7', tag, debug);
		if (wbGameMode = gmTES5) then begin
			EvaluateEx(e, m, 'NAM8', tag, debug);
			EvaluateEx(e, m, 'NAM9', tag, debug);
		end;
		EvaluateEx(e, m, 'DATA', tag, debug);
	end;

	// v1.4: evaluate MGEF properties
	if (sig = 'MGEF') and (wbGameMode = gmTES5) then begin
		EvaluateEx(e, m, 'Magic Effect Data\DATA\Casting Light', tag, debug);
		EvaluateEx(e, m, 'Magic Effect Data\DATA\Hit Shader', tag, debug);
		EvaluateEx(e, m, 'Magic Effect Data\DATA\Enchant Shader', tag, debug);
	end;

	// evaluate Material property
	if (sig = 'STAT') then
		EvaluateEx(e, m, 'DNAM\Material', tag, debug);
end;

// ==================================================================
// Invent
procedure CheckInvent(e, m: IInterface; debug: boolean);
var
	items, itemsmaster: IInterface;
begin
	// define tag
	tag := 'Invent';

	// exit if tag exists
	if TagExists(tag) then exit;

	// assign Items properties
	items := GetElement(e, 'Items');
	itemsmaster := GetElement(m, 'Items');

	// add tag if Items properties exist in one record but not the other
	if Assigned(items) <> Assigned(itemsmaster) then begin
		if debug then PrintDebugE(e, m, '[Assigned] ' + tag);
		AddTag(tag);
		exit;
	end;

	// exit if Items property does not exist in control record
	if not Assigned(items) then exit;

	// Items are sorted, so we don't need to compare by individual item
	// SortKey combines all the items data
	if CompareKeys(items, itemsmaster, debug) then AddTag(tag);
end;

// ==================================================================
// NpcFaces
procedure CheckNPCFaces(e, m: IInterface; debug: boolean);
begin
	// define tag
	tag := 'NpcFaces';

	// exit if tag exists
	if TagExists(tag) then exit;

	// evaluate properties
	EvaluateEx(e, m, 'HNAM', tag, debug);
	EvaluateEx(e, m, 'LNAM', tag, debug);
	EvaluateEx(e, m, 'ENAM', tag, debug);
	EvaluateEx(e, m, 'HCLR', tag, debug);
	EvaluateEx(e, m, 'FaceGen Data', tag, debug);
end;

// ==================================================================
// Body-F | Body-M | Body-Size-F | Body-Size-M
procedure CheckRaceBody(e, m: IInterface; tag: string; debug: boolean);
begin
	// define tag
	if TagExists(tag) then exit;

	// evaluate Body-F properties
	if (tag = 'Body-F') then
	EvaluateEx(e, m, 'Body Data\Female Body Data\Parts', tag, debug);

	// evaluate Body-M properties
	if (tag = 'Body-M') then
	EvaluateEx(e, m, 'Body Data\Male Body Data\Parts', tag, debug);

	// evaluate Body-Size-F properties
	if (tag = 'Body-Size-F') then begin
		EvaluateEx(e, m, 'DATA\Female Height', tag, debug);
		EvaluateEx(e, m, 'DATA\Female Weight', tag, debug);
	end;

	// evaluate Body-Size-M properties
	if (tag = 'Body-Size-M') then begin
		EvaluateEx(e, m, 'DATA\Male Height', tag, debug);
		EvaluateEx(e, m, 'DATA\Male Weight', tag, debug);
	end;
end;

// ==================================================================
// R.Ears | R.Head | R.Mouth | R.Teeth
procedure CheckRaceHead(e, m: IInterface; tag: string; debug: boolean);
begin
	// exit if tag exists
	if TagExists(tag) then exit;

	// evaluate R.Head properties
	if (tag = 'R.Head') then begin
		EvaluateEx(e, m, 'Head Data\Male Head Data\Parts\[0]', tag, debug);
		EvaluateEx(e, m, 'Head Data\Female Head Data\Parts\[0]', tag, debug);
		EvaluateEx(e, m, 'FaceGen Data', tag, debug);
	end;

	// evaluate R.Ears properties
	if (tag = 'R.Ears') then begin
		EvaluateEx(e, m, 'Head Data\Male Head Data\Parts\[1]', tag, debug);
		EvaluateEx(e, m, 'Head Data\Female Head Data\Parts\[1]', tag, debug);
	end;

	// evaluate R.Mouth properties
	if (tag = 'R.Mouth') then begin
		EvaluateEx(e, m, 'Head Data\Male Head Data\Parts\[2]', tag, debug);
		EvaluateEx(e, m, 'Head Data\Female Head Data\Parts\[2]', tag, debug);
	end;

	// evaluate R.Teeth properties
	if (tag = 'R.Teeth') then begin
		EvaluateEx(e, m, 'Head Data\Male Head Data\Parts\[3]', tag, debug);
		EvaluateEx(e, m, 'Head Data\Female Head Data\Parts\[3]', tag, debug);

		// FO3
		if (wbGameMode = gmFO3) then begin
			EvaluateEx(e, m, 'Head Data\Male Head Data\Parts\[4]', tag, debug);
			EvaluateEx(e, m, 'Head Data\Female Head Data\Parts\[4]', tag, debug);
		end;
	end;
end;

// ==================================================================
// Sound
procedure CheckSound(e, m: IInterface; debug: boolean);
var
	sig: string;
begin
	tag := 'Sound';
	if TagExists(tag) then exit;

	sig := Signature(e);

	// Activators, Containers, Doors, and Lights
	if InSignatureList(sig, 'ACTI, CONT, DOOR, LIGH') then
		EvaluateEx(e, m, 'SNAM', tag, debug);

	// Activators
	if (sig = 'ACTI') then
		EvaluateEx(e, m, 'VNAM', tag, debug);

	// Containers
	if (sig = 'CONT') then begin
		EvaluateEx(e, m, 'QNAM', tag, debug);
		if not (wbGameMode = gmFO3) or not (wbGameMode = gmTES5) then
			EvaluateEx(e, m, 'RNAM', tag, debug); // FO3 and TESV don't have this element
	end;

	// Creatures
	if (sig = 'CREA') then begin
		EvaluateEx(e, m, 'WNAM', tag, debug);
		EvaluateEx(e, m, 'CSCR', tag, debug);
		EvaluateEx(e, m, 'Sound Types', tag, debug);
	end;

	// Doors
	if (sig = 'DOOR') then begin
		EvaluateEx(e, m, 'ANAM', tag, debug);
		EvaluateEx(e, m, 'BNAM', tag, debug);
	end;

	// Lights - this is checked above

	// Magic Effects
	if (sig = 'MGEF') then begin
		// TES5
		if (wbGameMode = gmTES5) then
			EvaluateEx(e, m, 'SNDD', tag, debug);

		// FO3, FNV, TES4
		if not (wbGameMode = gmTES5) then begin
			EvaluateEx(e, m, 'DATA\Effect sound', tag, debug);
			EvaluateEx(e, m, 'DATA\Bolt sound', tag, debug);
			EvaluateEx(e, m, 'DATA\Hit sound', tag, debug);
			EvaluateEx(e, m, 'DATA\Area sound', tag, debug);
		end;
	end;

	// Weather
	if (sig = 'WTHR') then
		EvaluateEx(e, m, 'Sounds', tag, debug);
end;

// ==================================================================
// SpellStats
procedure CheckSpellStats(e, m: IInterface; debug: boolean);
begin
	// define tag
	tag := 'SpellStats';

	// exit if tag exists
	if TagExists(tag) then exit;

	// evaluate properties
	EvaluateEx(e, m, 'FULL', tag, debug);
	EvaluateEx(e, m, 'SPIT', tag, debug);
end;

// ==================================================================
// Stats - v1.4: 200% implementation (evaluates more than needed; too much work to narrow down)
procedure CheckStats(e, m: IInterface; debug: boolean);
var
	d, dm: IInterface;
	sig: string;
begin
	// define tag
	tag := 'Stats';

	// exit if tag exists
	if TagExists(tag) then exit;

	// get record signature
	sig := Signature(e);

	// Ingestibles, Ammunition, Alchemical Apparatuses, Armor, Books, Clothing, Ingredients, Keys, Lights, Misc. Items, Sigil Stones, Soul Gems, Weapons
	if InSignatureList(sig, 'ALCH, AMMO, APPA, ARMO, BOOK, CLOT, INGR, KEYM, LIGH, MISC, SGST, SLGM, WEAP') then begin
		EvaluateEx(e, m, 'EDID', tag, debug);
		EvaluateEx(e, m, 'DATA', tag, debug);
	end;

	// ARMA
	if InSignatureList(sig, 'ARMA, ARMO, WEAP') then
		EvaluateEx(e, m, 'DNAM', tag, debug);

	// ARMO
	if (sig = 'WEAP') then
		EvaluateEx(e, m, 'CRDT', tag, debug);
end;

// ==================================================================
// Debug Message
procedure PrintDebugE(x, y: IInterface; t: string);
begin
	AddMessage(t + ': ' + TrimLeft(FullPath(x)));
	AddMessage(t + ': ' + TrimLeft(FullPath(y)));
end;

// ==================================================================
// Debug Message
procedure PrintDebugS(x, y: IInterface; p, t: string);
begin
	AddMessage(t + ': ' + TrimLeft(FullPath(GetElement(x, p))));
	AddMessage(t + ': ' + TrimLeft(FullPath(GetElement(y, p))));
end;


// ******************************************************************
// PROCESSOR
// ******************************************************************

// ==================================================================
// Main
function Initialize: integer;
var
	tmplLoaded: string;
begin
	// clear
	ClearMessages();

	// prompt to write tags to file header
	optionSelected := MessageDlg('Do you want to add suggested tags to the file header?', mtConfirmation, [mbYes, mbNo, mbAbort], 0);

	// exit if the user aborted
	if optionSelected = mrAbort then exit;

	// create list of tags
	slTags := TStringList.Create;
	slTags.Delimiter := ','; // separated by comma

	AddMessage(#13#10 + '-------------------------------------------------------------------------------');
	if (wbGameMode = gmFO3) then AddMessage('Using record structure for Fallout 3');
	if (wbGameMode = gmFNV) then AddMessage('Using record structure for Fallout: New Vegas');
	if (wbGameMode = gmTES4) then AddMessage('Using record structure for The Elder Scrolls IV: Oblivion');
	if (wbGameMode = gmTES5) then AddMessage('Using record structure for The Elder Scrolls V: Skyrim');
	AddMessage('-------------------------------------------------------------------------------' + #13#10);
end;

// ==================================================================
// Process
function Process(e: IInterface): integer;
var
	o: IInterface; // master record
	sig, fm: string;
	i: integer;
begin

	//AddMessage('[PROCESSING] ' + FullPath(e));

	// exit conditions
	if (optionSelected = mrAbort)								// user aborted
	or (Signature(e) = 'TES4')									// record is the file header
	or (ConflictAllString(e) = 'caUnknown')			// unknown conflict status
	or (ConflictAllString(e) = 'caOnlyOne')			// record neither conflicts nor overrides
	or (ConflictAllString(e) = 'caNoConflict') then	// no conflict
		exit;

	// get file and file name
	f := GetFile(e);
	fn := GetFileName(f);

	// exit if the record should not be processed
	if (fn = 'Dawnguard.esm')
	and InIgnoreList(HexFormID(e), '00016BCF, 0001EE6D, 0001FA4C, 00039F67, 0006C3B6') then
		exit;

	// get master record
	o := Master(e);

	// exit if the override does not exist
	if not Assigned(o) then exit;

	// if record overrides several masters, then get the last one
	if OverrideCount(o) > 1 then
		o := OverrideByIndex(o, OverrideCount(o) - 2);

	// v1.3.4: stop processing deleted records to avoid errors
	if GetIsDeleted(e) or GetIsDeleted(o) then exit;

	// get record signature
	sig := Signature(e);

	// -------------------------------------------------------------------------------
	// GROUP: [1] Supported tag exclusive to FNV
	// -------------------------------------------------------------------------------
	if (wbGameMode = gmFNV) then begin
	// TAG: WeaponMods
		if (sig = 'WEAP') then
			EvaluateEx(e, o, 'Weapon Mods', 'WeaponMods', true);
	end; // end game

	// -------------------------------------------------------------------------------
	// GROUP: Supported tags exclusive to TES4
	// -------------------------------------------------------------------------------
	if (wbGameMode = gmTES4) then begin

	// TAG: Actors.Spells
		if InSignatureList(sig, 'CREA, NPC_') then
			EvaluateEx(e, o, 'Spells', 'Actors.Spells', true);

	// TAG: Creatures.Blood
		if (sig = 'CREA') then begin
			EvaluateEx(e, o, 'NAM0', 'Creatures.Blood', true);
			EvaluateEx(e, o, 'NAM1', 'Creatures.Blood', true);
		end;

	// TODO: Npc.EyesOnly - NOT IMPLEMENTED

	// TODO: Npc.HairOnly - NOT IMPLEMENTED

	// TODO: R.AddSpells - NOT IMPLEMENTED

		if (sig = 'RACE') then begin
	// TAG: R.ChangeSpells
			EvaluateEx(e, o, 'Spells', 'R.ChangeSpells', true);

	// TAG: R.Attributes-F
			EvaluateEx(e, o, 'ATTR\Female', 'R.Attributes-F', true);

	// TAG: R.Attributes-M
			EvaluateEx(e, o, 'ATTR\Male', 'R.Attributes-M', true);
		end;

	// TAG: Roads
		if (sig = 'ROAD') then
			EvaluateEx(e, o, 'PGRP', 'Roads', true);

	// TAG: SpellStats
		if (sig = 'SPEL') then
			CheckSpellStats(e, o, true);

	end; // end game

	// -------------------------------------------------------------------------------
	// GROUP: [1] Supported tags exclusive to TES5
	// -------------------------------------------------------------------------------
	if (wbGameMode = gmTES5) then begin
		if (sig = 'CELL') then begin
	// TAG: C.Location
			EvaluateEx(e, o, 'XLCN', 'C.Location', true);

	// TAG: C.Regions
			EvaluateEx(e, o, 'XCLR', 'C.Regions', true);

	// TAG: C.SkyLighting
			CheckCellSkyLighting(e, o, true);
		end;
	end; // end game

	// -------------------------------------------------------------------------------
	// GROUP: [2] Supported tags exclusive to FO3 and FNV
	// -------------------------------------------------------------------------------
	if (wbGameMode = gmFO3) or (wbGameMode = gmFNV) then begin
	// TAG: Destructible
		if InSignatureList(sig, 'ACTI, ALCH, AMMO, BOOK, CONT, DOOR, FURN, IMOD, KEYM, MISC, MSTT, PROJ, TACT, TERM, WEAP') then
			CheckDestructible(e, o, true);

	// TAG: Destructible - special handling for CREA and NPC_ record types
		if InSignatureList(sig, 'CREA, NPC_') then
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Model/Animation') then
				CheckDestructible(e, o, true);
	end; // end game

	// -------------------------------------------------------------------------------
	// GROUP: [3] Supported tags exclusive to FO3, FNV, and TES4
	// -------------------------------------------------------------------------------
	if (wbGameMode = gmFO3) or (wbGameMode = gmFNV) or (wbGameMode = gmTES4) then begin
	// TAG: Factions
		if InSignatureList(sig, 'CREA, NPC_') then begin
			if (wbGameMode = gmTES4) then begin
				CheckActorsFactions(e, o, true);
			end else begin
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Factions') then
				CheckActorsFactions(e, o, true);
			end;
		end;

	// TAG: Relations
		if (sig = 'FACT') then
			EvaluateEx(e, o, 'Relations', 'Relations', true);
	end; // end game

	// -------------------------------------------------------------------------------
	// GROUP: [3] Supported tags exclusive to FO3, FNV, and TES5
	// -------------------------------------------------------------------------------
	if (wbGameMode = gmFO3) or (wbGameMode = gmFNV) or (wbGameMode = gmTES5) then begin
		if InSignatureList(sig, 'CREA, NPC_') then begin
	// TAG: Actors.ACBS
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Stats') then
				CheckActorsACBS(e, o, true);

	// TAG: Actors.AIData
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use AI Data') then
				CheckActorsAIData(e, o, true);

	// TAG: Actors.AIPackages
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use AI Packages') then
				CheckActorsAIPackages(e, o, true);

	// TAG: Actors.Anims
			if (sig = 'CREA') then
				if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Model/Animation') then
					EvaluateEx(e, o, 'KFFZ', 'Actors.Anims', true);

			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Traits') then begin
	// TAG: Actors.CombatStyle
				EvaluateEx(e, o, 'ZNAM', 'Actors.CombatStyle', true);

	// TAG: Actors.DeathItem
				EvaluateEx(e, o, 'INAM', 'Actors.DeathItem', true);
			end;

	// TAG: Actors.Skeleton
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Model/Animation') then
				CheckActorsSkeleton(e, o, true);

	// TAG: Actors.Stats
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Stats') then
				CheckActorsStats(e, o, true);

	// TODO: IIM - NOT IMPLEMENTED

	// TODO: MustBeActiveIfImported - NOT IMPLEMENTED

			if (sig = 'NPC_') then begin
				if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Traits') then begin
	// TAG: NPC.Class
					EvaluateEx(e, o, 'CNAM', 'NPC.Class', true);

	// TAG: NPC.Race
					EvaluateEx(e, o, 'RNAM', 'NPC.Race', true);
				end;

	// TAG: NPCFaces
				if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Model/Animation') then
					CheckNPCFaces(e, o, true);
			end;

	// TAG: Scripts
			if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Script') then
				EvaluateEx(e, o, 'SCRI', 'Scripts', true);
		end;

		if (sig = 'CELL') then begin
	// TAG: C.Acoustic
			EvaluateEx(e, o, 'XCAS', 'C.Acoustic', true);

	// TAG: C.Encounter
			EvaluateEx(e, o, 'XEZN', 'C.Encounter', true);

	// TAG: C.ImageSpace
			EvaluateEx(e, o, 'XCIM', 'C.ImageSpace', true);
		end;

		if (sig = 'RACE') then begin
	// TAG: Body-F
			CheckRaceBody(e, o, 'Body-F', true);

	// TAG: Body-M
			CheckRaceBody(e, o, 'Body-M', true);

	// TAG: Body-Size-F
			CheckRaceBody(e, o, 'Body-Size-F', true);

	// TAG: Body-Size-M
			CheckRaceBody(e, o, 'Body-Size-M', true);

	// TAG: Eyes
			EvaluateEx(e, o, 'ENAM', 'Eyes', true);

	// TAG: Hair
			EvaluateEx(e, o, 'HNAM', 'Hair', true);

	// TAG: R.Description
			EvaluateEx(e, o, 'DESC', 'R.Description', true);

	// TAG: R.Ears
			CheckRaceHead(e, o, 'R.Ears', true);

	// TAG: R.Head
			CheckRaceHead(e, o, 'R.Head', true);

	// TAG: R.Mouth
			CheckRaceHead(e, o, 'R.Mouth', true);

	// TAG: R.Relations
			EvaluateEx(e, o, 'Relations', 'R.Relations', true);

	// TAG: R.Skills
			EvaluateEx(e, o, 'DATA\Skill Boosts', 'R.Skills', true);

	// TAG: R.Teeth
			CheckRaceHead(e, o, 'R.Teeth', true);

	// TAG: Voice-F
			EvaluateEx(e, o, 'VTCK\Voice #1 (Female)', 'Voice-F', true);

	// TAG: Voice-M
			EvaluateEx(e, o, 'VTCK\Voice #0 (Male)', 'Voice-M', true);
		end;

	// TODO: ScriptContents - SHOULD NOT BE IMPLEMENTED
		// -- According to the Wrye Bash Readme: "Should not be used. Can cause serious issues."

	// TAG: Scripts
		if InSignatureList(sig, 'ACTI, ALCH, ARMO, CONT, DOOR, FLOR, FURN, INGR, KEYM, LIGH, LVLC, MISC, QUST, WEAP') then
			EvaluateEx(e, o, 'SCRI', 'Scripts', true);
	end; // end game

	// -------------------------------------------------------------------------------
	// GROUP: [4] Supported tags exclusive to FO3, FNV, TES4, and TES5
	// -------------------------------------------------------------------------------
	if (wbGameMode = gmFO3) or (wbGameMode = gmFNV) or (wbGameMode = gmTES4) or (wbGameMode = gmTES5) then begin
		if (sig = 'CELL') then begin
	// TAG: C.Climate
			CheckCellClimate(e, o, true);

	// TAG: C.Light
			EvaluateEx(e, o, 'XCLL', 'C.Light', true);

	// TAG: C.Music
			EvaluateEx(e, o, 'XCMO', 'C.Music', true);

	// TAG: C.Name
			EvaluateEx(e, o, 'FULL', 'C.Name', true);

	// TAG: C.Owner
			EvaluateEx(e, o, 'Ownership', 'C.Owner', true);

	// TAG: C.RecordFlags
			CheckCellRecordFlags(e, o, true);

	// TAG: C.Water
			CheckCellWater(e, o, true);
		end;

	// TODO: Deactivate - NOT IMPLEMENTED

	// TAG: Delev, Relev
		if InSignatureList(sig, 'LVLC, LVLI, LVLN, LVSP') then
			CheckDelevRelev(e, o, true);

	// TODO: Filter - NOT IMPLEMENTED

	// TAG: Graphics
		if InSignatureList(sig, 'ACTI, ALCH, AMMO, APPA, ARMO, BOOK, BSGN, CLAS, CLOT, CREA, DOOR, EFSH, FLOR, FURN, GRAS, INGR, KEYM, LIGH, LSCR, LTEX, MGEF, MISC, REGN, SGST, SLGM, STAT, TREE, WEAP') then
			CheckGraphics(e, o, true);

	// TAG: Invent
		if (sig = 'CONT') then
			CheckInvent(e, o, true);

	// TAG: Names
		if InSignatureList(sig, 'ACTI, ALCH, AMMO, APPA, ARMO, BOOK, BSGN, CLAS, CLOT, CONT, DIAL, DOOR, ENCH, EYES, FACT, FLOR, FURN, HAIR, INGR, KEYM, LIGH, MGEF, MISC, QUST, RACE, SGST, SLGM, SPEL, WEAP, WRLD') then
			EvaluateEx(e, o, 'FULL', 'Names', true);

	// TODO: NoMerge - NOT IMPLEMENTED

	// TAG: Sound
		if InSignatureList(sig, 'ACTI, CONT, DOOR, LIGH, MGEF, WTHR') then
			CheckSound(e, o, true);

		if InSignatureList(sig, 'CREA, NPC_') then begin

			if (wbGameMode = gmTES4) then begin
	// TAG: Invent - special handling for CREA and NPC_ record types
				CheckInvent(e, o, true);

	// TAG: Names - special handling for CREA and NPC_ record types
				EvaluateEx(e, o, 'FULL', 'Names', true);

	// TAG: Sound - special handling for CREA record type
				if (sig = 'CREA') then
					CheckSound(e, o, true);

			end else begin
				if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Inventory') then
					CheckInvent(e, o, true);

	// TAG: Names - special handling for CREA and NPC_ record types
				if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Base Data') then
					EvaluateEx(e, o, 'FULL', 'Names', true);

	// TAG: Sound - special handling for CREA record type
				if (sig = 'CREA') then
					if not CompareFlagsOr(e, o, 'ACBS\Template Flags', 'Use Model/Animation') then
						CheckSound(e, o, true);
			end;
		end;

	// TAG: Stats
		if InSignatureList(sig, 'ALCH, AMMO, APPA, ARMO, BOOK, CLOT, INGR, KEYM, LIGH, MISC, SGST, SLGM, WEAP') then
			CheckStats(e, o, true);
	end; // end game
end;

// ==================================================================
// Finalize
function Finalize: integer;
var
	hdr, desc: IInterface;
	sTags, eTags, dTags, bTags, tTags: TSTringList;
	sDescription: string;
begin
	sTags := TStringList.Create;
	eTags := TStringList.Create;
	dTags := TStringList.Create;
	bTags := TStringList.Create;
	tTags := TStringList.Create;

	// exit conditions
	if (optionSelected = mrAbort) or (not Assigned(slTags)) or (not Assigned(fn)) then exit;

	// sort list of suggested tags
	slTags.Sort;

	// output file name
	AddMessage(#13#10 + '-------------------------------------------------------------------------------');
	AddMessage(fn);
	AddMessage('-------------------------------------------------------------------------------' + #13#10);

	// if any suggested tags were generated
	if (slTags.Count > 0) then begin
		hdr := GetElement(f, 'TES4');

		// determine if the header record exists
		if Assigned(hdr) then begin
			desc := GetElement(hdr, 'SNAM');
			sTags.CommaText := slTags.CommaText;
			tTags.CommaText := slTags.CommaText;
			eTags.CommaText := GetSubstring(GetEditValue(desc), '{{BASH:', '}}');
			dTags.CommaText := GetDiffList(eTags, sTags);

			// exit if existing and suggested tags are the same
			if (eTags.CommaText = sTags.CommaText) then begin
				AddMessage('No tags suggested. Exiting.' + #13#10);
				AddMessage('-------------------------------------------------------------------------------' + #13#10);
				exit;
			end;

		// exit if the header record doesn't exist
		end else begin
			AddMessage('Header record not found. Nothing to do. Exiting.' + #13#10);
			AddMessage('-------------------------------------------------------------------------------' + #13#10);
			exit;
		end;

		// write tags
		if (optionSelected = 6) then begin
			// if the description element doesn't exist, add the element
			if not Assigned(desc) then
				desc := Add(hdr, 'SNAM', false);

			if (eTags <> sTags) then begin
				// store description
				sDescription := GetEditValue(desc);

				// remove existing tags, if any; trim regardless
				sDescription := Trim(RemoveFromEnd(sDescription, Format('{{BASH:%s}}', [eTags.DelimitedText])));

				// write new description
				SetEditValue(desc, sDescription + #13#10 + #13#10 + Format('{{BASH:%s}}', [slTags.DelimitedText]));
			end;

			// output bad tags
			bTags.CommaText := GetDiffList(tTags, eTags);
			GenerateTagOutput(bTags, 'bad tag removed:', 'bad tags removed:', 'No bad tags found.');

			// output to log
			GenerateTagOutput(dTags, 'tag added to file header:', 'tags added to file header:', 'No tags added.');
		end;

		// suggest tags only and output to log
		if (optionSelected = 7) then begin
			// output existing tags
			GenerateTagOutput(eTags, 'existing tag found:', 'existing tags found:', 'No existing tags found.');

			// output bad tags
			bTags.CommaText := GetDiffList(tTags, eTags);
			GenerateTagOutput(bTags, 'bad tag found:', 'bad tags found:', 'No bad tags found.');

			// output suggested tags
			GenerateTagOutput(dTags, 'suggested tag to add:', 'suggested tags to add:', 'No suggested tags to add.');

			// output all suggested tags
			GenerateTagOutput(slTags, 'suggested tag overall:', 'suggested tags overall:', 'No suggested tags overall.');
		end;
	end;

	slTags.Free;
	sTags.Free;
	eTags.Free;
	dTags.Free;
	bTags.Free;
	tTags.Free;
end;

end.
