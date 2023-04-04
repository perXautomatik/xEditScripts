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
	frmPrg: TForm;
	
	closeOnFinishedCheckbox: TCheckBox;
	closeButton: TCheckBox;
	
	
	prgPanLabs1: TStringList;
	prgPanLabs2: TStringList;
	prgStepsLst: TStringList;
	prgStepsProgPercentLst: TStringList;
	prgCurStepIndex: Integer;
	prgStepsPanel: TPanel;
	prgStepsLstLabs: TStringList;
	
	prgStatsPanel: TPanel;
	prgStatsEntries: TStringList;

	curStepFromPercent,curStepToPercent: Integer;
	
	onCloseTimer: TTimer;

	
implementation

{Init the progress GUI}
procedure init();
begin
	cleanup();
	prgStatsEntries := TStringList.Create;
	prgStepsLst := TStringList.Create;
	prgStepsProgPercentLst := TStringList.Create;
	
	// Prerequisites
	if Assigned(frmPrg) then
		Exit;
end;

{Draw the progress GUI}
procedure draw();
var
	i: Integer;
	tlab: TLabel;
begin
	// Setup
	frmPrg := TForm.Create(nil);
	frmPrg.Width := 606;
	frmPrg.Height := 300;
	frmPrg.BorderStyle := bsDialog;
	frmPrg.Position := poScreenCenter;
	frmPrg.Caption := 'Processing';
	
	//frmPrg.OnKeyPress := _eventKeyPress;
	
	efStartSub(frmPrg,frmPrg);
	prgPanLabs1 := _drawProgressPanel(40);
	efTopAdd(40+10);
	prgPanLabs2 := _drawProgressPanel(30);
	efTopAdd(-10);
	
	setProgressPercent(0);
	
	// Progress list
	_drawStepsPanel();
	frmPrg.Height := prgStepsPanel.Top + prgStepsPanel.Height + 120;
	
	// Stats group
	_drawStatsPanel();

	// Abort button
	closeButton := TButton.Create(frmPrg);
	closeButton.Height := 40;
	closeButton.Width := 150;
	closeButton.TabOrder := 1;
	closeButton.Left := (frmPrg.Width - closeButton.Width)/2;
	closeButton.Top := frmPrg.Height - windowPadding*2 - closeButton.Height;
	closeButton.modalResult := nil;
	closeButton.OnClick := _eventAbortProcess;
	closeButton.Caption := 'Abort processing';
	closeButton.Parent := frmPrg;
	
	// Keep open checkbox
	closeOnFinishedCheckbox := ConstructCheckbox(frmPrg, frmPrg, frmPrg.Height - windowPadding*2-60, windowPadding, 200, 'Close window when finished', false, '');
	closeOnFinishedCheckbox.Checked := getSettingsBoolean('config.bProgressCloseOnFinished');
	closeOnFinishedCheckbox.TabStop := false;
	closeOnFinishedCheckbox.OnClick := _eventToggleCloseOnFinished;

	// Result.Checked := checked;
	frmPrg.Show();
	
	efEndSub();
end;


{Add a progress step}
procedure addStep(stepIdent, stepName:String;stepProgress:Integer);
begin
	// AddMessage('Add step '+stepIdent+' - prgprc: '+IntToStr(stepProgress));
	prgStepsLst.values[stepIdent] := stepName;
	prgStepsProgPercentLst.values[stepIdent] := IntToStr(stepProgress);
end;


{Sets the current progress step}
procedure setCurrentStep(stepIdent: String);
var i, prevHeight:Integer;
	tlab: TButton;
begin
	if not Assigned(prgStepsLst) or not Assigned(prgStepsLstLabs) then
		Exit;
	prgCurStepIndex := prgStepsLst.indexOfName(stepIdent);
	if prgCurStepIndex = -1 then begin
		AddMessage('Unknown progress step: '+stepIdent);
		Exit;
		end;
	
	curStepFromPercent := StrToInt(prgStepsProgPercentLst.values[stepIdent]);
	if prgStepsProgPercentLst.Count - 1 > prgCurStepIndex then
		curStepToPercent := StrToInt(prgStepsProgPercentLst.ValueFromIndex[prgCurStepIndex+1])
	else
		curStepToPercent := 100;
		
	setProgressPercentCurrentStep(0);
	setProgressPercent(curStepFromPercent);
	for i := 0 to prgStepsLst.Count -1 do begin
		tlab := prgStepsLstLabs.Objects[i];
		prevHeight := tlab.Height;
		tlab.Font.Style := [];
		tlab.Font.Color := clBlack;
		tlab.Layout := tlCenter;
		tlab.Height := prevHeight;
		// efApplyLabelColor(tlab,clBlack);
		if prgStepsLst.Names[i] = stepIdent then begin
			tlab.Font.Style := [fsBold];
			break;
			end;
		end;
	
end;


{Sets the shown progress percentage}
procedure setProgressPercent(percent: Integer);
begin
	_setProgressForPanLabsLst(prgPanLabs1, percent,'');
end;

