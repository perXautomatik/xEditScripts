

// adds item record reference to the list
function YggaddItem(list: IInterface; item: IInterface; amount: integer): IInterface;
var
	newItem: IInterface;
	listName: string;
	debugmsg: boolean;
begin
	debugMsg := false;
	// add new item to list
	newItem := ElementAssign(list, HighInteger, nil, false);
	listName := Name(list);
	{debug} if debugmsg then msg('Current COBJ is ' + name(newItem));
	if Length(listName) = 0 then
	begin
		{debug} if debugmsg then msg('Crafting Recipe doesnt have proper item list');
		exit;
	end;
	// COBJ
	if listName = 'Items' then begin
		// set item reference
		SetElementEditValues(newItem, 'CNTO - Item\Item', GetEditValue(item));
		// set amount
		SetElementEditValues(newItem, 'CNTO - Item\Count', amount);
	end;
	{debug} if debugmsg then msg('item added');
	// remove nil records from list
	YggremoveInvalidEntries(list);

	Result := newItem;
end;