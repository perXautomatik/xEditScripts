
Procedure SetFurnitureMarkerState(asFurniture: IInterface; aiIndex: Integer; abState: Boolean);
var
   eMNAM: IInterface;
   iOldValue: LongWord;
   iBitValue: LongWord;
   iNewValue: LongWord;
Begin
   eMNAM := ElementBySignature(asFurniture, 'MNAM');
   iOldValue := GetNativeValue(eMNAM);
   iBitValue := 1 Shl aiIndex;
   If abState Then iNewValue := iOldValue Or iBitValue;
   If Not abState Then iNewValue := iOldValue And Not iBitValue;
   SetNativeValue(eMNAM, iNewValue);
End;
{$ENDREGION}