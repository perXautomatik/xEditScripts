

{$REGION 'Functions for working with generic Forms'}
Function GetFormModel(aeForm: IInterface): String;
Begin
   Result := GetElementEditValues(aeForm, 'Model\MODL');
End;