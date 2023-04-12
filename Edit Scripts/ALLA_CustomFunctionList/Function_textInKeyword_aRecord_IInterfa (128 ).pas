
function textInKeyword(aRecord: IInterface; text: string; checkCaps: boolean): boolean;
var
	Keywords: IInterface;
	tempString: String;
	i: Integer;
begin
	result := false;
	if not checkCaps then text := Lowercase(text);
	Keywords := ElementByPath(aRecord, 'KWDA');
	for i := 0 to ec(Keywords) - 1 do begin
		tempString := EditorID(LinksTo(ebi(Keywords, i)));
		if not checkCaps then tempString := Lowercase(tempString);
		if ContainsText(tempString, text) then begin
			Result := True;
		Exit;
		end;
	end;
end;