
{$REGION 'Functions for working with Keywords'}
Function HasKeyword(aeForm: IInterface; aeKeyword: IInterface): Boolean;
Var
   eKeywords: IInterface;
   iIterator: Integer;
Begin
   Result := False;
   eKeywords := ElementBySignature(aeForm, 'KWDA');
   If Not Assigned(eKeywords) Then Exit;
   For iIterator := 0 To ElementCount(eKeywords) - 1 Do Begin
      If GetNativeValue(ElementByIndex(eKeywords, iIterator)) = FormID(aeKeyword) Then Begin
         Result := True;
	 Exit;
      End;
   End;
End;