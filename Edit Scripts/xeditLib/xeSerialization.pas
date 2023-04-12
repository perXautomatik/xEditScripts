unit xeSerialization;

interface

uses
  Argo, ArgoTypes,
  wbInterface;

  {$region 'Native functions'}
  procedure JsonToElement(const element: IwbElement; obj: TJSONObject; const path: String);
  procedure JsonToElements(const container: IwbContainerElementRef; obj: TJSONObject; const excludedPaths: array of string);
  procedure JsonToGroup(const group: IwbGroupRecord; obj: TJSONObject); overload;
  procedure JsonToGroup(const group: IwbGroupRecord; obj: TJSONObject; const key: String); overload;
  function NativeElementToJson(const element: IwbElement): TJSONValue;
  function GroupToJson(const group: IwbGroupRecord; obj: TJSONObject): TJSONObject;
  function ElementDefToJSON(def: IwbNamedDef): TJSONValue;
  {$endregion}

  {$region 'API functions'}
  function ElementToJson(_id: Cardinal; len: PInteger): WordBool; cdecl;
  function ElementFromJson(_id: Cardinal; path: PWideChar; json: PWideChar): WordBool; cdecl;
  function DefToJson(_id: Cardinal; len: PInteger): WordBool; cdecl;
  {$endregion}

implementation

uses
  Variants, SysUtils, StrUtils,
  wbImplementation,
  xeMeta, xeFiles, xeElements, xeElementValues, xeMessages;

{$region 'Native functions'}
{$region 'ElementToJSON helpers'}
function ValueToJson(const element: IwbElement): TJSONValue;
var
  v: Variant;
  ref: IwbMainRecord;
  n: Int64;
  vt: TVarType;
begin
  Result := TJSONValue.Create;
  if IsFormID(element) and Supports(element.LinksTo, IwbMainRecord, ref) then begin
    if ref.ElementExists['EDID'] then
      Result.Put(ref.ElementEditValues['EDID'])
    else
      Result.Put(IntToHex(element.NativeValue, 8));
  end
  else begin
    v := element.NativeValue;
    vt := VarType(v);
    case vt of
      varByte, varSmallint, varInteger, varInt64, varWord, varLongWord: begin
        n := v;
        Result.Put(n);
      end;
      varSingle, varDouble:
        Result.Put(Double(v));
      varBoolean:
        Result.Put(Boolean(v));
      varUString:
        Result.Put(String(v));
    else // byte array
      Result.Put(element.EditValue);
    end;
  end;
end;

function StructToJson(const container: IwbContainerElementRef): TJSONValue;
var
  obj: TJSONObject;
  i: Integer;
  childElement: IwbElement;
begin
  Result := TJSONValue.Create;
  obj := TJSONObject.Create;
  for i := 0 to Pred(container.ElementCount) do begin
    childElement := container.Elements[i];
    obj[childElement.Name] := NativeElementToJson(childElement);
  end;
  Result.Put(obj);
end;

function ArrayToJson(const container: IwbContainerElementRef): TJSONValue;
var
  ary: TJSONArray;
  i: Integer;
begin
  Result := TJSONValue.Create;
  ary := TJSONArray.Create;
  for i := 0 to Pred(container.ElementCount) do
    ary.AddValue(NativeElementToJson(container.Elements[i]));
  Result.Put(ary);
end;

function NativeElementToJson(const element: IwbElement): TJSONValue;
var
  container: IwbContainerElementRef;
begin
  if Supports(element, IwbContainerElementRef, container)
  and ((container.ElementCount > 0) or NativeIsFlags(element)) then begin
    if IsArray(element) then
      Result := ArrayToJson(container)
    else
      Result := StructToJson(container);
  end
  else
    Result := ValueToJSON(element);
end;

function RecordHeaderToJSON(const recHeader: IwbElement): TJSONObject;
var
  container: IwbContainerElementRef;
  flags: IwbElement;
  formID: Cardinal;
