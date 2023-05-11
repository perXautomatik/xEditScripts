
{Shorthand to create a form with a given signature and editor ID.}
Function CreateForm(aeFile: IInterface; asSignature: String; asEditorID: String): IInterface;
Begin
   Result := Add(GroupBySignature(aeFile, asSignature), asSignature, True);
   SetElementEditValues(Result, 'EDID', asEditorID);
End;
{$ENDREGION}