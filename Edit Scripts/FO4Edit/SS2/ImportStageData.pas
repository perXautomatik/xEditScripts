{
    Import StageModels and StageItemSpawns to a Building Plan or Skin, SimSettlements 2 edition
}
unit ImportStageData;

uses 'SS2\SS2Lib'; // uses praUtil

const
    MODE_BP_ROOT    = 1;
    MODE_BP_LEVEL   = 2;
    MODE_SKIN_ROOT  = 4;
    MODE_SKIN_LEVEL = 5;
    configFile = ProgramPath + 'Edit Scripts\SS2\SS2_ImportStageData.cfg';

var
    targetElem, targetFile: IInterface;
    globalTargetBlueprintElem: IInterface;
    globalTargetSingleLevelElem: IInterface;
    skinTargetBuildingPlan: IInterface;
    stageFilePath, itemFilePath: string;
    skinSpawnsMode, setupStacking: boolean;

    plotName, plotId, modPrefix, plotEdidBase, descriptionBase: string;

    plotData: TJsonObject;

    currentMode, currentType: integer;

    numStages, selectedLevelNr, extractedLevelNr, extractedStageNr: integer;

    existingPlotThemes: TStringList;

    autoRegister, makePreviews: boolean;


function isSkinMode(): boolean;
begin
    Result := ((currentMode = MODE_SKIN_ROOT) or (currentMode = MODE_SKIN_LEVEL));
end;

procedure loadConfig();
var
    i, j, breakPos: integer;
    curLine, curKey, curVal: string;
    lines : TStringList;
begin
    // default
    modPrefix := '';

    if(not FileExists(configFile)) then begin
        exit;
    end;
    lines := TStringList.create;
    lines.LoadFromFile(configFile);

    //
    for i:=0 to lines.count-1 do begin
        curLine := lines[i];
        breakPos := -1;

        for j:=1 to length(curLine) do begin
            if(curLine[j] = '=') then begin
                breakPos := j;
                break;
            end;
        end;

        if breakPos <> -1 then begin
            curKey := trim(copy(curLine, 0, breakPos-1));
            curVal := trim(copy(curLine, breakPos+1, length(curLine)));

            if(curKey = 'ModPrefix') then begin
                modPrefix := curVal;
            end else if(curKey = 'AutoRegister') then begin
                autoRegister := StrToBool(curVal);
            end else if(curKey = 'MakePreviews') then begin
                makePreviews := StrToBool(curVal);
            end else if(curKey = 'SetupStacking') then begin
                setupStacking := StrToBool(curVal);
            end;
        end;
    end;

    lines.free();
end;

procedure saveConfig();
var
    lines : TStringList;
begin
    lines := TStringList.create;
    lines.add('ModPrefix='+modPrefix);
    lines.add('AutoRegister='+BoolToStr(autoRegister));
    lines.add('MakePreviews='+BoolToStr(makePreviews));
    lines.add('SetupStacking='+BoolToStr(setupStacking));

    lines.saveToFile(configFile);
    lines.free();
end;


function findPrefix(edid: string): string;
var
    str: string;
    i: integer;
begin
    str := edid;
    Result := '';
    for i:=1 to length(str)-1 do begin
        if(str[i] = '_') then begin
            Result := copy(str, 0, i);
            exit;
        end;
    end;
end;

procedure typeSelectCallback(sender: TObject);
var
    levelInput: TEdit;
begin
    levelInput := sender.parent.findComponent('LevelInput');

    if (sender.ItemIndex = 0) or (sender.ItemIndex = 2) then begin
        levelInput.enabled := false;
    end else begin
        levelInput.enabled := true;
    end;

end;

procedure addToStackEnabledListIfEnabled(model: IInterface);
begin
    if(not setupStacking) then exit;

    addToStackEnabledList(targetFile, model);
end;

function showTypeSelectDialog(): boolean;
var
    frm: TForm;
    btnOk, btnCancel: TButton;
    resultCode: integer;
    typeSelect: TComboBox;
    entries: TStringList;
    levelInput: TEdit;
begin
    Result := false;

    frm := CreateDialog('Stage Data Import', 400, 170);

    CreateLabel(frm, 10, 10, 'No element selected for import. What do you want to generate?');

    entries := TStringList.create();
    entries.add('Entire Building Plan');
    entries.add('Single Building Plan Level');
    entries.add('Entire Skin');
    entries.add('Single Skin Level');

    typeSelect := CreateComboBox(frm, 10, 30, 150, entries);
    typeSelect.Style := csDropDownList;
    typeSelect.ItemIndex := 0;
    typeSelect.onChange := typeSelectCallback;

    CreateLabel(frm, 180, 32, 'Level nr.:');
    levelInput := CreateInput(frm, 230, 30, '1');
    levelInput.width := 30;
    levelInput.enabled := false;
    levelInput.name := 'LevelInput';


    btnOk     := CreateButton(frm, 100, 100, ' OK ');
    btnCancel := CreateButton(frm, 200, 100, 'Cancel');

    btnCancel.ModalResult := mrCancel;

    btnOk.ModalResult := mrYes;
    btnOk.Default := true;

    resultCode := frm.showModal();

    selectedLevelNr := 0;

    if(resultCode = mrYes) then begin
        if(typeSelect.ItemIndex = 0) then begin
            currentMode := MODE_BP_ROOT;
            Result := true;
        end else if(typeSelect.ItemIndex = 2) then begin
            currentMode := MODE_SKIN_ROOT;
            Result := true;
        end else begin
            selectedLevelNr := StrToInt(levelInput.text);
            if(typeSelect.ItemIndex = 1) then begin
                currentMode := MODE_BP_LEVEL;
                Result := true;
            end else if(typeSelect.ItemIndex = 3) then begin
                currentMode := MODE_SKIN_LEVEL;
                Result := true;
            end;
        end;
    end;

    entries.free();
    frm.free();
end;

function showConfigDialog(): boolean;
var
    resultData: TJsonObject;
    dialogLabel, skinTargetEdid: string;
    plotType: integer;
//    plotThemes: TStringList;
    requreStageModels, isSkin, showThemeSelector, hasSkinTarget, isNewEntry: boolean;
