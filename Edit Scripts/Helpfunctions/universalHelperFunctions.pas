unit universalHelperFunctions;
//=========================================================================
//Reverses a string
function ReverseString(s: string): string;
var
  i: integer;

procedure FindCell(WrldEDID, XVal, YVal: string);
var
  CellX, CellY, x, y: integer;
  modidx, wrldidx, blockidx, subblockidx, cellidx: integer;
  f, wrlds, wrld, wrldgrup, block, subblock, cell: IInterface;
  BlockName, SubBlockName: string;
begin
  CellX := StrToIntDef(XVal, 0);
  CellY := StrToIntDef(YVal, 0);
  x := CellX div 32;
  if (CellX < 0) and (CellX mod 32 <> 0) then Dec(x);
  y := CellY div 32;
  if (CellY < 0) and (CellY mod 32 <> 0) then Dec(y);
  BlockName := Format('Block %d, %d', [x, y]);
  x := CellX div 8;
  if (CellX < 0) and (CellX mod 8 <> 0) then Dec(x);
  y := CellY div 8;
  if (CellY < 0) and (CellY mod 8 <> 0) then Dec(y);
  SubBlockName := Format('Sub-Block %d, %d', [x, y]);

  // traverse mods
  for modidx := 0 to FileCount - 1 do begin
    f := FileByIndex(modidx);
    wrlds := GroupBySignature(f, 'WRLD');
    if not Assigned(wrlds) then Continue;

    // traverse Worldspaces
    for wrldidx := 0 to ElementCount(wrlds) - 1 do begin
      wrld := ElementByIndex(wrlds, wrldidx);
      if GetElementEditValues(wrld, 'EDID') <> WrldEDID then Continue;
      wrldgrup := ChildGroup(wrld);

      // traverse Blocks
      for blockidx := 0 to ElementCount(wrldgrup) - 1 do begin
        block := ElementByIndex(wrldgrup, blockidx);
        if ShortName(block) <> BlockName then Continue;
          
        // traverse SubBlocks
        for subblockidx := 0 to ElementCount(block) - 1 do begin
          subblock := ElementByIndex(block, subblockidx);
          if ShortName(subblock) <> SubBlockName then Continue;

          // traverse Cells
          for cellidx := 0 to ElementCount(subblock) - 1 do begin
            cell := ElementByIndex(subblock, cellidx);
            if Signature(cell) <> 'CELL' then Continue;
            if (GetElementNativeValues(cell, 'XCLC\X') = CellX) and (GetElementNativeValues(cell, 'XCLC\Y') = CellY) then begin
              JumpTo(cell, False);
              Exit;
            end;
          end;

          Break;
        end;

        Break;
      end;

      Break;
    end;
  end;

  AddMessage('Cell not found!');
end;

procedure FillWorldspaces(lst: TStrings);
var
  sl: TStringList;
  i, j: integer;
  f, wrlds, wrld: IInterface;
  s: string;
begin
  sl := TStringList.Create;
  for i := 0 to FileCount - 1 do begin
    f := FileByIndex(i);
    wrlds := GroupBySignature(f, 'WRLD');
    if not Assigned(wrlds) then Continue;
    for j := 0 to ElementCount(wrlds) - 1 do begin
      wrld := ElementByIndex(wrlds, j);
      s := GetElementEditValues(wrld, 'EDID');
      if (s <> '') and (sl.IndexOf(s) = -1) then
        sl.Add(s);
    end;
  end;

//============================================================================
procedure btnSrcClick(Sender: TObject);
var
  ed: TLabeledEdit;
  s: string;
begin
  ed := TLabeledEdit(TForm(Sender.Parent).FindComponent('edSrc'));
  s := SelectDirectory('Select source', '', ed.Text, nil);
  if s <> '' then begin
    ed.Text := s;
    ed := TLabeledEdit(TForm(Sender.Parent).FindComponent('edDst'));
    if ed.Text = '' then
      ed.Text := s;
  end;
end;

//============================================================================
procedure btnDstClick(Sender: TObject);
var
  ed: TLabeledEdit;
  s: string;
begin
  ed := TLabeledEdit(TForm(Sender.Parent).FindComponent('edDst'));
  s := SelectDirectory('Select destination', '', ed.Text, nil);
  if s <> '' then
    ed.Text := s;
end;
  sl.Sort;
  lst.AddStrings(sl);
  sl.Free;
end;

procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    TForm(Sender).ModalResult := mrOk;
  if Key = VK_ESCAPE then
    TForm(Sender).ModalResult := mrCancel;
end;
begin
   Result := '';
   for i := Length(s) downto 1 do begin

procedure CheckForESL(f: IInterface);
var
  i: Integer;
  e: IInterface;
  RecCount, RecMaxFormID, fid: Cardinal;
  HasCELL: Boolean;
begin
  // iterate over all records in plugin
  for i := 0 to Pred(RecordCount(f)) do begin
    e := RecordByIndex(f, i);
    
    // override doesn't affect ESL


procedure SetupBaseFolderPath;
begin
	if not DirectoryExists(ProgramPath + 'Edit Scripts\FyTy') then
		CreateDir(ProgramPath + 'Edit Scripts\FyTy');
		
	if not DirectoryExists(ProgramPath + 'Edit Scripts\FyTy\Face Tint Groups') then
		CreateDir(ProgramPath + 'Edit Scripts\FyTy\Face Tint Groups');
end;


procedure OutputTintGroupsToFolder;
var
	eCurrentTintContainer, eCurrentTintLayer, eTemplateColors: IInterface;
	iCounter, iSubCounter, iCounterForColors: integer;
	strTintGroup, strTintLayerIndex, strTintLayerName, strNewFolderPath: string;
begin
	
	
	for iCounter := 0 to ElementCount(eTintLayerContainer) - 1 do begin // Iterate through every tint layer category
	
		strTintGroup := GetElementEditValues(ElementByIndex(eTintLayerContainer, iCounter), 'TTGP'); // This contains the individual tint layers
		strNewFolderPath := strBaseFolderPath + strTintGroup + '\';
		
		if not DirectoryExists(strNewFolderPath) then // If we haven't already made it
			if not CreateDir (strNewFolderPath) then // Try to create the directory. If the script fails
				AddMessage('Failed to create: ' + strNewFolderPath); // Output the directory to FO4Edit
		
		tstrlistTintLayers := TStringList.Create;
		tstrlistTintLayerIndexes := TStringList.Create;
		
		eCurrentTintContainer := ElementByPath(ElementByIndex(eTintLayerContainer, iCounter), 'Options');
		
		
		for iSubCounter := 0 to ElementCount(eCurrentTintContainer) - 1 do begin // Iterate through every tint layer variation (e.g, all tattoos)
			
			eCurrentTintLayer := ElementByIndex(eCurrentTintContainer, iSubCounter);
			
			strTintLayerIndex := GetElementEditValues(eCurrentTintLayer, 'TETI - Index\Index');
			strTintLayerName := GetElementEditValues(eCurrentTintLayer, 'TTGP - Name');
			
			tstrlistTintLayerIndexes.Add(strTintLayerIndex);
			tstrlistTintLayers.Add(strTintLayerName);
			
			
			// Some tint layers can have colour variations, which is embedded in the tint layer itself.
			// So we have to iterate through each colour for the current tint layer.

//============================================================================
procedure btnSrcClick(Sender: TObject);
var
  edSrc: TLabeledEdit;
  s: string;
begin
  edSrc := TLabeledEdit(TForm(Sender.Parent).FindComponent('edSrc'));
  s := SelectDirectory('Select a directory', '', edSrc.Text, nil);
  if s <> '' then
    edSrc.Text := s;
end;
			// We're gonna have a nice repetoire of text files goin'
			if ElementExists(eCurrentTintLayer, 'TTEC - Template Colors') then begin
				
				
				eTemplateColors := ElementBySignature(eCurrentTintLayer, 'TTEC');
				
				tstrlistTemplateColors := TStringList.Create;
				tstrlistTemplateColorIndexes := TStringList.Create;
				
				
				for iCounterForColors := 0 to ElementCount(eTemplateColors) - 1 do begin
					
					tstrlistTemplateColors.Add(GetElementEditValues(ElementByIndex(eTemplateColors, iCounterForColors), 'Color'));
					tstrlistTemplateColorIndexes.Add(GetElementEditValues(ElementByIndex(eTemplateColors, iCounterForColors), 'Template Index'));
					
				end;
				
				
			tstrlistTemplateColors.SaveToFile(strNewFolderPath + strTintLayerName + ' - Color.txt');
			tstrlistTemplateColorIndexes.SaveToFile(strNewFolderPath + strTintLayerName + ' - Color Indexes.txt');
			
			tstrlistTemplateColors.Free;
			tstrlistTemplateColorIndexes.Free;
				
			end;
			
			
		end;
		
		
		tstrlistTintLayerIndexes.SaveToFile(strNewFolderPath + strTintGroup + ' - Layer Indexes.txt');
		tstrlistTintLayers.SaveToFile(strNewFolderPath + strTintGroup + ' - Layer Names.txt');
		
		
		tstrlistFullTintLayers := TStringList.Create;
		
		for iSubCounter := 0 to tstrlistTintLayers.Count - 1 do begin
		
			tstrlistFullTintLayers.Add(tstrlistTintLayerIndexes[iSubCounter] + ' ' + strTintGroup + ' - ' + tstrlistTintLayers[iSubCounter]);
		end;
		
		tstrlistFullTintLayers.SaveToFile(strNewFolderPath + strTintGroup + ' - Full Layer IDs.txt');
		
		tstrlistFullTintLayers.Free;
		tstrlistTintLayerIndexes.Free;
		tstrlistTintLayers.Free;
		
	end;
	
