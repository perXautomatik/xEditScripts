{
	M8r98a4f2s Complex Item Sorter for FallUI - PluginScript module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Handler for plugin scripts.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit CSPluginScript;

var
	// Constant
	_scriptAllowedMathOps: TStringList;

	// Global storage for all plugins
	_pluginScriptVarStorage: TStringList;
	_pluginScriptParsedParamsStorage: TStringList;

	// Runtime environment for scripts
	_scriptPluginId: String;
	_scriptPluginIdAndScript: String;
	_scriptFlagNoFinalTagIdent: Boolean;
	_scriptFlagDoExit: Boolean;
	_scriptShouldSaveRecord: Boolean;
	_scriptRuleApplyTag: String;
	_scriptCurrentSTagSoFar: String;
	_scriptVars: TStringList;
	_scriptSubBlockStack: TStringList;
	_scriptPerformedActions: TStringList;
	
	// Caching system (Warning var names have no namespace system tied to unit;
	_ps_cache_enabled,
	_ps_cache_flagScriptActionsCacheable: Boolean;
	_ps_cache_flagCurCacheValid: Boolean;
	
	_ps_cache_resultsCur,
	_ps_cache_resultsNew: TStringList;
	
	pPS_cacheInvalidationsPS: Integer;
	
	
{Initializes the plugin script system}
procedure init();
begin
	// Set allowed mathematical operations
	_scriptAllowedMathOps := TStringList.Create;
	_scriptAllowedMathOps.add('+');
	_scriptAllowedMathOps.add('-');
	_scriptAllowedMathOps.add('/');
	_scriptAllowedMathOps.add('*');
	
	_pluginScriptVarStorage := TStringList.Create;
	_pluginScriptParsedParamsStorage := TStringList.Create;
	// Init cache 
	_scriptPerformedActions := TStringList.Create;
end;


{Initializes the PS-Cache}
procedure reinitCache();
var 
	i, j:Integer;
	curValidationStr, pluginId, pluginScriptName:String;
	cacheSubBlockCur, cacheSubBlockNew: TStringList;
	sectionCacheCur, sectionCacheNew,pluginScripts: TStringList;
begin
	_ps_cache_enabled    := getSettingsBoolean('config.bUseCachePluginScript');
	if not _ps_cache_enabled then
		Exit;

	// Init cache
	if not Cache.existsCache('pluginScriptsResult') then begin
		Cache.initBulkStorage('pluginScriptsResult');

		// Explode result cache for faster access
		Cache.initLevelTwoCache('pluginScriptsResult');
		end;
	
	// Direct access
	_ps_cache_resultsCur := Cache.getDirectAccessCachedEntriesList('pluginScriptsResult');

	// Add entry for every possibility and validate
	for i := 0 to pluginRegistry.Count - 1 do begin
		pluginId := pluginRegistry[i];
		pluginScripts := CSPluginSystem.getPluginScripts(pluginId);
		if Assigned(pluginScripts) then
			for j := 0 to pluginScripts.Count - 1 do
				if Cache.getEntrySetLevelTwo('pluginScriptsResult', pluginId+':'+pluginScripts[j], true, sectionCacheCur, sectionCacheNew) then
					// Validate section cache
					_cacheValidateBlock(pluginId+':'+pluginScripts[j],sectionCacheCur, sectionCacheNew);
		end;
	
	// Setup and validate Cache 
	{for i := 0 to _ps_cache_resultsCur.Count - 1 do
		if Cache.getEntrySetLevelTwo('pluginScriptsResult',_ps_cache_resultsCur.Names[i], true, sectionCacheCur, sectionCacheNew) then
			// Validate section cache
			_cacheValidateBlock(_ps_cache_resultsCur.Names[i],sectionCacheCur, sectionCacheNew);
	}		
end;

{Validates the cache}
procedure _cacheValidateBlock(pluginIdAndScript: String; var sectionCacheCur:THashedStringList; sectionCacheNew:TStringList );
var 
	pluginId, pluginScriptName, curValidationStr: String;
	tmpLst: TStringList;
begin
	tmpLst := Split(':', pluginIdAndScript);
	pluginId := tmpLst[0];
	pluginScriptName := tmpLst[1];
	tmpLst.Free;
	curValidationStr := '';//_getCacheValidationString(pluginId, pluginScriptName);
	CSPluginSystem.addPluginCacheValidationStr(pluginId, pluginScriptName, curValidationStr);

	if (curValidationStr <> '' ) and (sectionCacheCur.Values['VAL_STR_PLG'] = curValidationStr) then 
		Exit;

	AddMessage('(Re-)new script cache for: '+pluginIdAndScript);
	sectionCacheCur.Clear();
	sectionCacheNew.Clear();
	sectionCacheCur.Values['VAL_STR_PLG'] := curValidationStr;
	sectionCacheNew.Values['VAL_STR_PLG'] := curValidationStr;
end;

function _getCacheValidationStringForCurrentRecord(pluginId, pluginScriptName:String):String;
var 
	curValidationStr:String;
begin
	curValidationStr := pDR_cacheValidationStr;
	if curValidationStr <> '' then 
		if CSPluginSystem.addPluginCacheValidationStr(pluginId, pluginScriptName, curValidationStr) then 
			Result := curValidationStr;
end;

procedure _cache_clearSubBlock(cacheSubBlockCur, cacheSubBlockNew: TStringList; curValidationStr:String);
begin
	cacheSubBlockCur.Clear();
	cacheSubBlockNew.Clear();
	cacheSubBlockCur.Values['VAL_STR_PLG'] := curValidationStr;
	cacheSubBlockNew.Values['VAL_STR_PLG'] := curValidationStr;
end;

{Execute a plugin script}
function applyScriptLines(pluginScript:TStringList;const pluginId:String;const pluginIdAndScript:String;
	var saveRecord:Boolean; var ruleApplyTag:String;sTag:String;var madeModifications:Boolean):Boolean;
var
	i, varStorageIndex, parsedParamsStorageIndex, cacheIndex: Integer;
	parsedParamsList: TStringList;
begin
	_scriptPluginIdAndScript := pluginIdAndScript;
	// Cache?
	if _ps_cache_enabled then begin
		cacheIndex := _ps_cache_resultsCur.indexOfName(pluginIdAndScript);
		if cacheIndex > -1 then begin
			Result := _useScriptCache(cacheIndex,pluginIdAndScript, saveRecord, madeModifications, ruleApplyTag);
			if _ps_cache_flagCurCacheValid then
				Exit;
			end;
		end;
		
	// Setup environment
	madeModifications := false; // Have done nothing yet
	_scriptPluginId := pluginId;
	_scriptShouldSaveRecord := false;
	_scriptRuleApplyTag := ruleApplyTag;
	_scriptCurrentSTagSoFar := sTag;
	_scriptSubBlockStack := nil;
	_scriptFlagDoExit := false;
	_ps_cache_flagScriptActionsCacheable := true;
	_scriptPerformedActions.Clear();
	
	// Quick save value pDR_fullName is not compatible with scripts. Save bevore and reset
	if pDR_fullName <> '' then
		DynamicPatcher.flushCacheFullName;

	// Get var storage
	varStorageIndex := _pluginScriptVarStorage.indexOf(pluginId);
	if varStorageIndex = -1 then
		_scriptVars := _initScriptVars(pluginId)
	else
		_scriptVars := _pluginScriptVarStorage.Objects[varStorageIndex];

	// Get preparsed script lines
	parsedParamsStorageIndex := _pluginScriptParsedParamsStorage.indexOf(pluginIdAndScript);
	if parsedParamsStorageIndex = -1 then
		parsedParamsList := _initPreparsedScriptLines(pluginScript,pluginIdAndScript)
	else
		parsedParamsList := _pluginScriptParsedParamsStorage.Objects[parsedParamsStorageIndex];
		
	// Result = true for continue processing chain, false will apply ruleApplyTag to item
	_scriptFlagNoFinalTagIdent := true;
	
	// Execute script
	for i := 0 to parsedParamsList.Count -1 do
		if not _scriptFlagDoExit then
			_scriptExecuteLine(parsedParamsList[i],parsedParamsList.Objects[i]);

	// Take results
	if _scriptShouldSaveRecord then begin
		saveRecord := _scriptShouldSaveRecord;
		madeModifications := true;
		end;
	ruleApplyTag := _scriptRuleApplyTag;
	Result := _scriptFlagNoFinalTagIdent;
	
	// Cache
	if _ps_cache_enabled and _ps_cache_flagScriptActionsCacheable then
		_cache_writeScriptResults(pluginId, pluginScript, pluginIdAndScript);
	
	// Little cleanup
	if Assigned(_scriptSubBlockStack) then
		FreeAndNil(_scriptSubBlockStack);
end;

{Initializes plugin script var storage}
function _initScriptVars(const pluginId:String):TStringList;
var
	i:Integer;
	plugin, userSettings: TStringList;
begin
	Result := TStringList.Create;
	userSettings := getPluginObj(pluginId).Objects[PLUGIN_INDEX_OBJ_USERSETTINGS];
	for i := 0 to userSettings.Count - 1 do
		if userSettings.Objects[i].values['basetype'] = 'setting' then
			Result.values['$'+userSettings[i]] := getPluginUserSetting(pluginId,userSettings[i]);
	_pluginScriptVarStorage.addObject(pluginId, Result );
end;

{Initializes plugin preparsed script lines}
function _initPreparsedScriptLines(const pluginScript:TStringList;const pluginIdAndScript:String):TStringList;
var
	i,j,blockStack:Integer;
	plugin, userSettings, parsedParams, subScriptRaw, subScriptParsed: TStringList;
	lineNr, subBlockIdent: String;
begin
	Result := TStringList.Create;
	j := -1;
	for i := 0 to pluginScript.Count - 1 do begin
		// Skip sub blocks
		if i <= j then
			continue;
		parsedParams := parseParameters(pluginScript.ValueFromIndex[i], false);
		parsedParams.Delimiter := ' ';
		lineNr := pluginScript.Names[i];
		Result.addObject(lineNr,parsedParams);
		if parsedParams[0] = 'foreach' then begin
			blockStack := 0;
			subScriptRaw := TStringList.Create;
			for j := i+1 to pluginScript.Count - 1 do begin
				if (Pos('endforeach',pluginScript.ValueFromIndex[j]) = 1 ) then
					if blockStack > 0 then
						Dec(blockStack)
					else begin
						// Found my end - Parse and store!
						_initPreparsedScriptLines(subScriptRaw, pluginIdAndScript+'>'+lineNr+'-foreach');
						// Forward script pointer
						// i := j; // Pascal doesn't like it that way .. okay ...
						break;
						end;
				if (Pos('foreach',pluginScript.ValueFromIndex[j]) = 1 ) then
					Inc(blockStack);
				// Add line to subscript
				subScriptRaw.add(pluginScript[j])
				end;
			subScriptRaw.Free;
			end;
		end;
	_pluginScriptParsedParamsStorage.addObject(pluginIdAndScript, Result);
	// AddMessage('Resulting script "'+pluginIdAndScript+'": '+Result.CommaText);
end;

{Executes one line}
procedure _scriptExecuteLine(lineNr:String;params:TStringList);
var
	command: String;
begin	
	// AddMessage('Run script line: '+params.DelimitedText + '    _scriptVars: '+_scriptVars.DelimitedText+'   params.CNT: '+IntToStr(params.Count));
	command := params[0];
	if command = 'set' then
		_scriptCommandSet(params)
	else if command = 'if' then
		_scriptCommandIf(params)
	else if command = 'assign' then
		_scriptCommandAssign(params)
	else if command = 'foreach' then
		_scriptCommandForeach(lineNr,params)
	else if command = 'modset' then
		_scriptCommandModSet(params)
	else if command = 'addmessage' then
		_scriptCommandAddMessage(lineNr,params)
	else if command = 'end' then
		_scriptFlagDoExit := true
	else
		AddMessage('Warning plugin "'+_scriptPluginId+'": Unknown script command in line: '+params.DelimitedText);
end;

{Executes the 'if' command}
procedure _scriptCommandIf(params:TStringList);
var
	targetVar, compOp, thenCode, sValA, sValB: String;
	fValA, fValB: Real;
	compResult: Boolean;
	paramsSub: TStringList;
begin
	
	if (params.Count = 6) and (params[4] = 'then' ) then begin
		sValA := _scriptGetValue(params[1]);
		sValB := _scriptGetValue(params[3]);
		compOp := params[2];
		
		// Str compare? 
		if compOp = 'eq' then
			compResult := sValA = sValB
		else if compOp = 'neq' then
			compResult := sValA <> sValB
		else begin 
			// Mathematical comparisment
			
			if sValA <> '' then
				fValA := StrToFloat(sValA);
			if sValB <> '' then
				fValB := StrToFloat(sValB);

			
			if compOp = '>=' then
				compResult := fValA >= fValB
			else if compOp = '<=' then
				compResult := fValA <= fValB
			else if compOp = '>' then
				compResult := fValA > fValB
			else if compOp = '<' then
				compResult := fValA < fValB
			else if compOp = '=' then
				compResult := fValA = fValB
			else if compOp = '<>' then
				compResult := fValA <> fValB
			else
				raise Exception.Create('Dont know how to handle compare operator: '+compOp );
			end;
		// Result true?
		if compResult then begin
			paramsSub := parseParameters(getStringWithoutQuotes(params[5]), false);
			_scriptExecuteLine('nA',paramsSub);
			paramsSub.Free;
			end;
		Exit;
		end;
	raise Exception.Create('Dont know how to handle command line: '+params.DelimitedText);
end;
	
{Executes the 'set' command}
procedure _scriptCommandAssign(params:TStringList);
var
	targetVar, mathOp, recordFieldPath, sValA, sValB: String;
	fValA, fValB, valResult: Real;
begin
	if params.Count <> 4 then
		raise Exception.Create('Invalid command line for assign - must have four params and "=": '+params.DelimitedText);
	if params[2] <> '=' then
		raise Exception.Create('Invalid command line for assign - third param must be "=": '+params.DelimitedText);
	// All ok - let the fun start
	targetVar := params[1];
	// Simple assignment
	if params.Count = 4 then begin
		if Pos('@',targetVar) = 1 then
			_scriptAssignRef(targetVar, _scriptGetRefValue(params[3]))
		else
			raise Exception.Create('Invalid assign usage: '+params.DelimitedText);
		Exit;
		end;
end;


{Executes the 'set' command}
procedure _scriptCommandSet(params:TStringList);
var
	targetVar, mathOp, recordFieldPath, sValA, sValB: String;
	fValA, fValB, valResult: Real;
begin
	if params.Count < 4 then
		raise Exception.Create('Invalid command line for set - must have min four params and "=": '+params.DelimitedText);
	if params[2] <> '=' then
		raise Exception.Create('Invalid command line for set - third param must be "=": '+params.DelimitedText);
	// All ok - let the fun start
	targetVar := params[1];
	// Simple assignment
	if params.Count = 4 then begin
		{if Pos('@',params[3]) = 1 then
			_scriptSetRefValue(targetVar, _scriptGetRefValue(params[3]))
		else}
			_scriptSetValue(targetVar, _scriptGetValue(params[3]));
		Exit;
		end;
	// Simple calculation
	if params.Count = 6 then
		if _scriptAllowedMathOps.indexOf(params[4]) > -1 then begin
			mathOp := params[4];
			sValA := _scriptGetValue(params[3]);
			sValB := _scriptGetValue(params[5]);
			if sValA <> '' then
				fValA := StrToFloat(sValA);
			if sValB <> '' then
				fValB := StrToFloat(sValB);
			
			if mathOp = '+' then
				valResult := fValA + fValB
			else if mathOp = '-' then
				valResult := fValA - fValB
			else if mathOp = '/' then
				if fValB <> 0 then
					valResult := fValA / fValB
				else
					valResult := 0
			else if mathOp = '*' then
				valResult := fValA * fValB
			else
				raise Exception.Create('Invalid command line: '+params.DelimitedText);
			// Save result
			_scriptSetValue(targetVar, FloatToStr(valResult));
			Exit;
			end
		else if params[4] = '.' then begin
			_scriptSetValue(targetVar, _scriptGetValue(params[3])+_scriptGetValue(params[5]));
			Exit;
			end;
	raise Exception.Create('Dont know how to handle command line: '+params.DelimitedText);
end;


{Executes the 'modset' command, which allows to use complexer modification functions}
procedure _scriptCommandModSet(params:TStringList);
var
	targetVar, modFunc, sStr: String;
	fValA, fValB, valResult: Real;
begin
	if params.Count < 4 then
		raise Exception.Create('Invalid command line for modset - must have min four params and "=": '+params.DelimitedText);
	if params[2] <> '=' then
		raise Exception.Create('Invalid command line for modset - third param must be "=": '+params.DelimitedText);
	// All ok - let the fun start
	targetVar := params[1];
	modFunc := params[3];
	
	// Modificator: PregReplace
	if (modFunc = 'PregReplace') and (params.Count = 7 ) then begin 
		// Get stat value 
		sStr := _scriptGetValue(params[4]);
		// Modificate
		sStr := PregReplace(getStringWithoutQuotes(params[5]),getStringWithoutQuotes(params[6]),sStr);
		// Set value 
		_scriptSetValue(targetVar, sStr);
		Exit;
		End;
	
	raise Exception.Create('Dont know how to handle command line: '+params.DelimitedText);
end;

{Executes the addmessage command}
procedure _scriptCommandAddMessage(lineNr:String;params:TStringList);
begin
	if params.Count <> 2 then
		raise Exception.Create('Invalid command line for addMessage - must have min 2 params: '+params.DelimitedText);
	
	AddMessage('(PluginScript: '+_scriptPluginIdAndScript+' Line '+lineNr+') ' + _scriptGetValue(params[1]));
end;

{Executes the 'foreach' command}
procedure _scriptCommandForeach(lineNr:String;params:TStringList);
var
	i,j, elmCount, parsedParamsStorageIndex: Integer;
	parent, child: IInterface;
	subScriptParsedParamsList, flagsLst: TStringList;
	parentExpr, targetVarChild, targetVarIndex: String;
	flagIsFlags: Boolean;
begin
	if ( (params.Count <>4 ) and (params.Count <> 6 ) ) or (params[2] <> 'as' ) or ((params.Count = 6) and (params[4] <> '=>')) then
		raise Exception.Create('Invalid form for foreach. Must be: foreach @parent as @child. :'+params.DelimitedText);
	
	// Search the parent element
	parentExpr := params[1];
	if Pos('flags:', parentExpr) = 1 then 
		if BeginsWithExtract('flags:', parentExpr, parentExpr) then
			flagIsFlags := true;
			
	parent := _scriptGetRefValue(parentExpr);
	elmCount := ElementCount(parent);
	
	if elmCount = 0 then 
		Exit;
	// Read flags 
	if flagIsFlags then begin
		flagsLst := TStringList.Create;
		//flagsLst.CommaText := FlagValues(parent);
		flagsLst.CommaText := getSettedFlagsAsString(parent);
		end;
		
	
	// Add to exec stack
	if not Assigned(_scriptSubBlockStack) then begin
		_scriptSubBlockStack := TStringList.Create;
		_scriptSubBlockStack.Delimiter := '>';
		_scriptSubBlockStack.add(_scriptPluginIdAndScript);
		end;

	// Get the script part for repeat
	_scriptSubBlockStack.add(lineNr+'-foreach');
	parsedParamsStorageIndex := _pluginScriptParsedParamsStorage.indexOf(_scriptSubBlockStack.DelimitedText);
	subScriptParsedParamsList := _pluginScriptParsedParamsStorage.Objects[parsedParamsStorageIndex];
	
	if params.Count = 4 then
		targetVarChild := params[3]
	else begin
		targetVarIndex := params[3];
		targetVarChild := params[5];
		end;

	// Executes the foreach ( seperate blocks for different types for more speedup
	if not flagIsFlags then 
		for i := 0 to elmCount - 1 do
			if not _scriptFlagDoExit then begin
				child := ElementByIndex(parent, i);
				if targetVarIndex <> '' then
					_scriptSetValue(targetVarIndex, IntToStr(i));
				_scriptAssignRef(targetVarChild, child);
				// Execute sub script
				for j := 0 to subScriptParsedParamsList.Count - 1 do
					_scriptExecuteLine(subScriptParsedParamsList[j],subScriptParsedParamsList.Objects[j]);
				end;

	// For flags 
	if flagIsFlags then 
		for i := 0 to elmCount - 1 do
			if not _scriptFlagDoExit then begin
				if targetVarIndex <> '' then
					_scriptSetValue(targetVarIndex, IntToStr(i));
				_scriptSetValue(targetVarChild, flagsLst[i]);
				// Execute sub script
				for j := 0 to subScriptParsedParamsList.Count - 1 do
					_scriptExecuteLine(subScriptParsedParamsList[j],subScriptParsedParamsList.Objects[j]);
				end;
				
				
	// Remove from exec stack
	_scriptSubBlockStack.delete(_scriptSubBlockStack.Count - 1);
	// Cleanup
	if flagIsFlags then
		flagsLst.Free;
end;


{Fetches a value for a script expression}
function _scriptGetValue(const expression:String):String;
var
	recordFieldPath, expr2: String;
begin
	// Local script var
	if Pos('$',expression) = 1 then begin
		Result := _scriptVars.values[expression];
		Exit;
		end
	else if expression = 'TagIdent' then
		Result := _scriptCurrentSTagSoFar
	// record entry or fixed expression
	else if Pos('count:',expression) <> 0 then begin 
		BeginsWithExtract('count:',expression,expr2);
		Result := ElementCount(_scriptGetRefValue(expr2));
		end
	else begin
		// Standard "string"
		if Pos('"',expression) = 1 then 
			if Pos('"',Copy(expression,2,1000)) = Length(expression) - 1 then begin
				Result := Copy(expression,2,Length(expression)-2);
				Exit;
				end;
		// Numbers?
		if expression = '0' then
			Result := expression
		else if IsNumber(expression) then
			Result := expression
		else // Any other value
			Result := GetEditValue(_scriptGetRefValue(expression));
		end;
		
	//raise Exception.Create('Can''t evaluate expression "'+expression+'"');
end;


{Sets a value for a targetVar}
procedure _scriptSetValue(const targetVar:String; const value:String);
var
	recordFieldPath: String;
	recRef: IInterface;
begin
	// Local script var
	if Pos('$',targetVar) = 1 then
		_scriptVars.values[targetVar] := value
	// Tagident?
	else if targetVar = 'TagIdent' then
		_scriptRegisterAndExecuteModification('setTagIdent', nil, value,'')
	else begin // Only records left
		recRef := _scriptGetRefValue(targetVar);
		if Assigned(recRef) then
			_scriptRegisterAndExecuteModification('setRecordValue',recRef, value,targetVar)
		else
			raise Exception.Create('target for var "'+targetVar+'" doesn''t exist.');
		end;
end;


{Sets a reference value for a script expression}
procedure _scriptAssignRef(const targetVar:String; recRef:IInterface);
begin
	// Local script var
	if Pos('@',targetVar) = 1 then begin
		_scriptVars.values[targetVar] := '@';
		_scriptVars.Objects[_scriptVars.indexOfName(targetVar)] := TObject(recRef);
		Exit;
		end
	else
		raise Exception.Create('Invalid set @var usage for '+targetVar);
end;


{Gets a reference value for a script expression}
function _scriptGetRefValue(const expression:String):IInterface;
var
	index: Integer;
	varName, recordFieldPath, expr2:String;
begin
	// Local script var
	if Pos('record.',expression) = 1 then begin 
		BeginsWithExtract('record.',expression,recordFieldPath);
		Result := ElementByPath(pDR_record, getStringWithoutQuotes(recordFieldPath));
		end
	else if Pos('@',expression) = 1 then begin
		// Handle sub path calls
		SplitSimple('.',expression,varName,recordFieldPath);
		index := _scriptVars.indexOfName(varName);
		if index = -1 then
			raise Exception.Create('Usage of unassigned reference "'+varName+'"');
		Result := ObjectToElement(_scriptVars.Objects[index]);
		if recordFieldPath <> '' then
			Result := ElementByPath(Result, getStringWithoutQuotes(recordFieldPath));
		Exit;
		end
	else if BeginsWithExtract('linksto:',expression,expr2) then
		Result := LinksTo(_scriptGetRefValue(expr2))
	else
		raise Exception.Create('Invalid get @var usage: '+expression);
end;


{Returns the string without surrounding quotes, if it has any. Returns original if not. - Better: AnsiExtractQuotedStr - NOT BETTER!}
function getStringWithoutQuotes(const str:String):String;
begin
	if (Pos('"',str) = 1) and (Copy(str,length(str),1) = '"' ) then
		Result := StringReplace(Copy(str,2,Length(str)-2),'""','"',[rfReplaceAll])
	else
		Result := str;
end;


{Returns a quoted string.}
function getQuoted(const str:String):String;
begin
	Result := '"'+StringReplace(str,'"','""',[rfReplaceAll])+'"';
end;


{Registers and execute a modification by plugin script}
procedure _scriptRegisterAndExecuteModification(modActionIdent:String;recRef:IInterface; value:String;targetVar:String);
var
	sTmp, storedActionPackStr: String;
	tmpLst: TStringList;
begin
	tmpLst := nil;
	// Mod action: setTagIdent
	if modActionIdent = 'setTagIdent' then begin
		// setTagIdent action is also cachable by rules result cache - no makeModifications flag!
		tmpLst := TStringList.Create;
		tmpLst.add(modActionIdent);
		tmpLst.add(value);
		end;
		
	// Mod action: Set record value
	if modActionIdent = 'setRecordValue' then begin
		// Is targetVar cachable?
		//AddMessage('test: '+targetVar);
		if not BeginsWithExtract('record.', targetVar, sTmp) then begin
			// uncachable yet
			_ps_cache_flagScriptActionsCacheable := false;
			SetEditValue(recRef, value);
			_scriptShouldSaveRecord := true;
			end
			
		else begin
			//AddMessage('seems good: '+getStringWithoutQuotes(sTmp));
			tmpLst := TStringList.Create;
			tmpLst.add(modActionIdent);
			tmpLst.add(targetVar);
			tmpLst.add(value);
			end;
		end;
		
	if Assigned(tmpLst) then begin
		//AddMessage('Mod stored: '+modActionIdent+' - '+tmpLst.CommaText);
		_scriptExecuteModification(tmpLst, recRef);
		_scriptPerformedActions.add(tmpLst.CommaText);
		tmpLst.Free;
		end;
end;

{Execute a packed modification}
procedure _scriptExecuteModification(modPack:TStringList; recRef:IInterface);
var 
	modActionIdent, targetVar, value:String;
begin
	modActionIdent := modPack[0];
	// Action: setTagIdent
	if modActionIdent = 'setTagIdent' then begin
		_scriptRuleApplyTag := modPack[1];
		_scriptFlagNoFinalTagIdent := false;
		_scriptShouldSaveRecord := true;
		Exit;
		end;
		
	// Action: 
	if modActionIdent = 'setRecordValue' then begin
		targetVar := modPack[1];
		value := modPack[2];
		if not Assigned(recRef) then
			recRef := _scriptGetRefValue(targetVar);
		// Execute
		SetEditValue(recRef, value);
		_scriptShouldSaveRecord := true;
		Exit;
		end;
		
	raise Exception.create('Can''t handle modPack for action '+modActionIdent);
end;


{Write result of one script execution}
procedure _cache_writeScriptResults(const pluginId, pluginScript, pluginIdAndScript: String);
var 
	cacheIndex: Integer;
	resultPack, cacheSubBlockCur, cacheSubBlockNew: TStringList;
	sectionCacheCur, sectionCacheNew: TStringList;
	curValidationStr, newCacheEntry: String;
begin
	resultPack := TStringList.Create;

	// Slot 0: Validation String
	resultPack.add(pDR_cacheValidationStr+','+languageFO4EditParam);
	
	
	// Slot 1: _scriptShouldSaveRecord
	resultPack.add(_scriptShouldSaveRecord); // Boolerized
		
	// Slot 2: _scriptFlagNoFinalTagIdent
	resultPack.add(_scriptFlagNoFinalTagIdent); // Boolerized
		
	// Slot 3: Actions
	resultPack.add(_scriptPerformedActions.CommaText); // Real string
			
	//Cache.setEntryLevelTwo('pluginScriptsResult',xx, pDR_cacheLoadOrderFormId, resultPack.CommaText,cacheSubBlockCur, cacheSubBlockNew);
	
	setEntryLevelTwo('pluginScriptsResult', pluginIdAndScript, pDR_cacheLoadOrderFormId, resultPack.CommaText, sectionCacheCur, sectionCacheNew);

	Inc(pPS_cacheInvalidationsPS);
	resultPack.Free;
end;

function _useScriptCache(const cacheIndex:Integer; const pluginIdAndScript:String;var saveRecord:Boolean; var madeModifications:Boolean; ruleApplyTag: String;):Boolean;
var 
	i, subCacheIndex: Integer;
	resultPack, modActions, modAction: TStringList;
	cacheEntry: String;
begin
	_ps_cache_flagCurCacheValid := false;

	cacheEntry := Cache.getEntryLevelTwo('pluginScriptsResult', pluginIdAndScript, pDR_cacheLoadOrderFormId);	
	//AddMessage('Cache for '+pluginIdAndScript+':'+pDR_cacheLoadOrderFormId+' = '+cacheEntry);
	if cacheEntry = '' then 
		Exit;
	// Unpack
	resultPack := TStringList.Create();
	resultPack.CommaText := cacheEntry;
	
	// Validation 
	if (pDR_cacheValidationStr <> '' ) and (resultPack[0] = (pDR_cacheValidationStr+','+languageFO4EditParam) ) then 
		_ps_cache_flagCurCacheValid := true
	else 
		Exit; // Invalid
		
	
	
	modActions := TStringList.Create;
	modAction := TStringList.Create;
	modActions.CommaText := resultPack[3];
	
	// Reapply actions
	for i := 0 to modActions.Count - 1 do begin
		modAction.CommaText := modActions[i];
		_scriptExecuteModification(modAction, nil);
		end;

	// Restore result
	_scriptShouldSaveRecord := resultPack[1] = 'True';
	_scriptFlagNoFinalTagIdent := resultPack[2] = 'True';
	if _scriptShouldSaveRecord then begin
		saveRecord := _scriptShouldSaveRecord;
		madeModifications := true;
		end;
	ruleApplyTag := _scriptRuleApplyTag;
	Result := _scriptFlagNoFinalTagIdent;

	// Cleanup
	modActions.Free;
	modAction.Free;
	resultPack.Free;
end;


{Cleanup}
procedure cleanup();
var
	i:Integer;
begin
	// Save cache
	if Cache.existsCache('pluginScriptsResult') then
		Cache.save('pluginScriptsResult', true);

	if Assigned(_pluginScriptVarStorage) then
		for i := 0 to _pluginScriptVarStorage.Count - 1 do
			_pluginScriptVarStorage.Objects[i].Free;
	FreeAndNil(_pluginScriptVarStorage);
	if Assigned(_pluginScriptParsedParamsStorage) then
		for i := 0 to _pluginScriptParsedParamsStorage.Count - 1 do
			_pluginScriptParsedParamsStorage.Objects[i].Free;
	FreeAndNil(_pluginScriptParsedParamsStorage);
	FreeAndNil(_scriptAllowedMathOps);
	FreeAndNil(_scriptPerformedActions);
end;

end.
