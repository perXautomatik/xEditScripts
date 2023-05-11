

{$REGION 'Functions for working with FormLists'}
Procedure FormListAddForm(aeFormList: IInterface; avForm: Variant);
Var
   iFormID: Integer;
   eLNAM: IInterface;
   eEntry: IInterface;
Begin
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
   If Not Assigned(eLNAM) Then eLNAM := Add(aeFormList, 'LNAM', True);
   eEntry := ElementAssign(eLNAM, HighInteger, nil, False);
   SetNativeValue(eEntry, iFormID);
End;