

{$REGION 'UI utility helpers'}
{
   Helper method: given a UI control and a string, finds any descendant 
   control whose Name is equal to the string.
}
Function FindControlByName(auiBase: TObject; asName: String) : TObject;
Var
   iIterator: Integer;
   sTemporary: String;
Begin
   Result := nil;
   For iIterator := 0 To auiBase.ComponentCount - 1 Do Begin
      Try
         sTemporary := auiBase.Components[iIterator].Name;
	 If sTemporary = asName Then Begin
	    Result := auiBase.Components[iIterator];
	    Exit;
	 End;
      Finally
      End;
   End;
   For iIterator := 0 To auiBase.ControlCount - 1 Do Begin
      Try
         sTemporary := auiBase.Controls[iIterator].Name;
	 If sTemporary = asName Then Begin
	    Result := auiBase.Controls[iIterator];
	    Exit;
	 End;
      Finally
      End;
   End;
   If Result = nil Then AddMessage('Failed to find UI control named ' + asName);
End;
{$ENDREGION}