
function HasGenderKeyword(aRecord: IInterface): Boolean;
begin
	if (textInKeyword(aRecord, 'male', false)) or (textInKeyword(aRecord, 'female', false)) then result := true else result := false;
end;

function GetGenderFromKeyword(aRecord: IInterface): String;
begin
	Result := '';
	if textInKeyword(aRecord, 'female', false) then result := 'Female'
	else if textInKeyword(aRecord, 'male', false) then result := 'Male';
end;