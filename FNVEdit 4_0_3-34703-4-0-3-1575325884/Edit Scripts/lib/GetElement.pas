unit getElement;

// --------------------------------------------------------------------
// Returns any element from a string
// --------------------------------------------------------------------
function GetElementQ(const x: IInterface; const s: String): IInterface;
begin
	if Length(s) > 0 then begin
		if Pos('[', s) > 0 then
			Result := ElementByIP(x, s)
		else if Pos('\', s) > 0 then
			Result := ElementByPath(x, s)
		else if s = Uppercase(s) then
			Result := ElementBySignature(x, s)
		else
			Result := ElementByName(x, s);
	end;
end;
//=========================================================================
// convert record to string consisting of Editor ID and plugin's name with signature of group
function RecordToString(rec: IInterface): string;
var
	baseRec: IInterface;
begin
	baseRec := MasterOrSelf(rec); //use baseRec to be safe against renames
	Result := EditorID(baseRec) + '[' + GetFileName(baseRec) + ']' + ':' + Signature(baseRec);
end;


// ==================================================================
// Better SortKey
// Returns the sortkey with handling for .nif paths, and unknown/unused
// 	data. Also uses a better delimiter.
// --------------------------------------------------------------------
function SortKeyEx(const e: IInterface): String;
var
	i: integer;
	kElement: IInterface;
begin
	Result := GetEditValue(e);

	// manipulate result for model paths - sometimes the same paths have different cases
	if (pos('.nif', Lowercase(Result)) > 0) then
		Result := Lowercase(GetEditValue(e));

	for i := 0 to ElementCount(e) - 1 do begin
		kElement := ElementByIndex(e, i);
//		AddMessage('Processing: ' + ElementByIndex(e, i));

		if (Pos('unknown', Lowercase(Name(kElement))) > 0)
		or (Pos('unused', Lowercase(Name(kElement))) > 0) then
			exit;
		if (Result <> '') then
			Result := Result + ' ' + SortKeyEx(kElement)
		else
			Result := SortKeyEx(kElement);
	end;
end;

// --------------------------------------------------------------------
// Bin to Int
// --------------------------------------------------------------------
function BinToIntY(value: String): LongInt;
var
	i, sz: Integer;
begin
	Result := 0;
	sz := Length(value);
	for i := sz downto 1 do
		if Copy(value, i, 1) = '1' then
			Result := Result + (1 shl (sz - i));
end;

function BipedDataToString(const kElement: IInterface): string;
const
  //Outfit, Glove, Boots, NoseRing, Neck, Belt, Back, Accessory, EditValueEDID,OutfitBin, GloveBin, BootsBin, NoseRingBin, NeckBin, BeltBin, BackBin, AccessoryBin: string;
    Accessory = 'Accessory';
  AccessoryBin = '0000000000000001'      ;
    Back = 'Back';
  BackBin = '00000001';
    Belt = 'Belt';
  BeltBin = '00000000000000000001';
    Boots = 'Boots';
  BootsBin = '0000000000000000001';
    Glove = 'Glove';
  GloveBin = '000000000000000001';
    Neck = 'Neck';
  NeckBin = '000000001';
    NoseRing = 'Shoulder';
  NoseRingBin = '0000000000001';
    Outfit = 'Outfit';
  OutfitBin = '001';
var
i,q: integer;
prefix,output: string;
begin        
	for i := 0 to ElementCount(kElement) - 1 do begin
		prefix := getEditValue(ElementByIndex(kElement, i));
		//AddMessage(': ' + prefix);
		q := length(prefix);
	case q of
	3	:	begin if prefix = OutfitBin then output := output + ', ' + Outfit else	begin
		output := output +' '+inttostr(q)+'['+ prefix+ ']';
		end;
			end;
		length(GloveBin)	:	begin if prefix = GloveBin then output := output + ', ' + Glove else	begin
			output := output +' '+inttostr(q)+'['+ prefix+ ']';
			end;
		end;
	length(BootsBin)	:	begin if prefix = BootsBin then output := output + ', ' + Boots else	begin
		output := output +' '+inttostr(q)+'['+ prefix+ ']';
		end;
			end;
		length(NoseRingBin)	:	begin if prefix = NoseRingBin then output := output + ', ' + NoseRing else	begin
			output := output +' '+inttostr(q)+'['+ prefix+ ']';
			end;
		end;
	length(NeckBin)	:	begin if prefix = NeckBin then output := output + ', ' + Neck else	begin
		output := output +' '+inttostr(q)+'['+ prefix+ ']';
		end;
			end;
		length(BeltBin)	:	begin if prefix = BeltBin then output := output + ', ' + Belt else	begin
			output := output +' '+inttostr(q)+'['+ prefix+ ']';
			end;
		end;
	length(BackBin)	:	begin if prefix = BackBin then output := output + ', ' + Back else	begin
		output := output +' '+inttostr(q)+'['+ prefix+ ']';
		end;
			end;
		length(AccessoryBin)	:	begin if prefix = AccessoryBin then output := output + ', ' + Accessory else	begin
			output := output +' '+inttostr(q)+'['+ prefix+ ']';
			end;
		end;
	else	begin if q < 10 then output := output +' '+inttostr(q)+'['+ prefix+ ']' else
		output := output +'.'+inttostr(q);
		end;
	end;
end;
result: = output+ ' ';

end;



end.