begin
  Result := TJSONObject.Create;
  if not Supports(recHeader, IwbContainerElementRef, container) then
    raise Exception.Create('Failed to serialize record header.');
  // serialize record header elements
  Result.S['Signature'] := container.ElementEditValues['Signature'];
  flags := container.ElementByPath['Record Flags'];
  Result['Record Flags'] := StructToJSON(flags as IwbContainerElementRef);
  formID := container.ElementNativeValues['FormID'];
  Result.S['FormID'] := IntToHex(formID, 8);
end;

function RecordToJson(const rec: IwbMainRecord): TJSONObject;
var
  container: IwbContainerElementRef;
  i: Integer;
  element: IwbElement;
  path: String;
  recHeaderProcessed: Boolean;
begin
  Result := TJSONObject.Create;
  recHeaderProcessed := False;
  // serialize elements
  if not Supports(rec, IwbContainerElementRef, container) then
    raise Exception.Create('Failed to serialize record.');
  for i := 0 to Pred(container.ElementCount) do begin
    element := container.Elements[i];
    path := element.Name;
    if (not recHeaderProcessed) and (path = 'Record Header') then begin
      recHeaderProcessed := true;
      Result.O[path] := RecordHeaderToJSON(element);
    end
    else
      Result[path] := NativeElementToJSON(element);
  end;
  // serialize child group
  if Assigned(rec.ChildGroup) then
    GroupToJson(rec.ChildGroup, Result);
end;

function GroupToJson(const group: IwbGroupRecord; obj: TJSONObject): TJSONObject;
var
  name: String;
  i: Integer;
  rec: IwbMainRecord;
  innerGroup: IwbGroupRecord;
  records: TJSONArray;
  groups: TJSONObject;
begin
  Result := obj;
  records := TJSONArray.Create;
  groups := TJSONObject.Create;
  // iterate through children
  for i := 0 to Pred(group.ElementCount) do begin
    if Supports(group.Elements[i], IwbMainRecord, rec) then
      records.Add(RecordToJson(rec))
    else if Supports(group.Elements[i], IwbGroupRecord, innerGroup)
    and not (innerGroup.GroupType in [1, 6..7]) then
      GroupToJson(innerGroup, groups);
  end;
  // assign objects
  name := GetPathName(group as IwbElement);
  if groups.Count = 0 then begin
    groups.Free;
    obj.A[name] := records;
  end
  else begin
    obj.O[name] := groups;
    if records.Count > 1 then
      obj.O[name].A['Records'] := records
    else
      records.Free;
  end;
end;

function FileToJson(const _file: IwbFile): TJSONObject;
var
  group: IwbGroupRecord;
  i: Integer;
begin
  Result := TJSONObject.Create;
  // serialize filename and header
  Result.S['Filename'] := _file.FileName;
  Result.O['File Header'] := RecordToJson(_file.Header);
  // serialize groups
  Result.O['Groups'] := TJSONObject.Create;
  for i := 1 to Pred(_file.ElementCount) do
    if Supports(_file.Elements[i], IwbGroupRecord, group) then
      GroupToJson(group, Result.O['Groups']);
end;
{$endregion}

{$region 'ElementFromJSON helpers'}
function AddElementIfMissing(const container: IwbContainerElementRef; const path: String): IwbElement;
begin
  Result := container.ElementByPath[path];
  if not Assigned(Result) then
    Result := container.Add(path);
end;

function AssignElementIfMissing(const container: IwbContainerElementRef; index: Integer): IwbElement;
begin
  if container.ElementCount > index then
    Result := container.Elements[index]
  else
    Result := container.Assign(High(integer), nil, False);
end;

procedure JsonToArrayElement(const element: IwbElement; ary: TJSONArray; index: Integer);
var
  v: TJSONValue;
begin
  v := ary[index];
  case v.JSONValueType of
    jtInt, jtBoolean, jtDouble:
      element.NativeValue := v.AsVariant;
    jtString:
      element.EditValue := v.AsString;
    jtObject:
      JsonToElement(element, v.AsObject, '');
  end;
end;

procedure JsonToFlags(const element: IwbElement; const flagsDef: IwbFlagsDef; obj: TJSONObject);
var
  flagVal: UInt64;
  i, index: Integer;
  flagName: String;
