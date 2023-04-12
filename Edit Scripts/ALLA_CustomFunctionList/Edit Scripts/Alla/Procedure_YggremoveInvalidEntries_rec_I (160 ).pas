
procedure YggremoveInvalidEntries(rec: IInterface);
var
  i, num: integer;
  lst, ent: IInterface;
  recordSignature, refName, countname: string;
begin
	recordSignature := Signature(rec);

	// containers and constructable objects
	if (recordSignature = 'CONT') or (recordSignature = 'COBJ') then
		begin
		lst := ElementByName(rec, 'Items');
		refName := 'CNTO\Item';
		countname := 'COCT';
	end

	num := ElementCount(lst);
	// check from the end since removing items will shift indexes
	for i := num - 1 downto 0 do
	begin
		// get individual entry element
		ent := ElementByIndex(lst, i);
		// Check() returns error string if any or empty string if no errors
	if Check(ElementByPath(ent, refName)) <> '' then Remove(ent);
	end;

	// has counter
	if Assigned(countname) then
	begin
		// update counter subrecord
		if num <> ElementCount(lst) then
		begin
			num := ElementCount(lst);
			// set new value or remove subrecord if list is empty (like CK does)
			if num > 0 then SetElementNativeValues(rec, countname, num)
			else RemoveElement(rec, countname);
		end;
	end;
end;