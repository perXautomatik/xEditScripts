unit AdhesiveAdjust;

const
	AdhesiveC = 'c_Adhesive "Glue" [CMPO:0001FAA5]';
	AluminumC = 'c_Aluminum "Aluminum" [CMPO:0001FA91]';
	BallisticFiberC = 'c_AntiBallisticFiber "Ballistic Fiber" [CMPO:0001FA94]';
	AsbestosC = 'c_Asbestos "Asbestos" [CMPO:0001FA97]';
	BoneC = 'c_Bone "Bone" [CMPO:0001FA98]';
	CircuitryC = 'c_Circuitry "Circuitry" [CMPO:0001FA9B]';
	ClothC = 'c_Cloth "Cloth" [CMPO:001223C7]';
	CopperC = 'c_Copper "Copper" [CMPO:0001FA9C]';
	CorkC = 'c_Cork "Cork" [CMPO:0001FA9D]';
	FiberglassC = 'c_Fiberglass "Fiberglass" [CMPO:0001FAA1]';
	GoldC = 'c_Gold "Gold" [CMPO:0001FAA6]';
	LeadC = 'c_Lead "Lead" [CMPO:0001FAAD]';
	LeatherC = 'c_Leather "Leather" [CMPO:0001FAAE]';
	OilC = 'c_Oil "Oil" [CMPO:0001FAB4]';
	PlasticC = 'c_Plastic "Plastic" [CMPO:0001FAB7]';
	RubberC = 'c_Rubber "Rubber" [CMPO:0001FAB9]';
	SteelC = 'c_Steel "Steel" [CMPO:0001FABD]';
	ScrewsC = 'c_Screws "Screw" [CMPO:0003D294]';
	FluxC = '_gkx_c_flux "Flux" [CMPO:04000F99]';
	SolderC = '_gkx_c_solder "Solder" [CMPO:04002E18]';
	TapeC = '_gkx_c_tape "Tape" [CMPO:04000F9A]';
	ThreadC = '_gkx_c_thread "Thread" [CMPO:04002E1E]';
	WireC = '_gkx_c_wire "Wire" [CMPO:04002E11]';
	
Procedure FindMax(x, y, z: Integer; var r: Integer);

BEGIN
	IF ((z >= y) AND (z >= x)) THEN
		r := 3
	ELSE
		IF ((y >= z) AND (y >= x)) THEN
			r := 2
		ELSE
			IF ((x >= y) AND (x >= z)) THEN
				r := 1;
END;

var
	sl: TStringList;

function Initialize: integer;
BEGIN
	sl := TStringList.Create;
END;

Function Process(e: IInterface): integer;
var
	eFVPA, WorkingComp: IInterface;
	eEDID: String;
	
	CompN: Array[1..20] of String;
	CompC: Array[1..20] of Integer;
	
	AdhsvIndex, CopperIndex, GoldIndex, OilIndex, ScrewIndex: Integer;
	AdhsvCount, AlumCount, BalFibCount, BoneCount, CircCount, ClothCount, CopperCount, CorkCount, FGlassCount, GoldCount, LeadCount, LeatherCount, OilCount, PlasticCount, RubberCount, ScrewCount, SteelCount: Integer;
	MetalCount: Integer;
	HasAdhesive, HasOil, HasScrews, IsPipeGun: Bool;
	GlueCount, FluxCount, SolderCount, TapeCount, ThreadCount, WireCount: Integer;
	GluePcs, FluxPcs, SolderPcs, TapePcs, ThreadPcs, WirePcs, CircSolder: Integer;
	MaxComp, vsScrews: Integer;
	
	count, CompCountOld, CompCountNew : Integer;
	
	MarkForDelete1, MarkForDelete2, MarkForDelete3, ZeroInt: Integer;
	
	sTemp1, sTemp2, sTemp3, sTemp4, sTemp5, sTemp6: String;
	
