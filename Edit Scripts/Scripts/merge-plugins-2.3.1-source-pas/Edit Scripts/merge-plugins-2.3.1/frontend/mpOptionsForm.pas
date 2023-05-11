unit mpOptionsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ImgList, FileCtrl, ExtCtrls, Types,
  // mte units
  mteHelpers, RttiTranslation,
  // mp units
  mpCore, mpConfiguration, mpClient,
  // mp forms
  mteChangeLogForm;

type
  TOptionsForm = class(TForm)
    [FormPrefix('mpOpt')]
      SettingsPageControl: TPageControl;
      btnCancel: TButton;
      btnOK: TButton;
      IconList: TImageList;
      [FormSection('General Tab')]
        GeneralTabSheet: TTabSheet;
        gbLanguage: TGroupBox;
        lblLanguage: TLabel;
        gbStyle: TGroupBox;
        kbSimpleDictionary: TCheckBox;
        kbSimplePlugins: TCheckBox;
        gbReports: TGroupBox;
        lblUsername: TLabel;
        edUsername: TEdit;
        btnRegister: TButton;
        lblStatus: TLabel;
        lblStatusValue: TLabel;
        btnReset: TButton;
        gbUpdating: TGroupBox;
        kbUpdateDictionary: TCheckBox;
        lblDictionaryStatus: TLabel;
        btnUpdateDictionary: TButton;
        kbUpdateProgram: TCheckBox;
        lblProgramStatus: TLabel;
        btnUpdateProgram: TButton;
        [FormSection('DontTranslate')]
          cbLanguage: TComboBox;
      [FormSection('Merging Tab')]
        MergingTabSheet: TTabSheet;
        gbAssetHandling: TGroupBox;
        lblMergeDestination: TLabel;
        edMergeDirectory: TEdit;
        btnBrowseAssetDirectory: TSpeedButton;
        kbFaceGen: TCheckBox;
        kbVoiceAssets: TCheckBox;
        kbTranslations: TCheckBox;
        kbINIs: TCheckBox;
        kbFragments: TCheckBox;
        kbSelfRef: TCheckBox;
        kbSEQ: TCheckBox;
        kbExtractBSAs: TCheckBox;
        kbBuildBSA: TCheckBox;
        kbBatCopy: TCheckBox;
        gbDebug: TGroupBox;
        kbDebugRenumbering: TCheckBox;
        kbDebugMergeStatus: TCheckBox;
        kbDebugAssetCopying: TCheckBox;
        kbDebugRecordCopying: TCheckBox;
        kbDebugMasters: TCheckBox;
        kbDebugBatchCopying: TCheckBox;
        kbDebugBSAs: TCheckBox;
        kbDebugScriptFragments: TCheckBox;
        btnVerifyAccess: TButton;
      [FormSection('Advanced Tab')]
        AdvancedTabSheet: TTabSheet;
        gbMergeProfile: TGroupBox;
        lblCurrentProfile: TLabel;
        btnChangeMergeProfile: TButton;
        gbBackend: TGroupBox;
        lblHost: TLabel;
        lblPort: TLabel;
        kbNoStatistics: TCheckBox;
        gbLogging: TGroupBox;
        lblClientColor: TLabel;
        cbClientColor: TColorBox;
        lblGeneralColor: TLabel;
        cbGeneralColor: TColorBox;
        lblLoadColor: TLabel;
        cbLoadColor: TColorBox;
        lblMergeColor: TLabel;
        cbMergeColor: TColorBox;
        lblPluginColor: TLabel;
        cbPluginColor: TColorBox;
        lblErrorColor: TLabel;
        cbErrorColor: TColorBox;
        lblTemplate: TLabel;
        meTemplate: TMemo;
        lblSample: TLabel;
        [FormSection('DontTranslate')]
          lblCurrentProfileName: TLabel;
          lblSampleValue: TLabel;
          edHost: TEdit;
          edPort: TEdit;
      [FormSection('Integrations Tab')]
        IntegrationsTabSheet: TTabSheet;
        btnDetect: TButton;
        gbModManager: TGroupBox;
        kbUsingMO: TCheckBox;
        kbUsingNMM: TCheckBox;
        kbCopyGeneralAssets: TCheckBox;
        lblModManagerPath: TLabel;
        edModManagerPath: TEdit;
        lblModsPath: TLabel;
        edModsPath: TEdit;
        gbPapyrus: TGroupBox;
        lblDecompilerPath: TLabel;
        edDecompilerPath: TEdit;
        lblCompilerPath: TLabel;
        edCompilerPath: TEdit;
        lblFlagsPath: TLabel;
        edFlagsPath: TEdit;
        gbBSAs: TGroupBox;
        lblBSAOptPath: TLabel;
        edBsaOptPath: TEdit;
        lblBSAOptOptions: TLabel;
        edBsaOptOptions: TEdit;
        [FormSection('DontTranslate')]
          btnBrowseManager: TSpeedButton;
          btnBrowseMods: TSpeedButton;
          btnBrowseDecompiler: TSpeedButton;
          btnBrowseCompiler: TSpeedButton;
          btnBrowseFlags: TSpeedButton;
          btnBrowseBSAOpt: TSpeedButton;

    // HELPERS
    procedure LoadLanguageOptions;
    procedure LoadGeneralSettings;
    procedure LoadMergingSettings;
    procedure LoadAdvancedSettings;
    procedure LoadIntegrationSettings; 
    procedure HandleRegistrationControls;
    procedure HandleUpdateControls;
    procedure LoadButtonGlyphs;
    procedure SaveGeneralSettings;
    procedure SaveMergingSettings;
    procedure SaveAdvancedSettings;
    procedure SaveIntegrationSettings;
    function ManagerIntegrationValid: boolean;
    function BSAOptIntegrationValid: boolean;
    function PapyrusIntegrationValid: boolean;
    procedure searchForNexusModManager;
    procedure searchForModOrganizer;
    // PRIMARY EVENTS
    procedure FormCreate(Sender: TObject); 
    procedure FormShow(Sender: TObject);
    procedure ToggleOkButton;
    procedure btnOKClick(Sender: TObject);
    procedure SettingsPageControlChange(Sender: TObject); 
    procedure appendBackslashOnExit(Sender: TObject);
    procedure edPathChange(Sender: TObject);
    // GENERAL TAB EVENTS 
    procedure edUsernameChange(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnUpdateDictionaryClick(Sender: TObject);
    procedure btnUpdateProgramClick(Sender: TObject);
    // MERGING TAB EVENTS
    procedure btnBrowseAssetDirectoryClick(Sender: TObject);
    procedure kbExtractBSAsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure kbBuildBSAMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnVerifyAccessClick(Sender: TObject);
    // ADVANCED TAB EVENTS
    procedure btnChangeMergeProfileClick(Sender: TObject);
    procedure meTemplateChange(Sender: TObject);
    // INTEGRATIONS TAB EVENTS
    procedure kbUsingMOClick(Sender: TObject);
    procedure kbUsingNMMClick(Sender: TObject);
    procedure btnBrowseManagerClick(Sender: TObject);
    procedure btnBrowseModsClick(Sender: TObject);
    procedure btnBrowseDecompilerClick(Sender: TObject);
    procedure btnBrowseCompilerClick(Sender: TObject);
    procedure btnBrowseFlagsClick(Sender: TObject);
    procedure btnBrowseBSAOptClick(Sender: TObject);
    procedure edBsaOptPathExit(Sender: TObject);
    procedure btnDetectClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;
  slSampleLogMessage: TStringList;

implementation

{$R *.dfm}


{******************************************************************************}
{ HELPERS
  General functions and procedures used by the 
  event handlers.
}
{******************************************************************************}
procedure TOptionsForm.LoadLanguageOptions;
var
  info: TSearchRec;
  sLang: string;
begin
  cbLanguage.Items.Add('English');
  cbLanguage.ItemIndex := 0;
  if not DirectoryExists('lang') then
    exit;
  if FindFirst('lang\*.lang', faAnyFile, info) <> 0 then
    exit;
  repeat
    sLang := TitleCase(ChangeFileExt(info.Name, ''));
    if sLang <> 'English' then
      cbLanguage.Items.Add(sLang);
  until FindNext(info) <> 0;
  FindClose(info);
end; 

procedure TOptionsForm.LoadGeneralSettings;
var
  index: Integer;
begin
  // General > Language
  LoadLanguageOptions;
  index := cbLanguage.Items.IndexOf(settings.language);
  if index > -1 then
    cbLanguage.ItemIndex := index;
  // General > reports
  edUsername.Text := settings.username;
  // General > Style
  kbSimpleDictionary.Checked := settings.simpleDictionaryView;
  kbSimplePlugins.Checked := settings.simplePluginsView;
  // General > Updating
  kbUpdateDictionary.Checked := settings.updateDictionary;
  kbUpdateProgram.Checked := settings.updateProgram;
end;

procedure TOptionsForm.LoadMergingSettings;
begin
  // Merging > Asset handling
  edMergeDirectory.Text := settings.mergeDirectory;
  kbFaceGen.Checked := settings.handleFaceGenData;
  kbVoiceAssets.Checked := settings.handleVoiceAssets;
  kbTranslations.Checked := settings.handleMCMTranslations;
  kbINIs.Checked := settings.handleINIs;
  kbSEQ.Checked := settings.handleSEQ;
  kbFragments.Checked := settings.handleScriptFragments;
  kbSelfRef.Checked := settings.handleSelfReference;
  kbSelfRef.Enabled := (ProgramStatus.GameMode.appName = 'FNV') or
    (ProgramStatus.GameMode.appName = 'FO3');
  kbExtractBSAs.Checked := settings.extractBSAs;
  kbBuildBSA.Checked := settings.buildMergedBSA;
  kbBatCopy.Checked := settings.batCopy;
  // Merging > Debug
  kbDebugRenumbering.Checked := settings.debugRenumbering;
  kbDebugMergeStatus.Checked := settings.debugMergeStatus;
  kbDebugAssetCopying.Checked := settings.debugAssetCopying;
  kbDebugRecordCopying.Checked := settings.debugRecordCopying;
  kbDebugMasters.Checked := settings.debugMasters;
  kbDebugBatchCopying.Checked := settings.debugBatchCopying;
  kbDebugBSAs.Checked := settings.debugBSAs;
  kbDebugScriptFragments.Checked := settings.debugScriptFragments;
end;

procedure TOptionsForm.LoadAdvancedSettings;
begin
  // prepare sample log message
  slSampleLogMessage := TStringList.Create;
  slSampleLogMessage.Values['Time'] := '12:34:56';
  slSampleLogMessage.Values['AppTime'] := '00:01:52';
  slSampleLogMessage.Values['Group'] := 'GENERAL';
  slSampleLogMessage.Values['Label'] := 'Test';
  slSampleLogMessage.Values['Text'] := 'This is a test message.';
  
  // Advanced > Backend
  edHost.Text := settings.serverHost;
  edPort.Text := IntToStr(settings.serverPort);
  kbNoStatistics.Checked := settings.dontSendStatistics;
  // Advanced > Profile
  lblCurrentProfileName.Caption := settings.profile;
  // Advanced > Logging
  cbClientColor.Selected := TColor(settings.clientMessageColor);
  cbGeneralColor.Selected := TColor(settings.generalMessageColor);
  cbLoadColor.Selected := TColor(settings.loadMessageColor);
  cbMergeColor.Selected := TColor(settings.mergeMessageColor);
  cbPluginColor.Selected := TColor(settings.pluginMessageColor);
  cbErrorColor.Selected := TColor(settings.errorMessageColor);
  meTemplate.Lines.Text := settings.logMessageTemplate;
end;

procedure TOptionsForm.LoadIntegrationSettings;
begin
  // Integrations > Mod Organizer
  kbUsingMO.Checked := settings.usingMO;
  kbUsingNMM.Checked := settings.usingNMM;
  edModManagerPath.Text := settings.ManagerPath;
  edModsPath.Text := settings.ModsPath;
  kbCopyGeneralAssets.Checked := settings.copyGeneralAssets;
  // Integrations > Papyrus
  edDecompilerPath.Text := settings.decompilerPath;
  edCompilerPath.Text := settings.compilerPath;
  edFlagsPath.Text := settings.flagsPath;
  // Integrations > BSAs
  edBsaOptPath.Text := settings.bsaOptPath;
  edBsaOptOptions.Text := settings.bsaOptOptions;

  // disable BSAOpt integration if bsaOptMode is nil
  if ProgramStatus.GameMode.bsaOptMode = '' then begin
    edBsaOptPath.Enabled := false;
    btnBrowseBsaOpt.Enabled := false;
    edBsaOptOptions.Enabled := false;
  end;

  // disable controls if not using MO or NMM
  if not (kbUsingMO.Checked or kbUsingNMM.Checked) then
    kbUsingMOClick(nil);
end;

procedure TOptionsForm.HandleRegistrationControls;
begin
  // Initialize registration GUI controls
  edUsernameChange(nil);

  // Disable controls if registered
  if settings.registered then begin
    edUsername.Enabled := false;
    btnRegister.Enabled := false;
    // get authorization status if we're connected
    if TCPClient.Connected then begin 
      // if registered but not authorized, enable reset button
      if not ProgramStatus.bAuthorized then begin
        btnReset.Enabled := true;
        lblStatusValue.Caption := GetLanguageString('mpOpt_AuthFailed');
        lblStatusValue.Font.Color := clRed;
        lblStatusValue.Hint := GetLanguageString('mpOpt_AuthFailed');
      end
      // registered and authorized
      else begin
        lblStatusValue.Caption := GetLanguageString('mpOpt_Registered');
        lblStatusValue.Font.Color := clGreen;
        lblStatusValue.Hint := '';
        ProgramStatus.bAuthorized := true;
      end;
    end;
  end;
end;

procedure TOptionsForm.HandleUpdateControls;
begin
  // dictionary update
  if ProgramStatus.bDictionaryUpdate then begin
    btnUpdateDictionary.Enabled := ProgramStatus.bDictionaryUpdate;
    lblDictionaryStatus.Caption := GetLanguageString('mpOpt_UpdateAvailable');
    lblDictionaryStatus.Font.Color := $000080FF;
  end;

  // program update
  if ProgramStatus.bProgramUpdate then begin
    btnUpdateProgram.Enabled := ProgramStatus.bProgramUpdate;
    lblProgramStatus.Caption := GetLanguageString('mpOpt_UpdateAvailable');
    lblProgramStatus.Hint := Format(GetLanguageString('mpOpt_VersionCompare'),
      [LocalStatus.programVersion, RemoteStatus.programVersion]);
    lblProgramStatus.Font.Color := $000080FF;
  end;
end;

procedure TOptionsForm.LoadButtonGlyphs;
begin
  // Make buttons flat
  btnBrowseManager.Flat := true;
  btnBrowseMods.Flat := true;
  btnBrowseAssetDirectory.Flat := true;
  btnBrowseDecompiler.Flat := true;
  btnBrowseCompiler.Flat := true;
  btnBrowseFlags.Flat := true;
  btnBrowseBsaOpt.Flat := true;
  // Load glyphs from IconList
  IconList.GetBitmap(0, btnBrowseManager.Glyph);
  IconList.GetBitmap(0, btnBrowseMods.Glyph);
  IconList.GetBitmap(0, btnBrowseAssetDirectory.Glyph);
  IconList.GetBitmap(0, btnBrowseDecompiler.Glyph);
  IconList.GetBitmap(0, btnBrowseCompiler.Glyph);
  IconList.GetBitmap(0, btnBrowseFlags.Glyph);
  IconList.GetBitmap(0, btnBrowseBsaOpt.Glyph);
end;

procedure TOptionsForm.SaveGeneralSettings;
begin
  // General > Language
  settings.language := cbLanguage.Text;
  // General > Reports
  settings.username := edUsername.Text;
  // General > Style
  settings.simpleDictionaryView := kbSimpleDictionary.Checked;
  settings.simplePluginsView := kbSimplePlugins.Checked;
  // General > Updating
  settings.updateDictionary := kbUpdateDictionary.Checked;
  settings.updateProgram := kbUpdateProgram.Checked;
end;

procedure TOptionsForm.SaveMergingSettings;
begin
  // Merging > Asset Handling
  settings.mergeDirectory := edMergeDirectory.Text;
  settings.handleFaceGenData := kbFaceGen.Checked;
  settings.handleVoiceAssets := kbVoiceAssets.Checked;
  settings.handleMCMTranslations := kbTranslations.Checked;
  settings.handleINIs := kbINIs.Checked;
  settings.handleSEQ := kbSEQ.Checked;
  settings.handleScriptFragments := kbFragments.Checked;
  settings.handleSelfReference := kbSelfRef.Checked;
  settings.extractBSAs := kbExtractBSAs.Checked;
  settings.buildMergedBSA := kbBuildBSA.Checked;
  settings.batCopy := kbBatCopy.Checked;
  // Merging > Debug
  settings.debugRenumbering := kbDebugRenumbering.Checked;
  settings.debugMergeStatus := kbDebugMergeStatus.Checked;
  settings.debugAssetCopying := kbDebugAssetCopying.Checked;
  settings.debugRecordCopying := kbDebugRecordCopying.Checked;
  settings.debugMasters := kbDebugMasters.Checked;
  settings.debugBatchCopying := kbDebugBatchCopying.Checked;
  settings.debugBSAs := kbDebugBSAs.Checked;
  settings.debugScriptFragments := kbDebugScriptFragments.Checked;
end;

procedure TOptionsForm.SaveAdvancedSettings;
begin
  // Advanced > Backend
  settings.serverHost := edHost.Text;
  settings.serverPort := StrToInt(edPort.Text);
  settings.dontSendStatistics := kbNoStatistics.Checked;
  // Advanced > Logging
  settings.clientMessageColor := cbClientColor.Selected ;
  settings.generalMessageColor := cbGeneralColor.Selected;
  settings.loadMessageColor := cbLoadColor.Selected;
  settings.mergeMessageColor := cbMergeColor.Selected;
  settings.pluginMessageColor := cbPluginColor.Selected;
  settings.errorMessageColor := cbErrorColor.Selected;
  settings.logMessageTemplate := meTemplate.Lines.Text;
end;

procedure TOptionsForm.SaveIntegrationSettings;
begin
  // Integrations > Mod Organizer
  settings.usingMO := kbUsingMO.Checked;
  settings.usingNMM := kbUsingNMM.Checked;
  settings.ManagerPath := edModManagerPath.Text;
  settings.ModsPath := edModsPath.Text;
  settings.copyGeneralAssets := kbCopyGeneralAssets.Checked;
  // Integrations > Papyrus
  settings.decompilerPath := edDecompilerPath.Text;
  settings.compilerPath := edCompilerPath.Text;
  settings.flagsPath := edFlagsPath.Text;
  // Integrations > BSAs
  settings.bsaOptPath := edBsaOptPath.Text;
  settings.bsaOptOptions := edBsaOptOptions.Text;
end;

function TOptionsForm.ManagerIntegrationValid: boolean;
var
  sPath: string;
begin
  Result := false;

  // if not using a mod manager integration, result is true
  if not (kbUsingMO.Checked or kbUsingNMM.Checked) then begin
    Result := true;
    exit;
  end;

  // validate MO integration
  if kbUsingMO.Checked then begin
    sPath := edModManagerPath.Text + 'ModOrganizer.ini';
    Result := DirectoryExists(edModsPath.Text) and FileExists(sPath);
  end

  // validate NMM integration
  else if kbUsingNMM.Checked then begin
    Result := DirectoryExists(edModManagerPath.Text)
      and DirectoryExists(edModsPath.Text);
  end;
end;

function TOptionsForm.BSAOptIntegrationValid: boolean;
begin
  Result := (edBSAOptPath.Text <> '') 
    and (FileExists(edBSAOptPath.Text))
    and (edBSAOptOptions.Text <> '');
end; 

function TOptionsForm.PapyrusIntegrationValid: boolean;
begin
  Result := (edDecompilerPath.Text <> '')
    and (FileExists(edDecompilerPath.Text))
    and (edCompilerPath.Text <> '')
    and (FileExists(edCompilerPath.Text))
    and (edFlagsPath.Text <> '')
    and (FileExists(edFlagsPath.Text));
end;

procedure TOptionsForm.searchForNexusModManager;
const
  sNMMUninstallKey  = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'+
    '6af12c54-643b-4752-87d0-8335503010de_is1\';
  sNMMRegKey        = '\SOFTWARE\NexusModManager\';
var
  keys: TStringList;
  path: string;
begin
  // find program path
  keys := TStringList.Create;
  keys.Add(sNMMUninstallKey + 'InstallLocation');
  path := TryRegistryKeys(keys);
  if path <> '' then
    edModManagerPath.Text := path;

  // find mods path
  keys.Clear;
  keys.Add(sNMMRegKey + 'Mods');
  path := TryRegistryKeys(keys);
  if path <> '' then
    edModsPath.Text := path;
end;

procedure TOptionsForm.searchForModOrganizer;
const
  validModOrganizerFilenames: array[1..1] of string = ('ModOrganizer.exe');
  ignore: array[1..1] of string = ('data');
var
  DrivesArray: TStringDynArray;
  modOrganizerPath, sPaths, sDrive: string;
begin
  // search for installations in GamePath
  modOrganizerPath := RecursiveFileSearch(PathList.Values['GamePath'],
    validModOrganizerFilenames, ignore, 2);

  // search for installations in ?:\Program Files and ?:\Program Files (x86)
  DrivesArray := GetDriveList;
  for sDrive in DrivesArray do begin
    if not DriveReady(sDrive) then
      continue;
    if DirectoryExists(sDrive + 'Program Files') then
      sPaths := sPaths + sDrive + 'Program Files;';
    if DirectoryExists(sDrive + 'Program Files (x86)') then
      sPaths := sPaths + sDrive + 'Program Files (x86);';
  end;

  if (modOrganizerPath = '') then
    modOrganizerPath := FileSearch('Mod Organizer\ModOrganizer.exe', sPaths);

  // search each folder in each valid Program Files directory for ModOrganizer.exe
  if (modOrganizerPath = '') then 
    modOrganizerPath := SearchPathsForFile(sPaths, 'ModOrganizer.exe');

  // if found, set TEdit captions, else alert user
  if (modOrganizerPath <> '') then begin
    edModManagerPath.Text := Copy(modOrganizerPath, 1, length(modOrganizerPath) - 16);
    if DirectoryExists(edModManagerPath.Text + 'mods\') then begin
      edModsPath.Text := edModManagerPath.Text + 'mods\';
      edMergeDirectory.Text := edModManagerPath.Text + 'mods\';
    end;
  end
  else begin
    MessageDlg(GetLanguageString('mpOpt_ModOrganizerNotFound'), mtConfirmation, [mbOk], 0);
    edModManagerPath.Text := '';
  end;
end; 


{******************************************************************************}
{ PRIMARY EVENTS
  Form or primary component events, not associated with
  a particular TabSheet of the PageControl.
}
{******************************************************************************}

procedure TOptionsForm.FormCreate(Sender: TObject);
begin
  // do translation dump?
  if bTranslationDump then
    TRttiTranslation.Save('lang\english.lang', self);

  // load translation
  TRttiTranslation.Load(language, self);
end;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
  // get status update if we can
  if GetStatus then
    CompareStatuses;

  // Load settings into GUI
  LoadGeneralSettings;
  LoadMergingSettings;
  LoadAdvancedSettings;
  LoadIntegrationSettings;

  // Handle control initialization
  HandleRegistrationControls;
  HandleUpdateControls;
  LoadButtonGlyphs;

  // Handle new profile
  if settings.newProfile then begin
    btnCancel.Enabled := false;
    ShowMessage('You''ve made a new profile.  Please configure settings '+
      'to use with this profile.  If you have questions refer to the '+
      'documentation.');
  end;
end;

procedure TOptionsForm.ToggleOkButton;
begin
  btnOK.Enabled := ManagerIntegrationValid and
    DirectoryValid(edMergeDirectory.Text);
end;

procedure TOptionsForm.btnOKClick(Sender: TObject);
begin
  // check if we need to update merge status afterwards
  ProgramStatus.bUpdateMergeStatus := (settings.usingMO <> kbUsingMO.Checked)
    or (settings.ManagerPath <> edModManagerPath.Text)
    or (settings.mergeDirectory <> edMergeDirectory.Text);

  // Save settings from GUI
  SaveGeneralSettings;
  SaveMergingSettings;
  SaveAdvancedSettings;
  SaveIntegrationSettings;

  // Save settings to disk
  SaveSettings;
end;

procedure TOptionsForm.SettingsPageControlChange(Sender: TObject);
var
  iIndex: integer;
begin
  iIndex := TPageControl(Sender).ActivePageIndex;
  case iIndex of
    1: begin
      // Handle Script Fragments is available only when 
      // the papyrus integration is set up correctly
      kbFragments.Enabled := PapyrusIntegrationValid;
      if not kbFragments.Enabled then
        kbFragments.Checked := false;  
      
      // Build Merged BSA is available only when  the 
      // BSAOpt integration is set up correctly
      kbBuildBSA.Enabled := BSAOptIntegrationValid; 
      if not kbBuildBSA.Enabled then
        kbBuildBSA.Checked := false;
    end;
  end;
end; 

procedure TOptionsForm.appendBackslashOnExit(Sender: TObject);
var
  ed: TEdit;
begin
  // add trailing backslash if length > 0 and it is missing
  ed := TEdit(Sender);
  if Length(ed.Text) > 0 then
    ed.Text := AppendIfMissing(ed.Text, '\');
end;   

   
{******************************************************************************}
{ GENERAL TAB EVENTS
  Event handlers associated with controls on
  the general tab sheet. 
}
{******************************************************************************} 

procedure TOptionsForm.edUsernameChange(Sender: TObject);
begin
  if not TCPClient.Connected then begin
    lblStatusValue.Caption := GetLanguageString('mpOpt_ServerUnavailable');
    lblStatusValue.Font.Color := clRed;
    lblStatusValue.Hint := GetLanguageString('mpOpt_ServerUnavailable');
    btnRegister.Enabled := false;
    exit;
  end;

  btnRegister.Caption := GetLanguageString('mpOpt_Check');
  if Length(edUsername.Text) < 4 then begin
    lblStatusValue.Caption := GetLanguageString('mpOpt_InvalidUsername');
    lblStatusValue.Font.Color := clRed;
    lblStatusValue.Hint := GetLanguageString('mpOpt_UsernameTooShort');
    btnRegister.Enabled := false;
  end
  else if Length(edUsername.Text) > 24 then begin
    lblStatusValue.Caption := GetLanguageString('mpOpt_InvalidUsername');
    lblStatusValue.Font.Color := clRed;
    lblStatusValue.Hint := GetLanguageString('mpOpt_UsernameTooLong');
    btnRegister.Enabled := false;
  end
  else begin
    lblStatusValue.Caption := GetLanguageString('mpOpt_ValidUsername');
    lblStatusValue.Font.Color := clBlack;
    lblStatusValue.Hint := GetLanguageString('mpOpt_ValidUsername');
    btnRegister.Enabled := true;
  end;
end;    

procedure TOptionsForm.btnRegisterClick(Sender: TObject);
begin
  if not TCPClient.Connected then begin
    lblStatusValue.Caption := GetLanguageString('mpOpt_ServerUnavailable');
    lblStatusValue.Font.Color := clRed;
    lblStatusValue.Hint := GetLanguageString('mpOpt_ServerUnavailable');
    btnRegister.Enabled := false;
    exit;
  end;

  if (btnRegister.Caption = GetLanguageString('mpOpt_Register')) then begin
    if RegisterUser(edUsername.Text) then begin
      settings.registered := true;
      settings.username := edUsername.Text;
      SaveSettings;
      lblStatusValue.Caption := GetLanguageString('mpOpt_Registered');
      lblStatusValue.Font.Color := clGreen;
      lblStatusValue.Hint := '';
      edUsername.Enabled := false;
      btnRegister.Enabled := false;
    end
    else begin
      lblStatusValue.Caption := GetLanguageString('mpOpt_FailedToRegister');
      lblStatusValue.Font.Color := clRed;
      lblStatusValue.Hint := GetLanguageString('mpOpt_FailedToRegister');
    end;
  end
  else begin
    if UsernameAvailable(edUsername.Text) then begin
      lblStatusValue.Caption := GetLanguageString('mpOpt_UsernameAvailable');
      lblStatusValue.Font.Color := clBlue;
      lblStatusValue.Hint := GetLanguageString('mpOpt_UsernameAvailable');
      btnRegister.Caption := GetLanguageString('mpOpt_Register');
    end
    else begin
      lblStatusValue.Caption := GetLanguageString('mpOpt_UsernameUnavailable');
      lblStatusValue.Font.Color := clRed;
      lblStatusValue.Hint := GetLanguageString('mpOpt_UsernameUnavailable');
    end;
  end;
end;

procedure TOptionsForm.btnResetClick(Sender: TObject);
begin
  if settings.registered and not ProgramStatus.bAuthorized then begin
    ResetAuth;
    ProgramStatus.bAuthorized := CheckAuthorization;
    if not ProgramStatus.bAuthorized then
      ProgramStatus.bAuthorized := RegisterUser(edUsername.Text);
    if ProgramStatus.bAuthorized then begin
      btnReset.Enabled := false;
      lblStatusValue.Caption := GetLanguageString('mpOpt_Registered');
      lblStatusValue.Font.Color := clGreen;
      lblStatusValue.Hint := '';
    end;
  end;
end;

procedure TOptionsForm.btnUpdateDictionaryClick(Sender: TObject);
begin
  if TCPClient.Connected then begin
    if UpdateDictionary then begin
      LocalStatus := TmpStatus.Create;
      CompareStatuses;
      UpdatePluginData;
      btnUpdateDictionary.Enabled := false;
      lblDictionaryStatus.Caption := GetLanguageString('mpOpt_UpToDate');
      lblDictionaryStatus.Font.Color := clGreen;
    end;
  end;
end;

procedure TOptionsForm.btnUpdateProgramClick(Sender: TObject);
begin
  if TCPClient.Connected then begin
    clProgramVersion := LocalStatus.ProgramVersion;
    UpdateChangeLog;
    if ChangeLogPrompt(self) and DownloadProgram then begin
      ProgramStatus.bInstallUpdate := true;
      btnOKClick(nil);
      Close;
    end;
  end;
end; 


{******************************************************************************} 
{ MERGING TAB EVENTS
  Event handlers associated with the components on
  the mergeing tab sheet.
}
{******************************************************************************}

procedure TOptionsForm.btnBrowseAssetDirectoryClick(Sender: TObject);
begin
  BrowseForFolder(edMergeDirectory, PathList.Values['ProgramPath']);
end; 

procedure TOptionsForm.kbExtractBSAsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  kbBuildBSA.Checked := false;
end;

procedure TOptionsForm.kbBuildBSAMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  kbExtractBSAs.Checked := false;
end; 

{ Verifies the application has full read/write access on the user's
  filesystem. }
procedure TOptionsForm.btnVerifyAccessClick(Sender: TObject);
var
  sFailed, sPathName, sTestPath: string;
begin
  // prepare failure message
  sFailed := 'Failed.  Insufficient permissions at %s.'#13#10+
    'Path: %s'#13#10+
    'Exception: %s';
    
  // test paths
  try
    // test temp path
    sPathName := 'Temporary Path';
    sTestPath := PathList.Values['TempPath'];
    PerformFileSystemTests(sTestPath);

    // test program path
    sPathName := 'Program Path';
    sTestPath := PathList.Values['ProgramPath'];
    PerformFileSystemTests(sTestPath);

    // test merge directory 
    sPathName := 'Merge Destination Directory';
    sTestPath := edMergeDirectory.Text;
    PerformFileSystemTests(sTestPath);
  except
    on x: Exception do begin
      ShowMessage(Format(sFailed, [sPathName, sTestPath, x.Message]));
      exit;
    end;
  end;

  // all tests passed, yippee!
  ShowMessage('Merge Plugins has the required file system access permissions.');
end;

     
{******************************************************************************}
{ ADVANCED TAB EVENTS
  Event handlers associated with components on
  the advanced tab sheet.
}
{******************************************************************************} 

procedure TOptionsForm.btnChangeMergeProfileClick(Sender: TObject);
begin
  ProgramStatus.bChangeMergeProfile := true;
  btnOKClick(nil);
  Close;
end;    

procedure TOptionsForm.meTemplateChange(Sender: TObject);
var
  template: string;
begin
  template := meTemplate.Lines.Text;
  lblSampleValue.Caption := ApplyTemplate(template, slSampleLogMessage);
end;


{******************************************************************************}
{ INTEGRATIONS TAB EVENTS
  Event handlers associated with components on
  the integrations tab sheet.
}
{******************************************************************************}

{=== MOD MANAGER INTEGRATION ===}

procedure TOptionsForm.kbUsingMOClick(Sender: TObject);
var
  b: boolean;
begin
  b := kbUsingMO.Checked or kbUsingNMM.Checked;
  if kbUsingMO.Checked then
    kbUsingNMM.State := cbUnchecked;
  edModManagerPath.Enabled := b;
  edModsPath.Enabled := b;
  btnBrowseManager.Enabled := b;
  btnBrowseMods.Enabled := b;
  kbCopyGeneralAssets.Enabled := b;
  kbCopyGeneralAssets.Checked := b;
  ToggleOkButton;
  gbModManager.Repaint;
end;

procedure TOptionsForm.kbUsingNMMClick(Sender: TObject);
var
  b: boolean;
begin
  b := kbUsingMO.Checked or kbUsingNMM.Checked;
  if kbUsingNMM.Checked then
    kbUsingMO.State := cbUnchecked;
  edModManagerPath.Enabled := b;
  edModsPath.Enabled := b;
  btnBrowseManager.Enabled := b;
  btnBrowseMods.Enabled := b;
  kbCopyGeneralAssets.Enabled := b;
  kbCopyGeneralAssets.Checked := b;
  ToggleOkButton;
  gbModManager.Repaint;
end;

procedure TOptionsForm.btnBrowseManagerClick(Sender: TObject);
var
  modsPath: string;
begin
  BrowseForFolder(edModManagerPath, PathList.Values['ProgramPath']);
  modsPath := edModManagerPath.Text + 'mods\';
  if DirectoryExists(modsPath) then begin
    edModsPath.Text := modsPath;
    edMergeDirectory.Text := modsPath;
  end;
  modsPath := edModManagerPath.Text + ProgramStatus.gameMode.gameName + '\Mods\VirtualInstall\';
  if DirectoryExists(modsPath) then begin
    edModsPath.Text := modsPath;
    edMergeDirectory.Text := modsPath;
  end;
  ToggleOkButton;
end;

procedure TOptionsForm.btnBrowseModsClick(Sender: TObject);
begin
  BrowseForFolder(edModsPath, PathList.Values['ProgramPath']);
  ToggleOkButton;
end;

procedure TOptionsForm.edPathChange(Sender: TObject);
begin
  ToggleOkButton;
end;

{=== PAPYRUS INTEGRATION ===}

procedure TOptionsForm.btnBrowseDecompilerClick(Sender: TObject);
begin
  BrowseForFile(edDecompilerPath, GetLanguageString('mpOpt_ExeFilter'), PathList.Values['ProgramPath']);
end;

procedure TOptionsForm.btnBrowseCompilerClick(Sender: TObject);
begin
  BrowseForFile(edCompilerPath, GetLanguageString('mpOpt_ExeFilter'), PathList.Values['DataPath']);
end;

procedure TOptionsForm.btnBrowseFlagsClick(Sender: TObject);
begin
  BrowseForFile(edFlagsPath, GetLanguageString('mpOpt_FlagsFilter'), PathList.Values['DataPath'] + 'scripts\source\');
end;  
  
{=== BSAOPT INTEGRATION ===}

procedure TOptionsForm.btnBrowseBSAOptClick(Sender: TObject);
begin
  BrowseForFile(edBsaOptPath, GetLanguageString('mpOpt_ExeFilter'), PathList.Values['ProgramPath']);
  edBsaOptPathExit(nil);
end;

procedure TOptionsForm.edBsaOptPathExit(Sender: TObject);
begin
  if FileExists(edBsaOptPath.Text) and (edBsaOptOptions.Text = '') then
    edBsaOptOptions.Text := Format('-game %s -passthrough -compress 9',
      [ProgramStatus.GameMode.bsaOptMode]);
end;

procedure TOptionsForm.btnDetectClick(Sender: TObject);
const
  validDecompilerFilenames: array[1..1] of string = ('Champollion.exe');
  validCompilerFilenames: array[1..1] of string = ('PapyrusCompiler.exe');
  validFlagFilenames: array[1..1] of string = ('TESV_Papyrus_Flags.flg');
  validBsaOptFilenames: array[1..5] of string =
    ('BSAopt x32.exe',
    'BSAopt x64.exe',
    'BSAopt x32 (XP).exe',
    'BSAopt x64 (XP).exe',
    'BSAopt.exe');
  ignore: array[1..4] of string = ('merge', 'logs', 'temp', 'data');
var
  path: string;
  paths: array[1..2] of string;
begin
  // paths array
  paths[1] := PathList.Values['ProgramPath'];
  paths[2] := PathList.Values['GamePath'];

  // search for mod organizer
  if kbUsingMo.Checked then
    searchForModOrganizer;

  if kbUsingNMM.Checked then
    searchForNexusModManager;

  // search for champollion decompiler
  path := MultFileSearch(paths, validDecompilerFilenames, ignore, 2);
  if (path <> '') then
    edDecompilerPath.Text := path;

  // search for papyrus compiler
  path := MultFileSearch(paths, validCompilerFilenames, ignore, 2);
  if (path <> '') then
    edCompilerPath.Text := path;

  // search for papyrus flags
  path := PathList.Values['DataPath'] + 'scripts\source\TESV_Papyrus_Flags.flg';
  if FileExists(path) then
    edFlagsPath.Text := path;

  // search for bsaopt if available
  if edBsaOptPath.Enabled then begin
    path := MultFileSearch(paths, validBsaOptFilenames, ignore, 2);
    if (path <> '') then begin
      edBsaOptPath.Text := path;
      edBsaOptPathExit(nil);
    end;
  end;
end;

end.
