{
  Crafting Framework Workbench Patcher
  code derived from Ruddy88's Simple Sorter
  FALLOUT 4
  
  Aim: Changing workbench keywords so that all recipes can be found on Crafting Framework's multi-functional Universal Workbench.
  
  Requires: Crafting Framework, FO4Edit and MXPF
  
  Credits: 
  Ruddy88 for allowing me to use his code and adapt it for my own needs
}

unit UserScript;
// Import MXPF functions
uses 'lib\mxpf';

const
  localFormID_Armor = $02788A;
  localFormID_Weapon = $02788E;
  localFormID_Ammo = $02788B;
  localFormID_Junk = $02788C;
  
var
  UserCancelled, bReset, bChemlabOnly: Boolean;
  sCaption: String;
  cArmor, cAmmo, cWeapon, cJunk, cUtility, fWorkbenchKeywords: IInterface;
  

// Options dialogue form prep
procedure PrepareDialog(frm: TForm; caption: String; height, width: Integer);
begin
  frm.BorderStyle := bsDialog;
  frm.Height := height;
  frm.Width := width;
  frm.Position := poScreenCenter;
  frm.Caption := caption;
end;

// Sets layout for Main Options Form
procedure ShowForm;
var
  frm: TForm;
  lblPrompt, lblMoreinfo: TLabel;
  cbChemlabOnly: TCheckBox;
  btnNewPatch, btnAmend, btnCancel: TButton;
  i: integer;
begin
  frm := TForm.Create(nil);
  try
    // Create main frame
    PrepareDialog(frm, '::: Crafting Framework Workbench Patcher :::', 200, 280);
    lblPrompt := ConstructLabel(frm, frm, 20, 25, 40, 260 - 32, 'PLEASE SELECT OPTIONS', '');
    lblPrompt.Font.Style := [fsBold];
    lblMoreinfo := ConstructLabel(frm, frm, lblPrompt.Top +15, 25, 40, 260 - 32, 'Mouseover for more info', '');
    lblMoreinfo.Font.Style := lblMoreinfo.Font.Style + [fsItalic];
	
    cbChemlabOnly := ConstructCheckbox(frm, frm, lblMoreinfo.Top + 30, 30, 300, 'Recipes from Chemistry Station only', cbChecked, '');
    cbChemlabOnly.ShowHint := true;
    cbChemlabOnly.Hint := 'If checked only recipes with the Chemistry Station workbench keyword will get processed and converted.';
	cbChemlabOnly.Checked := False;
    
    btnNewPatch := TButton.Create(frm);
    btnNewPatch.Parent := frm;
    btnNewPatch.Left := frm.Width div 3 - btnNewPatch.Width -3;
    btnNewPatch.Top := cbChemlabOnly.Top + 40;
    btnNewPatch.Caption := 'New Patch';
    btnNewPatch.ModalResult := mrYes;
    btnNewPatch.ShowHint := true;
    btnNewPatch.Hint := 'Select this to clear previous patched records and re-run the script completely';
  
    btnAmend := TButton.Create(frm);
    btnAmend.Parent := frm;
    btnAmend.Left := btnNewPatch.Left + btnNewPatch.Width + 9;
    btnAmend.Top := btnNewPatch.Top;
    btnAmend.Caption := 'Amend';
    btnAmend.ModalResult := mrNo;
    btnAmend.ShowHint := true;
    btnAmend.Hint := 'Select this to only add new entries without clearing previously patched records';
    
    btnCancel := TButton.Create(frm);
    btnCancel.Parent := frm;
    btnCancel.Left := btnAmend.Left + btnAmend.Width + 9;
    btnCancel.Top := btnNewPatch.Top;
    btnCancel.Caption := 'Cancel';
    btnCancel.ModalResult := mrCancel;
  
    i := frm.ShowModal;
    UserCancelled := i = 2;
    bReset := i = 6;
    if not UserCancelled then begin
      bChemlabOnly := cbChemlabOnly.Checked;
    end;
  finally
    frm.Free;
  end;
end;

// Dialogue form for choosing which plugins to include in the patch. Taken from mteFunctions
function MultipleFileSelectString(sPrompt: String; var sFiles: String): Boolean;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    Result := MultipleFileSelect(sl, (sPrompt));
    sFiles := sl.CommaText;
  finally
    sl.Free;
  end;
end;

// Another part of the dialogie form. Has been edited to exclude vanilla esms and SkyAI plugins from checkable options.
function MultipleFileSelect(var sl: TStringList; prompt: string): Boolean;
const
  spacing = 24;
