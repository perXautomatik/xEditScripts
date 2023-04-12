{
	M8r98a4f2s Complex Item Sorter for FallUI - Tasks handler
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Used for task handling.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}
unit Tasks;

var
	// Private
	_taskCPRs: TStringList;
	_taskCPRActives: TStringList;

{Initialize the unit}
procedure init();
begin

	// Setup
	cleanup();
	
	_taskCPRs := TStringList.Create;
	_taskCPRActives := TStringList.Create;
	registerTask('ItemSorterTags', 'Item sorter tags');
end;

{Adds a new task}
procedure registerTask(taskIdent, taskName: String);
begin
	AddMessage('Registered task "'+taskIdent+'": '+taskName);
	_taskCPRs.Values[taskIdent] := taskName;
	setTaskActive(taskIdent, True);
	//scDefaults.values['task.'+taskIdent+'.active'] := True;
end;

{Returns the (active) processing tasks}
function getProcessingTasks():TStringList;
begin
	Result := _taskCPRs;
end;

{Returns the (active) processing tasks}
function getProcessingActiveTasks():TStringList;
begin
	Result := _taskCPRActives;
end;

{Returns true if the task exists}
function taskExists(taskIdent:String):Boolean;
begin
	Result := _taskCPRs.indexOfName(taskIdent) <> -1;
end;

{Set the active property of a task}
procedure setTaskActive(taskIdent:String;active:Boolean);
var 
	index, i: Integer;
	lstPrevActives: TStringList;
begin
	
	if _taskCPRs.indexOfName(taskIdent) = -1 then
		Exit;
		
	index := _taskCPRActives.indexOfName(taskIdent);
	if (index <> -1 ) <> active then begin
		// Update
		if active then
			_taskCPRActives.Values[taskIdent] := _taskCPRs.Values[taskIdent]
		else
			_taskCPRActives.Delete(index);
		// Keep task order
		lstPrevActives := TStringList.Create;
		lstPrevActives.Assign(_taskCPRActives);
		_taskCPRActives.Clear;
		for i := 0 to _taskCPRs.Count-1 do 
			if lstPrevActives.indexOfName(_taskCPRs.Names[i]) <> -1 then 
				_taskCPRActives.append(_taskCPRs[i]);
			
		lstPrevActives.Free;
		end;
end;

{Updates the active task list}
procedure updateActiveTasks();
begin
	// No item sorter tags? :(
	Tasks.setTaskActive('ItemSorterTags',getSettingsBoolean('plugin.cpp_itemSorterTags.active'));
end;

{unit cleanup}
procedure cleanup();
var
	i,j: Integer;
begin
	FreeAndNil(_taskCPRs);
	FreeAndNil(_taskCPRActives);
end;



end.