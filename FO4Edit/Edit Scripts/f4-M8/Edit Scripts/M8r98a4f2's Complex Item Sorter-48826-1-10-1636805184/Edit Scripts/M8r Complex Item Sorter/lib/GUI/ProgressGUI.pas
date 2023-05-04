{
	M8r98a4f2s Complex Item Sorter for FallUI - RuleEditorGUI module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. Part of the GUI.
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit ProgressGUI;


const
	windowPadding = 25;
	SELECTION_COLOR = $FF6666;

var
	// Private
	_pgFrm: TForm;
	
	_pgCurStepIndex,
	_pgCurStepFromPercent,
	_pgCurStepToPercent: Integer;
	
	_pgCloseButton,
	_pgCloseOnFinishedCheckbox: TCheckBox;
		
	_pgPanLabs1,
	_pgPanLabs2,
	_pgStepsLst,
	_pgStepsLstLabs,
	_pgStatsEntries,
	_pgStepsProgPercentLst: TStringList;
	
	_pgStepsPanel,
	_pgStatsPanel: TPanel;

	
	
implementation

{Init the progress GUI}
procedure init();
begin
	cleanup();
	_pgStatsEntries := TStringList.Create;
	_pgStepsLst := TStringList.Create;
	_pgStepsProgPercentLst := TStringList.Create;
	
end;

{Draw the progress GUI}
procedure draw();
var
	i: Integer;
	tlab: TLabel;
begin
	// Setup
	_pgFrm := TForm.Create(nil);
	_pgFrm.Width := 606;
	_pgFrm.Height := 300;
	_pgFrm.BorderStyle := bsDialog;
	_pgFrm.Position := poScreenCenter;
	_pgFrm.Caption := 'Processing';
	
	//_pgFrm.OnKeyPress := _eventKeyPress;
	
	efStartSub(_pgFrm,_pgFrm);
	_pgPanLabs1 := _drawProgressPanel(40);
	efTopAdd(40+10);
	_pgPanLabs2 := _drawProgressPanel(30);
	efTopAdd(-10);
	
	setProgressPercent(0);
	
	// Progress list
	_drawStepsPanel();
	
	// Stats group
	_drawStatsPanel();

	// Abort button
	_pgCloseButton := TButton.Create(_pgFrm);
	_pgCloseButton.Height := 40;
	_pgCloseButton.Width := 150;
	_pgCloseButton.TabOrder := 1;
	_pgCloseButton.Left := (_pgFrm.Width - _pgCloseButton.Width)/2;
	_pgCloseButton.modalResult := nil;
	_pgCloseButton.OnClick := _eventAbortProcess;
	_pgCloseButton.Caption := 'Abort processing';
	_pgCloseButton.Parent := _pgFrm;
	
	// Keep open checkbox
	_pgCloseOnFinishedCheckbox := ConstructCheckbox(_pgFrm, _pgFrm, {_pgFrm.Height - windowPadding*2-60}0, windowPadding, 200, 'Close window when finished', false, '');
	_pgCloseOnFinishedCheckbox.Checked := getSettingsBoolean('config.bProgressCloseOnFinished');
	_pgCloseOnFinishedCheckbox.TabStop := false;
	_pgCloseOnFinishedCheckbox.OnClick := _eventToggleCloseOnFinished;

	// Result.Checked := checked;
	updateForm();
	_pgFrm.Show();
	
	efEndSub();
end;

procedure updateForm;
begin
	_drawStepsPanel();
	_pgStatsPanel.Height := Max(_pgStepsPanel.Height,_pgStatsPanel.Height);
	_pgFrm.Height := _pgStepsPanel.Top + Max(_pgStepsPanel.Height,_pgStatsPanel.Height) + 120;
	_pgCloseButton.Top := _pgFrm.Height - windowPadding*2 - _pgCloseButton.Height;
	_pgCloseOnFinishedCheckbox.Top := _pgFrm.Height - windowPadding*2 - _pgCloseButton.Height - 20;
	_pgFrm.Position := poScreenCenter;

end;

{Add a progress step}
procedure addStep(stepIdent, stepName:String;stepProgress:Integer);
begin
	// AddMessage('Add step '+stepIdent+' - prgprc: '+IntToStr(stepProgress));
	_pgStepsLst.values[stepIdent] := stepName;
	_pgStepsProgPercentLst.values[stepIdent] := IntToStr(stepProgress);
end;


{Sets the current progress step}
procedure setCurrentStep(stepIdent: String);
var i, prevHeight:Integer;
	tlab: TButton;
begin
	if not Assigned(_pgStepsLst) or not Assigned(_pgStepsLstLabs) then
		Exit;
	_pgCurStepIndex := _pgStepsLst.indexOfName(stepIdent);
	if _pgCurStepIndex = -1 then begin
		AddMessage('Unknown progress step: '+stepIdent);
		Exit;
		end;
	
	_pgCurStepFromPercent := StrToInt(_pgStepsProgPercentLst.values[stepIdent]);
	if _pgStepsProgPercentLst.Count - 1 > _pgCurStepIndex then
		_pgCurStepToPercent := StrToInt(_pgStepsProgPercentLst.ValueFromIndex[_pgCurStepIndex+1])
	else
		_pgCurStepToPercent := 100;
		
	setProgressPercentCurrentStep(0);
	setProgressPercent(_pgCurStepFromPercent);
	for i := 0 to _pgStepsLst.Count -1 do begin
		tlab := _pgStepsLstLabs.Objects[i];
		prevHeight := tlab.Height;
		tlab.Font.Style := [];
		tlab.Font.Color := clBlack;
		tlab.Layout := tlCenter;
		tlab.Height := prevHeight;
		// efApplyLabelColor(tlab,clBlack);
		if _pgStepsLst.Names[i] = stepIdent then begin
			tlab.Font.Style := [fsBold];
			break;
			end;
		end;
	
end;


{Sets the shown progress percentage}
procedure setProgressPercent(percent: Integer);
begin
	_setProgressForPanLabsLst(_pgPanLabs1, percent,'');
end;

{Sets the shown progress percentage in one steps.}
procedure setProgressPercentCurrentStep(percent: Integer);
begin
	if not Assigned(_pgFrm) then 
		Exit;
	setProgressPercent(_pgCurStepFromPercent + (_pgCurStepToPercent-_pgCurStepFromPercent)*percent/100);
	_setProgressForPanLabsLst(_pgPanLabs2, percent,_pgStepsLst.ValueFromIndex[_pgCurStepIndex]+' ');
end;

procedure _setProgressForPanLabsLst(prgPanLabsLst:TStringList;percent:Integer;prefixText:String);
var
	i: Integer;
	var tlab: TLabel;
begin
	for i := 0 to prgPanLabsLst.Count - 2 do
		prgPanLabsLst.Objects[i].Transparent := not (percent > i*100/(prgPanLabsLst.Count-1));
	tlab := prgPanLabsLst.Objects[prgPanLabsLst.Count-1];
	tlab.Text := prefixText + IntToStr(percent)+'%';
	efApplyLabelColor(tlab,clGray);
	tlab.Left := tlab.Parent.Width / 2 - tlab.Width/2;
	tlab.Height := 14;
	tlab.Alignment := taCenter;
end;


{Updates/Add a statistic}
procedure setStatistic(statName:String;statValue:String);
var tName, tStat: TLAbel;
begin
	if not Assigned(_pgStatsEntries) then
		Exit;
	if statValue = '0' then
		statValue := '-';
	if _pgStatsEntries.indexOfName(statName) = -1 then begin
		efStartSub(_pgStatsPanel,_pgStatsPanel);
		tName := efLabel(statName,5,30+_pgStatsEntries.Count*20,0,16,efNone);
		efApplyLabelColor(tName, clGray);
		tStat := efLabel('',5,30+_pgStatsEntries.Count*20,0,16,efNone+efRight);
		efEndSub();
		_pgStatsEntries.addObject(statName+'=1',tStat);
		end;
	_pgStatsEntries.values[statName] := statValue;
	_pgStatsEntries.Objects[_pgStatsEntries.indexOfName(statName)].Text := statValue;
end;


{Marks the progress as finished. Shows the box if the user choosed to keep open}
procedure setFinished();
var
	tlab: TLabel;
begin
	if not Assigned(_pgFrm) or not Assigned(_pgCloseOnFinishedCheckbox) then
		Exit;
	try
		if not _pgCloseOnFinishedCheckbox.Checked then begin
			_pgCloseButton.Text := 'Close';
			_pgCloseButton.Left := (_pgFrm.Width - _pgCloseButton.Width)/2;
			_pgCloseButton.OnClick := nil;
			_pgCloseButton.modalResult := mrCancel;
			_pgCloseButton.Cancel := true;
			
			//_pgFrm.Hide();
			_pgFrm.Visible := false;
			// Sleep(500);
			_pgFrm.ShowModal();
			end;
		// _pgFrm.Visible := false;
		_pgFrm.hide();
		_pgFrm.Free;
		_pgFrm := nil;
		
		// Create new form to focus fo4edit...
		// Make it some effectful so user isn't get bored by the senseless dialog
		
		_pgFrm := TForm.create(nil);
		
		_pgFrm.BorderStyle := bsDialog;
		_pgFrm.Position := poScreenCenter;
		_pgFrm.Caption := 'Shutting down';
		_pgFrm.Width := 250;
		_pgFrm.Height := 100;
		
		efStartSub(_pgFrm,_pgFrm);
		{onCloseTimer := TTimer.Create(_pgFrm);onCloseTimer.Interval := 500;onCloseTimer.Enabled := true;onCloseTimer.OnTimer := eventOnTimer;}
		
		_pgFrm.Show();
		tlab := efLabel('Shutting down',0,_pgFrm.Height/2-25,0,0,efBold+efCenter);
		efEndSub();
		AddMessage('Shutting down');
		Sleep(200);
		Sleep(200);
		Sleep(200);
		Sleep(200);
		Sleep(200);
		
		
	finally
		_pgFrm.Free;
		_pgFrm := nil;
	end;
end;

{procedure eventOnTimer(  Sender: TObject);
begin
	AddMessage('TIMER');
	_pgFrm.hide();
	if Assigned(_pgFrm) then
		_pgFrm.Free;
	_pgFrm := nil;
	cleanup();
end;}

{Draws the statistics panel}
procedure _drawStatsPanel();
begin
	_pgStatsPanel := efPanel(windowPadding,windowPadding+50,0,0);
	_pgStatsPanel.Left := _pgStepsPanel.Left +_pgStepsPanel.Width + 20;
	_pgStatsPanel.Width := _pgFrm.Width - windowPadding*2 - _pgStatsPanel.Left + 8;
	efStartSub(_pgStatsPanel,_pgStatsPanel);
	efLeft := 5;
	efTop := 5;
	efLabel('Statistics',0,0,0,20,efTopAddHeight+efBold);
	efEndSub();
end;


{Draw the progress panel}
function _drawProgressPanel(height:Integer):TStringList;
var
	i, prgStepsCnt,prgStepsGap: Integer;
	tlab: TLabel;
	progressPanel: TPanel;
begin
	if not Assigned(progressPanel) then begin
		progressPanel := efPanel(windowPadding,windowPadding,0,height);
		end;
	efStartSub(progressPanel,progressPanel);
	
	Result := TStringList.Create;
	prgStepsCnt := Floor((progressPanel.Width-10-5-6) / 14);
	prgStepsGap := progressPanel.Width - prgStepsCnt * 14 - 10 - 5 - 6;
	progressPanel.Width := progressPanel.Width - prgStepsGap;
		
	// Progress bar "labels"
	for i := 0 to prgStepsCnt do begin		
		tlab := efLabel('',5+i*14 {+ (prgStepsGap/prgStepsCnt*i)},height*0.125,10,height*0.75,efNone);
		tlab.Color := $009900;
		tlab.Transparent := true;
		Result.addObject('obj', tlab);
		end;
	// Additional text lab
	tlab := efLabel('TEST',progressPanel.Width/2-10,(height-14)/2,10,14,efNone);
	tlab.Transparent := false;
	if getSettingsBoolean('config.bUseDarkTheme') then 
		tlab.color := $333333
	else 
		tlab.color := clBtnFace;
	Result.addObject('obj', tlab);
	efEndSub();
end;


{Draws the progress list panel}
procedure _drawStepsPanel();
var
	i: Integer;
	tlab: TButton;
	//tGroup: TGroupBox;
begin
	FreeAndNil(_pgStepsLstLabs);
	_pgStepsLstLabs := TStringList.Create;
	if not Assigned(_pgStepsPanel) then
		_pgStepsPanel := efPanel(windowPadding,windowPadding+50,0,0);
	// Clean for reuse
	for i := _pgStepsPanel.ControlCount-1 downto 0 do
		_pgStepsPanel.Controls[i].Free;
		
	_pgStepsPanel.Width := 300;
	efStartSub(_pgStepsPanel,_pgStepsPanel);
	//tGroup.Name := 'groupSteps';
	efLeft := 5;
	efTop := 5;
	efLabel('Progress',0,0,0,20,efTopAddHeight+efBold);
	efTopAdd(10);
	for i:= 0 to _pgStepsLst.Count -1 do begin
		tlab := efLabel(_pgStepsLst.ValueFromIndex[i],0,0,0,20,efTopAddHeight);
		efApplyLabelColor(tlab, clGray);
		_pgStepsLstLabs.addObject(_pgStepsLst.Names[i],tlab);
		end;
	_pgStepsPanel.Height := efTop + 5;
	efEndSub();
end;

{Event: KeyPress}
{procedure _eventKeyPress(Sender: TObject; var Key: Char);
begin
	if Key = #27 then
		_pgFrm.Close;
end;}

{User requests abort}
procedure _eventAbortProcess(Sender: TObject);
begin
	if WindowConfirm('Abort processing', 'Do you want to abort processing? '+#10#13+'The existing patch file will be incomplete and propably unusable.') then
		bUserRequestAbort := true;
end;

procedure _eventToggleCloseOnFinished(Sender: TObject);
begin
	setSettingsBoolean('config.bProgressCloseOnFinished', Sender.Checked);
	ScriptConfiguration.saveSettings();
end;

{Cleanup}
procedure cleanup();
begin
	// Clear form (auto clears sub childs)
	if Assigned(_pgFrm) then
		_pgFrm.Free;
	// Nil form pointers
	_pgFrm := nil;
	// progressPanel := nil;
	_pgStepsPanel := nil;
	_pgStatsPanel := nil;
	_pgCloseOnFinishedCheckbox := nil;
	_pgCloseButton := nil;
	
	// Clear TObjects
	FreeAndNil(_pgPanLabs1);
	FreeAndNil(_pgPanLabs2);
	FreeAndNil(_pgStepsLst);
	FreeAndNil(_pgStepsProgPercentLst);
	FreeAndNil(_pgStepsLstLabs);
	FreeAndNil(_pgStatsEntries);
end;




end.