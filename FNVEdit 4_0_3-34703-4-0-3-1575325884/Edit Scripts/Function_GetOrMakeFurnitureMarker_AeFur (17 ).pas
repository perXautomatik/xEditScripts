

Function GetOrMakeFurnitureMarker(aeFurniture: IInterface; aiIndex: Integer): IInterface;
Var
   eMarkers: IInterface;
   eMarker: IInterface;
Begin
   Add(aeFurniture, 'Markers', True);
   Result := GetFurnitureMarker(aeFurniture, aiIndex);
   If Assigned(Result) Then Add(Result, 'NAM0', True);
   If Not Assigned(Result) Then Begin
      //Add(aeFurniture, 'Markers', True);
      eMarkers := ElementByName(aeFurniture, 'Markers');
      eMarker := ElementAssign(eMarkers, HighInteger, nil, False);
      SetNativeValue(ElementBySignature(eMarker, 'ENAM'), aiIndex);
      Add(eMarker, 'NAM0', True);
   End;
End;