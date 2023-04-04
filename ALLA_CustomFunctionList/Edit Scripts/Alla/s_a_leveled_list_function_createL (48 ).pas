
// Creates a leveled list
function createLeveledList(aPlugin: IInterface; aName: String; LVLF: TStringList; LVLD: Integer): IInterface;
var
	startTime, stopTime: TDateTime;
	aLevelList: IInterface;
	debugMsg: Boolean;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;

	{Debug} if debugMsg then msgList('[createLeveledList] createLeveledList('+GetFileName(aPlugin)+', '+aName+', ', LVLF, ', '+IntToStr(LVLD)+' );');
	aLevelList := createRecord(aPlugin, 'LVLI');
	SetElementEditValues(aLevelList, 'EDID', aName);
	slSetFlagValues(aLevelList, LVLF, aPlugin);
	if not (LVLD = 0) then
		SetElementEditValues(aLevelList, 'LVLD', LVLD);
	Add(aLevelList, 'Leveled List Entries', true);
	RemoveInvalidEntries(aLevelList);
	Result := aLevelList;
	{Debug} if debugMsg then msg('[createLeveledList] Result := '+EditorID(Result));

	// Finalize
	stopTime := Time;
	if ProcessTime then
		addProcessTime('createLeveledList', TimeBtwn(startTime, stopTime));
end;