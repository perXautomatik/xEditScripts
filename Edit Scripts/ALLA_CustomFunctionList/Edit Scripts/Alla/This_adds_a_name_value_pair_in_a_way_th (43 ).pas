
// This adds a name-value pair in a way that allows for duplicate values
function slAddValue(aName, aValue: String): String;
var
  slTemp: TStringList;
  debugMsg: Boolean;
begin
	// Initialize
  if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;

	// Function
	slTemp.Values[aValue] := aName;
	if (slTemp.Count > 0) then
		Result := slTemp[0];

	// Finalize
	slTemp.Free;
end;