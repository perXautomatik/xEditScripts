
function YggcreateRecord(recordSignature: string; plugin: IInterface): IInterface;
var
  newRecordGroup: IInterface;
begin
	// get category in file
	newRecordGroup := GroupBySignature(plugin, recordSignature);

	// create record and return it
	result := elementassign(newRecordGroup, LowInteger, nil,false);
	//Result := Add(newRecordGroup, recordSignature, true);
end;