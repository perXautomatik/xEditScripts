unit userscript;
uses: 'universalHelperFunctions';
var
FormIDList: TStringList;
ePath: IInterface;
eString, NewString: string;
i, iInt: integer;
bAddedEmptyEntries: boolean;


function Initialize: integer;
begin
	FormIDList := TStringList.Create;
	FormIDList.LoadFromFile(ProgramPath + 'Edit Scripts\FyTy\Clothes FormIDs.txt');
	
	AddMessage('First Clothing is: '+FormIDList[0]);
end;



function Process(e: IInterface): integer;
begin
  if Signature(e) <> 'LVLI' then
		exit;

  AddMessage('Processing: ' + FullPath(e));
	
	if (ElementExists(e, 'Leveled List Entries') = false) and (bAddedEmptyEntries = false) and (ElementCount(ElementByPath(e, 'Leveled List Entries')) <= 1) then
		AddToLeveledListWithoutEntries(e);
	
	if (ElementExists(e, 'Leveled List Entries')) and (bAddedEmptyEntries = false) and (ElementCount(ElementByPath(e, 'Leveled List Entries')) <= 1) then
		AddToLeveledListWithEntries(e);
	
	EditAddedLevelledListEntries(e);
end;


function Finalize: integer;
begin

end;

end.
