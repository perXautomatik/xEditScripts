

// Gets a HexFormID
function HexFormID(e: IInterface): String;
begin
	Result := IntToHex(GetLoadOrderFormID(e), 8);
end;