var
  frm: TForm;
  pnl: TPanel;
  lastTop, contentHeight: Integer;
  cbArray: Array[0..4351] of TCheckBox;
  lbl, lbl2: TLabel;
  sb: TScrollBox;
  i: Integer;
  f: IInterface;
  sFileName: String;
begin
  Result := false;
  frm := TForm.Create(nil);
  try
    frm.Position := poScreenCenter;
    frm.Width := 400;
    frm.Height := 600;
    frm.BorderStyle := bsDialog;
    frm.Caption := '::: PLUGIN SELECTION :::';
    
    // create scrollbox
    sb := TScrollBox.Create(frm);
    sb.Parent := frm;
    sb.Align := alTop;
    sb.Height := 500;
    
    // create label
    lbl := TLabel.Create(sb);
    lbl.Parent := sb;
    lbl.Caption := prompt;
    lbl.Font.Style := [fsBold];
    lbl.Left := 8;
    lbl.Top := 10;
    lbl.Width := 270;
    lbl.WordWrap := true;
    lbl2 := TLabel.Create(sb);
    lbl2.Parent := sb;
    lbl2.Caption := sCaption;
    lbl2.Font.Style := [fsItalic];
    lbl2.Left := 8;
    lbl2.Top := lbl.Top + lbl.Height + 12;
    lbl2.Width := 250;
    lbl2.WordWrap := true;
    lastTop := lbl2.Top + lbl2.Height + 12 - spacing;
    
    // create checkboxes
    for i := 0 to FileCount - 2 do begin
      f := FileByLoadOrder(i);
      sFileName := (GetFileName(f));
      if (GetAuthor(f) = 'CraftingFramework_WorkbenchPatcher') then
        Continue;
      cbArray[i] := TCheckBox.Create(sb);
      cbArray[i].Parent := sb;
      cbArray[i].Caption := Format(' [%s] %s', [IntToHex(i, 2), GetFileName(f)]);
      cbArray[i].Top := lastTop + spacing;
      cbArray[i].Width := 260;
      lastTop := lastTop + spacing;
      cbArray[i].Left := 12;
      if bReset then
        cbArray[i].Checked := true
      else
        cbArray[i].Checked := sl.IndexOf(GetFileName(f)) > -1;
      if (sFilename = 'CraftingFramework.esp') then
        begin
          cbArray[i].Checked := true;
          cbArray[i].Enabled := False;
        end;
    end;
    
    contentHeight := spacing*(i + 2) + 150;
    if frm.Height > contentHeight then
      frm.Height := contentHeight;
    
    // create modal buttons
    cModal(frm, frm, frm.Height - 70);
    sl.Clear;
    
    if frm.ShowModal = mrOk then begin
      Result := true;
      for i := 0 to FileCount - 2 do begin
        f := FileByLoadOrder(i);
        sFileName := (GetFileName(f));
        if (GetAuthor(f) = 'CraftingFramework_WorkbenchPatcher') then
          Continue
        else if (cbArray[i].Checked) and (sl.IndexOf(GetFileName(f)) = -1) then
          sl.Add(GetFileName(f));
      end;
    end;
  finally
    frm.Free;
  end;
end;


//////////////////////////////
// Various Custom Functions //
//////////////////////////////

// Clears workbench and category keywords from recipes, adds Crafting Framework keywords instead.
procedure clearRecipeKeywords(rec, kWorkbench: IInterface);
begin
  Remove(ElementBySignature(rec, 'BNAM'));
  Add(rec, 'BNAM', false);
  SetElementEditValues(rec, 'BNAM - Workbench Keyword', Name(kWorkbench));
end;


////////////////////////////
// GROUP Filter Functions //
////////////////////////////

// The following procedures filter out already loaded records prior to copying them to the plugin if they are deemed invalid for tagging.

procedure filterCOBJ(j: Integer; rec: IInterface);
begin
  if not ElementExists(rec, 'BNAM - Workbench Keyword')
  or not ElementExists(rec, 'CNAM - Created Object') then
    RemoveRecord(j)
  else if not ContainsText((GetElementEditValues(rec, 'BNAM - Workbench Keyword')), 'WorkbenchChemlab') and bChemlabOnly then
    RemoveRecord(j)
  else if not (Signature(WinningOverride(LinksTo(ElementBySignature(rec, 'CNAM - Created Object')))) = 'ARMO')
  and not (Signature(WinningOverride(LinksTo(ElementBySignature(rec, 'CNAM - Created Object')))) = 'AMMO')
  and not (Signature(WinningOverride(LinksTo(ElementBySignature(rec, 'CNAM - Created Object')))) = 'WEAP') then
    RemoveRecord(j);
