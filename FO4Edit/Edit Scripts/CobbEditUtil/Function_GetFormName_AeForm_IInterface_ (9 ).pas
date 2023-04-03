
Function GetFormName(aeForm: IInterface): String;
Begin
   Result := GetElementEditValues(aeForm, 'FULL');
End;

Procedure SetFormName(aeForm: IInterface; asName: String);
Begin
   SetElementEditValues(aeForm, 'FULL', asName);
End;
{$ENDREGION}