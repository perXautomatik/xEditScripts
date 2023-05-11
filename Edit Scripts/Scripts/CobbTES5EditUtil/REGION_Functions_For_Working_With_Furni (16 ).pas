

{$REGION 'Functions for working with Furniture'}
{Returns a Marker element within a Furniture's Markers collection}
Function GetFurnitureMarker(aeFurniture: IInterface; aiIndex: Integer): IInterface;
Var
   eMarkers: IInterface;
   iIterator: Integer;
   eMarker: IInterface;
Begin
   Result := nil;
   eMarkers := ElementByName(aeFurniture, 'Markers');
   For iIterator := 0 To ElementCount(eMarkers) - 1 Do Begin
      eMarker := ElementByIndex(eMarkers, iIterator);
      If GetElementNativeValues(eMarker, 'ENAM') = aiIndex Then Begin
         Result := eMarker;
	 Exit;
      End;
   End;
End;