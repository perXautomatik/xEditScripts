

// Find if a file is loaded is xEdit
function DoesFileExist(aPluginName: String): Boolean;
var
	debugMsg: Boolean;
	i: Integer;
	fn: string;
begin
// Begin debugMsg section
	debugMsg := false;

	// Function
	Result := True;
	for i := 0 to Pred(FileCount) do begin
		FN := GetFileName(FileByIndex(i));
		// {Debug} if debugMsg then msg('[DoesFileExist] GetFileName(aPluginName) := '+aPluginName);
		{Debug} if debugMsg then msg('[DoesFileExist] if ('+aPluginName+' = '+ FN +' ) then begin');
		if (aPluginName = FN) then begin
			{Debug} if debugMsg then msg('[DoesFileExist] Result := '+ FN);
			Exit;
		end;
	end;
	Result := False;
end;