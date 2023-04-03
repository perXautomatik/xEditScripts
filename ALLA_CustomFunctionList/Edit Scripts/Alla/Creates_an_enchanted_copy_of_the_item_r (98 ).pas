

// Creates an enchanted copy of the item record and returns it [From Generate Enchanted Versions]
function CreateEnchantedVersion(aRecord, aPlugin, objEffect, enchRecord: IInterface; suffix: String; enchAmount: Integer; aBoolean: Boolean): IInterface;
var
	startTime, stopTime: TDateTime;
  tempRecord: IInterface;
	tempString: String;
	debugMsg: Boolean;
  enchCost: Integer;
begin
	// Initialize
	debugMsg := false;
	startTime := Time;

	{Debug} if debugMsg then msg('[CreateEnchantedVersion] Begin');
	{Debug} if debugMsg then msg('[CreateEnchantedVersions] CreateEnchantedVersion('+EditorID(aRecord)+', '+GetFileName(aPlugin)+', '+EditorID(objEffect)+', '+EditorID(enchRecord)+', '+suffix+', '+IntToStr(enchAmount)+' );');

	// Create new enchantment if one is not detected
	BeginUpdate(enchRecord);
	try
		{Debug} if debugMsg then msg('[CreateEnchantedVersions] SetElementEditValues(enchRecord, EditorID, '+EditorID(aRecord)+'_'+EditorID(objEffect)+' );');
		SetElementEditValues(enchRecord, 'EDID', EditorID(aRecord)+'_'+EditorID(objEffect));
		SetElementEditValues(enchRecord, 'EITM', GetEditValue(objEffect));
		if (enchAmount = 0) then
			enchAmount := 1;
		SetElementEditValues(enchRecord, 'EAMT', enchAmount);
		SetElementEditValues(enchRecord, 'FULL', full(aRecord)+' of '+Trim(suffix));
		// Set template so that enchanted version will use base record's COBJ
		if (sig(aRecord) = 'WEAP') then begin
			{Debug} if debugMsg then msg('[CreateEnchantedVersions] SetElementEditValues('+EditorID(enchRecord)+', CNAM, '+ShortName(aRecord)+' );');
			SetElementEditValues(enchRecord, 'CNAM', ShortName(aRecord));
		end else if (sig(aRecord) = 'ARMO') then begin
			{Debug} if debugMsg then msg('[CreateEnchantedVersions] SetElementEditValues('+EditorID(enchRecord)+', TNAM, '+ShortName(aRecord)+' );');
			SetElementEditValues(enchRecord, 'TNAM', ShortName(aRecord));
		end;
	
		// Disallow enchanting
		if not aBoolean then begin
			if not HasKeyword(enchRecord, 'DisallowEnchanting') then begin
				enchRecord := CopyRecordToFile(enchRecord, aPlugin, False, True);
				SetElementEditValues(enchRecord, 'EDID', EditorID(aRecord)+'_'+EditorID(objEffect)+'_DisallowEnchanting');
				AddKeyword(enchRecord, GetRecordByFormID('000C27BD'));
			end;
		end;
	finally
		EndUpdate(enchRecord);
	end;

	// Finalize
	{Debug} if debugMsg then msg('[CreateEnchantedVersions] Result := '+EditorID(enchRecord));
  Result := enchRecord;
	if ProcessTime then begin
		stopTime := Time;
		addProcessTime('createEnchantedVersion', TimeBtwn(startTime, stopTime));
	end;
end;