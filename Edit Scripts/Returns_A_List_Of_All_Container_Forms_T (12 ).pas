
{
   Returns a list of all Container forms that contain this item, and all 
   Container forms that contain a LeveledItem that contains (directly or 
   indirectly) this item.
}
Function GetContainersWithItem(aeItemBase: IInterface): TList;
Var
   iIterator: Integer;
   eContainer: IInterface;
Begin
   Result := TList.Create;
   For iIterator := 0 To ReferencedByCount(aeItemBase) - 1 Do Begin
      eContainer := ReferencedByIndex(aeItemBase, iIterator);
      If Signature(eContainer) = 'LVLI' Then Begin
         MergeTLists(Result, GetContainersWithItem(eContainer));
      End;
      If Signature(eContainer) = 'CONT' Then Begin
         Result.Add(TObject(eContainer));
      End;
   End;
End;
{$ENDREGION}