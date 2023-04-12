
// Creates a % Chance Leveled List
function createChanceLeveledList(aPlugin: IInterface; aName: String; Chance: Integer; aRecord, aLevelList: IInterface): IInterface;
var
	chanceLevelList, nestedChanceLevelList: IInterface;
	debugMsg, tempBoolean: Boolean;
	i, tempInteger: Integer;
	slTemp: TStringList;
begin
// Begin debugMsg section
	debugMsg := false;
	// The following section can be real confusing without examples.
	// If I have a 10% chance I need a Leveled List with 9 copies of the regular item and 1 copy of the enchantment Leveled List.  In math this looks like 1/10 = 10/100 = 10%.
	// If I have a 9% chance I need a Leveled List (List A) with 9 copies of the regular item and 1 copy of the enchantment Leveled List.
	// I also need ANOTHER list (List B) with 9 copies of the regular item and 1 copy of List A.  In math this looks like 1/10 * 9/10 = 9/100 (or 9%).
	// Similarly, if I have an 11% chance I need a Leveled List (List A) with 9 copies of the regular item and 1 copy of the enchantment Leveled List.
	// I also need ANOTHER list with 8 copies of the regular item, 1 copy of List A, and 1 copy of the enchantment list.  In math this looks like 1/10 + (1/10 * 9/10) = 11/100 (or 11%).

	// Initialize
	if Chance = 0 then Exit;
	slTemp := TStringList.Create;

	// Create %chance list
	slTemp.CommaText := '"Calculate from all levels <= player''s level", "Calculate for each item in count"';
	chanceLevelList := createLeveledList(aPlugin, aName, slTemp, 0);

	// If it's a 100% chance we just need a single leveled list
	if Chance = 100 then begin {Debug} if debugMsg then msg('[%Chance] Chance = 100; Removing chanceLevelList and assigning aLevelList to chanceLevelList for AddToLeveledListAuto input');
		Remove(chanceLevelList);
		chanceLevelList := aLevelList;
	end else if (Length(IntToStr(Chance)) = 1) then begin {Debug} if debugMsg then msg('[%Chance] for i := 0 to Chance do addToLeveledList('+EditorID(nestedChanceLevelList)+', '+EditorID(aLevelList)+', 1 );');
		for i := 0 to Chance do
			addToLeveledList(nestedChanceLevelList, aLevelList, 1); {Debug} if debugMsg then msg('[%Chance] while (LLec(nestedChanceLevelList) < 10) do addToLeveledList('+EditorID(nestedChanceLevelList)+', '+EditorID(aRecord)+', 1 );');
		while (LLec(nestedChanceLevelList) < 10) do
			addToLeveledList(nestedChanceLevelList, aRecord, 1);
		addToLeveledList(chanceLevelList, nestedChanceLevelList, 1); {Debug} if debugMsg then msg('[%Chance] while (LLec('+EditorID(chanceLevelList)+' ) < 10) do addToLeveledList('+EditorID(chanceLevelList)+', '+EditorID(aRecord)+', 1 );');
		while (LLec(chanceLevelList) < 10) do
			addToLeveledList(chanceLevelList, aRecord, 1);				 
	end else begin
		// Grab the second digit; If the second digit is 0 we don't need the nested leveled list; Example: 10, 20, 30, etc.
		{Debug} if debugMsg then msg('[%Chance] StrToInt(Copy(IntToStr(Chance), 2, 1)) := '+Copy(IntToStr(Chance), 2, 1));
		tempInteger := StrToInt(Copy(IntToStr(Chance), 2, 1));
		if (tempInteger = 0) then
			tempBoolean := True
		else
			tempBoolean := False;
		{Debug} if debugMsg then msg('[%Chance] tempBoolean := '+BoolToStr(tempBoolean));
		// Grab the first digit
		{Debug} if debugMsg then msg('[%Chance] StrToInt(Copy(IntToStr(Chance), 1, 1)) := '+Copy(IntToStr(Chance), 1, 1));
		tempInteger := StrToInt(Copy(IntToStr(Chance), 1, 1));
		// Create the percent chance leveled list for 10, 20, 30, etc. (numbers that don't need the nested leveled list)
		if tempBoolean then begin {Debug} if debugMsg then msg('[%Chance] if tempBoolean then begin for i := 0 to tempInteger-1 := '+IntToStr(tempInteger-1)+' do addToLeveledList('+EditorID(chanceLevelList)+', '+EditorID(aLevelList)+', 1 ); while (LLec(chanceLevelList) :='+IntToStr(LLec(chanceLevelList))+' < 10) do addToLeveledList('+EditorID(chanceLevelList)+', '+EditorID(aRecord)+', 1 );');
			for i := 0 to tempInteger-1 do addToLeveledList(chanceLevelList, aLevelList, 1);
				while (LLec(chanceLevelList) < 10) do
			addToLeveledList(chanceLevelList, aRecord, 1);
		end else begin {Debug} if debugMsg then msg('[%Chance] Not tempBoolean; Beginning nested list generation');
			// Create a nested leveled list for valid integers between 0 and 100 with a second digit greater than 0.  Example: 51, 52, 53, etc.
			{Debug} if debugMsg then msg('[%Chance] Creating and preparing nestedchanceLevelList');
			nestedChanceLevelList := createLeveledList(aPlugin, Insert('nested', aName, ItPos(aName, 'e', 3)), slTemp, 0);
			// Fill the nested and chance leveled lists based on Chance
			for i := 0 to (StrToInt(Copy(IntToStr(Chance), 2, 1))-1) do
				addToLeveledList(nestedChanceLevelList, aLevelList, 1);
			while (LLec(nestedChanceLevelList) < 10) do
				addToLeveledList(nestedChanceLevelList, aRecord, 1);
			addToLeveledList(chanceLevelList, nestedChanceLevelList, 1);
			for i := 0 to tempInteger-1 do
				addToLeveledList(chanceLevelList, aLevelList, 1);
			while (LLec(chanceLevelList) < 10) do
				addToLeveledList(chanceLevelList, aRecord, 1);
		end;
	end;
	Result := chanceLevelList;

	// Finalize
	slTemp.Free;

	debugMsg := false;
// End debugMsg section
end;