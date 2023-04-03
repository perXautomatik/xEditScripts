
{$REGION 'Functions for working with Containers'}
{
   Returns the number of aeItemBase in aeContainer.
}
Function ContainerCountOfItem(aeContainer: IInterface; aeItemBase: IInterface) : Integer;
Var
   iIterator: Integer;
   eItems: IInterface;
   eItemRecord: IInterface;
   iItemRecord: Integer;
Begin
   Result := 0;
   If Not Assigned(aeContainer) Or Not Assigned(aeItemBase) Then Exit;
   If Signature(aeContainer) <> 'CONT' Then Exit;
   eItems := ElementByName(aeContainer, 'Items');
   If Not Assigned(eItems) Then Exit;
   For iIterator := 0 To ElementCount(eItems) - 1 Do Begin
      eItemRecord := ElementBySignature(ElementByIndex(eItems, iIterator), 'CNTO');
      iItemRecord := GetElementNativeValues(eItemRecord, 'Item');
      If iItemRecord = FormID(aeItemBase) Then Begin
         Result := GetElementNativeValues(eItemRecord, 'Count');
	 Exit;
      End;
   End;
End;