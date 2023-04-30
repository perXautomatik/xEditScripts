unit mpLoader;

interface

uses
  Classes,
  // mte units
  mteHelpers, mteBase,
  // mp units
  mpConfiguration;

  { Initialization Methods }
  function InitBase: boolean;
  function GamePathValid(path: string; id: integer): boolean;
  procedure SetGame(id: integer);
  function GetGameID(name: string): integer;
  function GetGamePath(mode: TGameMode): string;
  procedure LoadDefinitions;
  { Mod Organizer methods }
  procedure ModOrganizerInit;
  function GetActiveProfile: string;
  procedure GetActiveMods(var modlist: TStringList; profileName: string);
  { Load order functions }
  procedure RemoveCommentsAndEmpty(var sl: TStringList);
  procedure RemoveMissingFiles(var sl: TStringList);
  procedure RemoveMergedPlugins(var sl: TStringList);
  procedure FixLoadOrder(var sl: TStringList; filename: String; index: Integer);
  procedure AddMissingFiles(var sl: TStringList);
  procedure GetPluginDates(var sl: TStringList);
  function PluginListCompare(List: TStringList; Index1, Index2: Integer): Integer;

var
  slPlugins: TStringList;
  UpdateCallback: TCallback;

implementation

uses
  SysUtils, StrUtils, IniFiles, ShlObj, Controls,
  // mte units
  mteTracker, mteLogger, mteLogging, mtePluginSelectionForm,
  // mp units
  mpCore, mpClient,
  // mp forms
  // xEdit units
  wbHelpers, wbInterface, wbImplementation, wbBSA,
  wbDefinitionsFNV, wbDefinitionsFO3, wbDefinitionsTES3, wbDefinitionsTES4,
  wbDefinitionsTES5, wbDefinitionsFO4;


{******************************************************************************}
{ Initialization Methods
  Methods that are used for initialization.

  List of methods:
  - GamePathValid
  - SetGame
  - GetGameID
  - GetGamePath
  - LoadDataPath
  - LoadDefinitions
  - InitPapyrus
}
{******************************************************************************}

function InitBase: boolean;
var
  sLoadPath, sPath: string;
  slLoadOrder: TStringList;
  psForm: TPluginSelectionForm;