end;
    if not IsMaster(e) then
      Continue;
    
    if Signature(e) = 'CELL' then
      HasCell := True;
    
    // increase the number of new records found
    Inc(RecCount);
    
    // no need to check for more if we are already above the limit
    if RecCount > iESLMaxRecords then
      Break;
    
    // get raw FormID number
    fid := FormID(e) and $FFFFFF;
    
    // determine the max one
    if fid > RecMaxFormID then
      RecMaxFormID := fid;
  end;

  // too many new records, can't be ESL
  if RecCount > iESLMaxRecords then
    Exit;
  
  AddMessage(Name(f));
  
  if RecMaxFormID <= iESLMaxFormID then
    AddMessage(#9'Can be turned into ESL by adding ESL flag in TES4 header')
  else
    AddMessage(#9'Can be turned into ESL by compacting FormIDs first, then adding ESL flag in TES4 header');
    
  // check if plugin has new cell(s)
  if HasCELL then
    AddMessage(#9'Warning: Plugin has new CELL(s) which won''t work when turned into ESL and overridden by other mods due to the game bug');
end;
  
{
	Opens a file selection form
	Returns the selected file
}
function SelectFile: IInterface;
var
	i: integer;
	clb: TCheckListBox;
	frm: TForm;
begin
	frm := frmFileSelect;
	clb := TCheckListBox(frm.FindComponent('CheckListBox1'));
	clb.Items.Add('<New File>');
	for i := Pred(FileCount) downto 0 do
		if(GetFileName(FileByIndex(i)) <> 'Skyrim.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat') then
			clb.Items.InsertObject(1, GetFileName(FileByIndex(i)), FileByIndex(i));
	if(frm.ShowModal = mrOk) then
		for i := 0 to Pred(clb.Items.Count) do
			if(clb.Checked[i]) then begin
				if i = 0 then Result := AddNewFile else
					Result := ObjectToElement(clb.Items.Objects[i]);
				Break;
			end;
	frm.Free;
end;
end.
     Result := Result + Copy(s, i, 1);
   end;
end;



//=========================================================================
// convert record to string consisting of Editor ID and plugin's name with signature of group
function RecordToString(rec: IInterface): string;
var
	baseRec: IInterface;
begin
	baseRec := MasterOrSelf(rec); //use baseRec to be safe against renames
	if useDefaultRecordSyntax then begin
		Result := GetElementEditValues(baseRec, 'Record Header\FormID');
	end else begin 
		Result := EditorID(baseRec) + '[' + GetFileName(baseRec) + ']' + ':' + Signature(baseRec);
	end;
end;


//=========================================================================
// locate record in the current load order by string
function StringToRecord(rec: string): IInterface;
var
	i: integer;
	fname, id, sig: string;
	f, g: IInterface;
begin

	if useDefaultRecordSyntax then begin
		rec := ReverseString(rec);
		i := Pos('[', rec);
		rec := Copy(rec, 0, i);
		rec := ReverseString(rec); //--> Rhino "Rhino M1" [WEAP:0B088059] -> [WEAP:0B088059]
		i := Pos(':', rec);
		rec := Copy(rec, i+1,Length(rec)-i-1); // --> 0B088059
		
		f := FileByLoadOrder(StrToInt('$' + Copy(rec, 1, 2)));
		Result := ContainingMainRecord(RecordByFormID(f, StrToInt('$' + rec), true));
	end else begin 
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

end.