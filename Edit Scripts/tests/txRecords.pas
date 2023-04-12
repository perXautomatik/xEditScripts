unit txRecords;

interface

type
  TConflictAll = (
    caUnknown,
    caOnlyOne,
    caNoConflict,
    caConflictBenign,
    caOverride,
    caConflict,
    caConflictCritical
  );
  TConflictThis = (
    ctUnknown,
    ctIgnored,
    ctNotDefined,
    ctIdenticalToMaster,
    ctOnlyOne,
    ctHiddenByModGroup,
    ctMaster,
    ctConflictBenign,
    ctOverride,
    ctIdenticalToMasterWinsConflict,
    ctConflictWins,
    ctConflictLoses
  );

  // PUBLIC TESTING INTERFACE
  procedure BuildRecordHandlingTests;
  procedure TestIsMaster(rec: Cardinal; expectedValue: WordBool);

implementation

uses
  classes, Mahogany,
  {$IFDEF USE_DLL}
  txImports,
  {$ENDIF}
  {$IFNDEF USE_DLL}
  xeMeta, xeElements, xeRecords, xeElementValues,
  {$ENDIF}
  txMeta;

function TestGetRecord(h: Cardinal; formID: Cardinal): Cardinal;
begin
  ExpectSuccess(GetRecord(h, formID, False, @Result));
  Expect(Result > 0, 'Should return a handle');
end;

procedure TestGetRecords(h: Cardinal; path, search: PWideChar; includeOverrides: WordBool; expectedCount: Integer);
var
  len: Integer;
  a: CardinalArray;
  i: Integer;
begin
  if path <> '' then
    ExpectSuccess(GetElement(h, path, @h));
  ExpectSuccess(GetRecords(h, search, includeOverrides, @len));
  ExpectEqual(len, expectedCount);
  a := gra(len);
  for i := Low(a) to High(a) do
    Release(a[i]);
end;

procedure TestGetREFRs(h: Cardinal; search: PWideChar; flags, expectedCount: Integer);
var
  len: Integer;
  a: CardinalArray;
  i: Integer;
begin
  ExpectSuccess(GetREFRs(h, search, flags, @len));
  ExpectEqual(len, expectedCount);
  a := gra(len);
  for i := Low(a) to High(a) do
    Release(a[i]);
end;

function TestFindNextRecord(context: Cardinal; search: PWideChar; byEdid, byName: WordBool; expectedEdid: String): Cardinal;
var
  len: Integer;
begin
  ExpectSuccess(FindNextRecord(context, search, byEdid, byName, @Result));
  Expect(Result > 0, 'Should return a handle');
  ExpectSuccess(GetValue(Result, 'EDID', @len));
  ExpectEqual(grs(len), expectedEDID);
end;

procedure TestFindValidReferences(h: Cardinal; path: PWideChar; signature, search: PWideChar; expectedResults: TStringArray);
var
  expectedLen, len: Integer;
  sl: TStringList;
  i: Integer;
begin
  if path <> '' then
    ExpectSuccess(GetElement(h, path, @h));
  expectedLen := Length(expectedResults);
  ExpectSuccess(FindValidReferences(h, signature, search, expectedLen, @len));
  sl := TStringList.Create;
  try
    sl.Text := grs(len);
    ExpectEqual(expectedLen, sl.Count);
    for i := Low(expectedResults) to High(expectedResults) do
      ExpectEqual(sl[i], expectedResults[i]);
  finally
    sl.Free;
  end;
end;

procedure TestIsMaster(rec: Cardinal; expectedValue: WordBool);
var
  b: WordBool;
begin
  ExpectSuccess(IsMaster(rec, @b));
  ExpectEqual(b, expectedValue);
end;

procedure TestIsInjected(rec: Cardinal; expectedValue: WordBool);
var
  b: WordBool;
begin
  ExpectSuccess(IsInjected(rec, @b));
  ExpectEqual(b, expectedValue);
end;

procedure TestIsOverride(rec: Cardinal; expectedValue: WordBool);
var
  b: WordBool;
begin
  ExpectSuccess(IsOverride(rec, @b));
  ExpectEqual(b, expectedValue);
end;

procedure TestIsWinningOverride(rec: Cardinal; expectedValue: WordBool);
var
  b: WordBool;
begin
  ExpectSuccess(IsWinningOverride(rec, @b));
  ExpectEqual(b, expectedValue);
end;

procedure TestGetConflictData(nodes, element: Cardinal; path: PWideChar; ca: TConflictAll; ct: TConflictTHis);
var
  caResult, ctResult: Byte;