begin
  Result := false;

  // INITIALIZE VARIABLES
  LogPath := PathList.Values['ProgramPath'] + 'logs\';
  PathList.Values['TempPath'] := PathList.Values['ProgramPath'] + 'temp\';
  PathList.Values['ProfilePath'] := PathList.Values['ProgramPath'] +
    'profiles\'+ CurrentProfile.name + '\';
  ForceDirectories(PathList.Values['TempPath']);
  ForceDirectories(LogPath);
  ForceDirectories(PathList.Values['ProfilePath']);
  LocalStatus := TmpStatus.Create;
  LastStatusTime := 0;

  // SET GAME VARS
  SetGame(CurrentProfile.gameMode);
  wbVWDInTemporary := wbGameMode in [gmSSE, gmTES5, gmFO3, gmFNV];
  wbVWDAsQuestChildren := wbGameMode = gmFO4;
  wbArchiveExtension := IfThen(wbGameMode = gmFO4, '.ba2', '.bsa');
  wbLoadBSAs := wbGameMode in [gmFO4, gmSSE, gmTES5, gmTES4];
  Logger.Write('GENERAL', 'Game', 'Using '+wbGameName);
  Logger.Write('GENERAL', 'Path', 'Using '+wbDataPath);

  // INITIALIZE SETTINGS FOR GAME
  LoadSettings;
  LoadLanguage;
  if settings.usingMO then
    ModOrganizerInit;

  // INITIALIZE TES5EDIT API
  wbDisplayLoadOrderFormID := True;
  wbSortSubRecords := True;
  wbDisplayShorterNames := True;
  wbHideUnused := True;
  wbHideIgnored := False;
  wbFlagsAsArray := True;
  wbRequireLoadOrder := True;
  wbLanguage := settings.language;
  wbEditAllowed := True;
  wbContainerHandler := wbCreateContainerHandler;
  wbContainerHandler._AddRef;

  // IF AUTOMATIC UPDATING IS ENABLED, CHECK FOR UPDATE
  InitializeClient;
  if settings.updateDictionary or settings.updateProgram then try
    Tracker.Write('Checking for updates');
    ConnectToServer;
    if TCPClient.Connected then begin
      UpdateCallback;
      if ProgramStatus.bInstallUpdate then
        exit;
    end;
  except
    on x: Exception do
      Logger.Write('CLIENT', 'Update', 'Failed to get automatic update '+x.Message);
  end;

  // INITIALIZE DICTIONARY
  Logger.Write('GENERAL', 'Dictionary', 'Using '+wbAppName+'Dictionary.txt');
  LoadDictionary;

  // INITIALIZE TES5EDIT DEFINITIONS
  Logger.Write('GENERAL', 'Definitions', 'Using '+wbAppName+'Edit Definitions');
  LoadDefinitions;

  // LOAD MERGES
  Tracker.Write('Loading merges');
  LoadMerges;

  // GET LOAD ORDER PATH
  sLoadPath := settings.ManagerPath + 'profiles\'+ActiveModProfile+'\';
  if (not settings.usingMO) or (not DirectoryExists(sLoadPath)) then begin
    if settings.usingMO then
      Logger.Write('GENERAL', 'Load Order', 'Couldn''t find MO profile folder '+sLoadPath);
    sLoadPath := GetCSIDLShellFolder(CSIDL_LOCAL_APPDATA) + wbGameName2+'\';
  end;
  Logger.Write('GENERAL', 'Load Order', 'Using '+sLoadPath);

  // LOAD LIST OF ACTIVE PLUGINS (plugins.txt)
  slPlugins := TStringList.Create;
  sPath := sLoadPath + 'plugins.txt';
  if FileExists(sPath) then
    slPlugins.LoadFromFile(sPath)
  else
    AddMissingFiles(slPlugins);

  // PREPARE PLUGINS LIST
  RemoveCommentsAndEmpty(slPlugins);
  RemoveMissingFiles(slPlugins);
  RemoveMergedPlugins(slPlugins);

  // LOAD ORDER OF ALL PLUGINS (loadorder.txt)
  slLoadOrder := TStringList.Create;
  sPath := sLoadPath + 'loadorder.txt';
  if FileExists(sPath) then
    slLoadOrder.LoadFromFile(sPath)
  else
    slLoadOrder.AddStrings(slPlugins);

  // PREPARE LOAD ORDER
  RemoveCommentsAndEmpty(slLoadOrder);
  RemoveMissingFiles(slLoadOrder);
  AddMissingFiles(slLoadOrder);

  // if GameMode is not Skyrim, SkyrimSE or Fallout 4 and user
  // isn't using MO, sort by date modified else add base masters
  // to load order if missing
  if (wbGameMode = gmTES5) or (wbGameMode = gmSSE) then begin
    FixLoadOrder(slLoadOrder, 'Skyrim.esm', 0);
    FixLoadOrder(slLoadOrder, 'Update.esm', 1);
  end
  else if (wbGameMode = gmFO4) then begin
    FixLoadOrder(slLoadOrder, 'Fallout4.esm', 0);
  end
  else begin
    if not settings.usingMO then begin
      GetPluginDates(slPlugins);
      GetPluginDates(slLoadOrder);
      slPlugins.CustomSort(PluginListCompare);
      slLoadOrder.CustomSort(PluginListCompare);
    end;
  end;

  // DISPLAY PLUGIN SELECTION FORM
  THeaderHelpers.LoadPluginHeaders(slLoadOrder);
  psForm := TPluginSelectionForm.Create(nil);
  psForm.slCheckedPlugins := slPlugins;
  psForm.slAllPlugins := slLoadOrder;
  psForm.sColumns := 'Plugin,Merge';
  psForm.GetPluginInfo := TMergeHelpers.GetMergeForPlugin;
  psForm.GetPluginMasters := THeaderHelpers.GetPluginMasters;
  psForm.GetPluginDependencies := THeaderHelpers.GetPluginDependencies;
  if psForm.ShowModal = mrCancel then
    exit;
  slPlugins.Text := psForm.slCheckedPlugins.Text;
  psForm.Free;
  wbFileForceClosed;
  FreeList(HeaderList);

  // ALL DONE
  Result := true;
