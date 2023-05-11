
{$REGION 'Delphi syntax helpers'}
{
   Copies the contents of aslB into aslA.
}
Procedure MergeTLists(aslA: TList; aslB: TList);
Var
   iIterator: Integer;
Begin
   For iIterator := 0 To aslB.Count - 1 Do Begin
      If aslA.IndexOf(aslB[iIterator]) = -1 Then aslA.Add(aslB[iIterator]);
   End;
End;
Procedure MergeTStringLists(aslA: TStringList; aslB: TStringList);
Var
   iIterator: Integer;
Begin
   For iIterator := 0 To aslB.Count - 1 Do Begin
      If aslA.IndexOf(aslB[iIterator]) = -1 Then aslA.Add(aslB[iIterator]);
   End;
End;
{$ENDREGION}