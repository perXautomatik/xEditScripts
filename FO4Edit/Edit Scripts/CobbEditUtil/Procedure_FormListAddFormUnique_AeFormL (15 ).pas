

Procedure FormListAddFormUnique(aeFormList: IInterface; avForm: Variant);
Begin
   If FormListIndexOf(aeFormList, avForm) = -1 Then FormListAddForm(aeFormList, avForm);
End;
{$ENDREGION}