
//gets templetes for books
//todo fix paths for SPIT\Half-cost Perk and SPIT/BASE COST
function BookTemplate(bookRecord:IInterface):IInterface;
var
	books, flags, tempSpellRecord: IInterface;
	halfCostPerk: string;
begin
	if (GetEditValue(elementbypath(selectedRecord, 'DATA\Flags\Teaches spell'))) = '1' then begin//checks if book is tome
		tempSpellRecord := LinksTo(elementbypath(bookRecord, 'DATA\Flags\Teaches'));//spell from tome
		if not (LinksTo(elementbypath(tempSpellRecord, 'SPIT\Half-cost Perk')) = nil) then begin
			halfCostPerk := GetElementEditValues(tempSpellRecord, 'SPIT\Half-cost Perk');
			{Debug} msg('halfCostPerk' + halfCostPerk);
			case extractInts(halfCostPerk, 1) of
			00	:	begin
						case elementbypath(halfCostPerk, 'Novice', True) of
							'Alteration'	:	Result :=GetRecordByFormID('0009E2A7');
							'Conjuration'	:	Result :=GetRecordByFormID('0009E2AA');
							'Destruction'	:	Result :=GetRecordByFormID('0009CD52');
							'Illusion'		:	Result :=GetRecordByFormID('0009E2AD');
							'Restoration'	:	Result :=GetRecordByFormID('0009E2AE');
						end;
					end;
			25	:	begin
						case elementbypath(halfCostPerk, 'Apprentice', True) of
							'Alteration'	:	Result :=GetRecordByFormID('000A26E3');
							'Conjuration'	:	Result :=GetRecordByFormID('0009CD54');
							'Destruction'	:	Result :=GetRecordByFormID('000A2702');
							'Illusion'		:	Result :=GetRecordByFormID('000A270F');
							'Restoration'	:	Result :=GetRecordByFormID('000A2720');
						end;
					end;
			50	:	begin
						case elementbypath(halfCostPerk, 'Adept', True) of
							'Alteration'	:	Result :=GetRecordByFormID('000A26E7');
							'Conjuration'	:	Result :=GetRecordByFormID('000A26EE');
							'Destruction'	:	Result :=GetRecordByFormID('000A2708');
							'Illusion'		:	Result :=GetRecordByFormID('000A2714');
							'Restoration'	:	Result :=GetRecordByFormID('0010F64D');
						end;
					end;
			75	:	begin
						case elementbypath(halfCostPerk, 'Expert', True) of
							'Alteration'	:	Result :=GetRecordByFormID('000A26E8');
							'Conjuration'	:	Result :=GetRecordByFormID('000A26F7');
							'Destruction'	:	Result :=GetRecordByFormID('0010F7F4');
							'Illusion'		:	Result :=GetRecordByFormID('000A2718');
							'Restoration'	:	Result :=GetRecordByFormID('000A2729');
						end;
					end;
			100	:	begin
						case elementbypath(halfCostPerk, 'Master', True) of
							'Alteration'	:	Result :=GetRecordByFormID('000DD646');
							'Conjuration'	:	Result :=GetRecordByFormID('000A26FA');
							'Destruction'	:	Result :=GetRecordByFormID('000A270D');
							'Illusion'		:	Result :=GetRecordByFormID('000A2719');
							'Restoration'	:	Result :=GetRecordByFormID('000FDE7B');
						end;
					end;
			end;
		end
		else begin //uses restoration books as level list base
			case StrToInt(GetElementEditValues(tempSpellRecord, 'SPIT/BASE COST')) of
				0..96		: Result :=GetRecordByFormID('0009E2AE');//novice
				97..156		: Result :=GetRecordByFormID('000A2720');//aprentice
				157..250	: Result :=GetRecordByFormID('0010F64D');//adept
				251..644	: Result :=GetRecordByFormID('000A2729');//expert
			else
				Result :=GetRecordByFormID('000FDE7B');//master
			end;
		end;
	end;
end;