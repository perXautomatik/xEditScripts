//////////////////////////////// FILE BY NAME IS NATIVE PAST xEdit 4.1.x //////////////////////////////////
// Find loaded plugin by name
function FileByName(aPluginName: String): IInterface;
var
	debugMsg: Boolean;
  i: Integer;
begin
	// Begin debugMsg section
	debugMsg := false;

	{Debug} if debugMsg then msg('[FileByName] FileByName('+aPluginName+' );');
	for i := 0 to Pred(FileCount) do begin
		if (LowerCase(GetFileName(FileByIndex(i))) = LowerCase(aPluginName)) then begin
			result := FileByIndex(i);
			{Debug} if debugMsg then msg('FileByIndex(i) := '+GetFileName(Result));
			exit;
		end else begin
			{Debug} if debugMsg then msg('[FileByName] '+aPluginName+' not found');
			Result := nil;
		end;
	end;
end;