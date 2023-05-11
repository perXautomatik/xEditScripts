
{
   aiEntry is a bitmask representing the entry points to disallow:
    1 Front
    2 Back
    4 Right
    8 Left
   16 Up
}
Procedure SetFurnitureBlockedEntryPoints(aeFurniture: IInterface; aiIndex: Integer; aiEntry: Integer);
Var
   eMarker: IInterface;
   eChild: IInterface;
   iSupported: Integer;
Begin
   iSupported := GetFurnitureEntryPoints(aeFurniture, aiIndex);
   eMarker := GetOrMakeFurnitureMarker(aeFurniture, aiIndex);
   eMarker := GetFurnitureMarker(aeFurniture, aiIndex); // xEdit APIs are totally broken... -_-
   SetElementNativeValues(eMarker, 'NAM0\Disabled Points', (aiEntry And iSupported));
End;