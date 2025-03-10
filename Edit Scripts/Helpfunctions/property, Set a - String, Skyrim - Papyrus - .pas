{
   For each selected object that has the specified Papyrus script attached, create a 
   property on that script with the specified name and assign it the specified string. 
   (If the property already exists, it is set -- a duplicate is not added.)
   
   We don't check the new property name against the script source, so it's possible 
   to add invalid properties with this.

   Created by DavidJCobb.
}
Unit CobbSingleSetPapyrusString;
Uses 'Skyrim - Papyrus Resource Library';
Uses 'CobbTES5EditUtil';

Var
   gsScriptName: String;
   gsPropertyName: String;
   gsValue: String;

Function Initialize: integer;
Var
   sType: String;
   slResult: TStringList;
Begin
   sType := 'String';
   //
   // Ask the user what to do.
   //
   slResult := PromptFor3Strings('Set ' + sType + ' property', 'Add property to what script?', 'Create a new ' + sType + ' property named...', 'Enter the value of the new property.');
   If slResult.Count = 0 Then Begin
      Result := 1;
      Exit;
   End Else Begin
      gsScriptName := slResult[0];
      gsPropertyName := slResult[1];
      gsValue := slResult[2];
   End;
End;

Function Process(e: IInterface) : Integer;
Begin
   If ElementType(e) = etMainRecord Then
      If ElementExists(e, 'VMAD') Then Begin
         SetStringPropertyOnScript(GetScript(e, gsScriptName), gsPropertyName, gsValue);
      End;
End;

End.