{Sets the shown progress percentage in one steps.}
procedure setProgressPercentCurrentStep(percent: Integer);
begin
	setProgressPercent(curStepFromPercent + (curStepToPercent-curStepFromPercent)*percent/100);
	_setProgressForPanLabsLst(prgPanLabs2, percent,prgStepsLst.ValueFromIndex[prgCurStepIndex]+' ');
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
	if not Assigned(prgStatsEntries) then
		Exit;
	if statValue = '0' then
		statValue := '-';
	if prgStatsEntries.indexOfName(statName) = -1 then begin
		efStartSub(prgStatsPanel,prgStatsPanel);
		tName := efLabel(statName,5,30+prgStatsEntries.Count*20,0,16,efNone);
		efApplyLabelColor(tName, clGray);
		tStat := efLabel('',5,30+prgStatsEntries.Count*20,0,16,efNone+efRight);
		efEndSub();
		prgStatsEntries.addObject(statName+'=1',tStat);
		end;
	prgStatsEntries.values[statName] := statValue;
	prgStatsEntries.Objects[prgStatsEntries.indexOfName(statName)].Text := statValue;
end;


{Marks the progress as finished. Shows the box if the user choosed to keep open}
procedure setFinished();
var
	tlab: TLabel;
begin
	if not Assigned(frmPrg) or not Assigned(closeOnFinishedCheckbox) then
		Exit;
	try
		if not closeOnFinishedCheckbox.Checked then begin
			closeButton.Text := 'Close';
			closeButton.Left := (frmPrg.Width - closeButton.Width)/2;
			closeButton.OnClick := nil;
			closeButton.modalResult := mrCancel;
			closeButton.Cancel := true;
			
			//frmPrg.Hide();
			frmPrg.Visible := false;
			// Sleep(500);
			frmPrg.ShowModal();
			end;
		// frmPrg.Visible := false;
		frmPrg.hide();
		frmPrg.Free;
		frmPrg := nil;
		
		// Create new form to focus fo4edit...
		// Make it some effectful so user isn't get bored by the senseless dialog
		
		frmPrg := TForm.create(nil);
		
		frmPrg.BorderStyle := bsDialog;
		frmPrg.Position := poScreenCenter;
		frmPrg.Caption := 'Shutting down';
		frmPrg.Width := 250;
		frmPrg.Height := 100;
		
		efStartSub(frmPrg,frmPrg);
		{onCloseTimer := TTimer.Create(frmPrg);
		onCloseTimer.Interval := 500;
		onCloseTimer.Enabled := true;
		onCloseTimer.OnTimer := eventOnTimer;}
		//frmPrg.ShowModal();
		frmPrg.Show();
		tlab := efLabel('Shutting down',0,frmPrg.Height/2-25,0,0,efBold+efCenter);
		efEndSub();
		AddMessage('Shutting down');
		Sleep(200);
		Sleep(200);
		Sleep(200);
		Sleep(200);
		Sleep(200);
		
		
	finally
		frmPrg.Free;
		frmPrg := nil;
	end;
end;

{procedure eventOnTimer(  Sender: TObject);
begin
	AddMessage('TIMER');
	frmPrg.hide();
	if Assigned(frmPrg) then
		frmPrg.Free;
	frmPrg := nil;
	cleanup();
end;}

{Draws the statistics panel}
procedure _drawStatsPanel();
begin
	prgStatsPanel := efPanel(windowPadding,windowPadding+50,0,0);
	prgStatsPanel.Left := prgStepsPanel.Left +prgStepsPanel.Width + 20;
	prgStatsPanel.Width := frmPrg.Width - windowPadding*2 - prgStatsPanel.Left + 8;
	efStartSub(prgStatsPanel,prgStatsPanel);
	efLeft := 5;
	efTop := 5;
	efLabel('Statistics',0,0,0,20,efTopAddHeight+efBold);
	prgStatsPanel.Height := prgStepsPanel.Height;
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
begin
	prgStepsLstLabs := TStringList.Create;
	prgStepsPanel := efPanel(windowPadding,windowPadding+50,0,0);
	prgStepsPanel.Width := 300;
	efStartSub(prgStepsPanel,prgStepsPanel);
	efLeft := 5;
	efTop := 5;
	efLabel('Progress',0,0,0,20,efTopAddHeight+efBold);
	efTopAdd(10);
	for i:= 0 to prgStepsLst.Count -1 do begin
		tlab := efLabel(prgStepsLst.ValueFromIndex[i],0,0,0,20,efTopAddHeight);
		efApplyLabelColor(tlab, clGray);
		prgStepsLstLabs.addObject(prgStepsLst.Names[i],tlab);
		end;
	prgStepsPanel.Height := efTop + 5;
	efEndSub();
end;

{Event: KeyPress}
{procedure _eventKeyPress(Sender: TObject; var Key: Char);
begin
	if Key = #27 then
		frmPrg.Close;
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
	if Assigned(frmPrg) then
		frmPrg.Free;
	// Nil form pointers
	frmPrg := nil;
	// progressPanel := nil;
	prgStepsPanel := nil;
	prgStatsPanel := nil;
	closeOnFinishedCheckbox := nil;
	closeButton := nil;
	
	// Clear TObjects
	FreeAndNil(prgPanLabs1);
	FreeAndNil(prgPanLabs2);
	FreeAndNil(prgStepsLst);
	FreeAndNil(prgStepsProgPercentLst);
	FreeAndNil(prgStepsLstLabs);
	FreeAndNil(prgStatsEntries);
end;




end.