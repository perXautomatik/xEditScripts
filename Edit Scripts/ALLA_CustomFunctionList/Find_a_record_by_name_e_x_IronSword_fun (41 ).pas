
// Find a record by name (e.x. 'IronSword')
function RecordByName(aName: String; aGroupName: String; aFileName: String): IInterface;
var
  slTemp: TStringList;
  i, slTempCount: Integer;
begin
	// Initialize
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;

	// Function
  if not (StrEndsWith(aFileName, '.esm') or StrEndsWith(aFileName, '.esl') or StrEndsWith(aFileName, '.exe')) then AppendIfMissing(aFileName, '.esp');
  if (aFileName = 'Skyrim.esm') then begin
    slTemp := TStringList.Create;
	slTemp.CommaText := 'Skyrim.esm, Dawnguard.esm, HearthFires.esm, Dragonborn.esm';
  end else begin
    slTemp := TStringList.Create;
	slTemp.Add(aFileName);
  end;
  for slTempCount := 0 to slTemp.Count-1 do begin
		for i := 0 to Pred(ec(gbs(FileByName(slTemp[slTempCount]), aGroupName))) do begin
			if ContainsText(EditorID(ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i)), 'Ench') or ContainsText(full(ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i)), 'Of') then begin
				Continue;
			end else if ContainsText(EditorID(ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i)), aName) then begin
				Result := ebi(gbs(FileByName(slTemp[slTempCount]), aGroupName), i);
				Exit;
			end;
		end;
  end;

	// Finalize
	slTemp.Free;
end;