begin
  if path <> '' then
    ExpectSuccess(GetElement(element, path, @element));
  ExpectSuccess(GetConflictData(nodes, element, @caResult, @ctResult));
  ExpectEqual(caResult, Ord(ca));
  ExpectEqual(ctResult, Ord(ct));
end;

procedure BuildRecordHandlingTests;
var
  b: WordBool;
  skyrim, armo, ar1, dnam, xt1, xt2, xt4, ar2, ar3, kw1, kw2, kw3, h, n1, n2, n3: Cardinal;
begin
  Describe('Record Handling', procedure
    begin
      BeforeAll(procedure
        begin
          ExpectSuccess(GetElement(0, 'Skyrim.esm', @skyrim));
          ExpectSuccess(GetElement(skyrim, 'ARMO', @armo));
          ExpectSuccess(GetElement(armo, '00012E46', @ar1));
          ExpectSuccess(GetElement(ar1, 'DNAM', @dnam));
          ExpectSuccess(GetElement(0, 'xtest-1.esp', @xt1));
          ExpectSuccess(GetElement(0, 'xtest-2.esp', @xt2));
          ExpectSuccess(GetElement(0, 'xtest-4.esp', @xt4));
          ExpectSuccess(GetElement(0, 'xtest-2.esp\00012E46', @ar2));
          ExpectSuccess(GetElement(0, 'xtest-3.esp\00012E46', @ar3));
          ExpectSuccess(GetElement(0, 'xtest-1.esp\00C23800', @kw1));
          ExpectSuccess(GetElement(0, 'xtest-1.esp\00C23801', @kw2));
          ExpectSuccess(GetElement(0, 'xtest-4.esp\00C23801', @kw3));
        end);

      Describe('GetRecord', procedure
        begin
          It('Should be able to resolve records from root', procedure
            begin
              TestGetRecord(0, $01000800);
              TestGetRecord(0, $03000800);
              TestGetRecord(0, $05000800);
            end);

          It('Should be able to resolve injected records from root', procedure
            begin
              TestGetRecord(0, $00C23800);
              TestGetRecord(0, $00C23801);
              TestGetRecord(0, $00C23802);
            end);

          It('Should be able to resolve overrides by local FormID', procedure
            begin
              TestGetRecord(xt2, $0007F82A);
              TestGetRecord(xt2, $00012E46);
            end);

          It('Should be able to new records by local FormID', procedure
            begin
              TestGetRecord(xt2, $03000800);
              TestGetRecord(xt4, $03000800);
            end);

          It('Should be able to resolve injections by local FormID', procedure
            begin
              TestGetRecord(xt1, $00C23800);
              TestGetRecord(xt1, $00C23801);
            end);
        end);

      Describe('GetRecords', procedure
        begin
          Describe('No search', procedure
            begin
              It('Should return all records in a file', procedure
                begin
                  TestGetRecords(0, 'xtest-2.esp', '', True, 6);
                end);

              It('Should be able to exclude overrides', procedure
                begin
                  TestGetRecords(0, 'xtest-2.esp', '', False, 1);
                end);

              It('Should return all records in a top level group', procedure
                begin
                  TestGetRecords(armo, '', '', True, 2762);
                  TestGetRecords(0, 'xtest-2.esp\CELL', '', True, 3);
                end);

              It('Should return all records in a subgroup', procedure
                begin
                  TestGetRecords(0, 'xtest-2.esp\00027D1C\Child Group\Persistent', '', True, 2);
                end);

              It('Should return all record children of a record', procedure
                begin
                  TestGetRecords(0, 'xtest-2.esp\00027D1C', '', True, 2);
                end);
            end);

          Describe('Search', procedure
            begin
              It('Should return all records of a given signature in all files', procedure
                begin
                  TestGetRecords(0, '', 'DOBJ', False, 1);
                  TestGetRecords(0, '', 'DOBJ', True, 2);
                  TestGetRecords(0, '', 'ARMO', False, 2763);
                  TestGetRecords(0, '', 'ARMO', True, 2808);
                end);

              It('Should be able to handle multiple signatures', procedure
                begin
                  TestGetRecords(0, '', 'ARMO,WEAP,MISC', False, 2763 + 2484 + 371);
                end);

              It('Should map names to signatures', procedure
                begin
                  TestGetRecords(0, '', 'Armor', False, 2763);
                  TestGetRecords(0, '', 'Constructible Object,Non-Player Character (Actor)', False, 606 + 5119);
                end);
            end);

          {$IFNDEF SKIP_BENCHMARKS}
          Describe('Speed', procedure
            begin
              It('Should load records quickly', procedure
                begin
                  Benchmark(5, procedure
                    begin
                      TestGetRecords(0, 'Skyrim.esm', '', False, 869692);
                    end);
                end);
            end);
          {$ENDIF}
        end);

      {$IFNDEF SKIP_BENCHMARKS}
      Describe('GetREFRs', procedure
        begin
          Describe('Speed', procedure
            begin
              It('Should load records quickly', procedure
                begin
                  Benchmark(5, procedure
                    begin
                      TestGetREFRs(0, 'DOOR', 0, 3535);
                    end);
                end);
            end);
        end);
      {$ENDIF}

      Describe('FindNextRecord', procedure
        begin
          BeforeAll(procedure
            begin
              ExpectSuccess(SetSortMode(1, false));
            end);

          AfterAll(procedure
            begin
              ExpectSuccess(SetSortMode(0, false));
            end);

          It('Should work with root handle', procedure
            begin
              h := TestFindNextRecord(0, 'Armor', True, False, 'TG08ANightingaleArmorActivator');
            end);

          It('Should work from record handle', procedure
            begin
              h := TestFindNextRecord(h, 'Armor', True, False, 'FortifySkillHeavyArmor02');
            end);
        end);

      Describe('FindValidReferences', procedure
        begin
          It('Should work in Update.esm', procedure
            begin
              TestFindValidReferences(0, 'Update.esm', 'KYWD', 'a', TStringArray.Create(
                'DA15WabbajackExcludedKeyword [KYWD:01000997]',
                'ImmuneDragonPairedKill [KYWD:010009A2]',
                'ArmorMaterialForsworn [KYWD:010009B9]',
                'ArmorMaterialMS02Forsworn [KYWD:010009BA]',
                'ArmorMaterialPenitus [KYWD:010009BB]'
              ));
            end);
        end);

      Describe('IsMaster', procedure
        begin
          It('Should return true for master records', procedure
            begin
              TestIsMaster(ar1, True);
              TestIsMaster(kw1, True);
              TestIsMaster(kw2, True);
            end);

          It('Should return false for override records', procedure
            begin
              TestIsMaster(ar2, False);
              TestIsMaster(ar3, False);
              TestIsMaster(kw3, False);
            end);

          It('Should fail on elements that are not records', procedure
            begin
              ExpectFailure(IsMaster(skyrim, @b));
              ExpectFailure(IsMaster(armo, @b));
              ExpectFailure(IsMaster(dnam, @b));
            end);

          It('Should fail if a null handle is passed', procedure
            begin
              ExpectFailure(IsMaster(0, @b));
            end);
        end);

      Describe('IsInjected', procedure
        begin
          It('Should return false for master records', procedure
            begin
              TestIsInjected(ar1, False);
            end);

          It('Should return false for override records', procedure
            begin
              TestIsInjected(ar2, False);
            end);

          It('Should return true for injected records', procedure
            begin
              TestIsInjected(kw1, True);
              TestIsInjected(kw2, True);
            end);

          It('Should fail on elements that are not records', procedure
            begin
              ExpectFailure(IsInjected(skyrim, @b));
              ExpectFailure(IsInjected(armo, @b));
              ExpectFailure(IsInjected(dnam, @b));
            end);

          It('Should fail if a null handle is passed', procedure
            begin
              ExpectFailure(IsInjected(0, @b));
            end);
        end);

      Describe('IsOverride', procedure
        begin
          It('Should return false for master records', procedure
            begin
              TestIsOverride(ar1, False);
              TestIsOverride(kw1, False);
              TestIsOverride(kw2, False);
            end);

          It('Should return true for override records', procedure
            begin
              TestIsOverride(ar2, True);
              TestIsOverride(ar3, True);
              TestIsOverride(kw3, True);
            end);

          It('Should fail on elements that are not records', procedure
            begin
              ExpectFailure(IsOverride(skyrim, @b));
              ExpectFailure(IsOverride(armo, @b));
              ExpectFailure(IsOverride(dnam, @b));
            end);

          It('Should fail if a null handle is passed', procedure
            begin
              ExpectFailure(IsOverride(0, @b));
            end);
        end);

      Describe('IsWinningOverride', procedure
        begin
          It('Should return true for records with no overrides', procedure
            begin
              TestIsWinningOverride(kw1, True);
            end);

          It('Should return false for losing master records', procedure
            begin
              TestIsWinningOverride(ar1, False);
            end);

          It('Should return false for losing override records', procedure
            begin
              TestIsWinningOverride(ar2, False);
              TestIsWinningOverride(kw2, False);
            end);

          It('Should return true for winning override records', procedure
            begin
              TestIsWinningOverride(ar3, True);
              TestIsWinningOverride(kw3, True);
            end);

          It('Should fail on elements that are not records', procedure
            begin
              ExpectFailure(IsWinningOverride(skyrim, @b));
              ExpectFailure(IsWinningOverride(armo, @b));
              ExpectFailure(IsWinningOverride(dnam, @b));
            end);

          It('Should fail if a null handle is passed', procedure
            begin
              ExpectFailure(IsWinningOverride(0, @b));
            end);
        end);

      Describe('GetRecordDef', procedure
        begin
          It('Should return a handle if signature is valid', procedure
            begin
              ExpectSuccess(GetRecordDef('ARMO', @h));
              ExpectSuccess(Release(h));
              ExpectSuccess(GetRecordDef('REFR', @h));
              ExpectSuccess(Release(h));
            end);

          It('Should fail is signature is invalid', procedure
            begin
              ExpectFailure(GetRecordDef('ABCD', @h));
            end);
        end);

      Describe('GetNodes', procedure
        begin
          It('Should return a handle if argument is record', procedure
            begin
              ExpectSuccess(GetNodes(kw1, @n1));
              ExpectSuccess(ReleaseNodes(n1));
            end);

          It('Should work with records with overrides', procedure
            begin
              ExpectSuccess(GetNodes(ar1, @n1));
              ExpectSuccess(ReleaseNodes(n1));
            end);

          It('Should work with file headers', procedure
            begin
              ExpectSuccess(GetElement(skyrim, 'File Header', @h));
              ExpectSuccess(GetNodes(h, @n1));
              ExpectSuccess(ReleaseNodes(n1));
            end);

          It('Should work with union defs', procedure
            begin
              ExpectSuccess(GetElement(0, 'Update.esm\0100080E', @h));
              ExpectSuccess(GetNodes(h, @n1));
              ExpectSuccess(ReleaseNodes(n1));
            end);

          It('Should fail on elements that are not records', procedure
            begin
              ExpectFailure(GetNodes(skyrim, @n1));
              ExpectFailure(GetNodes(armo, @n1));
              ExpectFailure(GetNodes(dnam, @n1));
            end);

          It('Should fail if a null handle is passed', procedure
            begin
              ExpectFailure(GetNodes(0, @n1));
            end);
        end);

      Describe('GetConflictData', procedure
        begin
          BeforeAll(procedure
            begin
              ExpectSuccess(GetNodes(kw1, @n1));
              ExpectSuccess(GetNodes(kw2, @n2));
              ExpectSuccess(GetNodes(ar1, @n3));
            end);

          It('Should work on main records', procedure
            begin
              TestGetConflictData(n1, kw1, '', caOnlyOne, ctOnlyOne);
              TestGetConflictData(n2, kw2, '', caConflictCritical, ctMaster);
              TestGetConflictData(n3, ar1, '', caConflict, ctMaster);
            end);

          It('Should work on struct elements', procedure
            begin
              TestGetConflictData(n1, kw1, 'Record Header', caOnlyOne, ctOnlyOne);
              TestGetConflictData(n2, kw2, 'Record Header', caNoConflict, ctMaster);
              TestGetConflictData(n3, ar1, 'Record Header', caNoConflict, ctMaster);
              TestGetConflictData(n2, kw2, 'CNAM - Color', caConflictCritical, ctMaster);
              TestGetConflictData(n3, ar1, 'OBND - Object Bounds', caConflict, ctMaster);
            end);

          It('Should work on value elements', procedure
            begin
              TestGetConflictData(n1, kw1, 'Record Header\Signature', caOnlyOne, ctOnlyOne);
              TestGetConflictData(n2, kw2, 'Record Header\Signature', caNoConflict, ctMaster);
              TestGetConflictData(n3, ar1, 'Record Header\Signature', caNoConflict, ctMaster);
              TestGetConflictData(n2, kw2, 'CNAM - Color\Red', caConflictCritical, ctMaster);
              TestGetConflictData(n3, ar1, 'OBND - Object Bounds\X1', caConflict, ctMaster);
            end);

          It('Should work on file headers', procedure
            begin
              ExpectSuccess(GetElement(skyrim, 'File Header', @h));
              ExpectSuccess(GetNodes(h, @n1));
              TestGetConflictData(n1, h, 'CNAM - Author', caOnlyOne, ctOnlyOne);
              TestGetConflictData(n1, h, 'HEDR - Header\Version', caOnlyOne, ctOnlyOne);
            end);
        end);
    end);
end;

end.
