

// Find the type of Item
function ItemKeyword(inputRecord: IInterface): String;
var
  KWDAentries, KWDAkeyword: IInterface;
  debugMsg: Boolean;
  slTemp: TStringList;
  i: Integer;
begin
// Begin debugMsg section
	debugMsg := false;
	// Initialize
	if not Assigned(slTemp) then slTemp := TStringList.Create else slTemp.Clear;

	// Function
  slTemp.CommaText := 'ArmorHelmet, ArmorCuirass, ArmorGauntlets, ArmorBoots, ArmorShield, ClothingHead, ClothingBody, ClothingHands, ClothingFeet, ClothingCirclet, ClothingRing, ClothingNecklace, WeapTypeBattleaxe, WeapTypeBow, WeapTypeDagger, WeapTypeGreatsword, WeapTypeMace, WeapTypeSword, WeapTypeWarAxe, WeapTypeWarhammer, VendorItemArrow';
  {Debug} if debugMsg then for i := 0 to slTemp.Count-1 do msg('[ItemKeyword] '+slTemp[i]);
  KWDAentries := ebp(inputRecord, 'KWDA'); {Debug} if debugMsg then msg('[ItemKeyword] Pred(ec(KWDAentries)) :='+IntToStr(Pred(ec(KWDAentries))));
  for i := 0 to Pred(ec(KWDAentries)) do begin {Debug} if debugMsg then msg('[ItemKeyword] LinksTo(ebi(KWDAentries, i)) :='+EditorID(LinksTo(ebi(KWDAentries, i))));
    KWDAkeyword := LinksTo(ebi(KWDAentries, i)); {Debug} if debugMsg then msg('[ItemKeyword] slTemp.Count-1 :='+IntToStr(slTemp.Count-1));
	for i := 0 to slTemp.Count-1 do begin {Debug} if debugMsg then msg('[ItemKeyword] Result := '+slTemp[i]);
	  Result := slTemp[i]; {Debug} if debugMsg then msg('[ItemKeyword] EditorID(KWDAkeyword) := '+EditorID(KWDAkeyword)+') = Result := '+slTemp[i]+') then Exit;');
	  if (EditorID(KWDAkeyword) = Result) then begin
			slTemp.Free;
			Exit;
		end;
	end;
	Result := nil;
  end;
  {Debug} if debugMsg then msg('[ItemKeyword] Result := nil; Exit;');

	// Finalize
  slTemp.Free;
	debugMsg := false;
// End debugMsg section
end;