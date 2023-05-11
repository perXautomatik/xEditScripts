
// Converts Hex FormID to String
function HexToStr(aFormID: String): String;
begin
  Result := IntToStr(StrToInt(aFormID));
end;

function Flip(inputBoolean: Boolean): Boolean;
begin
  if inputBoolean then Result := False   
  else Result := True;
end;

// gets record by IntToStr HEX FormID [SkyrimUtils]
function getRecordByFormID(id: string): IInterface;
var
	startTime, stopTime: TDateTime;
  tmp: IInterface;
begin
	// Initialize
	startTime := Time;

  // basically we took record like 00049BB7, and by slicing 2 first symbols, we get IntToStr file index, in this case Skyrim (00)
  tmp := FileByLoadOrder(StrToInt('$' + Copy(id, 1, 2)));

  // file was found
  if Assigned(tmp) then begin
    // look for this record in founded file, and return it
    tmp := RecordByFormID(tmp, StrToInt('$' + id), true);

    // check that record was found
    if Assigned(tmp) then begin
      Result := tmp;
    end else begin // return nil if not
      Result := nil;
    end;

  end else begin // return nil if not
    Result := nil;
  end;

	// Finalize
	stopTime := Time;
	if ProcessTime then
		addProcessTime('getRecordByFormID', TimeBtwn(startTime, stopTime));
end;