unit mpResolveForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Menus,
  // mte units
  mteProgressForm, RttiTranslation,
  // mp units
  mpCore;

type
  TResolveForm = class(TForm)
    [FormPrefix('mpRes')]
      btnOK: TButton;
      ResolvePageControl: TPageControl;
      [FormSection('Broken Dependencies Tab')]
        tsBrokenDependencies: TTabSheet;
        lblBrokenDependencies: TLabel;
        lvBrokenDependencies: TListView;
        [FormSection('Broken Dependencies Popup Menu')]
          DependenciesPopupMenu: TPopupMenu;
          IgnoreDependencyItem: TMenuItem;
          RemoveBreakingPluginItem: TMenuItem;
          AddDependencyItem: TMenuItem;
      [FormSection('Non-contiguous Plugins Tab')]
        tsNonContiguous: TTabSheet;
        lblNonContiguous: TLabel;
        lvNonContiguous: TListView;
        btnIgnoreContiguous: TButton;
      [FormSection('Plugin Errors Tab')]
        tsPluginErrors: TTabSheet;
        lblPluginErrors: TLabel;
        lvPluginErrors: TListView;
        [FormSection('Plugin Errors Popup Menu')]
          PluginErrorsPopupMenu: TPopupMenu;
          IgnoreErrorsItem: TMenuItem;
          RemoveErrorsPluginItem: TMenuItem;
          CheckPluginItem: TMenuItem;
          FixErrorsItem: TMenuItem;
      [FormSection('Other Issues Tab')]
        tsOtherIssues: TTabSheet;
        lblOtherIssues: TLabel;
        lvOtherIssues: TListView;
        [FormSection('Other Issues Popup Menu')]
          OtherIssuesPopupMenu: TPopupMenu;
          RemoveUnloadedPluginItem: TMenuItem;

    procedure EvaluateMergeIssues;
    procedure FormShow(Sender: TObject);
    procedure ProgressDone;
    procedure RemoveBreakingPluginItemClick(Sender: TObject);
    procedure AddDependencyItemClick(Sender: TObject);
    procedure IgnoreDependencyItemClick(Sender: TObject);
    procedure CheckPluginItemClick(Sender: TObject);
    procedure FixErrorsItemClick(Sender: TObject);
    procedure RemoveErrorsPluginItemClick(Sender: TObject);
    procedure IgnoreErrorsItemClick(Sender: TObject);
    procedure btnIgnoreContiguousClick(Sender: TObject);
    procedure RemoveUnloadedPluginItemClick(Sender: TObject);
    procedure PluginErrorsPopupMenuPopup(Sender: TObject);
    procedure OtherIssuesPopupMenuPopup(Sender: TObject);
    procedure DependenciesPopupMenuPopup(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    merge: TMerge;
  end;

var
  ResolveForm: TResolveForm;
  pForm: TProgressForm;

implementation

uses
  // mte units
  mteBase, mteHelpers, mteLogging,
  // mp units
  mpConfiguration, mpThreads;

{$R *.dfm}

var
  bBrokenDependencies, bNonContiguous, bPluginErrors, bOtherIssues,
  bNonContiguousCritical: boolean;

procedure TResolveForm.EvaluateMergeIssues;
var
  i, j, currentLoadOrder, lastLoadOrder, firstLoadOrder: Integer;
  plugin, master: TPlugin;
  ListItem: TListItem;
  fn: string;
begin
  // clear listviews
  lvBrokenDependencies.Items.Clear;
  lvNonContiguous.Items.Clear;
  lvPluginErrors.Items.Clear;
  lvOtherIssues.Items.Clear;
  bBrokenDependencies := false;
  bNonContiguous := false;
  bNonContiguousCritical := false;
  bPluginErrors := false;
  bOtherIssues := false;


  // don't merge if no plugins to merge
  if (merge.plugins.Count < 1) then begin
    bOtherIssues := true;
    ListItem := lvOtherIssues.Items.Add;
    ListItem.Caption := GetLanguageString('mpRes_NoPlugins');
    ListItem.SubItems.Add(GetLanguageString('mpRes_NoPlugins_Merge'));
  end;

  // don't merge if mod destination directory is blank
  if (settings.mergeDirectory = '') then begin
    bOtherIssues := true;
    ListItem := lvOtherIssues.Items.Add;
    ListItem.Caption := GetLanguageString('mpRes_DirInvalid');
    ListItem.SubItems.Add(GetLanguageString('mpRes_DirBlank_Merge'));
  end;

  // don't merge if usingMO is true and MODirectory is blank
  if settings.usingMO and (settings.ManagerPath = '') then begin
    bOtherIssues := true;
    ListItem := lvOtherIssues.Items.Add;
    ListItem.Caption := GetLanguageString('mpRes_DirInvalid');
    ListItem.SubItems.Add(GetLanguageString('mpRes_DirBlank_MO'));
  end;

  // don't merge if usingMO is true and MODirectory is invalid
  if settings.usingMO and not DirectoryExists(settings.ManagerPath) then begin
    bOtherIssues := true;
    ListItem := lvOtherIssues.Items.Add;
    ListItem.Caption := GetLanguageString('mpRes_DirInvalid');
    ListItem.SubItems.Add(GetLanguageString('mpRes_DirInvalid_MO'));
  end;

  // loop through plugins
  firstLoadOrder := -1;
  lastLoadOrder := -1;
  for i := 0 to Pred(merge.plugins.Count) do begin
    plugin := PluginByFilename(merge.plugins[i]);

    // see if plugin is loaded
    if not Assigned(plugin) then begin
      bOtherIssues := true;
      ListItem := lvOtherIssues.Items.Add;
      ListItem.Caption := GetLanguageString('mpRes_UnloadedPlugin');
      ListItem.GroupID := 1;
      ListItem.SubItems.Add(merge.plugins[i]);
      continue;
    end;

    // check if plugins are contiguous
    currentLoadOrder := plugin._File.LoadOrder;
    if firstLoadOrder = -1 then
      firstLoadOrder := currentLoadOrder;
    if (lastLoadOrder > -1) and (not merge.bIgnoreNonContiguous)
    and (currentLoadOrder - lastLoadOrder <> 1) then
      bNonContiguous := true;
    lastLoadOrder := currentLoadOrder;

    if bNonContiguous then begin
      // add non-contiguous list items
      ListItem := lvNonContiguous.Items.Add;
      ListItem.Caption := IntToStr(plugin._File.LoadOrder);
      ListItem.SubItems.Add(plugin.filename);

      // check if plugins are critically non-contiguous
      // this is when masters of the plugins being merged are interpolated
      // between plugins being merged, but are not in the merge themselves
      for j := 0 to Pred(plugin.masters.Count) do begin
        fn := plugin.masters[j];
        if merge.plugins.IndexOf(fn) = -1 then begin
          master := PluginByFileName(fn);
          if master._File.LoadOrder > firstLoadOrder then begin
            bNonContiguousCritical := true;
            ListItem.SubItems.Add(GetLanguageString('mpRes_Critical'));
          end;
        end;
      end;

      // add Minor subitem if not Critical
      if ListItem.SubItems.Count = 1 then
        ListItem.SubItems.Add(GetLanguageString('mpRes_Minor'));
    end;

    // check if plugins break dependencies
    for j := 0 to Pred(plugin.requiredBy.Count) do begin
      fn := plugin.requiredBy[j];
      if (merge.plugins.IndexOf(fn) = -1)
      and (merge.ignoredDependencies.IndexOf(fn) = -1) then begin
        bBrokenDependencies := true;
        ListItem := lvBrokenDependencies.Items.Add;
        ListItem.Caption := plugin.filename;
        ListItem.SubItems.Add(plugin.requiredBy[j]);
      end;
    end;

    // check if plugin has been checked for errors, and is error-free
    if (not plugin.HasBeenCheckedForErrors) then begin
      bPluginErrors := true;
      ListItem := lvPluginErrors.Items.Add;
      ListItem.Caption := GetLanguageString('mpRes_NeedsErrorCheck');
      ListItem.SubItems.Add(plugin.filename);
    end
    else if plugin.HasErrors and not plugin.bIgnoreErrors then begin
      bPluginErrors := true;
      ListItem := lvPluginErrors.Items.Add;
      ListItem.Caption := GetLanguageString('mpRes_HasErrors');
      ListItem.SubItems.Add(plugin.filename);
    end;
  end;

  // set active page
  if bBrokenDependencies then
    ResolvePageControl.ActivePage := tsBrokenDependencies
  else if bNonContiguous then
    ResolvePageControl.ActivePage := tsNonContiguous
  else if bPluginErrors then
    ResolvePageControl.ActivePage := tsPluginErrors
  else if bOtherIssues then
    ResolvePageControl.ActivePage := tsOtherIssues
  else begin
    ShowMessage(GetLanguageString('mpRes_IssuesResolved'));
    Close;
  end;

  // update GUI
  tsBrokenDependencies.TabVisible := bBrokenDependencies;
  tsNonContiguous.TabVisible := bNonContiguous;
  tsPluginErrors.TabVisible := bPluginErrors;
  tsOtherIssues.TabVisible := bOtherIssues;
  btnIgnoreContiguous.Enabled := not bNonContiguousCritical;

  // correct list view widths
  ListView_CorrectWidth(lvBrokenDependencies);
  ListView_CorrectWidth(lvNonContiguous);
  ListView_CorrectWidth(lvPluginErrors);
  ListView_CorrectWidth(lvOtherIssues);
end;

procedure TResolveForm.FormShow(Sender: TObject);
begin
  // do translation dump?
  if bTranslationDump then
    TRttiTranslation.Save('lang\english.lang', self);

  // load language
  TRttiTranslation.Load(language, self);

  // evalute merge issues, if merge assigned
  if Assigned(merge) then
    EvaluateMergeIssues;
end;

procedure TResolveForm.DependenciesPopupMenuPopup(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
  bHasSelection: boolean;
begin
  // initialize booleans
  bHasSelection := false;

  for i := 0 to Pred(lvBrokenDependencies.Items.Count) do begin
    ListItem := lvBrokenDependencies.Items[i];
    if not ListItem.Selected then
      continue;
    bHasSelection := true;
  end;

  // toggle menu items
  IgnoreDependencyItem.Enabled := bHasSelection;
  RemoveBreakingPluginItem.Enabled := bHasSelection;
  AddDependencyItem.Enabled := bHasSelection;
end;

procedure TResolveForm.RemoveBreakingPluginItemClick(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
  plugin: TPlugin;
begin
  for i := 0 to Pred(lvBrokenDependencies.Items.Count) do begin
    ListItem := lvBrokenDependencies.Items[i];
    if not ListItem.Selected then
      continue;
    plugin := PluginByFilename(ListItem.Caption);
    merge.Remove(plugin);
  end;

  // re-evalute issues
  EvaluateMergeIssues;
  if bBrokenDependencies then
    ResolvePageControl.ActivePage := tsBrokenDependencies;
end;

procedure TResolveForm.AddDependencyItemClick(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
  plugin: TPlugin;
begin
  for i := 0 to Pred(lvBrokenDependencies.Items.Count) do begin
    ListItem := lvBrokenDependencies.Items[i];
    if not ListItem.Selected then
      continue;
    plugin := PluginByFilename(ListItem.SubItems[0]);
    // skip plugins that have been been disallowed by the user
    if (plugin.bDisallowMerging) then begin
      ShowMessage(Format(GetLanguageString('mpRes_DoNotMerge'),
        [plugin.filename, merge.name]));
      continue;
    end;
    // skip plugins that are blacklisted
    if (IS_BLACKLISTED in plugin.flags) then begin
      ShowMessage(Format(GetLanguageString('mpRes_Blacklisted'),
        [plugin.filename, merge.name]));
      continue;
    end;
    // skip plugins that are already in another merge
    if plugin.merge <> ' ' then begin
      ShowMessage(Format(GetLanguageString('mpRes_InMerge'),
        [plugin.filename, merge.name]));
      continue;
    end;
    // add plugin to merge if it isn't already in another merge
    if plugin.merge = ' ' then begin
      plugin.merge := merge.name;
      merge.plugins.Add(plugin.filename);
      merge.SortPlugins;
    end;
  end;

  // re-evalute issues
  EvaluateMergeIssues;
  if bBrokenDependencies then
    ResolvePageControl.ActivePage := tsBrokenDependencies;
end;

procedure TResolveForm.IgnoreDependencyItemClick(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
begin
  for i := 0 to Pred(lvBrokenDependencies.Items.Count) do begin
    ListItem := lvBrokenDependencies.Items[i];
    if not ListItem.Selected then
      continue;
    merge.ignoredDependencies.Add(ListItem.SubItems[0]);
  end;

  // re-evalute issues
  EvaluateMergeIssues;
  if bBrokenDependencies then
    ResolvePageControl.ActivePage := tsBrokenDependencies;
end;

procedure TResolveForm.PluginErrorsPopupMenuPopup(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
  plugin: TPlugin;
  bAllNeedErrorCheck, bAllPluginsHaveErrors, bHasSelection: boolean;
begin
  // initialze
  bAllNeedErrorCheck := true;
  bAllPluginsHaveErrors := true;
  bHasSelection:= false;

  for i := 0 to Pred(lvPluginErrors.Items.Count) do begin
    ListItem := lvPluginErrors.Items[i];
    if not ListItem.Selected then
      continue;
    // process booleans for plugin
    bHasSelection := true;
    plugin := PluginByFilename(ListItem.SubItems[0]);
    bAllNeedErrorCheck := bAllNeedErrorCheck and (not plugin.HasBeenCheckedForErrors);
    bAllPluginsHaveErrors := bAllPluginsHaveErrors and (plugin.HasErrors);
  end;

  // toggle menu items
  CheckPluginItem.Enabled := ProgramStatus.bLoaderDone and bHasSelection and bAllNeedErrorCheck;
  FixErrorsItem.Enabled := ProgramStatus.bLoaderDone and bHasSelection and bAllPluginsHaveErrors;
  IgnoreErrorsItem.Enabled := ProgramStatus.bLoaderDone and bHasSelection and bAllPluginsHaveErrors;
end;

procedure TResolveForm.ProgressDone;
begin
  xEditLogGroup := 'GENERAL';
  pForm.SaveLog;
  pForm.Visible := false;
  FlashWindow(Application.Handle, True);
  pForm.ShowModal;
  pForm.Free;
  Enabled := true;
  ShowWindow(Application.Handle, SW_RESTORE);
  SetForegroundWindow(Application.Handle);

  // free lists
  if Assigned(timeCosts) then timeCosts.Free;
  if Assigned(pluginsToHandle) then pluginsToHandle.Free;
  if Assigned(mergesToBuild) then mergesToBuild.Free;

  // re-evalute issues
  EvaluateMergeIssues;
  if bPluginErrors then
    ResolvePageControl.ActivePage := tsPluginErrors;
end;

procedure TResolveForm.btnIgnoreContiguousClick(Sender: TObject);
begin
  merge.bIgnoreNonContiguous := true;

  // re-evalute issues
  EvaluateMergeIssues;
  if bNonContiguous then
    ResolvePageControl.ActivePage := tsNonContiguous;
end;

procedure TResolveForm.CheckPluginItemClick(Sender: TObject);
var
  i: integer;
  ListItem: TListItem;
  plugin: TPlugin;
begin
  if not ProgramStatus.bLoaderDone then
    exit;
  // create lists
  pluginsToHandle := TList.Create;
  timeCosts := TStringList.Create;

  for i := 0 to Pred(lvPluginErrors.Items.Count) do begin
    ListItem := lvPluginErrors.Items[i];
    if not ListItem.Selected then
      continue;
    // skip blacklisted plugins and plugins that have already been checked
    plugin := PluginByFilename(ListItem.SubItems[0]);
    if (IS_BLACKLISTED in plugin.flags) or (plugin.errors.Count > 0) then
      continue;
    timeCosts.Add(plugin.numRecords);
    pluginsToHandle.Add(plugin);
  end;

  // show progress form
  ShowProgressForm(self, pForm, GetLanguageString('mpProg_Checking'), 'errors');

  // start error check thread
  ErrorCheckCallback := ProgressDone;
  TErrorCheckThread.Create;
end;

procedure TResolveForm.FixErrorsItemClick(Sender: TObject);
var
  i: integer;
  ListItem: TListItem;
  plugin: TPlugin;
begin
  if not ProgramStatus.bLoaderDone then
    exit;
  // create lists
  pluginsToHandle := TList.Create;
  timeCosts := TStringList.Create;

  for i := 0 to Pred(lvPluginErrors.Items.Count) do begin
    ListItem := lvPluginErrors.Items[i];
    if not ListItem.Selected then
      continue;
    // skip plugins that don't have errors
    plugin := PluginByFilename(ListItem.SubItems[0]);
    if not plugin.hasErrors then
      continue;
    timeCosts.Add(plugin.numRecords);
    pluginsToHandle.Add(plugin);
  end;

  // show progress form
  ShowProgressForm(self, pForm, GetLanguageString('mpProg_Fixing'), 'errors');

  // start error check thread
  ErrorFixCallback := ProgressDone;
  TErrorFixThread.Create;
end;

procedure TResolveForm.RemoveErrorsPluginItemClick(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
  plugin: TPlugin;
begin
  for i := 0 to Pred(lvPluginErrors.Items.Count) do begin
    ListItem := lvPluginErrors.Items[i];
    if not ListItem.Selected then
      continue;
    // remove plugin from merge
    plugin := PluginByFilename(ListItem.SubItems[0]);
    merge.Remove(plugin);
  end;

  // re-evalute issues
  EvaluateMergeIssues;
  if bPluginErrors then
    ResolvePageControl.ActivePage := tsPluginErrors;
end;

procedure TResolveForm.IgnoreErrorsItemClick(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
  plugin: TPlugin;
begin
  for i := 0 to Pred(lvPluginErrors.Items.Count) do begin
    ListItem := lvPluginErrors.Items[i];
    if not ListItem.Selected then
      continue;
    // ignore errors in plugin
    plugin := PluginByFilename(ListItem.SubItems[0]);
    plugin.bIgnoreErrors := true;
  end;

  // re-evalute issues
  EvaluateMergeIssues;
  if bPluginErrors then
    ResolvePageControl.ActivePage := tsPluginErrors;
end;

procedure TResolveForm.OtherIssuesPopupMenuPopup(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
  bAllPluginsUnloaded, bHasSelection: boolean;
begin
  // initialize booleans
  bAllPluginsUnloaded:= true;
  bHasSelection := false;

  for i := 0 to Pred(lvOtherIssues.Items.Count) do begin
    ListItem := lvOtherIssues.Items[i];
    if not ListItem.Selected then
      continue;
    // process booleans for plugin
    bHasSelection := true;
    bAllPluginsUnloaded := bAllPluginsUnloaded and
      (ListItem.Caption = GetLanguageString('mpRes_UnloadedPlugin'));
  end;

  // toggle menu items
  RemoveUnloadedPluginItem.Enabled := bHasSelection and bAllPluginsUnloaded;
end;

procedure TResolveForm.RemoveUnloadedPluginItemClick(Sender: TObject);
var
  i: Integer;
  ListItem: TListItem;
begin
  for i := 0 to Pred(lvOtherIssues.Items.Count) do begin
    ListItem := lvOtherIssues.Items[i];
    if not ListItem.Selected then
      continue;
    // remove plugin if is an unloaded plugin issue
    if ListItem.Caption = GetLanguageString('mpRes_UnloadedPlugin') then
      merge.Remove(ListItem.SubItems[0]);
  end;

  // re-evalute issues
  EvaluateMergeIssues;
  if bOtherIssues then
    ResolvePageControl.ActivePage := tsOtherIssues;
end;

end.