BEGIN
	//Basic stuff
	
	AdhsvCount := 0;
	AlumCount := 0;
	BalFibCount := 0;
	BoneCount := 0;
	CircCount := 0;
	ClothCount := 0;
	CopperCount := 0;
	CorkCount := 0;
	FGlassCount := 0;
	GoldCount := 0;
	LeadCount := 0;
	LeatherCount := 0;
	OilCount := 0;
	PlasticCount := 0;
	RubberCount := 0;
	ScrewCount := 0;
	SteelCount := 0;
	MetalCount := 0;
	AdhsvIndex := 0;
	CopperIndex := 0;
	GoldIndex := 0;
	OilIndex := 0;
	HasAdhesive := FALSE;
	HasOil := FALSE;
	HasScrews := FALSE;
	IsPipeGun := FALSE;
	GlueCount := 0;
	FluxCount := 0;
	SolderCount := 0;
	TapeCount := 0;
	ThreadCount := 0;
	WireCount := 0;
	GluePcs := 0;
	FluxPcs := 0;
	SolderPcs := 0;
	TapePcs := 0;
	ThreadPcs := 0;
	WirePcs := 0;
	MaxComp := 0;
	vsScrews := 0;
	count := 0;
	CompCountOld := 0;
	CompCountNew := 0;
	sTemp1 := '';
	sTemp2 := '';
	sTemp3 := '';
	sTemp4 := '';
	sTemp5 := '';
	sTemp6 := '';
	MarkForDelete1 := -1;
	MarkForDelete2 := -1;
	MarkForDelete3 := -1;
	ZeroInt := 0;
	
	eFVPA := ElementByPath(e, 'FVPA - Components');
	eEDID := GetEditValue(ElementByPath(e, 'EDID'));
	CompCountOld := ElementCount(eFVPA);
	sl.add(eEDID);
	sTemp1 := ('Components: ' + IntToStr(CompCountOld));
	sl.add(sTemp1);
	IF CompCountOld = 0 THEN Exit;
	
	//Determine relevant component counts
	
	FOR count := 1 TO CompCountOld DO
		BEGIN
			WorkingComp := ElementByIndex(eFVPA, count - 1);
			CompN[count] := GetEditValue(ElementByIndex(WorkingComp, 0));
			CompC[count] := GetNativeValue(ElementByIndex(WorkingComp, 1));
			
			IF CompN[count] = AdhesiveC THEN
				BEGIN
					AdhsvCount := CompC[count];
					AdhsvIndex := count - 1;
					HasAdhesive := TRUE;
				END;
			IF CompN[count] = OilC THEN
				BEGIN
					OilCount := CompC[count];
					OilIndex := count - 1;
					HasOil := TRUE;
				END;
			IF CompN[count] = ScrewsC THEN
				BEGIN
					ScrewCount := CompC[count];
					ScrewIndex := count - 1;
					HasScrews := TRUE;
				END;
				
			IF CompN[count] = AluminumC THEN
				AlumCount := CompC[count];
			IF CompN[count] = BallisticFiberC THEN
				BalFibCount := CompC[count];
			IF CompN[count] = BoneC THEN
				BoneCount := CompC[count];
			IF CompN[count] = CircuitryC THEN
				CircCount := CompC[count];
			IF CompN[count] = ClothC THEN
				ClothCount := CompC[count];
			IF CompN[count] = CopperC THEN
				CopperCount := CompC[count];
			IF CompN[count] = CorkC THEN
				CorkCount := CompC[count];
			IF CompN[count] = FiberglassC THEN
				FGlassCount := CompC[count];
			IF CompN[count] = GoldC THEN
				GoldCount := CompC[count];
			IF CompN[count] = LeadC THEN
				LeadCount := CompC[count];
			IF CompN[count] = LeatherC THEN
				LeatherCount := CompC[count];
			IF CompN[count] = PlasticC THEN
				PlasticCount := CompC[count];
			IF CompN[count] = RubberC THEN
				RubberCount := CompC[count];
			IF CompN[count] = SteelC THEN
				SteelCount := CompC[count];
			
		END;
		
	//Various Adhesive Calculations
	
	sTemp1 := ('Pipe');
	sTemp2 := ('Wrench');
	sTemp3 := ('Lead');
	IsPipeGun := ((POS(sTemp1, eEDID) > 0) AND (POS(sTemp2, eEDID) = 0) AND (POS(sTemp3, eEDID) = 0));
	
	GluePcs := (BoneCount + CorkCount + FGlassCount + PlasticCount + RubberCount);
	ThreadPcs := (ClothCount + LeatherCount);
	IF IsPipeGun THEN
		WirePcs := (GoldCount)
	ELSE
		WirePcs := (CopperCount + GoldCount);
	FluxPcs := (AlumCount + SteelCount);
	IF IsPipeGun THEN
		SolderPcs := (LeadCount + CopperCount)
	ELSE
		SolderPcs := (LeadCount);
	
	//Account for "Banker's Rounding"
	
	IF NOT ((GluePcs MOD 2) = 0) THEN GlueCount := (GluePcs + 1) / 2 ELSE GlueCount := GluePcs / 2;
	IF NOT ((ThreadPcs MOD 2) = 0) THEN ThreadCount := (ThreadPcs + 1) / 2 ELSE ThreadCount := ThreadPcs / 2;
	IF NOT ((WirePcs MOD 2) = 0) THEN WireCount := (WirePcs + 1) / 2 ELSE WireCount := WirePcs / 2;
	IF NOT ((FluxPcs MOD 2) = 0) THEN FluxCount := (FluxPcs + 1) / 2 ELSE FluxCount := FluxPcs / 2;
	IF NOT ((SolderPcs MOD 2) = 0) THEN SolderCount := (SolderPcs + 1) / 2 ELSE SolderCount := SolderPcs / 2;
	
	//Deal with Screws
	
	IF HasScrews THEN
		BEGIN
			vsScrews := (GlueCount + FluxCount + SolderCount);
			IF (ScrewCount > 0) THEN
				FOR count := 1 TO ScrewCount DO
					BEGIN
						FindMax(GlueCount, SolderCount, FluxCount, MaxComp);
						IF MaxComp = 1 THEN
							GlueCount := GlueCount - 1;
						IF MaxComp = 2 THEN
							SolderCount := SolderCount - 1;
						IF MaxComp = 3 THEN
							FluxCount := FluxCount - 1;
					END;
		END;
	
	OilCount := (OilCount + FluxCount);
	
	//Deal with Circuitry
	
	IF NOT ((CircCount MOD 2) = 0) THEN CircSolder := (CircCount + 1) / 2 ELSE CircSolder := CircCount / 2;
	SolderCount := SolderCount + CircSolder;
		
	//Debugging
		
