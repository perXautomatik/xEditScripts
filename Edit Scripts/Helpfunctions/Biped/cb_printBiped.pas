{
  New script template, only shows processed records
  Assigning any nonzero value to Result will terminate script
  todo: cut down functions this overcomplicated and not helpful
}
unit userscript;
uses 'lib/dubhFunctions';

// Called before processing
// You can remove it if script doesn't require initialization code
function Process(e:IInterface): integer;
begin
  PrintBiped(e);
end;

// called for every record selected in xEdit
function PrintBiped(e: IInterface): integer;
var
strPresent: string;
begin
  strPresent := GetBiped(e);
      if Assigned(strPresent) then addMessage(strPresent);
  Result := 0;

  // processing code goes here

end;

function GetBiped(e: IInterface): string;
var
	strPresent, elementName: IInterface;
	strResult,strEl,part,val: string;
  strList : TStringList;
	i: integer;
begin
    addmessage('Processing: ' + name(e));
    strEl := 'BMDT\[' + inttostr(0) + ']'; 
    strPresent := ElementByPath(e,strEl);
      if Assigned(strPresent) then Result := FlagsToNames(strPresent);

  // processing code goes here

end;

end.
