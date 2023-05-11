

// Adds item record reference to the list [SkyrimUtils]
function addItem(aRecord: IInterface; aItem: IInterface; aCount: integer): IInterface;
var
  tempRecord: IInterface;
	debugMsg: Boolean;
begin
// Begin debugMsg section
	debugMsg := false;

	if not Assigned(ebp(aRecord, 'Items')) then
		Add(aRecord, 'Items', True);
	tempRecord := ElementAssign(ebp(aRecord, 'Items'), HighInteger, nil, False);
	seev(tempRecord, 'CNTO - Item\Item', Name(aItem));
	seev(tempRecord, 'CNTO - Item\Count', aCount);
	Result := tempRecord;

	debugMsg := false;
// End debugMsg section
end;