begin
  flagVal := 0;
  for i := 0 to Pred(obj.Count) do begin
    flagName := obj.Keys[i];
    index := IndexOfFlag(flagsDef, flagName);
    flagVal := flagVal or (1 shl index);
  end;
  element.NativeValue := flagVal;
end;

procedure JsonToElement(const element: IwbElement; obj: TJSONObject; const path: String);
var
  container: IwbContainerElementRef;
  childElement: IwbElement;
  ary: TJSONArray;
  i: Integer;
  v: TJSONValue;
  flagsDef: IwbFlagsDef;
begin
  if not Assigned(element) or not Assigned(obj) then
    exit;
  if GetFlagsDef(element, flagsDef) then
    JsonToFlags(element, flagsDef, obj.O[path])
  else if Supports(element, IwbContainerElementRef, container)
  and (container.ElementCount > 0) then begin
    if IsArray(element) then begin
      ary := obj.A[path];
      for i := 0 to Pred(ary.Count) do begin
        childElement := AssignElementIfMissing(container, i);
        JsonToArrayElement(childElement, ary, i);
      end;
    end
    else
      JsonToElements(container, obj.O[path], []);
  end
  else begin
    v := obj[path];
    case v.JSONValueType of
      jtInt, jtBoolean, jtDouble:
        element.NativeValue := v.AsVariant;
      jtString:
        SetElementValue(element, v.AsString);
    end;
  end;
end;

procedure JsonToElements(const container: IwbContainerElementRef; obj: TJSONObject; const excludedPaths: array of string);
var
  element: IwbElement;
  path: string;
  i: Integer;
begin
  for i := 0 to Pred(obj.Count) do begin
    path := obj.Keys[i];
    if MatchStr(path, excludedPaths) then continue;
    element := CreateFromContainer(container, path) as IwbElement;
    JsonToElement(element, obj, path);
  end;
end;

function GetObjSignature(obj: TJSONObject; var signature: String): Boolean;
begin
  Result := obj.HasKey('Signature');
  if Result then
    signature := obj.S['Signature'];
end;

function GetObjFormID(obj: TJSONObject; var formID: Cardinal): Boolean;
var
  v: TJSONValue;
begin
  Result := obj.HasKey('FormID');
  if Result then begin
    v := obj['FormID'];
    case v.JSONValueType of
      jtInt: formID := v.AsVariant;
      jtString: formID := StrToInt('$' + v.AsString);
      else
        Result := false;
    end;
  end;
end;

procedure JsonToRecordHeader(const header: IwbElement; obj: TJSONObject);
var
  container: IwbContainerElementRef;
  recordSig, objSig: String;
  recordFormID, objFormID: Cardinal;
begin
  if not Supports(header, IwbContainerElementRef, container)
  or not Assigned(obj) then
    exit;
  // raise exception if signature does not match
  recordSig := container.ElementEditValues['Signature'];
  if GetObjSignature(obj, objSig) and (recordSig <> objSig) then
    raise Exception.Create(Format('Error deserializing record header: record ' +
      'signatures do not match, %s != %s', [recordSig, objSig]));
  // set load order formID if different
  recordFormID := container.ElementNativeValues['FormID'];
  if GetObjFormID(obj, objFormID) and (recordFormID <> objFormID) then
    header.ContainingMainRecord.SetLoadOrderFormID(objFormID);
  // assign to whitelisted paths
  JsonToElements(container, obj, ['Signature', 'Data Size', 'FormID', 'Form Version']);
end;

procedure JsonToRecord(const rec: IwbMainRecord; obj: TJSONObject);
var
  i: Integer;
  path: String;
  e: IInterface;
  element: IwbElement;
  group: IwbGroupRecord;
begin
  // deserialize header
  JsonToRecordHeader(rec.ElementByPath['Record Header'], obj.O['Record Header']);
  // deserialize elements
  for i := 0 to Pred(obj.Count) do begin
    path := obj.Keys[i];
    if path = 'Record Header' then continue;
    e := CreateFromRecord(rec, path);
    if Supports(e, IwbGroupRecord, group) then
      JsonToGroup(group, obj, path)
    else if Supports(e, IwbElement, element) then
      JsonToElement(element, obj, path);
  end;
