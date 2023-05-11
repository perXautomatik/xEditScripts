{
	Set FULL subrecords
}
unit UserScript;

const
//  StrReplace = 'Wood';
//  StrReplace = 'Leather Sheath';
//  StrReplace = 'Glass';
//  StrReplace = 'Ceramic';
//  StrReplace = 'Plastic';
//  StrReplace = 'Adhesive';
//  StrReplace = 'Steel';
//  StrReplace = 'Scrap Electronics';
//  StrReplace = 'Scrap-Blade';
  StrReplace = 'Scrap Metal';
//  StrReplace = 'Stimpak';
//  StrReplace = 'Cloth';
//StrReplace = 'Empty Syringe';
  StrSearch = '';
var
  ReplaceCount: integer;

function Initialize: integer;
begin
  ReplaceCount := 0;
end;

procedure SearchAndReplace(e: IInterface; s1, s2: string);
var
  s: string;
begin
  if not Assigned(e) then Exit;

  // remove rfIgnoreCase to be case sensitive
  s := StrReplace;

  if not SameText(s, GetEditValue(e)) then begin
    Inc(ReplaceCount);
    AddMessage('Replacing in ' + FullPath(e));
    SetEditValue(e, s);
  end;

end;

function Process(e: IInterface): integer;
begin
  SearchAndReplace(ElementBySignature(e, 'FULL'), StrSearch, StrReplace);
end;

function Finalize: integer;
begin
  AddMessage(Format('Replaced %d occurences.', [ReplaceCount]));
end;

end.
