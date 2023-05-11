

{$REGION 'General shorthands for working with files, forms, and the like.'}
{Returns a file by name (which should include the file extension).}
Function GetFileByName(asFileName: String): IInterface;
Var
   iIterator: Integer;
   eCurrentFile: IInterface;
Begin
   For iIterator := 0 To FileCount Do Begin
      eCurrentFile := FileByIndex(iIterator);
      If GetFileName(eCurrentFile) = asFileName Then Begin
         Result := eCurrentFile;
	 Exit;
      End;
   End;
End;