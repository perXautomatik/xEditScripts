{
  New script template, only shows processed records
  Assigning any nonzero value to Result will terminate script
}
unit userscript;

// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
  Result := 0;
end;

// called for every record selected in xEdit
function Process(e: IInterface): integer;
var
q: TStrings;
begin
  Result := 0;
  // comment this out if you don't want those messages
  AddMessage('Processing: ' + name(e));
/// <summary>Checks which master files aeElement depends on, and adds their filenames to akListOut. First boolean is Recursive to go over children elements if it is a container, second is Initial which is false by default.</summary>
//ReportRequiredMasters(aeElement: IwbElement; akListOut: TStrings; akUnknown1: boolean; akUnknown2: boolean);

AddMessage('linksto: ');
AddMessage(FullPath(getfile(e)));

  // processing code goes here

end;

// Called after processing
// You can remove it if script doesn't require finalization code
function Finalize: integer;
begin
  Result := 0;
end;

end.