begin
    Result := false;

    isSkin := false;

    if(currentMode = 0) then begin
        if(not showTypeSelectDialog()) then begin
            exit;
        end;
    end;

    if(existingPlotThemes <> nil) then begin
        existingPlotThemes.free();
        existingPlotThemes := nil;
    end;
    //plotThemes := nil;
    plotType := -1;
    plotName := '';
    plotId := '';
    // modPrefix := '';
    requreStageModels := true;
    showThemeSelector := true;

    loadConfig();

    isNewEntry := true;
    if(assigned(targetElem)) then begin
        isNewEntry := false;

        plotName := DisplayName(targetElem);
        plotId := EditorId(targetElem);
        modPrefix := findPrefix(plotId);
        plotType := -1;
        requreStageModels := false;

        if(currentMode = MODE_BP_ROOT) then begin
            plotType := getNewPlotType(targetElem);
            existingPlotThemes := getPlotThemes(targetElem);
            dialogLabel := 'Selected Blueprint: '+plotId;
        end else if(currentMode = MODE_BP_LEVEL) then begin
            dialogLabel := 'Selected Blueprint Level: '+plotId;
            showThemeSelector := false;
        end else if(currentMode = MODE_SKIN_ROOT) then begin
            existingPlotThemes := getPlotThemes(targetElem);
            // plotType := getNewPlotType(targetElem);
            dialogLabel := 'Selected Skin: '+plotId;
            isSkin := true;
        end else if(currentMode = MODE_SKIN_LEVEL) then begin
            dialogLabel := 'Selected Skin Level: '+plotId;
            isSkin := true;
            showThemeSelector := false;
        end;
    end else begin
        // generate new
        if(currentMode = MODE_BP_ROOT) then begin
            plotType := 0;
            dialogLabel := 'Create new Blueprint';
        end else if(currentMode = MODE_BP_LEVEL) then begin
            showThemeSelector := false;
            dialogLabel := 'Create new Blueprint Level';
        end else if(currentMode = MODE_SKIN_ROOT) then begin
            plotType := 0;
            dialogLabel := 'Create new Skin';
            isSkin := true;
        end else if(currentMode = MODE_SKIN_LEVEL) then begin
            showThemeSelector := false;
            dialogLabel := 'Create new Skin Level';
            isSkin := true;
        end;
    end;

    // ugh
    // ShowPlotCreateDialog

    if(isSkin) then begin
        // old skin target
        if(assigned(targetElem)) then begin
            skinTargetBuildingPlan := getSkinTargetPlot(targetElem);
        end;

        // function ShowSkinCreateDialog(title, text, initialPlotName, initialPlotId, initialModPrefix: string; existingPlotTarget: IInterface; showThemeSelector: boolean; initialThemes: TStringList; autoRegister, makePreview: boolean): TJsonObject;
        resultData := ShowSkinCreateDialog(
            'Skin Data Import', // title
            dialogLabel,    // text
            plotName,       // skin name
            plotId,         // skin edid
            modPrefix,      // mod prefix
            skinTargetBuildingPlan, // target BP
            showThemeSelector,           // isFullSkin
            existingPlotThemes,            // initial themes
            autoRegister,           // autoRegister
            makePreviews,            // make previews
            setupStacking
        );

        if(not assigned(resultData)) then begin
            exit;
        end;

        stageFilePath := resultData.S['modelsFile'];
        itemFilePath  := resultData.S['itemsFileAdd'];

        // currentType   := resultData.I['type'];
        plotName      := resultData.S['name'];
        plotId        := resultData.S['edid'];
        modPrefix     := resultData.S['prefix'];
        skinSpawnsMode:= resultData.B['itemsReplace'];
        skinTargetEdid:= resultData.S['targetPlot'];

		autoRegister     := resultData.B['registerPlot'];
        makePreviews     := resultData.B['makePreview'];
        setupStacking    := resultData.B['setupStacking'];

        hasSkinTarget := false;

        if(skinTargetEdid <> '') then begin
            if(assigned(skinTargetBuildingPlan)) then begin
                if(skinTargetEdid = EditorID(skinTargetBuildingPlan)) then begin
                    hasSkinTarget := true;
                end;
            end;

            if(not hasSkinTarget) then begin
                skinTargetBuildingPlan := FindObjectByEdid(skinTargetEdid);
            end;
        end else begin
            if(assigned(skinTargetBuildingPlan)) then hasSkinTarget := true;
        end;

        // for SS2Lib
        globalNewFormPrefix := modPrefix;
        resultData.free();

        if(plotName = '') or (plotId = '') or (modPrefix = '') then begin
            AddMessage('Plot Name, Plot ID and Mod Prefix must be filled out');
            exit;
        end;
    end else begin
        resultData := ShowPlotCreateDialog(
                'Plot Data Import',
                dialogLabel,
                plotName,
                plotId,
                modPrefix,
                plotType,
                requreStageModels,
                showThemeSelector,
                existingPlotThemes,
                autoRegister,
                makePreviews,
                setupStacking,
                isNewEntry
            );

        // selectedThemeTagList

        if(not assigned(resultData)) then begin
            exit;
        end;

        AddMessage(resultData.ToString());

        stageFilePath := resultData.S['modelsFile'];
        itemFilePath  := resultData.S['itemsFile'];
        currentType   := resultData.I['type'];
        plotName      := resultData.S['name'];
        plotId        := resultData.S['edid'];
        modPrefix     := resultData.S['prefix'];

        autoRegister     := resultData.B['registerPlot'];
        makePreviews     := resultData.B['makePreview'];
        setupStacking    := resultData.B['setupStacking'];

        descriptionBase := resultData.S['description'];

        // resultData


        // for SS2Lib
        globalNewFormPrefix := modPrefix;

        resultData.free();

        if(plotName = '') or (plotId = '') or (modPrefix = '') then begin
            AddMessage('Plot Name, Plot ID and Mod Prefix must be filled out');
            exit;
        end;
    end;

    plotEdidBase := StripPrefix(modPrefix, plotId);


    Result := true;
end;



function importModelData(modelsSheet: string): boolean;
var
    csvLines, csvCols: TStringList;
    i, j, lvl, stage: integer;
    curLine, curRow: string;
    stageObj: TJSONObject;
    modelElem: IInterface;
begin
    Result := true;
    csvLines := TStringList.create;
    csvLines.LoadFromFile(modelsSheet);

    lvl := 0;
    stage := 0;

    for i:=0 to csvLines.count-1 do begin
        curLine := csvLines.Strings[i];
        if(curLine = '') then begin
            continue;
        end;


        csvCols := TStringList.create;

        csvCols.Delimiter := ',';
        csvCols.StrictDelimiter := TRUE;
        csvCols.DelimitedText := curLine;

        if (csvCols.count > 0) then begin
            for stage:=0 to csvCols.count-1 do begin
                curRow := csvCols.Strings[stage];

                if(curRow = '') then begin
                    break;
                end;

                if(lvl = 0) then begin
                    if(isSkinMode()) then continue;

                    if (curRow = 'default') then begin
                        // special shortcut for buildMats
                        plotData.S['buildMats'] := '';
                        continue;
                    end;
                end;

                modelElem := FindObjectByEdidWithSuffix(curRow);
                if (not assigned(modelElem)) then begin
                    AddMessage('ERROR: found no Form for '+curRow);
                    Result := false;
                    curRow := '0';
                end else begin
                    curRow := FormToStr(modelElem);// IntToStr(GetLoadOrderFormID(modelElem));
                end;

                if(lvl > 0) then begin
                    //stageObj := plotData.O['levels'].O[lvl].A['models'].AddObject();
                    stageObj := plotData.O['levels'].O[lvl].A['models'].Add(curRow);
                    // stageObj.S['model'] := curRow;
                end else begin
                    plotData.S['buildMats'] := curRow;
                end;
            end;
        end;

        lvl := lvl + 1;
        csvCols.free();
    end;

    plotData.B['hasModels'] := true;
    csvLines.free();
