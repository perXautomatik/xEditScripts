unit SS2Lib;

    uses 'SS2\praUtilSS2';

    const
        // maximal length of editorIDs. Anything longer will be partially hashed
        maxEdidLength = 99;
		ss2Filename = 'SS2.esm';
		wsfrFilename = 'WorkshopFramework.esm';
		ss2Suffix = '_SS2';
		buildingPlanDescriptionPrefix = 'BPDescription_';
		buildingPlanPrefix = 'BuildingPlan_';
		masterBuildingPlanPrefix = 'MasterBuildingPlan_';
		buildingLevelDescriptionPrefix = 'LPDescription_';
		levelPlanPrefix = 'LevelPlan_';
		levelPlanListPrefix = 'BPLevels_';
		stageItemPrefix = 'StageItem_';
		buildingPlanConfirmPrefix = 'BPConfirm_';
		levelPlanConfirmPrefix = 'LPConfirm_';
        buildingSkinPrefix = 'BPSkin_';
        buildingSkinDescriptionPrefix = 'BPSkinDescr_';
        levelBuildingSkinPrefix = 'LPSkin_';
        leaderCardPrefix = 'LeaderCard_';

        furnItemPrefix = 'PurchaseableFurniture_';
        flagPrefix = 'Flag_';
        deskPrefix = 'LeaderDesk_';

		cityPlanPrefix = 'CityPlan_';
        designNamePrefix = 'CityPlanDesigner_';
        usageReqsPrefix = 'UsageRequirements_';
        unlockablePrefix = 'Unlockable_';

        foundationPrefix = 'Foundation_';

		addonQuestSuffix = 'AddonQuest';
		addonDataSuffix = 'AddonData';
		addonVersionSuffix = 'AddonVersion';
		ridpSuffix = 'RIDPManager';

		addonFlstPrefix = 'AddonBPs_';
		addonItemsFlstPrefix = 'AddonItems_';
		stackEnableFlstBase = 'EnableStackedParenting';
		stackEnableCobjBase = 'co_StackEnable';
		vipReqPrefix = 'ActorValueReq_';

        // files in here will not appear in the file select dropdown
        readOnlyFiles = 'Fallout4.esm'#13'Fallout4.exe'#13'DLCRobot.esm'#13'DLCworkshop01.esm'#13'DLCCoast.esm'#13'DLCworkshop02.esm'#13'DLCworkshop03.esm'#13'DLCNukaWorld.esm'#13'SimSettlements.esm'#13'WorkshopFramework.esm';

        recycleableMiscPrefix = 'RECYCLED_MISC_';

        tagOpenChars = '[|({<';
        tagCloseChars = ']|)}>';

        enableOutpostSubtype = false;

		miscItemCacheFileName = ProgramPath + 'Edit Scripts\SS2\PlotMiscItemCache.json';

    // variables, templates and such
    var
        ss2masterFile: IInterface;

        buildingPlanTemplate: IInterface;
        buldingPlanLevelTemplate: IInterface;// SS2_Template_BuildingPlan_Level

        descriptionTemplate: IInterface;
        stageItemTemplate: IInterface; //kgSIM_TextReplace_NA
        usageReqsTemplate: IInterface; // SS2_Template_UsageRequirements
        unlockableTemplate: IInterface; //SS2_Template_Unlockable

        confirmMessageTemplate: IInterface; //SS2_Template_BuildingPlanConfirmation
        addonQuestTemplate: IInterface;//SS2_AddonTemplate [QUST:0900D33A]
        addonDataTemplate: IInterface;//SS2_Template_AddonConfig
        versionGlobalTemplate: IInterface;//SS2_ModVersion [GLOB:0900D163]

        buildingLevelSkinTemplate: IInterface; // SS2_Template_BuildingLevelSkin "Weapon Based Building Level Skin Template" [WEAP:090338BC]
        buildingSkinTemplate: IInterface; // SS2_Template_BuildingSkin "Weapon Based Building Plan Skin Template" [WEAP:090338BA]

        flagTemplate: IInterface; // SS2_ThemeDefinition_Flags_Template "Flag Name Here" [ARMO:030201A1]
        flagTemplate_Wall,
        flagTemplate_Down,
        flagTemplate_Waving,
        flagTemplate_Banner,
        flagTemplate_BannerTorn,
        flagTemplate_BannerTornWaving,
        flagTemplate_Circle01,
        flagTemplate_Circle02,
        flagTemplate_Matswap,
        SS2_ThemeRuleset_Flags: IInterface;


        terraformerTemplate_Misc_1x1, // the misc item, SS2_PlotFoundation_1x1_Terraformer_Dirt
        terraformerTemplate_Misc_2x2, // the misc item, SS2_PlotFoundation_2x2_Terraformer_Dirt
        terraformerTemplate_Misc_3x3, // the misc item, SS2_PlotFoundation_3x3_Terraformer_Dirt
        terraformerTemplate_Cobj, // the cobj, SS2_COBJ_Foundation_TerraformBlock2x2_Dirt

        terraformerTemplate_Block_1x1,// SS2_Foundation_TerraformBlock1x1_Dirt
        terraformerTemplate_Corner_1x1,//SS2_Foundation_TerraformBlock1x1_Dirt_Corner
        terraformerTemplate_Edge_1x1,//SS2_Foundation_TerraformBlock1x1_Dirt_Edge

        terraformerTemplate_Block_2x2,// SS2_Foundation_TerraformBlock2x2_Dirt
        terraformerTemplate_Corner_2x2,//SS2_Foundation_TerraformBlock2x2_Dirt_Corner
        terraformerTemplate_Edge_2x2,// SS2_Foundation_TerraformBlock2x2_Dirt_Edge
        terraformerTemplate_LPiece_2x2,//SS2_Foundation_TerraformBlock2x2_Dirt_LPiece

        terraformerTemplate_Block_3x3,//SS2_Foundation_TerraformBlock3x3_Dirt
        terraformerTemplate_Corner_3x3,//SS2_Foundation_TerraformBlock3x3_Dirt_Corner
        terraformerTemplate_Edge_3x3: IInterface;//SS2_Foundation_TerraformBlock3x3_Dirt_Edge

        foundationTemplate, // the misc, SS2_PlotFoundation_1x1_Concrete
        foundationTemplate_Cobj: IInterface; // template for making non-terraformer foundation COBJs

        // desk stuff
        SS2_Tag_ManagementDesk,
        SS2_Workbench_CityPlannersDesk,
        WSFW_DoNotAutoassign,
        deskBaseCobj, //SS2_co_CityPlannerDesk
        packedDeskBaseCobj: IInterface; //kgSIM_co_CityPlannerDesk_Packed

        cityPlanRootTemplate: IInterface;
        cityPlanLayerTemplate: IInterface;
        cityPlanDescriptionTemplate: IInterface;

        keywordTemplate: IInterface;

        keywordRecipeScrap: IInterface;

        ridpManagerTemplate: IInterface; //SS2_RIDPManager_FurnitureStore_Template

        SS2_PurchaseableFurniture_Template: IInterface;

        furnitureCobjTemplate: IInterface;//SS2_co_FurnitureStoreItem_76CrateChair1 [COBJ:03014050]

        stackingCobjTemplate: IInterface;//SS2_co_StackEnable_SS

        // leader cards
        SS2_FLID_LeaderCards,
        SS2_Template_LeaderCardDescription,
        leaderCardTemplate: IInterface;

        // SS2_Tag_CityPlan

        globalNewFormPrefix, globalAddonName: string;

        // plot type KWs
        SS2_FLID_BuildingPlans_Agricultural_1x1,
        SS2_FLID_BuildingPlans_Agricultural_2x2,
        SS2_FLID_BuildingPlans_Agricultural_3x3,
        SS2_FLID_BuildingPlans_Agricultural_Int,
        SS2_FLID_BuildingPlans_Commercial_1x1,
        SS2_FLID_BuildingPlans_Commercial_2x2,
        SS2_FLID_BuildingPlans_Commercial_3x3,
        SS2_FLID_BuildingPlans_Commercial_Int,
        SS2_FLID_BuildingPlans_Industrial_1x1,
        SS2_FLID_BuildingPlans_Industrial_2x2,
        SS2_FLID_BuildingPlans_Industrial_3x3,
        SS2_FLID_BuildingPlans_Industrial_Int,
        SS2_FLID_BuildingPlans_Martial_1x1,
        SS2_FLID_BuildingPlans_Martial_2x2,
        SS2_FLID_BuildingPlans_Martial_3x3,
        SS2_FLID_BuildingPlans_Martial_Int,
        SS2_FLID_BuildingPlans_Municipal_1x1,
        SS2_FLID_BuildingPlans_Municipal_2x2,
        SS2_FLID_BuildingPlans_Municipal_3x3,
        SS2_FLID_BuildingPlans_Municipal_Int,
        SS2_FLID_BuildingPlans_Recreational_1x1,
        SS2_FLID_BuildingPlans_Recreational_2x2,
        SS2_FLID_BuildingPlans_Recreational_3x3,
        SS2_FLID_BuildingPlans_Recreational_Int,
        SS2_FLID_BuildingPlans_Residential_1x1,
        SS2_FLID_BuildingPlans_Residential_2x2,
        SS2_FLID_BuildingPlans_Residential_3x3,
        SS2_FLID_BuildingPlans_Residential_Int: IInterface;


        // skin type KWs
        SS2_FLID_Skins_Agricultural_1x1,
        SS2_FLID_Skins_Agricultural_2x2,
        SS2_FLID_Skins_Agricultural_3x3,
        SS2_FLID_Skins_Agricultural_Int,
        SS2_FLID_Skins_Commercial_1x1,
        SS2_FLID_Skins_Commercial_2x2,
        SS2_FLID_Skins_Commercial_3x3,
        SS2_FLID_Skins_Commercial_Int,
        SS2_FLID_Skins_Industrial_1x1,
        SS2_FLID_Skins_Industrial_2x2,
        SS2_FLID_Skins_Industrial_3x3,
        SS2_FLID_Skins_Industrial_Int,
        SS2_FLID_Skins_Martial_1x1,
        SS2_FLID_Skins_Martial_2x2,
        SS2_FLID_Skins_Martial_3x3,
        SS2_FLID_Skins_Martial_Int,
        SS2_FLID_Skins_Municipal_1x1,
        SS2_FLID_Skins_Municipal_2x2,
        SS2_FLID_Skins_Municipal_3x3,
        SS2_FLID_Skins_Municipal_Int,
        SS2_FLID_Skins_Recreational_1x1,
        SS2_FLID_Skins_Recreational_2x2,
        SS2_FLID_Skins_Recreational_3x3,
        SS2_FLID_Skins_Recreational_Int,
        SS2_FLID_Skins_Residential_1x1,
        SS2_FLID_Skins_Residential_2x2,
        SS2_FLID_Skins_Residential_3x3,
        SS2_FLID_Skins_Residential_Int: IInterface;

        // city plan type KW
        SS2_FLID_CityPlans: IInterface;

        // furniture type KW
        SS2_FLID_FurnitureStoreItems: IInterface;
        // flag type KW
        SS2_FLID_ThemeDefinitions_Flags: IInterface;

        SS2_FLID_Unlockables: IInterface;

        // foundation type KWs
        SS2_FLID_1x1_Foundations,
        SS2_FLID_2x2_Foundations,
        SS2_FLID_3x3_Foundations: IInterface;

        // subtypes
        // agricultural
        SS2_PlotTypeSubClass_Agricultural_Advanced,
        SS2_PlotTypeSubClass_Agricultural_Default_Basic,
        SS2_PlotTypeSubClass_Agricultural_HighTech,
        // commercial
        SS2_PlotTypeSubClass_Commercial_ArmorStore,
        SS2_PlotTypeSubClass_Commercial_Bar,
        SS2_PlotTypeSubClass_Commercial_Beauty,
        SS2_PlotTypeSubClass_Commercial_Bookstore,
        SS2_PlotTypeSubClass_Commercial_Clinic,
        SS2_PlotTypeSubClass_Commercial_ClothingStore,
        SS2_PlotTypeSubClass_Commercial_Default_Other,
        SS2_PlotTypeSubClass_Commercial_FurnitureStore,
        SS2_PlotTypeSubClass_Commercial_GeneralStore,
        SS2_PlotTypeSubClass_Commercial_PowerArmorStore,
        SS2_PlotTypeSubClass_Commercial_WeaponsStore,
        SS2_PlotTypeSubClass_Commercial_PetStore,
        // industrial
        SS2_PlotTypeSubClass_Industrial_BuildingMaterials,
        SS2_PlotTypeSubClass_Industrial_Default_General,
        SS2_PlotTypeSubClass_Industrial_MachineParts,
        SS2_PlotTypeSubClass_Industrial_OrganicMaterials,
        SS2_PlotTypeSubClass_Industrial_RareMaterials,
        SS2_PlotTypeSubClass_Industrial_Conversion,
        SS2_PlotTypeSubClass_Industrial_Production,

        // martial
        SS2_PlotTypeSubClass_Martial_Advanced,
        SS2_PlotTypeSubClass_Martial_Default_Basic,
        SS2_PlotTypeSubClass_Martial_HighTech,

        SS2_PlotTypeSubClass_Martial_OutpostType_Armory,
        SS2_PlotTypeSubClass_Martial_OutpostType_BattlefieldScavengers,
        // SS2_PlotTypeSubClass_Martial_OutpostType_FieldHospital,
        SS2_PlotTypeSubClass_Martial_OutpostType_FieldSurgeon,
        SS2_PlotTypeSubClass_Martial_OutpostType_Prison,
        SS2_PlotTypeSubClass_Martial_OutpostType_RecruitmentCenter,
        SS2_PlotTypeSubClass_Martial_OutpostType_WatchTower,
        // municipial
        SS2_PlotTypeSubClass_Municipal_CaravanServices,
        SS2_PlotTypeSubClass_Municipal_CommunicationStation,
        SS2_PlotTypeSubClass_Municipal_Default_Other,
        SS2_PlotTypeSubClass_Municipal_PowerPlant_Advanced,
        SS2_PlotTypeSubClass_Municipal_PowerPlant_Basic,
        SS2_PlotTypeSubClass_Municipal_PowerPlant_HighTech,
        SS2_PlotTypeSubClass_Municipal_PowerTransfer,
        SS2_PlotTypeSubClass_Municipal_TaxServices,
        SS2_PlotTypeSubClass_Municipal_WaterPlant_Advanced,
        SS2_PlotTypeSubClass_Municipal_WaterPlant_Basic,
        SS2_PlotTypeSubClass_Municipal_WaterPlant_HighTech,
        // recreational
        SS2_PlotTypeSubClass_Recreational_AgilityTraining,
        SS2_PlotTypeSubClass_Recreational_Cemetery,
        SS2_PlotTypeSubClass_Recreational_CharismaTraining,
        SS2_PlotTypeSubClass_Recreational_Default_Relaxation,
        SS2_PlotTypeSubClass_Recreational_EnduranceTraining,
        SS2_PlotTypeSubClass_Recreational_IntelligenceTraining,
        SS2_PlotTypeSubClass_Recreational_LuckTraining,
        SS2_PlotTypeSubClass_Recreational_PerceptionTraining,
        SS2_PlotTypeSubClass_Recreational_StrengthTraining,

        SS2_PlotTypeSubClass_Recreational_OutpostType_MessHall,
        SS2_PlotTypeSubClass_Recreational_OutpostType_TrainingYard,
        // residential
        SS2_PlotTypeSubClass_Residential_Default_SinglePerson,
        SS2_PlotTypeSubClass_Residential_MultiPerson: IInterface;

        // sizes
        SIZE_1x1,
        SIZE_2x2,
        SIZE_3x3,
        SIZE_INT : integer;

        // integer types
        PLOT_TYPE_AGR: integer;
        PLOT_TYPE_COM: integer;
        PLOT_TYPE_IND: integer;
        PLOT_TYPE_MAR: integer;
        PLOT_TYPE_MUN: integer;
        PLOT_TYPE_REC: integer;
        PLOT_TYPE_RES: integer;

        // agricultural
        PLOT_SC_AGR_Advanced,
        PLOT_SC_AGR_Default_Basic,
        PLOT_SC_AGR_HighTech,
        // commercial
        PLOT_SC_COM_ArmorStore,
        PLOT_SC_COM_Bar,
        PLOT_SC_COM_Beauty,
        PLOT_SC_COM_Bookstore,
        PLOT_SC_COM_Clinic,
        PLOT_SC_COM_ClothingStore,
        PLOT_SC_COM_Default_Other,
        PLOT_SC_COM_FurnitureStore,
        PLOT_SC_COM_GeneralStore,
        PLOT_SC_COM_PowerArmorStore,
        PLOT_SC_COM_WeaponsStore,
        PLOT_SC_COM_PetStore,
        // industrial
        PLOT_SC_IND_BuildingMaterials,
        PLOT_SC_IND_Default_General,
        PLOT_SC_IND_MachineParts,
        PLOT_SC_IND_OrganicMaterials,
        PLOT_SC_IND_RareMaterials,
        PLOT_SC_IND_Conversion,
        PLOT_SC_IND_Production,
        // martial
        PLOT_SC_MAR_Advanced,
        PLOT_SC_MAR_Default_Basic,
        PLOT_SC_MAR_HighTech,
        PLOT_SC_MAR_OutpostType_Armory,
        PLOT_SC_MAR_OutpostType_BattlefieldScavengers,
        PLOT_SC_MAR_OutpostType_FieldSurgeon,
        PLOT_SC_MAR_OutpostType_Prison,
        PLOT_SC_MAR_OutpostType_RecruitmentCenter,
        PLOT_SC_MAR_OutpostType_WatchTower,
        // municipial
        PLOT_SC_MUN_CaravanServices,
        PLOT_SC_MUN_CommunicationsStation,
        PLOT_SC_MUN_Default_Other,
        PLOT_SC_MUN_PowerPlant_Advanced,
        PLOT_SC_MUN_PowerPlant_Basic,
        PLOT_SC_MUN_PowerPlant_HighTech,
        PLOT_SC_MUN_PowerTransfer,
        PLOT_SC_MUN_TaxServices,
        PLOT_SC_MUN_WaterPlant_Advanced,
        PLOT_SC_MUN_WaterPlant_Basic,
        PLOT_SC_MUN_WaterPlant_HighTech,
        // recreational
        PLOT_SC_REC_AgilityTraining,
        PLOT_SC_REC_Cemetery,
        PLOT_SC_REC_CharismaTraining,
        PLOT_SC_REC_Default_Relaxation,
        PLOT_SC_REC_EnduranceTraining,
        PLOT_SC_REC_IntelligenceTraining,
        PLOT_SC_REC_LuckTraining,
        PLOT_SC_REC_OutpostType_MessHall,
        PLOT_SC_REC_OutpostType_TrainingYard,
        PLOT_SC_REC_PerceptionTraining,
        PLOT_SC_REC_StrengthTraining,
        // residential
        PLOT_SC_RES_Default_SinglePerson,
        PLOT_SC_RES_MultiPerson: integer;


        // lists
        plotTypeNames, plotSizeNames, plotSubtypeNames: TStringList;
        hardcodedEdidMappingKeys, hardcodedEdidMappingValues: TStringList;

        plotSubtypeMapping: TJsonObject;

        // gui stuff
        plotDialogOkBtn: TButton;
        plotSubtypeCombobox, plotMainTypeCombobox, plotSizeCombobox: TComboBox;

        isConvertDialogActive: boolean; // true: convert, false: import
        StageModelFileRequired: boolean;
        PlotEdidInputRequired: boolean;
        stageModelInput, itemSpawnInput, plotEdidInput: TEdit;

        // these are configurabe, and can be set by the script

        // if not empty, this will be removed when forms are converted
        oldFormPrefix: string;
        // if not empty, this will be added to newly-created forms
		newFormPrefix: string;

        // Cache for MISCs for recycling
        // miscItemCache: TList;

        miscItemLastIndex: integer;

        // table of data hash -> misc item in the current file
        // miscItemLookupTable: TStringList;
        // to show the warning
        numRecycleableMiscs: integer;

		spawnMiscData: TJsonObject;
		spawnMiscDataLoaded: boolean;

        // cache for stacked mod items
        stackedFormlistCache: IInterface;

        // all building plans cache
        allBuildingPlansCache: TList;

        // cached addon config stuff
        currentAddonQuest, currentAddonConfig: IInterface;

        themeTagList, selectedThemeTagList: TStringList;
        hasSelectedThemes: boolean;

        // forms from files on this list will never be translated
        validMastersList: TStringList;

        // keywords for plot types
        SS2_PlotSize_1x1, SS2_PlotSize_2x2, SS2_PlotSize_3x3, SS2_PlotSize_Int: IInterface;
        SS2_PlotType_Agricultural, SS2_PlotType_Commercial, SS2_PlotType_Industrial, SS2_PlotType_Martial: IInterface;
        SS2_PlotType_Municipal, SS2_PlotType_Recreational, SS2_PlotType_Residential: IInterface;

    ////////////////////// MISC RECYCLING FUNCTIONS /////////////////////
    function normalizeKeyFloat(x: float): string;
    begin
        Result := IntToStr(Round(x * 10000));
    end;

    function getMiscLookupKey(targetFile, formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; iType: integer; spawnName: string; requirementsItem: IInterface): string;
    var
        formToSpawnId, reqItemId, curFileName: string;
		curFile: IInterface;
    begin
		curFile := GetFile(formToSpawn);
		curFileName := GetFileName(curFile);
        // formToSpawnId := IntToHex(getLocalFormId(curFile, FormID(formToSpawn)), 8);
        formToSpawnId := IntToStr(getLocalFormId(curFile, FormID(formToSpawn)));

        reqItemId := '';
        if(assigned(requirementsItem)) then begin
            reqItemId := IntToHex(FormID(requirementsItem), 8);
        end;

        // F4 uses at most 4 decimals, rounding them if necessary

        Result :=
			curFileName+'-'+
            formToSpawnId+'-'+
            normalizeKeyFloat(posX)+'-'+
            normalizeKeyFloat(posY)+'-'+
            normalizeKeyFloat(posZ)+'-'+
            normalizeKeyFloat(rotX)+'-'+
            normalizeKeyFloat(rotY)+'-'+
            normalizeKeyFloat(rotZ)+'-'+
            normalizeKeyFloat(scale)+'-'+
            IntToStr(iType)+'-'+spawnName+'-'+reqItemid;

        // just return it without hashing...
    end;

    function getMiscLookupKeyFromScript(miscScript: IInterface): string;
    var
        spawnDetails, formToSpawn: IInterface;
        posX, posY, posZ, rotX, rotY, rotZ, scale: float;
        iType: integer;
        spawnName: string;
        reqItem: IInterface;
    begin
        spawnDetails := getScriptProp(miscScript, 'SpawnDetails');
        if (not assigned(spawnDetails(spawnDetails))) then begin
            AddMessage('No SpawnDetails in a spawn misc, this shouldn''t happen');
            exit;
        end;

        formToSpawn := getStructMemberDefault(spawnDetails, 'ObjectForm', nil);
        if (not assigned(spawnDetails(formToSpawn))) then begin
            AddMessage('No formToSpawn in a spawn misc, this shouldn''t happen');
            exit;
        end;

        posX := getStructMemberDefault(spawnDetails, 'fPosX', 0.0);
        posY := getStructMemberDefault(spawnDetails, 'fPosY', 0.0);
        posZ := getStructMemberDefault(spawnDetails, 'fPosZ', 0.0);

        rotX := getStructMemberDefault(spawnDetails, 'fAngleX', 0.0);
        rotY := getStructMemberDefault(spawnDetails, 'fAngleY', 0.0);
        rotZ := getStructMemberDefault(spawnDetails, 'fAngleZ', 0.0);
        scale := getStructMemberDefault(spawnDetails, 'fScale', 1.0);

        iType := getScriptPropDefault(miscScript, 'iType', 0);
        spawnName := getScriptPropDefault(miscScript, 'sSpawnName', '');
        reqItem := getScriptPropDefault(miscScript, 'Requirements', nil);

        Result := getMiscLookupKey(GetFile(miscScript), formToSpawn, posX, posY, posZ, rotX, rotY, rotZ, scale, iType, spawnName, reqItem);
    end;

    procedure addMiscToLookup(misc, miscScript: IInterface);
    var
        oldScript, curFile: IInterface;

        oldIndex: integer;
        hashedString, curFileName: string;
        oldMisc: IInterface;
		curArray: TJsonObject;
    begin
        // super special workaround:
        if(EditorID(misc) = 'SS2_Template_StageItem') then exit;

        hashedString := getMiscLookupKeyFromScript(miscScript);
        if(hashedString = '') then begin
            AddMessage('Failed to generate lookup key for '+EditorID(misc));
            exit;
        end;

		curFile := GetFile(misc);
		curFileName := GetFileName(curFile);

		curArray := spawnMiscData.O[curFileName].O['spawns'];
		AddMessage('Will be adding misc to lookup: '+EditorID(misc)+' -> '+hashedString+' file: '+curFileName);

		if(curArray.S[hashedString] <> '') then begin
			oldMisc := getFormByFileAndFormID(curFile, StrToInt(curArray.S[hashedString]));

			if(Equals(oldMisc, misc)) then begin
                // for some reason, we have this already
				AddMessage('!!!CONFLICT!!! '+hashedString);
                exit;
            end;

			oldScript := getScript(oldMisc, 'SimSettlementsV2:MiscObjects:StageItem');
			if(ElementsEquivalent(oldScript, miscScript)) then begin
                numRecycleableMiscs := numRecycleableMiscs + 1;
                // AddMessage('WARNING! Redundant MISCs found: '+EditorID(oldMisc)+'/'+EditorID(misc)+', you should run SS2_RecycleRedundantMiscs on your AddOn.');
            end else begin
                AddMessage('WARNING! Seems like SS2Lib can no longer generate text keys for spawn miscs! Generated '+hashedString+' for '+EditorID(oldMisc)+'/'+EditorID(misc)+', which seem to be different!');
            end;
            exit;
		end;

		AddMessage('Should be putting it in now');
        // otherwise put it in
		curArray.S[hashedString] := IntToStr(getLocalFormId(curFile, FormID(misc)));

        //miscItemLookupTable.AddObject(hashedString, misc);
    end;

	procedure addMiscToRecycled(misc: IInterface);
	var
		curFile: IInterface;
		curFileName: string;
		curFormId: cardinal;
	begin

		curFile := GetFile(misc);
		curFileName := GetFileName(curFile);
		curFormId := getLocalFormId(curFile, FormID(misc));

		spawnMiscData.O[curFileName].A['recycled'].add(IntToStr(curFormId));
	end;

    function getSpawnMiscByParams(targetFile, formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; iType: integer; spawnName: string; requirementsItem: IInterface): IInterface;
    var
        key: string;
		curFileName: string;
        i: integer;
		curArray: TJsonObject;
    begin
        Result := nil;
        //if(miscItemLookupTable = nil) then exit;
        key := getMiscLookupKey(targetFile, formToSpawn, posX, posY, posZ, rotX, rotY, rotZ, scale, iType, spawnName, requirementsItem);

		curFileName := GetFileName(targetFile);

        AddMessage('-> Looking for MISC: '+key+' in '+curFileName);
		curArray := spawnMiscData.O[curFileName].O['spawns'];
		//i := curArray.IndexOfName(key);
        if (curArray.S[key] = '') then exit;

        AddMessage('should have it '+curArray.S[key]);
		Result := getFormByFileAndFormID(targetFile, StrToInt(curArray.S[key]));
    end;

    function tryToParseInt(s: string): integer;
    var
        tmp, curPart, curChar: string;
        i: integer;
    begin
        Result := 0;
        tmp := s;
        curPart := '';

        for i:=1 to length(tmp) do begin
            curChar := tmp[i];
            if (curChar >= '0') and (curChar <= '9') then begin
                curPart := curPart + curChar;
            end;
        end;

        if(curPart <> '') then begin
            Result := StrToInt(curPart);
        end;
    end;

	function testConcat(l: TStringList): string;
	var
		i: integer;
	begin
		Result := '';

		for i:=0 to l.count-1 do begin
			Result := Result + l[i];
		end;
	end;

	function loadMiscsFromCache(targetFile: IInterface): boolean;
	var
		jsonData, curData, curSpawnData: TJsonObject;
		recycled, spawns: TJsonArray;
		curFileName, testwhat, curKey, otherKey: string;
		tempStringList: TStringList;
		i: integer;
		curFormId: cardinal;
		curForm, curScript: IInterface;
	begin
		spawnMiscDataLoaded := true;
		AddMessage('Loading Spawn Misc cache from '+miscItemCacheFileName);
		tempStringList := TStringList.create;

		tempStringList.LoadFromFile(miscItemCacheFileName);

		//jsonData := TJsonObject.create;
		//tempStringList.Delimiter := #10;
		testwhat := testConcat(tempStringList);
		//AddMessage(testwhat);
		spawnMiscData := spawnMiscData.parse(testwhat);

		tempStringList.free();

		if(not assigned(targetFile)) then begin
			AddMessage('Cache loaded.');
			exit;
		end;
		curFileName := getFileName(targetFile);
		curData := spawnMiscData.O[curFileName];
		//spawnMiscData
		if(not spawnMiscData.O[curFileName].B['exists']) then begin
			AddMessage('No data for '+GetFileName(targetFile)' present in cache, cache will be rebuilt.');
			Result := true;
			exit;
		end;

		miscItemLastIndex := curData.I['max_index'];

		recycled := curData.A['recycled'];
		spawns := curData.O['spawns'];

		// check if cache is valid?
		for i:=0 to recycled.count-1 do begin
			curFormId := StrToInt(recycled.S[i]);
			curForm := getFormByFileAndFormID(targetFile, curFormId);
			if(not assigned(curForm)) then begin
				AddMessage('Cache file is not valid, it will be rebuilt.');
				Result := true;
				exit;
			end;
			// is this a recycled misc?
			if(not strStartsWith(EditorID(curForm), recycleableMiscPrefix)) then begin
				AddMessage('Cache file is not valid, it will be rebuilt.');
				Result := true;
				exit;
			end;
		end;

		for i:=0 to spawns.count-1 do begin
			curKey := spawns.names[i];
			curFormId := StrToInt(spawns.S[curKey]);
			curForm := getFormByFileAndFormID(targetFile, curFormId);
			if(not assigned(curForm)) then begin
				AddMessage('Cache file is not valid, it will be rebuilt.');
				Result := true;
				exit;
			end;

			// is this a real spawn?
			if(strStartsWith(EditorID(curForm), recycleableMiscPrefix)) then begin
				AddMessage('Cache file is not valid, it will be rebuilt.');
				Result := true;
				exit;
			end;

			curScript := getScript(curForm, 'SimSettlementsV2:MiscObjects:StageItem');
			if(not assigned(curScript)) then begin
				AddMessage('Cache file is not valid, it will be rebuilt.');
				Result := true;
				exit;
			end;
			otherKey := getMiscLookupKeyFromScript(curScript);
			if(otherKey <> curKey) then begin
				AddMessage('Cache file is not valid, it will be rebuilt.');
				Result := true;
				exit;
			end;
		end;

		AddMessage('Loaded Spawn Misc cache from file. Found '+(IntToStr(recycled.count))+' recycled, '+IntToStr(spawns.count)+' used for '+GetFileName(targetFile));

		Result := false;
		//curData.free();
	end;

	procedure saveMiscsToCache();
	var
		//lookupData: TJsonObject;
		curFile, curObj: IInterface;
		curFileName, curKey: string;
		i: integer;
		curFormId: cardinal;
		tempStringList: TStringList;
	begin
		if(not spawnMiscDataLoaded) then begin
			exit;
		end;

		tempStringList := TStringList.create;

		tempStringList.add(spawnMiscData.toString());
		tempStringList.saveToFile(miscItemCacheFileName);

		tempStringList.free();
		//jsonData.free();
	end;

    procedure loadRecycledMiscs(targetFile: IInterface; deprecated: boolean);
    var
        i, curIndex: integer;
        curElem, miscGroup, miscScript: IInterface;
        curEdid, substr: string;
		doRebuildCache: boolean;
    begin
		doRebuildCache := true;
		spawnMiscDataLoaded := true;

		miscItemLastIndex := 0;

		if (FileExists(miscItemCacheFileName)) then begin
			// load cache
			doRebuildCache := loadMiscsFromCache(targetFile);
		end;

		if(not doRebuildCache) then begin
			exit;
		end;

        loadRecycledMiscsNoCacheFile(targetFile, true);

		// saveMiscsToCache();

		//AddMessage('Finished building Spawn Misc cache. Found '+IntToStr(miscItemCache.count)+' recycled Miscs, indexed '+IntToStr(miscItemLookupTable.count)+' used Miscs');
		if(numRecycleableMiscs > 0) then begin
			AddMessage('WARNING! Found '+IntToStr(numRecycleableMiscs)+' Redundant MISCs! You should run SS2_RecycleRedundantMiscs on your AddOn.');
		end;
    end;

	procedure loadRecycledMiscsNoCacheFile(targetFile: IInterface; buildSpawnList: boolean);
    var
        i, curIndex: integer;
        curElem, miscGroup, miscScript: IInterface;
        curFilename, curEdid, substr: string;
    begin
		spawnMiscDataLoaded := true;
		curFilename := GetFileName(targetFile);

        AddMessage('Building Spawn Misc cache from scratch for file '+curFilename+'...');

		spawnMiscData.O[curFilename].clear();

        numRecycleableMiscs := 0;
        miscGroup := GroupBySignature(targetFile, 'MISC');
        for i:=0 to ElementCount(miscGroup)-1 do begin
            curElem := ElementByIndex(miscGroup, i);
            curEdid := EditorID(curElem);
            if(strStartsWith(curEdid, recycleableMiscPrefix)) then begin

                addMiscToRecycled(curElem);

                substr := copy(curEdid, length(recycleableMiscPrefix)+1, length(curEdid));
                // this MIGHT be numeric, or maybe not
                curIndex := tryToParseInt(substr);

                if(curIndex > miscItemLastIndex) then begin
                    miscItemLastIndex := curIndex;
                end;

            end else begin
				if(buildSpawnList) then begin
					miscScript := getScript(curElem, 'SimSettlementsV2:MiscObjects:StageItem');
					if(assigned(miscScript)) then begin
						addMiscToLookup(curElem, miscScript);
					end;
				end;
            end;
        end;
		//
		spawnMiscData.O[curFilename].B['exists'] := true;
		spawnMiscData.O[curFilename].I['max_index'] := miscItemLastIndex;
		AddMessage('Spawn Misc cache built.');
    end;

    function getRecycledMisc(targetFile: IInterface): IInterface;
    var
        lastIndex: index;

		curFileName: string;
		curFormId: cardinal;
		curArray: TJsonArray;
	begin
        Result := nil;
		curFileName := GetFileName(targetFile);

		curArray := spawnMiscData.O[curFileName].A['recycled'];
		if(curArray.count = 0) then begin
			exit;
		end;

		lastIndex := curArray.count - 1;

		Result := getFormByFileAndFormID(targetFile, StrToInt(curArray.S[lastIndex]));

		curArray.delete(lastIndex);
    end;

    procedure addRecycledMisc(misc: IInterface);
    begin
        miscItemLastIndex := miscItemLastIndex + 1;
        SetElementEditValues(misc, 'EDID', recycleableMiscPrefix + IntToStr(miscItemLastIndex));
        // if(miscItemCache = nil) then exit;
        addMiscToRecycled(misc);
    end;

    procedure recycleSpawnMiscIfPossible(misc: IInterface);
    var
        curSpawnScript, curFile: IInterface;
        key, curFileName: string;
        i: index;
		curArray: TJsonObject;
    begin
        if(not assigned(misc)) then begin
            AddMessage('recycleSpawnMiscIfPossible called with unassigned misc');
            exit;
        end;

        if(ReferencedByCount(misc) > 0) then begin
            AddMessage('Spawn Misc '+EditorID(misc)+' is still used, NOT recycling');
            exit;
        end;

        // AddMessage('Spawn Misc '+EditorID(misc)+' is no longer used, recycling');

        curSpawnScript := getScript(misc, 'SimSettlementsV2:MiscObjects:StageItem');

		curFile := GetFile(misc);
		curFileName := GetFileName(curFile);

		curArray := spawnMiscData.O[curFileName].O['spawns'];

		key := getMiscLookupKeyFromScript(curSpawnScript);
        AddMessage('Spawn Misc '+EditorID(misc)+' is no longer used, recycling '+key);

		//i := curArray.IndexOfName(key);

		//i := miscItemLookupTable.indexOf(key);
		if(curArray.S[key] <> '') then begin
			AddMessage('Deleting spawn '+key+' from used list');
			curArray.delete(curArray.indexOf(key));
		end;

        deleteScriptProps(curSpawnScript);

        addRecycledMisc(misc);
    end;

    ////////////////////// GENERIC HELPER FUNCTIONS /////////////////////

    {
        Fetches an item from a file by editorID and signature. If it doesn't exist, it will be created.
    }
    function getElemByEdidAndSig(edid: string; sig: string; fromFile: IInterface): IInterface;
    var
        group, newElem: IInterface;
    begin
        group := GroupBySignature(fromFile, sig);

        if(not assigned(group)) then begin
            group := Add(fromFile, sig, True);
        end;

        newElem := MainRecordByEditorID(group, edid);

        if(not assigned(newElem)) then begin
            newElem := Add(group, sig, true);
            if(not assigned(newElem)) then begin
                newElem := Add(group, sig, true); // stolen from dubhFunctions
            end;
            SetElementEditValues(newElem, 'EDID', edid);
        end;

        Result := newElem;
    end;

    {
        matswap: pass nil to remove
        remapIndex: pass < 0 to remove
    }
    procedure applyMatswapToModel(matswap: IInterface; remapIndex: integer; target: IInterface);
    var
        isRemoving: boolean;
        modelRoot, modc, mods: IInterface;
    begin
        isRemoving := false;
        if(not assigned(matswap) and remapIndex < 0) then begin
            isRemoving := true;
        end;

        modelRoot := ElementByPath(target, 'Model');
        if(not assigned(modelRoot)) and (isRemoving) then begin
            exit;
        end;

        if(assigned(matswap)) then begin
            setPathLinksTo(modelRoot, 'MODS', matswap);
        end else begin
            RemoveElement(modelRoot, 'MODS');
        end;

        if(remapIndex >= 0) then begin
            SetElementEditValues(modelRoot, 'MODC', FloatToStr(remapIndex));
        end else begin
            RemoveElement(modelRoot, 'MODC');
        end;
    end;

    {
        Tries to copy the matswap (and remap index) from source to target.
    }
    procedure copyModelMatswap(source: IInterface; target: IInterface);
    var
        modelRoot, mods: IInterface;
        modc: string;
        modcFloat: string;
    begin
        // Result := false;

        if(signature(source) = 'SCOL') then begin
            AddMessage('=== WARNING ===: copyModelMatswap called with an SCOL for source. This might be a bug! Source: '+Name(source)+', Target: '+Name(target));
            exit;
        end;

        mods := PathLinksTo(source, 'Model\MODS'); // material swap, linksTo
        modc := GetElementEditValues(source, 'Model\MODC');
        modcFloat := -1;
        if(modc <> '') then begin
            modcFloat := StrToFloat(modc);
        end;

        applyMatswapToModel(mods, modcFloat, target);
    end;

    procedure applyModelAndTranslate(source, target, fromFile, toFile: IInterface);//, oldFile, toFile: IInterface
    var
        modelRoot, modl, modc, mods, modf: IInterface;
        swap: IInteface;
    begin
        if(signature(source) = 'SCOL') then begin
            AddMessage('=== WARNING ===: applyModel called with an SCOL for source. This might be a bug! Source: '+Name(source)+', Target: '+Name(target));
            exit;
        end;

        modl := ElementByPath(source, 'Model\MODL'); // model name, string
        modc := ElementByPath(source, 'Model\MODC'); // color remapping index, float
        mods := ElementByPath(source, 'Model\MODS'); // material swap, linksTo
        modf := ElementByPath(source, 'Model\MODF'); //

        // maybe to extra stuff to matswap
        if(assigned(mods)) then begin
            swap := LinksTo(mods);
            if(assigned(swap)) then begin
                if(assigned(fromFile) and assigned(toFile)) then begin
                    swap := translateFormToFile(swap, fromFile, toFile);
                end;
            end;
        end;

        if(Signature(target) = 'ARMO') then begin
            modelRoot := ebp(target, 'Male world model');
            if(not assigned(modelRoot)) then begin
                modelRoot := Add(target, 'Male world model', true);
            end;

            // here:
            // MOD2: model name, string
            // MODC: color remapping index
            // MO2S: Matswap
            if(assigned(modl)) then SetEditValueByPath(modelRoot, 'MOD2', GetEditValue(modl));
            if(assigned(modc)) then SetEditValueByPath(modelRoot, 'MODC', GetEditValue(modc));
            if(assigned(swap)) then SetPathLinksTo(modelRoot, 'MO2S', swap); //SetEditValueByPath(modelRoot, 'MO2S', GetEditValue(mods));
        end else begin
            modelRoot := ebp(target, 'Model');
            if(not assigned(modelRoot)) then begin
                modelRoot := Add(target, 'Model', true);
            end;

            if(assigned(modl)) then SetEditValueByPath(modelRoot, 'MODL', GetEditValue(modl));
            if(assigned(modc)) then SetEditValueByPath(modelRoot, 'MODC', GetEditValue(modc));
            if(assigned(swap)) then SetPathLinksTo(modelRoot, 'MODS', swap);//SetEditValueByPath(modelRoot, 'MODS', GetEditValue(mods));
            if(assigned(modf)) then SetEditValueByPath(modelRoot, 'MODF', GetEditValue(modf));
        end;
    end;

    {
        Copies model data, for blueprint items
    }
    procedure applyModel(source: IInterface; target: IInterface);
    var
        modelRoot, modl, modc, mods, modf: IInterface;
    begin
        applyModelAndTranslate(source, target, nil, nil);
    end;

    procedure setUniversalFormProperty_id(struct: IInterface; id: cardinal; pluginName, idKey, nameKey: string);
    begin
        setStructMember(struct, idKey, id);
        setStructMember(struct, nameKey, pluginName);
    end;

    procedure setUniversalFormProperty_elem(struct: IInterface; elem: IInterface; elemKey: string);
    begin
        setStructMember(struct, elemKey, elem);
    end;

    function canUseMasterForUniversalForm(masterName: string; targetFile: IInterface;): boolean;
    var
        targetName: string;
    begin
        if(masterName = '') then begin
            Result := false;
            exit;
        end;
        targetName := GetFileName(targetFile);
        if (masterName = targetName) or (masterName = 'SS2.esm') or (masterName = 'Fallout4.esm') then begin
            Result := true;
            exit;
        end;

        if(masterName = 'SimSettlements.esm') then begin
            Result := false;
            exit;
        end;


        Result := HasMaster(targetFile, masterName);
    end;

    procedure setUniversalFormProperty(struct: IInterface; elem: IInterface; id: cardinal; pluginName, elemKey, idKey, nameKey: string);
    var
        fromFile, toFile: IInterface;
        masterType : integer;
        newEdid: string;
    begin

        toFile := GetFile(getParentRecord(struct));
        //AddMessage('Found ToFile: ');
        //dumpElem(toFile);

        if(assigned(elem)) then begin
            fromFile := GetFile(elem);
            pluginName := GetFileName(fromFile);

            if (canUseMasterForUniversalForm(pluginName, toFile)) then begin
                setUniversalFormProperty_elem(struct, elem, elemKey);
                exit;
            end;

            id := getLocalFormId(fromFile, FormID(elem));
            setUniversalFormProperty_id(struct, id, pluginName, idKey, nameKey);

            exit;
        end;

        if (canUseMasterForUniversalForm(pluginName, toFile)) then begin
            elem := getFormByFileAndFormID(FindFile(pluginName), id);
            if(assigned(elem)) then begin
                setUniversalFormProperty_elem(struct, elem, elemKey);
                exit;
            end;

            setUniversalFormProperty_id(struct, id, pluginName, idKey, nameKey);

            exit;
        end;

        setUniversalFormProperty_id(struct, id, pluginName, idKey, nameKey);
    end;

    function getUniversalForm(script: IInterface; propName: string): IInterface;
    var
        structProp, BaseForm : IInterface;
        iFormID : cardinal;
        sPluginName : string;
    begin
        Result := nil;
        structProp := getScriptProp(script, propName);
        if(not assigned(structProp)) then exit;

        BaseForm := getStructMemberDefault(structProp, 'BaseForm', nil);
        iFormID := getStructMemberDefault(structProp, 'iFormID', 0);
        sPluginName := getStructMemberDefault(structProp, 'sPluginName', '');

        if(assigned(BaseForm)) then begin
            Result := BaseForm;
            exit;
        end;

        if(iFormID > 0) and (sPluginName <> '') then begin
            Result := getFormByFilenameAndFormID(sPluginName, iFormID);
        end;
    end;

    {
        Sets a script property to a WorkshopFramework "UniversalForm" struct
    }
    procedure setUniversalForm(script: IInterface; propName: string; rec: IInterface);
    var
        prop: IInterface;
    begin
        prop := getOrCreateScriptPropStruct(script, propName);
        setUniversalFormProperty(prop, rec, 0, '', 'BaseForm', 'iFormID', 'sPluginName');
    end;

    procedure setUniversalForm_id(script: IInterface; propName: string; id: cardinal; pluginName: string);
    var
        prop: IInterface;
    begin
        prop := getOrCreateScriptPropStruct(script, propName);
        setUniversalFormProperty(prop, nil, id, pluginName, 'BaseForm', 'iFormID', 'sPluginName');
    end;

    procedure setUniversalFormStruct(struct: IInterface; rec: IInterface);
    begin
        setUniversalFormProperty(struct, rec, 0, '', 'BaseForm', 'iFormID', 'sPluginName');
    end;

    procedure setUniversalFormStruct_id(struct: IInterface; id: cardinal; pluginName: string);
    begin
        setUniversalFormProperty(struct, nil, id, pluginName, 'BaseForm', 'iFormID', 'sPluginName');
    end;

	function isResourceObject_elem(elem: IInterface): boolean;
    var
        script: IInterface;
        sig: string;
        resourceVal: float;
    begin
        Result := false;

        sig := Signature(elem);

        if(sig = 'SCOL') then begin
            exit;
        end;

        resourceVal := getAvByPath(elem, 'PRPS', 'WorkshopResourceObject');
        if(resourceVal > 0) then begin
            Result := true;
            exit;
        end;

        //script := getScript(elem, 'workshopobjectscript');
        script := getScript(elem, 'SimSettlementsV2:ObjectReferences:SimPlot');
        Result := assigned(script);
    end;

    function isResourceObject_id(formFileName: string; id: cardinal): boolean;
    var
        elem: IInterface;
    begin
        Result := false;
        elem := getFormByFilenameAndFormID(formFileName, id);
        if(not assigned(elem)) then begin
            exit;
        end;

        Result := isResourceObject_elem(elem);
    end;

    function sanitizeEdidPart(input: string): string;
    var
        i: integer;
        tmp, c: string;
    begin
        tmp := input;
        Result := '';

        for i:=1 to length(tmp) do begin
            c := tmp[i];

            if (
                (c >= 'a') and (c <= 'z') or
                (c >= 'A') and (c <= 'Z') or
                (c >= '0') and (c <= '9') or
                (c = '-') or (c = '_')
            ) then begin
                Result := Result + c;
            end;
        end;

    end;

    function shortenWithCrc32(input: string): string;
    var
        part: string;
    begin
        if(length(input) > maxEdidLength) then begin
            part := copy(input, 1, maxEdidLength-9);
            Result := part + '_' + IntToHex(StringCRC32(input), 8);
            exit;
        end;
        Result := input;
    end;

    {
        Shortens the edid, if necessary.
        Tries to preserve the given prefix, if possible.

        Returns prefix+rest if it's shorter than maxEdidLength
        Returns prefix+CRC32(rest) if the prefix is short enough
        Returns CRC32(prefix+rest) if the prefix itself is too long already
    }
    function getShortEdid(prefix, rest: string): string;
    begin
        {
        if ((length(prefix) + length(rest)) > maxEdidLength) then begin
            if((length(prefix)+8) > maxEdidLength) then begin
                // if the prefix itself is too long already, hash everything
                Result := IntToHex(StringCRC32(prefix+rest), 8);
                exit;
            end;
            // leave the prefix, hash the rest
            Result := prefix + IntToHex(StringCRC32(rest), 8);
            exit;
        end;
        }
        // just return everything
        Result := shortenWithCrc32(prefix + rest);
    end;

    function stripPrefix(prefix, base: string): string;
    var
        prefixLength, strLength: integer;
    begin
        Result := base;
        if(prefix = '') then begin
            exit;
        end;

        //AddMessage('Stripping '+prefix+' from '+base);

        prefixLength := length(prefix);
        strLength := length(base);
        Result := base;
        if(prefixLength > strLength) then begin
            exit;
        end;

        if(copy(base, 1, prefixLength) = prefix) then begin
            Result := copy(base, prefixLength+1, strLength);
        end;
    end;

    function isNumericString(str: string): boolean;
    var
        strFuq: string;
        i: integer;
    begin
        strFuq := str;
        Result := true;

        for i:=1 to length(strFuq) do begin
            if (strFuq[i] < '0') or (strFuq[i] > '9') then begin
                Result := false;
                exit;
            end;
        end;
    end;


    function FindObjectByEdidWithSuffix(maybeEdid: string): IInterface;
    var
        suffix, prefix: string;
        i: integer;
    begin
        suffix := Copy(maybeEdid, Length(maybeEdid) - 2, 3);

        if(not isNumericString(suffix)) then begin
            Result := FindObjectByEdid(maybeEdid);
            exit;
        end;

        prefix := copy(maybeEdid, 1, length(maybeEdid)-3);
        Result := FindObjectByEdid(prefix);

        if(not assigned(Result)) then begin
            // maybe the suffix belongs there?
            Result := FindObjectByEdid(maybeEdid);
        end;

        if(not assigned(Result)) then begin
            // special case: if this is a kgSIM_ form, check if it exists as SS2_
            if(strStartsWith(maybeEdid, 'kgSIM_')) then begin
                Result := FindObjectByEdidWithSuffix('SS2_'+stripPrefix('kgSIM_', maybeEdid));
            end;
        end;
    end;

    function generateEdid(prefix, base: string): string;
    begin
        Result := getShortEdid(globalNewFormPrefix+prefix, stripPrefix(prefix, stripPrefix(globalNewFormPrefix, base)));
    end;


    ///////////////////// TEMPLATE HELPER FUNCTIONS /////////////////////

    procedure loadThemeTags();
    var
        parentQuest, questScript, themeProp, curEntry, curMisc, curMiscScript, curKw: IInterface;
        i: integer;
        curName: string;
    begin
        themeTagList := TStringList.create;

        parentQuest := FindObjectByEdid('SS2_PlotManager');

        questScript := getScript(parentQuest, 'SimSettlementsV2:quests:PlotManager');

        themeProp := getScriptProp(questScript, 'BuildingPlanThemes');
        themeTagList.sorted := true;

        // dumpElem(themeProp);
        for i:=0 to ElementCount(themeProp)-1 do begin
            curEntry := ElementByIndex(themeProp, i);

            curMisc := PathLinksTo(curEntry, 'Object v2\FormID');
            if(not assigned(curMisc)) then continue;

            curMiscScript := GetScript(curMisc, 'SimSettlementsV2:MiscObjects:BuildingPlanTheme');
            if(not assigned(curMiscScript)) then continue;

            curKw := getScriptProp(curMiscScript, 'ThemeKeyword');
            if(not assigned(curKw)) then continue;

            // dumpElem(curKw);
            curName := getElementEditValues(curMisc, 'FULL');
            curName := stripPrefix('[*Tag] ', curName);


            themeTagList.AddObject(curName, curKw);
        end;

    end;

    function getThemeKeywordCaption(kw: IInterface): string;
    var
        i: integer;
        curKw: IInterface;
        curTitle: string;
    begin
        Result := '';
        for i:=0 to themeTagList.count-1 do begin
            curKw := ObjectToElement(themeTagList.Objects[i]);
            if(isSameForm(curKw, kw)) then begin
                Result := themeTagList[i];
                // Result := true;
                exit;
            end;
        end;
    end;

    function getPlotThemes(plot: IInterface): TStringList;
    var
        kwda, curKw: IInterface;
        i: integer;
        curName: string;
    begin
        Result := TStringList.create;
        // anything from the plot's KWDA which is a theme KW
        kwda := ElementByPath(plot, 'KWDA');
        for i:=0 to ElementCount(kwda)-1 do begin
            curKw := LinksTo(ElementByIndex(kwda, i));

            curName := getThemeKeywordCaption(curKw);

            if(curName <> '') then begin
                Result.addObject(curName, curKw);
            end;
        end;
    end;

    procedure setPlotThemes(plot: IInterface; themeTagList: TStringList);
    var
        i: integer;
    begin
        if(themeTagList <> nil) then begin
            stripThemeKeywords(plot);
            for i:=0 to themeTagList.count-1 do begin
                addKeywordByPath(plot, ObjectToElement(themeTagList.Objects[i]), 'KWDA');
            end;
        end;// otherwise don't touch
    end;

    function generatePluginReqsMisc(targetFile: IInterface; requiredPlugins: TStringList): IInterface;
    var
        i: integer;
        edidBase, miscEdid, curPlugin: string;
        reqScript, prop, curEntry, propVal, curStruct: IInterface;
    begin
        Result := nil;
        if(requiredPlugins.count = 0) then exit;

        edidBase := 'RequiredPlugins_';
        if(requiredPlugins.count = 1) then begin
            edidBase := edidBase + requiredPlugins[0];
        end else begin
            requiredPlugins.Delimiter := '_';
            requiredPlugins.StrictDelimiter := true;

            edidBase := edidBase + requiredPlugins.DelimitedText;
        end;

        edidBase := StringReplace(edidBase, '.', '', [rfReplaceAll]);

        miscEdid := GenerateEdid(usageReqsPrefix, edidBase);
        // usageReqsTemplate
        // usageReqsPrefix
        Result := getCopyOfTemplate(targetFile, usageReqsTemplate, miscEdid);

        reqScript := getScript(Result, 'SimSettlementsV2:MiscObjects:UsageRequirements');

        prop := getOrCreateScriptProp(reqScript, 'RequiredPlugins', 'Array of Struct');
        clearProperty(prop);

        // propVal := ElementByPath(prop, 'Value\Array of String');

        for i:=0 to requiredPlugins.count-1 do begin
            curPlugin := requiredPlugins[i];

            curStruct := appendStructToProperty(prop);

            setStructMember(curStruct, 'PluginName', curPlugin);

            // curEntry  := ElementAssign(propVal, HighInteger, nil, False);
            // SetEditValue(curEntry, curPlugin);
        end;
    end;

    function generateTerraformerCobj(edidBase: string; piece: IInterface; targetFile: IInterface; cost: integer; shouldHaveText: boolean): IInterface;
    var
        cobj, fvpa, curCmp, curItem: IInterface;
        i: integer;
    begin
        cobj := getCopyOfTemplate(targetFile, terraformerTemplate_Cobj, GenerateEdid('COBJ_'+foundationPrefix, edidBase));

        if(not shouldHaveText) then begin
            RemoveElement(cobj, 'DESC');
        end;

        SetPathLinksTo(cobj, 'CNAM', piece);


        fvpa := ElementByPath(cobj, 'FVPA');
        for i:=0 to ElementCount(fvpa)-1 do begin
            // should be only one in theory
            curCmp := ElementByIndex(fvpa, i);
            curItem := PathLinksTo(curCmp, 'Component');
            if(EditorID(curItem) = 'c_Concrete') then begin
                SetElementEditValues(curCmp, 'Count', IntToStr(cost));
                break;
            end;
        end;

        Result := cobj;
    end;

    procedure generateTerraformerSize(size: integer; tfName, tfPrefix: string; edidBase: string; targetFile: IInterface; matSwap: IInterface);
    var
        tmplMisc, tmplBlock, tmplCorner, tmplEdge, tmplLPiece, contentKeyword: IInterface;
        misc, block, corner, edge, lPiece: IInterface;
        sizeStr, edidWithSize, edidBlock, edidCorner, edidEdge, edidLPiece, namePrefix: string;
        miscScript, spawnData, blockScript: IInterface;
        costBlock, costEdge, costCorner, costLPiece: integer;
    begin

        costBlock  := 1;
        costEdge   := 1;
        costCorner := 1;
        costLPiece := 1;

        // size must be 1, 2, 3
        case size of
            1:  begin
                    tmplMisc := terraformerTemplate_Misc_1x1;
                    tmplBlock := terraformerTemplate_Block_1x1;
                    tmplCorner := terraformerTemplate_Corner_1x1;
                    tmplEdge := terraformerTemplate_Edge_1x1;
                    tmplLPiece := nil;
                    contentKeyword := SS2_FLID_1x1_Foundations;

                    costBlock := 8;
                    costEdge := 1;
                    costCorner := 1;
                end;
            2:  begin
                    tmplMisc := terraformerTemplate_Misc_2x2;
                    tmplBlock := terraformerTemplate_Block_2x2;
                    tmplCorner := terraformerTemplate_Corner_2x2;
                    tmplEdge := terraformerTemplate_Edge_2x2;
                    tmplLPiece := terraformerTemplate_LPiece_2x2;
                    contentKeyword := SS2_FLID_2x2_Foundations;

                    costBlock := 15;
                    costEdge := 1;
                    costCorner := 1;
                    costLPiece := 4;
                end;
            3:  begin
                    tmplMisc := terraformerTemplate_Misc_3x3;
                    tmplBlock := terraformerTemplate_Block_3x3;
                    tmplCorner := terraformerTemplate_Corner_3x3;
                    tmplEdge := terraformerTemplate_Edge_3x3;
                    tmplLPiece := nil;
                    contentKeyword := SS2_FLID_3x3_Foundations;

                    costBlock := 30;
                    costEdge := 2;
                    costCorner := 1;
                end;
            else exit;
        end;

        sizeStr := IntToStr(size);
        sizeStr := sizeStr+'x'+sizeStr;

        edidWithSize := edidBase+'_'+sizeStr;

        // generate the things
        edidBlock   := edidWithSize+'_Block';
        edidCorner  := edidWithSize+'_Corner';
        edidEdge    := edidWithSize+'_Edge';
        edidLPiece  := edidWithSize+'_LPiece';

        misc    := getCopyOfTemplate(targetFile, tmplMisc,      GenerateEdid(foundationPrefix, edidWithSize+'_Misc'));
        block   := getCopyOfTemplate(targetFile, tmplBlock,     GenerateEdid(foundationPrefix, edidBlock));
        corner  := getCopyOfTemplate(targetFile, tmplCorner,    GenerateEdid(foundationPrefix, edidCorner));
        edge    := getCopyOfTemplate(targetFile, tmplEdge,      GenerateEdid(foundationPrefix, edidEdge));
        if(assigned(tmplLPiece)) then begin
            lPiece := getCopyOfTemplate(targetFile, tmplLPiece, GenerateEdid(foundationPrefix, edidLPiece));
        end;

        // apply matswaps. unassigned is a valid matswap, too
        applyMatswapToModel(matSwap, -1, misc);
        applyMatswapToModel(matSwap, -1, block);
        applyMatswapToModel(matSwap, -1, corner);
        applyMatswapToModel(matSwap, -1, edge);
        if(assigned(lPiece)) then begin
            applyMatswapToModel(matSwap, -1, lPiece);
        end;

        namePrefix := 'Terraformer - ';
        if(tfPrefix <> '') then begin
            namePrefix := tfPrefix + ' ' + namePrefix;
        end;


        // apply names, too
        SetElementEditValues(misc, 'FULL', namePrefix+tfName);
        SetElementEditValues(block, 'FULL', namePrefix+tfName + ' - ' +sizeStr);
        SetElementEditValues(edge, 'FULL', namePrefix+tfName+' - '+sizeStr+' - Edge');
        SetElementEditValues(corner, 'FULL', namePrefix+tfName+' - '+sizeStr+' - Corner');
        if(assigned(lPiece)) then begin
            SetElementEditValues(lPiece, 'FULL', namePrefix+tfName+' - '+sizeStr+' - L Piece');
        end;

        // connect it together
        // block goes into the misc
        miscScript := getScript(misc, 'SimSettlementsV2:MiscObjects:Foundation');
        spawnData := getOrCreateScriptPropStruct(miscScript, 'SpawnData');
        setStructMember(spawnData, 'ObjectForm', block);

        // corner and edge go into the block
        blockScript := getScript(block, 'SimSettlementsV2:ObjectReferences:TerraformBlock');
        setScriptProp(blockScript, 'CornerPiece', corner);
        setScriptProp(blockScript, 'EdgePiece', edge);



        // generate COBJs
        //procedure generateTerraformerCobj(edidBase: string; piece: IInterface; targetFile: IInterface; cost: integer; shouldHaveText: boolean);


        {        costBlock := 15;
        costEdge := 1;
        costCorner := 1;
        costLPiece := 4;}
        generateTerraformerCobj(edidBlock, block, targetFile, costBlock, true);
        generateTerraformerCobj(edidCorner, corner, targetFile, costCorner, false);
        generateTerraformerCobj(edidEdge, edge, targetFile, costEdge, false);
        if(assigned(lPiece)) then begin
            generateTerraformerCobj(edidLPiece, lPiece, targetFile, costLPiece, false);
        end;

        // finally register the MISC
        //contentKeyword
        //procedure registerAddonContent(targetFile, content, keyword: IInterface);
        registerAddonContent(targetFile, misc, contentKeyword);
    end;

    {
        Generates the whole shebang of terraformers from just one matswap.
        tfName: name which will be shown to the user
        edidBase: without prefix
        targetFile: duh
        matSwap: can be nil
    }
    procedure generateTerraformers(tfName, tfPrefix, edidBase: string; targetFile: IInterface; matSwap: IInterface);
    var
        misc1x1, block1x1, corner1x1, edge1x1: IInterface;
        misc2x2, block2x2, corner2x2, edge2x2, lpiece2x2: IInterface;
        misc3x3, block3x3, corner3x3, edge3x3: IInterface;
    begin
        generateTerraformerSize(1, tfName, tfPrefix, edidBase, targetFile, matSwap);
        generateTerraformerSize(2, tfName, tfPrefix, edidBase, targetFile, matSwap);
        generateTerraformerSize(3, tfName, tfPrefix, edidBase, targetFile, matSwap);

        {        SS2_FLID_1x1_Foundations,
        SS2_FLID_2x2_Foundations,
        SS2_FLID_3x3_Foundations: IInterface;
}
        // oof
        {
        terraformerTemplate_Misc_1x1 := MainRecordByEditorID(miscGroup, 'SS2_PlotFoundation_1x1_Terraformer_Dirt');
        terraformerTemplate_Misc_2x2 := MainRecordByEditorID(miscGroup, 'SS2_PlotFoundation_2x2_Terraformer_Dirt');
        terraformerTemplate_Misc_3x3 := MainRecordByEditorID(miscGroup, 'SS2_PlotFoundation_3x3_Terraformer_Dirt');

        terraformerTemplate_Cobj := MainRecordByEditorID(cobjGroup, 'SS2_COBJ_Foundation_TerraformBlock2x2_Dirt'), // the cobj, SS2_COBJ_Foundation_TerraformBlock2x2_Dirt

        terraformerTemplate_Block_1x1  := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock1x1_Dirt'),
        terraformerTemplate_Corner_1x1 := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock1x1_Dirt_Corner'),
        terraformerTemplate_Edge_1x1   := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock1x1_Dirt_Edge'),

        terraformerTemplate_Block_2x2   := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt'),
        terraformerTemplate_Corner_2x2  := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt_Corner'),
        terraformerTemplate_Edge_2x2    := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt_Edge'),
        terraformerTemplate_LPiece_2x2  := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt_LPiece'),

        terraformerTemplate_Block_3x3   := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock3x3_Dirt'),
        terraformerTemplate_Corner_3x3  := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock3x3_Dirt_Corner'),
        terraformerTemplate_Corner_3x3  := MainRecordByEditorID(cobjGroup, 'SS2_Foundation_TerraformBlock3x3_Dirt_Edge'),

        terraformerTemplate_1x1 := MainRecordByEditorID(staticGroup, 'SS2_PlotFoundation_1x1_Terraformer_Dirt');
        terraformerTemplate_2x2 := MainRecordByEditorID(staticGroup, 'SS2_PlotFoundation_2x2_Terraformer_Dirt');
        terraformerTemplate_3x3 := MainRecordByEditorID(staticGroup, 'SS2_PlotFoundation_3x3_Terraformer_Dirt');
        }
    end;

    procedure registerHardcodedSSTranslation(ss1Edid, ss2Edid: string);
    var
        i: integer;
    begin
        i := hardcodedEdidMappingKeys.indexOf(ss1Edid);
        if(i < 0) then begin
            i:= hardcodedEdidMappingKeys.add(ss1Edid);
            hardcodedEdidMappingValues.add(ss2Edid);
        end else begin
            hardcodedEdidMappingValues[i] := ss2Edid;
        end;



        // hardcodedEdidMappingKeys   := TStringList.create;
        // hardcodedEdidMappingValues := TStringList.create;
    end;

    function getHardcodedSSTranslation(ss1Edid: string): string;
    var
        i: integer;
    begin
        Result := '';
        i := hardcodedEdidMappingKeys.indexOf(ss1Edid);
        if(i < 0) then exit;

        Result := hardcodedEdidMappingValues[i];
    end;

    {
        Loads all relevant stuff from all relevant files
    }
    function initSS2Lib(): boolean;
    var
        f4File, miscGroup, kywdGroup, weapGroup, armoGroup, staticGroup, msttGroup, cobjGroup, omodGroup, actiGroup, wsfrMasterFile: IInterface;
    begin
        Result := true;

		//miscItemCache := nil;
		//miscItemLookupTable := nil;
		spawnMiscData := TJsonObject.create;


        plotDialogOkBtn := nil;

        currentAddonQuest := nil;
        currentAddonConfig := nil;

        ss2masterFile := FileByName(ss2Filename);
        if(not assigned(ss2masterFile)) then begin
            AddMessage('Could not find '+ss2Filename+', this won''t work without.');
            Result := false;
            exit;
        end;

        wsfrMasterFile := FileByName(wsfrFilename);
        if(not assigned(wsfrMasterFile)) then begin
            AddMessage('Could not find '+wsfrFilename+', how did you even load SS2 without it??');
            Result := false;
            exit;
        end;


        f4File := FileByName('Fallout4.esm');
        keywordRecipeScrap := MainRecordByEditorId(GroupBySignature(f4File, 'KYWD'), 'WorkshopRecipeFilterScrap');

        miscGroup := GroupBySignature(ss2masterFile, 'MISC');
        kywdGroup := GroupBySignature(ss2masterFile, 'KYWD');
        weapGroup := GroupBySignature(ss2masterFile, 'WEAP');
        armoGroup := GroupBySignature(ss2masterFile, 'ARMO');
        staticGroup := GroupBySignature(ss2masterFile, 'STAT');
        msttGroup := GroupBySignature(ss2masterFile, 'MSTT');
        cobjGroup := GroupBySignature(ss2masterFile, 'COBJ');
        omodGroup := GroupBySignature(ss2masterFile, 'OMOD');
        actiGroup := GroupBySignature(ss2masterFile, 'ACTI');

        SS2_PlotSize_1x1 := MainRecordByEditorID(kywdGroup, 'SS2_PlotSize_1x1');
        SS2_PlotSize_2x2 := MainRecordByEditorID(kywdGroup, 'SS2_PlotSize_2x2');
        SS2_PlotSize_3x3 := MainRecordByEditorID(kywdGroup, 'SS2_PlotSize_3x3');
        SS2_PlotSize_Int := MainRecordByEditorID(kywdGroup, 'SS2_PlotSize_Int');
        SS2_PlotType_Agricultural := MainRecordByEditorID(kywdGroup, 'SS2_PlotType_Agricultural');
        SS2_PlotType_Commercial := MainRecordByEditorID(kywdGroup, 'SS2_PlotType_Commercial');
        SS2_PlotType_Industrial := MainRecordByEditorID(kywdGroup, 'SS2_PlotType_Industrial');
        SS2_PlotType_Martial := MainRecordByEditorID(kywdGroup, 'SS2_PlotType_Martial');
        SS2_PlotType_Municipal := MainRecordByEditorID(kywdGroup, 'SS2_PlotType_Municipal');
        SS2_PlotType_Recreational := MainRecordByEditorID(kywdGroup, 'SS2_PlotType_Recreational');
        SS2_PlotType_Residential := MainRecordByEditorID(kywdGroup, 'SS2_PlotType_Residential');

        SS2_FLID_LeaderCards := MainRecordByEditorID(kywdGroup, 'SS2_FLID_LeaderCards');
        SS2_Template_LeaderCardDescription := MainRecordByEditorID(omodGroup, 'SS2_Template_LeaderCardDescription');
        leaderCardTemplate := MainRecordByEditorID(weapGroup, 'SS2_Template_LeaderCard');

        buildingPlanTemplate := MainRecordByEditorID(weapGroup, 'SS2_Template_BuildingPlan');
        buldingPlanLevelTemplate := MainRecordByEditorID(weapGroup, 'SS2_Template_BuildingPlan_Level');

        cityPlanRootTemplate := MainRecordByEditorID(weapGroup, 'SS2_Template_CityPlan');
        cityPlanLayerTemplate:= MainRecordByEditorID(weapGroup, 'SS2_Template_CityPlanLayout');
        cityPlanDescriptionTemplate := MainRecordByEditorID(omodGroup, 'SS2_Template_CityPlanDescription');

        ridpManagerTemplate := MainRecordByEditorId(GroupBySignature(ss2masterFile, 'ACTI') ,'SS2_RIDPManager_FurnitureStore_Template');
        SS2_PurchaseableFurniture_Template := MainRecordByEditorId(GroupBySignature(ss2masterFile, 'MISC') ,'SS2_PurchaseableFurniture_Template');


        furnitureCobjTemplate := MainRecordByEditorId(cobjGroup ,'SS2_co_FurnitureStoreItem_76CrateChair1');
        // stackingCobjTemplate: IInterface;//SS2_co_StackEnable_SS
        stackingCobjTemplate := MainRecordByEditorId(cobjGroup ,'SS2_co_StackEnable_SS');

        descriptionTemplate := MainRecordByEditorID(omodGroup, 'SS2_Template_BuildingPlanDescription');
        stageItemTemplate := MainRecordByEditorID(miscGroup, 'SS2_Template_StageItem');

        usageReqsTemplate := MainRecordByEditorID(miscGroup, 'SS2_Template_UsageRequirements');
        unlockableTemplate := MainRecordByEditorID(miscGroup, 'SS2_Template_Unlockable');

        confirmMessageTemplate := MainRecordByEditorID(GroupBySignature(ss2masterFile, 'MESG'), 'SS2_Template_BuildingPlanConfirmation');

        addonQuestTemplate := MainRecordByEditorID(GroupBySignature(ss2masterFile, 'QUST'), 'SS2_AddonTemplate');

        addonDataTemplate := MainRecordByEditorID(miscGroup, 'SS2_Template_AddonConfig');

        versionGlobalTemplate := MainRecordByEditorID(GroupBySignature(ss2masterFile, 'GLOB'), 'SS2_ModVersion');

        buildingLevelSkinTemplate := MainRecordByEditorID(weapGroup, 'SS2_Template_BuildingLevelSkin');
        buildingSkinTemplate := MainRecordByEditorID(weapGroup, 'SS2_Template_BuildingSkin');

        // flags
        flagTemplate := MainRecordByEditorID(armoGroup, 'SS2_ThemeDefinition_Flags_Template');

        flagTemplate_Wall       := MainRecordByEditorID(staticGroup, 'SS2_FlagWallUSA');
        flagTemplate_Down       := MainRecordByEditorID(staticGroup, 'SS2_FlagDown_USA');
        flagTemplate_Waving     := MainRecordByEditorID(msttGroup, 'SS2_FlagWavingUSA01');

        flagTemplate_Banner     := MainRecordByEditorID(staticGroup, 'SS2_StaticBanner_USA');
        flagTemplate_BannerTorn := MainRecordByEditorID(staticGroup, 'SS2_StaticBannerTorn_USA');
        flagTemplate_BannerTornWaving := MainRecordByEditorID(staticGroup, 'SS2_WavingBannerTorn_USA_DoNotSCOL');
        flagTemplate_Circle01   := MainRecordByEditorID(staticGroup, 'SS2_HalfCircleFlag01_USA');
        flagTemplate_Circle02   := MainRecordByEditorID(staticGroup, 'SS2_HalfCircleFlag02_USA');
        flagTemplate_Matswap    := MainRecordByEditorID(GroupBySignature(ss2MasterFile, 'MSWP'), 'SS2_MS_HalfCircle_USAToMM');
        SS2_ThemeRuleset_Flags  := MainRecordByEditorID(miscGroup, 'SS2_ThemeRuleset_Flags');

        // terraformers
        terraformerTemplate_Misc_1x1 := MainRecordByEditorID(miscGroup, 'SS2_PlotFoundation_1x1_Terraformer_Dirt');
        terraformerTemplate_Misc_2x2 := MainRecordByEditorID(miscGroup, 'SS2_PlotFoundation_2x2_Terraformer_Dirt');
        terraformerTemplate_Misc_3x3 := MainRecordByEditorID(miscGroup, 'SS2_PlotFoundation_3x3_Terraformer_Dirt');

        terraformerTemplate_Cobj := MainRecordByEditorID(cobjGroup, 'SS2_COBJ_Foundation_TerraformBlock2x2_Dirt'); // the cobj, SS2_COBJ_Foundation_TerraformBlock2x2_Dirt
        foundationTemplate_Cobj := MainRecordByEditorID(cobjGroup, 'SS2_COBJ_Foundation_Concrete_2x2'); // SS2_COBJ_Foundation_Concrete_2x2

        foundationTemplate := MainRecordByEditorID(miscGroup, 'SS2_PlotFoundation_1x1_Concrete');

        terraformerTemplate_Block_1x1  := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock1x1_Dirt');
        terraformerTemplate_Corner_1x1 := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock1x1_Dirt_Corner');
        terraformerTemplate_Edge_1x1   := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock1x1_Dirt_Edge');

        terraformerTemplate_Block_2x2   := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt');
        terraformerTemplate_Corner_2x2  := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt_Corner');
        terraformerTemplate_Edge_2x2    := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt_Edge');
        terraformerTemplate_LPiece_2x2  := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock2x2_Dirt_LPiece');

        terraformerTemplate_Block_3x3   := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock3x3_Dirt');
        terraformerTemplate_Corner_3x3  := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock3x3_Dirt_Corner');
        terraformerTemplate_Edge_3x3  := MainRecordByEditorID(actiGroup, 'SS2_Foundation_TerraformBlock3x3_Dirt_Edge');

        //terraformerTemplate_1x1 := MainRecordByEditorID(staticGroup, 'SS2_PlotFoundation_1x1_Terraformer_Dirt');
        //terraformerTemplate_2x2 := MainRecordByEditorID(staticGroup, 'SS2_PlotFoundation_2x2_Terraformer_Dirt');
        //terraformerTemplate_3x3 := MainRecordByEditorID(staticGroup, 'SS2_PlotFoundation_3x3_Terraformer_Dirt');

        globalNewFormPrefix := '';
        globalAddonName := '';

        SS2_Tag_ManagementDesk := MainRecordByEditorID(kywdGroup, 'SS2_Tag_ManagementDesk');
        SS2_Workbench_CityPlannersDesk := MainRecordByEditorID(kywdGroup, 'SS2_Workbench_CityPlannersDesk');
        WSFW_DoNotAutoassign := MainRecordByEditorID(GroupBySignature(wsfrMasterFile, 'KYWD'), 'WSFW_DoNotAutoassign');

        deskBaseCobj := MainRecordByEditorID(cobjGroup, 'SS2_co_CityPlannerDesk'); //SS2_co_CityPlannerDesk
        packedDeskBaseCobj := MainRecordByEditorID(cobjGroup, 'kgSIM_co_CityPlannerDesk_Packed'); //kgSIM_co_CityPlannerDesk_Packed

        keywordTemplate := MainRecordByEditorID(kywdGroup, 'SS2_Tag_CityPlan');
        // TYPES
        // skintypes
        SS2_FLID_Skins_Agricultural_1x1 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Agricultural_1x1');
        SS2_FLID_Skins_Agricultural_2x2 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Agricultural_2x2');
        SS2_FLID_Skins_Agricultural_3x3 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Agricultural_3x3');
        SS2_FLID_Skins_Agricultural_Int := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Agricultural_Int');
        SS2_FLID_Skins_Commercial_1x1   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Commercial_1x1');
        SS2_FLID_Skins_Commercial_2x2   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Commercial_2x2');
        SS2_FLID_Skins_Commercial_3x3   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Commercial_3x3');
        SS2_FLID_Skins_Commercial_Int   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Commercial_Int');
        SS2_FLID_Skins_Industrial_1x1   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Industrial_1x1');
        SS2_FLID_Skins_Industrial_2x2   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Industrial_2x2');
        SS2_FLID_Skins_Industrial_3x3   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Industrial_3x3');
        SS2_FLID_Skins_Industrial_Int   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Industrial_Int');
        SS2_FLID_Skins_Martial_1x1      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Martial_1x1');
        SS2_FLID_Skins_Martial_2x2      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Martial_2x2');
        SS2_FLID_Skins_Martial_3x3      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Martial_3x3');
        SS2_FLID_Skins_Martial_Int      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Martial_Int');
        SS2_FLID_Skins_Municipal_1x1    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Municipal_1x1');
        SS2_FLID_Skins_Municipal_2x2    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Municipal_2x2');
        SS2_FLID_Skins_Municipal_3x3    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Municipal_3x3');
        SS2_FLID_Skins_Municipal_Int    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Municipal_Int');
        SS2_FLID_Skins_Recreational_1x1 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Recreational_1x1');
        SS2_FLID_Skins_Recreational_2x2 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Recreational_2x2');
        SS2_FLID_Skins_Recreational_3x3 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Recreational_3x3');
        SS2_FLID_Skins_Recreational_Int := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Recreational_Int');
        SS2_FLID_Skins_Residential_1x1  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Residential_1x1');
        SS2_FLID_Skins_Residential_2x2  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Residential_2x2');
        SS2_FLID_Skins_Residential_3x3  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Residential_3x3');
        SS2_FLID_Skins_Residential_Int  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Skins_Residential_Int');

        // buidplantypes
        SS2_FLID_BuildingPlans_Agricultural_1x1 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Agricultural_1x1');
        SS2_FLID_BuildingPlans_Agricultural_2x2 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Agricultural_2x2');
        SS2_FLID_BuildingPlans_Agricultural_3x3 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Agricultural_3x3');
        SS2_FLID_BuildingPlans_Agricultural_Int := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Agricultural_Int');
        SS2_FLID_BuildingPlans_Commercial_1x1   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Commercial_1x1');
        SS2_FLID_BuildingPlans_Commercial_2x2   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Commercial_2x2');
        SS2_FLID_BuildingPlans_Commercial_3x3   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Commercial_3x3');
        SS2_FLID_BuildingPlans_Commercial_Int   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Commercial_Int');
        SS2_FLID_BuildingPlans_Industrial_1x1   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Industrial_1x1');
        SS2_FLID_BuildingPlans_Industrial_2x2   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Industrial_2x2');
        SS2_FLID_BuildingPlans_Industrial_3x3   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Industrial_3x3');
        SS2_FLID_BuildingPlans_Industrial_Int   := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Industrial_Int');
        SS2_FLID_BuildingPlans_Martial_1x1      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Martial_1x1');
        SS2_FLID_BuildingPlans_Martial_2x2      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Martial_2x2');
        SS2_FLID_BuildingPlans_Martial_3x3      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Martial_3x3');
        SS2_FLID_BuildingPlans_Martial_Int      := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Martial_Int');
        SS2_FLID_BuildingPlans_Municipal_1x1    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Municipal_1x1');
        SS2_FLID_BuildingPlans_Municipal_2x2    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Municipal_2x2');
        SS2_FLID_BuildingPlans_Municipal_3x3    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Municipal_3x3');
        SS2_FLID_BuildingPlans_Municipal_Int    := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Municipal_Int');
        SS2_FLID_BuildingPlans_Recreational_1x1 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Recreational_1x1');
        SS2_FLID_BuildingPlans_Recreational_2x2 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Recreational_2x2');
        SS2_FLID_BuildingPlans_Recreational_3x3 := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Recreational_3x3');
        SS2_FLID_BuildingPlans_Recreational_Int := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Recreational_Int');
        SS2_FLID_BuildingPlans_Residential_1x1  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Residential_1x1');
        SS2_FLID_BuildingPlans_Residential_2x2  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Residential_2x2');
        SS2_FLID_BuildingPlans_Residential_3x3  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Residential_3x3');
        SS2_FLID_BuildingPlans_Residential_Int  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_BuildingPlans_Residential_Int');

        SS2_FLID_CityPlans  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_CityPlans');
        SS2_FLID_FurnitureStoreItems  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_FurnitureStoreItems');
        SS2_FLID_ThemeDefinitions_Flags  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_ThemeDefinitions_Flags');

        SS2_FLID_Unlockables  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_Unlockables');

        SS2_FLID_1x1_Foundations  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_1x1_Foundations');
        SS2_FLID_2x2_Foundations  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_2x2_Foundations');
        SS2_FLID_3x3_Foundations  := MainRecordByEditorID(kywdGroup, 'SS2_FLID_3x3_Foundations');

        // subtypes
        SS2_PlotTypeSubClass_Agricultural_Advanced                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Agricultural_Advanced');
        SS2_PlotTypeSubClass_Agricultural_Default_Basic                 := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Agricultural_Default_Basic');
        SS2_PlotTypeSubClass_Agricultural_HighTech                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Agricultural_HighTech');
        SS2_PlotTypeSubClass_Commercial_ArmorStore                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_ArmorStore');
        SS2_PlotTypeSubClass_Commercial_Bar                             := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_Bar');
        SS2_PlotTypeSubClass_Commercial_Beauty                          := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_Beauty');
        SS2_PlotTypeSubClass_Commercial_Bookstore                       := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_Bookstore');
        SS2_PlotTypeSubClass_Commercial_Clinic                          := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_Clinic');
        SS2_PlotTypeSubClass_Commercial_ClothingStore                   := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_ClothingStore');
        SS2_PlotTypeSubClass_Commercial_Default_Other                   := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_Default_Other');
        SS2_PlotTypeSubClass_Commercial_FurnitureStore                  := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_FurnitureStore');
        SS2_PlotTypeSubClass_Commercial_GeneralStore                    := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_GeneralStore');
        SS2_PlotTypeSubClass_Commercial_PowerArmorStore                 := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_PowerArmorStore');
        SS2_PlotTypeSubClass_Commercial_WeaponsStore                    := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_WeaponsStore');
        SS2_PlotTypeSubClass_Commercial_PetStore                        := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Commercial_PetStore');
        SS2_PlotTypeSubClass_Industrial_BuildingMaterials               := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Industrial_BuildingMaterials');
        SS2_PlotTypeSubClass_Industrial_Default_General                 := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Industrial_Default_General');
        SS2_PlotTypeSubClass_Industrial_MachineParts                    := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Industrial_MachineParts');
        SS2_PlotTypeSubClass_Industrial_OrganicMaterials                := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Industrial_OrganicMaterials');
        SS2_PlotTypeSubClass_Industrial_RareMaterials                   := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Industrial_RareMaterials');
        SS2_PlotTypeSubClass_Industrial_Conversion                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Industrial_Conversion');
        SS2_PlotTypeSubClass_Industrial_Production                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Industrial_Production');



        SS2_PlotTypeSubClass_Martial_Advanced                           := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_Advanced');
        SS2_PlotTypeSubClass_Martial_Default_Basic                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_Default_Basic');
        SS2_PlotTypeSubClass_Martial_HighTech                           := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_HighTech');
        SS2_PlotTypeSubClass_Martial_OutpostType_Armory                 := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_OutpostType_Armory');
        SS2_PlotTypeSubClass_Martial_OutpostType_BattlefieldScavengers  := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_OutpostType_BattlefieldScavengers');
        // SS2_PlotTypeSubClass_Martial_OutpostType_FieldHospital          := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_OutpostType_FieldHospital');
        SS2_PlotTypeSubClass_Martial_OutpostType_Prison                 := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_OutpostType_Prison');
        SS2_PlotTypeSubClass_Martial_OutpostType_RecruitmentCenter      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_OutpostType_RecruitmentCenter');
        SS2_PlotTypeSubClass_Martial_OutpostType_WatchTower             := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Martial_OutpostType_WatchTower');
        SS2_PlotTypeSubClass_Municipal_CaravanServices                  := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_CaravanServices');
        SS2_PlotTypeSubClass_Municipal_CommunicationStation             := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_Communications');
        SS2_PlotTypeSubClass_Municipal_Default_Other                    := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_Default_Other');
        SS2_PlotTypeSubClass_Municipal_PowerPlant_Advanced              := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_PowerPlant_Advanced');
        SS2_PlotTypeSubClass_Municipal_PowerPlant_Basic                 := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_PowerPlant_Basic');
        SS2_PlotTypeSubClass_Municipal_PowerPlant_HighTech              := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_PowerPlant_HighTech');
        SS2_PlotTypeSubClass_Municipal_PowerTransfer                    := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_PowerTransfer');
        SS2_PlotTypeSubClass_Municipal_TaxServices                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_TaxServices');
        SS2_PlotTypeSubClass_Municipal_WaterPlant_Advanced              := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_WaterPlant_Advanced');
        SS2_PlotTypeSubClass_Municipal_WaterPlant_Basic                 := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_WaterPlant_Basic');
        SS2_PlotTypeSubClass_Municipal_WaterPlant_HighTech              := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Municipal_WaterPlant_HighTech');
        SS2_PlotTypeSubClass_Recreational_AgilityTraining               := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_AgilityTraining');
        SS2_PlotTypeSubClass_Recreational_Cemetery                      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_Cemetery');
        SS2_PlotTypeSubClass_Recreational_CharismaTraining              := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_CharismaTraining');
        SS2_PlotTypeSubClass_Recreational_Default_Relaxation            := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_Default_Relaxation');
        SS2_PlotTypeSubClass_Recreational_EnduranceTraining             := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_EnduranceTraining');
        SS2_PlotTypeSubClass_Recreational_IntelligenceTraining          := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_IntelligenceTraining');
        SS2_PlotTypeSubClass_Recreational_LuckTraining                  := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_LuckTraining');
        SS2_PlotTypeSubClass_Recreational_OutpostType_MessHall          := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_OutpostType_MessHall');
        SS2_PlotTypeSubClass_Recreational_OutpostType_TrainingYard      := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_OutpostType_TrainingYard');
        SS2_PlotTypeSubClass_Recreational_PerceptionTraining            := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_PerceptionTraining');
        SS2_PlotTypeSubClass_Recreational_StrengthTraining              := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Recreational_StrengthTraining');
        SS2_PlotTypeSubClass_Residential_Default_SinglePerson           := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Residential_Default_SinglePerson');
        SS2_PlotTypeSubClass_Residential_MultiPerson                    := MainRecordByEditorID(kywdGroup, 'SS2_PlotTypeSubClass_Residential_MultiPerson');

        initPlotTypes();

        loadThemeTags();

        hasSelectedThemes := false;

        allBuildingPlansCache := nil;
        selectedThemeTagList := nil;

        hardcodedEdidMappingKeys   := TStringList.create;
        hardcodedEdidMappingValues := TStringList.create;

        registerHardcodedSSTranslation('kgSIM_SettingsHolotape_MainMenu', 'SS2_CityManager_MainMenu');
        registerHardcodedSSTranslation('kgSIM_FlagSelector', 'SS2_CityPlannerDeskObject_FlagSelector');

        validMastersList := TSTringList.create;
        validMastersList.Duplicates := dupIgnore;
        validMastersList.CaseSensitive := false;
    end;

    procedure cleanupSS2Lib();
    begin
		saveMiscsToCache();
        validMastersList.free();
        plotTypeNames.free();
        //plotTypeNamesShort.free();

        plotSizeNames.free();
        plotSubtypeNames.free();
        plotSubtypeMapping.free();

        hardcodedEdidMappingKeys.free();
        hardcodedEdidMappingValues.free();

        //if(miscItemCache <> nil) then begin
            //miscItemCache.free();
        //end;
{
        if(miscItemLookupTable <> nil) then begin
            miscItemLookupTable.free();
        end;

		if(spawnMiscData <> nil) then begin
			spawnMiscData.free();
		end;
		}

        themeTagList.free();

        if(selectedThemeTagList <> nil) then begin
            selectedThemeTagList.free();
        end;

        if(allBuildingPlansCache <> nil) then begin
            allBuildingPlansCache.free();
        end;
    end;


    procedure initPlotTypes();
    var
        stArr_agr,
        stArr_com,
        stArr_ind,
        stArr_mar,
        stArr_mun,
        stArr_rec,
        stArr_res: TJsonArray;
    begin
        plotTypeNames := TStringList.create;
        //plotTypeNamesShort := TStringList.create;
        plotSizeNames := TStringList.create;
        plotSubtypeNames := TStringList.create;
        plotSubtypeMapping := TJsonObject.create();

        SIZE_1x1 := plotSizeNames.add('1x1');
        SIZE_2x2 := plotSizeNames.add('2x2');
        SIZE_3x3 := plotSizeNames.add('3x3');
        SIZE_INT := plotSizeNames.add('Interior');

        PLOT_TYPE_AGR := plotTypeNames.add('Agricultural');
        PLOT_TYPE_COM := plotTypeNames.add('Commercial');
        PLOT_TYPE_IND := plotTypeNames.add('Industrial');
        PLOT_TYPE_MAR := plotTypeNames.add('Martial');
        PLOT_TYPE_MUN := plotTypeNames.add('Municipial');
        PLOT_TYPE_REC := plotTypeNames.add('Recreational');
        PLOT_TYPE_RES := plotTypeNames.add('Residential');

        //plotTypeNamesShort.insert(

        stArr_agr := plotSubtypeMapping.A[PLOT_TYPE_AGR];
        stArr_com := plotSubtypeMapping.A[PLOT_TYPE_COM];
        stArr_ind := plotSubtypeMapping.A[PLOT_TYPE_IND];
        stArr_mar := plotSubtypeMapping.A[PLOT_TYPE_MAR];
        stArr_mun := plotSubtypeMapping.A[PLOT_TYPE_MUN];
        stArr_rec := plotSubtypeMapping.A[PLOT_TYPE_REC];
        stArr_res := plotSubtypeMapping.A[PLOT_TYPE_RES];

        // agricultural
        PLOT_SC_AGR_Default_Basic   := plotSubtypeNames.add('Default/Basic Farm');
        PLOT_SC_AGR_Advanced        := plotSubtypeNames.add('Advanced Farm');
        PLOT_SC_AGR_HighTech        := plotSubtypeNames.add('High-Tech Farm');
        // commercial
        PLOT_SC_COM_Default_Other   := plotSubtypeNames.add('Default/Other Store');
        PLOT_SC_COM_ArmorStore      := plotSubtypeNames.add('Armor Store');
        PLOT_SC_COM_Bar             := plotSubtypeNames.add('Bar');
        PLOT_SC_COM_Beauty          := plotSubtypeNames.add('Beauty');
        PLOT_SC_COM_Bookstore       := plotSubtypeNames.add('Book Store');
        PLOT_SC_COM_Clinic          := plotSubtypeNames.add('Clinic');
        PLOT_SC_COM_ClothingStore   := plotSubtypeNames.add('Clothing Store');
        PLOT_SC_COM_FurnitureStore  := plotSubtypeNames.add('Furniture Store');
        PLOT_SC_COM_GeneralStore    := plotSubtypeNames.add('General Store');
        PLOT_SC_COM_PowerArmorStore := plotSubtypeNames.add('Power Armor Store');
        PLOT_SC_COM_WeaponsStore    := plotSubtypeNames.add('Weapon Store');
        PLOT_SC_COM_PetStore        := plotSubtypeNames.add('Pet Store');
        // industrial
        PLOT_SC_IND_Default_General     := plotSubtypeNames.add('Default/General Factory');
        PLOT_SC_IND_BuildingMaterials   := plotSubtypeNames.add('Building Materials');
        PLOT_SC_IND_MachineParts        := plotSubtypeNames.add('Machine Parts');
        PLOT_SC_IND_OrganicMaterials    := plotSubtypeNames.add('Organic Materials');
        PLOT_SC_IND_RareMaterials       := plotSubtypeNames.add('Rare Materials');
        PLOT_SC_IND_Conversion          := plotSubtypeNames.add('Conversion');
        PLOT_SC_IND_Production          := plotSubtypeNames.add('Production');
        // martial
        PLOT_SC_MAR_Default_Basic                       := plotSubtypeNames.add('Default/Basic Martial');
        PLOT_SC_MAR_Advanced                            := plotSubtypeNames.add('Advanced Martial');
        PLOT_SC_MAR_HighTech                            := plotSubtypeNames.add('High-Tech Martial');

        // municipial
        PLOT_SC_MUN_Default_Other           := plotSubtypeNames.add('Default/Other Municipial');
        PLOT_SC_MUN_CaravanServices         := plotSubtypeNames.add('Caravan Services');
        PLOT_SC_MUN_CommunicationsStation   := plotSubtypeNames.add('Communications Station');
        PLOT_SC_MUN_PowerPlant_Basic        := plotSubtypeNames.add('Powerplant (Basic)');
        PLOT_SC_MUN_PowerPlant_Advanced     := plotSubtypeNames.add('Powerplant (Advanced)');
        PLOT_SC_MUN_PowerPlant_HighTech     := plotSubtypeNames.add('Powerplant (High-Tech)');
        PLOT_SC_MUN_PowerTransfer           := plotSubtypeNames.add('Power Transfer');
        PLOT_SC_MUN_TaxServices             := plotSubtypeNames.add('Tax Services');
        PLOT_SC_MUN_WaterPlant_Basic        := plotSubtypeNames.add('Waterplant (Basic)');
        PLOT_SC_MUN_WaterPlant_Advanced     := plotSubtypeNames.add('Waterplant (Advanced)');
        PLOT_SC_MUN_WaterPlant_HighTech     := plotSubtypeNames.add('Waterplant (High-Tech)');
        // recreational
        PLOT_SC_REC_Default_Relaxation          := plotSubtypeNames.add('Default Relaxation');
        PLOT_SC_REC_Cemetery                    := plotSubtypeNames.add('Cemetery');

        PLOT_SC_REC_StrengthTraining            := plotSubtypeNames.add('Training (Strength)');
        PLOT_SC_REC_PerceptionTraining          := plotSubtypeNames.add('Training (Perception)');
        PLOT_SC_REC_EnduranceTraining           := plotSubtypeNames.add('Training (Endurance)');
        PLOT_SC_REC_CharismaTraining            := plotSubtypeNames.add('Training (Charisma)');
        PLOT_SC_REC_IntelligenceTraining        := plotSubtypeNames.add('Training (Intelligence)');
        PLOT_SC_REC_AgilityTraining             := plotSubtypeNames.add('Training (Agility)');
        PLOT_SC_REC_LuckTraining                := plotSubtypeNames.add('Training (Luck)');
        // residential
        PLOT_SC_RES_Default_SinglePerson    := plotSubtypeNames.add('Default Single-Person Home');
        PLOT_SC_RES_MultiPerson             := plotSubtypeNames.add('Multi-Person Home');

        if(enableOutpostSubtype) then begin
            // martial
            PLOT_SC_MAR_OutpostType_Armory                  := plotSubtypeNames.add('Armory');
            PLOT_SC_MAR_OutpostType_BattlefieldScavengers   := plotSubtypeNames.add('Battlefield Scavengers');
            PLOT_SC_MAR_OutpostType_FieldSurgeon            := plotSubtypeNames.add('Field Surgeon');
            PLOT_SC_MAR_OutpostType_Prison                  := plotSubtypeNames.add('Prison');
            PLOT_SC_MAR_OutpostType_RecruitmentCenter       := plotSubtypeNames.add('Recruitment Center');
            PLOT_SC_MAR_OutpostType_WatchTower              := plotSubtypeNames.add('Watchtower');

            // recreational
            PLOT_SC_REC_OutpostType_MessHall        := plotSubtypeNames.add('Outpost Mess Hall');
            PLOT_SC_REC_OutpostType_TrainingYard    := plotSubtypeNames.add('Outpost Training Yard');
        end;


        stArr_agr.add(PLOT_SC_AGR_Default_Basic);
        stArr_agr.add(PLOT_SC_AGR_Advanced);
        stArr_agr.add(PLOT_SC_AGR_HighTech);

        stArr_com.add(PLOT_SC_COM_Default_Other);
        stArr_com.add(PLOT_SC_COM_ArmorStore);
        stArr_com.add(PLOT_SC_COM_Bar);
        stArr_com.add(PLOT_SC_COM_Beauty);
        stArr_com.add(PLOT_SC_COM_Bookstore);
        stArr_com.add(PLOT_SC_COM_Clinic);
        stArr_com.add(PLOT_SC_COM_ClothingStore);
        stArr_com.add(PLOT_SC_COM_FurnitureStore);
        stArr_com.add(PLOT_SC_COM_GeneralStore);
        stArr_com.add(PLOT_SC_COM_PowerArmorStore);
        stArr_com.add(PLOT_SC_COM_WeaponsStore);
        stArr_com.add(PLOT_SC_COM_PetStore);

        stArr_ind.add(PLOT_SC_IND_Default_General);
        stArr_ind.add(PLOT_SC_IND_BuildingMaterials);
        stArr_ind.add(PLOT_SC_IND_MachineParts);
        stArr_ind.add(PLOT_SC_IND_OrganicMaterials);
        stArr_ind.add(PLOT_SC_IND_RareMaterials);
        stArr_ind.add(PLOT_SC_IND_Conversion);
        stArr_ind.add(PLOT_SC_IND_Production);

        stArr_mar.add(PLOT_SC_MAR_Default_Basic);
        stArr_mar.add(PLOT_SC_MAR_Advanced);
        stArr_mar.add(PLOT_SC_MAR_HighTech);

        stArr_mun.add(PLOT_SC_MUN_Default_Other);
        stArr_mun.add(PLOT_SC_MUN_CaravanServices);
        stArr_mun.add(PLOT_SC_MUN_CommunicationsStation);
        stArr_mun.add(PLOT_SC_MUN_PowerPlant_Basic);
        stArr_mun.add(PLOT_SC_MUN_PowerPlant_Advanced);
        stArr_mun.add(PLOT_SC_MUN_PowerPlant_HighTech);
        stArr_mun.add(PLOT_SC_MUN_PowerTransfer);
        stArr_mun.add(PLOT_SC_MUN_TaxServices);
        stArr_mun.add(PLOT_SC_MUN_WaterPlant_Basic);
        stArr_mun.add(PLOT_SC_MUN_WaterPlant_Advanced);
        stArr_mun.add(PLOT_SC_MUN_WaterPlant_HighTech);

        stArr_rec.add(PLOT_SC_REC_Default_Relaxation);
        stArr_rec.add(PLOT_SC_REC_Cemetery);

        stArr_rec.add(PLOT_SC_REC_StrengthTraining);
        stArr_rec.add(PLOT_SC_REC_PerceptionTraining);
        stArr_rec.add(PLOT_SC_REC_EnduranceTraining);
        stArr_rec.add(PLOT_SC_REC_CharismaTraining);
        stArr_rec.add(PLOT_SC_REC_IntelligenceTraining);
        stArr_rec.add(PLOT_SC_REC_AgilityTraining);
        stArr_rec.add(PLOT_SC_REC_LuckTraining);

        stArr_res.add(PLOT_SC_RES_Default_SinglePerson);
        stArr_res.add(PLOT_SC_RES_MultiPerson);

        if(enableOutpostSubtype) then begin
            stArr_mar.add(PLOT_SC_MAR_OutpostType_Armory);
            stArr_mar.add(PLOT_SC_MAR_OutpostType_BattlefieldScavengers);
            stArr_mar.add(PLOT_SC_MAR_OutpostType_FieldSurgeon);
            stArr_mar.add(PLOT_SC_MAR_OutpostType_Prison);
            stArr_mar.add(PLOT_SC_MAR_OutpostType_RecruitmentCenter);
            stArr_mar.add(PLOT_SC_MAR_OutpostType_WatchTower);

            stArr_rec.add(PLOT_SC_REC_OutpostType_MessHall);
            stArr_rec.add(PLOT_SC_REC_OutpostType_TrainingYard);
        end;
    end;



    function getPlotShortName(mainType: integer): string;
    begin
        Result := copy(plotTypeNames[mainType], 1, 3);
    end;

    {
        Test whenever elem is an override which could be used instead of making a new one
    }
    function isValidOverride(targetFile, elem): boolean;
    var
        elemFile: IInterface;
    begin
        Result := false;
        if(not assigned(elem)) then begin
            exit;
        end;
        elemFile := GetFile(elem);

        Result := FilesEqual(targetFile, elemFile);
    end;

    {
        Creates a copy of the given template with the given edid, if it doesn't exist. If it does, the existing record is returned
    }
    function getCopyOfTemplate(targetFile, template: IInterface; newEdid: string): IInterface;
    var
        group, newElem: IInterface;
        tmpEdid, templateSig: string;
        i: integer;
        isAssignedWat: boolean;
    begin
        templateSig := signature(template);
        if(templateSig = '') then begin
            AddMessage('=== COULD NOT COPY TEMPLATE FOR '+newEdid+'. THIS IS VERY BAD ===');
            // dumpElem(template);
            exit;
        end;

        // before doing anything else, see if this edid is used already
        newElem := FindObjectInFileByEdid(targetFile, newEdid);
        if(assigned(newElem)) then begin
            Result := newElem;
            exit;
        end;
        //i := 1;


        if(tmpEdid <> '') then begin
            newEdid := tmpEdid;
        end;

        // AddMessage('New Edid: '+newEdid);