end;

function GetObjString(obj: TJSONObject; const key: String; var value: String): Boolean;
begin
  Result := obj.HasKey(key);
  if Result then
    value := obj.S[key];
end;

function GetRecordKey(recObj: TJSONObject; var allowOverride: Boolean): String;
var
  recHeader: TJSONObject;
  v: TJSONValue;
  str: String;
begin
  Result := '';
  allowOverride := false;
  recHeader := recObj.O['Record Header'];
  if Assigned(recHeader) and recHeader.HasKey('FormID') then begin
    v := recHeader['FormID'];
    allowOverride := true;
    case v.JSONValueType of
      jtInt: Result := IntToHex(v.AsVariant, 8);
      jtString: Result := v.AsString;
    end;
  end
  else if GetObjString(recObj, 'EDID - Editor ID', str)
  or GetObjString(recObj, 'EDID', str) then
    Result := str
  else if GetObjString(recObj, 'FULL - Name', str)
  or GetObjString(recObj, 'FULL', str) then
    Result := '"' + str + '"';
end;

function GetAddSignature(obj: TJSONObject; const group: IwbGroupRecord): String;
var
  recHeader: TJSONObject;
begin
  recHeader := obj.O['Record Header'];
  if Assigned(recHeader) and recHeader.HasKey('Signature') then
    Result := recHeader.S['Signature']
  else begin
    case group.GroupType of
      0: Result := String(TwbSignature(group.GroupLabel));
      1,2,3: Result := 'CELL';
      else
        raise Exception.Create('Failed to determine add signature when deserializing: ' + Copy(obj.ToString, 1, 20) + '...');
    end;
  end;
end;

procedure JsonToRecords(const group: IwbGroupRecord; ary: TJSONArray);
var
  recObj: TJSONObject;
  key, sig: String;
  allowOverride: Boolean;
  e: IwbElement;
  rec: IwbMainRecord;
  i: Integer;
begin
  // loop through array of records
  for i := 0 to Pred(ary.Count) do begin
    recObj := ary.O[i];
    key := GetRecordKey(recObj, allowOverride);
    // attempt to resolve existing record if resolution key found
    if key <> '' then
      e := ResolveGroupOrRecord(group, key, '') as IwbElement;
    // override record if it is not in the correct file and
    // it was found by formID
    if Assigned(e) and not e._File.Equals(group._File) then begin
      if allowOverride then
        e := CopyElementToFile(e, group._File, false, true)
      else
        e := nil;
    end;
    // create record if not found
    if not Assigned(e) then begin
      sig := GetAddSignature(recObj, group);
      e := group.Add(sig) as IwbElement;
    end;
    // deserialize record JSON
    if Supports(e, IwbMainRecord, rec) then
      JsonToRecord(rec, recObj);
  end;
end;

procedure JsonToGroup(const group: IwbGroupRecord; obj: TJSONObject); overload;
var
  i: Integer;
  key: String;
  innerGroup: IwbGroupRecord;
begin
  for i := 0 to Pred(obj.Count) do begin
    key := obj.Keys[i];
    if key = 'Records' then
      JsonToRecords(group, obj.A['Records'])
    else begin
      innerGroup := CreateGroupOrRecord(group, key, '') as IwbGroupRecord;
      if not Assigned(innerGroup) then
        raise Exception.Create('Failed to resolve inner group ' + key);
      JsonToGroup(innerGroup, obj, key);
    end;
  end;
end;

procedure JsonToGroup(const group: IwbGroupRecord; obj: TJSONObject; const key: String); overload;
var
  v: TJSONValue;
begin
  v := obj[key];
  if v.JSONValueType = jtArray then
    JsonToRecords(group, v.AsArray)
  else
    JsonToGroup(group, v.AsObject);
end;

procedure JsonToFileHeader(const header: IwbMainRecord; obj: TJSONObject);
const
  ExcludedPaths: array[0..3] of string = (
    'Record Header',
    'HEDR - Header',
    'Master Files',
    'ONAM - Overridden Forms' // may be able to include?
  );
var
  container: IwbContainerElementRef;
  _file: IwbFile;
  ary: TJSONArray;
  i: Integer;
