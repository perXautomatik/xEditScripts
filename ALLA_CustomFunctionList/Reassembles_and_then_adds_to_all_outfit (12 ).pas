

// Reassembles and then adds to all outfits containing inputRecord
function AddToOutfitAuto(templateRecord: IInterface; inputRecord: IInterface; aPlugin: IInterface): String; 
var
  tempLevelList, tempRecord, tempElement, masterLevelList, baseLevelList, subLevelList, vanillaLevelList, masterRecord, LVLIrecord, OTFTrecord,
	OTFTitems, OTFTitem, OTFTcopy, LLentry, Record_edid: IInterface;
  debugMsg, tempBoolean, LightArmorBoolean, HeavyArmorBoolean: Boolean; 
  tempInteger, i, x, y, z, a, b: Integer;
  slTemp, slTempObject, slOutfit, slpair, slItem, slEnchantedList, slLevelList, slBlackList, slStringList, sl1, sl2: TStringList;
  tempString, String1, CommonString, OTFTrecord_edid: String;
begin
	// If the OTFT draws from a series of level lists assemble complete outfits from the items in those lists.
	// In most cases OTFT records draw from a level list for each piece of the outfit (e.g. boots level list, helmet level list, etc.)
	// Identifies and assembles based on BOD2 slots
	// This assembles a level list of the entire 'Steel Plate' outfit so that npcs will USUALLY spawn with a complete outfit instead of a hodge-podge drawn from various level lists
	// This does not edit or remove the original list.  The original entries remain intact as a single outfit within the complete list of outfits in masterLevelList. 
	// This means that, if there is 1 level list of the original outfit, 9 outfits are detected and assembled, and the script is adding 1 outfit, then you will StrToIntll have a 1/11 chance for a hodge-podge outfit <-- (1+9+1)
	// This is intended.  The goal is to improve the outfits, NEVER to remove existing entries or functionality (even if there is a lower chance to find those items).
	// The output should be A) A LL of selected Records B) LLs of outfit's original records C) A LL consiStrToIntng of the leftovers
// Begin debugMsg Section
  debugMsg := false;

	// Initialize
	if not Assigned(slEnchantedList) then slEnchantedList := TStringList.Create else slEnchantedList.Clear;
	if not Assigned(slStringList) then slStringList := TStringList.Create else slStringList.Clear;
	if not Assigned(slTempObject) then slTempObject := TStringList.Create else slTempObject.Clear;
	if not Assigned(slBlacklist) then slBlacklist := TStringList.Create else slBlacklist.Clear;
	if not Assigned(slLevelList) then slLevelList := TStringList.Create else slLevelList.Clear;
	if not Assigned(slOutfit) then slOutfit := TStringList.Create else slOutfit.Clear;
	if not Assigned(slItem) then slItem := TStringList.Create else slItem.Clear;
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;
	if not Assigned(slpair) then slpair := TStringList.Create else slpair.Clear;
	if not Assigned(sl1) then sl1 := TStringList.Create else sl1.Clear;
	if not Assigned(sl2) then sl2 := TStringList.Create else sl2.Clear;

	// Common Function Output
  masterRecord := MasterOrSelf(templateRecord);
 