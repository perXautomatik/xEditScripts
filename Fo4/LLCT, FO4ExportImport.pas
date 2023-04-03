
{
  Export LLCT record list of a leveled list to CSV text file (*.csv) and import it back
  CSV files can be edited in Excel or other speadsheets
  
  The plugin you are importing to must have all masters added used by imported keywords
  After Import change to another file and back to refresh the references
  
  Tested for Lists containing references to LVLI, MISC, WEAP, ARMO, ALCH, AMMO, NOTE
  But should work for all kind of LLCT records
}
unit FO4ExportImportLLCT;

uses 'universalHelperFunctions';

const
	sDelimiterChar = ';';
	sortedExport = true;
	itemsFirst = false;
	autoAddMasters = true;
	


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