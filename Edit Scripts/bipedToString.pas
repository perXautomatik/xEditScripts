{
	Purpose: OTFT - List INAM Items
	Game: The Elder Scrolls V: Skyrim
	Author: fireundubh <fireundubh@gmail.com>
	Version: 0.1
}

unit UserScript;

function Initialize: integer;
	begin
		Result := 0;
	end;

function Process(e: IInterface): integer;
	var
		rec, list, ref, item: IInterface;
    input,output: TStringList;
		formid, edid, full, itemid,prefix: string;
		i,j,k,inputCount,outputCount: integer;
	begin
		Result := 0;

		//list := ElementByName(e, 'INAM - Items');

		AddMessage('-------------------------------------------------------------------------------');

		for i := 0 to ElementCount(e) - 1 do begin
			item	:= ElementByIndex(e, i);
		{	if iputcount = 1 & outputcount = 1 
        then prefix := convert
      else if output = 1
        then  prefix := create
      else if input =1 
        then  prefix := break

      casw input nr = output nr 
        and input contain 1 > element output 
          then prefix process
      
      ref		:= LinksTo(item);
			formid	:= IntToHex(FixedFormID(ref), 8);
			}
			edid	:= GetElementEditValues(ref, 'EDID');
			full	:= GetElementEditValues(ref, 'FULL');
			itemid	:= GetEditValue(item);
      input := GetElementEditValues(ref, 'Ingredients');
      output :=  GetElementEditValues(ref, 'Outputs');
      inputcount := input.count; //ElementCount(input);
      outputcount := output.count; //ElementCount(output);
      
			AddMessage(name(item));
      


      for j := 0 to ElementCount(item) - 1 do begin
			  list	:= ElementByIndex(item, j);
        AddMessage('_'+GetEditValue(list));

        for k := 0 to ElementCount(list) - 1 do begin
          ref	:= ElementByIndex(list, k);
          AddMessage('--'+GetEditValue(ref));

        end;
      end;
    end;

		AddMessage('-------------------------------------------------------------------------------');

	end;

function Finalize: integer;
	begin
		Result := 1;
	end;

end.
