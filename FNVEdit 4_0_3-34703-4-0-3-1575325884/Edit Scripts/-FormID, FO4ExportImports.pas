
{
  Export FormID list to CSV text file (*.csv) and import it back
  CSV files can be edited in Excel or other speadsheets
  
  The plugin you are importing to must have all masters added used by imported keywords
  After Import change to another file and back to refresh the references
  
  Tested for Lists containing references to AMMO, WEAP, MISC, ALCH
  But should work for all kind of records
}

unit FormidExpIMport;
uses 'universalHelperFunctions';

const
	sDelimiterChar = ';';
	sortedExport = true;
	autoAddMasters = true;
	useDefaultRecordSyntax = false;


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