begin
  if not Supports(header, IwbContainerElementRef, container)
  or not Assigned(obj) then
    exit;
  // add masters
  _file := header._File;
  ary := obj.A['Master Files'];
  if Assigned(ary) then
    for i := 0 to Pred(ary.Count) do
      _file.AddMasterIfMissing(ary.O[i].S['MAST - Filename']);
  // set record header and element values
  JsonToRecordHeader(header.ElementByPath['Record Header'], obj.O['Record Header']);
  JsonToElements(container, obj, ExcludedPaths);
end;

procedure JsonToFile(const _file: IwbFile; obj: TJSONObject);
var
  groups: TJSONObject;
  group: IwbGroupRecord;
  signature: string;
  i: Integer;
begin
  // deserialize header
  JsonToFileHeader(_file.Header, obj.O['File Header']);
  // deserialize groups
  groups := obj.O['Groups'];
  if Assigned(groups) then
    for i := 0 to Pred(groups.Count) do begin
      signature := groups.Keys[i];
      group := AddGroupIfMissing(_file, signature);
      JsonToGroup(group, groups, signature);
    end;
end;

procedure JsonToFiles(obj: TJSONObject);
var
  i: Integer;
  _file: IwbFile;
  fileName: String;
begin
  for i := 0 to Pred(obj.Count) do begin
    fileName := obj.Keys[i];
    _file := CreateFile(fileName, '') as IwbFile;
    JsonToFile(_file, obj.O[fileName]);
  end;
end;
{$endregion}

{$region 'GetRecordDefJSON helpers'}
procedure AddChildDef(a: TJSONArray; def: IwbNamedDef);
var
  name: String;
  i: Integer;
begin
  name := def.Name;
  for i := 0 to Pred(a.Count) do
    if a.O[i].S['name'] = name then
      exit;
  a.AddValue(ElementDefToJSON(def));
end;

procedure ChildDefsToJSON(def: IwbNamedDef; a: TJSONArray; bAllowDuplicates: Boolean = True);
var
  i: Integer;
  subDef: IwbSubRecordDef;
  unionDef: IwbUnionDef;
  structDef: IwbStructDef;
  intDef: IwbIntegerDefFormaterUnion;
  recDef: IwbRecordDef;
  sraDef: IwbSubRecordArrayDef;
  aDef: IwbArrayDef;
begin
  if Supports(def, IwbSubRecordDef, subDef) then
    def := subDef.Value;

  if Supports(def, IwbRecordDef, recDef) then begin
    for i := 0 to Pred(recDef.MemberCount) do
      ChildDefsToJSON(recDef.Members[i] as IwbNamedDef, a, False);
  end
  else if Supports(def, IwbUnionDef, unionDef) then begin
    for i := 0 to Pred(unionDef.MemberCount) do
      AddChildDef(a, unionDef.Members[i] as IwbNamedDef);
  end
  else if Supports(def, IwbStructDef, structDef) then begin
    for i := 0 to Pred(structDef.MemberCount) do
      AddChildDef(a, structDef.Members[i] as IwbNamedDef);
  end
  else if Supports(def, IwbIntegerDefFormaterUnion, intDef) then begin
    for i := 0 to Pred(intDef.MemberCount) do
      AddChildDef(a, intDef.Members[i] as IwbNamedDef);
  end
  else if Supports(def, IwbSubRecordArrayDef, sraDef) then
    AddChildDef(a, sraDef.Element as IwbNamedDef)
  else if Supports(def, IwbArrayDef, aDef) then
    AddChildDef(a, aDef.Element as IwbNamedDef);
end;

function ElementDefToJSON(def: IwbNamedDef): TJSONValue;
var
  obj: TJSONObject;
  elements: TJSONArray;
  sigDef: IwbSignatureDef;
  i: Integer;
  v: TJSONValue;
