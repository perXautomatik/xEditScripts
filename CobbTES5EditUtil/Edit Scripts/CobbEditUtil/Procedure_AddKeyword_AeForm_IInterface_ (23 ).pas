
Procedure AddKeyword(aeForm: IInterface; aeKeyword: IInterface);
Var
   eKeywords: IInterface;
   eNewKeyword: IInterface;
Begin
   If Not HasKeyword(aeForm, aeKeyword) Then Begin
      eKeywords := ElementBySignature(aeForm, 'KWDA');
      If Not Assigned(eKeywords) Then eKeywords := Add(aeForm, 'KWDA', True);
      If ElementCount(eKeywords) = 1 And GetNativeValue(ElementByIndex(eKeywords, 0)) = 0 Then Begin
         //
         // If the CK wrote a null KWDA record, reuse it.
         //
         SetNativeValue(ElementByIndex(eKeywords, 0), FormID(aeKeyword));
      End Else Begin
         //
         // Otherwise, add a new keyword.
         //
         eNewKeyword := ElementAssign(eKeywords, HighInteger, nil, False);
	 If Not Assigned(eNewKeyword) Then Exit; // Can't add keyword to this record.
	 SetNativeValue(eNewKeyword, FormID(aeKeyword));
      End;
      //
      // Update keyword count value.
      //
      If Not ElementExists(aeForm, 'KSIZ') Then Add(aeForm, 'KSIZ', True);
      SetElementNativeValues(aeForm, 'KSIZ', ElementCount(eKeywords));
   End;
End;
{$ENDREGION}