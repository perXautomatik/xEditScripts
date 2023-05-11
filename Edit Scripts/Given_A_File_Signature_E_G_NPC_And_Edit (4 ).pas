
{Given a file, signature (e.g. NPC_), and editor ID, returns the desired Form.
This function is not performant. Cache its result whenever you can.}
Function GetRecordByEditorID(aeFile: IInterface; asSignature: String; asEditorID: String): IInterface;
Begin
   Result := MainRecordByEditorID(GroupBySignature(aeFile, asSignature), asEditorID);
End;

Function GetRecordInAnyFileByEditorID(asSignature: String; asEditorID: String): IInterface;
Var
   iIterator: Integer;
   eCurrentFile: IInterface;
Begin
   For iIterator := 0 To FileCount Do Begin
      eCurrentFile := FileByIndex(iIterator);
      Result := MainRecordByEditorID(GroupBySignature(eCurrentFile, asSignature), asEditorID);
      If Assigned(Result) Then Exit;
   End;
   Result := nil;
End;