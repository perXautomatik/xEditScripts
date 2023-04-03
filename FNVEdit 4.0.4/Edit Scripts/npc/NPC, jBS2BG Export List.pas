{
	Export female NPC list for jBodySlide2BodyGen.
}
unit ExportScripts;

var
	NPCList : TStringList;
	ModNameList : TStringList;
	strFileName : string;

// Called when the script starts
function Initialize : integer;
var i : integer;
begin
	NPCList := TStringList.Create;
	
	ModNameList := TStringList.Create;
	ModNameList.Sorted := True;
	ModNameList.Duplicates := dupIgnore;

	strFileName := 'FemaleNPCList';
	
	AddMessage('Exporting female NPCs to ' + strFileName + ' - [Masters].txt...');
end;

// Called for each selected record in the TES5Edit tree
// If an entire plugin is selected then all records in the plugin will be processed
function Process(e : IInterface) : integer;
var i : integer;
	strTemp, strMod, strName, strEditorId, strRace, strFormId : string;
begin
	if Signature(e) <> 'NPC_' then exit;
	
	if ElementExists(e, 'ACBS - Configuration\Flags\Female') AND NOT ElementExists(e, 'ACBS - Configuration\Flags\Is CharGen Face Preset') then begin
		strMod := '' + GetFileName(GetFile(e));
		strName := GetElementEditValues(e, 'FULL');
		strEditorId := GetElementEditValues(e, 'EDID');
		strRace := '' + GetElementEditValues(e, 'RNAM');
		strFormId := '' + IntToHex(FixedFormID(e), 8);
	
		strTemp := strMod + ' | ' + strName + ' | ' + strEditorId + ' | ' + strRace + ' | ' + strFormId;
		NPCList.Add(strTemp);
		
		ModNameList.Add(strMod);
		
		AddMessage(strTemp);
	end;
end;

// Called after the script has finished processing every record
function Finalize : integer;
var i : integer;
	strMods : string;
begin
	strMods := '';
	
	for i := 0 to ModNameList.Count - 1 do
	begin
		if (i <= 0) then
			begin
				strMods := ModNameList[i];
				strMods := stringreplace(strMods, '.esm', '', [rfReplaceAll, rfIgnoreCase]);
				strMods := stringreplace(strMods, '.esp', '', [rfReplaceAll, rfIgnoreCase]);
			end
		else
			begin
				strMods := strMods + ' + ' + ModNameList[i];
				strMods := stringreplace(strMods, '.esm', '', [rfReplaceAll, rfIgnoreCase]);
				strMods := stringreplace(strMods, '.esp', '', [rfReplaceAll, rfIgnoreCase]);
			end;
	end;
	
	
	strFileName := strFileName + ' - ' + strMods + '.txt';
	NPCList.SaveToFile(strFileName);
	AddMessage(Format('Exported %d NPCs to file %s.', [NPCList.Count, strFileName]));
	
	ModNameList.Free;
	NPCList.Free;
end;

end.