{	sTemp1 := ('  Glue: ' + IntToStr(GlueCount));
	sTemp2 := ('Thread: ' + IntToStr(ThreadCount));
	sTemp3 := ('  Wire: ' + IntToStr(WireCount));
	sTemp4 := ('  Flux: ' + IntToStr(FluxCount));
	sTemp5 := ('Solder: ' + IntToStr(SolderCount));
	sTemp6 := ('Screws: ' + IntToStr(ScrewCount));
	sl.add(sTemp1);
	sl.add(sTemp2);
	sl.add(sTemp3);
	sl.add(sTemp4);
	sl.add(sTemp5);
	sl.add(sTemp6);}
		
	//Get rid of Adhesive, Copper (except Pipe weapons), and Gold
	
	FOR count := 1 TO CompCountOld DO
		BEGIN
			WorkingComp := ElementByIndex(eFVPA, count - 1);
			IF (CompN[count] = AdhesiveC) THEN
				SetNativeValue(ElementByIndex(WorkingComp, 1), 0);
			IF ((CompN[count] = CopperC) AND NOT IsPipeGun) THEN
				SetNativeValue(ElementByIndex(WorkingComp, 1), 0);
			IF (CompN[count] = GoldC) THEN
				SetNativeValue(ElementByIndex(WorkingComp, 1), 0);
		END;
	
	//Replace Glue and add other components
	
	sTemp1 := AdhesiveC;
	sTemp2 := FluxC;
	sTemp3 := SolderC;
	sTemp4 := ThreadC;
	sTemp5 := WireC;
	sTemp6 := OilC;
		
	IF (GlueCount > 0) THEN
		IF HasAdhesive THEN
			BEGIN
				WorkingComp := ElementByIndex(eFVPA, AdhsvIndex);
				SetNativeValue(ElementByIndex(WorkingComp, 1), GlueCount);
			END
		ELSE
			BEGIN
				WorkingComp := ElementAssign(eFVPA, HighInteger, NIL, FALSE);
				SetEditValue(ElementByIndex(WorkingComp, 0), sTemp1);
				SetNativeValue(ElementByIndex(WorkingComp, 1), GlueCount);
			END;
	
	IF (FluxCount > 0) THEN
		BEGIN
			WorkingComp := ElementAssign(eFVPA, HighInteger, NIL, FALSE);
			SetEditValue(ElementByIndex(WorkingComp, 0), sTemp2);
			SetNativeValue(ElementByIndex(WorkingComp, 1), FluxCount);
			IF HasOil THEN
				BEGIN
					WorkingComp := ElementByIndex(eFVPA, OilIndex);
					SetNativeValue(ElementByIndex(WorkingComp, 1), OilCount);
				END
			ELSE
				BEGIN
					WorkingComp := ElementAssign(eFVPA, HighInteger, NIL, FALSE);
					SetEditValue(ElementByIndex(WorkingComp, 0), sTemp6);
					SetNativeValue(ElementByIndex(WorkingComp, 1), OilCount);
				END;			
		END;
		

	IF (SolderCount > 0) THEN
		BEGIN
			WorkingComp := ElementAssign(eFVPA, HighInteger, NIL, FALSE);
			SetEditValue(ElementByIndex(WorkingComp, 0), sTemp3);
			SetNativeValue(ElementByIndex(WorkingComp, 1), SolderCount);
		END;
		
	IF (ThreadCount > 0) THEN
		BEGIN
			WorkingComp := ElementAssign(eFVPA, HighInteger, NIL, FALSE);
			SetEditValue(ElementByIndex(WorkingComp, 0), sTemp4);
			SetNativeValue(ElementByIndex(WorkingComp, 1), ThreadCount);
		END;
		
	IF (WireCount > 0) THEN
		BEGIN
			WorkingComp := ElementAssign(eFVPA, HighInteger, NIL, FALSE);
			SetEditValue(ElementByIndex(WorkingComp, 0), sTemp5);
			SetNativeValue(ElementByIndex(WorkingComp, 1), WireCount);
		END;
		
	//Final clean-up, remove zero entries
	
	CompCountNew := ElementCount(eFVPA);
	FOR count := 1 TO CompCountNew DO
		BEGIN
			WorkingComp := ElementByIndex(eFVPA, count - 1);
			ZeroInt := GetNativeValue(ElementByIndex(WorkingComp, 1));
			IF (ZeroInt = 0) THEN
				IF (MarkForDelete1 < 0) THEN
					MarkForDelete1 := count - 1
				ELSE 
					IF (MarkForDelete2 < 0) THEN
						MarkForDelete2 := count - 1
					ELSE
						IF (MarkForDelete3 < 0) THEN
							MarkForDelete3 := count - 1;
		END;
	IF (MarkForDelete3 >= 0) THEN
		BEGIN
			WorkingComp := (ElementByIndex(eFVPA, MarkForDelete3));
			Remove(WorkingComp);
		END;
	IF (MarkForDelete2 >= 0) THEN
		BEGIN
			WorkingComp := (ElementByIndex(eFVPA, MarkForDelete2));
			Remove(WorkingComp);
		END;
	IF (MarkForDelete1 >= 0) THEN
		BEGIN
			WorkingComp := (ElementByIndex(eFVPA, MarkForDelete1));
			Remove(WorkingComp);
		END;
	
END;

function Finalize: integer;

//More Debugging

var
	fname: string;

BEGIN
{	fname := ProgramPath + 'outputtest.txt';
	sl.SaveToFile(fname);
	sl.Free;}
END;

END.