end;


///////////////////////////
// GROUP Patch Functions //
///////////////////////////

// The following procedures modify the valid records after they have been copied to the plugin.

procedure patchCOBJ(rec: IInterface);
var
  r: IInterface;
begin
  r := WinningOverride(LinksTo(ElementBySignature(rec, 'CNAM')));
  if Signature(r) = 'ARMO' then
    clearRecipeKeywords(rec, cArmor)
  else if Signature(r) = 'AMMO' then
    clearRecipeKeywords(rec, cAmmo)
  else if Signature(r) = 'WEAP' then
    clearRecipeKeywords(rec, cWeapon);    
end;

/////////////////
// Main Script //
/////////////////

function Initialize: Integer;

var
  i: Integer;
  rec: IInterface;
  sFiles: String;
  
begin

  // Call MXPF init functions and set MXPF prefs
  InitializeMXPF;
  mxLoadMasterRecords := true;
  mxSkipPatchedRecords := true;
  mxLoadWinningOverrides := true;
  mxDebug := false;
  mxSaveDebug := false;
  mxSaveFailures := false;
  mxPrintFailures := false;
  
  fWorkbenchKeywords := FileByName('CraftingFramework.esp');
  
  // Call form for user options.
  ShowForm;
  
  if UserCancelled then begin
    AddMessage('User cancelled patching');
    AddMessage('Operation cancelled. No patch generated');
    exit;
  end; 
  
  if bReset then
    sCaption := 'It is advised to keep all plugins selected unless certain plugins are causing errors.'
  else
    sCaption := 'Only include plugins not previously patched or plugins that may have received updates with new records.';
  
  if not MultipleFileSelectString(('Select the plugins you would like to be included.'), sFiles) then
    exit;
  SetInclusions(sFiles);  
  PatchFileByAuthor('CraftingFramework_WorkbenchPatcher');
  
  ShowMessage('Script Initialising. Patching can take some time depending on the size of your mod list. Please be patient.');
  // createLists();
  
  // Nukes previous patch files if creating NEW PATCH.
  if bReset then
    begin
      RemoveNode(GroupBySignature(mxPatchFile, 'COBJ'));
    end;

  // Load valid records.
  AddMessage('Loading records...');
  LoadRecords('COBJ');
      
  cArmor := RecordByFormID(fWorkbenchKeywords, (MasterCount(fWorkbenchKeywords) * $01000000 + localFormID_Armor), false);
  cWeapon := RecordByFormID(fWorkbenchKeywords, (MasterCount(fWorkbenchKeywords) * $01000000 + localFormID_Weapon), false);
  cAmmo := RecordByFormID(fWorkbenchKeywords, (MasterCount(fWorkbenchKeywords) * $01000000 + localFormID_Ammo), false);
  cJunk := RecordByFormID(fWorkbenchKeywords, (MasterCount(fWorkbenchKeywords) * $01000000 + localFormID_Junk), false);
      
  AddMessage('Filtering invalid records...');
  
  // Filter out unnecessary records on groups that may contain invalid records for tagging.
  for i := MaxrecordIndex downto 0 do begin
    rec := GetRecord(i);
    if (GetElementEditValues(rec, 'Record Header\Signature') = 'COBJ') then
      filterCOBJ(i, rec);
  end;
  
  // Copy remaining records to patch file.
  AddMessage('Copying records to patch...');
  AddMessage('This process can take several minutes, please be patient');
  CopyRecordsToPatch;
  
  // Patch Files
  AddMessage('Beginning patch file process...');
  AddMessage('Patching ' + IntToStr(MaxPatchRecordIndex + 1) + (' Records...'));
  for i :=  MaxPatchRecordIndex downto 0 do begin
    rec := GetPatchRecord(i);
    if (GetElementEditValues(rec, 'Record Header\Signature') = 'COBJ') then
      begin
        patchCOBJ(rec);
      end;
  end;
  
  AddMessage('Patching Process Complete. Finalising Script');
  AddMessage('This process can take several minutes, please be patient');
  
  // Cleanup MXPF
  CleanMasters(mxPatchFile);
  //PrintMXPFReport;
  FinalizeMXPF;
  ShowMessage('Patching Complete.');
end;
end.