{
adhodoc append armorslot indication as prefix to itemname if biped is set as prefix textraise 
todo: cut down functions this overcomplicated and not helpful
if GetChar(val, 1) = '1' then
result := result + 'head' + ';';
end;

\bmdt - biped data\biped flags (sorted)\hat\
\bmdt - biped data\biped flags (sorted)\mask\
}
unit FullPrefixSufix;
uses 'biped/cb_printBiped';

var
  DoPrepend: boolean;
  s: string;
  
function Initialize: integer;
begin
  if not InputQuery('Enter', 'sure you want to append bipedData to full?', s) then begin
    Result := 2;
    Exit;
  end;  // empty string - do nothing
  if s = '' then
    Result := 3;
end;
    
function Process(itemX: IInterface): integer;
var
	strName,newName: string;
	eName: IInterface;
begin
  Result := 0;
  if Assigned(itemX) 
    then begin

	eName := ElementBySignature(itemX, 'FULL');
	strName := GetEditValue(eName);
	newName := GetBiped(itemX) +'|'+ strName;
          SetEditValue(eName, newName);
      end;
end;
    
  end.

