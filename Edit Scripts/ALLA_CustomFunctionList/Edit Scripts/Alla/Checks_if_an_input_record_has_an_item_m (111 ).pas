

// Checks if an input record has an item matching the input EditorID.
function HasItem(aRecord: IInterface; s: string): Boolean;
var
	name: string;
	items, li: IInterface;
	i: integer;
begin
	Result := False;
	items := ebp(aRecord, 'Items');
	if not Assigned(items) then
		exit;

	for i := 0 to Pred(ec(items)) do begin
		li := ebi(items, i);
		name := EditorID(LinksTo(ebp(li, 'CNTO - Item\Item')));
		if (name = s) then begin
			Result := True;
			Break;
		end;
	end;
end;