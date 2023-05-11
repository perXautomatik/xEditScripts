unit UserScript;

var
  plugin: IInterface;
  RefCount: integer;
  UpdCount: integer;
  TikCount: integer;

function Initialize: integer;
begin
  RefCount := 0;
  UpdCount := 0;
  TikCount := 0;
end;

procedure ConvertToContainer(e: IInterface; v: string; n: string; i: string; f: Cardinal);
var
  r: IInterface;
begin
  if i <> v then
    Exit;

  r := wbCopyElementToFile(e, plugin, False, True);
  SetElementEditValues(r, 'NAME', n);
  Inc(RefCount);
  AddMessage('Converted static ' + f + '-' + i + ' to container.');
end;

function Process(e: IInterface): integer;
var
  s: string;
  i: string;
  f: Cardinal;
begin
  if not IsMaster(e) then
    Exit;

  s := Signature(e);
  i := EditorID(LinksTo(ElementBySignature(e, 'NAME')));
  f := IntToHex(GetLoadOrderFormID(e), 8);

  if (s <> 'REFR') and (s <> 'ACHR') then
    Exit;

  if isInjected(e) then
    Exit;

  if GetIsDeleted(e) then
    Exit;

  if not Assigned(plugin) then begin
    if MessageDlg('Create a new plugin [YES], or use the plugin at the bottom of your load order [NO]?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      plugin := AddNewFile
    else
      plugin := FileByIndex(Pred(FileCount));
    if not Assigned(plugin) then begin
      Result := 1;
      Exit;
    end;
  end;

  if GetFileName(e) = GetFileName(plugin) then
    Exit;

  AddRequiredElementMasters(e, plugin, False);
  AddRequiredElementMasters(FileByIndex(11), plugin, False);

  if UpdCount = 99 then begin
    UpdCount := 0;
    Inc(TikCount);
    AddMessage('Still applying Lootable Statics script. Tick ' + IntToStr(TikCount) + '.');
  end else
    Inc(UpdCount);

  ConvertToContainer(e, 'Car01', '0A000ADD', i, f);
  ConvertToContainer(e, 'Car02', '0A000ADE', i, f);
  ConvertToContainer(e, 'Car03', '0A000ADF', i, f);
  ConvertToContainer(e, 'Car03A', '0A000AE0', i, f);
  ConvertToContainer(e, 'Car03B', '0A000AE1', i, f);
  ConvertToContainer(e, 'Car10', '0A000AE3', i, f);
  ConvertToContainer(e, 'Car01HulkBodyStatic', '0A000DC1', i, f);
  ConvertToContainer(e, 'Car02HulkBodyStatic', '0A000DC2', i, f);
  ConvertToContainer(e, 'Truck01', '0A00169E', i, f);
  ConvertToContainer(e, 'Truck02', '0A00169F', i, f);
  ConvertToContainer(e, 'Truck03', '0A0016A0', i, f);
  ConvertToContainer(e, 'Truck04', '0A0016A1', i, f);
  ConvertToContainer(e, 'Truck05', '0A0016A2', i, f);
  ConvertToContainer(e, 'Truck06', '0A0016A3', i, f);
  ConvertToContainer(e, 'Truck08', '0A0016A4', i, f);
  ConvertToContainer(e, 'NVDLC04Road01Car01', '0A0016A5', i, f);
  ConvertToContainer(e, 'NVDLC04Car03A', '0A0016A6', i, f);
  ConvertToContainer(e, 'NVDLC04Car03B', '0A0016A7', i, f);
  ConvertToContainer(e, 'Car10HulkBodyStatic', '0A0016A8', i, f);
  ConvertToContainer(e, 'Car03ChryslusBuildingStatic', '0A0016A9', i, f);
  ConvertToContainer(e, 'NVTruck', '0A0016AA', i, f);
  ConvertToContainer(e, 'dlcanchtruckhulk05static', '0A0016AB', i, f);
  ConvertToContainer(e, 'TruckFlatbed', '0A0016AC', i, f);
  ConvertToContainer(e, 'NVFireTruckStatic', '0A0016AD', i, f);
  ConvertToContainer(e, 'Car03HulkBodyStatic02', '0A0016AE', i, f);
  ConvertToContainer(e, 'Truck01Static', '0A0016AF', i, f);
  ConvertToContainer(e, 'Truck02Static', '0A0016B0', i, f);
  ConvertToContainer(e, 'truckarmy02Static', '0A0016B1', i, f);
  ConvertToContainer(e, 'NVDLC02ParkRangerTruck', '0A0016B2', i, f);
  ConvertToContainer(e, 'NVDLC04TruckArmy02StaticLightOn', '0A0016B3', i, f);
  ConvertToContainer(e, 'NVDLC04FireTruck', '0A0016B4', i, f);
  ConvertToContainer(e, 'NVDLC04TruckFlatbed', '0A0016B5', i, f);
  ConvertToContainer(e, 'NVGolfCart01', '0A0016B6', i, f);
  ConvertToContainer(e, 'NVGolfCart02', '0A0016B7', i, f);
  ConvertToContainer(e, 'NVCHPPatrolCar', '0A0016B8', i, f);
  ConvertToContainer(e, 'NVNHPPatrolCar', '0A0016B9', i, f);
  ConvertToContainer(e, 'NVNHPPatrolCarAltC', '0A0016BA', i, f);
  ConvertToContainer(e, 'NVDLC04Car03ChryslusBuildingStatic', '0A0016BD', i, f);

  ConvertToContainer(e, 'HotelDesk02Static', '0A0017E6', i, f);
  ConvertToContainer(e, 'LockerVaultR01Static', '0A0017F1', i, f);
  ConvertToContainer(e, 'HVEnclaveContainerStatic', '0A0017F2', i, f);
  ConvertToContainer(e, 'SchoolDeskDirtyR01', '0A0037CE', i, f);
  ConvertToContainer(e, 'SchoolDeskADirty01', '0A0037CF', i, f);

  ConvertToContainer(e, 'DLC03DuctworkVent01', '0A000800', i, f);
  ConvertToContainer(e, 'NVVent01', '0A000801', i, f);
  ConvertToContainer(e, 'NVMonoRailCarVent', '0A000802', i, f);
  ConvertToContainer(e, 'NVVentNOSOUND', '0A000803', i, f);

  ConvertToContainer(e, 'TreeWastelandHardwoodLog01', '0A000804', i, f);
  ConvertToContainer(e, 'TreeEvergreenStumpMudDirt01', '0A000805', i, f);
  ConvertToContainer(e, 'TreeStump01', '0A000806', i, f);
  ConvertToContainer(e, 'TreeWastelandHardwoodStump01', '0A000807', i, f);
  ConvertToContainer(e, 'TreeWastelandEvergreenStump01', '0A000808', i, f);
  ConvertToContainer(e, 'TreeHardwoodStumpCanyonRubble01', '0A000809', i, f);
  ConvertToContainer(e, 'TreeHardwoodStumpMudDirt01', '0A00080A', i, f);
end;

function Finalize: integer;
begin
  if Assigned(plugin) then
    SortMasters(plugin);

  AddMessage('Done adding lootable statics, updated ' + IntToStr(RefCount) + ' reference(s).');
end;

end.
