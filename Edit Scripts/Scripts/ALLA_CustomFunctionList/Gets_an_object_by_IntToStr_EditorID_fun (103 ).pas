

// Gets an object by IntToStr EditorID
function IndexOfObjectbyFULL(s: String; aList: TStringList): Integer;
var
	debugMsg: Boolean;
	i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[IndexOfObjectbyFULL] IndexOfObjectbyFULL('+s+', aList );');
	for i := 0 to aList.Count-1 do begin
		if ContainsText(full(ote(aList.Objects[i])), s) then begin
			Result := i;
			{Debug} if debugMsg then msg('[IndexOfObjectbyFULL] Result := '+IntToStr(Result));
		end;
	end;

	debugMsg := false;
// End debugMsg section
end;