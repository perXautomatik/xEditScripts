
// Creates new record inside provided file [Skyrim Utils]
function createRecord(recordFile: IwbFile; recordSignature: string): IInterface;
var
  newRecordGroup: IInterface;
begin
	newRecordGroup := gbs(recordFile, recordSignature);
	if not Assigned(newRecordGroup) then
		newRecordGroup := Add(recordFile, recordSignature, true);
	Result := Add(newRecordGroup, recordSignature, true);
end;