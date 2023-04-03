{
    Run on a cell, select spawns CSV
}
unit ImportCsvToCell;
    uses 'SS2\praUtilSS2';
    uses '..\universalHelperFunctions';
    var
        csvLines: TStringList;
        groupsToSearch: TStringList;
        selectedCell: IInterface;


    // Called before processing
    // You can remove it if script doesn't require initialization code
    function Initialize: integer;
    begin
        Result := 0;


        groupsToSearch := TStringList.create;

        groupsToSearch.add('MISC');
        groupsToSearch.add('ALCH');
        groupsToSearch.add('AMMO');
        groupsToSearch.add('ARMO');
        groupsToSearch.add('BOOK');
        groupsToSearch.add('WEAP');
        groupsToSearch.add('CONT');
        groupsToSearch.add('DOOR');
        groupsToSearch.add('FLOR');
        groupsToSearch.add('FURN');
        groupsToSearch.add('LIGH');
        groupsToSearch.add('LVLI');
        groupsToSearch.add('LVLN');
        groupsToSearch.add('MSTT');
        groupsToSearch.add('NOTE');
        groupsToSearch.add('NPC_');
        groupsToSearch.add('STAT');
        groupsToSearch.add('SCOL');
        groupsToSearch.add('TERM');
        groupsToSearch.add('KEYM');
        groupsToSearch.add('ACTI');
        groupsToSearch.add('IDLM');
        groupsToSearch.add('SOUN');
        groupsToSearch.add('FLST');

        selectedCell := nil;
    end;

    // called for every record selected in xEdit
    function Process(e: IInterface): integer;
    begin
        Result := 0;

        if(signature(e) <> 'CELL') then exit;

        if(not assigned(selectedCell)) then begin
            selectedCell := e;
        end else begin
            AddMessage('Error: You must run this script on one cell exactly! More than one found!');
            Result := 1;
        end;

        //AddMessage('Processing: ' + FullPath(e));
        // start at 1 to skip the header


        // processing code goes here

    end;

    // Called after processing
    // You can remove it if script doesn't require finalization code
    function Finalize: integer;
    var
		fields: TStringList;
        i: integer;
        curLine, planName: string;
    begin
        Result := 0;

        if(not assigned(selectedCell)) then begin
            AddMessage('Error: You must run this script on one cell exactly! None found!');
            exit;
        end;

        csvLines := LoadFromCsv();

        if(csvLines = nil) then begin
            Result := 1;
            AddMessage('Cancelled');
            exit;
        end;

        if(csvLines.count <= 0) then begin
            csvLines.free();
            Result := 1;
            AddMessage('No CSV file loaded!');
            exit;
        end;

		fields := TStringList.Create;

        fields.Delimiter := ',';
        fields.StrictDelimiter := TRUE;
        fields.DelimitedText := csvLines[0];

        planName := fields[0];

		planName := StringReplace(planName, ' ', '_', '');
        
        if(planName = 'Form') then begin
            planName := 'BuildingPlan';
        end;

		fields.free;

        Randomize();

        for i:=1 to csvLines.count-1 do begin
            curLine := csvLines[i];
            processLine(selectedCell, curLine, planName);
        end;

        csvLines.free();
    end;

end.