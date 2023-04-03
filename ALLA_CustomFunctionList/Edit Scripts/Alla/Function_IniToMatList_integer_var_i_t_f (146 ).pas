
function IniToMatList: integer;
var
	i, t, f, as, MLI: integer;
	cs, cg, cf, ce, ca: string;
	MaterialsSublist, TempList: TStringList;
	item: IInterface;
	debugMsg: boolean;
begin
	debugMsg := false;

	for MLI := MaterialList.Count - 1 downto 0 do
	begin
		{debug} if debugmsg then msg('initomatlist (0), keyword: ' + materiallist[mli]);
		TempList := TStringList.Create;
		MaterialsSublist := TStringList.Create;
		TempList.DelimitedText := Ini.ReadString('Crafting', MaterialList.strings[MLI], '');
		for i := TempList.count - 1 downto 0 do
		begin
			cs := TempList.Strings[i];
			{debug} if debugmsg then msg('initomatlist (1): ' + cs);
			t := pos(':', cs);
			f := pos('|', cs);
			as := pos('=', cs);
			if copy(cs, 0, 1) = 'i' then
			begin
				cg := UpperCase(Copy(cs, 2, 4));
				cf := copy(cs, t+1, f-t-1);
				ce := copy(cs, f+1, as-f-1);
				ca := copy(cs, as+1, length(cs) - as);
				item := MainRecordByEditorID(GroupBySignature(FileByName(cf), cg), ce);
				{Debug} if debugMsg then msg('IniToMatList (2): ' + cg + ' ' + cf + ' ' + ce + ' ' + ca);
				MaterialsSublist.AddObject(floattostr(ca), item);
				{Debug} //if debugMsg then msg('IniToMatList (3): ' + FloatToStr(ca) + ' ' + EditorID(item) + ' ' + EditorID(ObjectToElement(MaterialsSublist.Objects[MaterialsSublist.IndexOf(ca)])));
			end else if pos('p', copy(cs, 0, 1)) = 0 then
			begin
				cf := copy(cs, t+1,f-1);
				ce := copy(cs,f+1,length(cs) - 1);
				//MaterialsSublist.AddObject('Perk', MainRecordByEditorID(GroupBySignature(FileByName(cf), 'PERK'), ce));
				MaterialsSublist.AddObject('Perk', RecordByEDID(FileByName(cf), ce));
				{Debug} if debugMsg then msg('IniToMatList (4): ' + EditorID(item) + ' ' + EditorID(ObjectToElement(MaterialsSublist.Objects[MaterialsSublist.IndexOf(ca)])));
			end;
		end;
		MaterialList.objects[MLI] := MaterialsSublist;
		//MaterialList.Objects[MLI] := TempList;
	end;
end;