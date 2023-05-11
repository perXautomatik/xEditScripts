

{
   Prompt for two strings using a dialog box; you can specify labels for each 
   string.
}
{$REGION 'PromptFor2Strings(asTitle, asLabel1, asLabel2)'}
Function PromptFor2Strings(asTitle: String; asLabel1: String; asLabel2: String): TStringList;
Var
   slLabels: TStringList;
Begin

   slLabels := TStringList.Create;
   slLabels.Add(asLabel1);
   slLabels.Add(asLabel2);
   Result := PromptForStrings(asTitle, slLabels);
End;
{$ENDREGION}