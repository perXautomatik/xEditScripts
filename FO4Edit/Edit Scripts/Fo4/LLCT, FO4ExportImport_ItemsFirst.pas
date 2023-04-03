
{
  Export LLCT record list of a leveled list to CSV text file (*.csv) and import it back
  CSV files can be edited in Excel or other speadsheets
  
  The plugin you are importing to must have all masters added used by imported keywords
  After Import change to another file and back to refresh the references
  
  Tested for Lists containing references to LVLI, MISC, WEAP, ARMO, ALCH, AMMO, NOTE
  But should work for all kind of LLCT records
}
unit FO4ExportImportLLCT;

const
	sDelimiterChar = ';';
	sortedExport = true;
	itemsFirst = true;
	autoAddMasters = true;
	
//=========================================================================
// convert record to string consisting of Editor ID and plugin's name with signature of group
function RecordToString(rec: IInterface): string;
var
	baseRec: IInterface;
begin
	baseRec := MasterOrSelf(rec); //use baseRec to be safe against renames
	Result := EditorID(baseRec) + '[' + GetFileName(baseRec) + ']' + ':' + Signature(baseRec);
end;

//=========================================================================
// locate record in the current load order by string
function StringToRecord(rec: string): IInterface;
var
	i: integer;
	fname, id, sig: string;
	f, g: IInterface;
begin
	i := Pos('[', rec);
	id := Copy(rec, 1, i - 1); // Editor ID of keyword
	fname := Copy(rec, i + 1, Pos(']', rec) - i - 1); // plugin of keyword
	sig := Copy(rec, Pos(']', rec) + 2, Length(rec)); // Signature of Group where the mainrecord is in keyword

	for i := 0 to Pred(FileCount) do
		if SameText(GetFileName(FileByIndex(i)), fname) then begin
			f := FileByIndex(i);
			Break;
		end;
	g := GroupBySignature(f, sig);
	Result := MainRecordByEditorID(g, id);
end;

//=========================================================================
//Reverses a string
function ReverseString(s: string): string;
var
	i: integer;
begin
	Result := '';
	for i := Length(s) downto 1 do begin
		Result := Result + Copy(s, i, 1);
	end;
end;

//=========================================================================
//use Hex-ID to support referencing to different records having the same EditorID
function HexFormID(e: IInterface): string;
var
	s: string;
	i: integer;
begin
	s := GetElementEditValues(e, 'Record Header\FormID');
	s := ReverseString(s);
	i := Pos('[', s);
	s := Copy(s, 0, i);
	Result := ReverseString(s);
end;

//=========================================================================
//ask for adding master
procedure AskForAddingMaster(requiredMasterList: TStringList; rec : IInterface; entry : IInterface; eFile : IInterface; eFileName : string; slEntries : TStringList; sl : TStringList);
var
	masterIndex, mr : integer;
	requMasterStr : string;
begin
	requiredMasterList.Clear;
	ReportRequiredMasters(rec, requiredMasterList, false, false);
	for masterIndex := 0 to Pred(requiredMasterList.Count) do begin
		requMasterStr := requiredMasterList[masterIndex];
		if not HasMaster(eFile, requMasterStr) then begin
			mr := MessageDlg('Add ' + requMasterStr + ' to file ' + eFileName +'?', mtConfirmation, [mbYes, mbCancel], 0);
			if mr = mrYes then begin
				AddMasterIfMissing(eFile, requMasterStr);
			end else if mr = mrCancel then begin
				Remove(entry);
				requiredMasterList.Free;
				sl.Free;
				slEntries.Free;
				Exit;
			end
		end;
	end;
end;

//=========================================================================
procedure ImportLLCT(e: IInterface);
var
	dlg: TOpenDialog;
	slEntries, sl: TStringList;
	requiredMasterList: TStringList;
	fname, line, recStr, lvlStr, chanceStr, countStr: string;
	condStr, ownerStr, globVarStr, eFileName, requMasterStr: string;
	entries, entry, lvloEntry, ref, rec, coedRec, ownerRec, globVarRec, eFile : IInterface;
	l, masterIndex, mr : integer;
