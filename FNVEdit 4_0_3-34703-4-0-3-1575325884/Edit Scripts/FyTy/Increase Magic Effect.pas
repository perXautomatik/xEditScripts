unit userscript;
var
	strEffectMagnitudePath: string;
	fModifier: float;

function Initialize: integer;
begin
	strEffectMagnitudePath := 'EFIT - \Magnitude';
	fModifier := 1.00;
end;


function Process(e: IInterface): integer;
var
	eEffects, eCurrentEffect: IInterface;
	fMagnitudeOrig, fMagnitudeNew: float;
	iCounter: integer;
begin

	if Signature(e) <> 'SPEL' then
		exit;
	
  AddMessage('Processing: ' + FullPath(e));
	
	eEffects := ElementByPath(e, 'Effects');
	
	for iCounter := 0 to ElementCount(eEffects) - 1 do begin
	
		eCurrentEffect := ElementByIndex(eEffects, iCounter);
		fMagnitudeOrig := StrToFloat(GetElementEditValues(eCurrentEffect, strEffectMagnitudePath));
		
		fMagnitudeNew := fMagnitudeOrig + fModifier;
		
		SetElementEditValues(eCurrentEffect, strEffectMagnitudePath, FloatToStr(fMagnitudeNew));
		
	end;
	
end;


function Finalize: integer;
begin
	
end;

end.
