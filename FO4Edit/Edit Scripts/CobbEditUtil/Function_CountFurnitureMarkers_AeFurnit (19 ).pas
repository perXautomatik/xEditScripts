
Function CountFurnitureMarkers(aeFurniture: IInterface): Integer;
Begin
   Result := ElementCount(ElementByName(aeFurniture, 'Marker Entry Points'));
End;