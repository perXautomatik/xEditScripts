
// Copies from end instead of beginning
function StrPosCopyReverse(inputString: String; findString: String; inputBoolean: Boolean): String;
begin
  if ContainsText(inputString, findString) then begin
    RemoveFromEnd(inputString, ' ');
    if (findString = ' ') then
	  if Flip(inputBoolean) then Result := RemoveFromEnd(ReverseString(Copy(ReverseString(inputString), 0, ItPos(findString, ReverseString(inputString), 2)-length(findString))), ' ')
	  else Result := RemoveFromEnd(ReverseString(Copy(ReverseString(inputString), ItPos(findString, ReverseString(inputString), 2)-length(findString)), (Length(ReverseString(inputString))-ItPos(findstring, inputstring, 2))), ' ')
	else Result := ReverseString(StrPosCopy(ReverseString(inputString), findString, Flip(inputBoolean)))
	// msg('[StrPosCopyReverse]'+ReverseString(inputString));
	// msg('[StrPosCopyReverse]'+StrPosCopy(ReverseString(inputString), ' ', Flip(inputBoolean)));
	// msg('[StrPosCopyReverse]'+ReverseString(StrPosCopy(ReverseString(inputString), ' ', Flip(inputBoolean))));
  end else Result := inputString;
end;