end;

function findMaxStageForLevel(lvl: integer): integer;
var
    existingLevel, existingLevelScript, modelList: IInterface;
    i: integer;
    modelsArray: TJsonArray;
begin
    Result := 1;

    // if models in json exists, use them
    if(plotData.B['hasModels']) then begin
        modelsArray := plotData.O['levels'].O[lvl].A['models'];
        if(modelsArray.count > 0) then begin
            Result := modelsArray.count;
            // AddMessage('Found '+IntToStr(Result));
            exit;
        end;
    end;


    if(assigned(globalTargetBlueprintElem)) then begin
        // AddMessage('Yes have globalTargetBlueprintElem');
        // fish it out of the levels
        existingLevel := getLevelBuildingPlan(globalTargetBlueprintElem, lvl);

        if(assigned(existingLevel)) then begin
            // AddMessage('Yes have existing level');
            existingLevelScript := getScript(existingLevel, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
            modelList := getScriptProp(existingLevelScript, 'StageModels');

            Result := ElementCount(modelList);
            exit;
        end;
    end;

    if(assigned(globalTargetSingleLevelElem)) then begin
        existingLevelScript := getScript(globalTargetSingleLevelElem, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
        modelList := getScriptProp(existingLevelScript, 'StageModels');

        Result := ElementCount(modelList);
        exit;
    end;

end;

function isRIDP(elem: IInterface): boolean;
begin
    Result := false;

    if(assigned(getScript(elem, 'WorkshopFramework:ObjectRefs:RealInventoryDisplayPoint'))) then begin
        Result := true;
        exit;
    end;

    if(Pos(EditorID(elem), 'RIDP') > 0) then begin
        Result := true;
        exit;
    end;
end;

function getArrayElemDefault(arr: TStringList; index: integer; default: string): string;
begin
    if(arr.count > index) then begin
        Result := arr[index];
        exit;
    end;

    Result := default;
end;

function importItemData(itemsSheet: string; skinReplace: boolean): boolean;
var
    csvLines, csvCols: TStringList;
    i, j, lvl, stage, stageEnd, maxStage, vendorLevel: integer;
    curEditorId, curLine, curRow, vendorType, spawnName, reqsEdid: string;
    lvlObj, stageObj, curSpawnObj, ridpObj: TJSONObject;
    spawnsArr: TJSONArray;
    curElement, reqsElement: IInterface;
begin
    Result := true;
    csvLines := TStringList.create;
    csvLines.LoadFromFile(itemsSheet);

    lvl := 0;
    stage := -1;

    for i:=1 to csvLines.count-1 do begin
        curLine := csvLines.Strings[i];
        if(curLine = '') then begin
            continue;
        end;

        csvCols := TStringList.create;

        csvCols.Delimiter := ',';
        csvCols.StrictDelimiter := TRUE;
        csvCols.DelimitedText := curLine;

        curEditorId := trim(csvCols[0]);
        if(curEditorId = '') then begin
            continue;
        end;

        curElement := FindObjectByEdidWithSuffix(curEditorId);
        if (not assigned(curElement)) then begin
            AddMessage('ERROR: found no Form for '+curEditorId);
            Result := false;
            csvCols.Free;
            continue;
        end;


        // pos, rot, scale
        if (csvCols.count < 9) or
            (csvCols.Strings[1] = '') or
            (csvCols.Strings[2] = '') or
            (csvCols.Strings[3] = '') or
            (csvCols.Strings[4] = '') or
            (csvCols.Strings[5] = '') or
            (csvCols.Strings[6] = '') or
            (csvCols.Strings[7] = '') or
            (csvCols.Strings[8] = '') then begin // 8 is level
            AddMessage('Line "'+curLine+'" is not valid, skipping');
            csvCols.Free;
            continue;
        end;
//Line "praSS2_CustomChairMarkerSitAndEat_BackONly001,51.0000,-132.0000,0.0000,0.0000,-0.0000,90.0000,1.0000,,,,,,,1,," is not valid, skipping

        // find correct level and stage
        lvl := StrToInt(csvCols.Strings[8]);
        lvlObj := plotData.O['levels'].O[lvl];

        if (plotData.O['levels'].O[lvl].I['maxStage'] <= 0) then begin
            // AddMessage('MaxStage not set, finding it');
            maxStage := findMaxStageForLevel(lvl);
            plotData.O['levels'].O[lvl].I['maxStage'] := maxStage;
        end else begin
            maxStage := plotData.O['levels'].O[lvl].I['maxStage'];
        end;

        stage := -1;
        stageEnd := -1;

        if(not isSkinMode()) then begin
            if(getArrayElemDefault(csvCols, 9, '') = '') then begin
                stage := -1;
            end else begin
                stage := StrToInt(getArrayElemDefault(csvCols, 9, '-1'));

                if(stage < 0) then begin
                    stage := -1;
                end else if(stage > maxStage) then begin
                    AddMessage('Invalid stage nr in '+curLine+': '+IntToStr(stage)+'. Stage will be set to '+IntToStr(maxStage));
                    stage := -1;
                end;
            end;


            if(getArrayElemDefault(csvCols, 10, '') <> '') then begin
                stageEnd := StrToInt(getArrayElemDefault(csvCols, 10, '0'));
                if(stageEnd > stage) then begin
                    if(stageEnd > maxStage) then begin
                        AddMessage('Invalid end stage nr in '+curLine+': '+IntToStr(stageEnd)+'. Stage will be set to '+IntToStr(maxStage));
                        stageEnd := -1;
                    end;
                end else begin
                    AddMessage('Invalid end stage nr in '+curLine+': '+IntToStr(stageEnd)+'. Stage will be set to '+IntToStr(maxStage));
                    stageEnd := -1;
                end;
            end;
        end;

        // RIDP STUFF
        if(isRIDP(curElement)) then begin
            // this is a display point
            // AddMessage('YES IS RIDP');

            if(skinReplace) then begin
                ridpObj := lvlObj.O['ridpReplace'];//stageObj.A['spawns'];
            end else begin
                ridpObj := lvlObj.O['ridp'];//stageObj.A['spawns'];
            end;

            vendorType  := getArrayElemDefault(csvCols, 12, '0'); // String '0' is an okay default here, ints are vanilla types
            vendorLevel := StrToInt(getArrayElemDefault(csvCols, 13, '0'));

            // have to group them by spawns
            spawnsArr := ridpObj.O[IntToStr(stage)].O[IntToStr(stageEnd)].O[vendorType].A[vendorLevel];

            curSpawnObj := spawnsArr.addObject();

            curSpawnObj.S['Form'] := FormToStr(curElement);//IntToStr(GetLoadOrderFormID(curElement));
            curSpawnObj.F['posX'] := StrToFloat(csvCols.Strings[1]);
            curSpawnObj.F['posY'] := StrToFloat(csvCols.Strings[2]);
            curSpawnObj.F['posZ'] := StrToFloat(csvCols.Strings[3]);
            curSpawnObj.F['rotX'] := StrToFloat(csvCols.Strings[4]);
            curSpawnObj.F['rotY'] := StrToFloat(csvCols.Strings[5]);
            curSpawnObj.F['rotZ'] := StrToFloat(csvCols.Strings[6]);
            curSpawnObj.F['scale']:= StrToFloat(csvCols.Strings[7]);

            // 11 = type
            // 12 = sVendorType
            // 13 = iVendorLevel

            csvCols.free();
            continue;
        end;

        spawnsArr := lvlObj.A['spawns'];//stageObj.A['spawns'];

        curSpawnObj := spawnsArr.addObject();

        curSpawnObj.S['Form'] := FormToStr(curElement);//IntToStr(GetLoadOrderFormID(curElement));
        curSpawnObj.F['posX'] := StrToFloat(csvCols.Strings[1]);
        curSpawnObj.F['posY'] := StrToFloat(csvCols.Strings[2]);
        curSpawnObj.F['posZ'] := StrToFloat(csvCols.Strings[3]);
        curSpawnObj.F['rotX'] := StrToFloat(csvCols.Strings[4]);
        curSpawnObj.F['rotY'] := StrToFloat(csvCols.Strings[5]);
        curSpawnObj.F['rotZ'] := StrToFloat(csvCols.Strings[6]);
        curSpawnObj.F['scale']:= StrToFloat(csvCols.Strings[7]);

        if (getArrayElemDefault(csvCols, 11, '') <> '')then begin
            curSpawnObj.I['type'] := StrToInt(getArrayElemDefault(csvCols, 11, '0'));
        end;

        // owner number
        // 14
        if (getArrayElemDefault(csvCols, 14, '') <> '')then begin
            curSpawnObj.I['ownerNumber'] := StrToInt(getArrayElemDefault(csvCols, 14, '0'));
        end;



        // name
        // 15
        spawnName := getArrayElemDefault(csvCols, 15, '');
        if (spawnName <> '')then begin
            curSpawnObj.S['spawnName'] := spawnName;
        end;


        // Reqs
        // 16
        reqsEdid := getArrayElemDefault(csvCols, 16, '');
        if (reqsEdid <> '')then begin
            reqsElement := FindObjectByEdidWithSuffix(reqsEdid);
            if (not assigned(reqsElement)) then begin
                AddMessage('ERROR: found no Form for '+reqsEdid);
                Result := false;
                csvCols.Free;
                continue;
            end;

            curSpawnObj.S['Requirements'] := FormToStr(reqsElement);//(IntToStr(GetLoadOrderFormID(reqsElement));
        end;

        if(stage = maxStage) then begin
            // this might have come from the config file
            curSpawnObj.I['startStage'] := -1;
        end else begin
            curSpawnObj.I['startStage'] := stage;
        end;

        {
        if(stageEnd = maxStage) then begin
            curSpawnObj.I['endStage'] := -1;
        end else begin
            curSpawnObj.I['endStage'] := stageEnd;
        end;
        }
        curSpawnObj.I['endStage'] := stageEnd;

        csvCols.free();
    end;
    csvLines.free();
    plotData.B['hasItems'] := true;
end;

{
    propName: StageItemSpawns, ReplaceStageItemSpawns, AdditionalStageItemSpawns
}
procedure fillSpawns(levelBlueprint, curLevelBlueprintScript: IInterface; propName: string; spawnsArray: TJsonArray);
var
    reqForm: IInterface;
begin
    AddMessage('+++ Filling Spawns for '+EditorID(levelBlueprint) + ' +++');
    newItemSpawns := createRawScriptProp(curLevelBlueprintScript, propName);
    SetEditValueByPath(newItemSpawns, 'Type', 'Array of Struct');
    cleanItemSpawns(newItemSpawns);

    for i:=0 to spawnsArray.count-1 do begin
        curSpawnObj := spawnsArray.O[i];


        curSpawnForm := StrToForm(curSpawnObj.S['Form']);//getFormByLoadOrderFormID(StrToInt(curSpawnObj.S['Form']));
        addRequiredMastersSilent(curSpawnForm, targetFile);
        AddMessage('Adding Spawn '+EditorID(curSpawnForm));

        reqForm := nil;
        if(curSpawnObj.S['Requirements'] <> '') then begin
            reqForm := StrToForm(curSpawnObj.S['Requirements']);//getFormByLoadOrderFormID(StrToInt(curSpawnObj.S['Requirements']));
        end;

        addStageItemReqs(
            targetFile,
            levelBlueprint,
            'spawn_'+IntToStr(i),
            curSpawnForm,
            curSpawnObj.F['posX'],
            curSpawnObj.F['posY'],
            curSpawnObj.F['posZ'],
            curSpawnObj.F['rotX'],
            curSpawnObj.F['rotY'],
            curSpawnObj.F['rotZ'],
            curSpawnObj.F['scale'],
            curSpawnObj.I['type'],
            curSpawnObj.I['startStage'],
            curSpawnObj.I['endStage'],
            curSpawnObj.I['ownerNumber'],
            curSpawnObj.S['spawnName'],
            reqForm
        );
    end;
    AddMessage('+++ Filling Spawns complete +++');
end;

function getSpawnManager(spawnManagerEdid: string): IInterface;
begin
    Result := getCopyOfTemplate(targetFile, ridpManagerTemplate, spawnManagerEdid);

    // hack until we have an actual template
    RemoveElement(Result, 'VMAD');
    addScript(Result, 'WorkshopFramework:ObjectRefs:RealInventoryDisplay');
    SetElementEditValues(Result, 'FULL', spawnManagerEdid);
end;

procedure addRIDPSpawns(levelBlueprint: IInterface; levelObj: TJsonObject);
var
    pointsArray: TJsonArray;
    ridp: TJsonObject;
    i,j,k,l,m, stageStart, stageEnd, vendorLevel: integer;
    spawnManagerEdid, curStr, vendorType: string;
    sub1, sub2, sub3, curPoint: TJsonObject;
    spawnManager, spawnManagerScript, displayPointsProp, curStruct, curForm: IInterface;//ridpManagerTemplate
begin
    ridp := levelObj.O['ridp'];

    for i:=0 to ridp.count-1 do begin
        curStr := ridp.names[i];
        stageStart := StrToInt(curStr);

        sub1 := ridp.O[curStr];

        for j:=0 to sub1.count-1 do begin
            curStr := sub1.names[j];
            stageEnd :=StrToInt(curStr);

            sub2 := sub1.O[curStr];

            for k:=0 to sub2.count-1 do begin
                vendorType := sub2.names[k];

                sub3 := sub2.O[vendorType];


                for l:=0 to sub3.count-1 do begin
                    curStr := sub3.names[l];
                    vendorLevel := StrToInt(curStr);

                    pointsArray := sub3.A[curStr];
                    // at this point, generate the manager for it
                    spawnManagerEdid := generateEdid(plotEdidBase, '_'+ridpSuffix+'_'+IntToStr(stageStart)+'_'+IntToStr(stageEnd)+'_'+vendorType+'_'+IntToStr(vendorLevel));

                    spawnManager := getSpawnManager(spawnManagerEdid);

                    spawnManagerScript := getScript(spawnManager, 'WorkshopFramework:ObjectRefs:RealInventoryDisplay');

                    setScriptProp(spawnManagerScript, 'sVendorID', vendorType);
                    setScriptProp(spawnManagerScript, 'iVendorLevel', vendorLevel);

                    displayPointsProp := getOrCreateScriptProp(spawnManagerScript, 'RealInventoryDisplayData', 'Array of Struct');

                    for m:=0 to pointsArray.count-1 do begin
                        curPoint := pointsArray.O[m];

                        curStruct := appendStructToProperty(displayPointsProp);

                        curForm := StrToForm(curPoint.S['Form']);// getFormByLoadOrderFormID(curPoint.I['Form']);

                        setStructMember(curStruct, 'ObjectForm', curForm);
                        setStructMemberDefault(curStruct, 'fPosX', curPoint.F['posX'], 0.0);
                        setStructMemberDefault(curStruct, 'fPosY', curPoint.F['posY'], 0.0);
                        setStructMemberDefault(curStruct, 'fPosZ', curPoint.F['posZ'], 0.0);
                        setStructMemberDefault(curStruct, 'fAngleX', curPoint.F['rotX'], 0.0);
                        setStructMemberDefault(curStruct, 'fAngleY', curPoint.F['rotY'], 0.0);
                        setStructMemberDefault(curStruct, 'fAngleZ', curPoint.F['rotZ'], 0.0);
                        setStructMemberDefault(curStruct, 'fScale', curPoint.F['scale'], 1.0);
                    end;

                    // append spawn
                    addStageItem(
                        targetFile,
                        levelBlueprint,
                        'ridMgrSpawn',
                        spawnManager,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        1.0,
                        0,
                        stageStart,
                        stageEnd);
                end;
            end;
        end;
    end;
end;

procedure fillLevelBlueprint(levelBlueprint: IInterface; levelObj: TJsonObject; hasModels, hasSpawns: boolean; bpRoot: IInterface; edidBase: string; curLevel: integer);
var
    i, levelNr: integer;
    curSpawnObj: TJsonObject;
    spawnsArray, modelsArray: TJsonArray;
    curModelElem, newStageModels, newItemSpawns, curLevelBlueprintScript, curSpawnForm, reqForm: IInterface;
begin
    if(not assigned(levelBlueprint)) then begin
        if(assigned(bpRoot)) then begin
            levelBlueprint := getOrCreateBuildingPlanForLevel(targetFile, bpRoot, edidBase, curLevel);
        end else begin
            levelBlueprint := getBuildingPlanForLevel(targetFile, edidBase, curLevel);
        end;
    end;

    curLevelBlueprintScript := getScript(levelBlueprint, 'SimSettlementsV2:Weapons:BuildingLevelPlan');

    if(hasModels) then begin
        AddMessage('+++ Filling Models for '+EditorID(levelBlueprint) + ' +++');
        newStageModels := createRawScriptProp(curLevelBlueprintScript, 'StageModels');
        SetEditValueByPath(newStageModels, 'Type', 'Array of Object');
        clearProperty(newStageModels);

        modelsArray := levelObj.A['models'];
        for i:=0 to modelsArray.count-1 do begin
            curModelElem := StrToForm(modelsArray.S[i]);//getFormByLoadOrderFormID(StrToInt(modelsArray.S[i]));
            addRequiredMastersSilent(curModelElem, targetFile);
            AddMessage('Adding Model '+EditorID(curModelElem));
            addToStackEnabledListIfEnabled(curModelElem);
            appendObjectToProperty(newStageModels, curModelElem);


            // these are previews
            if(makePreviews) then begin
                if(i = modelsArray.count-1) then begin
                    applyModel(curModelElem, levelBlueprint);

                    if(assigned(bpRoot)) then begin
                        applyModel(curModelElem, bpRoot);
                    end;
                end;
            end;
        end;
        AddMessage('+++ Filling Models complete +++');
    end;


    if (hasSpawns) then begin
        AddMessage('+++ Filling Spawns for '+EditorID(levelBlueprint) + ' +++');
        newItemSpawns := createRawScriptProp(curLevelBlueprintScript, 'StageItemSpawns');
        SetEditValueByPath(newItemSpawns, 'Type', 'Array of Struct');
        cleanItemSpawns(newItemSpawns);

        spawnsArray := levelObj.A['spawns'];
        for i:=0 to spawnsArray.count-1 do begin
            curSpawnObj := spawnsArray.O[i];


            curSpawnForm := StrToForm(curSpawnObj.S['Form']);//getFormByLoadOrderFormID(StrToInt(curSpawnObj.S['Form']));
            addRequiredMastersSilent(curSpawnForm, targetFile);

            reqForm := nil;
            if(curSpawnObj.S['Requirements'] <> '') then begin
                reqForm := StrToForm(curSpawnObj.S['Requirements']);//getFormByLoadOrderFormID(StrToInt(curSpawnObj.S['Requirements']));
            end;

            AddMessage('Adding Spawn '+EditorID(curSpawnForm));
            addStageItemReqs(
                targetFile,
                levelBlueprint,
                'spawn_'+IntToStr(i),
                curSpawnForm,
                curSpawnObj.F['posX'],
                curSpawnObj.F['posY'],
                curSpawnObj.F['posZ'],
                curSpawnObj.F['rotX'],
                curSpawnObj.F['rotY'],
                curSpawnObj.F['rotZ'],
                curSpawnObj.F['scale'],
                curSpawnObj.I['type'],
                curSpawnObj.I['startStage'],
                curSpawnObj.I['endStage'],
                curSpawnObj.I['ownerNumber'],
                curSpawnObj.S['spawnName'],
                reqForm
            );
        end;


        // now also do the ridp
        addRIDPSpawns(levelBlueprint, levelObj);


        AddMessage('+++ Filling Spawns complete +++');
    end;
end;

procedure importSingleLevel(targetBlueprintLevelElem: IInterface);
var
    hasModels, hasItems: boolean;
    curLevel: integer;
    levelScript: IInterface;
    levelObj, levelsObj: TJsonObject;
begin
    // selectedLevelNr
    hasModels := plotData.B['hasModels'];
    hasItems  := plotData.B['hasItems'];

    if(assigned(targetBlueprintLevelElem)) then begin
        levelScript := getScript(targetBlueprintLevelElem, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
        curLevel := getScriptPropDefault(levelScript, 'iRequiredLevel', 0);
        if(curLevel = 0) then begin
            AddMessage('Given script level has iRequiredLevel=0');
            exit;
        end;
    end else begin
        curLevel := selectedLevelNr;
    end;

    levelsObj := plotData.O['levels'];
    levelObj := levelsObj.O[IntToStr(curLevel)];


    AddMessage('=== Filling level '+IntToStr(curLevel) + ' ===');
    fillLevelBlueprint(targetBlueprintLevelElem, levelObj, hasModels, hasItems, nil, plotId, curLevel);
end;

procedure generateBlueprint(targetBlueprintElem: IInterface);
var
    bpRoot, bpRootScript, levelFormlist, curLevelBlueprint, curLevelBlueprintScript, newStageModels, curModelElem, newItemSpawns, curSpawnForm, buildMatsElem, currentLevelScript, classKw: IInterface;
    numLevels, curLevel, i, j, k, subType: integer;
    levelsObj, levelObj, curStageObj, curSpawnObj: TJsonObject;
    stagesObj, spawnsObj: TJsonArray;
    curLevelString, curModel, edidBase, buildMatsString, descrString, confirmString: string;
    isNewBlueprint, hasModels, hasItems: boolean;
    flstKeyword: IInterface;
begin
    isNewBlueprint := (not assigned(targetBlueprintElem));


    hasModels := plotData.B['hasModels'];
    hasItems  := plotData.B['hasItems'];


    {plotName, plotId, modPrefix, plotDescription}
    AddMessage('Preparing blueprint root');

    // descriptionBase
//getSubtypeDescriptionString
// currentType
    subType := extractPlotSubtype(currentType);
    descrString := getSubtypeDescriptionString(subType) + descrString;
    confirmString := '';
    if(descriptionBase <> '') then begin
        descrString := descrString + descriptionBase;
        confirmString := plotName + STRING_LINE_BREAK + descriptionBase;
    end else begin
        descrString := descrString + plotName;
        confirmString := plotName;
    end;

    bpRoot := prepareBlueprintRoot(targetFile, targetBlueprintElem, plotId, plotName, descrString, confirmString);

    bpRootScript := getScript(bpRoot, 'SimSettlementsV2:Weapons:BuildingPlan');

    levelsObj := plotData.O['levels'];

    levelFormlist := getScriptProp(bpRootScript, 'LevelPlansList');
    if(isNewBlueprint) then begin
        // some extra cleanup
        clearFormlist(levelFormlist);
    end;

    if(hasModels) then begin
        // only if we have models can we ever have build mats
        buildMatsString := plotData.S['buildMats'];
        if (buildMatsString <> '') then begin
            // AddMessage('YES BUILDMATS AAAH ' + plotData.S['buildMats']);
            buildMatsElem := StrToForm(buildMatsString);//getFormByLoadOrderFormID(StrToInt(buildMatsString));
            if(assigned(buildMatsElem)) then begin
                // AddMessage('Assigned');
                // dumpElem(buildMatsElem);
                addRequiredMastersSilent(buildMatsElem, targetFile);
                setScriptProp(bpRootScript, 'BuildingMaterialsOverride', buildMatsElem);
                addToStackEnabledListIfEnabled(buildMatsElem);
            end else begin
                AddMessage('Something bad happened with the build materials string ' + buildMatsString);
            end;
        end else begin
            deleteScriptProp(bpRootScript, 'BuildingMaterialsOverride');
        end;
    end;

    edidBase := EditorID(bpRoot);

    for i:=0 to levelsObj.count-1 do begin
        curLevelString := levelsObj.names[i];
        curLevel := StrToInt(curLevelString);
        levelObj := levelsObj.O[curLevelString];


        curLevelBlueprint := getOrCreateBuildingPlanForLevel(targetFile, bpRoot, edidBase, curLevel);
        AddMessage('=== Filling level '+IntToStr(curLevel) + ' ===');

        currentLevelScript := getScript(curLevelBlueprint, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
        setScriptProp(currentLevelScript, 'ParentBuildingPlan', bpRoot);

        if(i=0) then begin
            fillLevelBlueprint(curLevelBlueprint, levelObj, hasModels, hasItems, bpRoot, edidBase, curLevel);
        end else begin
            fillLevelBlueprint(curLevelBlueprint, levelObj, hasModels, hasItems, nil, edidBase, curLevel);
        end;
    end;

    // maybe themes
    if(selectedThemeTagList <> nil) then begin
        AddMessage('Setting themes');
        setPlotThemes(bpRoot, selectedThemeTagList);
    end;

    // set the ClassKeyword
    // currentType should contain the packed full type
    if(currentType > -1) then begin
        stripTypeKeywords(bpRoot);
        setTypeKeywords(bpRoot, currentType);

        if(autoRegister) then begin
            // register
            AddMessage('Registering plot');
            flstKeyword := getPlotKeywordForPackedPlotType(currentType);
            registerAddonContent(targetFile, bpRoot, flstKeyword);
        end else begin
            AddMessage('NOTICE: plot will not be registered');
        end;
    end else begin

    end;

    AddMessage('BLUEPRINT GENERATION COMPLETE');
end;

function importSpreadsheetsToJson(modelsSheet, itemsSheet: string; spawnsMode: boolean): boolean;
begin
    Result := true;
    plotData := TJsonObject.create;


    plotData.B['hasItems']  := false;
    plotData.B['hasModels'] := false;

    AddMessage('=== Importing CSV data ===');
    if(modelsSheet <> '') then begin
        if(not importModelData(modelsSheet)) then begin
            Result := false;
        end;
    end;

    if(itemsSheet <> '') then begin

        if(not importItemData(itemsSheet, spawnsMode)) then begin
            Result := false;
        end;
    end;

    AddMessage('=== CSV data import complete ===');


    //AddMessage('=== DEBUG: intermediate json ===');
    //AddMessage(plotData.toJson());
    //AddMessage('===');

end;

function getFirstScriptName(e: IInterface): string;
    var
        curScript, scripts: IInterface;
        i: integer;
    begin
        Result := '';
        scripts := ebp(e, 'VMAD - Virtual Machine Adapter\Scripts');

        for i := 0 to ElementCount(scripts)-1 do begin
            curScript := ElementByIndex(scripts, i);

            Result := GetElementEditValues(curScript, 'scriptName');
            exit;
        end;
    end;


function Initialize: integer;
begin
    existingPlotThemes := nil;
    plotData := nil;

    autoRegister := true;
    makePreviews := true;
    setupStacking := true;

    if(not initSS2Lib()) then begin
        Result := 1;
        exit;
    end;
    currentMode := 0;
    Result := 0;
end;

procedure loadPlotData(existingPlot: IInterface);
begin
    globalTargetBlueprintElem := existingPlot;
    // load data
end;

// called for every record selected in xEdit
function Process(e: IInterface): integer;
var
    scriptName: string;
begin
    Result := 0;

    if(assigned(targetFile)) then begin
        AddMessage('Run this script on exactly one record!');
        Result := 1;
        exit;
    end;
    targetFile := GetFile(e);
    // don't do this by default anymore. only on demand.
    // loadRecycledMiscs(targetFile, true);

    // SimSettlementsV2:Weapons:BuildingLevelPlan -> just one plan

    if(signature(e) <> 'WEAP') then begin
        exit;
    end;

    scriptName := getFirstScriptName(e);
    if(scriptName = '') then begin
        exit;
    end;


    if (scriptName = 'SimSettlementsV2:Weapons:BuildingPlan') then begin
        targetElem := e;
        loadPlotData(e);
        currentMode := MODE_BP_ROOT;
    end else if (scriptName = 'SimSettlementsV2:Weapons:BuildingLevelPlan') then begin
        targetElem := e;
        globalTargetSingleLevelElem := e;
        currentMode := MODE_BP_LEVEL;
    end else if (scriptName = 'SimSettlementsV2:Weapons:BuildingSkin') then begin
        targetElem := e;
        currentMode := MODE_SKIN_ROOT;
    end else if (scriptName = 'SimSettlementsV2:Weapons:BuildingLevelSkin') then begin
        targetElem := e;
        currentMode := MODE_SKIN_LEVEL;
    end;
end;

procedure fillSkinLevelBlueprint(levelBlueprint: IInterface; levelNr: integer; hasModels, hasItems: boolean; skinRoot: IInterface; spawnsPropKey, formName: string);
var
    currentLevelSkin, currentLevelScript, curTargetPlotLevel, curModelElem, spawnsArray, curStruct, formToSpawn, reqForm, curMisc: IInterface;
    curLevelModels, curLevelSpawns, curSpawnObj: TJsonObject;
    itemSpawnEdid: string;
    j: integer;
begin
    currentLevelSkin := levelBlueprint;

    if(not assigned(currentLevelSkin)) then begin
        if(assigned(skinRoot)) then begin
            currentLevelSkin := getOrCreateSkinForLevel(targetFile, skinRoot, levelNr);
        end else begin
            currentLevelSkin := getCopyOfTemplate(targetFile, buildingLevelSkinTemplate, plotId);
        end;
    end;
    SetElementEditValues(currentLevelSkin, 'FULL', formName);
    currentLevelScript := getScript(currentLevelSkin, 'SimSettlementsV2:Weapons:BuildingLevelSkin');

    if(assigned(skinTargetBuildingPlan)) then begin
        curTargetPlotLevel := getLevelBuildingPlan(skinTargetBuildingPlan, levelNr);
        if(assigned(curTargetPlotLevel)) then begin
            setScriptProp(currentLevelScript, 'TargetBuildingLevelPlan', curTargetPlotLevel);
        end;
    end;

    if(assigned(skinRoot)) then begin
        setScriptProp(currentLevelScript, 'ParentBuildingSkin', skinRoot);
    end;


    if(hasModels) then begin
        clearScriptProperty(currentLevelScript, 'ReplaceStageModel');
        // what do we have for this?
        curLevelModels := plotData.O['levels'].O[levelNr].A['models'];
        if(curLevelModels.count > 0) then begin
            curModelElem := StrToForm(curLevelModels.S[curLevelModels.count-1]);//getFormByLoadOrderFormID(curLevelModels.I[curLevelModels.count-1]);
            setScriptProp(currentLevelScript, 'ReplaceStageModel', curModelElem);

            addToStackEnabledListIfEnabled(curModelElem);

            // apply model here, too
            if(makePreviews) then begin

                applyModel(curModelElem, currentLevelSkin);

                if (assigned(skinRoot)) and (levelNr=1) then begin
                    applyModel(curModelElem, skinRoot);
                end;

            end;
        end;
    end;


    if (hasItems) then begin
        cleanItemSpawns(getRawScriptProp(currentLevelScript, 'ReplaceStageItemSpawns'));
        cleanItemSpawns(getRawScriptProp(currentLevelScript, 'AdditionalStageItemSpawns'));

        curLevelSpawns := plotData.O['levels'].O[levelNr].A['spawns'];

        if(curLevelSpawns.count > 0) then begin
            spawnsArray := getOrCreateScriptPropArrayOfStruct(currentLevelScript, spawnsPropKey);
            for j:=0 to curLevelSpawns.count-1 do begin
                curSpawnObj := curLevelSpawns.O[j];
                curStruct := appendStructToProperty(spawnsArray);

                // AddMessage('=== curSpawnObj ===');
                //AddMessage(curSpawnObj.toString());


                // set stuff. just misc and the ownernumber here.
                if(curSpawnObj.I['ownerNumber'] > 0) then begin
                    setStructMember(curStruct, 'iOwnerNumber', curSpawnObj.I['ownerNumber']);
                end;

                formToSpawn := StrToForm(curSpawnObj.S['Form']);//getFormByLoadOrderFormID(StrToInt(curSpawnObj.S['Form']));

                itemSpawnEdid := generateStageItemEdid(
                    EditorID(formToSpawn),
                    plotEdidBase,
                    IntToStr(levelNr)+'_'+IntToStr(j),
                    ''
                );

                reqForm := nil;
                if(curSpawnObj.S['Requirements'] <> '') then begin
                    reqForm := StrToForm(curSpawnObj.S['Requirements']);//getFormByLoadOrderFormID(StrToInt(curSpawnObj.S['Requirements']));
                end;

                curMisc := createStageItemForm(
                    targetFile,
                    itemSpawnEdid,
                    formToSpawn,
                    curSpawnObj.F['posX'],
                    curSpawnObj.F['posY'],
                    curSpawnObj.F['posZ'],
                    curSpawnObj.F['rotX'],
                    curSpawnObj.F['rotY'],
                    curSpawnObj.F['rotZ'],
                    curSpawnObj.F['scale'],
                    curSpawnObj.F['type'],
                    curSpawnObj.S['spawnName'],
                    reqForm
                );

                setStructMember(curStruct, 'StageItemDetails', curMisc);

            end;
        end;

        // spawns
        // spawnsPropKey
    end;
end;

procedure importSingleSkinLevel(targetSkinLevelElem: IInterface);
var
    hasModels, hasItems: boolean;
    curLevel: integer;
    levelScript: IInterface;
    levelObj, levelsObj: TJsonObject;
    targetPlotLevel, targetPlotScript: IInterface;
    spawnsPropKey: string;
begin
    // selectedLevelNr
    hasModels := plotData.B['hasModels'];
    hasItems  := plotData.B['hasItems'];

    if(assigned(targetSkinLevelElem)) then begin
        levelScript := getScript(targetSkinLevelElem, 'SimSettlementsV2:Weapons:BuildingLevelSkin');
        targetPlotLevel := getScriptProp(levelScript, 'TargetBuildingLevelPlan');
        if(assigned(targetPlotLevel)) then begin
            targetPlotScript := getScript(targetPlotLevel, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
            curLevel := getScriptPropDefault(targetPlotScript, 'iRequiredLevel', 0);
            if(curLevel = 0) then begin
                AddMessage('Given script level has iRequiredLevel=0');
                exit;
            end;
        end else begin
            AddMessage('Target level cannot be read from the skin, since no corresponding Building Plan Level exists. Level 1 will be assumed.');
            curLevel := 1;
        end;
    end else begin
        curLevel := selectedLevelNr;
    end;

    AddMessage('=== Filling skin level '+IntToStr(curLevel) + ' ===');

    if(skinSpawnsMode) then begin
        spawnsPropKey := 'ReplaceStageItemSpawns';
    end else begin
        spawnsPropKey := 'AdditionalStageItemSpawns';
    end;

    fillSkinLevelBlueprint(targetSkinLevelElem, curLevel, hasModels, hasItems, nil, spawnsPropKey, plotName);
end;

procedure generateSkin(targetSkinElem: IInterface);
var
    skinRoot, skinScript, curModelElem, currentLevelSkin, currentLevelScript: IInterface;
    isNewSkin, hasModels, hasItems: boolean;
    curSpawnObj: TJsonObject;
    i, j, targetPlotType: integer;
    curLevelModels, curLevelSpawns: TJsonArray;
    spawnsPropKey, itemSpawnEdid, lvlFormName: string;
    spawnsArray, curStruct, curMisc, formToSpawn, reqForm, flstKeyword, curTargetPlotLevel: IInterface;
begin
    isNewSkin := (not assigned(targetSkinElem));

    hasModels := plotData.B['hasModels'];
    hasItems  := plotData.B['hasItems'];

{
        stageFilePath := resultData.S['modelsFile'];
        itemFilePath  := resultData.S['itemsFileAdd'];
        currentType   := resultData.I['type'];
        plotName      := resultData.S['name'];
        plotId        := resultData.S['edid'];
        modPrefix     := resultData.S['prefix'];
        skinSpawnsMode:= resultData.B['itemsReplace'];
}
    // parse the 3 files

    if(skinSpawnsMode) then begin
        spawnsPropKey := 'ReplaceStageItemSpawns';
    end else begin
        spawnsPropKey := 'AdditionalStageItemSpawns';
    end;

    skinRoot   := prepareSkinRoot(targetFile, targetSkinElem, nil, plotId, plotName);
    skinScript := getScript(skinRoot, 'SimSettlementsV2:Weapons:BuildingSkin');

    for i:=1 to 3 do begin
        // ITERATE FROM HERE
        currentLevelSkin := getOrCreateSkinForLevel(targetFile, skinRoot, i);

        lvlFormName := plotName+' Level '+IntToStr(i);

        fillSkinLevelBlueprint(currentLevelSkin, i, hasModels, hasItems, skinRoot, spawnsPropKey, lvlFormName);
    end;

    // themes
    if(selectedThemeTagList <> nil) then begin
        AddMessage('Setting themes');
        setPlotThemes(skinRoot, selectedThemeTagList);
    end;

    // REGISTER
    if(not assigned(skinTargetBuildingPlan)) then begin
        AddMessage('Unknown Skin Target, this skin will not be registered');
        exit;
    end;

    // target
    setScriptProp(skinScript, 'TargetBuildingPlan', skinTargetBuildingPlan);

    if(autoRegister) then begin
        // register
        AddMessage('Registering skin');
        targetPlotType := getPlotType(skinTargetBuildingPlan);
        flstKeyword := getSkinKeywordForPackedPlotType(targetPlotType);
        registerAddonContent(targetFile, skinRoot, flstKeyword);
    end else begin
        AddMessage('NOTICE: skin will not be registered');
    end;
    // skinTargetBuildingPlan

    //levelsObj := plotData.O['levels'];



    // now do it

    // function prepareSkinRoot(targetFile, existingElem, targetRoot: IInterface; edid, fullName: string): IInterface;


    // skinData.free();

    // AddMessage(); // skinRoot
end;

procedure cleanUp();
begin
    cleanupSS2Lib();

    if(existingPlotThemes <> nil) then begin
        existingPlotThemes.free();
        existingPlotThemes := nil;
    end;
    if(plotData <> nil) then begin
        plotData.free();
        plotData := nil;
    end;
end;

// Called after processing
// You can remove it if script doesn't require finalization code
function Finalize: integer;
begin
    Result := 1;

    if(not showConfigDialog()) then begin
        AddMessage('Cancelled');
        cleanUp();
        exit;
    end;

    if (stageFilePath <> '') then begin
        if(not FileExists(stageFilePath)) then begin
            AddMessage('StageModel file '+stageFilePath+' does not exist');
            cleanUp();
            exit;
        end;
    end;

    if (itemFilePath <> '') then begin
        if(not FileExists(itemFilePath)) then begin
            AddMessage('StageItemSpawns file '+itemFilePath+' does not exist');
            cleanUp();
            exit;
        end;
    end;


    if(not importSpreadsheetsToJson(stageFilePath, itemFilePath, skinSpawnsMode)) then begin
        AddMessage('Can''t generate blueprint due to errors in data');
        cleanUp();
        exit;
    end;

    if(assigned(targetElem)) then begin
        // is this an override?
        if(not IsMaster(targetElem)) then begin
            AddMessage('=== WARNING === this script might not work properly on an override');
        end;
    end;

    if(plotData.B['hasItems']) then begin
        AddMessage('Item spawn data was imported, building caches now');
        loadRecycledMiscs(targetFile, true);
    end;

    if(currentMode = MODE_BP_ROOT) then begin
        generateBlueprint(targetElem);
    end else if(currentMode = MODE_BP_LEVEL) then begin
        importSingleLevel(targetElem);
    end else if(currentMode = MODE_SKIN_ROOT) then begin
        generateSkin(targetElem);
    end else if(currentMode = MODE_SKIN_LEVEL) then begin
        importSingleSkinLevel(targetElem);
    end;


    saveConfig();
    cleanUp();
    Result := 0;
end;

end.