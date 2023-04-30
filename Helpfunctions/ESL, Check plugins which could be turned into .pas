{
  Find plugins which can be converted to ESL
}
unit FindPotentialESL;

uses: 'universalHelperFunctions'
const
  iESLMaxRecords = $800; // max possible new records in ESL
  iESLMaxFormID = $fff; // max allowed FormID number in ESL


function Initialize: integer;
var
  i: integer;
  f: IInterface;
begin
  // iterate over loaded plugins
  for i := 0 to Pred(FileCount) do begin
    f := FileByIndex(i);
    // skip the game master
    if GetLoadOrder(f) = 0 then
      Continue;
    // check non-light plugins only
    if (GetElementNativeValues(ElementByIndex(f, 0), 'Record Header\Record Flags\ESL') = 0) and not SameText(ExtractFileExt(GetFileName(f)), '.esl') then
      CheckForESL(f);
  end;
end;


end.
