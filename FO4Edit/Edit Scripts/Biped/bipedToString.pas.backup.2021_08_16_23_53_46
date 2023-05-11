{
  This script will prepend or append supplied value to the FULL field
  of every selected record.
}
unit FullPrefixSufix;
uses 'lib\getElement';

var
  DoPrepend: boolean;
  s: string;
  
function Initialize: integer;
var
  i: integer;
begin Result := 0;// ask for prefix or suffix mode
 {} i := MessageDlg('Prepend [YES] or append [NO] to Editor ID?', mtConfirmation, [mbYes, mbNo, mbCancel], 0); if i = mrYes then DoPrepend := true else if i = mrNo then DoPrepend := false else begin Result := 1; Exit; end;// ask for string if not InputQuery('Enter', 'Prefix/suffix', s) then begin Result := 2; Exit; end;  // empty string - do nothing if s = '' then Result := 3;}
addmessage('-');
end;
    
function Process(itemX: IInterface): integer;
begin
  Result := 0;
  if Assigned(itemX) 
    then begin
{        if s = 'biped' then SetEditValue(ElementBySignature(itemX,'FULL - Name'), getEditValue(ElementByName(itemX, 'ETYP - Equipment Type')) + BipedDataToString(ElementByName(itemX, 'BMDT - Biped Data')) + getEditValue(ElementByName(itemX, 'FULL - Name'))) {if s = 'reset' then SetEditValue(ElementBySignature(itemX,'FULL - Name'), getEditValue(ElementByName(masterX, 'FULL - Name'))) if s = 'move' then SetEditValue(ElementBySignature(itemX,'FULL - Name'), moveStringPrefix(getEditValue(ElementByName(itemX, 'FULL - Name')))) else if DoPrepend then SetEditValue(itemX, s + GetEditValue(itemX)) else SetEditValue(itemX, GetEditValue(itemX) + s); end;}

		addmessage(ElementByName(itemX, 'Outputs'));

  end;
end;


  end.

