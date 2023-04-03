
Function FormListIndexOf(aeFormList: IInterface; avForm: Variant): Integer;
Var
   iFormID: Integer;
   eLNAM: IInterface;
   eEntry: IInterface;
   iIterator: Integer;
Begin
   Result := -1;
   Try
      iFormID := avForm;
   Except
      Try
         iFormID := StrToIntDef('$' + avForm, 0);
      Except
         iFormID := FormID(avForm);
      End;
   End;
   eLNAM := ElementBySignature(aeFormList, 'VMAD');
   If Not Assigned(eLNAM) Then Exit;
   For iIterator := 0 To ElementCount(eLNAM) - 1 Do Begin
      eEntry := ElementByIndex(eLNAM, iIterator);
      If GetNativeValue(eEntry) = iFormID Then Begin
         Result := iIterator;
	 Exit;
      End;
   End;
End;