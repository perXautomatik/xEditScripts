unit userscript;
uses: 'universalHelperFunctions'
var
	fileFallout4, eHumanRace, eTintLayerContainer: IInterface;
	strBaseFolderPath: string;
	tstrlistTintLayers, tstrlistTintLayerIndexes, tstrlistFullTintLayers,
	tstrlistTemplateColors, tstrlistTemplateColorIndexes: TStringList;

function Initialize: integer;
begin
	
	SetupBaseFolderPath;
	
	
	strBaseFolderPath := ProgramPath + 'Edit Scripts\FyTy\Face Tint Groups\';
	fileFallout4 := FileByIndex(0);
	eHumanRace := RecordByFormID(fileFallout4, 79686, false);
	eTintLayerContainer := ElementByPath(eHumanRace, 'Female Tint Layers');
	
	
	OutputTintGroupsToFolder;
	
end;



function Finalize: integer;
begin
	
	
	
end;

end.