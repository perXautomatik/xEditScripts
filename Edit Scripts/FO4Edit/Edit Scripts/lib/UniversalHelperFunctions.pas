
{
  Export FormID list to CSV text file (*.csv) and import it back
  CSV files can be edited in Excel or other speadsheets
  
  The plugin you are importing to must have all masters added used by imported keywords
  After Import change to another file and back to refresh the references
  
  Tested for Lists containing references to AMMO, WEAP, MISC, ALCH
  But should work for all kind of records
}
unit FO4ExportImport;
unit UniversalHelperFunctions;

const
	sDelimiterChar = ';';
	sortedExport = true;
	autoAddMasters = true;
	useDefaultRecordSyntax = false;


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
procedure AskForAddingMaster(requiredMasterList: TStringList; rec : IInterface; entry : IInterface; eFile : IInterface; eFileName : string; slEntries : TStringList);
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
				slEntries.Free;
				Exit;
			end
		end;
	end;
end;

//=========================================================================
procedure Import(e: IInterface);
var
	dlg: TOpenDialog;
	slEntries, sl: TStringList;
	requiredMasterList: TStringList;
	fname, line, eFileName : string;
	entries, entry, ref, rec, eFile : IInterface;
	l, bracketPos : integer;
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

	// iterate over lines
	for l := 0 to Pred(slEntries.Count) do begin
		line := slEntries[l];
		
		if SameText(Trim(line), '') then
			Continue;
		
		bracketPos := Pos('[', line);
		if bracketPos < 1 then begin
			AddMessage('Line was skipped since it contains no record: ' + line);
			Continue;
		end;
			
		//get reference
		rec := StringToRecord(line);
		if not Assigned(rec) then begin
			AddMessage('Reference ' + line + ' not found, skipped');
			Continue;
		end;
		
		//get&delete or create new entries 
		//(has to be here since a NULL-Reference would be left if we remove it before the loop and no entry is found)
		if not Assigned(entries) then begin
			// remove all current entries
			entries := ElementByName(e, 'FormIDs');
			Remove(entries);
			// add new ones
			entries := Add(e, 'FormIDs', True);
		end;
		
		// new entry 
		if not Assigned(entry) then
			entry := ElementByIndex(entries, l)
		else
			entry := ElementAssign(entries, HighInteger, nil, False);
			
		//check if we need to add a master for adding this record
		if autoAddMasters then AskForAddingMaster(requiredMasterList, rec, entry, eFile, eFileName, slEntries);		
		SetEditValue(entry, HexFormID(rec)); 
	end;
	
	requiredMasterList.Free;
	slEntries.Free;
end;

//=========================================================================
procedure Export(e: IInterface);
var
	dlg: TSaveDialog;
	sl: TStringList;
	line, fname : string;
	entries, entry : IInterface;
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
	
	entries := ElementByName(e, 'FormIDs');
	// iterate over entries
	for i := 0 to Pred(ElementCount(entries)) do begin
		entry := ElementByIndex(entries, i);
		
		line := RecordToString(LinksTo(entry));
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
	if Signature(e) <> 'FLST' then
		Exit;

	mr := MessageDlg('Import ' + EditorID(e) + ' record from file [YES] or export to a file [NO]?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
	if mr = mrYes then
		Import(e)
	else if mr = mrNo then
		Export(e);
  
	Result := 1;
end;

end.