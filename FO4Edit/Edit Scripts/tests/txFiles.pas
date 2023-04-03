unit txFiles;

interface

uses
  SysUtils;

  // PUBLIC TESTING INTERFACE
  procedure BuildFileHandlingTests;

implementation

uses
  Mahogany,
  txMeta,
{$IFDEF USE_DLL}
  txImports;
{$ENDIF}
{$IFNDEF USE_DLL}
  xeMeta, xeFiles, xeElements, xeSetup;
{$ENDIF}

procedure TestMD5Hash(fileName: PWideChar; expectedHash: String);
var
  f: Cardinal;
  len: Integer;
begin
  ExpectSuccess(FileByName(fileName, @f));
  ExpectSuccess(MD5Hash(f, @len));
  ExpectEqual(grs(len), expectedHash);
end;

procedure TestCRCHash(fileName: PWideChar; expectedHash: String);
var
  f: Cardinal;
  len: Integer;
begin
  ExpectSuccess(FileByName(fileName, @f));
  ExpectSuccess(CRCHash(f, @len));
  ExpectEqual(grs(len), expectedHash);
end;

procedure TestSaveFile(fileName: PWideChar; customPath: String = '');
var
  filePath: String;
  h: Cardinal;
begin
  if customPath <> '' then
    filePath := customPath
  else
    filePath := GetDataPath + fileName + '.save';
  if FileExists(filePath) then
    DeleteFile(filePath);
  ExpectSuccess(FileByName(fileName, @h));
  ExpectSuccess(SaveFile(h, PWideChar(customPath)));
  Expect(FileExists(filePath), 'Plugin file not found at "' + filePath + '"');
end;

procedure BuildFileHandlingTests;
var
  h: Cardinal;
  len, count: Integer;
