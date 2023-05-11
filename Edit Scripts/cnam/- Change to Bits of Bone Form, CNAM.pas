{
	Purpose: Change CNAM to Bone Meal
	Game: The Elder Scrolls V: Skyrim
	Author: fireundubh <fireundubh@gmail.com>
	Version: 0.1
}

unit UserScript;

function Process(e: IInterface): integer;
	var
		rec: IInterface;

	begin
		Result := 0;

		rec := Signature(e);

		AddMessage('Processing: ' + FullPath(e));
		AddMessage('-------------------------------------------------------------------------------');
		AddMessage(' ');

		// processing code goes here
		SetElementEditValues(e, 'CNAM', '_DS_BoneBits "Bits of Bone" [MISC:04006953]');
		SetElementNativeValues(e, 'NAM1', 1);
		SetElementEditValues(e, 'WBDT\Uses Skill', 'None');
	end;

function Finalize: integer;
	begin
		AddMessage(' ');
		Result := 1;
	end;

end.
