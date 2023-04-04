
{
   Checks if any ObjectReferences of a given container are merchant chests.
}
Function ContainerIsMerchantChest(aeContainer: IInterface): Boolean;
Var
   iIterator: Integer;
   eReference: IInterface;
   iIterator2: Integer;
   eFaction: IInterface;
   iMerchantChest: IInterface;
Begin
   Result := False;
   For iIterator := 0 To ReferencedByCount(aeContainer) - 1 Do Begin
      eReference := ReferencedByIndex(aeContainer, iIterator);
      If Signature(eReference) <> 'REFR' Then Continue;
      If GetElementNativeValues(eReference, 'NAME') <> FOrmID(aeContainer) Then Continue;
      //
      // eReference is a placed instance (ObjectReference) of aeContainer.
      //
      For iIterator2 := 0 To ReferencedByCount(eReference) - 1 Do Begin
         eFaction := ReferencedByIndex(eReference, iIterator2);
	 If Signature(eFaction) <> 'FACT' Then Continue;
	 If ((1 Shl 14) And GetElementNativeValues(eFaction, 'DATA\Flags')) = 0 Then Continue;
	 //
	 // eFaction is a Faction with the Vendor flag set.
	 //
	 iMerchantChest := GetElementNativeValues(eFaction, 'VENC');
	 If iMerchantChest = FormID(eReference) Then Begin
	    Result := True;
	    Exit;
	 End;
      End;
   End;
End;