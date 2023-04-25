{
	Set FULL subrecords
}
unit UserScript;

const
  StrReplace = 'Scrap Electronics';

var
  StrSearch,StrReplace: string;
  ReplaceCount: integer;


function Initialize: integer;
begin
  ReplaceCount := 0;
end;



procedure AskForString(t: String);
var
  s: string;
begin
  // ask for string
  if not InputQuery('Enter', t, s) then begin
    Result := s;
    Exit;
  end;
  
  // empty string - do nothing
  if s = '' then
    Result := s;
end;



procedure SearchAndReplace(e: IInterface; s1, s2: string);
var
  s: string;
begin
  if not Assigned(e) then Exit;

  // remove rfIgnoreCase to be case sensitive
  s := StringReplace(GetEditValue(e), s1, s2, [rfReplaceAll, rfIgnoreCase]);

  if not SameText(s, GetEditValue(e)) then begin
    Inc(ReplaceCount);
    AddMessage('Replacing in ' + FullPath(e));
    SetEditValue(e, s);
  end;

end;

function Process(e: IInterface): integer;
begin
  SearchAndReplace(ElementBySignature(e, AskForString('ElementBySignature')), AskForString('StrSearch'), AskForString('StrReplace'));
end;

function Finalize: integer;
begin
  AddMessage(Format('Replaced %d occurences.', [ReplaceCount]));
end;

end.
