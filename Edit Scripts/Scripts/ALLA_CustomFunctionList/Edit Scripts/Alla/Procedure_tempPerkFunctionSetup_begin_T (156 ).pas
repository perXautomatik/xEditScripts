
procedure tempPerkFunctionSetup;
begin
	TempPerkListExtra := TStringList.Create;
	TempPerkListExtra.sorted := true;
	TempPerkListExtra.duplicates := dupIgnore;
	TempPerkListExtra.AddObject('ArmorMaterialDragonscale', getRecordByFormID('00052190'));
	TempPerkListExtra.AddObject('ArmorMaterialDragonplate', getRecordByFormID('00052190'));
	TempPerkListExtra.AddObject('ArmorMaterialDaedric', getRecordByFormID('000CB413'));
	TempPerkListExtra.AddObject('ArmorMaterialDwarven', getRecordByFormID('000CB40E'));
	TempPerkListExtra.AddObject('ArmorMaterialEbony', getRecordByFormID('000CB412'));
	TempPerkListExtra.AddObject('ArmorMaterialElven', getRecordByFormID('000CB40F'));
	TempPerkListExtra.AddObject('ArmorMaterialElvenGilded', getRecordByFormID('000CB40F'));
	TempPerkListExtra.AddObject('ArmorMaterialBonemoldHeavy', getRecordByFormID('000CB40D'));
	TempPerkListExtra.AddObject('DLC2ArmorMaterialBonemoldHeavy', getRecordByFormID('000CB40D'));
	TempPerkListExtra.AddObject('ArmorMaterialGlass', getRecordByFormID('000CB411'));
	TempPerkListExtra.AddObject('ArmorMaterialImperialHeavy', getRecordByFormID('000CB40D'));
	TempPerkListExtra.AddObject('ArmorMaterialOrcish', getRecordByFormID('000CB410'));
	TempPerkListExtra.AddObject('ArmorMaterialScaled', getRecordByFormID('000CB414'));
	TempPerkListExtra.AddObject('ArmorMaterialSteel', getRecordByFormID('000CB40D'));
	TempPerkListExtra.AddObject('ArmorMaterialSteelPlate', getRecordByFormID('000CB414'));
	TempPerkListExtra.AddObject('ArmorMaterialNordicHeavy', getRecordByFormID('000CB414'));
	TempPerkListExtra.AddObject('DLC2ArmorMaterialNordicHeavy', getRecordByFormID('000CB414'));
	TempPerkListExtra.AddObject('ArmorMaterialStalhrimHeavy', getRecordByFormID('000CB412'));
	TempPerkListExtra.AddObject('DLC2ArmorMaterialStalhrimHeavy', getRecordByFormID('000CB412'));
	TempPerkListExtra.AddObject('ArmorMaterialStalhrimLight', getRecordByFormID('000CB412'));
	TempPerkListExtra.AddObject('DLC2ArmorMaterialStalhrimLight', getRecordByFormID('000CB412'));
	TempPerkListExtra.AddObject('ArmorMaterialBonemoldHeavy2', getRecordByFormID('000CB40D'));
	TempPerkListExtra.AddObject('ArmorMaterialChitinHeavy', getRecordByFormID('000CB40F'));
	TempPerkListExtra.AddObject('DLC2ArmorMaterialChitinHeavy', getRecordByFormID('000CB40F'));
	TempPerkListExtra.AddObject('ArmorMaterialChitinLight', getRecordByFormID('000CB40F'));
	TempPerkListExtra.AddObject('DLC2ArmorMaterialChitinLight', getRecordByFormID('000CB40F'));
end;

function TrueRecordByEDID(edid: String): IInterface;
var
	a: integer;
	temp: IInterface;
	debugmsg:boolean;
begin
	debugMsg := false;
	for a := fileCount - 1 downto 0 do
	begin
		temp := MainRecordByEditorID(GroupBySignature(FileByIndex(a), 'KYWD'), edid);
		if assigned(temp) then break;
	end;
	if not assigned(temp) then
	begin
		{Debug} if debugMsg then msg('there is a typo in a edid');
	end;
	result := temp;
end;