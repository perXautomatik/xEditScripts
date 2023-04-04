{
	M8r98a4f2s Complex Item Sorter for FallUI - Record Scripting
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Used for applieng dynamic little modification scripts for records
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit RecordScript;

implementation

{Initialise unit}
procedure init;
begin

end;

{Processes a record script for a given record}
procedure processRecScript(rec:IInterface;script:String);
var 
	i, pointer: Integer;
	action, sStr1,sStr2: String;
	curElm, lastFoundElm: IInterface;
	curScript: TStringList;
	stack: TList;
begin
	// Setup
	curScript := TStringList.Create;
	curScript.StrictDelimiter := True;
	curScript.Delimiter := ' ';
	script := StringReplace(script,'(',' ( ',[rfReplaceAll]);
	script := StringReplace(script,')',' ) ',[rfReplaceAll]);
	script := PregReplace('\s+',' ',script);
	curScript.DelimitedText := Trim(script);
	stack := TList.Create;
	stack.Add(rec);
	curElm := rec;
	
	// Action
	pointer := 0;
	while pointer < curScript.Count do begin
		
		action := LowerCase(curScript[pointer]);
		Inc(pointer);
		//AddMessage('Action: '+action+ ' - Current element: "'+Signature(curElm)+':'+Name(curElm)+'"');
		if action = 'addnode' then begin 
			sStr1 := curScript[pointer];
			Inc(pointer);
			lastFoundElm := Add(curElm, sStr1, true);	 // New entry added to end
			end
		else if action = 'addentry' then begin 
			lastFoundElm := ElementAssign(curElm, HighInteger, nil, false);	 // New entry added to end
			end
		else if action = 'findnode' then begin 
			sStr1 := curScript[pointer];
			Inc(pointer);
			lastFoundElm := ElementByPath(curElm, sStr1);
			end
		else if action = '(' then begin 
			stack.Add(TObject(curElm));
			curElm := lastFoundElm;
			end
		else if action = ')' then begin 
			curElm := ObjectToElement(stack[stack.Count-1]);
			stack.Delete(stack.Count-1);
			end
		else if action = 'setvalue' then begin
			sStr1 := curScript[pointer];
			Inc(pointer);
			SetEditValue(curElm, sStr1);
			end
		else if action = 'setreference' then begin
			sStr1 := curScript[pointer];
			Inc(pointer);
			sStr2 := curScript[pointer];
			Inc(pointer);
			RecordLib.setRecordReference(curElm,'',sStr1,sStr2);
			end
		else
			raise Exception.Create('Unknown action "'+action+'" in record script: '+script);
		
		end;
	
	// Cleanup
	curScript.Free;
	stack.Free;
end;

{Cleanup}
procedure cleanup();
begin
	
end;



end.