end;

{ Check if game paths are valid }
function GamePathValid(path: string; id: integer): boolean;
begin
  Result := FileExists(path + GameArray[id].exeName)
    and DirectoryExists(path + 'Data');
end;

{ Sets the game mode in the TES5Edit API }
procedure SetGame(id: integer);
begin
  ProgramStatus.GameMode := GameArray[id];
  wbGameName := ProgramStatus.GameMode.gameName;
  wbGameName2 := ProgramStatus.GameMode.regName;
  wbGameMode := ProgramStatus.GameMode.gameMode;
  wbAppName := ProgramStatus.GameMode.appName;
  wbDataPath := CurrentProfile.gamePath + 'Data\';
  // set general paths
  PathList.Values['DataPath'] := wbDataPath;
  PathList.Values['GamePath'] := UpDirectory(wbDataPath)
end;

{ Get the game ID associated with a game long name }
function GetGameID(name: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := Low(GameArray) to High(GameArray) do
    if GameArray[i].longName = name then begin
      Result := i;
      exit;
    end;
end;

{ Gets the path of a game from registry key or app path }
function GetGamePath(mode: TGameMode): string;
const
  sBethRegKey     = '\SOFTWARE\Bethesda Softworks\';
  sBethRegKey64   = '\SOFTWARE\Wow6432Node\Bethesda Softworks\';
  sSteamRegKey    = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'+
    'Steam App ';
  sSteamRegKey64  = '\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\'+
    'Uninstall\Steam App ';
var
  i: Integer;
  regName: string;
  keys, appIDs: TStringList;
begin
  Result := '';

  // initialize variables
  regName := mode.regName;
  keys := TStringList.Create;
  appIDs := TStringList.Create;
  appIDs.CommaText := mode.appIDs;

  // add keys to check
  keys.Add(sBethRegKey + regName + '\Installed Path');
  keys.Add(sBethRegKey64 + regName + '\Installed Path');
  for i := 0 to Pred(appIDs.Count) do begin
    keys.Add(sSteamRegKey + appIDs[i] + '\InstallLocation');
    keys.Add(sSteamRegKey64 + appIDs[i] + '\InstallLocation');
  end;

  // try to find path from registry
  Result := TryRegistryKeys(keys);

  // free memory
  keys.Free;
  appIDs.Free;

  // set result
  if Result <> '' then
    Result := IncludeTrailingPathDelimiter(Result);
end;

{ Loads definitions based on wbGameMode }
procedure LoadDefinitions;
begin
  case wbGameMode of
    gmTES5: DefineTES5;
    gmFNV: DefineFNV;
    gmTES4: DefineTES4;
    gmFO3: DefineFO3;
    gmFO4: DefineFO4;
    gmSSE: DefineTES5;
  end;
end;


{******************************************************************************}
{ Mod Organizer methods
  Set of methods that allow interaction Mod Organizer settings.

  List of methods:
  - ModOrganizerInit
  - GetActiveProfile
  - GetActiveMods
  - GetModContainingFile
}
{******************************************************************************}

procedure ModOrganizerInit;
begin
  ActiveMods := TStringList.Create;
  ActiveModProfile := GetActiveProfile;
  GetActiveMods(ActiveMods, ActiveModProfile);
  //Logger.Write('GENERAL', 'ModOrganizer', 'ActiveMods: '#13#10+ActiveMods.Text);
end;

function GetActiveProfile: string;
var
  ini : TMemIniFile;
  fname : string;
begin
  // exit if not using MO
  Result := '';
  if (not settings.usingMO) or (Trim(settings.ManagerPath) = '') then
    exit;

  // load ini file
  fname := settings.ManagerPath + 'ModOrganizer.ini';
  if(not FileExists(fname)) then begin
    Logger.Write('GENERAL', 'ModOrganizer', 'Mod Organizer ini file ' + fname + ' does not exist');
    exit;
  end;
  ini := TMemIniFile.Create(fname);

  // get selected_profile
  Result := ini.ReadString( 'General', 'selected_profile', '');
  ini.Free;
end;

procedure GetActiveMods(var modlist: TStringList; profileName: string);
var
  modlistFilePath: string;
  s: string;
  i: integer;
begin
  // exit if not using MO
  if (not settings.usingMO) or (Trim(settings.ManagerPath) = '') then
    exit;

  // prepare to load modlist
  modlistFilePath := settings.ManagerPath + 'profiles/' + profileName + '/modlist.txt';
  modlist.Clear;

  // exit if modlist file doesn't exist
  if not (FileExists(modlistFilePath)) then begin
    Tracker.Write('Cannot find modlist ' + modListFilePath);
    Logger.Write('GENERAL', 'ModOrganizer', 'Cannot find modlist ' + modListFilePath);
    exit;
  end;

  // load modlist
  modlist.LoadFromFile(modlistFilePath);
  for i := Pred(modlist.Count) downto 0 do begin
    s := modList[i];
    // if line starts with '+', then it's an active mod
    if (Pos('+', s) = 1) then
      modlist[i] := Copy(s, 2, Length(s) - 1)
    // else it's a comment or inactive mod, so delete it
    else
      modlist.Delete(i);
  end;
end;


{******************************************************************************}
{ Load order functions
  Set of functions for building a working load order.

  List of functions:
  - RemoveCommentsAndEmpty
  - RemoveMissingFiles
  - AddMissingFiles
  - PluginListCompare
{******************************************************************************}

{ Remove comments and empty lines from a stringlist }
procedure RemoveCommentsAndEmpty(var sl: TStringList);
var
  i, j, k: integer;
  s: string;
begin
  for i := Pred(sl.Count) downto 0 do begin
    s := Trim(sl.Strings[i]);
    j := Pos('#', s);
    k := Pos('*', s);
    if j > 0 then
      System.Delete(s, j, High(Integer));
    if s = '' then
      sl.Delete(i);
    if k = 1 then
      sl[i] := Copy(s, 2, Length(s));
  end;
end;

{ Remove nonexistent files from stringlist }
procedure RemoveMissingFiles(var sl: TStringList);
var
  i: integer;
begin
  for i := Pred(sl.Count) downto 0 do
    if not FileExists(wbDataPath + sl.Strings[i]) then
      sl.Delete(i);
end;

{ Remove merged plugins from stringlist }
procedure RemoveMergedPlugins(var sl: TStringList);
var
  i: integer;
begin
  for i := Pred(sl.Count) downto 0 do
    if Assigned(TMergeHelpers.MergeByFilename(MergesList, sl[i])) then
      sl.Delete(i);
end;

{ Forces a plugin to load at a specific position }
procedure FixLoadOrder(var sl: TStringList; filename: String; index: Integer);
var
  oldIndex: Integer;
begin
  oldIndex := sl.IndexOf(filename);
  if oldIndex <> index then begin
    sl.Delete(oldIndex);
    sl.Insert(index, filename);
  end;
end;

{ Add missing *.esp and *.esm files to list }
procedure AddMissingFiles(var sl: TStringList);
var
  F: TSearchRec;
  i, j: integer;
  slNew: TStringList;
begin
  slNew := TStringList.Create;
  try
    // search for missing plugins and masters
    if FindFirst(wbDataPath + '*.*', faAnyFile, F) = 0 then try
      repeat
        if not (IsFileESM(F.Name) or IsFileESP(F.Name)) then
          continue;
        if sl.IndexOf(F.Name) = -1 then
          slNew.AddObject(F.Name, TObject(FileAge(wbDataPath + F.Name)));
      until FindNext(F) <> 0;
    finally
      FindClose(F);
    end;

    // sort the list
    slNew.CustomSort(PluginListCompare);

    // The for loop won't initialize j if sl.count = 0, we must force it
    // to -1 so inserting will happen at index 0
    if sl.Count = 0 then
      j := -1
    else
      // find position of last master
      for j := Pred(sl.Count) downto 0 do
        if IsFileESM(sl[j]) then
          Break;

    // add esm masters after the last master, add esp plugins at the end
    Inc(j);
    for i := 0 to Pred(slNew.Count) do begin
      if IsFileESM(slNew[i]) then begin
        sl.InsertObject(j, slNew[i], slNew.Objects[i]);
        Inc(j);
      end else
        sl.AddObject(slNew[i], slNew.Objects[i]);
    end;
  finally
    slNew.Free;
  end;
end;

{ Get date modified for plugins in load order and store in stringlist objects }
procedure GetPluginDates(var sl: TStringList);
var
  i: Integer;
begin
  for i := 0 to Pred(sl.Count) do
    sl.Objects[i] := TObject(FileAge(wbDataPath + sl[i]));
end;

{ Compare function for sorting load order by date modified/esms }
function PluginListCompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  IsESM1, IsESM2: Boolean;
  FileAge1,FileAge2: Integer;
  FileDateTime1, FileDateTime2: TDateTime;
begin
  IsESM1 := IsFileESM(List[Index1]);
  IsESM2 := IsFileESM(List[Index2]);

  if IsESM1 = IsESM2 then begin
    FileAge1 := Integer(List.Objects[Index1]);
    FileAge2 := Integer(List.Objects[Index2]);

    if FileAge1 < FileAge2 then
      Result := -1
    else if FileAge1 > FileAge2 then
      Result := 1
    else begin
      if not SameText(List[Index1], List[Index1])
      and FileAge(List[Index1], FileDateTime1) and FileAge(List[Index2], FileDateTime2) then begin
        if FileDateTime1 < FileDateTime2 then
          Result := -1
        else if FileDateTime1 > FileDateTime2 then
          Result := 1
        else
          Result := 0;
      end else
        Result := 0;
    end;

  end else if IsESM1 then
    Result := -1
  else
    Result := 1;
end;

{ Log Initialization }
procedure InitLog;
begin
  // INITIALIZE GROUP FILTERS
  GroupFilters.Add(TFilter.Create('GENERAL', true));
  GroupFilters.Add(TFilter.Create('LOAD', true));
  GroupFilters.Add(TFilter.Create('CLIENT', true));
  GroupFilters.Add(TFilter.Create('MERGE', true));
  GroupFilters.Add(TFilter.Create('PLUGIN', true));
  GroupFilters.Add(TFilter.Create('ERROR', true));
  // INITIALIZE LABEL FILTERS
  LabelFilters.Add(TFilter.Create('GENERAL', 'Game', true));
  LabelFilters.Add(TFilter.Create('GENERAL', 'Status', true));
  LabelFilters.Add(TFilter.Create('GENERAL', 'Path', true));
  LabelFilters.Add(TFilter.Create('GENERAL', 'Definitions', true));
  LabelFilters.Add(TFilter.Create('GENERAL', 'Dictionary', true));
  LabelFilters.Add(TFilter.Create('GENERAL', 'Load Order', true));
  LabelFilters.Add(TFilter.Create('GENERAL', 'Log', true));
  LabelFilters.Add(TFilter.Create('LOAD', 'Order', false));
  LabelFilters.Add(TFilter.Create('LOAD', 'Plugins', false));
  LabelFilters.Add(TFilter.Create('LOAD', 'Background', true));
  LabelFilters.Add(TFilter.Create('CLIENT', 'Connect', true));
  LabelFilters.Add(TFilter.Create('CLIENT', 'Login', true));
  LabelFilters.Add(TFilter.Create('CLIENT', 'Response', true));
  LabelFilters.Add(TFilter.Create('CLIENT', 'Update', true));
  LabelFilters.Add(TFilter.Create('CLIENT', 'Report', true));
  LabelFilters.Add(TFilter.Create('MERGE', 'Status', false));
  LabelFilters.Add(TFilter.Create('MERGE', 'Create', true));
  LabelFilters.Add(TFilter.Create('MERGE', 'Edit', true));
  LabelFilters.Add(TFilter.Create('MERGE', 'Check', true));
  LabelFilters.Add(TFilter.Create('MERGE', 'Clean', true));
  LabelFilters.Add(TFilter.Create('MERGE', 'Delete', true));
  LabelFilters.Add(TFilter.Create('MERGE', 'Build', true));
  LabelFilters.Add(TFilter.Create('MERGE', 'Report', true));
  LabelFilters.Add(TFilter.Create('PLUGIN', 'Report', true));
  LabelFilters.Add(TFilter.Create('PLUGIN', 'Check', true));
  LabelFilters.Add(TFilter.Create('PLUGIN', 'Other', true));
end;

end.
