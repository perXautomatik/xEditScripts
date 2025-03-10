{FyTy}
unit userscript;

// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
  Result := 0;
end;

// called for every record selected in xEdit
function Process(e: IInterface): integer;
begin
  Result := 0;

  // comment this out if you don't want those messages
  AddMessage('Processing: ' + FullPath(e));

  // processing code goes here
  SetElementNativeValues(e, 'DATA\Flags', GetElementNativeValues(e, 'DATA\Flags') or 4);

end;

// Called after processing
// You can remove it if script doesn't require finalization code
function Finalize: integer;
begin
  Result := 0;
end;

end.