begin
  Describe('File Handling Functions', procedure
    begin
      Describe('FileByName', procedure
        begin
          It('Should return a handle if a matching file is loaded', procedure
            begin
              ExpectSuccess(FileByName('Skyrim.esm', @h));
              Expect(h > 0, 'Handle should be greater than 0');
            end);

          It('Should return return false if a matching file is not loaded', procedure
            begin
              ExpectFailure(FileByName('NonExistingFile.esp', @h));
            end);
        end);

      Describe('FileByIndex', procedure
        begin
          It('Should return a handle if the index is in bounds', procedure
            begin
              ExpectSuccess(FileByIndex(1, @h));
              Expect(h > 0, 'Handle should be greater than 0');
            end);

          It('Should return false if index is out of bounds', procedure
            begin
              ExpectFailure(FileByIndex(999, @h));
            end);
        end);

      Describe('FileByLoadOrder', procedure
        begin
          It('Should return a handle if the index is in bounds', procedure
            begin
              ExpectSuccess(FileByLoadOrder(1, @h));
              Expect(h > 0, 'Handle should be greater than 0');
            end);

          It('Should return return false if index is out of bounds', procedure
            begin
              ExpectFailure(FileByLoadOrder(999, @h));
            end);
        end);

      Describe('FileByAuthor', procedure
        begin
          It('Should return a handle if a matching file is loaded', procedure
            begin
              ExpectSuccess(FileByAuthor('mcarofano', @h));
              Expect(h > 0, 'Handle should be greater than 0');
            end);

          It('Should return return false if a matching file is not loaded', procedure
            begin
              ExpectFailure(FileByAuthor('U. N. Owen', @h));
            end);
        end);

      Describe('GetOverrideRecordCount', procedure
        begin
          It('Should return an integer > 0 for a plugin with overrides', procedure
            begin
              ExpectSuccess(FileByName('Update.esm', @h));
              ExpectSuccess(GetOverrideRecordCount(h, @count));
              Expect(count > 0, 'Should be greater than 0 for Update.esm');
            end);

          It('Should return 0 for a plugin with no records', procedure
            begin
              ExpectSuccess(FileByName('xtest-5.esp', @h));
              ExpectSuccess(GetOverrideRecordCount(h, @count));
              ExpectEqual(count, 0);
            end);
        end);

      {$IFNDEF WIN64}
      Describe('MD5Hash', procedure
        begin
          It('Should return the MD5 Hash of a file', procedure
            begin
              TestMD5Hash('xtest-1.esp', '3f4b772ce1a525e65f88ed8a789fb464');
              TestMD5Hash('xtest-2.esp', '43f5edb9430744d2c4928a4ab77c3da9');
              TestMD5Hash('xtest-3.esp', '9e9ff3b83db35bf4034dc76bf3494939');
              TestMD5Hash('xtest-4.esp', 'a79cfd017bdd0482d6870c0a8f170fde');
              TestMD5Hash('xtest-5.esp', '009c98d373424ae73cc26eae31c13193');
            end);

          It('Should fail if interface is not a file', procedure
            begin
              ExpectFailure(MD5Hash(0, @len));
            end);
        end);

      Describe('CRCHash', procedure
        begin
          It('Should return the CRC32 Hash of a file', procedure
            begin
              TestCRCHash('xtest-1.esp', 'F3806FAE');
              TestCRCHash('xtest-2.esp', '19829D28');
              TestCRCHash('xtest-3.esp', '0F0247D8');
              TestCRCHash('xtest-4.esp', '45A2BE28');
              TestCRCHash('xtest-5.esp', 'AD34E5F4');
            end);

          It('Should fail if interface is not a file', procedure
            begin
              ExpectFailure(CRCHash(0, @len));
            end);
        end);
      {$ENDIF}

      Describe('AddFile', procedure
        begin
          BeforeAll(procedure
            begin
              CopyPlugins(['xtest-6.esp']);
            end);

          AfterAll(procedure
            var
              i: Integer;
            begin
              for i := 254 downto 0 do
                if FileByName(PWideChar(IntToStr(i) + '.esp'), @h) then
                  ExpectSuccess(UnloadPlugin(h))
                else
                  Break;
              ExpectSuccess(FileByName('xtest-6.esp', @h));
              ExpectSuccess(UnloadPlugin(h));
              ExpectSuccess(FileByName('abc.esp', @h));
              ExpectSuccess(UnloadPlugin(h));
              DeletePlugins(['xtest-6.esp']);
            end);

          It('Should return true if it succeeds', procedure
            begin
              ExpectSuccess(AddFile('abc.esp', False, @h));
            end);

          It('Should return false if the file is already loaded', procedure
            begin
              ExpectFailure(AddFile('Skyrim.esm', False, @h));
            end);

          It('Should return false if the file exists and ignoreExists is false', procedure
            begin
              ExpectFailure(AddFile('xtest-6.esp', False, @h));
            end);

          It('Should return true if the file exists and ignoreExists is true', procedure
            begin
              ExpectSuccess(AddFile('xtest-6.esp', True, @h));
            end);

          It('Should return false if the load order is already full', procedure
            var
              i, start: Integer;
            begin
              ExpectSuccess(GetGlobal('FileCount', @len));
              start := StrToInt(grs(len));
              for i := start to 254 do
                ExpectSuccess(AddFile(PWideChar(IntToStr(i) + '.esp'), False, @h));
              ExpectFailure(AddFile('255.esp', False, @h));
            end);
        end);

      Describe('SaveFile', procedure
        begin
          BeforeAll(procedure
            begin
              ExpectSuccess(AddFile('xtest-6.esp', False, @h));
            end);

          AfterAll(procedure
            begin
              ExpectSuccess(FileByName('xtest-6.esp', @h));
              ExpectSuccess(UnloadPlugin(h));
            end);

          It('Should save new files', procedure
            begin
              TestSaveFile('xtest-6.esp');
            end);

          It('Should save files at custom paths', procedure
            begin
              TestSaveFile('xtest-6.esp', 'E:\xtest-6.esp');
            end);

          It('Should save existing files', procedure
            begin
              TestSaveFile('xtest-5.esp');
            end);

          It('Should fail if interface is not a file', procedure
            begin
              ExpectSuccess(GetElement(0, 'xtest-2.esp\00012E46', @h));
              ExpectFailure(SaveFile(h, ''));
            end);

          It('Should fail if the handle is invalid', procedure
            begin
              ExpectFailure(SaveFile(999, ''));
            end);
        end);
    end);
end;

end.
