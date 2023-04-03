
Function GetRecordInAnyFileByFormID(aiEditorID: String): IInterface;
Var
   iIterator: Integer;
   eCurrentFile: IInterface;
Begin
   For iIterator := 0 To FileCount Do Begin
      eCurrentFile := FileByIndex(iIterator);
      Result := RecordByFormID(eCurrentFile, aiEditorID, False);
      If Assigned(Result) Then Exit;
   End;
   Result := nil;
End;