begin
  obj := TJSONObject.Create;
  obj.S['name'] := def.Name;
  if Supports(def, IwbSignatureDef, sigDef) then begin
    obj.A['signatures'] := TJSONArray.Create;
    for i := 0 to Pred(sigDef.SignatureCount) do begin
      v := TJSONValue.Create;
      v.Put(sigDef.Signatures[i]);
      obj.A['signatures'].AddValue(v);
    end;
  end;
  obj.I['type'] := Ord(GetSmashTypeFromDef(def));
  elements := TJSONArray.Create;
  ChildDefsToJSON(def, elements);
  if elements.Count > 0 then
    obj.A['elements'] := elements;
  Result := TJSONValue.Create;
  Result.Put(obj);
end;

function RecordDefToJSON(recDef: IwbRecordDef): TJSONValue;
var
  obj: TJSONObject;
  elements: TJSONArray;
  i: Integer;
  def: IwbNamedDef;
begin
  obj := TJSONObject.Create;
  obj.S['name'] := recDef.Name;
  elements := TJSONArray.Create;
  for i := 0 to Pred(recDef.MemberCount) do
    if Supports(recDef.Members[i], IwbNamedDef, def)  then
      elements.AddValue(ElementDefToJSON(def));
  obj.A['elements'] := elements;
  Result := TJSONValue.Create;
  Result.Put(obj);
end;
{$endregion}
{$endregion}

{$region 'API functions'}
function ElementToJson(_id: Cardinal; len: PInteger): WordBool; cdecl;
var
  e: IInterface;
  _file: IwbFile;
  group: IwbGroupRecord;
  rec: IwbMainRecord;
  element: IwbElement;
  obj: TJSONObject;
begin
  Result := False;
  try
    e := Resolve(_id);
    obj := nil;
    // convert input element to JSONObject
    if Supports(e, IwbFile, _file) then
      obj := FileToJson(_file)
    else if Supports(e, IwbGroupRecord, group) then
      obj := GroupToJson(group, TJSONObject.Create)
    else if Supports(e, IwbMainRecord, rec) then
      obj := RecordToJson(rec)
    else if Supports(e, IwbElement, element) then begin
      obj := TJSONObject.Create;
      obj[element.Name] := NativeElementToJson(element);
    end;
    // serialize JSON to string
    if Assigned(obj) then try
      resultStr := obj.ToString;
      len^ := Length(resultStr);
      Result := True;
    finally
      obj.Free;
    end;
  except
    on x: Exception do ExceptionHandler(x);
  end;
end;

function ElementFromJson(_id: Cardinal; path: PWideChar; json: PWideChar): WordBool; cdecl;
var
  e: IInterface;
  obj: TJSONObject;
  _file: IwbFile;
  group: IwbGroupRecord;
  rec: IwbMainRecord;
  container: IwbContainerElementRef;
begin
  Result := False;
  try
    obj := TJSONObject.Create(json);
    try
      if (_id = 0) and (path = '') then
        JsonToFiles(obj)
      else begin
        e := NativeAddElement(_id, path);
        if Supports(e, IwbFile, _file) then
          JsonToFile(_file, obj)
        else if Supports(e, IwbGroupRecord, group) then
          JsonToGroup(group, obj)
        else if Supports(e, IwbMainRecord, rec) then
          JsonToRecord(rec, obj)
        else if Supports(e, IwbContainerElementRef, container) then
          JsonToElements(container, obj, []);
      end;
    finally
      obj.Free;
    end;
    Result := True;
  except
    on x: Exception do ExceptionHandler(x);
  end;
end;

function DefToJSON(_id: Cardinal; len: PInteger): WordBool; cdecl;
var
  e: IInterface;
  def: IwbNamedDef;
  recordDef: IwbRecordDef;
  v: TJSONValue;
begin
  Result := False;
  try
    e := Resolve(_id);
    if not Supports(e, IwbNamedDef, def) then
      raise Exception.Create('Interface must be an IwbNamedDef.');
    if Supports(def, IwbRecordDef, recordDef) then
      v := RecordDefToJSON(recordDef)
    else
      v := ElementDefToJSON(def);
    if Assigned(v) then try
      resultStr := v.ToString;
      len^ := Length(resultStr);
      Result := True;
    finally
      v.Free;
    end;
  except
    on x: Exception do ExceptionHandler(x);
  end;
end;
{$endregion}

end.
