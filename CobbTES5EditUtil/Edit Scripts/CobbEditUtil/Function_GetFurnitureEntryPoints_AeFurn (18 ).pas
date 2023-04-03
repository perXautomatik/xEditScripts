
Function GetFurnitureEntryPoints(aeFurniture: IInterface; aiIndex: Integer): Integer;
Begin
   Result := GetElementNativeValues(ElementByIndex(ElementByName(aeFurniture, 'Marker Entry Points'), aiIndex), 'Entry Points');
End;