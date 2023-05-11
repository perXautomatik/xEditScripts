{
  New script template, only shows processed records
  Assigning any nonzero value to Result will terminate script
  todo: cut down functions this overcomplicated and not helpful
}
unit userscript;
uses 'dubhFunctions';

// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
  Result := 0;
end;

// called for every record selected in xEdit
function PrintBiped(e: IInterface): string;
var
	strPresent, elementName: IInterface;
	strResult,strEl,part,val: string;
  strList : TStringList;
	i: integer;
begin
    addmessage('Processing: ' + name(e));
    strEl := 'BMDT\[' + inttostr(0) + ']'; 
    strPresent := ElementByPath(e,strEl);
      if Assigned(strPresent) then addMessage(FlagsToNames(strPresent));
  Result := FlagsToNames(strPresent);

  // processing code goes here

end;

end.
