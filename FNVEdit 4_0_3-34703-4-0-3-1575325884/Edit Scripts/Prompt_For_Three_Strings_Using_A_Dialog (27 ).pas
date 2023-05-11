
{
   Prompt for three strings using a dialog box; you can specify labels for each 
   string.
}
{$REGION 'PromptFor3Strings(asTitle, asLabel1, asLabel2, asLabel3)'}
Function PromptFor3Strings(asTitle: String; asLabel1: String; asLabel2: String; asLabel3: String): TStringList;
Var
   slLabels: TStringList;
Begin

   slLabels := TStringList.Create;
   slLabels.Add(asLabel1);
   slLabels.Add(asLabel2);
   slLabels.Add(asLabel3);
   Result := PromptForStrings(asTitle, slLabels);
End;
{$ENDREGION}