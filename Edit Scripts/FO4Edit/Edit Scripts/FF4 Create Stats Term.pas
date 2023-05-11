{
  Copy Some stuff for SAF because I'm lazy to do it over and over for 32 attributes
}
unit FF4;
	
var
	RecordID  : string;
	GlobalVar : string;
	Labels    : Array[0..6] of String;
	Values    : Array[0..6] of String;
	from      : integer;
	till      : integer;
	template  : IwbElement;

function Initialize: integer;
begin
	Result    := 0;
	RecordID  := '01000B8A';
	GlobalVar := 'FF4_GLOB_DisplayControlLevelUpBonusStats [GLOB:01000B8B]';
	Labels[0] := '+] Strength     [';
	Labels[1] := '+] Perception   [';
	Labels[2] := '+] Endurance    [';
	Labels[3] := '+] Charisma     [';
	Labels[4] := '+] Intelligence [';
	Labels[5] := '+] Agility      [';
	Labels[6] := '+] Luck         [';
	Values[0] := 'Strength "Strength" [AVIF:000002C2]';
	Values[1] := 'Perception "Perception" [AVIF:000002C3]';
	Values[2] := 'Endurance "Endurance" [AVIF:000002C4]';
	Values[3] := 'Charisma "Charisma" [AVIF:000002C5]';
	Values[4] := 'Intelligence "Intelligence" [AVIF:000002C6]';
	Values[5] := 'Agility "Agility" [AVIF:000002C7]';
	Values[6] := 'Luck "Luck" [AVIF:000002C8]';
	from      := 1;
	till      := 50;
end;

function Process(e: IInterface): integer;
var
	eIndex  : integer;
	aIndex  : integer;
	copied  : IwbElement;
	child   : IwbElement;
begin
	Result := 0;
	{
		IMPORTANT: While it is technically possible to ADD 'Menu Items' slot and then start adding from scratch, there is a bug with 'Conditions'
		It is impossible to add 'Conditions' tab no matter what (even wb-copy shamanism fails here). Hence, the only way to make it work is to clone
		Clone will work this way: there is a first item in the 'Menu Items' that ALREADY HAS 'Conditions' tab. Then cloning that propagates the tab.
		While we're at it, we also add the GlobalVariable up to the standard (see the second condition)
		TL;DR: for this to work, there MUST BE a first element properly set up!
	}
	if ElementExists(e, 'Menu Items') then begin
		template := ElementByPath(ElementByPath(e, 'Menu Items'), 'Menu Item');
		SetEditValue(ElementByPath(template, 'ITXT - Item Text'), 'EDITED');
	end;
	
	if ElementExists(e, 'Menu Items') then begin
		AddMessage('Adding?');
		for aIndex := 0 to 6 do begin
			for eIndex := from to till do begin
				copied := ElementAssign(ElementByPath(e, 'Menu Items'), HighInteger, template, False);
				EditMenuElement(copied, aIndex, eIndex);
			end
		end
	end;
	
	{
		While we're at it, also use the same technique to multiply script fragments (it's going to be fun with 350 of them):
	}
	child    := ElementByPath(e, 'VMAD');
	child    := ElementByPath(child, 'Script Fragments');
	child    := ElementByPath(child, 'Fragments');
	template := ElementByIndex(child, 0);
	for aIndex := 0 to 6 do begin
		for eIndex := from to till do begin
			copied := ElementAssign(child, HighInteger, template, False);
			EditFragmentElement(copied, aIndex, eIndex);
		end
	end
end;

function EditFragmentElement(e: IInterface; aIndex: integer; eIndex: integer): integer;
var
	data : IwbElement;
	inum : integer;
	itxt : String;
begin
	Result := 0;
	inum   := GetTermPosition(aIndex, eIndex);
	//Fragment Name :
	data := ElementByPath(e, 'FragmentName');
	itxt := 'Fragment_Terminal_';
	if inum > 99 then begin
		itxt := itxt + IntToStr(inum); //the string's API is unknown to this env:
	end
	else if inum > 9 then begin
		itxt := itxt + '0' + IntToStr(inum);
	end
	else begin
		itxt := itxt + '00' + IntToStr(inum);
	end;
	SetEditValue(data,  itxt);
	
	//Fragment index:
	data := ElementByPath(e, 'Fragment Index');
	SetEditValue(data,  IntToStr(inum));
end;

function EditMenuElement(e: IInterface; aIndex: integer; eIndex: integer): integer;
var
	data : IwbElement;
	ctda : IwbElement;
	grid : IwbElement;
	itxt : String;
begin
	Result := 0;
	//Button Text:
	data   := ElementByPath(e, 'ITXT - Item Text');
	if eIndex > 9 then begin
		itxt := Labels[aIndex] + IntToStr(eIndex); //the string's API is unknown to this env:
	end
	else begin
		itxt := Labels[aIndex] + '0' + IntToStr(eIndex);
	end
	SetEditValue(data,  itxt);
	
	//Menu type:
	data := ElementByPath(e, 'ANAM - Type');
	SetEditValue(data,  'Submenu - Force Redraw');
	
	//Item ID:
	Add(e, 'ITID - Item ID', True);
	data := ElementByPath(e, 'ITID - Item ID');
	SetEditValue(data,  IntToStr(GetTermPosition(aIndex, eIndex)));
	
	//Conditions:
	if ElementExists(e, 'Conditions') then begin
		data := ElementByIndex(ElementByPath(e, 'Conditions'), 0);
		ctda := ElementByName(data, 'CTDA - CTDA');
		grid := ElementByName(ctda, 'Comparison Value - Float');
		SetEditValue(grid, eIndex);
		grid := ElementByName(ctda, 'Function');
		SetEditValue(grid, 'GetBaseValue');
		grid := ElementByName(ctda, 'Actor Value');
		SetEditValue(grid, Values[aIndex]);
		grid := ElementByName(ctda, 'Run On');
		SetEditValue(grid, 'Reference');
		grid := ElementByName(ctda, 'Reference');
		SetEditValue(grid, 'PlayerRef [PLYR:00000014]');
	end
	else begin
		AddMessage('Failed with conditions');
	end;
end;

function GetTermPosition(aIndex: integer; eIndex: integer) : integer;
begin
	Result := (aIndex * (till - from + 1)) + eIndex;
end;
end.