begin
	dlg := TOpenDialog.Create(nil);
	try
		dlg.Filter := 'CSV files (*.csv)|*.csv';
		dlg.InitialDir := wbScriptsPath;
		dlg.FileName := EditorID(e) + '.csv';
		if dlg.Execute then
			fname := dlg.FileName
		else
			Exit;
	finally
		dlg.Free;
	end;

	if Pos('\' + EditorID(e) + '.csv',fname) < 1 then begin
		AddMessage('Aborting import - Filename seems to belong to another record - expected Filename: ' + EditorID(e) + '.csv');
		Exit;
	end;

	slEntries := TStringList.Create;
	slEntries.LoadFromFile(fname);
	
	requiredMasterList := TStringList.Create;
	eFile := GetFile(e);
	eFileName := GetFileName(e);
	
	sl := TStringList.Create;
	sl.Delimiter := sDelimiterChar;
	sl.StrictDelimiter := True;

	// iterate over lines
	for l := 0 to Pred(slEntries.Count) do begin
		line := slEntries[l];
		
		sl.DelimitedText := line;
		
		if SameText(Trim(line), '') then
			Continue;
		
		if sl.Count < 4 then begin
			AddMessage('Line was skipped since it contains less than 4 columns - Line content: ' + line);
			Continue;
		end;
		
		//get basic values
		if (itemsFirst) then begin
			recStr := Trim(sl[0]);
			lvlStr := Trim(sl[1]);
		end else begin
			lvlStr := Trim(sl[0]);
			recStr := Trim(sl[1]);
		end;
		
		countStr := Trim(sl[2]);
		chanceStr := Trim(sl[3]);
			
		//get reference
		if recStr = '' then Continue;
		rec := StringToRecord(recStr);
		if not Assigned(rec) then begin
			AddMessage('Reference ' + recStr + ' not found, skipped');
			Continue;
		end;
		
		//if provided: get condition, owner and global variable
		if sl.Count > 4 then condStr := Trim(sl[4]) else condStr := '';
		if sl.Count > 5 then ownerStr := Trim(sl[5]) else ownerStr := '';
		if sl.Count > 6 then globVarStr := Trim(sl[6]) else globVarStr := '';
		
		if not SameText(ownerStr, '') then begin 
			ownerRec := StringToRecord(ownerStr);
			if not Assigned(ownerRec) then begin
				AddMessage('Owner-Reference ' + ownerStr + ' not found, record skipped');
				Continue;
			end;
		end;
	
		if not SameText(globVarStr, '') then begin 
			globVarRec := StringToRecord(globVarStr);
			if not Assigned(globVarRec) then begin
				AddMessage('GlobalVariable-Reference ' + globVarStr + ' not found, record skipped');
				Continue;
			end;
		end;
		
		//get&delete or create new entries 
		//(has to be here since a NULL-Reference would be left if we remove it before the loop and no entry is found)
		if not Assigned(entries) then begin
			// remove all current entries
			entries := ElementByName(e, 'Leveled List Entries');
			Remove(entries);
			// add new ones
			entries := Add(e, 'Leveled List Entries', True);
		end;
		
		// new entry 
		if not Assigned(entry) then
			entry := ElementByIndex(entries, l)
		else
			entry := ElementAssign(entries, HighInteger, nil, False);
		
		//set LVLO record
		lvloEntry := ElementBySignature(entry, 'LVLO');
		if not Assigned(lvloEntry) then
			lvloEntry := Add(entry, 'LVLO', True);
		SetElementEditValues(lvloEntry, 'Level', lvlStr);
		SetElementEditValues(lvloEntry, 'Count', countStr);
		SetElementEditValues(lvloEntry, 'Chance None', chanceStr);
		
		//check if we need to add a master for adding this record
		if autoAddMasters then AskForAddingMaster(requiredMasterList, rec, entry, eFile, eFileName, slEntries, sl);	
		SetElementEditValues(lvloEntry, 'Reference', HexFormID(rec));
		
		//set COED record if provided
		if not SameText(condStr, '') then begin
			coedRec := ElementBySignature(entry, 'COED');
			if not Assigned(coedRec) then
				coedRec := Add(entry, 'COED', True);
			SetElementEditValues(coedRec, 'Item Condition', condStr);
			
			if not SameText(ownerStr, '') then begin 
				//check if we need to add a master for adding this record
				if autoAddMasters then AskForAddingMaster(requiredMasterList, ownerRec, entry, eFile, eFileName, slEntries, sl);
				SetElementEditValues(coedRec, 'Owner', HexFormID(ownerRec));
			end;
			if not SameText(globVarStr, '') then begin 
				//check if we need to add a master for adding this record
				if autoAddMasters then AskForAddingMaster(requiredMasterList, globVarRec, entry, eFile, eFileName, slEntries, sl);
				SetElementEditValues(coedRec, 'Global Variable', HexFormID(globVarRec));
			end;
		end;
	end;
	
	requiredMasterList.Free;
	sl.Free;
	slEntries.Free;
end;

//=========================================================================
procedure ExportLLCT(e: IInterface);
var
	dlg: TSaveDialog;
	sl: TStringList;
	line, fname, ownerStr, globVarStr : string;
	entries, entry, lvloEntry, coedRec, ownerRec, globVarRec : IInterface;
	i : integer;
begin
	dlg := TSaveDialog.Create(nil);
	try
		dlg.Filter := 'CSV files (*.csv)|*.csv';
		dlg.Options := dlg.Options + [ofOverwritePrompt];
		dlg.InitialDir := wbScriptsPath;
		dlg.FileName := EditorID(e) + '.csv';
		if dlg.Execute then
			fname := dlg.FileName
		else
			Exit;
		finally
			dlg.Free;
	end;

	sl := TStringList.Create;
	
	entries := ElementByName(e, 'Leveled List Entries');
	// iterate over entries
	for i := 0 to Pred(ElementCount(entries)) do begin
		entry := ElementByIndex(entries, i);
		lvloEntry := ElementBySignature(entry, 'LVLO');
		
		if (itemsFirst) then begin
			line := RecordToString(LinksTo(ElementByName(lvloEntry, 'Reference'))) + sDelimiterChar + GetElementEditValues(lvloEntry, 'Level') + sDelimiterChar + GetElementEditValues(lvloEntry, 'Count') + sDelimiterChar + GetElementEditValues(lvloEntry, 'Chance None');
		end else begin
			line := GetElementEditValues(lvloEntry, 'Level') + sDelimiterChar + RecordToString(LinksTo(ElementByName(lvloEntry, 'Reference'))) + sDelimiterChar + GetElementEditValues(lvloEntry, 'Count') + sDelimiterChar + GetElementEditValues(lvloEntry, 'Chance None');
		end;
		
		//add condition to export if provided
		coedRec := ElementBySignature(entry, 'COED');
		if Assigned(coedRec) then begin
			line := line + sDelimiterChar + GetElementEditValues(coedRec, 'Item Condition');
			
			//add owner if provided
			ownerRec := ElementByName(coedRec, 'Owner');
			if Assigned(ownerRec) then begin
				ownerStr := RecordToString(LinksTo(ownerRec));
				if not SameText(ownerStr, '[]:') then begin //filters out null reference - works but ugly
					line := line + sDelimiterChar + RecordToString(LinksTo(ownerRec));
					
					//only if an owner is provided: add a global variable if provided
					globVarRec := ElementByName(coedRec, 'Global Variable');
					if Assigned(globVarRec) then begin
						globVarStr := RecordToString(LinksTo(globVarRec));
						if not SameText(globVarStr, '[]:') then begin //filters out null reference - works but ugly
							line := line + sDelimiterChar + RecordToString(LinksTo(globVarRec));
						end;
					end;
				  
				end;
			end;
		  
		end;
		
		sl.Add(line);
	end;
  
	if (sortedExport) then
		sl.Sort;
  
	AddMessage('Saving to ' + fname);
	sl.SaveToFile(fname);
	sl.Free;
end;

//=========================================================================
function Process(e: IInterface): Integer;
var
	mr: integer;
begin
	if Signature(e) <> 'LVLI' then
		if Signature(e) <> 'LVLN' then
			Exit;

	mr := MessageDlg('Import ' + EditorID(e) + ' record from file [YES] or export to a file [NO]?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
	if mr = mrYes then
		ImportLLCT(e)
	else if mr = mrNo then
		ExportLLCT(e);
  
	Result := 1;
end;

end.