{
        group := GroupBySignature(targetFile, templateSig);

        if(not assigned(group)) then begin
            group := Add(targetFile, templateSig, True);
        end;

        newElem := MainRecordByEditorID(group, newEdid);
}
        if(not assigned(newElem)) then begin
            addRequiredMastersSilent(template, targetFile);

            newElem := wbCopyElementToFile(template, targetFile, true, true);
            SetElementEditValues(newElem, 'EDID', newEdid);
        end;

        Result := newElem;

    end;

    // function is

    {
        Tries to find the adodn quest in targetFile. Does not auto-create it
    }
    function findAddonQuest(targetFile: IInterface; edid: string): IInterface;
    var
        fallbackQuest, fallbackQuestScipt, curQuest, questScript, questGroup, scripts, curScript, addonConfig, addonScript: IInterface;
        i, j: integer;
        curScriptName, curSGEFlag: string;
        vendorDefInFB, vendorDefInCur: boolean;
    begin
        if(assigned(currentAddonQuest)) then begin
            Result := currentAddonQuest;
            exit;
        end;

        Result := nil;
        questGroup := GroupBySignature(targetFile, 'QUST');
        if(not assigned(questGroup)) then begin
            exit;
        end;
        curQuest := MainRecordByEditorID(questGroup, edid);

        if(assigned(curQuest)) then begin
            Result := curQuest;
            exit;
        end;
        AddMessage('Trying to find the AddonQuest');

        for i:=0 to ElementCount(questGroup)-1 do begin
            curQuest := ElementByIndex(questGroup, i);
            AddMessage('Checking '+EditorID(curQuest));

            scripts := ElementByPath(curQuest, 'VMAD - Virtual Machine Adapter\Scripts');
            for j := 0 to ElementCount(scripts)-1 do begin
                curScript := ElementByIndex(scripts, j);
                curScriptName := LowerCase(geevt(curScript, 'scriptName'));

                if(curScriptName = 'simsettlementsv2:quests:addonpack') then begin
                    // yes
                    Result := curQuest;
                    currentAddonQuest := Result;
                    exit;
                end;

                // otherwise check alternatives
                // fallbackQuest
                curSGEFlag := GetElementEditValues(curQuest, 'DNAM\Flags\Start Game Enabled');

                if(curSGEFlag = '1') then begin

                    addonConfig := getScriptProp(curScript, 'MyAddonConfig');
                    if (assigned(addonConfig)) then begin

                        addonScript := getScript(addonConfig, 'SimSettlementsV2:MiscObjects:AddonPackConfiguration');
                        if(assigned(addonScript)) then begin
                            AddMessage('Found potential custom AddonQuest in '+EditorID(curQuest)+'::'+curScriptName);

                            if (assigned(fallbackQuest)) then begin
                                // check which is more likely
                                // CustomVendorDefinitions
                                vendorDefInCur := assigned(getScriptProp(curScript, 'CustomVendorDefinitions'));
                                vendorDefInFB := assigned(getScriptProp(fallbackQuestScipt, 'CustomVendorDefinitions'));

                                if (vendorDefInCur and (not vendorDefInFB)) then begin
                                    AddMessage('This seems to be more likely AddonQuest: '+EditorID(curQuest)+'::'+curScriptName);
                                end;

                            end else begin
                                fallbackQuest      := curQuest;
                                fallbackQuestScipt := curScript;
                            end;
                        end;
                    end;
                end;
            end;
        end;

        if(assigned(fallbackQuest)) then begin
            AddMessage('Assuming '+EditorID(fallbackQuest)+' is the addon quest');
        end;


        currentAddonQuest  := fallbackQuest;
        currentAddonConfig := addonScript;
        // currentAddonQuestScriptName := geevt(curScript, 'scriptName');
        Result := fallbackQuest;
    end;


    {
        Gets or creates the script of the addon's MISC configuration item, creating the MISC and the quest itself in the process, if necessary
    }
    function getAddonConfigScript(targetFile: IInterface): IInterface;
    var
        versionGlobal: IInterface;
        addonQuest, addonMisc, questScript: IInterface;
        questEdid: string;
    begin
        if (assigned(currentAddonConfig)) then begin
            Result := getScript(currentAddonConfig, 'SimSettlementsV2:MiscObjects:AddonPackConfiguration');
            exit;
        end;

        // currentAddonQuest, currentAddonConfig: IInterface;
        // try finding it
        questEdid := generateEdid('', addonQuestSuffix);
        addonQuest := findAddonQuest(targetFile, questEdid);
        // findAddonQuest might have found the config
        if (assigned(currentAddonConfig) and assigned(addonQuest)) then begin
            Result := getScript(currentAddonConfig, 'SimSettlementsV2:MiscObjects:AddonPackConfiguration');
            exit;
        end;


        if(not assigned(addonQuest)) then begin
            // make it
            addonQuest := getCopyOfTemplate(targetFile, addonQuestTemplate, questEdid);
            if(globalAddonName <> '') then begin
                SetElementEditValues(addonQuest, 'FULL', globalAddonName+' Quest');
            end;

            // make sure it has NO MyAddonConfig
            questScript := getScript(addonQuest, 'SimSettlementsV2:Quests:AddonPack');
            deleteScriptProp(questScript, 'MyAddonConfig');
            //deleteScriptProps();
        end;

        if(not assigned(questScript)) then begin
            questScript := getScript(addonQuest, 'SimSettlementsV2:Quests:AddonPack');
        end;

        addonMisc := getScriptProp(questScript, 'MyAddonConfig');

        if(not assigned(addonMisc)) then begin
            addonMisc := getCopyOfTemplate(targetFile, addonDataTemplate, generateEdid('', addonDataSuffix));

            if(globalAddonName <> '') then begin
                SetElementEditValues(addonMisc, 'FULL', globalAddonName+' Config');
            end;

            // put it into the quest
            setScriptProp(questScript, 'MyAddonConfig', addonMisc);
        end;

        currentAddonConfig := addonMisc;
        Result := getScript(addonMisc, 'SimSettlementsV2:MiscObjects:AddonPackConfiguration');

        // make sure the version global is set
        versionGlobal := getScriptProp(Result, 'MyVersionNumber');

        if(not assigned(versionGlobal)) then begin
            versionGlobal := getCopyOfTemplate(targetFile, versionGlobalTemplate, generateEdid('', addonVersionSuffix));
            // reset it to 1
            SetElementEditValues(versionGlobal, 'FLTV', '1.000000');

            setScriptProp(Result, 'MyVersionNumber', versionGlobal);
        end;

        // also put the current filename into the config
        setScriptProp(Result, 'sAddonFilename', GetFileName(targetFile));

    end;

    {
        Attempts to find a "tag" at the start of the given name
    }
    function extactUserTagFromName(objectName: string): string;
    var
        tmp, c, closingChar: string;
        openChars, closeChars: string;
        startCharIndex, closeCharPos: integer;
    begin
        tmp := objectName;
        c := tmp[1];
        openChars := tagOpenChars;
        closeChars := tagCloseChars;

        startCharIndex := Pos(c, openChars);
        if(startCharIndex = 0) then begin
            Result := '';
            exit;
        end;

        closingChar := closeChars[startCharIndex];
        closeCharPos := Pos(closingChar, objectName);

        Result := copy(objectName, 0, closeCharPos);
        // Result := (c = '[') or (c = ']') or (c = '|') or (c = '{') or (c = '}') or (c = '(') or (c = ')');
    end;

    function getStackEnabledFormList(targetFile: IInterface): IInterface;
    var
        formlistEdid, cobjEdid, sig: string;
        group, newElem: IInterface;
        targetCobj, targetFlst: IInterface;
    begin
        if(assigned(stackedFormlistCache)) then begin
            Result := stackedFormlistCache;
            exit;
        end;
        //stackedFormlistCache: IInterface;

        sig := 'FLST';
        formlistEdid := globalNewFormPrefix + stackEnableFlstBase;
        group := GroupBySignature(targetFile, sig);

        if(not assigned(group)) then begin
            group := Add(targetFile, sig, True);
        end;

        targetFlst := MainRecordByEditorID(group, formlistEdid);

        if(not assigned(targetFlst)) then begin
            targetFlst := Add(group, sig, true);
            if(not assigned(targetFlst)) then begin
                targetFlst := Add(group, sig, true); // stolen from dubhFunctions
            end;
            SetElementEditValues(targetFlst, 'EDID', formlistEdid);

            // in this case, also create and setup the COBJcobjEdid
            cobjEdid := globalNewFormPrefix + stackEnableCobjBase;
            // targetCobj := getElemByEdidAndSig(cobjEdid, 'COBJ', targetFile);
            targetCobj := getCopyOfTemplate(targetFile, stackingCobjTemplate, cobjEdid);

            setPathLinksTo(targetCobj, 'CNAM', targetFlst);
        end;

        stackedFormlistCache := targetFlst;
        Result := targetFlst;
    end;

    procedure addToStackEnabledList(targetFile, model: IInterface);
    var
        formlistEdid, cobjEdid: string;
        targetCobj, targetFlst: IInterface;
    begin
        formlistEdid := globalNewFormPrefix + stackEnableFlstBase;
        cobjEdid     := globalNewFormPrefix + stackEnableCobjBase;

        targetFlst := getStackEnabledFormList(targetFile);
        addToFormlist(targetFlst, model);
        // SS2_co_StackEnable_SS
        // curFlst := getElemByEdidAndSig(formListEdid, 'FLST', targetFile);
        // stackingCobjTemplate
        // stackEnableFlstBase = 'EnableStackedParenting_';
		// stackEnableCobjBase = 'co_StackEnable_';
    end;

    {
        Registers content with the addon quest in targetFile, using keyword as the identifier
    }
    procedure registerAddonContent(targetFile, content, keyword: IInterface);
    var
        miscScript, itemsArray, itemsArrayValue, curFlst, curKw: IInterface;
        i: integer;
        formlistEdid: string;
    begin
        if(GetFileName(targetFile) = 'SS2.esm') then begin
            exit;
        end;

        if(not assigned(keyword)) then begin
            AddMessage('Cannot register content! Keywort not assigned!');
            exit;
        end;

        if(not assigned(targetFile)) then begin
            AddMessage('Cannot register content! TargetFile not assigned!');
            exit;
        end;

        if(not assigned(content)) then begin
            exit;
        end;

        miscScript := getAddonConfigScript(targetFile);

        itemsArray := getOrCreateScriptProp(miscScript, 'MyItems', 'Array of Object');

        itemsArrayValue := ElementByPath(itemsArray, 'Value\Array of Object');

        if(assigned(itemsArrayValue)) then begin
            // iterate it
            for i:=0 to ElementCount(itemsArrayValue) do begin

                curFlst := LinksTo(ElementByPath(ElementByIndex(itemsArrayValue, i), 'Object v2\FormID'));
                curKw := getFormListEntry(curFlst, 0);
                if(isSameForm(curKw, keyword)) then begin
                    addToFormlist(curFlst, content);
                    exit;
                end;
            end;
        end;

        // otherwise make a new flst
        formlistEdid := generateEdid(addonItemsFlstPrefix, stripPrefix('SS2_FLID_', EditorID(keyword)));
        curFlst := getElemByEdidAndSig(formListEdid, 'FLST', targetFile);

        addToFormlist(curFlst, keyword);
        addToFormlist(curFlst, content);

        // append it to the items
        appendObjectToProperty(itemsArray, curFlst);
    end;

    function getDefaultBuildingPlanList(plotType: integer): IInterface;
    var
        mainType, size: integer;
        flstEdid, mainTypePart, sizePart: string;
    begin
        mainType := extractPlotMainType(plotType);
        size     := extractPlotSize(plotType);

        case mainType of
            PLOT_TYPE_AGR: mainTypePart := 'Agricultural';
            PLOT_TYPE_COM: mainTypePart := 'Commercial';
            PLOT_TYPE_IND: mainTypePart := 'Industrial';
            PLOT_TYPE_MAR: mainTypePart := 'Martial';
            PLOT_TYPE_MUN: mainTypePart := 'Municipal';
            PLOT_TYPE_REC: mainTypePart := 'Recreational';
            PLOT_TYPE_RES: mainTypePart := 'Residential';
        end;

        case size of
            SIZE_1x1: sizePart := '1x1';
            SIZE_2x2: sizePart := '2x2';
            SIZE_3x3: sizePart := '3x3';
            SIZE_INT: sizePart := 'Int';
        end;

        flstEdid := 'SS2_BuildingPlanList_' + mainTypePart + '_' + sizePart;
        Result := FindObjectInFileByEdid(ss2masterFile, flstEdid);
    end;

    function registerBuildingPlanWithRequirement(targetFile, buildingPlan, reqMisc: IInterface; edidBase: string; plotType: integer): IInterface;
    var
        edid: string;
        unlockScript, plotFlst: IInterface;
        mainType, mainTypeForScript: integer;
    begin
        if(edidBase = '') then begin
            edidBase := stripPrefix(globalNewFormPrefix, EditorID(buildingPlan));
        end;

        // edid for the unlockable
        edid := GenerateEdid(unlockablePrefix, edidBase);

        Result := getCopyOfTemplate(targetFile, unlockableTemplate, edid);
        //
        unlockScript := getScript(Result, 'SimSettlementsV2:MiscObjects:UnlockableBuildingPlan');
        if(not assigned(unlockScript)) then begin
            unlockScript := getScript(Result, 'SimSettlementsV2:MiscObjects:Unlockable');
            SetElementEditValues(unlockScript, 'ScriptName', 'SimSettlementsV2:MiscObjects:UnlockableBuildingPlan');
        end;

        // plotType
        mainType := extractPlotMainType(plotType);
        case mainType of
            PLOT_TYPE_AGR: mainTypeForScript := 0;
            PLOT_TYPE_COM: mainTypeForScript := 1;
            PLOT_TYPE_IND: mainTypeForScript := 2;
            PLOT_TYPE_MAR: mainTypeForScript := 3;
            PLOT_TYPE_MUN: mainTypeForScript := 4;
            PLOT_TYPE_REC: mainTypeForScript := 5;
            PLOT_TYPE_RES: mainTypeForScript := 6;
        end;


        plotFlst := getDefaultBuildingPlanList(plotType);

        setScriptProp(unlockScript, 'Requirements', reqMisc);
        setScriptProp(unlockScript, 'BuildingPlan', buildingPlan);
        setScriptProp(unlockScript, 'iPlotType', mainTypeForScript);

        if(assigned(plotFlst)) then begin
            setScriptProp(unlockScript, 'TargetBuildingPlanList', plotFlst);
        end else begin
            AddMessage('Failed to find TargetBuildingPlanList for '+EditorID(Result)+', you should set it manually');
        end;

        // finally register this req misc
        registerAddonContent(targetFile, Result, SS2_FLID_Unlockables);
    end;

    procedure setupFurnitureCobj(cobj, misc, furn: IInterface);
    var
        i: integer;
        fvpa, component: IInterface;
    begin
        setPathLinksTo(cobj, 'CNAM', furn);
        fvpa := ElementByPath(cobj, 'FVPA');
        component := ElementByIndex(fvpa, 0);
        setPathLinksTo(component, 'Component', misc);
    end;

    procedure createFurnitureCobjs(targetFile: IInterface; edidBase: string; misc, furn: IInterface);
    var
        craftCobj, scrapCobj, conditions, cond, fnam, fnamKw: IInterface;
        edidBuild, edidScrap: string;
    begin
        edidBuild := generateEdid('', edidBase+'_co_Build');

        // targetFile, stageItemTemplate, edid
        craftCobj := getCopyOfTemplate(targetFile, furnitureCobjTemplate, edidBuild);
        setupFurnitureCobj(craftCobj, misc, furn);
        conditions := ElementByPath(craftCobj, 'Conditions');

        cond := ElementByIndex(conditions, 0);
        SetPathLinksTo(cond, 'CTDA\Referenceable Object', misc);



        edidScrap := generateEdid('', edidBase+'_co_Scrap');
        scrapCobj := getCopyOfTemplate(targetFile, furnitureCobjTemplate, edidScrap);
        setupFurnitureCobj(scrapCobj, misc, furn);

        // kill conditions here
        RemoveElement(scrapCobj, 'Conditions');

        // keywordRecipeScrap
        fnam := ElementByPath(scrapCobj, 'FNAM');
        fnamKw := ElementByIndex(fnam, 0);
        setLinksTo(fnamKw, keywordRecipeScrap);
    end;

    ///////////////////// PLOT CREATION FUNCTIONS /////////////////////
    procedure cleanItemSpawns(newItemSpawns: IInterface);
    var
        i : integer;
        curSpawn: IInterface;
        curSpawnItem, curSpawnScript: IInterface;
    begin
        // clear the list and erase all the items in it
        if(not assigned(newItemSpawns)) then begin
            exit;
        end;

        newItemSpawns := ebp(newItemSpawns, 'Value\Array of Struct');
        for i:=0 to ElementCount(newItemSpawns)-1 do begin
            curSpawn := ElementByIndex(newItemSpawns, 0);
            curSpawnItem := getStructMember(curSpawn, 'StageItemDetails');
            RemoveElement(newItemSpawns, curSpawn);

            recycleSpawnMiscIfPossible(curSpawnItem);
        end;
    end;

    {
        Creates a stageItemSpawn
    }
    function createStageItemForm(targetFile: IInterface; edid: string; formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; spawnType: integer; spawnName: string; requirementsItem: IInterface): IInterface;
    var
        spawnItemScript, spawnDetails, requirements, vipReqItem: IInterface;
        existingKey: string;
        isNewForm: boolean;
    begin
		if(not assigned(formToSpawn)) then begin
			Result := nil;
			AddMessage('ERROR: createStageItemForm called with empty form');
			assert(false);
			exit;
		end;
        isNewForm := false;
        // before even trying, see if we have an equivalent already
        // getMiscLookupKey(formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; iType: integer; spawnName: string; requirementsItem: IInterface): string;
        Result := getSpawnMiscByParams(targetFile, formToSpawn, posX, posY, posZ, rotX, rotY, rotZ, scale, spawnType, spawnName, requirementsItem);
        if(assigned(Result)) then begin
            AddMessage('Reusing spawn misc '+EditorID(Result));
            exit;
        end;

        Result := getRecycledMisc(targetFile);

        if(not assigned(Result)) then begin
            isNewForm := true;
            Result := getCopyOfTemplate(targetFile, stageItemTemplate, edid);
        end else begin
            AddMessage('Reusing recycled '+EditorID(Result));
            SetElementEditValues(Result, 'EDID', edid);
        end;

        // add script
        spawnItemScript := getScript(Result, 'SimSettlementsV2:MiscObjects:StageItem');

        spawnDetails := createRawScriptProp(spawnItemScript, 'SpawnDetails');
        SetEditValueByPath(spawnDetails, 'Type', 'Struct');
        spawnDetails := ebp(spawnDetails, 'Value\Struct');

        setStructMember(spawnDetails, 'ObjectForm', formToSpawn);

        if(posX <> 0.0) then setStructMember(spawnDetails, 'fPosX', posX);
        if(posY <> 0.0) then setStructMember(spawnDetails, 'fPosY', posY);
        if(posZ <> 0.0) then setStructMember(spawnDetails, 'fPosZ', posZ);
        if(rotX <> 0.0) then setStructMember(spawnDetails, 'fAngleX', rotX);
        if(rotY <> 0.0) then setStructMember(spawnDetails, 'fAngleY', rotY);
        if(rotZ <> 0.0) then setStructMember(spawnDetails, 'fAngleZ', rotZ);
        if(scale <> 1.0) then setStructMember(spawnDetails, 'fScale', scale);

        if(spawnType > 0) then begin
            setScriptProp(spawnItemScript, 'iType', spawnType);
        end else begin
            deleteScriptProp(spawnItemScript, 'iType');
        end;

        if(spawnName <> '') then begin
            setScriptProp(spawnItemScript, 'sSpawnName', spawnName);
        end else begin
            deleteScriptProp(spawnItemScript, 'sSpawnName');
        end;

        if(assigned(requirementsItem)) then begin
            setScriptProp(spawnItemScript, 'Requirements', requirementsItem);
        end else begin
            deleteScriptProp(spawnItemScript, 'Requirements');
        end;

        addMiscToLookup(Result, spawnItemScript);
    end;

    {
        Generates EDID for a stage item spawn
        @param string   formToSpawnEdid     edid of the form to spawn
        @param string   levelBlueprintEdid  edid of the levelBlueprint
        @param string   suffix              Something like IntToStr(itemSpawnIndex)
        @param string   optionalSpawnName   if not empty string, will be used instead of formToSpawnEdid
    }
    function generateStageItemEdid(formToSpawnEdid, levelBlueprintEdid, suffix, optionalSpawnName: string): string;
    begin
        formToSpawnEdid := stripPrefix(globalNewFormPrefix, formToSpawnEdid);
        levelBlueprintEdid := stripPrefix(globalNewFormPrefix+levelPlanPrefix, levelBlueprintEdid);
        // formToSpawnEdid=praSS2_BunkerEntrance_L3_IM_NDC, levelBlueprintEdid=praSS2_LevelPlan_BuildingPlan_BunkerEntrance_lvl3, suffix=33, optionalSpawnName=
        //AddMessage('formToSpawnEdid='+formToSpawnEdid+', levelBlueprintEdid='+levelBlueprintEdid+', suffix='+suffix+', optionalSpawnName='+optionalSpawnName);
        if(optionalSpawnName = '') then begin
            optionalSpawnName := formToSpawnEdid;
        end;
        Result := generateEdid(
            stageItemPrefix,
            levelBlueprintEdid+'_'+optionalSpawnName+'_'+suffix
        );
    end;

    function addStageItemReqs(targetFile, parentLevel: IInterface; edidBase: string; formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; spawnType, stageStart, stageEnd, ownerNumber: integer; spawnName: string; reqItem: IInterface): IInterface;
    var
        parentScript, spawnsStruct, itemStruct: IInterface;
        newEdid: string;
    begin
        newEdid := generateStageItemEdid(
            EditorID(formToSpawn),
            EditorID(parentLevel),
            edidBase,
            ''
        );
        //newEdid := generateEdid(stageItemPrefix, EditorID(parentLevel)+'_'+EditorID(formToSpawn)+'_'+edidBase);

        Result := createStageItemForm(
            targetFile,
            newEdid,
            formToSpawn,
            posX,
            posY,
            posZ,
            rotX,
            rotY,
            rotZ,
            scale,
            spawnType,
            spawnName,
            reqItem
        );

        parentScript := getScript(parentLevel, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
        spawnsStruct := createRawScriptProp(parentScript, 'StageItemSpawns');

        itemStruct := appendStructToProperty(spawnsStruct);


        if(stageStart > 0) then begin
            setStructMember(itemStruct, 'iStageNum', stageStart);
        end;

        if(stageEnd > 0) and (stageEnd > stageStart) then begin
            setStructMember(itemStruct, 'iStageEnd', stageEnd);
        end;

        if(ownerNumber > 0) then begin
            setStructMember(itemStruct, 'iOwnerNumber', ownerNumber);
        end;

        // append the item
        setStructMember(itemStruct, 'StageItemDetails', Result);
    end;


    {
        creates a stage item spawn and adds to the given level
        @param IInterface   parentLevel
        @param string       edidBase    parentEdid and formToSpawn's edid will be prepended, pass something like the nr of the spawn
        @param IInterface   formToSpawn
        @param float        posX
        @param float        posY
        @param float        posZ
        @param float        rotX
        @param float        rotY
        @param float        rotZ
        @param float        scale
        @param int          stageStart  stage num relative to the current level
        @param int          stageEnd    stage num end, will be left out if 0
    }
    function addStageItem(targetFile, parentLevel: IInterface; edidBase: string; formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; spawnType, stageStart, stageEnd: integer): IInterface;
    var
        parentScript, spawnsStruct, itemStruct: IInterface;
        newEdid: string;
    begin
        Result := addStageItemReqs(
            targetFile,
            parentLevel,
            edidBase,
            formToSpawn,
            posX,
            posY,
            posZ,
            rotX,
            rotY,
            rotZ,
            scale,
            spawnType,
            stageStart,
            stageEnd,
            0,
            '',
            nil
        );
    end;

    function getSubtypeDescriptionString(subType: integer): string;
    begin
        Result := '';
        if(subType < 0) then begin
            exit;
        end;
        case (subType) of

        // subtypes
        // agricultural
            PLOT_SC_AGR_Default_Basic:    Result := '[Basic Farm]';
            PLOT_SC_AGR_Advanced:         Result := '[Advanced Farm]'+STRING_LINE_BREAK+'[Requires Skilled Endurance]';
            PLOT_SC_AGR_HighTech:         Result := '[Hi-Tech Farm]'+STRING_LINE_BREAK+'[Requires Gifted Endurance]';
        // commercial
            PLOT_SC_COM_ArmorStore:         Result := '[Armor Store]';
            PLOT_SC_COM_Bar:                Result := '[Bar]';
            PLOT_SC_COM_Beauty:             Result := '[Barber]';
            PLOT_SC_COM_Bookstore:          Result := '[Bookstore]';
            PLOT_SC_COM_Clinic:             Result := '[Clinic]';
            PLOT_SC_COM_ClothingStore:      Result := '[Clothing Store]';
            PLOT_SC_COM_Default_Other:      Result := '[Other]';
            PLOT_SC_COM_FurnitureStore:     Result := '[Furniture Store]';
            PLOT_SC_COM_GeneralStore:       Result := '[General Store]';
            PLOT_SC_COM_PowerArmorStore:    Result := '[Power Armor Store]';
            PLOT_SC_COM_WeaponsStore:       Result := '[Weapons Store]';
            PLOT_SC_COM_PetStore:           Result := '[Pet Store]';
        // industrial
            PLOT_SC_IND_BuildingMaterials:  Result := '[Gathering: Building Materials]';
            PLOT_SC_IND_Default_General:    Result := '[Gathering: Junk]';
            PLOT_SC_IND_MachineParts:       Result := '[Gathering: Machine Parts]';
            PLOT_SC_IND_OrganicMaterials:   Result := '[Gathering: Organic Materials]';
            PLOT_SC_IND_RareMaterials:      Result := '[Gathering: Rare Materials]';
            PLOT_SC_IND_Conversion:         Result := '[Conversion]';
            PLOT_SC_IND_Production:         Result := '[Production]';

        // martial
            PLOT_SC_MAR_Advanced:           Result := '[Advanced Defenses]'+STRING_LINE_BREAK+'[Requires Skilled Agility]';
            PLOT_SC_MAR_Default_Basic:      Result := '[Basic Defenses]';
            PLOT_SC_MAR_HighTech:           Result := '[Hi-Tech Defenses]'+STRING_LINE_BREAK+'[Requires Gifted Agility]';

            // municipial
            PLOT_SC_MUN_CaravanServices:         Result := '[Caravan Services]';
            PLOT_SC_MUN_CommunicationsStation:   Result := '[Communications]';
            PLOT_SC_MUN_Default_Other:           Result := '[Other]';
            PLOT_SC_MUN_PowerPlant_Advanced:     Result := '[Advanced Power Plant]'+STRING_LINE_BREAK+'[Requires Skilled Intelligence]';
            PLOT_SC_MUN_PowerPlant_Basic:        Result := '[Basic Power Plant]';
            PLOT_SC_MUN_PowerPlant_HighTech:     Result := '[Hi-Tech Power Plant]'+STRING_LINE_BREAK+'[Requires Gifted Intelligence]';
            PLOT_SC_MUN_PowerTransfer:           Result := '[Power Transfer]';
            PLOT_SC_MUN_TaxServices:             Result := '[Tax Services]';
            PLOT_SC_MUN_WaterPlant_Advanced:     Result := '[Advanced Water Plant]'+STRING_LINE_BREAK+'[Requires Skilled Perception]';
            PLOT_SC_MUN_WaterPlant_Basic:        Result := '[Basic Water Plant]';
            PLOT_SC_MUN_WaterPlant_HighTech:     Result := '[Hi-Tech Water Plant]'+STRING_LINE_BREAK+'[Requires Gifted Perception]';
        // recreational
            PLOT_SC_REC_Cemetery:             Result := '[Cemetery]';
            PLOT_SC_REC_Default_Relaxation:   Result := '[Relaxation]';

            PLOT_SC_REC_StrengthTraining:     Result := '[Strength Training]';
            PLOT_SC_REC_PerceptionTraining:   Result := '[Perception Training]';
            PLOT_SC_REC_EnduranceTraining:    Result := '[Endurance Training]';
            PLOT_SC_REC_CharismaTraining:     Result := '[Charisma Training]';
            PLOT_SC_REC_IntelligenceTraining: Result := '[Intelligence Training]';
            PLOT_SC_REC_AgilityTraining:      Result := '[Agility Training]';
            PLOT_SC_REC_LuckTraining:         Result := '[Luck Training]';

        // residential
            PLOT_SC_RES_Default_SinglePerson:   Result := '[Single Person Home]';
            PLOT_SC_RES_MultiPerson:            Result := '[Multi-Person Home]';
        end;

        if(enableOutpostSubtype) then begin
            case (subType) of
                PLOT_SC_MAR_OutpostType_Armory:                Result := '[Armory]';
                PLOT_SC_MAR_OutpostType_BattlefieldScavengers: Result := '[Battlefield Scavengers]';
                PLOT_SC_MAR_OutpostType_FieldSurgeon:          Result := '[Field Surgeon]';
                PLOT_SC_MAR_OutpostType_Prison:                Result := '[Prison]';
                PLOT_SC_MAR_OutpostType_RecruitmentCenter:     Result := '[Recruitment Center]';
                PLOT_SC_MAR_OutpostType_WatchTower:            Result := '[Watchtower]';

                PLOT_SC_REC_OutpostType_MessHall:         Result := '[Mess Hall]';
                PLOT_SC_REC_OutpostType_TrainingYard:     Result := '[Training Yard]';
            end;
        end;

        if(Result <> '') then begin
            Result := Result + STRING_LINE_BREAK;
        end;
    end;

    /////////////// BLUEPRINT STUFF ///////////////
    function prepareBlueprintRoot(targetFile, existingElem: IInterface; rootEdid, fullName, description, confirmation: string): IInterface;
    var
        formList, newRoot, descrOmod, confirmMesg, newScript: IInterface;
        bpEdid, listEdid: string;
        isNewElement: boolean;
    begin
        isNewElement := (not assigned(existingElem));
        // get or create the relevant objects
        bpEdid   := generateEdid('', rootEdid);
        listEdid := generateEdid(levelPlanListPrefix, rootEdid);

        if(isNewElement) then begin
            // AddMessage('Would be creating blueprint root');
            newRoot := getCopyOfTemplate(targetFile, buildingPlanTemplate, bpEdid);
        end else begin
            newRoot := existingElem;

            bpEdid := EditorID(newRoot);
        end;
        //AddMessage('1 Have NewRoot, edid '+EditorID(newRoot));
        newScript := getScript(newRoot, 'SimSettlementsV2:Weapons:BuildingPlan');
        formList := getScriptProp(newScript, 'LevelPlansList');


        if(not assigned(formList)) then begin
            formList := getElemByEdidAndSig(listEdid, 'FLST', targetFile);

            setScriptProp(newScript, 'LevelPlansList', formList);
        end;

        //AddMessage('2 Have NewRoot, edid '+EditorID(newRoot));
        // clearFormlist(formList);


        // set the various strings
        SetEditValueByPath(newRoot, 'FULL - Name', fullName);
        if(isNewElement) then begin
            setBlueprintDescription(newRoot, description);
            setBlueprintConfirmation(newRoot, confirmation);
        end;

        //AddMessage('3 Have NewRoot, edid '+EditorID(newRoot));
        Result := newRoot;
    end;

    function getBuildingPlanForLevel(targetFile: IInterface; edid: string; lvlNr: integer): IInterface;
    var
        newElem: IInterface;
    begin
        Result := getCopyOfTemplate(targetFile, buldingPlanLevelTemplate, edid);
    end;


    function generateBuildingPlanForLevel(targetFile: IInterface; rootBlueprint: IInterface; edidBase: string; lvlNr: integer): IInterface;
    var
        edid: string;
        script: IInterface;
    begin

        //edid := EditorID(rootBlueprint)+'_lvl'+IntToStr(lvlNr);
        //AddMessage('Will be '+edid);
        //edid := stripPrefix(globalNewFormPrefix+buildingPlanPrefix, edid);
        //AddMessage('after stripping '+edid);
        edid := generateEdid(levelPlanPrefix, edidBase+'_lvl'+IntToStr(lvlNr));
        //AddMessage('after generating '+edid);

        Result := getBuildingPlanForLevel(targetFile, edid, lvlNr);

        SetEditValueByPath(Result, 'FULL', geev(rootBlueprint, 'FULL')+' Level '+IntToStr(lvlNr));

        script := getScript(Result, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
        setScriptProp(script, 'iRequiredLevel', lvlNr);
    end;

    {
        Returns the first blueprint for the given level
    }
    function getLevelBuildingPlan(rootBlueprint: IInterface; lvlNr: integer): IInterface;
    var
        rootScript, lvlFormList, curLvl, curLvlScript: IInterface;
        i, formListLength, curLvlNr: integer;
    begin


        rootScript := getScript(rootBlueprint, 'SimSettlementsV2:Weapons:BuildingPlan');
        lvlFormList := getScriptProp(rootScript, 'LevelPlansList');

        formListLength := getFormListLength(lvlFormList);
        Result := nil;


        for i:=0 to formListLength-1 do begin
            curLvl := getFormListEntry(lvlFormList, i);
            curLvlScript :=  getScript(curLvl, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
            curLvlNr := getScriptProp(curLvlScript, 'iRequiredLevel');

            if(curLvlNr = lvlNr) then begin

                Result := curLvl;
                exit;
            end;
        end;
    end;

    {
        Returns the first blueprint for the given level, or creates one
    }
    function getOrCreateBuildingPlanForLevel(targetFile: IInterface; rootBlueprint: IInterface; edidBase: string; lvlNr: integer): IInterface;
    var
        rootScript, lvlFormList, curLvl: IInterface;
        i, formListLength, curLvlNr: integer;
    begin
        Result := getLevelBuildingPlan(rootBlueprint, lvlNr);
        if(assigned(Result)) then begin
            exit;
        end;

        rootScript := getScript(rootBlueprint, 'SimSettlementsV2:Weapons:BuildingPlan');
        lvlFormList := getScriptProp(rootScript, 'LevelPlansList');

        Result := generateBuildingPlanForLevel(targetFile, rootBlueprint, edidBase, lvlNr);
        addToFormlist(lvlFormList, Result);
    end;

    procedure generateTemplateCombination(blueprintRoot, omod: IInterface);
    var
        objectTemplate, combinations, combi, obts, includes, include: IInterface;
    begin
        objectTemplate := ensurePath(blueprintRoot, 'Object Template');
        combinations := ElementByPath(objectTemplate, 'Combinations');
        if(not assigned(combinations)) then begin
            // Add doesn't work here. '1' was found via trial and error. sigh...
            combinations := ElementAssign(objectTemplate, 1, nil, False);
        end;

        combi := ElementByIndex(combinations, 0);
        obts := ElementBySignature(combi, 'OBTS');

        SetElementEditValues(obts, 'Addon Index', '-1');
        SetElementEditValues(obts, 'Default', 'True');

        includes := ensurePath(obts, 'Includes');

        include := ElementByIndex(includes, 0);
        if(not assigned(include)) then begin
            include := ElementAssign(includes, HighInteger, nil, false);
        end;

        SetElementEditValues(include, 'Don''t Use All', 'True');
        SetPathLinksTo(include, 'Mod', omod);
    end;

    procedure setBlueprintDescription(blueprint: IInterface; descr: string);
    var
        bpScript, omod, templateCombi: IInterface;
        propName, omodEditorID, omodEditorIDPrefix: string;
    begin
        bpScript := getScript(blueprint, 'SimSettlementsV2:Weapons:BuildingPlan');
        propName := 'BuildingPlanDescription';
        omodEditorIDPrefix := buildingPlanDescriptionPrefix;

        if(not assigned(bpScript)) then begin
            bpScript := getScript(blueprint, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
            propName := 'BuildingLevelDescription';
			omodEditorIDPrefix := buildingLevelDescriptionPrefix;
        end;
        if(not assigned(bpScript)) then begin
            exit;
        end;

        omod := getScriptProp(bpScript, propName);
        if(not assigned(omod)) then begin
            omodEditorID := generateEdid(omodEditorIDPrefix, EditorID(blueprint));
            omod := getCopyOfTemplate(targetFile, descriptionTemplate, omodEditorID);
            setScriptProp(bpScript, propName, omod);
            SetEditValueByPath(omod, 'FULL', geev(blueprint, 'FULL')+' Description OMOD');
        end;

        SetEditValueByPath(omod, 'DESC', descr);

        // Now generate the template
        generateTemplateCombination(blueprint, omod);
    end;

    procedure setBlueprintConfirmation(blueprint: IInterface; confirmation: string);
    var
        bpScript, mesg: IInterface;
        propName, messageEdid, messageEdidPrefix: string;
    begin
        bpScript := getScript(blueprint,'SimSettlementsV2:Weapons:BuildingPlan');
        propName := 'BuildingPlanConfirm';
        messageEdidPrefix := buildingPlanConfirmPrefix;
        if(not assigned(bpScript)) then begin
            bpScript := getScript(blueprint,'SimSettlementsV2:Weapons:BuildingLevelPlan');
            propName := 'BuildingLevelConfirm';
			messageEdidPrefix := levelPlanConfirmPrefix;
        end;
        if(not assigned(bpScript)) then begin
            exit;
        end;

        mesg := getScriptProp(bpScript, propName);
        if(not assigned(mesg)) then begin

            messageEdid := generateEdid(messageEdidPrefix, EditorID(blueprint));

            mesg := getCopyOfTemplate(targetFile, confirmMessageTemplate, messageEdid);
            setScriptProp(bpScript, propName, mesg);
            SetEditValueByPath(mesg, 'FULL', geev(blueprint, 'FULL')+' Confirmation MESG');
        end;

        SetEditValueByPath(mesg, 'DESC', confirmation);
    end;

    /////////////// FORM TRANSLATION //////////////

    function translateReference(oldForm: IInterface): IInterface;
    var
        refrEdid, cellEdid: string;
        cellMaster, cell, newCell, newForm: IInterface;
    begin
        Result := oldForm;

        cell := PathLinksTo(oldForm, 'Cell');
        if(assigned(cell)) then begin
            AddMessage('== Warning: ObjectReference detected: '+FullPath(oldForm));
            AddMessage('   You will have to copy '+Name(cell)+' manually, and update references to it.');
        end;
    end;

    {
        Specialized function to copy SCOLs, potentially leaving out parts if they can't be translated
    }
    function copySCOLToFile(oldScol, fromFile, toFile: IInterface): IInterface;
    var
        i: integer;
        partsRoot, curElem, curOnam, curTarget, newTarget, matSwap: IInterface;
        subRecordCache: TList;
    begin

        addRequiredMastersSilent(oldScol, toFile);
        Result := wbCopyElementToFile(oldScol, toFile, true, true);
        partsRoot := ElementByPath(Result, 'Parts');

        matSwap := PathLinksTo(oldScol, 'Model\MODS');
        if(assigned(matSwap)) then begin
            // in most cases, this should copy the matswap
            matSwap := translateFormToFile(matSwap, fromFile, toFile);
            setPathLinksTo(Result, 'Model\MODS', matSwap);
        end;


        subRecordCache := TList.create;

        // cache them first
        for i:=0 to ElementCount(partsRoot)-1 do begin
            curElem := ElementByIndex(partsRoot, i);
            subRecordCache.add(curElem);
        end;

        for i:=0 to subRecordCache.count-1 do begin
            curElem := ObjectToElement(subRecordCache[i]);

            curOnam := ElementByPath(curElem, 'ONAM');
            curTarget := LinksTo(curOnam);

            if(not assigned(curTarget)) then begin
                AddMessage('Found empty part in '+Name(Result)+', removing it.');
                RemoveElement(partsRoot, curElem);
            end else begin;
                newTarget := translateFormToFile(curTarget, fromFile, toFile);
                if(not assigned(newTarget)) then begin
                    // SCOL part could not be translated.
                    AddMessage('Could not translate SCOL part '+Name(curTarget)+'. This part will be removed from '+Name(Result));
                    RemoveElement(partsRoot, curElem);
                end else begin
                    if(not equals(newTarget, curTarget)) then begin
                        addRequiredMastersSilent(newTarget, toFile);
                        SetLinksTo(curOnam, newTarget);
                    end;
                end;
            end;
        end;

        subRecordCache.free();
    end;

    {
        Recursively checks a (sub)record for formIDs, and translates them
    }

    procedure findFormIds(subrec, fromFile, toFile: IInterface);
    var
        testLinksTo,curElem, newElem: IInterface;
        i: integer;
        subRecordCache: TList;
    begin
        subRecordCache := TList.create;
        // AddMessage('FindFormIDs '+FullPath(subrec)+' with '+IntToStr(ElementCount(subrec)));
        for i:=0 to ElementCount(subrec)-1 do begin
            curElem := ElementByIndex(subrec, i);
            subRecordCache.add(curElem);
        end;
        for i:=0 to subRecordCache.count-1 do begin
            curElem := ObjectToElement(subRecordCache[i]);
            //AddMessage('iterating '+IntToStr(i););

            if(IsEditable(curElem)) then begin
                //AddMessage('yes editable');
                testLinksTo := LinksTo(curElem);
                if(assigned(testLinksTo)) then begin
                    newElem := translateFormToFile(testLinksTo, fromFile, toFile);
                    //AddMessage('yes editable '+FullPath(testLinksTo));
                    //AddMessage('was '+FullPath(newElem));


                    if(assigned(newElem)) then begin
                        if(not equals(newElem, testLinksTo)) then begin
                            SetLinksTo(curElem, newElem);
                        end;
                    end;
                end;
            end;
            findFormIds(curElem, fromFile, toFile);
        end;
        subRecordCache.free();
    end;

    {

    }
    function GenerateTranslatedEdid(prefix, edid: string): string;
    begin
        Result := generateEdid(prefix, edid);
    end;

    function getSS2VersionEdid(ss1Edid: string): string;
    var
        curPrefix: string;
    begin
        curPrefix := LowerCase(copy(ss1Edid, 1, 6));
        if(curPrefix <> 'kgsim_') then begin
            Result := '';
            exit;
        end;

        Result := 'SS2_' + copy(ss1Edid, 7, length(ss1Edid));
    end;

    function getSS2Version(ss1Form: IInterface): IInterface;
    var
        sourceFileName, sig, edid, newEdid, ss2edid: string;
        ss2Group: IInterface;
    begin
        sourceFileName := GetFileName(GetFile(ss1Form));

        // Result := nil;
        if (sourceFileName <> 'SimSettlements.esm') then begin
            Result := ss1Form;
            exit;
        end;

        sig := Signature(ss1Form);
        edid := EditorId(ss1Form);

        ss2edid := getHardcodedSSTranslation(edid);
        if(ss2edid <> '') then begin
            Result := FindObjectInFileByEdid(ss2MasterFile, ss2edid);
            exit;
        end;

        ss2Group := GroupBySignature(ss2MasterFile, sig);

        Result := MainRecordByEditorID(ss2Group, edid);
        if(assigned(Result)) then begin
            exit;
        end;

        // try replacing kgSIM_ with SS2_

        newEdid := getSS2VersionEdid(edid);
        Result := MainRecordByEditorID(ss2Group, newEdid);
    end;

    procedure translateElementScripts(newElem: IInterface);
    var
        scripts, script: IInterface;
        i: integer;
        scriptName, oldFlagMode: string;
        isFlagUp: boolean;
    begin
        // do this manually for performance reasons
        scripts := ElementByPath(newElem, 'VMAD - Virtual Machine Adapter\Scripts');
        if(not assigned(scripts)) then exit;
        for i := 0 to ElementCount(scripts)-1 do begin
            script := ElementByIndex(scripts, i);

            scriptName := LowerCase(geevt(script, 'scriptName'));

            // now stuff
            if(scriptName = 'simsettlements:animatedobjectspawner') then begin
                SetElementEditValues(script, 'ScriptName', 'SimSettlementsV2:ObjectReferences:AnimatedObjectSpawner');
                // also remove AutoBuildParent
                deleteScriptProp(script, 'AutoBuildParent');
            end else if(scriptName = 'simsettlements:flagmanager') then begin
                // replace by SimSettlementsV2:ObjectReferences:ThemeControlledObject
                SetElementEditValues(script, 'ScriptName', 'SimSettlementsV2:ObjectReferences:ThemeControlledObject');

                // now the complex stuff
                oldFlagMode := getScriptPropDefault(script, 'iFlagModel', 'Up');
                isFlagUp := getScriptPropDefault(script, 'FlagUp', true);

                deleteScriptProps(script);

                // set obligatory SS2 stuff
                setScriptProp(script, 'ThemeScript', 'SimSettlementsV2:Armors:ThemeDefinition_Flags');
                setScriptProp(script, 'ThemeRuleSet', SS2_ThemeRuleset_Flags);

                if (isFlagUp) or (oldFlagMode = 'Up') then begin
                    // up
                    setScriptProp(script, 'ThemePropertyName', 'FlagWaving');
                    setScriptProp(script, 'DefaultForm', flagTemplate_Waving);
                end else if(oldFlagMode = 'Wall') then begin
                    // wall
                    setScriptProp(script, 'ThemePropertyName', 'FlagWall');
                    setScriptProp(script, 'DefaultForm', flagTemplate_Wall);
                end else begin
                    // down
                    setScriptProp(script, 'ThemePropertyName', 'FlagDown');
                    setScriptProp(script, 'DefaultForm', flagTemplate_Down);
                end;
            end else if(scriptName = 'simsettlements:cityplannerdeskdrawer') then begin
                // this is a building plans drawer
                SetElementEditValues(script, 'ScriptName', 'SimSettlementsV2:ObjectReferences:LeaderDeskObject_ThemeDrawer');
                deleteScriptProps(script);

                // special stuff because why not
                SetElementEditValues(newElem, 'FULL', 'Building Plans');
                SetElementEditValues(newElem, 'ATTX', 'Setup Themes');
                {
                SimSettlements:CityPlannerDeskDrawer > SimSettlementsV2:ObjectReferences:LeaderDeskObject_ThemeDrawer
                    - No properties needed on new script
                    - Name Field: Building Plans
                    - Activate Text Override: Setup Themes
                }
            end else if(scriptName = 'simsettlements:cityplannerdeskblueprint') then begin
                // this is a building plans drawer
                SetElementEditValues(script, 'ScriptName', 'SimSettlementsV2:ObjectReferences:LeaderDeskObject_CityPlanManager');
                deleteScriptProps(script);
                SetElementEditValues(newElem, 'FULL', 'Manage City');

                {
                SimSettlements:CityPlannerDeskBlueprint > SimSettlementsV2:ObjectReferences:LeaderDeskObject_CityPlanManager
                    - No properties needed on new script
                    - Name Field: Manage City
                }
            end else if(scriptName = 'simsettlements:citysupplies') then begin
                // this is a building plans drawer
                SetElementEditValues(script, 'ScriptName', 'SimSettlementsV2:ObjectReferences:LeaderDeskObject_Supplies');
                deleteScriptProps(script);

                SetElementEditValues(newElem, 'FULL', 'City Supplies');
                SetElementEditValues(newElem, 'ATTX', 'Manage');
                break;
                {
                SimSettlements:CitySupplies > SimSettlementsV2:ObjectReferences:LeaderDeskObject_Supplies
                    - No properties needed on new script
                    - Name Field: City Supplies
                    - Activate Text Override: Manage
                }
            end else if(scriptName = 'simsettlements:flagselector') then begin
                // this is a building plans drawer
                SetElementEditValues(script, 'ScriptName', 'SimSettlementsV2:ObjectReferences:LeaderDeskObject_FlagSelector');

                // this needs props!
                oldFlagMode := getScriptPropDefault(script, 'iFlagModel', 'Up');
                isFlagUp := getScriptPropDefault(script, 'FlagUp', true);

                deleteScriptProps(script);

                if (isFlagUp) or (oldFlagMode = 'Up') then begin
                    // up
                    setScriptProp(script, 'ThemePropertyName', 'FlagWaving');
                    setScriptProp(script, 'DefaultForm', flagTemplate_Waving);
                end else if(oldFlagMode = 'Wall') then begin
                    // wall
                    setScriptProp(script, 'ThemePropertyName', 'FlagWall');
                    setScriptProp(script, 'DefaultForm', flagTemplate_Wall);
                end else begin
                    // down
                    setScriptProp(script, 'ThemePropertyName', 'FlagDown');
                    setScriptProp(script, 'DefaultForm', flagTemplate_Down);
                end;
                setScriptProp(script, 'ThemeScript', 'SimSettlementsV2:Armors:ThemeDefinition_Flags');
                setScriptProp(script, 'ThemeRuleSet', SS2_ThemeRuleset_Flags);

                SetElementEditValues(newElem, 'FULL', 'Settlement Flag');
                SetElementEditValues(newElem, 'ATTX', 'Select Flag');
                break;
                {
                SimSettlements:FlagSelector -> SimSettlementsV2:ObjectReferences:LeaderDeskObject_FlagSelector
                    - DefaultForm: SS2_FlagDown_USA [STAT:03012BF3]
                    - ThemePropertyName: FlagDown (??) <- read from iFlagModel in old, find other values except 'Down'. there is also bool FlagUp=false
                    - ThemeRuleSet: SS2_ThemeRuleset_Flags "Flag Ruleset" [MISC:0301BB47]
                    - ThemeScript: SimSettlementsV2:Armors:ThemeDefinition_Flags
                    - Activate Text Override: Select Flag
                }
            end;


        end;


    end;

    procedure loadValidMastersFromFile(f: IInterface);
    var
        i: integer;
        curMaster: IInterface;
    begin
        validMastersList.clear();

        for i:=0 to MasterCount(f)-1 do begin
            curMaster := MasterByIndex(f, i);
            validMastersList.add(GetFileName(curMaster));
        end;
    end;

    function isFileValidMaster(f: IInterface): Boolean;
    begin
        Result := (validMastersList.indexOf(GetFileName(f)) >= 0);
    end;

    {
        Copies a form to targetFile. Will also transfer any forms referenced by it.

        @param IInterface oldForm   the form to translate
        @param IInterface oldFile   the "old mod" file, only forms from this file will be translated
        @param IInterface toFile    target

    }
    function translateFormToFile(oldForm, oldFile, toFile: IInterface): IInterface;
    var
        newEdid, oldEdid, sig: string;
        elemFile, targetGroup, script: IInterface;
    begin
        oldEdid := EditorID(oldForm);
        sig := signature(oldForm);
        Result := nil;

        // straight-out refuse for some signatures
        if
            (sig = 'CELL') or
            (sig = 'QUST') or
            (sig = 'REFR') or
            (sig = 'ACHR') or
            (sig = 'WRLD')
        then begin
            exit;
        end;


        // hack. forms below 0x800 should be vanilla
        if(FormID(oldForm) < 2048) then begin
            Result := oldForm;
            exit;
        end;

        elemFile := GetFile(oldForm);

        if(GetFileName(elemFile) = 'SimSettlements.esm') then begin

            Result := getSS2Version(oldForm);

            if(not assigned(Result)) then begin
                // usually exit anyway. but if oldFile is SimSettlements.esm and toFile is SS2.esm, this is ok
                if (not isSameFile(ss2masterFile, toFile)) or (GetFileName(oldFile) <> 'SimSettlements.esm') then begin
                    exit;
                end;
            end else exit;
            // exit;
        end;


        // AddMessage('OldFile: '+GetFileName(oldFile)+', elemFile='+GetFileName(elemFile));
        if(not FilesEqual(oldFile, elemFile)) then begin
            Result := oldForm;
            exit;
        end;

        // If oldForm is from any of the masters of target
        if(isFileValidMaster(oldFile)) then begin
            Result := oldForm;
            exit;
        end;

        newEdid := GenerateEdid('', stripPrefix(oldFormPrefix, oldEdid));

        // check if newEdid exists already
        targetGroup := GroupBySignature(toFile, sig);
        if(assigned(targetGroup)) then begin
            Result := MainRecordByEditorID(targetGroup, newEdid);
            if(assigned(Result)) then begin
                exit;
            end;
        end;


        AddMessage('Trying to convert '+EditorID(oldForm));

        // special treatment of SCOLs
        if(sig = 'SCOL') then begin
            Result := copySCOLToFile(oldForm, oldFile, toFile);
            SetElementEditValues(Result, 'EDID', newEdid);
            exit;
        end;

        addRequiredMastersSilent(oldForm, toFile);
        Result := wbCopyElementToFile(oldForm, toFile, true, true);
        if(not assigned(Result)) then begin
            AddMessage('================ Failed copying '+oldEdid+' into '+GetFileName(toFile)+' ================');
            exit;
        end;


        BeginUpdate(Result);
        try
            SetElementEditValues(Result, 'EDID', newEdid);

            {
            // special handling for scripts
            // kgSIM_IndRev_NuclearArms_CapCreator [ACTI:010034DD]
            script := getScript(Result, 'SimSettlements:AnimatedObjectSpawner');
            if(assigned(script)) then begin
                SetElementEditValues(script, 'ScriptName', 'SimSettlementsV2:ObjectReferences:AnimatedObjectSpawner');
                // also remove AutoBuildParent
                deleteScriptProp(script, 'AutoBuildParent');
            end;
            }
            translateElementScripts(Result);


            findFormIds(Result, oldFile, toFile);
        finally
            EndUpdate(Result);
        end;
    end;

    // translateFormToFile

    {
        Translates forms from SimSettlements.esm to SS2
function translateFormToFile(oldForm, fromFile, toFile: IInterface): IInterface;
    }


    /////////////// SKIN STUFF ///////////////

    function prepareSkinRoot(targetFile, existingElem, targetRoot: IInterface; edid, fullName: string): IInterface;
    var
        rootEdid: string;
        newScript, newDescription: IInterface;
    begin
        rootEdid := generateEdid('', edid);

        if(not assigned(existingElem)) then begin
            Result := getCopyOfTemplate(targetFile, buildingSkinTemplate, rootEdid);
        end else begin
            Result := existingElem;
        end;
        newScript := getScript(Result, 'SimSettlementsV2:Weapons:BuildingSkin');
        SetElementEditValues(Result, 'FULL', fullName);

        newDescription := getScriptProp(newScript, 'BuildingPlanSkinDescription');
        if(not assigned(newDescription)) then begin
            newDescription := getCopyOfTemplate(targetFile, descriptionTemplate, generateEdid(buildingSkinDescriptionPrefix, edid+'_descr'));
            setScriptProp(newScript, 'BuildingPlanSkinDescription', newDescription);
        end;
        SetElementEditValues(newDescription, 'FULL', fullName);
        SetElementEditValues(newDescription, 'DESC', fullName);

        if(assigned(targetRoot)) then begin
            setScriptProp(newScript, 'TargetBuildingPlan', targetRoot);
        end;
    end;


    function getSkinForLevel(targetFile: IInterface; edid: string; lvlNr: integer): IInterface;
    var
        currentLevelScript: IInterface;
    begin
        Result := getCopyOfTemplate(targetFile, buildingLevelSkinTemplate, edid);
        setScriptProp(currentLevelScript, 'TargetBuildingLevelPlan', lvlNr);
    end;

    function generateSkinForLevel(targetFile: IInterface; rootSkin: IInterface; lvlNr: integer): IInterface;
    var
        edid, test1, test2: string;
        currentLevelSkin, rootScript, currentLevelScript, levelSkinsArray: IInterface;
    begin
		// KG Change - stripped _root from level edIDs
        edid := generateEdid(buildingSkinPrefix, StringReplace(EditorID(rootSkin),'_root', '', [rfReplaceAll])+'_lvl'+IntToStr(lvlNr));
        currentLevelSkin := getCopyOfTemplate(targetFile, buildingLevelSkinTemplate, edid);

        rootScript := getScript(rootSkin, 'SimSettlementsV2:Weapons:BuildingSkin');
        levelSkinsArray := getOrCreateScriptProp(rootScript, 'LevelSkins', 'Array of Object');
        appendObjectToProperty(levelSkinsArray, currentLevelSkin);

        Result := currentLevelSkin;
    end;

    {
        Returns the first skin for the given level
    }
    function getLevelSkin(rootSkin: IInterface; lvlNr: integer): IInterface;
    var
        rootScript, levelSkinsArray, curLvl, curLvlScript, curLvlTarget, curLvlTargetScript: IInterface;
        i, curLvlNr: integer;
    begin
        Result := nil;

        rootScript := getScript(rootSkin, 'SimSettlementsV2:Weapons:BuildingSkin');
        levelSkinsArray := getScriptProp(rootScript, 'LevelSkins');
        if(not assigned(levelSkinsArray)) then begin
            exit;
        end;
        for i:=0 to ElementCount(levelSkinsArray)-1 do begin

            curLvl := getObjectFromProperty(levelSkinsarray, i);//LinksTo(ElementByIndex(levelSkinsarray, i));
            curLvlScript :=  getScript(curLvl, 'SimSettlementsV2:Weapons:BuildingLevelSkin');

            curLvlTarget := getScriptProp(curLvlScript, 'TargetBuildingLevelPlan');
            curLvlTargetScript := getScript(curLvlTarget, 'SimSettlementsV2:Weapons:BuildingLevelPlan');
            curLvlNr := getScriptProp(curLvlTargetScript, 'iRequiredLevel');
            if(curLvlNr = lvlNr) then begin
                Result := curLvl;
                exit;
            end;
        end;
    end;

    {
        Returns the first skin for the given level, or creates one
    }
    function getOrCreateSkinForLevel(targetFile: IInterface; rootSkin: IInterface; lvlNr: integer): IInterface;
    begin
        Result := getLevelSkin(rootSkin, lvlNr);
        if(assigned(Result)) then begin
            exit;
        end;

        Result := generateSkinForLevel(targetFile, rootSkin, lvlNr);
    end;

    ///////////// PLOT TYPE STUFF //////////////
    function getPlotActivatorEdidByType(plotType: integer): string;
    var
        mainType, size: integer;
    begin
        mainType := extractPlotMainType(plotType);
        size := extractPlotSize(plotType);

        case mainType of
            PLOT_TYPE_RES:
                begin
                    case size of
                        SIZE_1x1: Result := 'SS2_Plot_Residential_1x1';
                        SIZE_2x2: Result := 'SS2_Plot_Residential_2x2';
                        SIZE_3x3: Result := 'SS2_Plot_Residential_3x3';
                        SIZE_INT: Result := 'SS2_Plot_Residential_Int';
                    end;
                end;
            PLOT_TYPE_AGR:
                begin
                    case size of
                        SIZE_1x1: Result := 'SS2_Plot_Agricultural_1x1';
                        SIZE_2x2: Result := 'SS2_Plot_Agricultural_2x2';
                        SIZE_3x3: Result := 'SS2_Plot_Agricultural_3x3';
                        SIZE_INT: Result := 'SS2_Plot_Agricultural_Int';
                    end;
                end;
            PLOT_TYPE_COM:
                begin
                    case size of
                        SIZE_1x1: Result := 'SS2_Plot_Commercial_1x1';
                        SIZE_2x2: Result := 'SS2_Plot_Commercial_2x2';
                        SIZE_3x3: Result := 'SS2_Plot_Commercial_3x3';
                        SIZE_INT: Result := 'SS2_Plot_Commercial_Int';
                    end;
                end;
            PLOT_TYPE_IND:
                begin
                    case size of
                        SIZE_1x1: Result := 'SS2_Plot_Industrial_1x1';
                        SIZE_2x2: Result := 'SS2_Plot_Industrial_2x2';
                        SIZE_3x3: Result := 'SS2_Plot_Industrial_3x3';
                        SIZE_INT: Result := 'SS2_Plot_Industrial_Int';
                    end;

                end;
            PLOT_TYPE_REC:
                begin
                    case size of
                        SIZE_1x1: Result := 'SS2_Plot_Recreational_1x1';
                        SIZE_2x2: Result := 'SS2_Plot_Recreational_2x2';
                        SIZE_3x3: Result := 'SS2_Plot_Recreational_3x3';
                        SIZE_INT: Result := 'SS2_Plot_Recreational_Int';
                    end;
                end;
            PLOT_TYPE_MAR:
                begin
                    case size of
                        SIZE_1x1: Result := 'SS2_Plot_Martial_1x1';
                        SIZE_2x2: Result := 'SS2_Plot_Martial_2x2';
                        SIZE_3x3: Result := 'SS2_Plot_Martial_3x3';
                        SIZE_INT: Result := 'SS2_Plot_Martial_Int';
                    end;
                end;
            PLOT_TYPE_MUN:
                begin
                    case size of
                        SIZE_1x1: Result := 'SS2_Plot_Municipal_1x1';
                        SIZE_2x2: Result := 'SS2_Plot_Municipal_2x2';
                        SIZE_3x3: Result := 'SS2_Plot_Municipal_3x3';
                        SIZE_INT: Result := 'SS2_Plot_Municipal_Int';
                    end;
                end;
        end;
    end;

    function getSkinTargetPlot(skin: IInterface): IInterface;
    var
        script: IInterface;
        otherAddonStruct: IInterface;
    begin
        Result := nil;

        script := getScript(skin, 'SimSettlementsV2:Weapons:BuildingSkin');
        if(not assigned(script)) then exit;

        Result := getScriptProp(script, 'TargetBuildingPlan');
        if(assigned(Result)) then exit;

        Result := getUniversalForm(script, 'TargetBuildingPlan_OtherAddon');
    end;

    {
        Returns the ACTI for the mainType and size from the given packed plot type
    }
    function getPlotActivatorByType(plotType: integer): IInterface;
    var
        edid: string;
    begin
        edid := getPlotActivatorEdidByType(plotType);
        Result := nil;

        if(edid = '') then begin
            exit;
        end;

        Result := MainRecordByEditorID(GroupBySignature(ss2masterFile, 'ACTI'), edid);
    end;

    {
        Returns the MAIN keyword for the given (packed) plottype
    }
    function getPlotKeywordForPackedPlotType(plotType: Integer): IInterface;
    var
        mainType, size: integer;
    begin
        mainType := extractPlotMainType(plotType);
        size := extractPlotSize(plotType);

        Result := nil;
        case mainType of
            PLOT_TYPE_RES:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_BuildingPlans_Residential_1x1;
                        SIZE_2x2: Result := SS2_FLID_BuildingPlans_Residential_2x2;
                        SIZE_3x3: Result := SS2_FLID_BuildingPlans_Residential_3x3;
                        SIZE_INT: Result := SS2_FLID_BuildingPlans_Residential_Int;
                    end;
                end;
            PLOT_TYPE_AGR:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_BuildingPlans_Agricultural_1x1;
                        SIZE_2x2: Result := SS2_FLID_BuildingPlans_Agricultural_2x2;
                        SIZE_3x3: Result := SS2_FLID_BuildingPlans_Agricultural_3x3;
                        SIZE_INT: Result := SS2_FLID_BuildingPlans_Agricultural_Int;
                    end;
                end;
            PLOT_TYPE_COM:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_BuildingPlans_Commercial_1x1;
                        SIZE_2x2: Result := SS2_FLID_BuildingPlans_Commercial_2x2;
                        SIZE_3x3: Result := SS2_FLID_BuildingPlans_Commercial_3x3;
                        SIZE_INT: Result := SS2_FLID_BuildingPlans_Commercial_Int;
                    end;
                end;
            PLOT_TYPE_IND:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_BuildingPlans_Industrial_1x1;
                        SIZE_2x2: Result := SS2_FLID_BuildingPlans_Industrial_2x2;
                        SIZE_3x3: Result := SS2_FLID_BuildingPlans_Industrial_3x3;
                        SIZE_INT: Result := SS2_FLID_BuildingPlans_Industrial_Int;
                    end;

                end;
            PLOT_TYPE_REC:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_BuildingPlans_Recreational_1x1;
                        SIZE_2x2: Result := SS2_FLID_BuildingPlans_Recreational_2x2;
                        SIZE_3x3: Result := SS2_FLID_BuildingPlans_Recreational_3x3;
                        SIZE_INT: Result := SS2_FLID_BuildingPlans_Recreational_Int;
                    end;
                end;
            PLOT_TYPE_MAR:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_BuildingPlans_Martial_1x1;
                        SIZE_2x2: Result := SS2_FLID_BuildingPlans_Martial_2x2;
                        SIZE_3x3: Result := SS2_FLID_BuildingPlans_Martial_3x3;
                        SIZE_INT: Result := SS2_FLID_BuildingPlans_Martial_Int;
                    end;
                end;
            PLOT_TYPE_MUN:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_BuildingPlans_Municipal_1x1;
                        SIZE_2x2: Result := SS2_FLID_BuildingPlans_Municipal_2x2;
                        SIZE_3x3: Result := SS2_FLID_BuildingPlans_Municipal_3x3;
                        SIZE_INT: Result := SS2_FLID_BuildingPlans_Municipal_Int;
                    end;
                end;
        end;
    end;

    function getSkinKeywordForPackedPlotType(plotType: Integer): IInterface;
    var
        mainType, size: integer;
    begin
        mainType := extractPlotMainType(plotType);
        size := extractPlotSize(plotType);

        Result := nil;
        case mainType of
            PLOT_TYPE_RES:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_Skins_Residential_1x1;
                        SIZE_2x2: Result := SS2_FLID_Skins_Residential_2x2;
                        SIZE_3x3: Result := SS2_FLID_Skins_Residential_3x3;
                        SIZE_INT: Result := SS2_FLID_Skins_Residential_Int;
                    end;
                end;
            PLOT_TYPE_AGR:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_Skins_Agricultural_1x1;
                        SIZE_2x2: Result := SS2_FLID_Skins_Agricultural_2x2;
                        SIZE_3x3: Result := SS2_FLID_Skins_Agricultural_3x3;
                        SIZE_INT: Result := SS2_FLID_Skins_Agricultural_Int;
                    end;
                end;
            PLOT_TYPE_COM:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_Skins_Commercial_1x1;
                        SIZE_2x2: Result := SS2_FLID_Skins_Commercial_2x2;
                        SIZE_3x3: Result := SS2_FLID_Skins_Commercial_3x3;
                        SIZE_INT: Result := SS2_FLID_Skins_Commercial_Int;
                    end;
                end;
            PLOT_TYPE_IND:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_Skins_Industrial_1x1;
                        SIZE_2x2: Result := SS2_FLID_Skins_Industrial_2x2;
                        SIZE_3x3: Result := SS2_FLID_Skins_Industrial_3x3;
                        SIZE_INT: Result := SS2_FLID_Skins_Industrial_Int;
                    end;

                end;
            PLOT_TYPE_REC:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_Skins_Recreational_1x1;
                        SIZE_2x2: Result := SS2_FLID_Skins_Recreational_2x2;
                        SIZE_3x3: Result := SS2_FLID_Skins_Recreational_3x3;
                        SIZE_INT: Result := SS2_FLID_Skins_Recreational_Int;
                    end;
                end;
            PLOT_TYPE_MAR:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_Skins_Martial_1x1;
                        SIZE_2x2: Result := SS2_FLID_Skins_Martial_2x2;
                        SIZE_3x3: Result := SS2_FLID_Skins_Martial_3x3;
                        SIZE_INT: Result := SS2_FLID_Skins_Martial_Int;
                    end;
                end;
            PLOT_TYPE_MUN:
                begin
                    case size of
                        SIZE_1x1: Result := SS2_FLID_Skins_Municipal_1x1;
                        SIZE_2x2: Result := SS2_FLID_Skins_Municipal_2x2;
                        SIZE_3x3: Result := SS2_FLID_Skins_Municipal_3x3;
                        SIZE_INT: Result := SS2_FLID_Skins_Municipal_Int;
                    end;
                end;
        end;
    end;

    function getPlotTypeForKeyword(kw: IInterface): integer;
    var
        edid: string;
    begin
        edid := EditorID(kw);

        Result := -1;

        if(edid = 'SS2_FLID_BuildingPlans_Agricultural_1x1') then begin
            Result := packPlotType(PLOT_TYPE_AGR, SIZE_1x1, -1);
            exit;
        end;

        if(edid = 'SS2_FLID_BuildingPlans_Agricultural_2x2') then begin
            Result := packPlotType(PLOT_TYPE_AGR, SIZE_2x2, -1);
            exit;
        end;

        if(edid = 'SS2_FLID_BuildingPlans_Agricultural_3x3') then begin
            Result := packPlotType(PLOT_TYPE_AGR, SIZE_3x3, -1);
            exit;
        end;

        if(edid = 'SS2_FLID_BuildingPlans_Agricultural_Int') then begin
            Result := packPlotType(PLOT_TYPE_AGR, SIZE_INT, -1);
            exit;
        end;


        if(edid = 'SS2_FLID_BuildingPlans_Commercial_1x1') then begin
            Result := packPlotType(PLOT_TYPE_COM, SIZE_1x1, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Commercial_2x2') then begin
            Result := packPlotType(PLOT_TYPE_COM, SIZE_2x2, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Commercial_3x3') then begin
            Result := packPlotType(PLOT_TYPE_COM, SIZE_3x3, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Commercial_Int') then begin
            Result := packPlotType(PLOT_TYPE_COM, SIZE_INT, -1);
            exit;
        end;


        if(edid = 'SS2_FLID_BuildingPlans_Industrial_1x1') then begin
            Result := packPlotType(PLOT_TYPE_IND, SIZE_1x1, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Industrial_2x2') then begin
            Result := packPlotType(PLOT_TYPE_IND, SIZE_2x2, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Industrial_3x3') then begin
            Result := packPlotType(PLOT_TYPE_IND, SIZE_3x3, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Industrial_Int') then begin
            Result := packPlotType(PLOT_TYPE_IND, SIZE_INT, -1);
            exit;
        end;


        if(edid = 'SS2_FLID_BuildingPlans_Martial_1x1') then begin
            Result := packPlotType(PLOT_TYPE_MAR, SIZE_1x1, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Martial_2x2') then begin
            Result := packPlotType(PLOT_TYPE_MAR, SIZE_2x2, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Martial_3x3') then begin
            Result := packPlotType(PLOT_TYPE_MAR, SIZE_3x3, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Martial_Int') then begin
            Result := packPlotType(PLOT_TYPE_MAR, SIZE_INT, -1);
            exit;
        end;


        if(edid = 'SS2_FLID_BuildingPlans_Municipal_1x1') then begin
            Result := packPlotType(PLOT_TYPE_MUN, SIZE_1x1, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Municipal_2x2') then begin
            Result := packPlotType(PLOT_TYPE_MUN, SIZE_2x2, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Municipal_3x3') then begin
            Result := packPlotType(PLOT_TYPE_MUN, SIZE_3x3, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Municipal_Int') then begin
            Result := packPlotType(PLOT_TYPE_MUN, SIZE_INT, -1);
            exit;
        end;


        if(edid = 'SS2_FLID_BuildingPlans_Recreational_1x1') then begin
            Result := packPlotType(PLOT_TYPE_REC, SIZE_1x1, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Recreational_2x2') then begin
            Result := packPlotType(PLOT_TYPE_REC, SIZE_2x2, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Recreational_3x3') then begin
            Result := packPlotType(PLOT_TYPE_REC, SIZE_3x3, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Recreational_Int') then begin
            Result := packPlotType(PLOT_TYPE_REC, SIZE_INT, -1);
            exit;
        end;


        if(edid = 'SS2_FLID_BuildingPlans_Residential_1x1') then begin
            Result := packPlotType(PLOT_TYPE_RES, SIZE_1x1, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Residential_2x2') then begin
            Result := packPlotType(PLOT_TYPE_RES, SIZE_2x2, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Residential_3x3') then begin
            Result := packPlotType(PLOT_TYPE_RES, SIZE_3x3, -1);
            exit;
        end;
        if(edid = 'SS2_FLID_BuildingPlans_Residential_Int') then begin
            Result := packPlotType(PLOT_TYPE_RES, SIZE_INT, -1);
            exit;
        end;
    end;

    function getMainTypeKeyword(mainType: integer): IInteface;
    begin
        Result := nil;
        case mainType of
            PLOT_TYPE_AGR: Result := SS2_PlotType_Agricultural;
            PLOT_TYPE_COM: Result := SS2_PlotType_Commercial;
            PLOT_TYPE_IND: Result := SS2_PlotType_Industrial;
            PLOT_TYPE_MAR: Result := SS2_PlotType_Martial;
            PLOT_TYPE_MUN: Result := SS2_PlotType_Municipal;
            PLOT_TYPE_REC: Result := SS2_PlotType_Recreational;
            PLOT_TYPE_RES: Result := SS2_PlotType_Residential;
        end;
    end;

    function getSizeKeyword(size: integer): IInterface;
    begin
        Result := nil;
        case size of
            SIZE_1x1: Result := SS2_PlotSize_1x1;
            SIZE_2x2: Result := SS2_PlotSize_2x2;
            SIZE_3x3: Result := SS2_PlotSize_3x3;
            SIZE_INT: Result := SS2_PlotSize_Int;
        end;
    end;

    function getMainTypeByKeyword(kw: IInterface): integer;
    var
        edid: string;
    begin
        Result := -1;
        edid := EditorID(kw);
        if(edid = 'SS2_PlotType_Agricultural') then begin
            Result := PLOT_TYPE_AGR;
            exit;
        end;
        if(edid = 'SS2_PlotType_Commercial') then begin
            Result := PLOT_TYPE_COM;
            exit;
        end;
        if(edid = 'SS2_PlotType_Industrial') then begin
            Result := PLOT_TYPE_IND;
            exit;
        end;
        if(edid = 'SS2_PlotType_Martial') then begin
            Result := PLOT_TYPE_MAR;
            exit;
        end;
        if(edid = 'SS2_PlotType_Municipal') then begin
            Result := PLOT_TYPE_MUN;
            exit;
        end;
        if(edid = 'SS2_PlotType_Recreational') then begin
            Result := PLOT_TYPE_REC;
            exit;
        end;
        if(edid = 'SS2_PlotType_Residential') then begin
            Result := PLOT_TYPE_RES;
            exit;
        end;
    end;

    function getSizeByKeyword(kw: IInterface): integer;
    var
        edid: string;
    begin
        Result := -1;
        edid := EditorID(kw);
        if(edid = 'SS2_PlotSize_1x1') then begin
            Result := SIZE_1x1;
            exit;
        end;
        if(edid = 'SS2_PlotSize_2x2') then begin
            Result := SIZE_2x2;
            exit;
        end;
        if(edid = 'SS2_PlotSize_3x3') then begin
            Result := SIZE_3x3;
            exit;
        end;
        if(edid = 'SS2_PlotSize_Int') then begin
            Result := SIZE_INT;
            exit;
        end;
    end;

    function getSubtypeKeyword(subType: integer): IInterface;
    begin
        Result := nil;
        case subType of
            // agricultural
            PLOT_SC_AGR_Default_Basic:  Result := SS2_PlotTypeSubClass_Agricultural_Default_Basic;
            PLOT_SC_AGR_Advanced:       Result := SS2_PlotTypeSubClass_Agricultural_Advanced;
            PLOT_SC_AGR_HighTech:       Result := SS2_PlotTypeSubClass_Agricultural_HighTech;
            // commercial
            PLOT_SC_COM_Default_Other:      Result := SS2_PlotTypeSubClass_Commercial_Default_Other;
            PLOT_SC_COM_ArmorStore:         Result := SS2_PlotTypeSubClass_Commercial_ArmorStore;
            PLOT_SC_COM_Bar:                Result := SS2_PlotTypeSubClass_Commercial_Bar;
            PLOT_SC_COM_Beauty:             Result := SS2_PlotTypeSubClass_Commercial_Beauty;
            PLOT_SC_COM_Bookstore:          Result := SS2_PlotTypeSubClass_Commercial_Bookstore;
            PLOT_SC_COM_Clinic:             Result := SS2_PlotTypeSubClass_Commercial_Clinic;
            PLOT_SC_COM_ClothingStore:      Result := SS2_PlotTypeSubClass_Commercial_ClothingStore;
            PLOT_SC_COM_FurnitureStore:     Result := SS2_PlotTypeSubClass_Commercial_FurnitureStore;
            PLOT_SC_COM_GeneralStore:       Result := SS2_PlotTypeSubClass_Commercial_GeneralStore;
            PLOT_SC_COM_PowerArmorStore:    Result := SS2_PlotTypeSubClass_Commercial_PowerArmorStore;
            PLOT_SC_COM_WeaponsStore:       Result := SS2_PlotTypeSubClass_Commercial_WeaponsStore;
            PLOT_SC_COM_PetStore:           Result := SS2_PlotTypeSubClass_Commercial_PetStore;
            // industrial
            PLOT_SC_IND_Default_General:    Result := SS2_PlotTypeSubClass_Industrial_Default_General;
            PLOT_SC_IND_BuildingMaterials:  Result := SS2_PlotTypeSubClass_Industrial_BuildingMaterials;
            PLOT_SC_IND_MachineParts:       Result := SS2_PlotTypeSubClass_Industrial_MachineParts;
            PLOT_SC_IND_OrganicMaterials:   Result := SS2_PlotTypeSubClass_Industrial_OrganicMaterials;
            PLOT_SC_IND_RareMaterials:      Result := SS2_PlotTypeSubClass_Industrial_RareMaterials;
            PLOT_SC_IND_Conversion:      Result := SS2_PlotTypeSubClass_Industrial_Conversion;
            PLOT_SC_IND_Production:      Result := SS2_PlotTypeSubClass_Industrial_Production;

            // martial
            PLOT_SC_MAR_Default_Basic:                      Result := SS2_PlotTypeSubClass_Martial_Default_Basic;
            PLOT_SC_MAR_Advanced:                           Result := SS2_PlotTypeSubClass_Martial_Advanced;
            PLOT_SC_MAR_HighTech:                           Result := SS2_PlotTypeSubClass_Martial_HighTech;

            // municipial
            PLOT_SC_MUN_Default_Other:              Result := SS2_PlotTypeSubClass_Municipal_Default_Other;
            PLOT_SC_MUN_CaravanServices:            Result := SS2_PlotTypeSubClass_Municipal_CaravanServices;
            PLOT_SC_MUN_CommunicationsStation:      Result := SS2_PlotTypeSubClass_Municipal_CommunicationStation;
            PLOT_SC_MUN_PowerPlant_Basic:           Result := SS2_PlotTypeSubClass_Municipal_PowerPlant_Basic;
            PLOT_SC_MUN_PowerPlant_Advanced:        Result := SS2_PlotTypeSubClass_Municipal_PowerPlant_Advanced;
            PLOT_SC_MUN_PowerPlant_HighTech:        Result := SS2_PlotTypeSubClass_Municipal_PowerPlant_HighTech;
            PLOT_SC_MUN_PowerTransfer:              Result := SS2_PlotTypeSubClass_Municipal_PowerTransfer;
            PLOT_SC_MUN_TaxServices:                Result := SS2_PlotTypeSubClass_Municipal_TaxServices;
            PLOT_SC_MUN_WaterPlant_Basic:           Result := SS2_PlotTypeSubClass_Municipal_WaterPlant_Basic;
            PLOT_SC_MUN_WaterPlant_Advanced:        Result := SS2_PlotTypeSubClass_Municipal_WaterPlant_Advanced;
            PLOT_SC_MUN_WaterPlant_HighTech:        Result := SS2_PlotTypeSubClass_Municipal_WaterPlant_HighTech;
            // recreational
            PLOT_SC_REC_Default_Relaxation:         Result := SS2_PlotTypeSubClass_Recreational_Default_Relaxation;
            PLOT_SC_REC_Cemetery:                   Result := SS2_PlotTypeSubClass_Recreational_Cemetery;

            PLOT_SC_REC_StrengthTraining:           Result := SS2_PlotTypeSubClass_Recreational_StrengthTraining;
            PLOT_SC_REC_PerceptionTraining:         Result := SS2_PlotTypeSubClass_Recreational_PerceptionTraining;
            PLOT_SC_REC_EnduranceTraining:          Result := SS2_PlotTypeSubClass_Recreational_EnduranceTraining;
            PLOT_SC_REC_CharismaTraining:           Result := SS2_PlotTypeSubClass_Recreational_CharismaTraining;
            PLOT_SC_REC_IntelligenceTraining:       Result := SS2_PlotTypeSubClass_Recreational_IntelligenceTraining;
            PLOT_SC_REC_AgilityTraining:            Result := SS2_PlotTypeSubClass_Recreational_AgilityTraining;
            PLOT_SC_REC_LuckTraining:               Result := SS2_PlotTypeSubClass_Recreational_LuckTraining;
            // residential
            PLOT_SC_RES_Default_SinglePerson:   Result := SS2_PlotTypeSubClass_Residential_Default_SinglePerson;
            PLOT_SC_RES_MultiPerson:            Result := SS2_PlotTypeSubClass_Residential_MultiPerson;
        end;

        if(enableOutpostSubtype) then begin
            case subType of
                // martial
                PLOT_SC_MAR_OutpostType_Armory:                 Result := SS2_PlotTypeSubClass_Martial_OutpostType_Armory;
                PLOT_SC_MAR_OutpostType_BattlefieldScavengers:  Result := SS2_PlotTypeSubClass_Martial_OutpostType_BattlefieldScavengers;
                PLOT_SC_MAR_OutpostType_FieldSurgeon:           Result := SS2_PlotTypeSubClass_Martial_OutpostType_FieldSurgeon;
                PLOT_SC_MAR_OutpostType_Prison:                 Result := SS2_PlotTypeSubClass_Martial_OutpostType_Prison;
                PLOT_SC_MAR_OutpostType_RecruitmentCenter:      Result := SS2_PlotTypeSubClass_Martial_OutpostType_RecruitmentCenter;
                PLOT_SC_MAR_OutpostType_WatchTower:             Result := SS2_PlotTypeSubClass_Martial_OutpostType_WatchTower;

                // recreational
                PLOT_SC_REC_OutpostType_MessHall:       Result := SS2_PlotTypeSubClass_Recreational_OutpostType_MessHall;
                PLOT_SC_REC_OutpostType_TrainingYard:   Result := SS2_PlotTypeSubClass_Recreational_OutpostType_TrainingYard;
            end;
        end;
    end;

    function getSubtypeByKeyword(kw: IInterface): integer;
    var
        edid: string;
    begin
        edid := EditorID(kw);
        Result := -1;

        // agricultural
        if(edid = 'SS2_PlotTypeSubClass_Agricultural_Default_Basic') then begin
            Result := PLOT_SC_AGR_Default_Basic;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Agricultural_Advanced') then begin
            Result := PLOT_SC_AGR_Advanced;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Agricultural_HighTech') then begin
            Result := PLOT_SC_AGR_HighTech;
            exit;
        end;
        // commercial
        if(edid = 'SS2_PlotTypeSubClass_Commercial_Default_Other') then begin
            Result := PLOT_SC_COM_Default_Other;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_ArmorStore') then begin
            Result := PLOT_SC_COM_ArmorStore;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_Bar') then begin
            Result := PLOT_SC_COM_Bar;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_Beauty') then begin
            Result := PLOT_SC_COM_Beauty;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_Bookstore') then begin
            Result := PLOT_SC_COM_Bookstore;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_Clinic') then begin
            Result := PLOT_SC_COM_Clinic;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_ClothingStore') then begin
            Result := PLOT_SC_COM_ClothingStore;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_FurnitureStore') then begin
            Result := PLOT_SC_COM_FurnitureStore;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_GeneralStore') then begin
            Result := PLOT_SC_COM_GeneralStore;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_PowerArmorStore') then begin
            Result := PLOT_SC_COM_PowerArmorStore;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_WeaponsStore') then begin
            Result := PLOT_SC_COM_WeaponsStore;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Commercial_PetStore') then begin
            Result := PLOT_SC_COM_PetStore;
            exit;
        end;
        // industrial
        if(edid = 'SS2_PlotTypeSubClass_Industrial_Default_General') then begin
            Result := PLOT_SC_IND_Default_General;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Industrial_BuildingMaterials') then begin
            Result := PLOT_SC_IND_BuildingMaterials;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Industrial_MachineParts') then begin
            Result := PLOT_SC_IND_MachineParts;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Industrial_OrganicMaterials') then begin
            Result := PLOT_SC_IND_OrganicMaterials;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Industrial_RareMaterials') then begin
            Result := PLOT_SC_IND_RareMaterials;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Industrial_Conversion') then begin
            Result := PLOT_SC_IND_Conversion;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Industrial_Production') then begin
            Result := PLOT_SC_IND_Production;
            exit;
        end;


        // martial
        if(edid = 'SS2_PlotTypeSubClass_Martial_Default_Basic') then begin
            Result := PLOT_SC_MAR_Default_Basic;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Martial_Advanced') then begin
            Result := PLOT_SC_MAR_Advanced;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Martial_HighTech') then begin
            Result := PLOT_SC_MAR_HighTech;
            exit;
        end;

        // municipial
        if(edid = 'SS2_PlotTypeSubClass_Municipal_Default_Other') then begin
            Result := PLOT_SC_MUN_Default_Other;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_CaravanServices') then begin
            Result := PLOT_SC_MUN_CaravanServices;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_CommunicationStation') then begin
            Result := PLOT_SC_MUN_CommunicationsStation;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_PowerPlant_Basic') then begin
            Result := PLOT_SC_MUN_PowerPlant_Basic;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_PowerPlant_Advanced') then begin
            Result := PLOT_SC_MUN_PowerPlant_Advanced;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_PowerPlant_HighTech') then begin
            Result := PLOT_SC_MUN_PowerPlant_HighTech;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_PowerTransfer') then begin
            Result := PLOT_SC_MUN_PowerTransfer;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_TaxServices') then begin
            Result := PLOT_SC_MUN_TaxServices;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_WaterPlant_Basic') then begin
            Result := PLOT_SC_MUN_WaterPlant_Basic;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_WaterPlant_Advanced') then begin
            Result := PLOT_SC_MUN_WaterPlant_Advanced;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Municipal_WaterPlant_HighTech') then begin
            Result := PLOT_SC_MUN_WaterPlant_HighTech;
            exit;
        end;
        // recreational
        if(edid = 'SS2_PlotTypeSubClass_Recreational_Default_Relaxation') then begin
            Result := PLOT_SC_REC_Default_Relaxation;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Recreational_Cemetery') then begin
            Result := PLOT_SC_REC_Cemetery;
            exit;
        end;

        if(edid = 'SS2_PlotTypeSubClass_Recreational_StrengthTraining') then begin
            Result := PLOT_SC_REC_StrengthTraining;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Recreational_PerceptionTraining') then begin
            Result := PLOT_SC_REC_PerceptionTraining;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Recreational_EnduranceTraining') then begin
            Result := PLOT_SC_REC_EnduranceTraining;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Recreational_CharismaTraining') then begin
            Result := PLOT_SC_REC_CharismaTraining;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Recreational_IntelligenceTraining') then begin
            Result := PLOT_SC_REC_IntelligenceTraining;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Recreational_AgilityTraining') then begin
            Result := PLOT_SC_REC_AgilityTraining;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Recreational_LuckTraining') then begin
            Result := PLOT_SC_REC_LuckTraining;
            exit;
        end;
        // residential
        if(edid = 'SS2_PlotTypeSubClass_Residential_Default_SinglePerson') then begin
            Result := PLOT_SC_RES_Default_SinglePerson;
            exit;
        end;
        if(edid = 'SS2_PlotTypeSubClass_Residential_MultiPerson') then begin
            Result := PLOT_SC_RES_MultiPerson;
            exit;
        end;

        if(enableOutpostSubtype) then begin
            // martial
            if(edid = 'SS2_PlotTypeSubClass_Martial_OutpostType_Armory') then begin
                Result := PLOT_SC_MAR_OutpostType_Armory;
                exit;
            end;
            if(edid = 'SS2_PlotTypeSubClass_Martial_OutpostType_BattlefieldScavengers') then begin
                Result := PLOT_SC_MAR_OutpostType_BattlefieldScavengers;
                exit;
            end;
            if(edid = 'SS2_PlotTypeSubClass_Martial_OutpostType_FieldSurgeon') then begin
                Result := PLOT_SC_MAR_OutpostType_FieldSurgeon;
                exit;
            end;
            if(edid = 'SS2_PlotTypeSubClass_Martial_OutpostType_Prison') then begin
                Result := PLOT_SC_MAR_OutpostType_Prison;
                exit;
            end;
            if(edid = 'SS2_PlotTypeSubClass_Martial_OutpostType_RecruitmentCenter') then begin
                Result := PLOT_SC_MAR_OutpostType_RecruitmentCenter;
                exit;
            end;
            if(edid = 'SS2_PlotTypeSubClass_Martial_OutpostType_WatchTower') then begin
                Result := PLOT_SC_MAR_OutpostType_WatchTower;
                exit;
            end;

            // rec
            if(edid = 'SS2_PlotTypeSubClass_Recreational_OutpostType_MessHall') then begin
                Result := PLOT_SC_REC_OutpostType_MessHall;
                exit;
            end;
            if(edid = 'SS2_PlotTypeSubClass_Recreational_OutpostType_TrainingYard') then begin
                Result := PLOT_SC_REC_OutpostType_TrainingYard;
                exit;
            end;
        end;
    end;


    {
        Gets the type of a plot, deprecated
    }
    function getNewPlotType(newPlot: IInterface): integer;
    begin
        Result := getPlotType(newPlot);
    end;


    {
        Gets the type of a plot
    }
    function getPlotType(plot: IInterface): integer;
    var
        kwda, curKw: IInterface;
        mainType, subType, size, curType: integer;
    begin

        Result := getPlotTypeFromKeywords(plot);

        if(Result > 0) then exit;

        // otherwise do a formlist-based lookup
        Result := getPlotTypeFromFormLists(plot);
    end;

    function getPlotTypeFromKeywords(plot: IInterface): integer;
    var
        kwda, curKw: IInterface;
        mainType, subType, size, curType, i: integer;
    begin
        Result := -1;

        mainType := -1;
        subType  := -1;
        size     := -1;

        kwda := ElementByPath(plot, 'KWDA');
        if(assigned(kwda)) then begin
            for i:=0 to ElementCount(kwda)-1 do begin
                curKw := LinksTo(ElementByIndex(kwda, i));
                curType := getSizeByKeyword(curKw);
                if(curType > -1) then begin
                    size := curType;
                end else begin
                    curType := getMainTypeByKeyword(curKw);
                    if(curType > -1) then begin
                        mainType := curType;
                    end else begin
                        curType := getSubtypeByKeyword(curKw);
                        if(curType > -1) then begin
                            subType := curType;
                        end;
                    end;
                end;
            end;
        end;

        if(mainType > 0) and (size > 0) and (subType > 0) then begin
            Result := packPlotType(mainType, size, subType);
        end;

    end;

    {
        Gets the type of a plot based on the formlist it's registered with
    }
    function getPlotTypeFromFormLists(newPlot: IInterface): integer;
    var
        mainPlotAndSize, subType: integer;

    begin
        mainPlotAndSize := getNewPlotMainTypeAndSize(newPlot);
        if(mainPlotAndSize <= -1) then begin
            Result := -1;
            exit;
        end;

        subType := getNewPlotSubType(newPlot);

        if(subType > -1) then begin
            Result := replacePlotSubtype(mainPlotAndSize, subType);
            exit;
        end;

        Result := ensurePlotSubtype(mainPlotAndSize);
    end;

    {
        Gets the new plot's main and size types, using the KW of the FLST it is saved in.
        Returns a packed plot type with main type and size.
    }
    function getNewPlotMainTypeAndSize(newPlot: IInterface): integer;
    var
        i: integer;
        plotKw, curFlst: IInterface;
    begin
        Result := -1;
        // find formlist
        for i:=0 to ReferencedByCount(newPlot)-1 do begin
            curFlst := ReferencedByIndex(newPlot, i);
            if(Signature(curFlst) = 'FLST') then begin
                plotKw := getFormListEntry(curFlst, 0);
                if(assigned(plotKw)) then begin
                    if(Signature(plotKw) = 'KYWD') then begin
                        Result := getPlotTypeForKeyword(plotKw);
                        exit;
                    end;
                end;
            end;
        end;
    end;

    {
        Returns the plot's subtype (not packed), by looking on it's own keywords.
    }
    function getNewPlotSubType(newPlot: IInterface): integer;
    var
        i: integer;
        kwList, curKw: IInterface;
    begin
        Result := -1;
        kwList := ElementByPath(newPlot, 'KWDA');
        for i:=0 to ElementCount(kwList)-1 do begin
            curKw := LinksTo(ElementByIndex(kwList, i));

            Result := getSubtypeByKeyword(curKw);
            if(Result > -1) then begin
                exit;
            end;
        end;
    end;


    {
        Returns some a human-readable text for the given combined plot type
    }
    function getNameForPackedPlotType(packedPlotType: Integer): String;
    var
        mainType, size, subType: integer;
    begin
        if(packedPlotType < 0) then begin
            Result := 'Unknown Plot Type';
            exit;
        end;
        mainType := extractPlotMainType(packedPlotType);
        size     := extractPlotSize(packedPlotType);
        subType  := extractPlotSubtype(packedPlotType);

        Result := getPlotMainTypeName(mainType) + ' ' + getPlotSizeName(size);

        if(subType > 0) then begin
            Result := Result + ' (' + getPlotSubTypeName(subType) + ')';
        end;
    end;

    function getPlotMainTypeName(mainType: integer): String;
    begin
        Result := plotTypeNames[mainType];
    end;

    function getPlotSubTypeName(subType: integer): String;
    begin
        Result := plotSubtypeNames[subType];
    end;

    function getPlotSizeName(size: integer): String;
    begin
        Result := plotSizeNames[size];
    end;

    {
        Combine type, size, and subtype into one single int
    }
    function packPlotType(mainType, plotSize, subType: integer): integer;
    begin
        // 0xAABBCC, where AA is subtype, BB is plotSize, CC is plotType, all +1, because 0 is also a valid type
        Result := ((subType+1) shl 16) or ((plotSize+1) shl 8) or (mainType+1);
    end;

    {
        Extract the actual type from the combined/packed type
    }
    function extractPlotMainType(packedType: integer): integer;
    begin
        Result := (packedType and $FF) - 1;
    end;

    {
        Extract the size from the combined/packed type
    }
    function extractPlotSize(packedType: integer): integer;
    begin
        Result := ((packedType and $FF00) shr 8) - 1;
    end;

    {
        Extract the subtype from the combined/packed type
    }
    function extractPlotSubtype(packedType: integer): integer;
    begin
        Result := ((packedType and $FF0000) shr 16) - 1;
    end;

    {
        Replaces the subtype in the given packed type
    }
    function replacePlotSubtype(packedType, newSubtype: integer): integer;
    begin
        Result := packPlotType(extractPlotMainType(packedType), extractPlotSize(packedType), newSubtype);
    end;

    {
        Returns whenever the subtype is set in the given packed type
    }
    function hasPlotSubtype(packedType: integer): boolean;
    begin
        Result := (extractPlotSubtype(packedType) > -1);
    end;

    {
        Returns the default subtype for the given maintype
    }
    function getDefaultSubtype(mainType: integer): integer;
    var
        subtypeArray : TJsonArray;
    begin
        // AddMessage('MainType='+IntToStr(mainType));
        subtypeArray := plotSubtypeMapping.A[mainType];
        // AddMessage('subtypeArray='+subtypeArray.toString());
        Result := subtypeArray.I[0];
    end;

    {
        If packedType has no subtype, the default one will be added.
        Returns a packedType with the subtype set
    }
    function ensurePlotSubtype(packedType: integer): integer;
    var
        mainType, subType, size: integer;
    begin
        subType  := extractPlotSubtype(packedType);

        if(subType >= 0) then begin
            Result := packedType;
            exit;
        end;
        mainType := extractPlotMainType(packedType);
        size     := extractPlotSize(packedType);
        subType  := getDefaultSubtype(mainType);

        Result := packPlotType(mainType, size, subType);
    end;
    //////////// CITY PLAN STUFF ////////////
    function prepareCityPlanBase(): IInterface;
    begin
        {
        cityPlanRootTemplate := MainRecordByEditorID(GroupBySignature(ss2masterFile, 'WEAP'), 'SS2_Template_CityPlan');
        cityPlanLayerTemplate:= MainRecordByEditorID(GroupBySignature(ss2masterFile, 'WEAP'), 'SS2_Template_CityPlanLayout');
        }

    end;

    //////////// GUI STUFF ////////////
    procedure updateSubtypeDropdown(mainType: integer; dropdown: TComboBox);
    var
        subtypeArray : TJsonArray;
        i, curIndex: integer;
        curText: string;
    begin
        dropdown.ItemIndex := -1;

        dropdown.Items.clear();

        subtypeArray := plotSubtypeMapping.A[mainType];

        for i:=0 to subtypeArray.count-1 do begin
            curIndex := subtypeArray.I[i];
            curText := plotSubtypeNames[curIndex];
            dropdown.Items.add(curText);
        end;

        if(dropdown.Items.count > 0) then begin
            dropdown.ItemIndex := 0;
        end;
    end;

    function getSubtypeIndex(mainType, subType: integer): integer;
    var
        subtypeArray : TJsonArray;
        i, curIndex: integer;
        curText: string;
    begin
        subtypeArray := plotSubtypeMapping.A[mainType];
        Result := 0;

        for i:=0 to subtypeArray.count-1 do begin
            if(subtypeArray.I[i] = subType) then begin
                Result := i;
                exit;
            end;
        end;
    end;

    function getSubtypeByIndex(mainType, subtypeIndex: integer): integer;
    var
        subtypeArray : TJsonArray;
    begin
        subtypeArray := plotSubtypeMapping.A[mainType];

        if(subtypeIndex >= subtypeArray.count) then begin
            subtypeIndex := 0;
        end;

        Result := subtypeArray.I[subtypeIndex];
    end;

    procedure themeSelectionClick(Sender: TObject);
    var
        selectedList: TStringList;
        themesLabel: TLabel;
    begin
        themesLabel := TLabel(sender.parent.FindComponent('ThemeIndicatorLabel'));
        selectedList := showThemeSelectionDialog('Building Themes', 'Select theme keywords for current building', selectedThemeTagList);
        if(selectedList <> nil) then begin
            if(selectedThemeTagList <> nil) then begin
                selectedThemeTagList.free();
                selectedThemeTagList := nil;
            end;
            selectedThemeTagList := selectedList;
        end else begin
        end;

        if(selectedThemeTagList <> nil) then begin
            themesLabel.text := 'Selected '+IntToStr(selectedThemeTagList.count)+' themes';
        end else begin
            themesLabel.text := 'No themes selected';
        end;
    end;

    procedure browseModelFile(Sender: TObject);
    var
        dialogResult: string;
    begin
        dialogResult := ShowOpenFileDialog('Select Models file', 'CSV Files|*.csv|All Files|*.*');
        if(dialogResult <> '') then begin
            stageModelInput.Text := dialogResult;
        end;
    end;

    procedure browseItemFile(Sender: TObject);
    var
        dialogResult: string;
    begin
        dialogResult := ShowOpenFileDialog('Select Stage Items file', 'CSV Files|*.csv|All Files|*.*');
        if(dialogResult <> '') then begin
            itemSpawnInput.Text := dialogResult;
        end;
    end;

    procedure buildListOfBuildingPlans();
    var
        i, j, curIndex: integer;
        curFile, weapGroup, curWeap, plotScript: IInterface;
        curEdid: string;
    begin
        if(allBuildingPlansCache <> nil) then exit;

        allBuildingPlansCache := TList.create;

        AddMessage('Building plot list (this might take a while)');
        for i := 0 to FileCount-1 do begin
            curFile := FileByIndex(i);
            weapGroup := GroupBySignature(curFile, 'WEAP');

            if(not assigned(weapGroup)) then continue;

            for j:=0 to ElementCount(weapGroup)-1 do begin
                curWeap := ElementByIndex(weapGroup, j);
                plotScript := getScript(curWeap, 'SimSettlementsV2:Weapons:BuildingPlan');
                if(assigned(plotScript)) then begin
                    allBuildingPlansCache.add(curWeap);
                end;
            end;
        end;
        AddMessage('Finished plot list building');
    end;


    procedure fillPlotList(clb: TCheckListBox; preselectedEdid: string);
    var
        i, j, curIndex: integer;
        curFile, weapGroup, curWeap, plotScript: IInterface;
        curEdid: string;
    begin
        //allBuildingPlansCache
        buildListOfBuildingPlans();

        for i := 0 to allBuildingPlansCache.count-1 do begin
            curWeap := ObjectToElement(allBuildingPlansCache[i]);
            curEdid := EditorID(curWeap);
            curIndex := clb.Items.addObject(curEdid + ' "'+GetElementEditValues(curWeap, 'FULL')+'"', curWeap);
            if(curEdid = preselectedEdid) then begin
                clb.Checked[curIndex] := true;
            end;
        end;
    end;

    procedure browseTargetPlot(Sender: TObject);
    var
        dialogResult, selectedEdid: string;
        frm: TForm;
        clb: TCheckListBox;
        selectedElem: IInterface;
        i: integer;
        realSender: TButton;
    begin
        realSender := TButton(Sender);
        realSender.enabled :=  false;

        // prepare list
        frm := frmFileSelect;
        frm.Width := 800;
        frm.Height := 500;

        selectedEdid := trim(plotEdidInput.Text);
{
        addFileBtn := CreateButton(frm, 10, 425, 'Add File');
        addFileBtn.Name := 'addFileBtn';
        addFileBtn.onclick := addFileHandler;

        addDirBtn := CreateButton(frm, 100, 425, 'Add Directory');
        addDirBtn.Name := 'addDirBtn';
        addDirBtn.onclick := addDirHandler;
}
        // frm.onresize := resourceListResize;
        try
            frm.Caption := 'Select target building plan';
            clb := TCheckListBox(frm.FindComponent('CheckListBox1'));
            // clb.multiSelect := false;
            //clb.Items.Add('<new file>');
            fillPlotList(clb, selectedEdid);

            if (frm.ShowModal = mrOk) then begin

                for i := 0 to clb.Items.Count-1 do begin
                    if clb.Checked[i] then begin
                        selectedElem := ObjectToElement(clb.Items.Objects[i]);
                        selectedEdid := EditorID(selectedElem);
                        plotEdidInput.Text := selectedEdid;
                        break;
                    end;
                end;
            end;
        finally
            realSender.enabled := true;
            frm.Free;
        end;
    end;

    procedure plotTypeChangedEventHandler(Sender: TObject);
    var
        dropdown: TComboBox;
    begin
        updatePlotDialogOkBtnState(sender);

        dropdown := TComboBox(Sender);
        updateSubtypeDropdown(dropdown.ItemIndex, plotSubtypeCombobox);

    end;

    function shouldSkinOkBtnBeEnabled(frm: TForm): boolean;
    var
        inputName, inputId, inputPrefix: TEdit;
        stageModelStr, stageItemStr, plotEdidStr: string;
    begin
        Result := true;
{
        if(assigned(plotMainTypeCombobox)) then begin
            Result := (plotSubtypeCombobox.ItemIndex > -1 and plotMainTypeCombobox.ItemIndex > -1 and plotSizeCombobox.ItemIndex > -1);
        end;
}
        if(isConvertDialogActive or (not Result)) then begin
            exit; // exit here
        end;

        // otherwise check more
        ////itemSpawnInput stageModelInput
        // StageModelFileRequired


        inputName   := TEdit(frm.FindComponent('InputPlotName'));
        inputId     := TEdit(frm.FindComponent('InputPlotId'));
        inputPrefix := TEdit(frm.FindComponent('InputModPrefix'));

        if (trim(inputName.text) = '') or (trim(inputId.text) = '') or (trim(inputPrefix.text) = '') then begin
            Result := false;
            exit;
        end;

        stageModelStr := trim(stageModelInput.text);
        stageItemStr  := trim(itemSpawnInput.text);
        plotEdidStr := trim(plotEdidInput.text);

        if(PlotEdidInputRequired) then begin
            if(plotEdidStr = '') then begin
                Result := false;
                exit;
            end;
        end;

        if (stageModelStr = '') and (stageItemStr = '') then begin
            Result := false;
            exit;
        end;

        Result := true;
    end;

    function shouldOkBtnBeEnabled(frm: TForm): boolean;
    var
        inputName, inputId, inputPrefix: TEdit;
        stageModelStr, stageItemStr: string;
    begin
        Result := true;
        if(assigned(plotMainTypeCombobox)) then begin
            Result := (plotSubtypeCombobox.ItemIndex > -1 and plotMainTypeCombobox.ItemIndex > -1 and plotSizeCombobox.ItemIndex > -1);
        end;

        if(isConvertDialogActive or (not Result)) then begin
            exit; // exit here
        end;

        // otherwise check more
        ////itemSpawnInput stageModelInput
        // StageModelFileRequired


        inputName   := TEdit(frm.FindComponent('InputPlotName'));
        inputId     := TEdit(frm.FindComponent('InputPlotId'));
        inputPrefix := TEdit(frm.FindComponent('InputModPrefix'));

        if (trim(inputName.text) = '') or (trim(inputId.text) = '') or (trim(inputPrefix.text) = '') then begin
            Result := false;
            exit;
        end;

        stageModelStr := trim(stageModelInput.text);
        stageItemStr  := trim(itemSpawnInput.text);

        if(StageModelFileRequired) then begin
            if(stageModelStr = '') then begin
                Result := false;
                exit;
            end;
        end;

        if (stageModelStr = '') and (stageItemStr = '') then begin
            Result := false;
            exit;
        end;

        Result := true;
    end;

    procedure updatePlotDialogOkBtnState(sender: TObject);
    begin
        if(plotDialogOkBtn = nil) then exit;
        plotDialogOkBtn.enabled := shouldOkBtnBeEnabled(sender.parent);
    end;

    procedure updateSkinDialogOkBtnState(sender: TObject);
    begin
        if(plotDialogOkBtn = nil) then exit;
        plotDialogOkBtn.enabled := shouldSkinOkBtnBeEnabled(sender.parent);
    end;

    procedure addPlotTypeDropdowns(frm: TForm; horizontalOffset, verticalOffset, packedType: integer);
    var
        selectedMainType, selectedSize, selectedSubType: integer;
    begin
        selectedMainType := -1;
        selectedSize     := -1;
        selectedSubType  := -1;
        if(packedType >= 0) then begin
            selectedMainType := extractPlotMainType(packedType);
            selectedSize     := extractPlotSize(packedType);
            selectedSubType  := extractPlotSubtype(packedType);
        end;

        plotMainTypeCombobox := CreateComboBox(frm, horizontalOffset, verticalOffset, 100, plotTypeNames);
        plotMainTypeCombobox.Style := csDropDownList;
        plotMainTypeCombobox.onChange := plotTypeChangedEventHandler;
        plotMainTypeCombobox.ItemIndex := selectedMainType;

        plotSizeCombobox := CreateComboBox(frm, 105+horizontalOffset, verticalOffset, 60, plotSizeNames);
        plotSizeCombobox.Style := csDropDownList;
        plotSizeCombobox.onChange := updatePlotDialogOkBtnState;
        plotSizeCombobox.ItemIndex := selectedSize;

        plotSubtypeCombobox := CreateComboBox(frm, horizontalOffset+170, verticalOffset, 175, nil);
        plotSubtypeCombobox.Style := csDropDownList;
        plotSubtypeCombobox.onChange := updatePlotDialogOkBtnState;
        updateSubtypeDropdown(selectedMainType, plotSubtypeCombobox);
        if(selectedSubType > 0) then begin
            plotSubtypeCombobox.ItemIndex := getSubtypeIndex(selectedMainType, selectedSubType);
        end;
    end;

    procedure stripThemeKeywords(plot: IInterface);
    var
        i: integer;
        curKw: IInterface;
    begin
        for i:=0 to themeTagList.count-1 do begin
            curKw := ObjectToElement(themeTagList.Objects[i]);
            removeKeywordByPath(plot, curKw, 'KWDA');
        end;
    end;

    procedure setTypeKeywords(plot: IInterface; plotType: integer);
    var
        i, mainType, subType, size: integer;
        mainTypeKw, subTypeKw, sizeKw, newScript: IInterface;
    begin
        mainType := extractPlotMainType(plotType);
        subType  := extractPlotSubtype(plotType);
        size     := extractPlotSize(plotType);

        mainTypeKw := getMainTypeKeyword(mainType);
        subTypeKw  := getSubtypeKeyword(subType);
        sizeKw     := getSizeKeyword(size);

        addKeywordByPath(plot, mainTypeKw, 'KWDA');
        addKeywordByPath(plot, subTypeKw, 'KWDA');
        addKeywordByPath(plot, sizeKw, 'KWDA');

        // IMPORTANT: also put the KW into the script props
        newScript := getScript(plot, 'SimSettlementsV2:Weapons:BuildingPlan');
        setScriptProp(newScript, 'ClassKeyword', subTypeKw);
    end;

    procedure stripTypeKeywords(plot: IInterface);
    begin
        // strip main type
        removeKeywordByPath(plot, SS2_PlotType_Agricultural, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotType_Commercial, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotType_Industrial, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotType_Martial, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotType_Municipal, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotType_Recreational, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotType_Residential, 'KWDA');

        // strip size
        removeKeywordByPath(plot, SS2_PlotSize_1x1, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotSize_2x2, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotSize_3x3, 'KWDA');
        removeKeywordByPath(plot, SS2_PlotSize_Int, 'KWDA');

        stripSubtypeKeywords(plot);
    end;

    procedure stripSubtypeKeywords(plot: IInterface);
    var
        i: integer;
        curKw: IInterface;
    begin
        for i:=0 to plotSubtypeNames.count-1 do begin
            // here, i is the subtype index
            curKw := getSubtypeKeyword(i);
            removeKeywordByPath(plot, curKw, 'KWDA');
        end;
    end;

    function showThemeSelectionDialog(title, text: string; preselected: TStringList): TStringList;
    var
        frm: TForm;
        btnOk, btnCancel: TButton;
        numKws, i, colLength, cbX, cbY, lastYcoord, resultCode: integer;
        curKw: IInterface;
        curCaption: string;
        curCb: TCheckBox;
    begin
        numKws := themeTagList.count; // 21 by default
        colLength := ceil(numKws / 3.0);
        // attempt to arrange them in 3 columns
        frm := CreateDialog(title, 570, 250);

        CreateLabel(frm, 10, 10, text);

        for i:=0 to numKws-1 do begin
            curCaption := themeTagList[i];

            {
            cbX := 10 + (i mod 3) * 200;
            cbY := 30 + floor(i/3.0) * 20;
            }

            cbX := 10 + floor(i/colLength) * 200;
            cbY := 30 + (i mod colLength) * 20;

            // function CreateCheckbox(frm: TForm; left, top: Integer; text: String): TCheckBox;
            curCb := CreateCheckbox(frm, cbX, cbY, curCaption);
            curCb.name := 'PlotThemeCheckbox_'+IntToStr(i);

            if(preselected <> nil) then begin
                if(preselected.indexOf(curCaption) >= 0) then begin
                    curCb.checked := true;
                end;
            end;

            if(cbY > lastYcoord) then lastYcoord := cbY;
        end;




        btnOk := CreateButton(frm, 150, lastYcoord+30, '  OK  ');
        btnOk.ModalResult := mrYes;
        btnOk.Default := true;

        btnCancel := CreateButton(frm, 300, lastYcoord+30, 'Cancel');
        btnCancel.ModalResult := mrCancel;

        frm.Height := lastYcoord+100;

        resultCode := frm.ShowModal();

        Result := nil;

        if(resultCode = mrYes) then begin
            Result := TStringList.create;

            for i:=0 to numKws-1 do begin
                curCb := TCheckBox(frm.FindComponent('PlotThemeCheckbox_'+IntToStr(i)));
                if(curCb.checked) then begin
                    curKw := ObjectToElement(themeTagList.Objects[i]);
                    curCaption := themeTagList[i];

                    Result.AddObject(curCaption, curKw);
                end;
            end;
        end;
        frm.free();


    end;

    {
        title: Stage Data Import
        text: Selected Blueprint: foo
        initialPlotName: DisplayName(plot)
        initialPlotId: EditorId(blueprintRoot)
        packedPlotType
        initialModPrefix: foo_

    }
    function ShowPlotCreateDialog(title, text, initialPlotName, initialPlotId, initialModPrefix: string; packedPlotType: integer; requireStageModels, isFullPlot: boolean; initialThemes: TStringList; autoRegister, makePreview, setupStacking, showDescription: boolean): TJsonObject;
    var
        frm: TForm;
        btnBrowseModel, btnBrowseItems, btnOk, btnCancel, btnThemes: TButton;
        resultCode, yOffset: integer;
        inputName, inputPlotEdid, inputModPrefix: TEdit;
        descrElem: IInterface;
        selectedMainType, selectedSize, selectedSubType: integer;
        packedResultType: integer;
        descrLabel, themesLabel: TLabel;
        registerCb, previewCb, stackCb: TCheckBox;
        themesInitialText: string;
        descriptionInput: TMemo;
    begin
        Result := nil;

        StageModelFileRequired := requireStageModels;
        isConvertDialogActive := false;
        Result := false;
        frm := CreateDialog(title, 500, 360);

        CreateLabel(frm, 10, 6, text);

        CreateLabel(frm, 10, 32, 'Name:');
        inputName := CreateInput(frm, 100, 30, initialPlotName);
        inputName.Name := 'InputPlotName';
        inputName.text := initialPlotName;
        inputName.onChange := updatePlotDialogOkBtnState;
        inputName.width := 300;

        CreateLabel(frm, 10, 58, 'Editor ID:');
        inputPlotEdid := CreateInput(frm, 100, 54, initialPlotId);
        inputPlotEdid.Name := 'InputPlotId';
        inputPlotEdid.Text := initialPlotId;
        inputPlotEdid.onChange := updatePlotDialogOkBtnState;
        inputPlotEdid.width := 300;

        CreateLabel(frm, 10, 82, 'Mod Prefix:');
        inputModPrefix := CreateInput(frm, 100, 78, initialModPrefix);
        inputModPrefix.Name := 'InputModPrefix';
        inputModPrefix.Text := initialModPrefix;
        inputModPrefix.onChange := updatePlotDialogOkBtnState;
        inputModPrefix.width := 300;

        if(packedPlotType >= 0) then begin
            CreateLabel(frm, 10, 113, 'Plot Type:');

            addPlotTypeDropdowns(frm, 100, 110, packedPlotType);
        end;

        yOffset := 145;
        if(isFullPlot) then begin
            if(selectedThemeTagList <> nil) then begin
                selectedThemeTagList.free();
                selectedThemeTagList := nil;
            end;
            if(initialThemes <> nil) then begin
                selectedThemeTagList := TStringList.create;
                selectedThemeTagList.assign(initialThemes);
            end;

            CreateLabel(frm, 10, yOffset+5, 'Themes');
            btnThemes := CreateButton(frm, 70, yOffset, 'Select Themes...');
            btnThemes.onclick := themeSelectionClick;

            if(initialThemes <> nil) then begin
                themesInitialText := 'Selected '+IntToStr(initialThemes.count)+' themes';
            end else begin
                themesInitialText := 'No themes selected';
            end;
            themesLabel := CreateLabel(frm, 290, yOffset+5, themesInitialText);
            themesLabel.name := 'ThemeIndicatorLabel';
        end;

        yOffset := yOffset+35;

        descriptionInput := nil;

        if (showDescription) and (isFullPlot) then begin


            descriptionInput := TMemo.create(frm);

            descrLabel := CreateLabel(frm, 10, yOffset,
                'Description' + STRING_LINE_BREAK +
                '(Without subtype prefix)'
            );

            descriptionInput.Parent := frm;
            descriptionInput.Left := 150;
            descriptionInput.Top := yOffset;
            descriptionInput.Width := 290;
            descriptionInput.height := 50;
            // descriptionInput.Text := escapeString(text);

            descrLabel.AutoSize := False;
            descrLabel.WordWrap := True;
            descrLabel.Width := 120;
            descrLabel.Height := 60;

            yOffset := yOffset + 60;
            frm.height := (frm.height + 60);
        end;

        registerCb := CreateCheckbox(frm, 10, yOffset+2, 'Register Building Plan');
        previewCb  := CreateCheckbox(frm, 160, yOffset+2, 'Setup building previews');
        stackCb  := CreateCheckbox(frm, 320, yOffset+2, 'Setup stacked moving');

        //autoRegister, makePreview
        registerCb.checked := autoRegister;
        previewCb.checked := makePreview;
        stackCb.checked := setupStacking;

        if(not isFullPlot) then begin
            // registerCb.checked := false;
            registerCb.Enabled := false;
        end;

        yOffset := yOffset + 25;


        CreateLabel(frm, 10, yOffset+2, 'Models file:');
        stageModelInput := CreateInput(frm, 10, yOffset+20, '');
        stageModelInput.Name := 'InputStageModels';
        stageModelInput.Text := '';
        stageModelInput.onChange := updatePlotDialogOkBtnState;
        stageModelInput.width := 430;

        btnBrowseModel := CreateButton(frm, 450, yOffset+18, '...');
        btnBrowseModel.OnClick := browseModelFile;

        yOffset := yOffset + 35;

        CreateLabel(frm, 10, yOffset+12, 'Stage Items file:');
        itemSpawnInput := CreateInput(frm, 10, yOffset+30, '');
        itemSpawnInput.Name := 'InputStageItems';
        itemSpawnInput.Text := '';
        itemSpawnInput.onChange := updatePlotDialogOkBtnState;
        itemSpawnInput.width := 430;

        btnBrowseItems := CreateButton(frm, 450, yOffset+28, '...');
        btnBrowseItems.OnClick := browseItemFile;

        yOffset := yOffset + 50;

        btnOk := CreateButton(frm, 100, yOffset+10, 'Start');
        btnOk.ModalResult := mrYes;
        btnOk.Default := true;

        plotDialogOkBtn := btnOk;

        btnCancel := CreateButton(frm, 300, yOffset+10, 'Cancel');
        btnCancel.ModalResult := mrCancel;

        updatePlotDialogOkBtnState(btnCancel);

        resultCode := frm.ShowModal();

        if(resultCode = mrYes) then begin
            Result := TJsonObject.create;



            //stageFilePath := Trim(stageModelInput.Text);
            //itemFilePath  := Trim(itemSpawnInput.Text);

            //plotName        := Trim(inputName.text);
            //plotId          := Trim(inputPlotEdid.text);
            //modPrefix       := Trim(inputModPrefix.text);

            if(packedPlotType >= 0) then begin
                selectedMainType := plotMainTypeCombobox.ItemIndex;
                selectedSize     := plotSizeCombobox.ItemIndex;
                selectedSubType  := getSubtypeByIndex(selectedMainType, plotSubtypeCombobox.ItemIndex);

                Result.I['type'] := packPlotType(selectedMainType, selectedSize, selectedSubType);
            end else begin
                Result.I['type'] := -1;
            end;
            Result.S['modelsFile'] := Trim(stageModelInput.Text);
            Result.S['itemsFile'] := Trim(itemSpawnInput.Text);
            Result.S['name'] := Trim(inputName.text);
            Result.S['edid'] := Trim(inputPlotEdid.text);
            Result.S['prefix'] := Trim(inputModPrefix.text);

            Result.B['registerPlot'] := registerCb.checked;
            Result.B['makePreview'] := previewCb.checked;
            Result.B['setupStacking'] := stackCb.checked;

            if(descriptionInput <> nil) then begin
                Result.S['description'] := descriptionInput.Text;

            end;

        end;

        frm.free();

    end;


    ///AAA
    function ShowSkinCreateDialog(title, text, initialPlotName, initialPlotId, initialModPrefix: string; existingPlotTarget: IInterface; isFullSkin: boolean; initialThemes: TStringList; autoRegister, makePreview, setupStacking: boolean): TJsonObject;
    var
        frm: TForm;
        btnBrowseModel, btnBrowseItems, btnBrowsePlots, btnOk, btnCancel, btnThemes: TButton;
        resultCode, yOffset: integer;
        inputName, inputPlotEdid, inputModPrefix: TEdit;
        descrElem: IInterface;
        selectedMainType, selectedSize, selectedSubType: integer;
        packedResultType: integer;
        spawnsModeSelector: TRadioGroup;
        themesLabel: TLabel;
        registerCb, previewCb, stackCb: TCheckBox;
        themesInitialText: string;
    begin
        Result := nil;

        PlotEdidInputRequired := true;
        if (assigned(existingPlotTarget) or (not isFullSkin)) then begin
            PlotEdidInputRequired := false;
        end;
        StageModelFileRequired := false;
        isConvertDialogActive := false;
        Result := false;
        frm := CreateDialog(title, 500, 400);

        CreateLabel(frm, 10, 6, text);

        CreateLabel(frm, 10, 32, 'Name:');
        inputName := CreateInput(frm, 100, 30, initialPlotName);
        inputName.Name := 'InputPlotName';
        inputName.text := initialPlotName;
        inputName.onChange := updateSkinDialogOkBtnState;
        inputName.width := 300;

        CreateLabel(frm, 10, 58, 'Editor ID:');
        inputPlotEdid := CreateInput(frm, 100, 54, initialPlotId);
        inputPlotEdid.Name := 'InputPlotId';
        inputPlotEdid.Text := initialPlotId;
        inputPlotEdid.onChange := updateSkinDialogOkBtnState;
        inputPlotEdid.width := 300;

        CreateLabel(frm, 10, 82, 'Mod Prefix:');
        inputModPrefix := CreateInput(frm, 100, 78, initialModPrefix);
        inputModPrefix.Name := 'InputModPrefix';
        inputModPrefix.Text := initialModPrefix;
        inputModPrefix.onChange := updateSkinDialogOkBtnState;
        inputModPrefix.width := 300;

        // parent plot edid
        yOffset := 100;

        CreateLabel(frm, 10, yOffset+2, 'Target Building Plan (EditorID):');
        plotEdidInput := CreateInput(frm, 10, yOffset+20, '');
        plotEdidInput.Name := 'InputPlotEdid';
        plotEdidInput.Text := '';
        plotEdidInput.onChange := updateSkinDialogOkBtnState;
        plotEdidInput.width := 430;

        btnBrowsePlots := CreateButton(frm, 450, yOffset+18, '...');
        btnBrowsePlots.OnClick := browseTargetPlot;
        if(not isFullSkin) then begin
            plotEdidInput.Enabled := false;
            btnBrowsePlots.Enabled := false;
        end else if (assigned(existingPlotTarget)) then begin
            // disable the shit
            plotEdidInput.Enabled := false;
            btnBrowsePlots.Enabled := false;
            plotEdidInput.Text := EditorID(existingPlotTarget);
        end;

        {
        isFullSkin: as opposed to just a level
        }
        yOffset := yOffset + 50;
        if(isFullSkin) then begin
            if(selectedThemeTagList <> nil) then begin
                selectedThemeTagList.free();
                selectedThemeTagList := nil;
            end;
            if(initialThemes <> nil) then begin
                selectedThemeTagList := TStringList.create;
                selectedThemeTagList.assign(initialThemes);
            end;

            CreateLabel(frm, 10, yOffset+5, 'Skin Theme');
            btnThemes := CreateButton(frm, 70, yOffset, 'Select Themes...');
            btnThemes.onclick := themeSelectionClick;

            if(initialThemes <> nil) then begin
                themesInitialText := 'Selected '+IntToStr(initialThemes.count)+' themes';
            end else begin
                themesInitialText := 'No themes selected';
            end;
            themesLabel := CreateLabel(frm, 290, yOffset+5, themesInitialText);
            themesLabel.name := 'ThemeIndicatorLabel';
        end;
        yOffset := yOffset + 30;
        registerCb := CreateCheckbox(frm, 10, yOffset+2, 'Register Skin');
        previewCb  := CreateCheckbox(frm, 160, yOffset+2, 'Setup building previews');
        stackCb    := CreateCheckbox(frm, 320, yOffset+2, 'Setup stacked moving');

        registerCb.checked := autoRegister;
        if(not isFullSkin) then begin
            registerCb.Enabled := false;
        end;
        previewCb.checked := makePreview;
        stackCb.checked := setupStacking;

        yOffset := yOffset + 30;


        CreateLabel(frm, 10, yOffset+2, 'Models file:');
        stageModelInput := CreateInput(frm, 10, yOffset+20, '');
        stageModelInput.Name := 'InputStageModels';
        stageModelInput.Text := '';
        stageModelInput.onChange := updateSkinDialogOkBtnState;
        stageModelInput.width := 430;

        btnBrowseModel := CreateButton(frm, 450, yOffset+18, '...');
        btnBrowseModel.OnClick := browseModelFile;

        yOffset := yOffset + 40;

        CreateLabel(frm, 10, yOffset+2, 'Stage Items:');
        itemSpawnInput := CreateInput(frm, 10, yOffset+20, '');
        itemSpawnInput.Name := 'InputStageItems';
        itemSpawnInput.Text := '';
        itemSpawnInput.onChange := updateSkinDialogOkBtnState;
        itemSpawnInput.width := 430;

        btnBrowseItems := CreateButton(frm, 450, yOffset+18, '...');
        btnBrowseItems.OnClick := browseItemFile;

        yOffset := yOffset + 40;

        // extra input for skins
        spawnsModeSelector := TRadioGroup.create(frm);
        spawnsModeSelector.Parent := frm;
        spawnsModeSelector.Left := 10;
        spawnsModeSelector.Top := yOffset + 2;
        spawnsModeSelector.Text := 'Spawns Mode';
        spawnsModeSelector.Height := 40;
        spawnsModeSelector.Columns := 2;

        spawnsModeSelector.Items.Add('Replace');
        spawnsModeSelector.Items.Add('Append');

        spawnsModeSelector.ItemIndex := 0;

        yOffset := yOffset + 50;
        // yOffset := yOffset + 170;

        // BUTTONS
        btnOk := CreateButton(frm, 100, yOffset, 'Start');
        btnOk.ModalResult := mrYes;
        btnOk.Default := true;

        plotDialogOkBtn := btnOk;

        btnCancel := CreateButton(frm, 300, yOffset, 'Cancel');
        btnCancel.ModalResult := mrCancel;


        updateSkinDialogOkBtnState(btnCancel);

        resultCode := frm.ShowModal();

        if(resultCode = mrYes) then begin
            Result := TJsonObject.create;



            //stageFilePath := Trim(stageModelInput.Text);
            //itemFilePath  := Trim(itemSpawnInput.Text);

            //plotName        := Trim(inputName.text);
            //plotId          := Trim(inputPlotEdid.text);
            //modPrefix       := Trim(inputModPrefix.text);
            Result.S['targetPlot'] := Trim(plotEdidInput.Text);
            {
            if(packedPlotType >= 0) then begin
                selectedMainType := plotMainTypeCombobox.ItemIndex;
                selectedSize     := plotSizeCombobox.ItemIndex;
                selectedSubType  := getSubtypeByIndex(selectedMainType, plotSubtypeCombobox.ItemIndex);

                Result.I['type'] := packPlotType(selectedMainType, selectedSize, selectedSubType);
            end else begin
                Result.I['type'] := -1;
            end;
            }

            Result.S['modelsFile'] := Trim(stageModelInput.Text);
            Result.S['itemsFileAdd'] := Trim(itemSpawnInput.Text);
            // Result.S['itemsFileReplace'] := Trim(itemSpawnInputReplace.Text);
            Result.S['name'] := Trim(inputName.text);
            Result.S['edid'] := Trim(inputPlotEdid.text);
            Result.S['prefix'] := Trim(inputModPrefix.text);
            Result.B['itemsReplace'] := (spawnsModeSelector.ItemIndex = 0);

            Result.B['registerPlot'] := registerCb.checked;
            Result.B['makePreview'] := previewCb.checked;
            Result.B['setupStacking'] := stackCb.checked;

        end;

        frm.free();

    end;

end.
