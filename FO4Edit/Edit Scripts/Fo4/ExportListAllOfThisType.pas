
{
  Export a list of EditorIDs to CSV text file (*.csv) of all items of this kind 
  if you execute this script on a weapon, you will get a list of all weapons in all files
  (overriden records will not be ouptut, but only master records)
  
  if you select headers then the records within one file will be sorted by name
  if you select no headers then all records will be sorted by name
  
  Tested for Lists containing references to WEAP
  But should work for all kind of LLCT records
}
unit FO4ExportImport;

const
	sDelimiterChar = ';';
	sortedExport = 0;

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
procedure Exportlist(e: IInterface; addHeaders : boolean);
var
	dlg: TSaveDialog;
	sl, subSl: TStringList;
	line, fname, sig, header : string;
	f, g, entry : IInterface;
	i, j, k : integer;
begin
	sig := Signature(e);
	dlg := TSaveDialog.Create(nil);
	try
		dlg.Filter := 'CSV files (*.csv)|*.csv';
		dlg.Options := dlg.Options + [ofOverwritePrompt];
		dlg.InitialDir := wbScriptsPath;
		dlg.FileName := sig + '_All.csv';
		if dlg.Execute then
			fname := dlg.FileName
		else
			Exit;
		finally
			dlg.Free;
	end;

	sl := TStringList.Create;
	
	//go through each file and find all the relevant records
	for i := 0 to Pred(FileCount) do begin
		f := FileByIndex(i);
		
		header := '';
		subSl := TStringList.Create;
		if HasGroup(f, sig) then begin
			//AddMessage(GetFileName(f) + ' has group ' + sig);
			g := GroupBySignature(f, sig);
			for j := 0 to Pred(ElementCount(g)) do begin
				entry := ElementByIndex(g, j);
				//AddMessage('Record ' + EditorID(entry));
				if IsMaster(entry) then begin
					//AddMessage('Master Record ' + EditorID(entry));
					
					if (header = '') and (addHeaders) then begin
						header := '>>>>>>>>>> ' + GetFileName(f) + ' >>>>>>>>>>';
						sl.Add('');
						sl.Add('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
						sl.Add(header);
						sl.Add('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
					end;
					
					line := RecordToString(entry);
					subSl.Add(line);
				end;
			end;
		end;
		
		if addHeaders then
			subSl.Sort;
		
		//write sub entries to main ouptut
		for k := 0 to Pred(subSl.Count) do
			sl.Add(subSl[k]);
	end;
  
	if not addHeaders then
		sl.Sort;
  
	AddMessage('Saving to ' + fname);
	sl.SaveToFile(fname);
	subSl.Free;
	sl.Free;
end;

//=========================================================================
function Process(e: IInterface): Integer;
var
	mr: integer;
begin
	mr := MessageDlg('Add headers for each file [YES] or no headers and sort by EditorID [NO]?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
	if mr = mrYes then
		Exportlist(e, true)
	else if mr = mrNo then
		Exportlist(e, false);
	
	
  
	Result := 1;
end;

end.