
Procedure SetFormModel(aeForm: IInterface; asModelPath: String);
Begin
   Add(aeForm, 'Model', True);
   SetElementEditValues(aeForm, 'Model\MODL', asModelPath);
End;