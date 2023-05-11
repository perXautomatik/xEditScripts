(function|procedure) (?!process|initialize|finalize|main)

function _Serialize(e: IInterface): String;
function _Serialize(e: IInterface): String;
function _Serialize(e: IInterface): String;
function _SerializeArray(e: IInterface): String;
function _SerializeArray(e: IInterface): String;
function _SerializeArray(e: IInterface): String;
function _SerializeBase(e: IInterface): String;
function _SerializeBoolean(e: IInterface): String;
function _SerializeBoolean(e: IInterface): String;
function _SerializeBoolean(e: IInterface): String;
function _SerializeByteArray(e: IInterface): String;
function _SerializeByteArray(e: IInterface): String;
function _SerializeByteArray(e: IInterface): String;
function _SerializeCellRegion(e: IInterface): String;
function _SerializeComment(e: IInterface): String;
function _SerializeComment(e: IInterface): String;
function _SerializeComment(e: IInterface): String;
function _SerializeEmpty(e: IInterface): String;
function _SerializeEmpty(e: IInterface): String;
function _SerializeEmpty(e: IInterface): String;
function _SerializeGlob(e: IInterface): String;
function _SerializeHeader(header, e: IInterface): String;
function _SerializeHeader(header, e: IInterface): String;
function _SerializeHeader(header, e: IInterface): String;
function _SerializeLeveledItems(e: IInterface): String;
function _SerializeLink(e: IInterface): String;
function _SerializeLink(e: IInterface): String;
function _SerializeLink(e: IInterface): String;
function _SerializeMain(e: IInterface): String;
function _SerializeMain(e: IInterface): String;
function _SerializeMain(e: IInterface): String;
function _SerializeName(e: IInterface): String;
function _SerializeName(e: IInterface): String;
function _SerializeName(e: IInterface): String;
function _SerializeNullRef(e: IInterface): String;
function _SerializeNullRef(e: IInterface): String;
function _SerializeNullRef(e: IInterface): String;
function _SerializeNumber(e: IInterface): String;
function _SerializeNumber(e: IInterface): String;
function _SerializeNumber(e: IInterface): String;
function _SerializeObject(e: IInterface): String;
function _SerializeObject(e: IInterface): String;
function _SerializeObject(e: IInterface): String;
function _SerializeSig(e: IInterface): String;
function _SerializeString(e: IInterface): String;
function _SerializeString(e: IInterface): String;
function _SerializeString(e: IInterface): String;
function _SerializeUnknown(e: IInterface): String;
function _SerializeUnknown(e: IInterface): String;
function _SerializeUnknown(e: IInterface): String;

function _tab: String;
function _tab: String;
function _tab: String;

function AbsoluteValue(val: float): float;
function acos(x: float): float;
function acosDeg(x: float): float;
function acosReal(x: float): float;
function Add(aeContainer: IwbContainer; asNameOrSignature: string; abSilent: boolean): IwbElement;
function Add(aeContainer: IwbContainer; asNameOrSignature: string; abSilent: boolean): IwbElement;
function AddElementByString(const r: IInterface; const s: String): IInterface;
function AddElementByString(const r: IInterface; const s: String): IInterface;
function AddGroupBySignature(const f: IwbFile; const s: String): IInterface;
function AddGroupBySignature(const f: IwbFile; const s: String): IInterface;
function AddGroupBySignature(const f: IwbFile; const s: String): IInterface;
function addItem(aRecord: IInterface; aItem: IInterface; aCount: integer): IInterface;
function AdditionalElementCount(aeContainer: IwbContainer): integer;
function AdditionalElementCount(aeContainer: IwbContainer): integer;
function AddKeyword(itemRecord: IInterface; keyword: IInterface): integer;
function AddLogEntry(asTag, asTestName: String; e, m: IInterface): String;
function AddMasterBySignature(Sig: String; patch: IInterface): integer;
function addNewEntry(elem: IInterface; path: string): IInterface;
function AddNewFileName(asFileName: string): IwbFile;
function AddNewFileName(asFileName: string): IwbFile;
function AddNewRecordToGroup(const g: IInterface; const s: String): IInterface;
function AddNewRecordToGroup(const g: IInterface; const s: String): IInterface;
function AddNewRecordToGroup(const g: IInterface; const s: String): IInterface;
function addPerkCondition(aList: IInterface; aPerk: IInterface): IInterface;
function AddRNAM(wrld, e: IInterface): IInterface;
function addScript(e: IInterface; scriptName: String): IInterface;
function addStageItem(targetFile, parentLevel: IInterface; edidBase: string; formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; spawnType, stageStart, stageEnd: integer): IInterface;
function addStageItemReqs(targetFile, parentLevel: IInterface; edidBase: string; formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; spawnType, stageStart, stageEnd, ownerNumber: integer; spawnName: string; reqItem: IInterface): IInterface;
function addToLeveledList(aLeveledList, aRecord: IInterface; aLevel: integer): IInterface;
function AddToLeveledListAuto(templateRecord: IInterface; inputRecord: IInterface; aPlugin: IInterface): String;
function AddToLeveledListWithEntries(e: IInterface): integer;
function AddToLeveledListWithEntries(e: IInterface): integer;
function AddToLeveledListWithoutEntries(e: IInterface): integer;
function AddToLeveledListWithoutEntries(e: IInterface): integer;
function AddToOutfitAuto(templateRecord: IInterface; inputRecord: IInterface; aPlugin: IInterface): String; 
function AdjustCellHeight(cell: IInterface; h: Double): Boolean;
function AllowSign (search, signature: string): boolean; // if not on the list (0) then allow to ...
function AppendElementByString(const r: IInterface; const s: String): IInterface;
function AppendElementByString(const r: IInterface; const s: String): IInterface;
function AppendIfMissing(s1, s2: string): string;
function AppendIfMissing(s1, s2: string): string;
function AppendIfMissing(s1, s2: String): String;
function appendStructToProperty(prop: IInterface): IInterface;
function arccos(x: float): float;
function arcsin(x: float): float;
function arctan(x: float): float;
function asin(x: float): float;
function asinDeg(x: float): float;
function asinReal(x: float): float;
function Assigned(aeElement: IwbElement): boolean; overload;
function Assigned(aeElement: IwbElement): boolean; overload;
function Assigned(aObject: TObject): Boolean; overload;
function Assigned(aObject: TObject): Boolean; overload;
function AssignedBySignature(const x: IInterface; const s: String): Boolean;
function AssignedBySignature(const x: IInterface; const s: String): Boolean;
function AssignElementByString(const r: IInterface; const s: String): IInterface;
function AssignElementByString(const r: IInterface; const s: String): IInterface;
function AssociatedBOD2(aString: String): String;
function AssociatedComponent(s: String; frm: TForm): TObject;
function atan(x: float): float;
function atan2(y, x: float): float;
function atanDeg(x: float): float;
function atanReal(x: float): float;
Function AttachScript(aeForm: IInterface; asName: String; abRedundant: Boolean): IInterface;
Function AxisAngleToEuler(afAxisAngle: TJsonObject): TJsonObject;
function AxisAngleToMatrix(afAxisAngle: TJsonObject): TJsonArray;
Function AxisAngleToQuaternion(afAxisAngle: TJsonObject) : TJsonObject;
function BaseName(aeElement: IwbElement): string;
function BaseName(aeElement: IwbElement): string;
function BasePath(x: IInterface): String;
function BasePath(x: IInterface): String;
function BaseRecord(aeRecord: IwbMainRecord): IwbMainRecord;
function BaseRecord(aeRecord: IwbMainRecord): IwbMainRecord;
function BaseRecordID(aeRecord: IwbMainRecord): cardinal;
function BaseRecordID(aeRecord: IwbMainRecord): cardinal;
function BinToInt(bin: string): cardinal;
function BinToInt(value: String): LongInt;
function BinToInt(value: String): LongInt;
function BookTemplate(bookRecord:IInterface):IInterface;
function BoolToChecked(b: boolean): TCheckBoxState;
function BoolToChecked(b: boolean): TCheckBoxState;
function BoolToStr(b: boolean): string;
function BoolToStr(b: boolean): string;
function BoolToStr(b: boolean): string;
function BoolToStr(b: boolean): string;
Function BoolToStr(value: boolean): string;
Function Btn_ItemTierLevels_OnClick(Sender: TObject): TStringList;
function BuildMenuTree(e: IInterface; aNode: TTreeNode): TTreeNode;
function ButtonCount(x, y, size: Integer; frm, prnt: TObject; caption: String; tag: Integer): TButton;
Function by zilav
function CanContainFormIDs(aeElement: IwbElement): boolean;
function CanContainFormIDs(aeElement: IwbElement): boolean;
function canMasterBeUsed(masterName: string): boolean;
function CanMoveDown(aeElement: IwbElement): boolean;
function CanMoveDown(aeElement: IwbElement): boolean;
function CanMoveUp(aeElement: IwbElement): boolean;
function CanMoveUp(aeElement: IwbElement): boolean;
function canUseMasterForUniversalForm(masterName: string; targetFile: IInterface;): boolean;
function Capitalize(const s: string): string;
function CaptionExists(aString: String; aForm: TObject): Boolean;
function cButton(h, p: TObject; 
function cButton(h, p: TObject; 
function cCheckBox(h, p: TObject; top, left, width: Integer; 
function cCheckBox(h, p: TObject; top, left, width: Integer; 
function cEdit(h, p: TObject; top, left, height, 
function cEdit(h, p: TObject; top, left, height, 
function CellX2px(x: integer): integer;
function CellY2px(y: integer): integer;
function cGroup(h, p: TObject; top, left, height, 
function cGroup(h, p: TObject; top, left, height, 
function Check(aeElement: IwbElement): string;
function Check(aeElement: IwbElement): string;
function CheckDelevRelev(e, m: IInterface): integer;
function CheckEdge(tris: IInterface; tri1, tri2: integer): Boolean;
function CheckEdgeLink(navm1, navm2: IInterface; tri1, tri2: integer): Boolean;
function CheckEditable(e: IInterface): Boolean;
function CheckedToBool(cbs: TCheckBoxState): boolean;
function CheckedToBool(cbs: TCheckBoxState): boolean;
function CheckFactions(e, m: IInterface): integer;
function CheckForErrors(aIndent: Integer; aElement: IInterface): Boolean;
function checkIndirectDependency(e: IInterface): boolean;
function CheckInvent(e, m: IInterface): integer;
function CheckNames(e, m: IInterface): integer;
function ChildGroup(aeRecord: IwbMainRecord): IwbGroupRecord;
function ChildGroup(aeRecord: IwbMainRecord): IwbGroupRecord;
function ChildrenOf(aeGroup: IwbGroupRecord): IwbMainRecord;
function ChildrenOf(aeGroup: IwbGroupRecord): IwbMainRecord;
function cImage(h, p: TObject; top, left, height, 
function cImage(h, p: TObject; top, left, height, 
function cLabel(h, p: TObject; top, left, height, 
function cLabel(h, p: TObject; top, left, height, 
function cMemo(h, p: TObject; top, left, height, 
function cMemo(h, p: TObject; top, left, height, 
function ColorElementToColor(elColor: IInterface): LongWord;
function ColorToInt(red: integer; green: integer; blue: integer): integer;
function ColorToInt(red: integer; green: integer; blue: integer): integer;

function CompareAssignment(asTag: String; e, m: IInterface): Boolean;
function CompareEditValue(asTag: String; e, m: IInterface): Boolean;
function CompareElementCount(asTag: String; e, m: IInterface): Boolean;
function CompareExchangeFormID(aeRecord: IwbMainRecord; aiOldFormID: cardinal; aiNewFormID: cardinal): boolean;
function CompareExchangeFormID(aeRecord: IwbMainRecord; aiOldFormID: cardinal; aiNewFormID: cardinal): boolean;
function CompareFlags(asTag: String; e, m: IInterface; sPath, sFlagName: String; bAddTag, bOperation: Boolean): Boolean;
function CompareFlagsEx(x, y: IInterface; p, f: string): boolean;
function CompareFlagsEx(x, y: IInterface; p, f: string): boolean;
function CompareFlagsOr(x, y: IInterface; p, f: string): boolean;
function CompareFlagsOr(x, y: IInterface; p, f: string): boolean;
function CompareKeys(asTag: String; e, m: IInterface): Boolean;
function CompareKeys(x, y: IInterface; debug: boolean): boolean;
function CompareKeys(x, y: IInterface; debug: boolean): boolean;
function CompareNativeValues(asTag: String; e, m: IInterface; asPath: String): Boolean;
function CompareNativeValues(x, y: IInterface; s: string): boolean;
function CompareNativeValues(x, y: IInterface; s: string): boolean;

function ComponentByCaption(aString: String; aForm: TForm): TObject;
function ComponentByTop(aTop: Integer; aForm: TObject): TObject;

function ConflictAllString(e: IInterface): string;
function ConflictAllString(e: IInterface): string;
function ConflictThisString(e: IInterface): string;
function ConflictThisString(e: IInterface): string;

function ConstructButton(h, p: TObject; 
function ConstructButton(h, p: TObject; 
function ConstructCheckBox(h, p: TObject; top, left, width: Integer; 
function ConstructCheckBox(h, p: TObject; top, left, width: Integer; 
function ConstructEdit(h, p: TObject; top, left, height, 
function ConstructEdit(h, p: TObject; top, left, height, 
function ConstructGroup(h, p: TObject; top, left, height, 
function ConstructGroup(h, p: TObject; top, left, height, 
function ConstructImage(h, p: TObject; top, left, height, 
function ConstructImage(h, p: TObject; top, left, height, 
function ConstructLabel(h, p: TObject; top, left, height, 
function ConstructLabel(h, p: TObject; top, left, height, 
function ConstructLabelEditPair(c: TObject; 
function ConstructLabelEditPair(c: TObject; 
function ConstructMemo(h, p: TObject; top, left, height, 
function ConstructMemo(h, p: TObject; top, left, height, 
function ConstructRadioButton(h, p: TObject; top, left, height, 
function ConstructRadioButton(h, p: TObject; top, left, height, 
function ConstructRadioGroup(h, p: TObject; top, left, height, 
function ConstructRadioGroup(h, p: TObject; top, left, height, 
function ConstructScrollBox(h, p: TObject; height: Integer; 
function ConstructScrollBox(h, p: TObject; height: Integer; 

Function ContainerCountOfItem(aeContainer: IInterface; aeItemBase: IInterface) : Integer;
Function ContainerIsMerchantChest(aeContainer: IInterface): Boolean;
function ContainerStates(aeContainer: IwbContainer): byte;
function ContainerStates(aeContainer: IwbContainer): byte;
function ContainingMainRecord(aeElement: IwbElement): IwbMainRecord;
function ContainingMainRecord(aeElement: IwbElement): IwbMainRecord;
function ContainsTextSL(aList, bList: TStringList): Boolean;

function ConvertAbsoluteCoordinatesToBaseRelative(afParentPosition, afParentRotation, afOffsetPosition, afOffsetRotation: TJsonObject): TJsonObject;
function convertPackedDeskVersion(edidBase: string; oldPackedVersion, newDesk: IInterface): IInterface;
function CopyFromTo(s: string; p1: integer; p2: integer): string;
function CopyFromTo(s: string; p1: integer; p2: integer): string;
Function CopyRecordToFile(aRecord, aFile: IInterface; aBoolean, bBoolean: Boolean): IInterface;
function CopyRecordToPatch(i: integer): IInterface;
function copySCOLToFile(oldScol, fromFile, toFile: IInterface): IInterface;
function cos(x: float): float;
function cosApproximation(x: float): float;
function cosDeg(x: float): float;
function cosReal(x: float): float;

function CountAdd (Sender: TObject): Integer; // change integer in TEdit.text value for + / - button
function CountDuplicatesInTStringList(s: String; l: TStringList): Integer;
function CountDuplicatesInTStringList(s: String; l: TStringList): Integer;
Function CountFurnitureMarkers(aeFurniture: IInterface): Integer;
function CountOccurences( const SubText: string; const Text: string): Integer;
function CountOccurences( const SubText: string; const Text: string): Integer;
function CountOccurences( const SubText: string; const Text: string): Integer;

function cPair(c: TObject; 
function cPair(c: TObject; 
function cRadioButton(h, p: TObject; top, left, height, 
function cRadioButton(h, p: TObject; top, left, height, 
function cRadioGroup(h, p: TObject; top, left, height, 
function cRadioGroup(h, p: TObject; top, left, height, 

function CreateButton(frm: TForm; left: Integer; top: Integer; caption: String): TButton;
function CreateButton(x, y, w, h: Integer; frm, prnt: TObject; caption: String): TButton;
function createChanceLeveledList(aPlugin: IInterface; aName: String; Chance: Integer; aRecord, aLevelList: IInterface): IInterface;
function CreateCheckbox(frm: TForm; left, top: Integer; text: String): TCheckBox;
function CreateCheckBox(x, y, w: Integer; frm, prnt: TObject; option: boolean; caption: String): TCheckBox;
function CreateColorEditor(Parent: TControl; Left, Top: Integer; elColor: IInterface): TPanel;
function CreateComboBox(frm: TForm; left: Integer; top: Integer; width: Integer; items: TStringList): TComboBox;
function CreateComboBox(x, y, w: Integer; frm, prnt: TObject;): TComboBox;
function CreateComboBoxLabel(x, y, w, xOff: Integer; frm, prnt: TObject; caption: String; list: String; tagName: Integer;): TComboBox; // combobox with label, xOff = 0 -> label over field
function CreateComboList(aForm: TForm; aLeft, aTop, aWidth: integer): TComboBox;
function CreateDialog(caption: String; width, height: Integer): TForm;
function CreateElementByPath(e: IInterface; objectPath: string): IInterface;
function createElementOverride(sourceElem: IInterface; targetFile: IwbFile): IInterface;
function CreateEnchantedVersion(aRecord, aPlugin, objEffect, enchRecord: IInterface; suffix: String; enchAmount: Integer; aBoolean: Boolean): IInterface;
Function CreateForm(aeFile: IInterface; asSignature: String; asEditorID: String): IInterface;
function createFoundationCobj(edidBase: string; foundation, oldCobj: IInterface): IInterface;
function CreateGroup(frm: TForm; left: Integer; top: Integer; width: Integer; height: Integer; caption: String): TGroupBox;
function CreateGroup(x, y, w, h: Integer; frm, prnt: TObject; caption: String): TGroupBox;
function createHqRoomConfig(existingElem: IInterface; forHq: IInterface; roomName: string; roomShapeKw: IInterface; roomShapeKwEdid: string; actionGroup: IInterface; primaryDepartment: IInterface; UpgradeSlots: TStringList): IInterface;
function CreateInput(frm: TForm; left, top: Integer; text: String): TEdit;
function CreateInput(x, y, w: Integer; frm, prnt: TObject): TEdit;
function CreateInputLabel(x, y, w, xOff: Integer; frm, prnt: TObject; caption: String; tagName: Integer;): TEdit; // input with label + tag / name, xOff = 0 -> label over field
function CreateInputVal(x, y, w, size: Integer; frm, prnt: TObject; default: String; tag: Integer): TEdit;
function CreateLabel(aForm: TForm; aText: string; aLeft, aTop: integer): TLabel;
function CreateLabel(aParent: TControl; x, y: Integer; aCaption: string): TLabel;
function CreateLabel(aParent: TControl; x, y: Integer; aCaption: string): TLabel;
function CreateLabel(frm: TForm; left, top: Integer; text: String): TLabel;
function CreateLabel(Parent: TControl; Left, Top: Integer; LabelText: string): TLabel;
function CreateLabel(x, y: Integer; frm, prnt: TObject; caption: String): TEdit;
function createLeveledList(aPlugin: IInterface; aName: String; LVLF: TStringList; LVLD: Integer): IInterface;
function CreateListBox(frm: TForm; left: Integer; top: Integer; width: Integer; height: Integer; items: TStringList): TListBox;
function CreateOpenFileDialog(title: string; filter: string = ''; initialDir: string = ''; mustExist:boolean = true): TOpenDialog;
function CreatePanel(x, y, w, h: Integer; frm, prnt: TObject; align: String): TPanel;
function CreateRadioBGroup(x, y, w, h: Integer; frm, prnt: TObject; caption: String): TRadioGroup;
function CreateRadioButton(x, y: Integer; frm, prnt: TObject; option: boolean; caption: String): TRadioButton;
function CreateRadioGroup(frm: TForm; left, top, width, height: Integer; caption: String; items: TStringList): TRadioGroup;
function createRawScriptProp(script: IInterface; propName: String): IInterface;
function createRawStructMember(struct: IInterface; memberName: String): IInterface;
function createRecipe(aRecord, aPlugin: IInterface): IInterface;
function CreateRecord(curRecord: IInterface): IInterface;
function createRecord(recordFile: IwbFile; recordSignature: string): IInterface;
function createReference(cell: IInterface; baseForm: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float): IInterface;
function createRoomLayout(layoutName, csvPath, upgradeNameSpaceless, slotNameSpaceless: string): IInterface;
function createRoomUpgradeActivator(roomUpgradeMisc, forHq, hqManager: IInterface; upgradeName, modelStr: string): IInterface;
function createRoomUpgradeCOBJ(edidBase, descriptionText: string; resourceComplexity: integer; acti, availableGlobal: IInterface; resources: TStringList): IInterface;
function createRoomUpgradeMisc(
function CreateSaveFileDialog(title: string; filter: string = ''; initialDir: string = ''): TSaveDialog;
function createScol(name: string): IInterface;
function createStageItemForm(targetFile: IInterface; edid: string; formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; spawnType: integer; spawnName: string; requirementsItem: IInterface): IInterface;
function CreateStaticText(x, y: Integer; frm, prnt: TObject; sText: String): TStaticText;
function CreateTab(prnt: TObject; caption: String): TTabSheet;
function CreateWorldspaceMap(wrld: IInterface; bmpMap: TBitMap): Boolean;

function cScrollBox(h, p: TObject; height: Integer; 
function cScrollBox(h, p: TObject; height: Integer; 
function DataPath: String;
function DataPath:String;
function debugFindPowerGridItem(powerIndex, powerType: integer; layerArray: IInterface): string;
function DecToRoman(Decimal: Integer): string;
function DefType(aeElement: IwbElement): TwbDefType;
function DefType(aeElement: IwbElement): TwbDefType;
function DefTypeString(e: IInterface): string;
function DefTypeString(e: IInterface): string;
function DegToRad(degrees: float): float;
function DeleteDirectory(src: string; onlyChildren: boolean): boolean;
function DeleteDirectory(src: string; onlyChildren: boolean): boolean;
function DeleteSpaces(Str: string): string;
function DelimitedTextBetween(var sl: TStringList; first, last: integer): string;
function DelimitedTextBetween(var sl: TStringList; first, last: integer): string;
function Diff(lsList1, lsList2: TStringList): TStringList;
function DisplayName(aeElement: IwbElement): string;
function DisplayName(aeElement: IwbElement): string;
function DivisibleBy(x, y: Real): Boolean;
function DivisibleBy(x, y: Real): Boolean;
function DoesFileExist(aPluginName: String): Boolean;
function ebEDID(e: IInterface; s: String): IInterface;
function ebi(e: IInterface; i: integer): IInterface;
function ebi(e: IInterface; i: integer): IInterface;
function ebi(e: IInterface; i: integer): IInterface;
function ebip(e: IInterface; ip: string): IInterface;
function ebip(e: IInterface; ip: string): IInterface;
function ebn(e: IInterface; n: string): IInterface;
function ebn(e: IInterface; n: string): IInterface;
function ebn(e: IInterface; n: string): IInterface;
function ebp(e: IInterface; p: string): IInterface;
function ebp(e: IInterface; p: string): IInterface;
function ebp(e: IInterface; p: string): IInterface;
function ebs(e: IInterface; s: String): IInterface;
function ec(e: IInterface): Integer;
function EditAddedLevelledListEntries(e: IInterface): integer;
function EditAddedLevelledListEntries(e: IInterface): integer;
function EditEditorIDandName(var aEditorID, aName: WideString): Boolean;
function EditorID(aeRecord: IwbMainRecord): string;
function EditorID(aeRecord: IwbMainRecord): string;
function EditRuleForm(var aMesh: string; var aLOD4, aLOD8, aLOD16: integer;
function ee(e: IInterface; s: String): Boolean;

function ElementAssign(aeContainer: IwbContainer; aiIndex: integer; aeSource: IwbElement; abOnlySK: boolean): IwbElement;
function ElementAssign(aeContainer: IwbContainer; aiIndex: integer; aeSource: IwbElement; abOnlySK: boolean): IwbElement;
function ElementByIndex(aeContainer: IwbContainer; aiIndex: integer): IwbElement;
function ElementByIndex(aeContainer: IwbContainer; aiIndex: integer): IwbElement;
function ElementByIP(aElement: IInterface; aIndexedPath: String): IInterface;
function ElementByIP(aElement: IInterface; aIndexedPath: String): IInterface;
function ElementByIP(aElement: IInterface; aIndexedPath: String): IInterface;
function ElementByIP(e: IInterface; ip: string): IInterface;
function ElementByIP(e: IInterface; ip: string): IInterface;
function ElementByName(aeContainer: IwbContainer; asName: string): IwbElement;
function ElementByName(aeContainer: IwbContainer; asName: string): IwbElement;
function ElementByPath(aeContainer: IwbContainer; asPath: string): IwbElement;
function ElementByPath(aeContainer: IwbContainer; asPath: string): IwbElement;
function ElementBySignature(aeContainer: IwbContainer; asSignature: string): IwbElement;
function ElementBySignature(aeContainer: IwbContainer; asSignature: string): IwbElement;
function ElementCount(aeContainer: IwbContainer): integer;
function ElementCount(aeContainer: IwbContainer): integer;
function ElementExists(aeContainer: IwbContainer; asName: string): boolean;
function ElementExists(aeContainer: IwbContainer; asName: string): boolean;
function ElementPath(e: IInterface): string;
function ElementPath(e: IInterface): string;
function ElementsEquivalent(e1, e2: IInterface): boolean;
function ElementType(aeElement: IwbElement): TwbElementType;
function ElementType(aeElement: IwbElement): TwbElementType;
function ElementTypeString(e: IInterface): string;
function ElementTypeString(e: IInterface): string;

Function ELLR_Btn_AddToLeveledList: Boolean;
Function ELLR_Btn_SetTemplate(Sender: TObject): Boolean;
Function ELLR_GeneralSettings: TStringList;
function EnchantItem(item, echt: IInterface; amount: integer; suffix: string): IInterface;
function ensurePath(elem: IInterface; path: string): IInterface;
function ensurePlotSubtype(packedType: integer): integer;
function EnumValues(aeElement: IwbElement): string;
function EnumValues(aeElement: IwbElement): string;
function Equals(aeElement1: IwbElement; aeElement2: IwbElement): boolean;
function Equals(aeElement1: IwbElement; aeElement2: IwbElement): boolean;
function EscapeSlashes(s: String): String;
function EscapeSlashes(s: String): String;
function escapeString(str: string): string;
Function EulerToAxisAngle(afX, afY, afZ: float): TJsonObject;
Function EulerToMatrix(afX, afY, afZ: float): TJsonArray;
function EulerToQuaternion(afX, afY, afZ: float): TJsonObject;
function ExecuteExecuteExecute(aElement: IInterface): Integer;
function ExecuteLODGen: Boolean;
function exportLevelSkin(levelSkin: IInterface; list: TStringList): boolean;
function exportLevelSkinItems(levelSkin: IInterface; list: string): boolean;
function ExportWorldspace(wrld: IInterface): Boolean;
function extactUserTagFromName(objectName: string): string;
function extractInts(inputString: string; intToPull: integer): integer;//tested and works
function extractPlotMainType(packedType: integer): integer;
function extractPlotSize(packedType: integer): integer;
function extractPlotSubtype(packedType: integer): integer;
function FalloutLODMesh(rec: IInterface): string;

function FileByAuthor(s: string): IInterface;
function FileByAuthor(s: string): IInterface;
function FileByIndex(aiFile: integer): IwbFile;
function FileByIndex(aiFile: integer): IwbFile;
function FileByLightLoadOrder(lightLoadOrder: cardinal): IInterface;
function FileByLoadOrder(aiLoadOrder: integer): IwbFile;
function FileByLoadOrder(aiLoadOrder: integer): IwbFile;
function FileByName(AFileName: string): IwbFile;
function FileByName(aPluginName: String): IInterface;
function FileByName(s: string): IInterface;
function FileByName(s: string): IInterface;
function FileByName(s: string): IInterface;
function FileByName(s: String): IInterface;
function FileByRealLoadOrder(loadOrder: cardinal): IInterface;
function FileCount:	Integer;
function FileCount:	Integer;
function FileDateTimeStr(t: TDateTime): string;
function FileDateTimeStr(t: TDateTime): string;
function FileFormID(e: IInterface): cardinal;
function FileFormID(e: IInterface): cardinal;
function FileFormIDtoLoadOrderFormID(aeFile: IwbFile; aiFormID: cardinal): cardinal;
function FileFormIDtoLoadOrderFormID(aeFile: IwbFile; aiFormID: cardinal): cardinal;
function FileSelect(prompt: string): IInterface;
function FileSelect(prompt: string): IInterface;
function FilesEqual(file1, file2: IwbFile): boolean;
function FileToLoadOrderFormID(theFile: IwbFile; id: cardinal): cardinal;

function Filter(e: IInterface): Boolean;
function Filter(e: IInterface): Boolean;
function Filter(e: IInterface): Boolean;

function FinalCharacter(aString: String): String;
function Finalize: integer; // When present in a script, this function will always be run at the end.

function findAddonQuest(targetFile: IInterface; edid: string): IInterface;

function FindChildGroup(aeGroup: IwbGroupRecord; aiType: integer; aeMainRecord: IwbMainRecord): IwbGroupRecord;
function FindChildGroup(aeGroup: IwbGroupRecord; aiType: integer; aeMainRecord: IwbMainRecord): IwbGroupRecord;

function findCobjByResult(misc: IInterface): IInterface;
Function FindControlByName(auiBase: TObject; asName: String) : TObject;
function FindEdgeLink(EdgeLinks: IInterface; elM: string; elT: integer): integer;
function FindEdgeLinkIndex(Triangle: IInterface; elN: integer): integer;
function findExplosionNifName(meshName: string): string;
function FindFile (name: String): IwbFile;
function findFormByString(someStr: string): IInterface;
function findFormIdInString(someStr: string): cardinal;
function findFurnitureCobj(misc: IInterface): IInterface;
function findHqName(hqRef: IInterface): string;
function findHqNameShort(hqRef: IInterface): string;
function findInteriorCellInFileByEdid(sourceFile: IInterface; edid: String): IInterface;
function findKeywordByList(e: IInterface; possibleKeywords: TStringList): IInterface;
function findLinkedRef(ref, kw: IInterface): IInterface;
function findMaxStageForLevel(lvl: integer): integer;
function findNamedReference(cell: IInterface; refEdid: string): IInterface;
function findNextUndeletedStructIndex(parent: IInterface; offset: Integer): integer;

function FindObjectByEdid(edid: String): IInterface;
function findObjectByEdidCached(edid: string): IInterface;
function findObjectByEdidSS2(edid: String): IInterface;
function FindObjectByEdidWithError(edid: string): IInterface;
function FindObjectByEdidWithSuffix(maybeEdid: string): IInterface;
function FindObjectInFileByEdid(theFile: IInterface; edid: string): IInterface;
function findOldFoundationType(oldTfMisc: IInterface): integer;

function findPrefix(edid: string): string;
function findPrefix(edid: string): string;
function findPropertyContainingObject(script, obj: IInterface): string;
function FindRecipe(Create: boolean; List:TStringList; aRecord, Patch: IInterface): IInterface;

function findRecord (searchFile: IbwFile; recToFind, signature: string;): Integer; // finds record by EditorID value in signature group - returns Form ID
function FindRecordByEditorID(f: IInterface; sig, edid: string): IInterface;
function findRecordByValue (searchFile: IbwFile; recToFind: string; sign: string; path: string;): Integer; // finds record by string value in path in signature group - returns Form ID, e.g string in FULL

function FindTriangleByEdgeLinkIndex(Triangles: IInterface; elN: integer): integer;

function FixedFormID(aeRecord: IwbMainRecord): cardinal;
function FixedFormID(aeRecord: IwbMainRecord): cardinal;
function fixEditorID(edid: string): string;
function FixPackage(eRec, eRec2: IInterface): integer;
function FixScrapRecord(e: IInterface): Integer;

function FlagCheck(aRecord: IInterface; aFlag: String): Boolean;
function FlagsToHex(e: IInterface): String;
function FlagsToHex(e: IInterface): String;
function FlagsToNames(e: IInterface): String;
function FlagsToNames(e: IInterface): String;
function FlagValues(aeElement: IwbElement): string;
function FlagValues(aeElement: IwbElement): string;

function Flip(inputBoolean: Boolean): Boolean;
function FloatBinToInt(value: String): Real;
function FloatBinToInt(value: String): Real;
function floatEquals(val1, val2: float): boolean;
function floatEqualsWithTolerance(val1, val2, tolerance: float): boolean;
Function for Type 1 (Alias) properties. Accepts the quest as a variant, 
function FormatCount(i: Integer): string; // Check THIS!
function FormatTags(lsTags: TStringList; asSingular, asPlural, asNull: String): Integer;

function FormID(aeRecord: IwbMainRecord): cardinal;
function FormID(aeRecord: IwbMainRecord): cardinal;
Function FormListIndexOf(aeFormList: IInterface; avForm: Variant): Integer;
function FormsEqual(e1: IInterface; e2: IInterface): boolean;
function FormToStr(form: IInterface): string;
function full(e: IInterface): String;

function FullPath(aeElement: IwbElement): string;
function FullPath(aeElement: IwbElement): string;
function FullPathToFilename(asFilename: string): string;
function FullPathToFilename(asFilename: string): string;

function GatherMaterials: integer;
function gav(e: IInterface): string;
function gav(e: IInterface): string;
function gbs(e: IInterface; s: String): IInterface;
function geev(e: IInterface; ip: string): string;
function geev(e: IInterface; ip: string): string;
function geev(e: IInterface; s: String): String;
function geevt(e: IInterface; name: string): string;

function generateBuildingPlanForLevel(targetFile: IInterface; rootBlueprint: IInterface; edidBase: string; lvlNr: integer): IInterface;
function generateEdid(prefix, base: string): string;
function generateExplosionNifName(meshName: string): string;
function generatePluginReqsMisc(targetFile: IInterface; requiredPlugins: TStringList): IInterface;
function generateSkinForLevel(targetFile: IInterface; rootSkin: IInterface; lvlNr: integer): IInterface;
function generateStageItemEdid(formToSpawnEdid, levelBlueprintEdid, suffix, optionalSpawnName: string): string;
function GenerateTagOutput(tags: TStringList; singular, plural, nothing: string): integer;
function GenerateTagOutput(tags: TStringList; singular, plural, nothing: string): integer;
function generateTerraformerCobj(edidBase: string; piece: IInterface; targetFile: IInterface; cost: integer; shouldHaveText: boolean): IInterface;
function GenerateTranslatedEdid(prefix, edid: string): string;
function GenerateTranslatedEdid(prefix, edid: string): string;

function genv(e: IInterface; ip: string): variant;
function genv(e: IInterface; ip: string): variant;
function genv(e: IInterface; s: String): String;
function getActionAvailableGlobal(upgradeMisc: IInterface): IInterface;
function getAddonConfigScript(targetFile: IInterface): IInterface;
function getArrayElemDefault(arr: TStringList; index: integer; default: string): string;
function GetAuthor(f: IInterface): string;
function GetAuthor(f: IInterface): string;
function getAvByPath(e: IInterface; av: variant; signature: string): float;
function getBuildingPlanForLevel(targetFile: IInterface; edid: string; lvlNr: integer): IInterface;

function GetCell(e: IInterface): IInterface;
function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;
function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;
function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;
function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;
function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;
function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;

function GetChar(const aText: String; aPosition: Integer): Char;
function GetChar(const s: string; n: integer): char;
function GetChar(const s: string; n: integer): char;
function getCommercialSubType(oldKW: IInterface): integer;

function GetConditionOperator(const val: String): String;
function GetConditionOperator(const val: String): String;
function GetConditionType(const val: String): String;
function GetConditionType(const val: String): String;

function GetContainer(aeElement: IwbElement): IwbContainer;
function GetContainer(aeElement: IwbElement): IwbContainer;
Function GetContainersWithItem(aeItemBase: IInterface): TList;
function GetCoordinatesRelativeToBase(afParentPosition, afParentRotation, afOffsetPosition, afOffsetRotation: TJsonObject): TJsonObject;
function getCopyOfTemplate(targetFile, template: IInterface; newEdid: string): IInterface;
function getCsvLineForSpawn(curItem: IInterface; curLevel: integer; addStageNums: boolean): string;
function getDefaultBuildingPlanList(plotType: integer): IInterface;
function getDefaultSubtype(mainType: integer): integer;
function GetDiffList(list1, list2: TStringList): string;
function GetDiffList(list1, list2: TStringList): string;
function GetEditValue(aeElement: IwbElement): string;
function GetEditValue(aeElement: IwbElement): string;

function getElemByEdidAndSig(edid: string; sig: string; fromFile: IInterface): IInterface;
function GetElement(const aElement: IInterface; const aPath: String): IInterface;
function GetElement(const aElement: IInterface; const aPath: String): IInterface;
function GetElement(const aElement: IInterface; const aPath: String): IInterface;
function GetElement(const x: IInterface; const s: String): IInterface;
function GetElement(const x: IInterface; const s: String): IInterface;
function GetElement(x: IInterface; s: string): IInterface;
function GetElement(x: IInterface; s: string): IInterface;
function GetElementByValue(el: IInterface; smth, somevalue: string): IInterface;
function GetElementByValue(el: IInterface; smth, somevalue: string): IInterface;
function GetElementByValue(el: IInterface; smth, somevalue: string): IInterface;
function GetElementEditValues(aeContainer: IwbContainer; asPath: string): string;
function GetElementEditValues(aeContainer: IwbContainer; asPath: string): string;
function GetElementNativeValues(aeContainer: IwbContainer; asPath: string): Variant;
function GetElementNativeValues(aeContainer: IwbContainer; asPath: string): Variant;
function GetElementState(aeElement: IwbElement; aiState: TwbElementState): TwbElementState;
function GetElementState(aeElement: IwbElement; aiState: TwbElementState): TwbElementState;
function GetElementType(aRecord: IInterface): String;

function GetEnchAmount(aLevel: Integer): Integer;
function GetEnchLevel(objEffect: IInterface; slItemTiers: TStringList): Integer;
function GetEnchTemplate(e: IInterface): IInterface;
function getExistingElementOverride(sourceElem: IInterface; targetFile: IwbFile): IInterface;

function GetFile(aeElement: IwbElement): IwbFile;
function GetFile(aeElement: IwbElement): IwbFile;
Function GetFileByName(asFileName: String): IInterface;
function GetFileHeader(f: IInterface): IInterface;
function GetFileName(aeFile: IwbFile): string;
function GetFileName(aeFile: IwbFile): string;
function GetFileOverride(aRecord, aFile: IInterface): IInterface;

function getFirstCVPA(misc: IInterface): IInterface;
function getFirstScriptName(e: IInterface): string;
function getFirstScriptName(e: IInterface): string;

function GetFormByEdid(edid: string): IInterface;
function getFormByFileAndFormID(theFile: IInterface; id: cardinal): IInterface;
function getFormByFilenameAndFormID(filename: string; id: cardinal): IInterface;
function getFormByLoadOrderFormID(id: cardinal): IInterface;
function getFormListEntry(formList: IInterface; index: integer): IInterface;
function getFormlistEntryByEdid(formList: IInterface; edid: string): IInterface;
function getFormListLength(formList: IInterface): integer;
Function GetFormModel(aeForm: IInterface): String;
Function GetFormName(aeForm: IInterface): String;
function GetFormVCS1(aeRecord: IwbMainRecord): cardinal;
function GetFormVCS1(aeRecord: IwbMainRecord): cardinal;
function GetFormVCS2(aeRecord: IwbMainRecord): cardinal;
function GetFormVCS2(aeRecord: IwbMainRecord): cardinal;
function GetFormVersion(aeRecord: IwbMainRecord): cardinal;
function GetFormVersion(aeRecord: IwbMainRecord): cardinal;
function getFromFromOldSpawnStruct(oldStruct: IInterface): IInterface;

Function GetFurnitureEntryPoints(aeFurniture: IInterface; aiIndex: Integer): Integer;
Function GetFurnitureMarker(aeFurniture: IInterface; aiIndex: Integer): IInterface;
function GetFuzzyItem(aString: String): String;
function GetGameValue(aRecord: IInterface): String;
function GetGameValueType(inputRecord: IInterface): String;
function GetGenderFromKeyword(aRecord: IInterface): String;
function GetGridCell(aeRecord: IwbMainRecord): TwbGridCell;
function GetGridCell(aeRecord: IwbMainRecord): TwbGridCell;
function getHardcodedSSTranslation(ss1Edid: string): string;
function GetHours(aTime: TDateTime): Integer;
function getHqFromRoomActionGroup(actGrp: IInterface): IInterface;
function getHqFromRoomConfig(configScript: IInterface): IInterface;
function getIndexForItem(item: IInterface): integer;
function getInjectedRecordTarget(elem: IInterface): IInterface;

function GetIsDeleted(aeRecord: IwbMainRecord): boolean;
function GetIsDeleted(aeRecord: IwbMainRecord): boolean;
function GetIsESM(aeFile: IwbFile): boolean;
function GetIsESM(aeFile: IwbFile): boolean;
function GetIsInitiallyDisabled(aeRecord: IwbMainRecord): boolean;
function GetIsInitiallyDisabled(aeRecord: IwbMainRecord): boolean;
function GetIsPersistent(aeRecord: IwbMainRecord): boolean;
function GetIsPersistent(aeRecord: IwbMainRecord): boolean;
function GetIsVisibleWhenDistant(aeRecord: IwbMainRecord): boolean;
function GetIsVisibleWhenDistant(aeRecord: IwbMainRecord): boolean;

function GetItemCountForCondition(strEDID: string): string;
function GetItemType(aRecord: IInterface): String;

function GetLandscapeForCell(cell: IInterface; aAddIfMissing: Boolean; aPlugin: IInterface): IInterface;
function GetLandscapeForCell(cell: IInterface): IInterface;
function GetLandscapeForCell(cell: IInterface): IInterface;

function getLayer(inFile: IInterface; layerName: string; checkMasters: boolean): IInterface;
function getLayoutDisplayName(layoutName: string; layoutPath: string): string;
function getLevelBuildingPlan(rootBlueprint: IInterface; lvlNr: integer): IInterface;
function getLevelSkin(rootSkin: IInterface; lvlNr: integer): IInterface;
function GetLimbOrChestPiece(e: IInterface): string;
function GetLimbOrChestPiece(e: IInterface): string;

function GetLoadOrder(aeFile: IwbFile): integer;
function GetLoadOrder(aeFile: IwbFile): integer;
function GetLoadOrderFormID(aeRecord: IwbMainRecord): cardinal;
function GetLoadOrderFormID(aeRecord: IwbMainRecord): cardinal;

function getLocalFormId(theFile: IwbFile; id: cardinal): cardinal;
function GetLStringByFormID(const hex: String; const sl: TStringList): String;
function GetLStringByFormID(const hex: String; const sl: TStringList): String;

function getMainTypeByKeyword(kw: IInterface): integer;
function getMainTypeKeyword(mainType: integer): IInteface;
function getMappedResource(vrResource: IInterface; complexity: integer): IInterface;
function getMartialSubType(oldKW: IInterface): integer;
function getMasterType(masterName: string): integer;
function GetMinutes(aTime: TDateTime): Integer;

function getMiscLookupKey(targetFile, formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; iType: integer; spawnName: string; requirementsItem: IInterface): string;
function getMiscLookupKeyFromScript(miscScript: IInterface): string;
function getModelFromPlan(planScript: IInterface): IInterface;
function getModelFromSkin(planScript: IInterface): IInterface;

function GetName(rec: IInterface): string;
function getNameForPackedPlotType(packedPlotType: Integer): String;
function GetNativeValue(aeElement: IwbElement): Variant;
function GetNativeValue(aeElement: IwbElement): Variant;

function getNewConnStr(newConn: TJsonObject): string;
function GetNewFormID(aeFile: IwbFile): cardinal;
function GetNewFormID(aeFile: IwbFile): cardinal;
function getNewPlotMainTypeAndSize(newPlot: IInterface): integer;
function getNewPlotSubType(newPlot: IInterface): integer;
function getNewPlotType(newPlot: IInterface): integer;
function getNewPlotType(oldForm: IInterface): integer;
function getNewPowerConnectionByIndex(itemIndex: Integer): Integer;
function getNewPowerConnectionByItem(item: IInterface): Integer;
function getNewPowerData(oldIndex: integer; level: integer): TJsonObject;
function getNewStageItem(edid, suffix: string; oldSpawnEntry: IInterface; offsetX, offsetY, offsetZ: float): IInterface;
function getNewVersionOfPlot(oldPlot: IInterface): IInterface;

function getNumLevelForOldPlan(oldPlan: IInterface): integer;

Function GetObject(s: String; aList: TStringList): TObject;
function getObjectCobj(e: IInterface): IInterface;
function getObjectFromProperty(prop: IInterface; i: integer): IInterface;
function getOffsetsByPlotType(plotType: integer): TStringList;

function getOldMartialSubtype(plotTypeOverride: IInterface): integer;
function getOldPlotCommercialSubtype(propName: string): integer;
function getOldRecreationalSubtype(plotTypeOverride: IInterface): integer;

function getOrCreateBuildingPlanForLevel(targetFile: IInterface; rootBlueprint: IInterface; edidBase: string; lvlNr: integer): IInterface;
function getOrCreateElementOverride(sourceElem: IInterface; targetFile: IwbFile): IInterface;
function getOrCreateScriptProp(script: IInterface; propName: String; propType: String): IInterface;
function getOrCreateScriptPropArrayOfObject(script: IInterface; propName: String): IInterface;
function getOrCreateScriptPropArrayOfStruct(script: IInterface; propName: String): IInterface;
function getOrCreateScriptPropStruct(script: IInterface; propName: String): IInterface;
function getOrCreateSkinForLevel(targetFile: IInterface; rootSkin: IInterface; lvlNr: integer): IInterface;

Function GetOrMakeFurnitureMarker(aeFurniture: IInterface; aiIndex: Integer): IInterface;
Function GetOrMakePropertyOnScript(aeScript: IInterface; asPropertyName: String; aiPropertyType: Integer; out abResult : Boolean) : IInterface;
function GetOutfitFileFullName(strOutfitName: string): string;
function GetOutfitFileFullName(strOutfitName: string): string;
function getParentRecord(child: IInterface): IInterface;
function GetPatchRecord(i: Integer): IInterface;
function GetPathingForCell(cell: IInterface): IInterface;
Function GetPerkNumberAsString(aString: string): string;
function GetPersistentCellFromWorldspace(Worldspace: IInterface): IInterface;

function getPlotActivatorByType(plotType: integer): IInterface;
function getPlotActivatorEdidByType(plotType: integer): string;
function getPlotFromCache(key: string): IInterface;
function getPlotKeywordForPackedPlotType(plotType: Integer): IInterface;
function getPlotMainTypeName(mainType: integer): String;
function getPlotShortName(mainType: integer): string;
function getPlotSizeName(size: integer): String;
function getPlotSubTypeName(subType: integer): String;
function getPlotThemes(plot: IInterface): TStringList;
function getPlotType(plot: IInterface): integer;
function getPlotTypeForKeyword(kw: IInterface): integer;
function getPlotTypeFromFormLists(newPlot: IInterface): integer;
function getPlotTypeFromKeywords(plot: IInterface): integer;

function GetPosition(aeRecord: IwbMainRecord): TwbVector;
function GetPosition(aeRecord: IwbMainRecord): TwbVector;
function getPositionVector(e: IInterface; path: string): TJsonObject;
function GetPreviousOverride(aRecord: IInterface; LoadOrder: Integer): IInterface;
function GetPrimarySlot(aRecord: IInterface): String;
Function GetPropertyFromScript(aeScript: IInterface; asPropertyName: String; aiPropertyType: Integer) : IInterface;
function getRawScriptProp(script: IInterface; propName: String): IInterface;
function getRawStructMember(struct: IInterface; memberName: String): IInterface;

function GetRecord(i: integer): IInterface;
Function GetRecordByEditorID(aeFile: IInterface; asSignature: String; asEditorID: String): IInterface;
function getRecordByFormID(id: string): IInterface;
function GetRecordFromGroup(grp: IInterface; f: Cardinal): IInterface;
Function GetRecordInAnyFileByEditorID(asSignature: String; asEditorID: String): IInterface;
Function GetRecordInAnyFileByFormID(aiEditorID: String): IInterface;

function getRecreationalSubType(oldKW: IInterface): integer;
function getRecycledMisc(targetFile: IInterface): IInterface;
function getRefLocation(ref: IInterface): IInterface;
function getResourceAvName(av: IInterface): string;
function getResourcesGrouped(resources: TStringList; resourceComplexity: integer): TJsonObject;
function getRoomConfigName(configMisc: IInterface): string;
function GetRoomSlotName(slotMisc: IInterface): string;
function getRoomUpgradeSlots(roomConfig: IInterface): TStringList;

function GetRotation(aeRecord: IwbMainRecord): TwbVector;
function GetRotation(aeRecord: IwbMainRecord): TwbVector;
function getRotationVector(e: IInterface; path: string): TJsonObject;

Function GetScript(aeForm: IInterface; asName: String): IInterface;
function getScript(e: IInterface; scriptName: String): IInterface;
function getScriptProp(script: IInterface; propName: String): variant;
function getScriptPropDefault(script: IInterface; propName: String; defaultValue: variant): variant;

function GetSeconds(aTime: TDateTime): Integer;
function getShortEdid(prefix, rest: string): string;
function getSizeByKeyword(kw: IInterface): integer;
function getSizeKeyword(size: integer): IInterface;
function getSkinForLevel(targetFile: IInterface; edid: string; lvlNr: integer): IInterface;
function getSkinKeywordForPackedPlotType(plotType: Integer): IInterface;
function getSkinTargetPlot(skin: IInterface): IInterface;
function getSpawnManager(spawnManagerEdid: string): IInterface;
function getSpawnMiscByParams(targetFile, formToSpawn: IInterface; posX, posY, posZ, rotX, rotY, rotZ, scale: Float; iType: integer; spawnName: string; requirementsItem: IInterface): IInterface;

function getSS2TraitEdid(oldId: integer): string;
function getSS2TraitMisc(oldId: integer): IInterface;
function getSS2Version(ss1Form: IInterface): IInterface;
function getSS2VersionEdid(ss1Edid: string): string;
function getSS2VersionEdid(ss1Edid: string): string;

function getStackEnabledFormList(targetFile: IInterface): IInterface;
function getStaticType(stat: IINterface): integer;
function getStructMember(struct: IInterface; name: String): variant;
function getStructMemberDefault(struct: IInterface; name: String; defaultValue: variant): variant;
function GetSubstring(input, expr1, expr2: string): string;
function GetSubstring(input, expr1, expr2: string): string;

function getSubtypeByIndex(mainType, subtypeIndex: integer): integer;
function getSubtypeByKeyword(kw: IInterface): integer;
function getSubtypeDescriptionString(subType: integer): string;
function getSubtypeFromOldPlot(mainType: integer; oldPlot: IInterface): integer;
function getSubtypeIndex(mainType, subType: integer): integer;
function getSubtypeKeyword(subType: integer): IInterface;
function GetTemplate(aRecord: IInterface): IInterface;

function GetTextIn(str: string; open, close: char): string;
function GetTextIn(str: string; open, close: char): string;
function GetTextIn(str: string; open, close: char): string;

function getThemeKeywordCaption(kw: IInterface): string;
function GetToken(e: IInterface): string;
function GetTypeOfArmor(e: IInterface): string;
function GetTypeOfArmor(e: IInterface): string;
function GetTypeOfArmour(strEDID: string): string;
function getUniversalForm(script: IInterface; propName: string): IInterface;
function getUpgradeSlot(existingMisc: IInterface; roomShape, roomName, slotName: string; forHq: IInterface): IInterface;
function getValueAsVariant(prop: IInterface; defaultValue: variant): variant;
function getValueFromProperty(prop: IInterface; i: integer): variant;
function getValueFromPropertyDefault(prop: IInterface; i: integer; defaultValue: variant): variant;
function GetVersionString(v: integer): string;
function GetVersionString(v: integer): string;
function GetWorldspacePersistentCell(Worldspace: IInterface): IInterface;
function GetWorldspacePersistentCell(Worldspace: IInterface): IInterface;
function GetZeroFormID(theFile: IwbFile): cardinal;

function gev(const s: String): String;
function gev(const s: String): String;
function gnv(const x: IInterface): Variant;
function gnv(const x: IInterface): Variant;
function gridDataToStr(data: TJsonObject): string;

function GroupBySignature(aeFile: IwbFile; asSignature: string): IwbGroupRecord;
function GroupBySignature(aeFile: IwbFile; asSignature: string): IwbGroupRecord;
function GroupLabel(aeGroup: IwbGroupRecord): cardinal;
function GroupLabel(aeGroup: IwbGroupRecord): cardinal;
function GroupSignature(g: IInterface): string;
function GroupSignature(g: IInterface): string;
function GroupType(): integer;
function GroupType(): integer;

function guessPlotType(plot: IInterface): integer;
function HasCheckMasters(sl: TStrings): Boolean;
function HasFileOverride(aRecord, aFile: IInterface): Boolean;
function hasFlag(e: IInterface; flagName: string): boolean;
function HasFlag(f: IInterface; s: string): boolean;
function HasFlag(f: IInterface; s: string): boolean;
function hasFormlistEntry(formList: IInterface; entry: IInterface): boolean;
function HasGenderKeyword(aRecord: IInterface): Boolean;
function HasGroup(aeFile: IwbFile; asSignature: string): boolean;
function HasGroup(aeFile: IwbFile; asSignature: string): boolean;
function HasItem(aRecord: IInterface; s: string): Boolean;
function HasItem(rec: IInterface; s: string): boolean;
function HasItem(rec: IInterface; s: string): boolean;
Function HasKeyword(aeForm: IInterface; aeKeyword: IInterface): Boolean;
function HasKeyword(aRecord: IInterface; aString: String): boolean;
function HasKeyword(e: IInterface; edid: string): boolean;
function HasKeyword(e: IInterface; edid: string): boolean;
function hasKeywordByPath(e: IInterface; kw: variant; signature: String): boolean;
function HasLOD(wrld: IInterface): boolean;
function HasLOD(wrld: IInterface): boolean;
function HasLOD(wrld: IInterface): boolean;
function HasMaster(aeFile: IwbFile; asMasterFilename: string): boolean;
function HasMaster(aeFile: IwbFile; asMasterFilename: string): boolean;
function hasObjectInProperty(prop: IInterface; entry: IInterface): boolean;
function HasPerkCondition(rec: IInterface; s: string): boolean;
function HasPerkCondition(rec: IInterface; s: string): boolean;
function hasPlotSubtype(packedType: integer): boolean;
function HasPrecombinedMesh(aeRecord: IwbMainRecord): boolean;
function HasPrecombinedMesh(aeRecord: IwbMainRecord): boolean;
function HasScript(e: IInterface; aScript: string): Boolean;
function HasString(const asNeedle, asHaystack: String; const abCaseSensitive: Boolean): Boolean;
function HasString(const asNeedle, asHaystack: String; const abCaseSensitive: Boolean): Boolean;
function HasString(const asNeedle, asHaystack: String; const abCaseSensitive: Boolean): Boolean;

function HexFormID(e: IInterface): string;
function HexFormID(e: IInterface): string;
function HexFormID(e: IInterface): string;
function HexFormID(e: IInterface): string;
function HexFormID(e: IInterface): string;
function HexFormID(e: IInterface): string;
function HexFormID(e: IInterface): string;
function HexFormID(e: IInterface): String;
function HexFormID(e: IInterface): String;
function HexFormID(e: IInterface): String;
function HexFormID(rec: IInterface): string;

function HexToBin(h: String): String;
function HexToBin(h: String): String;
function HexToFloat(s: String): Real;
function HexToFloat(s: String): Real;
function HexToStr(aFormID: String): String;
function HexToString(s: String): String;
function HexToString(s: String): String;

function HighestOverrideOrSelf(): IwbMainRecord;
function HighestOverrideOrSelf(): IwbMainRecord;
function importItemData(itemsSheet: string; skinReplace: boolean): boolean;
function importItemData(itemsSheet: string): boolean;
function importModelData(modelsSheet: string): boolean;
function importSpreadsheetsToJson(modelsSheet, itemsSheet: string; spawnsMode: boolean): boolean;
function InDelimitedList(const x, y: String; const z: Char): Boolean;
function InDelimitedList(x, y: String; const z: Char): Boolean;

function IndexedPath(e: IInterface): string;
function IndexedPath(e: IInterface): string;
function IndexIn(Items: TStrings; Item: string): integer;
function IndexOf(aeContainer: IwbContainer; aeChild: IwbElement): integer;
function IndexOf(aeContainer: IwbContainer; aeChild: IwbElement): integer;
function IndexOfLL(aLevelList, aRecord): Integer;
function IndexOfObjectbyFULL(s: String; aList: TStringList): Integer;
function IndexOfObjectEDID(s: String; aList: TStringList): Integer;
function indexToVectorComponent(i: integer): string;

function InfoFileName(QuestID, DialID: string; InfoFormID, RespNum: integer): string;
function InfoFileName(QuestID, DialID: string; InfoFormID, RespNum: integer): string;
function InfoFileName(QuestID, DialID: string; InfoFormID, RespNumber: integer): string;
function InfoFileName(QuestID, DialID: string; InfoFormID: integer; RespNumber: string): string;

function InIgnoreList(x, y: string): boolean;
function InIgnoreList(x, y: string): boolean;
function IniProcess: integer;
function IniToMatList: integer;
function initSS2Lib(): boolean;
function InsertElement(aeContainer: IwbContainer; aiPosition: integer; aeElement: IwbElement): integer;
function InsertElement(aeContainer: IwbContainer; aiPosition: integer; aeElement: IwbElement): integer;
function InSignatureList(x, y: string): boolean;
function InStringList(const aText: String; const aList: TStringList): Boolean;
function InStringList(const s: String; const l: TStringList): Boolean;
function InStringList(const s: String; const l: TStringList): Boolean;

function IntegerToTime(TotalTime: Integer): String;
function IntToBin(value: LongInt; sz: Integer): String;
function IntToBin(value: LongInt; sz: Integer): String;
function IntToEsState(anInt: Integer): TwbElementState;
function IntWithinStr(aString: String): Integer;

function InvertMatrix(matrix: TJsonObject): TJsonObject;

function IsBadLeveledList(e: IInterface; iFormID: integer): boolean;
function isBlacklist(aRecord: IInterface): boolean;
function isBuildLimitHelper(oldSpawnEntry: IInterface): boolean;
function IsClothing(aRecord: IInterface): Boolean;
function IsD(e: IInterface): boolean;
function IsD(e: IInterface): boolean;
function IsDefaultPlugin(s: string): Boolean;
function IsDirectoryEmpty(const directory: string): boolean;
function IsDirectoryEmpty(const directory: string): boolean;
function IsEditable(aeElement: IwbElement): boolean;
function IsEditable(aeElement: IwbElement): boolean;
function isElementUnsaved(e: IInterface): boolean;
function IsEmptyKey(asSortKey: String): Boolean;
function IsEmptyKey(s: string): boolean;
function IsEmptyKey(s: string): boolean;
function IsFemaleOnly(aRecord: IInterface): Boolean;
function isFileLight(f: IInterface): boolean;
function isFileValidMaster(f: IInterface): Boolean;
function IsFormat3: Boolean;
function IsHighestOverride(aRecord: IInterface; aInteger: Integer): Boolean;
function IsID(e: IInterface): boolean;
function IsID(e: IInterface): boolean;
function IsInjected(aeElement: IwbElement): boolean;
function IsInjected(aeElement: IwbElement): boolean;
function isItemDeleted(item: IInterface): boolean;
function IsLocalRecord(e: IInterface): boolean;
function IsLocalRecord(e: IInterface): boolean;
function IsMaster(aeRecord: IwbMainRecord): boolean;
function IsMaster(aeRecord: IwbMainRecord): boolean;
function isMasterAllowed(fileName: string): boolean;
function IsMasterRef(FormID: Cardinal): boolean;
function IsNull(x: Variant): Boolean;
function IsNull(x: Variant): Boolean;
function isNumericString(str: string): boolean;
function IsOCOnizedPlugin(aFileName: string): boolean;
function IsOverrideRecord(e: IInterface): boolean;
function IsOverrideRecord(e: IInterface): boolean;
function IsP(e: IInterface): boolean;
function IsP(e: IInterface): boolean;
function isPartOfBranchingBlueprint(plot: IInterface): boolean;
function IsPlayableFemale(eFlags: IInterface): boolean;
function IsRef(e: IInterface): Boolean;
function IsReference(aRecord: IInterface): Boolean;
function isReferencedBy(f1, f2: IInterface): boolean;
function IsReferenceInWorldspace(refr: IInterface): Boolean;

function isResourceObject_elem(elem: IInterface): boolean;
function isResourceObject_elem(elem: IInterface): boolean;
function isResourceObject_id(formFileName: string; id: cardinal): boolean;
function isResourceObject_id(formFileName: string; id: cardinal): boolean;

function isRIDP(elem: IInterface): boolean;
function isSameFile(file1, file2: IwbFile): boolean;
function isSameForm(e1: IInterface; e2: IInterface): boolean;
function isSkinMode(): boolean;
function IsSorted(aeContainer: IwbSortableContainer): boolean;
function IsSorted(aeContainer: IwbSortableContainer): boolean;
function IsSpecial(e: IInterface): Boolean;
function isSubrecordArray(e: IInterface): boolean;
function isSubrecordScalar(e: IInterface): boolean;
function isUsedInSCOL(e: IInterface): boolean;
function isValidOverride(targetFile, elem): boolean;
function IsValidRace(e: IInterface; strRace: string): boolean;
function isVariantValidForProperty(value: variant): boolean;
function IsVWD(e: IInterface): boolean;
function IsVWD(e: IInterface): boolean;
function IsWinningOverride(aeRecord: IwbMainRecord): boolean;
function IsWinningOverride(aeRecord: IwbMainRecord): boolean;
function isWithin(value1, value2, margin: float): boolean;

function ItemKeyword(inputRecord: IInterface): String;
function ItPos(substr: string; str: string; it: integer): integer;
function ItPos(substr: string; str: string; it: integer): integer;
function ItPos(substr: String; str: String; it: Integer): Integer;
function jvtGetStackTrace: string;
function jvtHasTrace(t: string): boolean;
function KeywordToBOD2(aKeyword: String): String;
function LastElement(aeContainer: IwbContainer): IwbElement;
function LastElement(aeContainer: IwbContainer): IwbElement;
function LastOverride(const x: IInterface): IInterface;
function LastOverride(const x: IInterface): IInterface;
function LeftStr(s: String; i: Integer): String;
function LinksTo(aeElement: IwbElement): IwbElement;
function LinksTo(aeElement: IwbElement): IwbElement;
function ListNodes(aMesh: string; sl: TStringList): Boolean;
function ListObjectToTStringList(e: IInterface): TStringList;
function ListObjectToTStringList(e: IInterface): TStringList;
function LLcontains(aLevelList, aRecord: IInterface): Boolean;
function LLebi(e: IInterface; i: Integer): IInterface;
function LLec(e: IInterface): Integer;
function LLremove(aLevelList, aRecord): IInterface;
function LLreplace(aLevelList, aRecord, bRecord: IInterface): Boolean;

function LoadFromCsv(): TStringList;
function LoadFromCsv(const bSorted, bDuplicates, bDelimited: Boolean; const d: String = ';'): TStringList;
function LoadFromCsv(const bSorted, bDuplicates, bDelimited: Boolean; const d: String = ';'): TStringList;
function LoadFromDelimitedList(const sDelimiter: String = ';'): TStringList;
function LoadFromDelimitedList(const sDelimiter: String = ';'): TStringList;

function loadMiscsFromCache(targetFile: IInterface): boolean;
function loadNames (searchFile: IbwFile; signature: string; pattern: string;): TStringList;  // loads DisplayNames (FULL) to StringList.

function LoadOrderFormIDtoFileFormID(aeFile: IwbFile; aiFormID: cardinal): cardinal;
function LoadOrderFormIDtoFileFormID(aeFile: IwbFile; aiFormID: cardinal): cardinal;

function loadRecords (searchFile: IbwFile; signature: string; pattern: string;): TStringList;  // loads Names (EDID + "DisplayName" + [Signature:hex FormID]) to StringList.
function LODCellSW(wrld: IInterface; var SWCellX, SWCellY: integer): Boolean;
function LODMeshFor(rec: IInterface; LodType: integer): string;

function LODSettingsFileName(wrld: IInterface): string;
function LODSettingsFileName(wrld: IInterface): string;
function LODSettingsFileName(wrld: IInterface): string;

function LODTextureFileName(aGame, aFormID: integer; aEditorID: string;
function LongestCommonString(aList: TStringList): String;

function MakeBreakdown(aRecord, aPlugin: IInterface): IInterface;
function MakeCraftable(aRecord, aPlugin: IInterface): IInterface;
function makeFlagMatswap(edidBase, origMat, suffix: string; sourceMatswap: IInterface): IInterface;
function MakeTemperable(aRecord: IInterface; lightInteger, heavyInteger: Integer; aPlugin: IInterface): IInterface;
function Markdown(const ls: TStringList; const d: Char; const pre: Boolean): TStringList;
function Markdown(const ls: TStringList; const d: Char; const pre: Boolean): TStringList;

function Master(aeRecord: IwbMainRecord): IwbMainRecord;
function Master(aeRecord: IwbMainRecord): IwbMainRecord;
function MasterByIndex(aeFile: IwbFile; aiIndex: integer): IwbFile;
function MasterByIndex(aeFile: IwbFile; aiIndex: integer): IwbFile;
function MasterCount(aeFile: IwbFile): cardinal;
function MasterCount(aeFile: IwbFile): cardinal;
function MasterOrSelf(aeRecord: IwbMainRecord): IwbMainRecord;
function MasterOrSelf(aeRecord: IwbMainRecord): IwbMainRecord;
function MasterRecordByEditorID(e: IInterace; edid: string): IInterface;
function MastersList(aFile: IInterface): string;

function MatByKYWD(Keyword: String; RecipeItems: IInterface; AmountOfMainComponent: integer): integer;
function Matches(input, expression: string): boolean;
function Matches(input, expression: string): boolean;
function MaterialAmountHeavy(amountOfMainComponent, amountOfAdditionalComponent: integer; recipeItems, aRecord: IInterface): integer;
function MaterialAmountLight(amountOfMainComponent, amountOfAdditionalComponent: integer; recipeItems, aRecord: IInterface): integer;
function MaterialListPrinter(CurrentKYWDName: string): integer;

function MatrixDeterminant(matrix: TJsonObject): float;
function MatrixMultiply(m1, m2: TJsonArray): TJsonArray;
Function MatrixMultiplyByColumn(amMatrix: TJsonArray; avColumn: TJsonObject): TJsonObject;
function MatrixMultiplyScalar(scalar: float; matrix: TJsonObject): TJsonObject;
Function MatrixToAxisAngle(afMatrix: TJsonArray): TJsonObject;
Function MatrixToEuler(afMatrix: TJsonArray): TJsonObject;
Function MatrixToQuaternion(afMatrix: TJsonArray): TJsonObject;
Function MatrixTrace(afMatrix: TJsonArray): float;

function MaxPatchRecordIndex: Integer;
function MaxRecordIndex: Integer;
function ModifyRange(OldValue, OldMin, OldMax, NewMin, Newmax: integer): integer;
function MostCommonString(aList: TStringList): String;
function MoveCell(SrcCell: IInterface; x, y: integer): Boolean;
Function MoveObjectRelativeToObject(afParentPosition, afParentRotation, afPositionOffset, afRotationOffset: TJsonObject): TJsonObject;

function MultiFileSelect(var sl: TStringList; prompt: string): Boolean;
function MultiFileSelectString(sPrompt: String; var sFiles: String): Boolean;
function MultiLineStr(s: string): string;

function Name(aeElement: IwbElement): string;
function Name(aeElement: IwbElement): string;
function newAxisAngle(x, y, z, angle: float): TJsonObject;
function NewContainerElement(container: IInterface; path: string): IInterface;
function newMatrix(a, b, c, d, e, f, g, h, i: float): TJsonArray;
function newQuaternion(w, x, y, z: float): TJsonObject;
function newVector(x, y, z: float): TJsonObject;

function NifBlockList(akData: TBytes; akListOut: TStrings): boolean;
function NifBlockList(akData: TBytes; akListOut: TStrings): boolean;
function NifTextureList(akData: TBytes; akListOut: TStrings): boolean;
function NifTextureList(akData: TBytes; akListOut: TStrings): boolean;
function NifTextureListResource(akData: Variant; akListOut: TStrings): boolean;
function NifTextureListResource(akData: Variant; akListOut: TStrings): boolean;
function NifTextureListUVRange(akData: TBytes; afUVRange: Single; akListOut: TStrings): boolean;
function NifTextureListUVRange(akData: TBytes; afUVRange: Single; akListOut: TStrings): boolean;
function NifTrisCount(aMesh: string): Integer;

function normalizeAngle(rad: float): float;
function normalizeKeyFloat(x: float): string;
function NormalizePath(value: string; atype: integer): string;
function NumOfChar(const s: String; const c: Char): Integer;
function NumOfChar(const s: String; const c: Char): Integer;

function ObjectToElement(akObject: TObject): IInterface;
function ObjectToElement(akObject: TObject): IInterface;
function OneLineStr(s: string): string;

function OptionsForm: Boolean;
function OptionsForm: Boolean;
function OptionsForm: Boolean;
function OptionsForm: Boolean;
function OptionsForm: IInterface;
function ote(e: TObject): IInterface;

function OverrideByFile(e, f: IInterface): IInterface;
function OverrideByFile(e, f: IInterface): IInterface;
function OverrideByIndex(aeRecord: IwbMainRecord; aiIndex: integer): IwbMainRecord;
function OverrideByIndex(aeRecord: IwbMainRecord; aiIndex: integer): IwbMainRecord;
function OverrideCount(aeRecord: IwbMainRecord): cardinal;
function OverrideCount(aeRecord: IwbMainRecord): cardinal;
function OverrideExistsIn(e, f: IInterface): boolean;
function OverrideMaster(const x: IInterface; i: Integer): IInterface;
function OverrideMaster(const x: IInterface; i: Integer): IInterface;
function OverrideRecordCount(f: IInterface): integer;
function OverrideRecordCount(f: IInterface): integer;

function OverX(x: single): integer;
function OverY(y: single): integer;
function packPlotType(mainType, plotSize, subType: integer): integer;
function ParseConditions(conditions: IInterface; lstRaceSex, lstIDs: TStringList): string;

function PatchBook(Book: IInterface): boolean;
function PatchBook(Book: IInterface): Boolean;
function PatchBTTFile(aFileName: string): boolean;
function Path(aeElement: IwbElement): string;
function Path(aeElement: IwbElement): string;
function pathLinksTo(e: IInterface; path: string): IInterface;
function PathName(aeElement: IwbElement): string;
function PathName(aeElement: IwbElement): string;

function Pos2Cell(p: double): integer;
function PosTag (field: TObject;): Integer;
function PosX2px(x: single): integer;
function PosY2px(y: single): integer;
function PrecombinedMesh(aeRecord: IwbMainRecord): string;
function PrecombinedMesh(aeRecord: IwbMainRecord): string;

function prepareBlueprintRoot(targetFile, existingElem: IInterface; rootEdid, fullName, description, confirmation: string): IInterface;
function prepareCityPlanBase(): IInterface;
function prepareSkinRoot(targetFile, existingElem, targetRoot: IInterface; edid, fullName: string): IInterface;

function prependNoneEntry(list: TStringList): TStringList;
function PreviousOverrideExists(aRecord: IInterface; LoadOrder: Integer): Boolean;
function ProgramPath:	String;
function ProgramPath:	String;

Function PromptFor2Strings(asTitle: String; asLabel1: String; asLabel2: String): TStringList;
Function PromptFor3Strings(asTitle: String; asLabel1: String; asLabel2: String; asLabel3: String): TStringList;
Function PromptForEnum(asTitle: String; asLabel: String; aslOptions: TStringList; var aiValue: Integer): Boolean;
Function PromptForString(asTitle: String; asLabel: String; var asValue: String): Boolean;
Function PromptForStrings(asTitle: String; aslLabels: TStringList): TStringList;

function ProperCase(const aText: String): String;
function px2PosX(x: integer): single;
function px2PosY(y: integer): single;

Function QuaternionAdd(aqA, aqB: TJsonObject) : TJsonObject;
Function QuaternionConjugate(aq: TJsonObject): TJsonObject;
Function QuaternionMultiply(aqA, aqB: TJsonObject): TJsonObject;
Function QuaternionToAxisAngle(aqQuat: TJsonObject) : TJsonObject;
Function QuaternionToEuler(aqQuat: TJsonObject): TJsonObject;
Function QuaternionToMatrix(aqQuat: TJsonObject): TJsonArray;

function RadToDeg(rad: float): float;

function RandomHealth(hRandRange: integer; hRandMin:integer): integer;
function RandomLevel(lRandRange: integer; lRandMin:integer): integer;
function RandomLevel(lRandRange: integer; lRandMin:integer): integer;

function rbc(e: IInterface): Integer;
function rbi(e: IInterface; int: Integer): IInterface;
function ReadObj(aFileName: string): Boolean;
Function ReadPropertiesFromScriptFile(aScriptName: String) : TStringList;

function RecordByEditorID(aeFile: IwbFile; asEditorID: string): IwbMainRecord;
function RecordByEditorID(aeFile: IwbFile; asEditorID: string): IwbMainRecord;
function RecordByFormID(aeFile: IwbFile; aiFormID: integer; abAllowInjected: boolean): IwbMainRecord;
function RecordByFormID(aeFile: IwbFile; aiFormID: integer; abAllowInjected: boolean): IwbMainRecord;
function RecordByHexFormID(id: string): IInterface;
function RecordByHexFormID(id: string): IInterface;
function RecordByIndex(aeFile: IwbFile; aiIndex: integer): IwbMainRecord;
function RecordByIndex(aeFile: IwbFile; aiIndex: integer): IwbMainRecord;
function RecordByName(aName: String; aGroupName: String; aFileName: String): IInterface;
function RecordCount(aeFile: IwbFile): cardinal;
function RecordCount(aeFile: IwbFile): cardinal;
function RecordExist (searchFile: IbwFile; recToFind, signature: string;): boolean; // checks if record exist by EditorID value in signature group - returns true or false
function RecordSelect(sFile, sGroup: string): IInterface;
function RecordSelect(sFile, sGroup: string): IInterface;
function RecordToString(rec: IInterface): string;
function RecordToString(rec: IInterface): string;
function RecordToString(rec: IInterface): string;
function RecordToString(rec: IInterface): string;

function RecursiveFileSearch(aPath, aFileName: string; ignore: TStringList; 

function RecursiveFileSearch(aPath, aFileName: string; ignore: TStringList; 


function ReferencedByCount(aeRecord: IwbMainRecord): cardinal;
function ReferencedByCount(aeRecord: IwbMainRecord): cardinal;
function ReferencedByIndex(aeRecord: IwbMainRecord; aiIndex: integer): IwbMainRecord;
function ReferencedByIndex(aeRecord: IwbMainRecord; aiIndex: integer): IwbMainRecord;

function RefreshList(aRecord: IInterface; aString: String): IInterface;

function regexExtract(subject, regexString: string; returnMatchNr: integer): string;
function RegExMatch(ptrn, subj: String): String;
function RegExMatch(ptrn, subj: String): String;
function RegExMatchAll(ptrn, subj: String): TStringList;
function RegExMatchAll(ptrn, subj: String): TStringList;
function RegExMatches(ptrn, subj: String): Boolean;
function RegExMatches(ptrn, subj: String): Boolean;
function RegExReplace(const ptrn, repl, subj: String): String;
function RegExReplace(const ptrn, repl, subj: String): String;
function regexReplace(subject, regexString, replacement: string): string;

function registerBuildingPlanWithRequirement(targetFile, buildingPlan, reqMisc: IInterface; edidBase: string; plotType: integer): IInterface;

function RemoveByIndex(aeContainer: IwbContainer; aiIndex: integer; abMarkModified: boolean): IwbElement;
function RemoveByIndex(aeContainer: IwbContainer; aiIndex: integer; abMarkModified: boolean): IwbElement;

function RemoveElement(aeContainer: IwbContainer; avChild: Variant): IwbElement;
function RemoveElement(aeContainer: IwbContainer; avChild: Variant): IwbElement;
function RemoveFileSuffix(inputString: String): String;
function RemoveFinalCharacter(aString: String): String;
function RemoveFormIDsFromString(name: string): string;
function RemoveFromEnd(s1, s2: string): string;
function RemoveFromEnd(s1, s2: string): string;
function RemoveFromEnd(s1, s2: string): string;
function RemoveSpaces(inputString: String): String;
function RemoveUnneededElements(ePreset: IInterface): IInterface;

function replacePlotSubtype(packedType, newSubtype: integer): integer;
function resolvePowerIndex(layouts: IInterface; powerIndex, powerType: integer): TJsonObject;
function ResourceCount(asFilename: string; akContainers: TStrings): cardinal;
function ResourceCount(asFilename: string; akContainers: TStrings): cardinal;
function ResourceExists(asFilename: string): boolean;
function ResourceExists(asFilename: string): boolean;
function ResourceOpenData(asContainerName: string; asFilename: string): TBytesStream;
function ResourceOpenData(asContainerName: string; asFilename: string): TBytesStream;
function ReverseHex(const s: String): String;
function ReverseHex(const s: String): String;

function ReverseString(s: string): string;
function ReverseString(s: string): string;
function ReverseString(s: string): string;
function ReverseString(s: string): string;
function ReverseString(s: string): string;
function ReverseString(s: string): string;
function ReverseString(var s: string): string;
function ReverseString(var s: string): string;
function ReverseString(var s: string): string;

function rfc(e: IInterface): Integer;
function RightStr(s: String; i: Integer): String;
function rPos(aString, substr: string): integer;
function rPos(substr, str: string): integer;
function rPos(substr, str: string): integer;
function sanitizeEdidPart(input: string): string;
function SanitizeFileName(fn: string): string;
function SanitizeFileName(fn: string): string;

function ScriptsPath:	String;
function ScriptsPath:	String;

function seev(e: IInterface; v, s: String): String;

function SelectedContainer: string;

function SelectFile: IInterface;
function SelectFile: IInterface;
function SelectFile: IInterface;

function SelectOrCreateContainer(f: IInterface): IInterface;
function SelectRecord(aSignatures: string; aWithOverrides: Boolean): IInterface;
function selectSkinTargePlot(oldSkin, oldTarget: IInterface): IInterface;

function SentenceCase(const aText: String): String;

function Serialize(e: IInterface): String;
function Serialize(e: IInterface): String;
function Serialize(e: IInterface): String;

Function SetAliasPropertyOnScript(aeScript: IInterface; asPropertyName: String; avPropertyQuest: Variant, aiAliasIndex: Integer = 0) : Boolean;
Function SetBoolPropertyOnScript(aeScript: IInterface; asPropertyName: String; abPropertyValue: Boolean) : Boolean;
function SetEditorID(aeRecord: IwbMainRecord): string;
function SetEditorID(aeRecord: IwbMainRecord): string;
function SetEditValue(aeElement: IwbElement; asValue: string): string;
function SetEditValue(aeElement: IwbElement; asValue: string): string;
function SetElementState(aeElement: IwbElement; aiState: TwbElementState): TwbElementState;
function SetElementState(aeElement: IwbElement; aiState: TwbElementState): TwbElementState;
function setExternalFormData(jsonRoot: TJsonObject; key, pluginName: string; id: cardinal): boolean;
Function SetFloatPropertyOnScript(aeScript: IInterface; asPropertyName: String; afPropertyValue: Float) : Boolean;
Function SetFormPropertyOnScript(aeScript: IInterface; asPropertyName: String; avPropertyValue: Variant) : Boolean;
Function SetIntPropertyOnScript(aeScript: IInterface; asPropertyName: String; aiPropertyValue: Integer) : Boolean;
function SetIsDeleted(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetIsDeleted(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetIsInitiallyDisabled(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetIsInitiallyDisabled(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetIsPersistent(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetIsPersistent(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetIsVisibleWhenDistant(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetIsVisibleWhenDistant(aeRecord: IwbMainRecord; abFlag: boolean): boolean;
function SetLoadOrderFormID(aeRecord: IwbMainRecord; aiFormID: cardinal): cardinal;
function SetLoadOrderFormID(aeRecord: IwbMainRecord; aiFormID: cardinal): cardinal;
function SetNativeValue(aeElement: IwbElement; avValue: variant): string;
function SetNativeValue(aeElement: IwbElement; avValue: variant): string;
Function SetStringPropertyOnScript(aeScript: IInterface; asPropertyName: String; asPropertyValue: String) : Boolean;

function shortenWithCrc32(input: string): string;
function ShortFormID(x: IInterface): String;
function ShortFormID(x: IInterface): String;
function ShortName(aeElement: IwbElement): string;
function ShortName(aeElement: IwbElement): string;

function shouldOkBtnBeEnabled(frm: TForm): boolean;
function shouldSkinOkBtnBeEnabled(frm: TForm): boolean;

function showConfigDialog(): boolean;
function showConfigDialog(): boolean;
function showConfigDialog(): boolean;
function showFileds(field: TObject; value: String): boolean; // show / hide field - only fields with label, value = default
function ShowImportDialog(title, text: string): TJsonObject;
function showInitialConfigDialog(): boolean;
function showInitialConfigDialog(): boolean;
function showInitialConfigDialog(): boolean;
function showItemOffsetInput(plot: IInterface): boolean;
function ShowOpenFileDialog(title: string; filter:string = ''): string;
function ShowPlotConversionDialog(plot: IInterface): boolean;
function ShowPlotCreateDialog(title, text, initialPlotName, initialPlotId, initialModPrefix: string; packedPlotType: integer; requireStageModels, isFullPlot: boolean; initialThemes: TStringList; autoRegister, makePreview, setupStacking, showDescription: boolean): TJsonObject;
function ShowPlotTypeDialogForConversion(title, text, extraInfo, okBtnText, cancelBtnText: string; packedType: integer; showL4Dropdown: Boolean): integer;
function ShowSaveFileDialog(title: string; filter:string = ''): string;
function ShowSkinCreateDialog(title, text, initialPlotName, initialPlotId, initialModPrefix: string; existingPlotTarget: IInterface; isFullSkin: boolean; initialThemes: TStringList; autoRegister, makePreview, setupStacking: boolean): TJsonObject;
function showThemeSelectionDialog(title, text: string; preselected: TStringList): TStringList;
function showTypeSelectDialog(): boolean;
function ShowVectorInput(caption, text: string; x, y, z: float): TStringList;

function sig(e: IInterface): String;
function Sign(rec: IInterface; sign: string): boolean;
function Signature(aeRecord: IwbMainRecord): string;
function Signature(aeRecord: IwbMainRecord): string;
function SimpleName(aName: string): string;
function SimpleName(aName: string): string;

function sin(x: float): float;
function sinApproximation(x: float): float;
function sinDeg(x: float): float;
function sinReal(x: float): float;

function slAddValue(aName, aValue: String): String;
function slContains(aList: TStringList; s: String): Boolean;
function SLWithinStr(s: String; aList: TStringList): Boolean;

function SmallName(e: IInterface): string;
function SmallName(e: IInterface): string;
function SmallNameEx(const e: IInterface): String;
function SmallNameEx(const e: IInterface): String;

function SortedArrayElementByValue(e: IInterface; sPath, sValue: String): IInterface;
function SortKey(aeElement: IwbElement): string;
function SortKey(aeElement: IwbElement): string;
function SortKeyEx(const e: IInterface): String;
function SortKeyEx(const e: IInterface): String;
function SortKeyEx(e: IInterface): string;

function SoundDataFromREGN(r: IInterface): IInterface;

function StrCapFirst(str: String): String;
function strEndsWith(haystack: String; needle: String): boolean;
function StrEndsWith(s1, s2: string): boolean;
function StrEndsWith(s1, s2: string): boolean;
function StrEndsWith(s1, s2: String): Boolean;
function strEndsWithCI(haystack: String; needle: String): boolean;
function StrEndsWithInteger(aString: String): Boolean;

function StringCompare(const this, that: String; cs: Boolean): Integer;
function StringCompare(const this, that: String; cs: Boolean): Integer;
function StringCRC32(s: string): Cardinal;
function StringMD5(s: string): cardinal;
Function StringObject(s: String; aList: TStringList): String;
function StringRepeat(str: string; len: integer): string;
function StringReplaceLast(source, Str, subStr: string;): string;
function StringToRecord(rec: string): IInterface;
function StringToRecord(rec: string): IInterface;
function StringToRecord(rec: string): IInterface;
function StringToRecord(rec: string): IInterface;

function StripHTML(S: string): string;
function StripPageBreak(S: string): string;
function stripPrefix(prefix, base: string): string;

function StrPosCopy(inputString: String; findString: String; inputBoolean: Boolean): String;
function StrPosCopyBtwn(inputString, aString, bString: String): String;
function StrPosCopyReverse(inputString: String; findString: String; inputBoolean: Boolean): String;
function StrReplace(this, that, subj: String): String;
function StrReplace(this, that, subj: String): String;
function strStartsWith(haystack: String; needle: String): boolean;
function strStartsWithCI(haystack: String; needle: String): boolean;
function StrToBool(s: string): boolean;
function StrToBool(s: String): Boolean;
function StrToBool(s: String): Boolean;
function StrToForm(str: string): IInterface;
function StrToHex(const s: String): string;
function StrToHex(const s: String): string;
function StrToOrd(aString: String): Int64;
function strUpperCaseFirst(str: string): string;
function StrWithinSL(s: String; aList: TStringList): Boolean;

function Substring(sSubstring, sExpression1, sExpression2: String): String;
function SwapEdgeLinkValues(newTs, newLinks: IInterface; oldLinkIndex, newLimit, newLinkIndex, edgeIndex, newT: integer): integer;

function TagExists(asTag: String): Boolean;
function TagExists(t: string): boolean;
function TagExists(t: string): boolean;
function TagExists(t: string): boolean;

function tan(x: float): float;
function tanApproximation(x: float): float;
function tanDeg(x: float): float;
function tanReal(x: float): float;

function tempPerkFunction(Keyword: String; RecipeItems: IInterface; AmountOfMainComponent: integer): integer;
function ternaryOp(condition: boolean; ifTrue: variant; ifFalse: variant): variant;
function testConcat(l: TStringList): string;
function textInKeyword(aRecord: IInterface; text: string; checkCaps: boolean): boolean;

function TimeBtwn(Start, Stop: TDateTime): Integer;
function TimeStr(t: TDateTime): string;
function TimeStr(t: TDateTime): string;

function translateDeskSpawnObject(oldSpawn: IInterface): IInterface;
function translateForm(oldForm: IInterface): IInterface;
function translateFormToFile(oldForm, fromFile, toFile: IInterface): IInterface;
function translateFormToFile(oldForm, oldFile, toFile: IInterface): IInterface;
function translateReference(oldForm: IInterface): IInterface;

function TrimChar(const c: Char; const s: String): String;
function TrimChar(const c: Char; const s: String): String;
function TrimList(aList: TStringList): TStringList;

function TrueRecordByEDID(edid: String): IInterface;

function tryStrToFloat(item: string; default: double): double;
function tryStrToInt(item: string; default: integer): integer;
function TryToCreateRecord(e, akGroup: IInterface): IInterface;
function tryToParseFloat(s: string): integer;
function tryToParseInt(s: string): integer;

function typeOf(e: IInterface): String;
function typeOf(e: IInterface): String;
function typeOf(e: IInterface): String;

Function UIConfirm(asTitle: String; asText: String; asYes: String = 'Yes'; asNo: String = 'No'): Boolean;
function UnCamelCase(s: String): String;
function UnCamelCase(s: String): String;
function UnFuckulateNameEDID(eName, eEDID): string;

Function VectorAdd(avA, avB: TJsonObject): TJsonObject;
Function VectorCrossProduct(avA, avB: TJsonObject): TJsonObject;
Function VectorDivide(avA :TJsonObject; afB: float) : TJsonObject;
Function VectorDotProduct(avA, avB: TJsonObject): float;
function VectorLength(av: TJsonObject): float;
Function VectorMultiply(avA: TJsonObject; afB: float): TJsonObject;
function VectorNegate(av: TJsonObject): TJsonObject;
Function VectorNormalize(av: TJsonObject): TJsonObject;
Function VectorProject(avA, avB: TJsonObject): TJsonObject;
Function VectorSubtract(avA, avB: TJsonObject): TJsonObject;

function VoiceRaceName(race: IInterface; male: Boolean): string;

function wbAlphaBlend(akDestinationDeviceContext: IInterface; aiDestinationX: integer; aiDestinationY: integer; aiDestinationWidth: integer; aiDestinationHeight: integer; akSourceDeviceContext: IInterface; aiSourceX: integer; aiSourceY: integer; aiSourceWidth: integer; aiSourceHeight: integer; aiAlpha: integer): boolean;
function wbAlphaBlend(akDestinationDeviceContext: IInterface; aiDestinationX: integer; aiDestinationY: integer; aiDestinationWidth: integer; aiDestinationHeight: integer; akSourceDeviceContext: IInterface; aiSourceX: integer; aiSourceY: integer; aiSourceWidth: integer; aiSourceHeight: integer; aiAlpha: integer): boolean;
function wbAppName: String;
function wbAppName: String;
function wbBlockFromSubBlock(akSubBlock: TwbGridCell): TwbGridCell;
function wbBlockFromSubBlock(akSubBlock: TwbGridCell): TwbGridCell;
function wbCopyElementToFile(aeElement: IwbElement; aeFile: IwbFile; abAsNew: boolean; abDeepCopy: boolean): IwbElement;
function wbCopyElementToFile(aeElement: IwbElement; aeFile: IwbFile; abAsNew: boolean; abDeepCopy: boolean): IwbElement;
function wbCopyElementToFileWithPrefix(aeElement: IwbElement; aeFile: IwbFile; abAsNew: boolean; abDeepCopy: boolean; akUnknown1: IInterface; akUnknown2: IInterface; akUnknown3: IInterface): IwbElement;
function wbCopyElementToFileWithPrefix(aeElement: IwbElement; aeFile: IwbFile; abAsNew: boolean; abDeepCopy: boolean; akUnknown1: IInterface; akUnknown2: IInterface; akUnknown3: IInterface): IwbElement;
function wbCopyElementToRecord(aeElement: IwbElement; aeRecord: IwbMainRecord; abAsNew: boolean; abDeepCopy: boolean): IwbElement;
function wbCopyElementToRecord(aeElement: IwbElement; aeRecord: IwbMainRecord; abAsNew: boolean; abDeepCopy: boolean): IwbElement;
function wbCRC32Data(akData: TBytes): cardinal;
function wbCRC32Data(akData: TBytes): cardinal;
function wbCRC32File(asFilename: string): cardinal;
function wbCRC32File(asFilename: string): cardinal;
function wbCRC32Resource(asContainerName: string; asFileName: string): cardinal;
function wbCRC32Resource(asContainerName: string; asFileName: string): cardinal;
function wbDDSDataToBitmap(akData: TBytes; akBitmapOut: TBitmap): boolean;
function wbDDSDataToBitmap(akData: TBytes; akBitmapOut: TBitmap): boolean;
function wbDDSResourceToBitmap(akUnknown: IInterface; akBitmapOut: TBitmap): boolean;
function wbDDSResourceToBitmap(akUnknown: IInterface; akBitmapOut: TBitmap): boolean;
function wbDDSStreamToBitmap(akStream: TStream; akBitmapOut: TBitmap): boolean;
function wbDDSStreamToBitmap(akStream: TStream; akBitmapOut: TBitmap): boolean;
function wbGameMasterEsm: String;
function wbGameMasterEsm: String;
function wbGameName: String;
function wbGameName: String;
function wbGridCellToGroupLabel(akGridCell: TwbGridCell): cardinal;
function wbGridCellToGroupLabel(akGridCell: TwbGridCell): cardinal;
function wbIsInGridCell(akPosition: TwbVector; akGridCell: TwbGridCell): boolean;
function wbIsInGridCell(akPosition: TwbVector; akGridCell: TwbGridCell): boolean;

function wbMD5Data(akData: TBytes): cardinal;
function wbMD5Data(akData: TBytes): cardinal;
function wbMD5File(asFilename: string): cardinal;
function wbMD5File(asFilename: string): cardinal;

function wbNormalizeResourceName(asResourceName: string; akResourceType: TGameResourceType): string;
function wbNormalizeResourceName(asResourceName: string; akResourceType: TGameResourceType): string;
function wbPositionToGridCell(akPosition: TwbVector): TwbGridCell;
function wbPositionToGridCell(akPosition: TwbVector): TwbGridCell;
function wbSHA1Data(akData: TBytes): cardinal;
function wbSHA1Data(akData: TBytes): cardinal;
function wbSHA1File(asFilename: string): cardinal;
function wbSHA1File(asFilename: string): cardinal;
function wbStringListInString(akList: TStringList; asSubstring: string): integer;
function wbStringListInString(akList: TStringList; asSubstring: string): integer;
function wbSubBlockFromGridCell(akGridCell: TwbGridCell): TwbGridCell;
function wbSubBlockFromGridCell(akGridCell: TwbGridCell): TwbGridCell;
function wbVersionNumber:	Integer;
function wbVersionNumber:	Integer;

function WinningOverride(aeRecord: IwbMainRecord): IwbMainRecord;
function WinningOverride(aeRecord: IwbMainRecord): IwbMainRecord;
function WinningOverrideBefore(e, f: IInterface): IInterface;

function Workbench(amountOfMainComponent, amountOfAdditionalComponent: integer; recipeCraft, recipeCondition, recipeConditions, recipeItem, recipeItems, aRecord: IInterface): IInterface;
function writeNewCityPlanLayer(parentPlan: IInterface; edid: string; layerArray: IInterface; layerData: TJsonObject; startLevel, removeAtLevel: integer): IInterface;

function YggaddItem(list: IInterface; item: IInterface; amount: integer): IInterface;
function YggaddPerkCondition(list: IInterface; perk: IInterface): IInterface;
function YggcreateRecord(recordSignature: string; plugin: IInterface): IInterface;


procedure AddBoneData(e: IInterface;
procedure AddBoneData(e: IInterface;
procedure AddDebug(aMsg: string);
procedure AddDebug(aMsg: string);
procedure AddDebug(aMsg: string);

procedure AddEditEntry(ee: string);
procedure AddElement(aeContainer: IwbContainer; aeElement: IwbElement);
procedure AddElement(aeContainer: IwbContainer; aeElement: IwbElement);
procedure AddEnchantmentEntry(echt: string);
procedure AddFileToList(f: IInterface; var sl: TStringList);
Procedure AddGetItemCountCondition(rec: IInterface; s: string; aBoolean: Boolean);
procedure AddHair(eHeadParts: IInterface);
procedure AddHairline(eHeadParts: IInterface; strHairline: string);
procedure AddInfosFromDial(Dialogue: IInterface; lst: TStringList);
procedure AddInfosFromDial(Dialogue: IInterface; lst: TStringList);

Procedure AddItemCondition(aRecord, aItem: IInterface; aCount: String);
procedure addItemToLayer(itemArray, form: IInterface; posX, posY, posZ: float; iRemoveAtLevel, iType: integer);
procedure addItemToLayout(itemArray, form: IInterface; posX, posY, posZ: float; iType: integer);

Procedure AddKeyword(aeForm: IInterface; aeKeyword: IInterface);
procedure addKeywordByPath(toElem: IInterface; kw: IInterface; targetSig: string);
procedure AddKeywordWithNameValuePair(e: IInterface; lsHaystack: TStringList; bCaseSensitive: Boolean);

procedure addLayoutHandler(Sender: TObject);
procedure AddListEntry(le: string);

procedure AddMasterIfMissing(aeFile: IwbFile; asMasterFilename: string; aSortMasters: Boolean = True);
procedure AddMasterIfMissing(aeFile: IwbFile; asMasterFilename: string; aSortMasters: Boolean = True);
procedure AddMasters(aeFile: IwbFile; aMasters: TStrings);
procedure AddMasters(aeFile: IwbFile; aMasters: TStrings);
procedure AddMastersIfMissing(AFile: IwbFile; ARecord: IwbMainRecord);
procedure AddMastersToFile(f: IInterface; lst: TStringList; silent: boolean);
procedure AddMastersToFile(f: IInterface; lst: TStringList; silent: boolean);
procedure AddMastersToList(f: IInterface; var lst: TStringList);
procedure AddMastersToList(f: IInterface; var lst: TStringList);
procedure AddMastersToList(f: IInterface; var sl: TStringList; sorted: boolean);
procedure AddMastersToPatch;

procedure AddMessage(asMessage: string);
procedure AddMessage(asMessage: string);
Procedure AddMessageB (value: boolean);
Procedure AddMessageI (value: Integer);

procedure addMiscToLookup(misc, miscScript: IInterface);
procedure addMiscToRecycled(misc: IInterface);
procedure addOrEditLayout(layoutsBox: TListBox; index: integer);
Procedure AddOutfitByList(aList: TStringList; aPlugin: IInterface);
procedure AddOverrideToFile(const f: IwbFile; const r: IInterface);
procedure AddPackagesToNPCs;
procedure addPlotToCache(key: string; newPlot: IInterface);
procedure addPlotTypeDropdowns(frm: TForm; horizontalOffset, verticalOffset, packedType: integer);
Procedure AddPrimarySlots(aList: TStringList);
Procedure addProcessTime(aFunctionName: String; aTime: Integer);
procedure AddRecordToFormList(const f, r: IInterface);
procedure AddRecordToFormList(const f, r: IInterface);
procedure addRecycledMisc(misc: IInterface);
procedure AddRenamePairToNewList;
procedure AddRenamePairToNewList;
procedure addRequiredMastersSilent_Single(fromElement, toFile: IInterface);
procedure addRequiredMastersSilent(fromElement, toFile: IInterface);
procedure addResourceHandler(Sender: TObject);
procedure addResourceToList(resIndex, cnt: Integer; box: TListBox);

procedure addRIDPSpawns(levelBlueprint: IInterface; levelObj: TJsonObject);
procedure AddRNAMItem(rnam, e: IInterface);
procedure addRoomFuncHandler(Sender: TObject);
procedure AddRule(el: IInterface; csv: TStringList; idx: Integer);

procedure AddTag(asTag: String);
procedure AddTag(t: string);
procedure AddTag(t: string);
procedure AddTag(t: string);

procedure AddToContainer;
procedure addToFormlist(formList: IInterface; newForm: IInterface);
procedure AddToLeveledList(list, item: IInterface; level, count: integer);
Procedure AddToLeveledListByList(aList: TStringList; aPlugin: IInterface);

procedure addToStackEnabledList(targetFile, model: IInterface);
procedure addToStackEnabledListIfEnabled(model: IInterface);
procedure addToStackEnabledListIfEnabled(model: IInterface);
procedure addUpgradeSlotHandler(Sender: TObject);

procedure AppendFront;
procedure appendObjectLists(targetList: TStringList; sourceList: TStringList);
procedure appendObjectToProperty(prop: IInterface; newObject: IInterface);
procedure appendSpawn(baseElem: IInterface; curFileName: string; curFormId: cardinal; itemData: TJsonObject; targetArray: IInterface; isResObj: boolean; startLevel, removeAtLevel: integer);
procedure appendSpawn(baseElem: IInterface; itemData: TJsonObject; targetArray: IInterface);
procedure appendSpawn(itemData: TJsonObject; targetArray: IInterface);
procedure AppendTail;

procedure applyCobjData(oldCobj, newCobj: IInterface);
procedure applyLevelPlanOffsets(plotType: integer);
procedure applyMatswapToModel(matswap: IInterface; remapIndex: integer; target: IInterface);
procedure applyModel(source: IInterface; target: IInterface);
procedure applyModelAndTranslate(source, target, fromFile, toFile: IInterface);//, oldFile, toFile: IInterface
procedure applyPlotOffsets(curPlotType: integer; curPlotData: TJsonObject);

procedure AskForAddingMaster(requiredMasterList: TStringList; rec : IInterface; entry : IInterface; eFile : IInterface; eFileName : string; slEntries : TStringList; sl : TStringList);
procedure AskForAddingMaster(requiredMasterList: TStringList; rec : IInterface; entry : IInterface; eFile : IInterface; eFileName : string; slEntries : TStringList; sl : TStringList);
procedure AskForAddingMaster(requiredMasterList: TStringList; rec : IInterface; entry : IInterface; eFile : IInterface; eFileName : string; slEntries : TStringList; sl : TStringList);
procedure AskForAddingMaster(requiredMasterList: TStringList; rec : IInterface; entry : IInterface; eFile : IInterface; eFileName : string; slEntries : TStringList; sl : TStringList);
procedure AskForAddingMaster(requiredMasterList: TStringList; rec : IInterface; entry : IInterface; eFile : IInterface; eFileName : string; slEntries : TStringList);
procedure AskForString(t: String);

procedure AssertEqual(a: Variant; b: Variant; s: String = 'FAIL');
procedure AssertNotEqual(a: Variant; b: Variant; s: String = 'FAIL');

procedure AssetOpen(aContainerName, aFileName: string);
procedure AssetSaveAs(aContainerName, aFileName: string);

procedure BatchCopyDirectory(src, dst: string; ignore: TStringList; 
procedure BatchCopyDirectory(src, dst: string; ignore: TStringList; 
procedure BatchProcess(aSrcPath, aDstPath: string; bToFuz: Boolean);
procedure BatchProcess(aSrcPath, aDstPath: string; bToFuz: Boolean);
procedure BatchReplace(aSrcPath, aDstPath: string; aFind, aReplace: TStringList);

procedure BookmarkGo(aBookmark: integer);
procedure BookmarkSet(e: IInterface; aBookmark: integer);

procedure browseItemFile(Sender: TObject);
procedure browseLayoutItemsFile(Sender: TObject);
procedure browseModelFile(Sender: TObject);
procedure browseTargetPlot(Sender: TObject);

Procedure Btn_AddOrRemove_OnClick(Sender: TObject);
Procedure Btn_Breakdown_OnClick(Sender: TObject);
Procedure Btn_Bulk_OnClick(Sender: TObject);
Procedure Btn_Crafting_OnClick(Sender: TObject);
Procedure Btn_Temper_OnClick(Sender: TObject);
procedure btnApplyCloudClick(Sender: TObject);
procedure btnApplyLightingColorsClick(Sender: TObject);
procedure btnApplyWeatherColorsClick(Sender: TObject);
procedure btnChecksumsClick(Sender: TObject);
procedure btnCopyCloudsClick(Sender: TObject);
procedure btnCopyLightingColorsClick(Sender: TObject);
procedure btnCopyWeatherColorsClick(Sender: TObject);
procedure btnDataPathClick(Sender: TObject);
procedure btnDefaultClick(Sender: TObject);
procedure btnDestinationClick(Sender: TObject);
procedure btnDstClick(Sender: TObject);
procedure btnDstClick(Sender: TObject);
procedure btnDstClick(Sender: TObject);
procedure btnDstClick(Sender: TObject);
procedure btnDstClick(Sender: TObject);
procedure btnExecuteClick(Sender: TObject);
procedure btnExportClick(Sender: TObject);
procedure btnFileNameClick(Sender: TObject);
procedure btnLoadClick(Sender: TObject);
procedure btnPathClick(Sender: TObject);
procedure btnSaveClick(Sender: TObject);
procedure btnShowCloudTextureClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);
procedure btnSrcClick(Sender: TObject);

procedure BuildDependencies(var slTargettedMasters, slDependencies: TStringList);
procedure BuildForms;
Procedure BuildLeveledLists;
procedure buildListOfBuildingPlans();
procedure BuildMap(sOldMasters, sNewMaster: string; var slMap: TStringList);
procedure BuildRef(aeElement: IwbElement);
procedure BuildRef(aeElement: IwbElement);

procedure CallFixStringCharacters;
procedure CallRemovalProcedures(e: IInterface);
procedure CallSanitizeStringCharacters;

procedure cbWorldSelect(Sender: TObject);

procedure ChangeDefenceStats(eArmorRating, eResistancesContainer: IInterface;
procedure ChangeDefenceStats(eArmorRating, eResistancesContainer: IInterface;
procedure ChangeFormSignature(aeRecord: IwbMainRecord; asNewSignature: string);
procedure ChangeFormSignature(aeRecord: IwbMainRecord; asNewSignature: string);
procedure changeSample;
procedure changeValues;
procedure changeVis(Sender: TObject);

procedure CheckActorsACBS(e, m: IInterface; debug: boolean);
procedure CheckActorsACBS(e, m: IInterface; debug: boolean);
procedure CheckActorsAIData(e, m: IInterface; debug: boolean);
procedure CheckActorsAIData(e, m: IInterface; debug: boolean);
procedure CheckActorsAIPackages(e, m: IInterface; debug: boolean);
procedure CheckActorsAIPackages(e, m: IInterface; debug: boolean);
procedure CheckActorsFactions(e, m: IInterface; debug: boolean);
procedure CheckActorsFactions(e, m: IInterface; debug: boolean);
procedure CheckActorsSkeleton(e, m: IInterface; debug: boolean);
procedure CheckActorsSkeleton(e, m: IInterface; debug: boolean);
procedure CheckActorsStats(e, m: IInterface; debug: boolean);
procedure CheckActorsStats(e, m: IInterface; debug: boolean);

procedure CheckCellClimate(e, m: IInterface; debug: boolean);
procedure CheckCellClimate(e, m: IInterface; debug: boolean);
procedure CheckCellRecordFlags(e, m: IInterface; debug: boolean);
procedure CheckCellRecordFlags(e, m: IInterface; debug: boolean);
procedure CheckCellSkyLighting(e, m: IInterface; debug: boolean);
procedure CheckCellSkyLighting(e, m: IInterface; debug: boolean);
procedure CheckCellWater(e, m: IInterface; debug: boolean);
procedure CheckCellWater(e, m: IInterface; debug: boolean);

procedure CheckDelevRelev(e, m: IInterface; debug: boolean);
procedure CheckDelevRelev(e, m: IInterface; debug: boolean);

procedure CheckDestructible(e, m: IInterface; debug: boolean);
procedure CheckDestructible(e, m: IInterface; debug: boolean);

procedure CheckForESL(f: IInterface);
procedure CheckForESL(f: IInterface);
procedure CheckForESL(f: IInterface);
procedure CheckForESL(f: IInterface);

procedure CheckGraphics(e, m: IInterface; debug: boolean);
procedure CheckGraphics(e, m: IInterface; debug: boolean);

procedure CheckInvent(e, m: IInterface; debug: boolean);
procedure CheckInvent(e, m: IInterface; debug: boolean);

procedure CheckNPCFaces(e, m: IInterface; debug: boolean);
procedure CheckNPCFaces(e, m: IInterface; debug: boolean);

procedure CheckRaceBody(e, m: IInterface; tag: string; debug: boolean);
procedure CheckRaceBody(e, m: IInterface; tag: string; debug: boolean);
procedure CheckRaceHead(e, m: IInterface; tag: string; debug: boolean);
procedure CheckRaceHead(e, m: IInterface; tag: string; debug: boolean);

procedure CheckSound(e, m: IInterface; debug: boolean);
procedure CheckSound(e, m: IInterface; debug: boolean);

procedure CheckSpellStats(e, m: IInterface; debug: boolean);
procedure CheckSpellStats(e, m: IInterface; debug: boolean);

procedure CheckStats(e, m: IInterface; debug: boolean);
procedure CheckStats(e, m: IInterface; debug: boolean);

procedure CheckTextures(e: IInterface; aMODL, aMODS: string);
procedure checkValuesRange (field: TEdit; min, max: integer); // keeps the range of integer values in a string;
procedure chkPersistentClick(Sender: TObject);
procedure CleanCell(cell: IInterface);
procedure cleanItemSpawns(newItemSpawns: IInterface);

procedure CleanMasters(aeFile: IwbFile);
procedure CleanMasters(aeFile: IwbFile);

procedure CleanUp;
procedure cleanUp();
procedure cleanUp();
procedure cleanUp();
procedure cleanupSS2Lib();
procedure Clear;
procedure ClearCellData;
procedure ClearDependencies(var slDependencies, slMastersToRemove: TStringList;

procedure ClearElementState(aeElement: IwbElement; aiState: TwbElementState);
procedure ClearElementState(aeElement: IwbElement; aiState: TwbElementState);
procedure clearFormList(formList: IInterface);
procedure clearProperty(prop: IInterface);
procedure clearScriptProp(script: IInterface; propName: string);
procedure clearScriptProperty(script: IInterface; propName: string);

procedure cmbContainerOnChange(Sender: TObject);
procedure cmbContainerOnChange(Sender: TObject);
procedure cmbContainerOnChange(Sender: TObject);

procedure cmbQuestOnChange(Sender: TObject);
procedure cmbQuestOnChange(Sender: TObject);

procedure cModal(h, p: TObject; top: Integer);
procedure cModal(h, p: TObject; top: Integer);
procedure CollectOCOnizedNPC;
procedure ColorEditorClick(Sender: TObject);

procedure ColorEditorReadColor(idxFrom, idxTo: integer);
procedure ColorEditorWriteColor(idxFrom, idxTo: integer);
procedure Commit;
procedure CompareAndProcessUpgrades(bIsChest: boolean;
procedure CompareReferences(cell1, cell2: IInterface; GroupType: integer);

procedure ConstructModalButtons(h, p: TObject; top: Integer);
procedure ConstructModalButtons(h, p: TObject; top: Integer);
procedure Convert(aObjFile, aNifFile: string; aNifVersion: TwbNifVersion);

procedure Convert(aPath: string; aDigits: integer);
procedure Convert(aPath: string; aDigits: integer);
procedure convertDeskSpawn(edidBase: string; oldSpawnStruct, newProp: IInterface);
procedure convertItemSpawn(oldSpawnEntry, newItemSpawns: IInterface; curLevelStart, curLevelStop, baseBlueprintEdid, suffix: string; spawnStageOffset: integer);
procedure convertLeaderRequirements(edidBase: string; oldScript, newScript: IInterface);
procedure convertLeaderTraitArray(oldScript, newScript: IInterface; oldPropName, newPropName: string);
procedure convertStages(oldBlueprint: IInterface; newBlueprint: IInterface; planEdidBase: string);
procedure CopyAllClick(Sender: TObject);
procedure CopyClipboardClick(Sender: TObject);

procedure CopyDirectory(src, dst: string; ignore: TStringList; verbose: boolean);
procedure CopyDirectory(src, dst: string; ignore: TStringList; verbose: boolean);

procedure CopyElement(recsrc, recdst: IInterface; elName: string);
procedure CopyElement(recsrc, recdst: IInterface; elName: string);
procedure CopyElement(RecSrc, RecDst: IInterface; elName: string);

procedure CopyFromPackage(e: IInterface; iDist: integer);
procedure copyModelMatswap(source: IInterface; target: IInterface);

procedure CopyRecModLvlHealth(e: IInterface; CreaHealthVariance: integer; CreaHealthBase: integer;);
procedure CopyRecModLvlHealthAutoCalc(e: IInterface);

procedure CopyRecord(iCopyIndex: integer;);
procedure CopyRecord(iCopyIndex: integer;);
procedure CopyRecord(iCopyIndex: integer;);
procedure CopyRecordAsOverride(e: IInterface);
procedure CopyRecordsToPatch;

procedure CreateForms;
procedure createFurnitureCobjs(targetFile: IInterface; edidBase: string; misc, furn: IInterface);
procedure CreateNewLists;
procedure CreateNif(aFileName: string; aVersion: TNifVersion);
procedure createRoomUpgradeCOBJs(acti, forHq, availableGlobal: IInterface; upgradeName: string; resources: TStringList; completionTime: float);
procedure CreateSharedForm;
procedure CreateSharedForm;

procedure debugDumpPowerGrid(layerArray: IInterface);
procedure DebugList(var sl: TStringList; pre: string);
procedure DebugMessage(s: string);

procedure DefaultOptionsMXPF;

procedure DeleteKeywordWithNameValuePair(e: IInterface; lsHaystack: TStringList; bCaseSensitive: Boolean);
procedure deleteScriptProp(script: IInterface; propName: String);
procedure deleteScriptProps(script: IInterface);
procedure deleteStructMember(struct: IInterface; memberName: String);

procedure Demo1;
procedure Demo2;
procedure Demo3;
procedure DemoFO4;

procedure Describe(name: string);

procedure DoCreateSharedInfos(quest, dial: IInterface);
procedure DoCreateSharedInfos(quest, dial: IInterface);
procedure DoKeywords(e: IInterface);
procedure DoLODGen(wrld: IInterface);
procedure DoStuff(e: IInterface; iInteger: integer);
procedure DoWeatherEditor(e: IInterface);

procedure DrawCellGrid(bmp: TBitmap; Opacity: integer);
procedure DrawCellsForDebug(bmp: TBitmap);
procedure DrawMap(wrld: IInterface);

procedure dumpElem(e: IInterface);
procedure dumpElemWithPrefix(e: IInterface; prefix: String);
procedure dumpGrid();

procedure DuplicateReferences(e: IInterface);

procedure edFilterOnChange(Sender: TObject);
procedure editLayoutHandler(Sender: TObject);
procedure EditorUI;
procedure EditOutOfDate(minimumVersion: String; url: string);
procedure EditOutOfDate(minimumVersion: String; url: string);
procedure editResourceHandler(Sender: TObject);

procedure ElementsByMIP(var lst: TList; e: IInterface; ip: string);
procedure ElementsByMIP(var lst: TList; e: IInterface; ip: string);

Procedure ELLR_Btn_Add(Sender: TObject);
Procedure ELLR_Btn_AddTo(Sender: TObject);
Procedure ELLR_Btn_AddToLeveledListInfo(Sender: TObject);
Procedure ELLR_Btn_EnchantedInfo(Sender: TObject);
Procedure ELLR_Btn_GenerateRecipes;
Procedure ELLR_Btn_OutputPluginInfo(Sender: TObject);
Procedure ELLR_Btn_Patch(Sender: TObject);
Procedure ELLR_Btn_Plugin(Sender: TObject);
Procedure ELLR_Btn_RecipeInfo(Sender: TObject);
Procedure ELLR_Btn_Remove(Sender: TObject);
Procedure ELLR_Btn_SelectedItem(Sender: TObject);
Procedure ELLR_Btn_SelectedItemInfo(Sender: TObject);
Procedure ELLR_OnClick_ClearAll(Sender: TObject);
Procedure ELLR_OnClick_ddFile(Sender: TObject);
Procedure ELLR_OnClick_ddSuggested(Sender: TObject);
Procedure ELLR_OnClick_Patch_ddFileA(Sender: TObject);
Procedure ELLR_OnClick_Remove(Sender: TObject);
Procedure ELLR_OnClick_SelectedItem_AddToLeveledList(Sender: TObject);
Procedure ELLR_OnClick_SelectedItem(Sender: TObject);
Procedure ELLR_OnClick_Template(Sender: TObject);

procedure EnableSkyrimSaveFormat();
procedure EnableSkyrimSaveFormat();

procedure endProgress();

procedure Evaluate(asTag: String; e, m: IInterface);
procedure Evaluate(x, y: IInterface; tag: string; debug: boolean);
procedure Evaluate(x, y: IInterface; tag: string; debug: boolean);
procedure EvaluateByPath(asTag: String; e, m: IInterface; asPath: String);
procedure EvaluateEx(x, y: IInterface; z: string; tag: string; debug: boolean);
procedure EvaluateEx(x, y: IInterface; z: string; tag: string; debug: boolean);

procedure evtButtonAddPrefix(Sender: TObject);
procedure evtButtonAddSuffix(Sender: TObject);
procedure evtButtonReplace(Sender: TObject);

procedure evtClickBtnAppend(Sender: TObject);
procedure evtClickBtnAppFront(Sender: TObject);
procedure evtClickBtnAppTail(Sender: TObject);
procedure evtClickBtnFront2Tail(Sender: TObject);
procedure evtClickBtnRemFront(Sender: TObject);
procedure evtClickBtnRemTail(Sender: TObject);
procedure evtClickBtnRepAll(Sender: TObject);
procedure evtClickBtnRepFront(Sender: TObject);
procedure evtClickBtnReplace(Sender: TObject);
procedure evtClickBtnRepTail(Sender: TObject);
procedure evtClickBtnTail2Front(Sender: TObject);
procedure evtClickBtnTrim(Sender: TObject);

procedure Expect(expectation: boolean; test: string);
procedure ExpectEqual(v1, v2: Variant; test: string);

procedure Export(e: IInterface);
procedure Export(e: IInterface);
procedure Export(e: IInterface);
procedure exportBuildingPlanItems(curPlan: IInterface; list: TStringList);
procedure Exportlist(e: IInterface; addHeaders : boolean);
procedure ExportLLCT(e: IInterface);
procedure ExportLLCT(e: IInterface);
procedure ExportLLCT(e: IInterface);
procedure ExportLLCT(e: IInterface);
procedure ExportQuest(Quest: IInterface);
procedure ExportQuest(Quest: IInterface);
procedure ExportQuest(Quest: IInterface);

procedure ExtractBSA(aContainerName, aPath: string);
procedure ExtractBSA(aContainerName, aPath: string);
procedure ExtractPathBSA(aContainerName, aPath, aSubPath: string);
procedure ExtractPathBSA(aContainerName, aPath, aSubPath: string);

procedure Fail(x: Exception);

procedure FailureMessage(s: string);

procedure FemaleVoices(e: IInterface);
procedure FemaleVoices(e: IInterface);

procedure FileWriteToStream(aeFile: IwbFile; akOutStream: TStream);
procedure FileWriteToStream(aeFile: IwbFile; akOutStream: TStream);

procedure fillCache(formList: IInterface; cacheList: TStringList; cacheFileName: string);
procedure fillLevelBlueprint(levelBlueprint: IInterface; levelObj: TJsonObject; hasModels, hasSpawns: boolean; bpRoot: IInterface; edidBase: string; curLevel: integer);
procedure fillPlotList(clb: TCheckListBox; preselectedEdid: string);
procedure FillPlugins(cmbWorld: TComboBox);
procedure fillSkinLevelBlueprint(levelBlueprint: IInterface; levelNr: integer; hasModels, hasItems: boolean; skinRoot: IInterface; spawnsPropKey, formName: string);
procedure fillSpawns(levelBlueprint, curLevelBlueprintScript: IInterface; propName: string; spawnsArray: TJsonArray);
procedure FillWorldspaces(cmbWorld: TComboBox; f: IInterface);
procedure FillWorldspaces(lst: TStrings);
procedure FillWorldspaces(lst: TStrings);
procedure FillWorldspaces(lst: TStrings);
procedure FillWorldspaces(lst: TStrings);
procedure FillWorldspaces(lst: TStrings);
procedure FillWorldspacesWithLOD(cmbWorld: TComboBox);
procedure FillWorldspacesWithTreeLOD(lst: TStrings);

procedure FilterAssets;
procedure FilterStringList(var sl1, sl2: TStringList; bDeleteIfFound: boolean);

procedure FindCell(WrldEDID, XVal, YVal: string);
procedure FindCell(WrldEDID, XVal, YVal: string);
procedure FindCell(WrldEDID, XVal, YVal: string);
procedure FindClick(Sender: TObject);
procedure findFormIds(subrec, fromFile, toFile: IInterface);
procedure FindMatch(aRecord: IInterface; aQueryPath: string; aQueryNeedle: string; aResults: TStringList);
procedure FindMatch(aRecord: IInterface; aQueryPath: String; aQueryNeedle: String; aResults: TStringList);

procedure FixEmptyDupeText;
procedure FixFormIDString;
procedure FixFormIDString;
procedure FixReferences(rec, container: IInterface; NewOrdinal: Integer; 
procedure FixStringCharacters; // Check every character in the dialog, see if they're fucky. if they are, change 'em and start from the previous char.
procedure FixUnneededFullStop;

procedure forceRegenerateCache(targetFile: IInterface);

procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

Procedure FormListAddForm(aeFormList: IInterface; avForm: Variant);
Procedure FormListAddFormUnique(aeFormList: IInterface; avForm: Variant);

procedure FreeAndNil(var ObjectReference: TObject);
procedure FreeAndNil(var ObjectReference: TObject);
procedure FreeLists;
procedure freeStringListObjects(list: TStringList);
procedure FreeTheTStringLists;

procedure frmFormClose(Sender: TObject; var Action: TCloseAction);
procedure frmFormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure frmMainFormActivate(Sender: TObject);
procedure frmMainFormResize(Sender: TObject);
procedure frmOptionsFormClose(Sender: TObject; var Action: TCloseAction);
procedure frmRuleFormClose(Sender: TObject; var Action: TCloseAction);

procedure Front2Tail;

Procedure GenderOnlyArmor(aString: String; aRecord, aPlugin: IInterface);

procedure generateBlueprint(targetBlueprintElem: IInterface);
Procedure GenerateEnchantedVersionsAuto;
procedure GeneratePerkList(p: IInterface; l: TStringList);
procedure generateScolsForLayout(layout: IInterface);
procedure generateSkin(targetSkinElem: IInterface);
procedure generateTemplateCombination(blueprintRoot, omod: IInterface);
procedure generateTerraformers(tfName, tfPrefix, edidBase: string; targetFile: IInterface; matSwap: IInterface);
procedure generateTerraformerSize(size: integer; tfName, tfPrefix: string; edidBase: string; targetFile: IInterface; matSwap: IInterface);
procedure GenerateWorldspace(wrld: IInterface);

procedure GetAliasVoiceTypes(Quest: IInterface; aAlias: integer; lstVoice: TStringList);
procedure GetAliasVoiceTypes(Quest: IInterface; aAlias: integer; lstVoice: TStringList);

procedure GetConditionsVoiceTypes(Conditions: IInterface; lstVoice: TStringList);
procedure GetConditionsVoiceTypes(Conditions: IInterface; lstVoice: TStringList);
procedure GetConditionsVoiceTypes(Conditions: IInterface; lstVoice: TStringList);

procedure GetDataFromFilename; // One of the procedures to be looped
procedure GetDataFromFilename; // One of the procedures to be looped
procedure GetDataFromSCLP(tstrlistSCLP: TStringList; var iNumBones: integer; var tstrlistDest: TStringList);
procedure GetDataFromSCLP(tstrlistSCLP: TStringList; var iNumBones: integer; var tstrlistDest: TStringList);

procedure GetFullStop;
procedure GetInput(strInputType: string);
procedure GetMasters(f: IInterface; var sl: TStringList);
procedure GetNifAssets(aFileName: string; sl: TStringList);
procedure GetOutfitFileNamesAndPaths(e: IInterface; bIsFemale: boolean;
procedure GetOutfitFileNamesAndPaths(e: IInterface; bIsFemale: boolean;
procedure GetPaths;

procedure GetRecordDefNames(akList: TStrings);
procedure GetRecordDefNames(akList: TStrings);
procedure GetRecords(g: IInterface; lst: TStringList);
procedure GetRecords(g: IInterface; lst: TStringList);
procedure GetRecordVoiceTypes(e: IInterface; lstVoice: TStringList);
procedure GetRecordVoiceTypes(e: IInterface; lstVoice: TStringList);
procedure GetRecordVoiceTypes(e: IInterface; lstVoice: TStringList);
procedure GetRecordVoiceTypes2(e: IInterface; lstVoice: TStringList);
procedure GetRecordVoiceTypes2(e: IInterface; lstVoice: TStringList);
procedure GetRecordVoiceTypes2(e: IInterface; lstVoice: TStringList);

procedure GetRGBFromCLFM(strWithCLFMFormID: string; var outstrRed, outstrGreen, outstrBlue: string);
procedure GetSpeakersFromNPC(e: IInterface; lst: TStringList);
procedure GetSpeakersFromRace(e: IInterface; lst: TStringList);
procedure GetTexturesFromMaterial(aFileName: string; sl: TStringList);  
procedure GetTexturesFromTextureSet(aSet: TwbNifBlock; sl: TStringList);  
procedure GetTheDamnFormID(SomeString: string);
procedure GetTheDialogRecord; // Another procedure to loop, follows the above 'un
procedure GetTheDialogRecord; // Another procedure to loop, follows the above 'un
procedure GetTypeOfArmorThenChangeDefenceStats(e: IInterface);
procedure GetTypeOfArmorThenChangeDefenceStats(e: IInterface);

Procedure GEV_Btn_Remove(Sender: TObject);
Procedure GEV_GeneralSettings;
procedure HandleElement(e: IInterface; sl: TStrings);
procedure HandleOverrides(f: IInterface; sNewMaster: string; 
procedure HandleRecord(e: IInterface; sl: TStrings);
procedure HandleReferences(f: IInterface; sNewMaster: string;

procedure imgOverMouseDown(Sender: TObject; Button: TMouseButton;
procedure imgOverMouseMove(Sender: TObject; Shift: TShiftState; X,
procedure imgOverMouseUp(Sender: TObject; Button: TMouseButton;

procedure Import(e: IInterface);
procedure Import(e: IInterface);
procedure Import(e: IInterface);

procedure importItems(itemArray: IInterface; plotData: TJsonObject; startLevel: integer);
procedure ImportLLCT(e: IInterface);
procedure ImportLLCT(e: IInterface);
procedure ImportLLCT(e: IInterface);
procedure ImportLLCT(e: IInterface);
procedure importPlotPole(plotType: integer; curPlotData, plotData: TJsonObject; iBlueprintIndex, levelNr: integer);
procedure importPlots(plotArray: IInterface; plotData: TJsonObject; startLevel: integer);
procedure importPowerConnections(powerConnArray: IInterface; plotData: TJsonObject; startLevel: integer);
procedure ImportSCLP(e: IInterface; aGender, aFileName: string);
procedure importSingleLevel(targetBlueprintLevelElem: IInterface);
procedure importSingleSkinLevel(targetSkinLevelElem: IInterface);

procedure IncreaseHealthPast3000(e: IInterface);
Procedure IndexObjEffect(aRecord: IInterface; BOD2List, aList: TStringList);
procedure InfoVoiceTypes(Info: IInterface; lstVoice: TStringList);
procedure InfoVoiceTypes(Info: IInterface; lstVoice: TStringList);
procedure InfoVoiceTypes(Info: IInterface; lstVoice: TStringList);

procedure IniALLASettings;
procedure IniBlacklist;
procedure InitBrowser;
procedure initPlotTypes();

procedure IterateWorldspace(e: IInterface);
procedure IterateWorldspace(e: IInterface);

procedure JumpTo(aeElement: IwbElement; unknown: boolean);
procedure JumpTo(aeElement: IwbElement; unknown: boolean);

procedure jvtFinalize;
procedure jvtInitialize;
procedure jvtLogMessage(msg: string);
procedure jvtLogTest(msg: string);
procedure jvtPop(var sl: TStringList);
procedure jvtPrintLogMessages;
procedure jvtPrintReport;
procedure jvtPush(var sl: TStringList; s: string);
procedure jvtSaveLogMessages;

procedure KeyAction(Sender: TObject; var Key: Word;);

procedure layoutBrowseHandler(Sender: TObject);
procedure layoutBrowseUpdateOk(Sender: TObject);

procedure lbCloudLayersClick(Sender: TObject);
procedure lbCloudLayersClickCheck(Sender: TObject);
procedure lbRefsDblClick(Sender: TObject);

procedure LevelMessage;
procedure LevelMessage;
procedure LevelMessage;

procedure LinkClick(Sender: TObject);

procedure ListEntries(rec: IInterface; lstname, refname: string);
procedure ListRefs(aNifFileName: string);

procedure loadActivatorsFromFile(fromFile:  IInterface);
procedure LoadAssetsList(aIndex: integer);
procedure LoadChildRecords(groupSig, sig: string);

procedure loadConfig();
procedure loadConfig();
procedure loadConfig();
procedure loadConfig();

procedure loadForms();
procedure loadFormsFromFile(fromFile: IInterface);

procedure loadForRoomUpgade();
procedure LoadFromFile;
procedure loadHqDepartments();
procedure loadHQs();
procedure loadKeywordsFromFile(fromFile:  IInterface);
procedure loadListsFromCache();
procedure LoadLookupFile(aFileName: string);
procedure loadMiscsFromFile(fromFile:  IInterface);
procedure loadModels();
procedure loadPlotData(existingPlot: IInterface);
procedure loadPlotMapping();
procedure loadQuestsFromFile(fromFile:  IInterface);
procedure LoadRecords(sig: string);
procedure loadRecycledMiscs(targetFile: IInterface; deprecated: boolean);
procedure loadRecycledMiscsNoCacheFile(targetFile: IInterface; buildSpawnList: boolean);
procedure loadResourceGroups();
procedure loadResources();
procedure loadThemeTags();
procedure loadValidMastersFromFile(f: IInterface);

procedure LocalizationGetStringsFromFile(asFilename: string; akListOut: TStrings);
procedure LocalizationGetStringsFromFile(asFilename: string; akListOut: TStrings);

procedure LODCellSW(wrld: IInterface; var SWCellX, SWCellY: integer);

procedure Log(const s: String);
procedure Log(const s: String);

procedure lvAssetsData(Sender: TObject; Item: TListItem);
procedure lvAssetsDblClick(Sender: TObject);
procedure lvAssetsSelectItem(Sender: TObject; Item: TListItem;

procedure lvLinesData(Sender: TObject; Item: TListItem);
procedure lvLinesData(Sender: TObject; Item: TListItem);
procedure lvLinesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure lvLinesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

procedure lvRulesData(Sender: TObject; Item: TListItem);
procedure lvRulesDblClick(Sender: TObject);
procedure lvRulesDragDrop(Sender, Source: TObject; X, Y: Integer);
procedure lvRulesDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
procedure lvRulesSelectItem(Sender: TObject; Item: TListItem;

procedure MaleVoices(e: IInterface);
procedure MaleVoices(e: IInterface);

procedure MapPopup(Sender: TObject);

procedure MarkModifiedRecursive(aeElement: IwbElement);
procedure MarkModifiedRecursive(aeElement: IwbElement);

procedure MenuAddKeywordClick(Sender: TObject);
procedure MenuAddListClick(Sender: TObject);
procedure MenuAddNewKeywordClick(Sender: TObject);
procedure MenuAddNewListClick(Sender: TObject);
procedure MenuEditClick(Sender: TObject);
procedure MenuEditor(e: IInterface);
procedure MenuPopup(Sender: TObject);
procedure MenuPopup(Sender: TObject);
procedure MenuRemoveClick(Sender: TObject);

procedure MergeInto(e, m: IInterface);
Procedure MergeTLists(aslA: TList; aslB: TList);
Procedure MergeTStringLists(aslA: TStringList; aslB: TStringList);

procedure mgeev(var sl: TStringList; var lst: TList);
procedure mgeev(var sl: TStringList; var lst: TList);

procedure miCellClick(Sender: TObject);
procedure migratePlotProduction(oldScript, newScript, buildPlanPathScript: IInterface);
procedure migratePlotSettlementResources(oldScript, newScript, buildPlanPathScript: IInterface);
procedure migrateUniforms(oldPlotScript, newPlotScript: IInterface);

procedure miJumpToClick(Sender: TObject);
procedure miLocationClick(Sender: TObject);
procedure miMapMarkerClick(Sender: TObject);
procedure miOverlayChangeColorClick(Sender: TObject);
procedure miOverlayClearClick(Sender: TObject);
procedure miReferencesClick(Sender: TObject);
procedure miRegionalWeatherClick(Sender: TObject);
procedure miRegionClick(Sender: TObject);

procedure miWorldspaceClick(Sender: TObject);
procedure miWorldspaceFilterLODClick(Sender: TObject);
procedure miWorldspaceLoadImageClick(Sender: TObject);
procedure miWorldspaceSaveAsImageClick(Sender: TObject);
procedure miWorldspaceSaveAsLODClick(Sender: TObject);

procedure MoveDown(aeElement: IwbElement);
procedure MoveDown(aeElement: IwbElement);
procedure MoveReference(aRef: IInterface);
procedure MoveUp(aeElement: IwbElement);
procedure MoveUp(aeElement: IwbElement);

Procedure msg(s: String);
Procedure msgList(s1: String; aList: TStringList; s2: String);
Procedure msgListObject(s1: String; aList: TStringList; s2: String);

procedure MultiFileSelect(var sl: TStringList; prompt: string);
procedure MultiLoad(sRecords: String);

procedure OpenClick(Sender: TObject);

procedure OptionsForm;
procedure OptionsForm;
procedure OptionsForm;
procedure OptionsForm;
procedure OptionsForm;
procedure OptionsForm;
procedure OptionsForm;

procedure OutputTintGroupsToFolder;
procedure OutputTintGroupsToFolder;
procedure OutputTintGroupsToFolder;

procedure OverlayCell(wrld: IInterface);
procedure OverlayLocation(loc: IInterface);
procedure OverlayMapMarker(refr: IInterface);
procedure OverlayReference(refr: IInterface);
procedure OverlayRegion(regn: IInterface);

procedure parseAction;
procedure ParseLOD(rec, lod: IInterface);

procedure Pass;

procedure PatchFileByAuthor(author: string);
procedure PatchFileByName(filename: string);
procedure PatchWorldspace(aName: string);

procedure plotTypeChangedEventHandler(Sender: TObject);

procedure PopupMenuClick(Sender: TObject);

procedure postprocessLayer(layer: IInterface);
procedure postProcessLayout(layout: IInterface);

procedure PrepareData;

procedure PresetLoad(aFileName: string);
procedure PresetSave(aFileName: string);

procedure PrintBSAContents(aContainerName);
procedure PrintBSAContents(aContainerName);
procedure PrintDebugE(x, y: IInterface; t: string);
procedure PrintDebugE(x, y: IInterface; t: string);
procedure PrintDebugMessages;
procedure PrintDebugS(x, y: IInterface; p, t: string);
procedure PrintDebugS(x, y: IInterface; p, t: string);
procedure PrintFailureMessages;
procedure PrintItemLevel(eP: IInterface);
procedure PrintItemLevel(eP: IInterface);
procedure PrintItemLevel(eP: IInterface);
procedure PrintMXPFReport;

procedure PromptRemove(sName: string; e: IInterface; var sl: TStringList);

procedure QuickLoad(sFiles, sRecords: String; bMode: Boolean);

procedure QuickPatch(sAuthor, sFiles, sRecords: String; bMode: Boolean);

procedure RandomRGB(iR: integer);
procedure RandomVoicetype(e: IInterface);

procedure rbModeClick(Sender: TObject);
procedure rbModifyClick(Sender: TObject);
procedure rbNameClick(Sender: TObject);
procedure rbProperCaseClick(Sender: TObject);
procedure rbSentenceCaseClick(Sender: TObject);

procedure ReadScriptProperties(aScriptName: string);

procedure RecursiveAddPairToList(e: IInterface; keyName, valueName: String; results: TStringList);
procedure RecursiveAddPairToList(e: IInterface; keyName, valueName: String; results: TStringList);
procedure RecursiveAddToList(e: IInterface; elementName: String; results: TStringList);
procedure RecursiveAddToList(e: IInterface; elementName: String; results: TStringList);

procedure recycleSpawnMiscIfPossible(misc: IInterface);

procedure RegExpKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

procedure registerAddonContent(targetFile, content, keyword: IInterface);
procedure registerConvertedContent(content, kw: IInterface);
procedure registerEntryForDeletion(itemIndex: Integer);
procedure registerHardcodedSSTranslation(ss1Edid, ss2Edid: string);
procedure registerPlot(plot: IInterface; plotType: integer);
procedure registerPlotWithReqs(plot: IInterface; plotType: integer; reqs: TStringList);
procedure registerResource(vrEdid, realEdid, groupEdid, scrapEdid: string);
procedure registerScrapResource(vrEdid, realEdid, groupEdid: string);
procedure registerSimpleResource(vrEdid, realEdid: string);
procedure registerSkin(skin: IInterface; plotType: integer);

procedure remLayoutHandler(Sender: TObject);

procedure Remove(aeElement: IwbElement);
procedure Remove(aeElement: IwbElement);

procedure RemoveActivateParentsFromRef(e: IInterface);
procedure removeByPath(elem: IInterface; path: string);

procedure RemoveDuplicateKeywords(e: IInterface; sParent: String);
procedure RemoveDuplicates(eFaceTintingLayers: IInterface);

Procedure removeErrors(aRecord: IInterface);
procedure RemoveHairStuff(eHeadParts: IInterface);
Procedure removeInvalidEntries(aRecord: IInterface);
procedure RemoveInvalidEntries(rec: IInterface; lstname, refname, countname: string);
procedure removeKeywordByPath(e: IInterface; kw: variant; signature: String);
procedure RemoveLinkedReferencesFromRef(e: IInterface);

procedure RemoveMaster(f: IInterface; mast: String);
procedure RemoveMaster(f: IInterface; mast: String);
procedure RemoveMaster(f: IInterface; masterFilename: String);
Procedure RemoveMastersAuto(inputPlugin, outputPlugin: IInterface);

procedure removePrefixFromList(prefix: string; list: TStringList);
procedure RemoveRecord(i: integer);

Procedure RemoveScript(aeForm: IInterface; asName: String);
procedure RemoveScriptFromRef(e: IInterface);

Procedure RemoveSubStr(aList: TStringList; aString: String);
procedure RemoveSubstrings(pstringOpenCharToCheck, pstringClosedCharToCheck: string;);
procedure RemoveSubstrings(pstringOpenCharToCheck, pstringClosedCharToCheck: string;);

procedure remResourceHandler(Sender: TObject);
procedure remRoomFuncHandler(Sender: TObject);
procedure remUpgradeSlotHandler(Sender: TObject);

Procedure RenamePropertyOnScript(aeScript: IInterface; asPropertyName: String; asNewName: String);

procedure RenumberRecord(e: IInterface; OldFormID, NewFormID: Cardinal);

procedure ReplaceAll;
procedure ReplaceDraugr(e: IInterface);
procedure ReplaceFront;
Procedure ReplaceInLeveledListAuto(inputRecord, replaceRecord, aPlugin: IInterface);
Procedure ReplaceInLeveledListByList(aList, bList: TStringList; aPlugin: IInterface);
procedure ReplaceKeywordWithNameValuePair(e: IInterface; lsHaystack: TStringList; bCaseSensitive: Boolean);
procedure replaceRecordUsage(haystack, searchFor, replaceBy: IInterface);
procedure ReplaceTail;

procedure ReportMissingProps(rec: IInterface);
procedure ReportPlugin;
procedure ReportRequiredMasters(aeElement: IwbElement; akListOut: TStrings; akUnknown1: boolean; akUnknown2: boolean);
procedure ReportRequiredMasters(aeElement: IwbElement; akListOut: TStrings; akUnknown1: boolean; akUnknown2: boolean);

procedure ResourceContainerList(akContainers: TwbFastStringList);
procedure ResourceContainerList(akContainers: TwbFastStringList);

procedure ResourceCopy(asContainerName: string; asFilename: string; asPathOut: string);
procedure ResourceCopy(asContainerName: string; asFilename: string; asPathOut: string);

procedure ResourceList(asContainerName: string; akContainers: TStrings);
procedure ResourceList(asContainerName: string; akContainers: TStrings);

procedure resyncPowerGrid(parent: IInterface; iIndexOffset: integer);

procedure ReverseElements(aeContainer: IwbContainer);
procedure ReverseElements(aeContainer: IwbContainer);

procedure rsLoadGroups(Sender: TObject);
procedure rsLoadGroups(Sender: TObject);
procedure rsLoadRecords(Sender: TObject);
procedure rsLoadRecords(Sender: TObject);

procedure RulesMenuDeleteClick(Sender: TObject);
procedure RulesMenuEditClick(Sender: TObject);
procedure RulesMenuInsertClick(Sender: TObject);

procedure SanitizeList(entries: IInterface; refpath: string);
procedure SanitizeStringCharacters; // Check every character in the dialog, see if they're fucky. if they are, change 'em and start from the previous char.

procedure SaveAsClick(Sender: TObject);
procedure saveBuildingPlanModelDataToFile(targetFileName: string; script: IInterface);
procedure saveBuildingPlanSpawnDataToFile(script: IInterface; targetFileName: string);
procedure saveConfig();
procedure saveConfig();
procedure saveConfig();
procedure saveConfig();
procedure SaveDebugMessages;
procedure SaveFailureMessages;
procedure SaveForm;
procedure saveItemFile(Sender: TObject);
procedure saveListsToCache();
procedure saveMiscsToCache();
procedure saveModelDataToFile(targetFileName: string);
procedure saveModelFile(Sender: TObject);
procedure SavePlugin(aFile: IInterface; aFileName: string; aReset: Boolean);
procedure saveSkinModelDataToFile(targetFileName: string; script: IInterface);
procedure saveSkinSpawnDataToFile(script: IInterface; targetFileName: string);
procedure saveSpawnDataToFile(targetFileName: string);
procedure SaveToFile;

procedure ScanForAssets(e: IInterface);
procedure ScanForPapyrusScripts(e: IInterface);
procedure ScanTextures(aFolder: string);
procedure ScanVMAD(e: IInterface);
Procedure ScanVMAD(e: IInterface);

Procedure SearchAndReplace(aeElement: IInterface);
procedure SearchAndReplace(e: IInterface; s1, s2: string);
procedure SearchAndReplace(e: IInterface; s1, s2: string);
procedure SearchAndReplace(e: IInterface; s1, s2: string);
procedure SearchAndReplace(e: IInterface; s1, s2: string);

procedure seev(e: IInterface; ip: string; val: string);
procedure seev(e: IInterface; ip: string; val: string);

procedure SelectAllClick(Sender: TObject);
procedure SelectDestFile;
procedure SelectDestFile;
procedure SelectNoneClick(Sender: TObject);

procedure senv(e: IInterface; ip: string; val: variant);
procedure senv(e: IInterface; ip: string; val: variant);
Procedure senv(e: IInterface; s: String; i: Integer);

procedure Separator(bInsertNewlineBefore: Boolean);

procedure SetAuthor(f: IInterface; author: string);
procedure SetAuthor(f: IInterface; author: string);
procedure SetBlemishes(eFaceTintingLayers: IInterface);
procedure SetBlemishesMandatory(eFaceTintingLayers: IInterface);
procedure setBlueprintConfirmation(blueprint: IInterface; confirmation: string);
procedure setBlueprintDescription(blueprint: IInterface; descr: string);
procedure SetBlush(eFaceTintingLayers: IInterface);
procedure SetBrows(eFaceTintingLayers: IInterface);
procedure SetChar(var aText: String; aPosition: Integer; aChar: Char);
procedure SetChar(var input: string; n: integer; c: char);
procedure SetChar(var input: string; n: integer; c: char);

procedure SetColorLayer(eLayer: IInterface);
procedure SetContainer;
procedure SetD(e: IInterface; b: boolean);
procedure SetD(e: IInterface; b: boolean);
procedure SetDamage(eFaceTintingLayers: IInterface);
procedure SetDecalLayer(eLayer: IInterface);
procedure SetEditValueByPath(e: IInterface; path, value: string);

procedure SetElementEditValues(aeContainer: IwbContainer; asPath: string; asValue: string);
procedure SetElementEditValues(aeContainer: IwbContainer; asPath: string; asValue: string);
procedure SetElementNativeValues(aeContainer: IwbContainer; asPath: string; avValue: Variant);
procedure SetElementNativeValues(aeContainer: IwbContainer; asPath: string; avValue: Variant);

procedure SetExclusions(s: string);
procedure SetEyeLiner(eFaceTintingLayers: IInterface);
procedure SetEyeShadow(eFaceTintingLayers: IInterface);
procedure SetFacePaint(eFaceTintingLayers: IInterface);
procedure SetFaceTattoo(eFaceTintingLayers: IInterface;);
procedure SetFileSelection(sFiles: String; bMode: Boolean);

Procedure SetFloatArrayPropertyItemOnScript(aeScript: IInterface; asPropertyName: String; aiIndex: Integer; afValue: Float);
Procedure SetFloatArrayPropertyOnScript(aeScript: IInterface; asPropertyName: String; aslPropertyValues: TStringList);

Procedure SetFormArrayPropertyItemOnScript(aeScript: IInterface; asPropertyName: String; aiIndex: Integer; avValue: Variant);
Procedure SetFormArrayPropertyOnScript(aeScript: IInterface; asPropertyName: String; aslPropertyValues: TStringList);

Procedure SetFormModel(aeForm: IInterface; asModelPath: String);
Procedure SetFormName(aeForm: IInterface; asName: String);

procedure SetFormVCS1(aeRecord: IwbMainRecord; aiValue: cardinal);
procedure SetFormVCS1(aeRecord: IwbMainRecord; aiValue: cardinal);
procedure SetFormVCS2(aeRecord: IwbMainRecord; aiValue: cardinal);
procedure SetFormVCS2(aeRecord: IwbMainRecord; aiValue: cardinal);
procedure SetFormVersion(aeRecord: IwbMainRecord; aiVersion: cardinal);
procedure SetFormVersion(aeRecord: IwbMainRecord; aiVersion: cardinal);

Procedure SetFurnitureBlockedEntryPoints(aeFurniture: IInterface; aiIndex: Integer; aiEntry: Integer);
Procedure SetFurnitureMarkerState(asFurniture: IInterface; aiIndex: Integer; abState: Boolean);
procedure SetHealth(sEDID: string);

procedure SetID(e: IInterface; b: boolean);
procedure SetID(e: IInterface; b: boolean);

procedure SetInclusions(s: string);

Procedure SetIntArrayPropertyItemOnScript(aeScript: IInterface; asPropertyName: String; aiIndex: Integer; aiValue: Integer);
Procedure SetIntArrayPropertyOnScript(aeScript: IInterface; asPropertyName: String; aslPropertyValues: TStringList);

procedure SetIsESM(aeFile: IwbFile; abFlag: boolean);
procedure SetIsESM(aeFile: IwbFile; abFlag: boolean);

procedure setItemIndexByValue(dropDown: TComboBox; value: string);

procedure SetLayerColorIndex(eLayer: IInterface; strColorIndex: string;);
procedure SetLayerColorsRGB(eLayer: IInterface; iRed, iGreen, iBlue: integer);
procedure SetLayerIndex(eLayer: IInterface; strIndex: string;);
procedure SetLayerIntensity(eLayer: IInterface; fIntensity: float);

procedure setLinksTo(e: IInterface; formToAdd: IInterface);

procedure SetLipColor(eLayer: IInterface);
procedure SetLipDecals(eFaceTintingLayers: IInterface);
procedure SetLipLiner(eFaceTintingLayers: IInterface);
procedure SetLipstick(eFaceTintingLayers: IInterface);

procedure SetListEditValues(e: IInterface; ip: string; values: TStringList);
procedure SetListEditValues(e: IInterface; ip: string; values: TStringList);
procedure SetListNativeValues(e: IInterface; ip: string; values: TList);
procedure SetListNativeValues(e: IInterface; ip: string; values: TList);

procedure SetMarkings(eFaceTintingLayers: IInterface);

procedure setNewPowerConnectionByIndex(itemIndex, newVal: Integer);
procedure setNewPowerConnectionByItem(item: IInterface; newVal: Integer);
procedure setNewPowerData(baseElem: IInterface; oldIndex, newIndex, newType, startLevel, removeAtLevel: integer);

procedure SetNewValues(newRec: IInterface);

Procedure SetObject(s: String; aObject: Variant; aList: TStringList);

procedure SetP(e: IInterface; b: boolean);
procedure SetP(e: IInterface; b: boolean);

procedure setPathLinksTo(e: IInterface; path: string; form: IInterface);

procedure setPlotThemes(plot: IInterface; themeTagList: TStringList);

procedure setPropertyValue(propElem: IInterface; value: variant);

procedure setScriptProp(script: IInterface; propName: string; value: variant);
procedure setScriptPropDefault(script: IInterface; propName: string; value, default: variant);

procedure SetSkinTints(eFaceTintingLayers: IInterface);

Procedure SetStringArrayPropertyItemOnScript(aeScript: IInterface; asPropertyName: String; aiIndex: Integer; asValue: String);
Procedure SetStringArrayPropertyOnScript(aeScript: IInterface; asPropertyName: String; aslPropertyValues: TStringList);

procedure setStructMember(struct: IInterface; memberName: string; value: variant);
procedure setStructMemberDefault(struct: IInterface; memberName: string; value, default: variant);

procedure SetToDefault(aeElement: IwbElement);
procedure SetToDefault(aeElement: IwbElement);

procedure setTypeKeywords(plot: IInterface; plotType: integer);

procedure setUniversalForm_id(script: IInterface; propName: string; id: cardinal; pluginName: string);
procedure setUniversalForm(script: IInterface; propName: string; rec: IInterface);
procedure setUniversalFormProperty_elem(struct: IInterface; elem: IInterface; elemKey: string);
procedure setUniversalFormProperty_id(struct: IInterface; id: cardinal; pluginName, idKey, nameKey: string);
procedure setUniversalFormProperty(struct: IInterface; elem: IInterface; id: cardinal; pluginName, elemKey, idKey, nameKey: string);
procedure setUniversalFormStruct_id(struct: IInterface; id: cardinal; pluginName: string);
procedure setUniversalFormStruct(struct: IInterface; rec: IInterface);

procedure SetupBaseFolderPath;
procedure SetupBaseFolderPath;
procedure SetupBaseFolderPath;
procedure SetUpFileVars; // Preliminary stuff, get our file vars all geared up
procedure SetUpFileVars; // Preliminary stuff, get our file vars all geared up
procedure setupFurnitureCobj(cobj, misc, furn: IInterface);
procedure SetupLayerPreventionBooleans;
procedure SetUpOurVars; // More preliminary stuff. Make sure to set the paths correctly!
procedure SetUpOurVars; // More preliminary stuff. Make sure to set the paths correctly!
procedure SetupTheTStringLists;
procedure SetUpVariables(e: IInterface);
procedure SetVWD(e: IInterface; b: boolean);
procedure SetVWD(e: IInterface; b: boolean);

procedure sev(const x: IInterface; const s: String);
procedure sev(const x: IInterface; const s: String);

procedure ShowBrowser;
procedure ShowBrowser;
procedure ShowBrowser;
procedure showCOBJ; 
procedure showDialog(e: IInterface);
procedure ShowEditor;
procedure ShowForm(signature: string);
procedure showMultipleChoiceDialog();
procedure ShowOptions;
procedure showProgressWindow();
procedure showRelevantDialog();

procedure showRoomConfigDialog(existingElem: IInterface);
procedure showRoomUpgradeDialog(existingElem: IInterface);
procedure showRoomUpgradeDialog2(targetRoomConfig, existingElem: IInterface);
procedure showRoomUpradeDialog2UpdateOk(Sender: TObject);

procedure ShowSearchForm;
procedure ShowSearchForm;
procedure ShowSearchForm;
procedure ShowValues(e: IInterface);

Procedure slClearEmptyStrings(aList: TStringList);
Procedure slDeleteString(s: String; aList: TStringList);

procedure slev(e: IInterface; ip: string; values: TStringList);
procedure slev(e: IInterface; ip: string; values: TStringList);
procedure slevo(e: IInterface; ip: string; values: TStringList);
procedure slevo(e: IInterface; ip: string; values: TStringList);

Procedure slFuzzyItem(aString: String; aList: TStringList);
Procedure slGetFlagValues(e: IInterface; aList: TStringList; aBoolean: Boolean);
Procedure slKeywordList(aRecord: IInterface; out aList: TStringList);

procedure slnv(e: IInterface; ip: string; values: TList);
procedure slnv(e: IInterface; ip: string; values: TList);

Procedure slRemoveDuplicates(aList: TStringList);
Procedure slSetFlagValues(e: IInterface; aList: TStringList; aPlugin: IInterface);

procedure snv(const x: IInterface; const v: Variant);
procedure snv(const x: IInterface; const v: Variant);

procedure SortMasters(aeFile: IwbFile);
procedure SortMasters(aeFile: IwbFile);
procedure sortPowerConnections();

procedure startProgress(text: string; max: integer);
procedure StartTheMainProcess;

procedure stripSubtypeKeywords(plot: IInterface);
procedure stripThemeKeywords(plot: IInterface);
procedure stripTypeKeywords(plot: IInterface);

procedure SwapEdgeLink(swapLink, haveLink: IInterface);
procedure SwapMasters(sOldMasters, sNewMaster: string; var slMap: TStringList);
procedure swapStructs(s1, s2: IInterface);

procedure Tail2Front;
procedure tempPerkFunctionSetup;

procedure TestBooleans;
procedure TestFileSelection;
procedure TestGeneral;
procedure TestIntegers;
procedure TestLogging;
procedure TestMacros;
procedure TestPatchFileSelection;
procedure TestRecordPatching;
procedure TestRecordProcessing;

procedure themeSelectionClick(Sender: TObject);

procedure translateElementScripts(newElem: IInterface);

procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
procedure TreeViewDblClick(Sender: TObject);
procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
procedure TreeViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

procedure TrimFront;
procedure TrimTail;

procedure TripleHealth(e: IInterface);
procedure TryToReplaceReference(AParent: IwbMainRecord; AForms: IwbElement; AIndex: integer);
Procedure TShift(aInteger, bInteger: Integer; aForm: TForm; aBoolean: Boolean);
procedure TStringListStuff; // Just setting up our spawn lists.

procedure typeSelectCallback(sender: TObject);

procedure UpdatecbWorld(Sender: TObject);
procedure UpdateGlobalCondition(e: IInterface; iPackageType: integer);
procedure UpdateNodeFLST(aNode: TTreeNode);
procedure UpdateNodeText(aNode: TTreeNode);
procedure updatePlotDialogOkBtnState(sender: TObject);
procedure updateProgress(cur: integer);

procedure UpdateReferences(e: IInterface; ModLoadOrder: integer);
procedure UpdateRefPosition(aRef: IInterface; aPath: string);
procedure UpdateRefs();
procedure UpdateRefs();

procedure updateRoomConfigOkBtn(sender: TObject);
procedure updateRoomUpgrade1OkBtn(sender: TObject);
procedure updateSkinDialogOkBtnState(sender: TObject);
procedure updateSkinTargetOkBtn(sender: TObject);
procedure updateSubtypeDropdown(mainType: integer; dropdown: TComboBox);
procedure UpdateTangents(aPath: string; aAddIfMissing: Boolean);
procedure UpdateWorldspace(wrld: IInterface);

procedure UserPrompt(asCaption, asQuery: String);

procedure wbFilterStrings(akListIn: TStrings; akListOut: TStrings; asFilter: String);
procedure wbFilterStrings(akListIn: TStrings; akListOut: TStrings; asFilter: String);
procedure wbFindREFRsByBase(aeREFR: IwbMainRecord; asSignatures: string; aiFlags: integer; akOutList: TList);
procedure wbFindREFRsByBase(aeREFR: IwbMainRecord; asSignatures: string; aiFlags: integer; akOutList: TList);
procedure wbFlipBitmap(akBitmap: TBitmap; aiAxes: integer);
procedure wbFlipBitmap(akBitmap: TBitmap; aiAxes: integer);
procedure wbGetSiblingRecords(aeRecord: IwbElement; asSignatures: string; abIncludeOverrides: boolean; akOutList: TList);
procedure wbGetSiblingRecords(aeRecord: IwbElement; asSignatures: string; abIncludeOverrides: boolean; akOutList: TList);
procedure wbRemoveDuplicateStrings(akList: TStringList);
procedure wbRemoveDuplicateStrings(akList: TStringList);

procedure wCopyFile(src, dst: string; silent: boolean);
procedure wCopyFile(src, dst: string; silent: boolean);
procedure WorldspaceSelect(Sender: TObject);
procedure WorldspaceSelect(Sender: TObject);

procedure writeFormData_elem(struct: IInterface; elem: IInterface; elemKey: string);
procedure writeFormData_id(struct: IInterface; id: cardinal; pluginName, idKey, nameKey: string);
procedure writeFormData(struct: IInterface; elem: IInterface; id: cardinal; pluginName, elemKey, idKey, nameKey: string);
procedure writeNewCityPlan();
procedure writeOffsetsArray(targetScript: IInterface; propName: string);
procedure writeScrapData(arr: TJsonArray; layerScript: IInterface; isRestore: boolean);
procedure writeUniversalForm_rec(script: IInterface; propName: string; rec: IInterface);
procedure writeUniversalForm(script: IInterface; propName: string; rec: IInterface; id: cardinal; pluginName: string);

procedure xFindAllFilesIncSubfolders(sTheDirToSearch, sTheFileExt: string;): TStringList;
procedure YggremoveInvalidEntries(rec: IInterface);


_Execute external applications.pas
_JSON - Demo.pas
_jvTest - Example.pas
_newscript_.pas
_Regex Workbench.pas
_Save script source.pas
_SaveAs.pas
_xEditAPI.pas
A_copy_function_that_allows_you_to_copy (123 ).pas
A_Rewrite_Of_The_Native_InputQuery_That (25 ).pas
AAA FyTy - Show FormID.pas
Add Legendary Object Mod Rules.pas
Add_get_item_count_condition_Procedure_ (107 ).pas
Add_get_item_count_condition_Procedure_ (108 ).pas
Adds_a_TStringList_and_its_objects_to_a (77 ).pas
Adds_a_TStringList_to_an_msg_on_a_singl (76 ).pas
Adds_item_record_reference_to_the_list_ (159 ).pas
Adds_item_record_reference_to_the_list_ (69 ).pas
Adds_item_reference_to_the_leveled_list (70 ).pas
Adds_requirement_HasPerk_to_Conditions_ (161 ).pas
Adds_requirement_HasPerk_to_Conditions_ (57 ).pas
AiEntry_Is_A_Bitmask_Representing_The_E (20 ).pas
ALLA_AutomatedLeveledListAddition.pas
ALLA_CustomFunctionList.pas
Appends_a_string_to_the_end_of_the_inpu (26 ).pas
ASSEMBLE_OTFT_FROM_VANILLA_ENTRIES_OUTF (16 ).pas
ASSEMBLE_OTFT_FROM_VANILLA_ENTRIES_OUTF (17 ).pas
ASSEMBLE_OTFT_FROM_VANILLA_ENTRIES_RECO (15 ).pas
BASH tags autodetection.pas
Bookmark.pas
Bookmark1.pas
Bookmark1Go.pas
Bookmark2.pas
Bookmark2Go.pas
Bookmark3.pas
Bookmark3Go.pas
Bookmark4.pas
Bookmark4Go.pas
Bookmark5.pas
Bookmark5Go.pas
browser, Assets.pas
Caption_Exists_on_TForm_element_functio (86 ).pas
cell, Put master references in the same as overriding references.pas
Check textures, DDS - without mipmaps.pas
Check_a_records_Flags_for_aFlag_functio (65 ).pas
Checks_for_keyword_SkyrimUtils_function (50 ).pas
Checks_if_a_level_list_contains_a_recor (61 ).pas
Checks_if_a_string_contains_integers_an (29 ).pas
Checks_if_an_input_record_has_an_item_m (111 ).pas
Checks_If_Any_ObjectReferences_Of_A_Giv (11 ).pas
Checks_to_see_if_a_string_ends_with_an_ (25 ).pas
Clears_empty_TStringList_entries_Proced (112 ).pas
conflict, Detect between elements.pas
container, Add into .pas
Converts_a_boolean_value_into_a_string_ (46 ).pas
Converts_Hex_FormID_to_String_function_ (49 ).pas
Copies_from_end_instead_of_beginning_fu (36 ).pas
Copies_string_preceding_TRUE_or_followi (35 ).pas
count_loaded_refs_in_load_order.pas
Creates_a_Chance_Leveled_List_function_ (82 ).pas
Creates_a_leveled_list_function_createL (48 ).pas
Creates_an_enchanted_copy_of_the_item_r (98 ).pas
Creates_COBJ_record_for_item_SkyrimUtil (71 ).pas
Creates_new_COBJ_record_to_make_item_te (105 ).pas
Creates_new_record_inside_provided_file (66 ).pas
Dank_ModifyStrings.pas
dialogue responses Shared Infos, Create.pas
dubh - Bash Tagger v1_5_1_2.pas
dubhFunctions.pas
End (31 ).pas
ESL, Set.pas
Export AMMO, ARMO, COBJ, MISC, and WEAP Records.pas
Extracts_the_specified_integer_Natural_ (55 ).pas
Fallout4 - Convert ALCH to SPEL.pas
Fallout4 - Copy XPRI subrecord.pas
Fallout4 - Disable PreVis.pas
Fallout4 - Filter for precombined statics.pas
Fallout4 - Import SCLP bone weights.pas
Fallout4 - Workshop Menu Editor.pas
FILE_BY_NAME_IS_NATIVE_PAST_xEdit_x (4 ).pas
FILE_BY_NAME_IS_NATIVE_PAST_xEdit_x_Fin (1 ).pas
Fills_a_TStringList_with_true_flag_valu (33 ).pas
filter, Apply for cleaning.pas
Find and Replace References (FLST).pas
Find records.pas
Find_a_record_by_name_e_x_IronSword_fun (41 ).pas
Find_if_a_file_is_loaded_is_xEdit_funct (6 ).pas
Find_the_last_position_of_a_substring_i (45 ).pas
Find_the_type_of_Item_function_ItemKeyw (23 ).pas
Find_where_the_selected_record_is_refer (10 ).pas
Find_where_the_selected_record_is_refer (11 ).pas
Find_where_the_selected_record_is_refer (7 ).pas
Find_where_the_selected_record_is_refer (8 ).pas
Find_where_the_selected_record_is_refer (9 ).pas
Finds_a_TForm_element_by_name_function_ (84 ).pas
Finds_a_TForm_element_by_name_function_ (85 ).pas
Finds_if_StringList_contains_substring_ (30 ).pas
Finds_if_StringList_contains_substring_ (31 ).pas
Finds_if_StringList_contains_substring_ (32 ).pas
Finds_the_longest_common_substring_func (87 ).pas
Finds_the_nth_record_in_a_level_list_fu (63 ).pas
FO4ExportListAllOfThisType.pas
FormID, Renumber .pas
FormID, Renumber of Matching EDID.pas
Function_Btn_ItemTierLevels_OnClick_Sen (92 ).pas
Function_CountFurnitureMarkers_AeFurnit (19 ).pas
Function_DecToRoman_Decimal_Integer_str (88 ).pas
Function_FinalCharacter_aString_String_ (139 ).pas
Function_FindRecipe_Create_boolean_List (151 ).pas
Function_FormListIndexOf_AeFormList_IIn (14 ).pas
Function_GatherMaterials_integer_var_Te (141 ).pas
Function_GetElementType_aRecord_IInterf (130 ).pas
Function_GetEnchLevel_objEffect_IInterf (122 ).pas
Function_GetFileOverride_aRecord_aFile_ (121 ).pas
Function_GetFormName_AeForm_IInterface_ (9 ).pas
Function_GetFurnitureEntryPoints_AeFurn (18 ).pas
Function_GetOrMakeFurnitureMarker_AeFur (17 ).pas
Function_GetPreviousOverride_aRecord_II (119 ).pas
Function_GetPrimarySlot_aRecord_IInterf (135 ).pas
Function_GetRecordInAnyFileByFormID_AiE (5 ).pas
Function_GetSeconds_aTime_TDateTime_Int (132 ).pas
Function_GetTemplate_aRecord_IInterface (51 ).pas
Function_HasFileOverride_aRecord_aFile_ (120 ).pas
Function_HasGenderKeyword_aRecord_IInte (126 ).pas
Function_IniProcess_integer_var_TalkToU (143 ).pas
Function_InitializeRecipes_integer_var_ (154 ).pas
Function_IniToMatList_integer_var_i_t_f (146 ).pas
Function_IntegerToTime_TotalTime_Intege (133 ).pas
Function_isBlacklist_aRecord_IInterface (106 ).pas
Function_IsClothing_aRecord_IInterface_ (127 ).pas
Function_IsFemaleOnly_aRecord_IInterfac (125 ).pas
Function_IsHighestOverride_aRecord_IInt (104 ).pas
Function_MakeBreakdown_aRecord_aPlugin_ (109 ).pas
Function_MakeCraftable_aRecord_aPlugin_ (147 ).pas
Function_MatByKYWD_Keyword_String_Recip (153 ).pas
Function_MaterialAmountHeavy_amountOfMa (149 ).pas
Function_MaterialAmountLight_amountOfMa (150 ).pas
Function_MaterialListPrinter_CurrentKYW (142 ).pas
Function_MostCommonString_aList_TString (129 ).pas
Function_PreviousOverrideExists_aRecord (118 ).pas
Function_StrEndsWithInteger_aString_Str (138 ).pas
Function_StrToOrd_aString_String_Int_va (134 ).pas
Function_tempPerkFunction_Keyword_Strin (155 ).pas
Function_textInKeyword_aRecord_IInterfa (128 ).pas
Function_TimeBtwn_Start_Stop_TDateTime_ (131 ).pas
Function_tryStrToFloat_item_string_defa (157 ).pas
Function_tryStrToInt_item_string_defaul (158 ).pas
Function_Workbench_amountOfMainComponen (152 ).pas
Function_YggcreateRecord_recordSignatur (148 ).pas
FUNCTIONS_SPECIFIC_TO_GENERATEENCHANTED (89 ).pas
Generate Loose Mods for Selected OMOD Records.pas
Generate Scrap Recipes for Selected Object Records.pas
Generates_enchanted_versions_of_a_list_ (99 ).pas
Gets_a_HexFormID_function_HexFormID_e_I (56 ).pas
Gets_a_template_from_and_enchanted_reco (28 ).pas
Gets_an_Enchantment_Amount_from_the_lev (101 ).pas
Gets_an_item_type_for_slFuzzyItem_funct (72 ).pas
Gets_an_object_associated_with_a_string (114 ).pas
Gets_an_object_associated_with_a_string (115 ).pas
Gets_an_object_by_IntToStr_EditorID_fun (102 ).pas
Gets_an_object_by_IntToStr_EditorID_fun (103 ).pas
Gets_record_from_leveled_list_index_fun (79 ).pas
Gets_templetes_for_books_todo_fix_paths (54 ).pas
Gets_the_component_associated_with_a_ca (117 ).pas
Gets_the_relevant_game_value_function_G (58 ).pas
Gets_the_relevant_game_value_type_funct (59 ).pas
Given_A_File_Signature_E_G_NPC_And_Edit (4 ).pas
Indexes_an_Object_effect_Procedure_Inde (100 ).pas
jvTest.pas
Keymaster.pas
Keyword Search for Scripts.pas
LOD Statistics.pas
LODGen.pas
manager, Assets.pas
map marker, Replace .pas
model file name, Replace .pas
mteFunctions.pas
MXPF - Save Female NPCs - Quick.pas
MXPF - Tests.pas
mxpf.pas
navmeshes, Undelete.pas
NIF - Batch update tangents and bitangents.pas
NIF - Convert OBJ to NIF.pas
NIF - List blocks references.pas
NPC Add Flag (Auto-Calc Stats).pas
NPC Add Flag (Essential).pas
NPC Add Flag (PC Level Mult).pas
NPC Add Flag (Protected).pas
NPC Add Flag (Unique).pas
NPC Add Flags.pas
object, Base variations.pas
Oblivion - Items lookup replacement.pas
Oblivion - OCO faces assignment.pas
Only_first_letter_capitalized_function_ (83 ).pas
OTFT_RECORD_DETECTION_Find_valid_OTFT_r (13 ).pas
override, Remove identical to previous records.pas
overrides, Merge into master.pas
persistent flag, Change .pas
Procedure_AddKeyword_AeForm_IInterface_ (23 ).pas
Procedure_AddPrimarySlots_aList_TString (137 ).pas
Procedure_Btn_AddOrRemove_OnClick_Sende (90 ).pas
Procedure_Btn_Breakdown_OnClick_Sender_ (94 ).pas
Procedure_Btn_Crafting_OnClick_Sender_T (95 ).pas
Procedure_Btn_Temper_OnClick_Sender_TOb (93 ).pas
Procedure_ELLR_Btn_Patch_Sender_TObject (96 ).pas
Procedure_FormListAddFormUnique_AeFormL (15 ).pas
Procedure_GenderOnlyArmor_aString_Strin (124 ).pas
Procedure_GEV_Btn_Remove_Sender_TObject (91 ).pas
Procedure_GEV_GeneralSettings_var_lblpe (97 ).pas
Procedure_IniALLASettings_begin_Ini_TMe (145 ).pas
Procedure_IniBlacklist_begin_Ini_TMemIn (144 ).pas
Procedure_RemoveSubStr_aList_TStringLis (136 ).pas
Procedure_SetFormModel_AeForm_IInterfac (8 ).pas
Procedure_SetFurnitureMarkerState_AsFur (21 ).pas
Procedure_tempPerkFunctionSetup_begin_T (156 ).pas
Procedure_YggremoveInvalidEntries_rec_I (160 ).pas
Prompt_For_Three_Strings_Using_A_Dialog (27 ).pas
Prompt_For_Two_Strings_Using_A_Dialog_B (26 ).pas
Prompt_For_Up_To_Ten_Strings_Using_A_Di (28 ).pas
Reassembles_and_then_adds_to_all_outfit (12 ).pas
Recount KSIZ, COCT, LLCT, PKCU, PRKZ, SPCT, INAM, and QNAM subrecords.pas
Reduces_a_BOD_to_an_associated_BOD_func (73 ).pas
Reduces_a_list_of_armor_keywords_into_a (75 ).pas
references , Remove same against the master cell.pas
references, Redirect.pas
references, Remove duplicate .pas
references, Remove excess .pas
references, Remove percentage of of specific object.pas
References, Undelete and Disable .pas
REGION_Delphi_Syntax_Helpers_Copies_The (2 ).pas
REGION_Functions_For_Working_With_Conta (10 ).pas
REGION_Functions_For_Working_With_FormL (13 ).pas
REGION_Functions_For_Working_With_Furni (16 ).pas
REGION_Functions_For_Working_With_Gener (7 ).pas
REGION_Functions_For_Working_With_Keywo (22 ).pas
REGION_General_Shorthands_For_Working_W (3 ).pas
REGION_PromptForEnum_AsTitle_AsLabel_As (29 ).pas
REGION_UI_Utility_Helpers_Helper_Method (24 ).pas
Remove_invalid_entries_from_containers_ (68 ).pas
Removes_a_LL_entry_Returns_removed_elem (62 ).pas
Removes_an_entry_that_contains_substr_P (113 ).pas
Removes_an_entry_that_contains_substr_P (116 ).pas
Removes_any_file_suffixes_from_a_File_N (80 ).pas
Removes_duplicate_strings_in_a_TStringL (81 ).pas
Removes_invalid_entries_from_containers (67 ).pas
Removes_records_dependent_on_a_specifie (5 ).pas
Removes_s_from_the_end_of_s_if_found_mt (42 ).pas
Removes_spaces_from_a_string_function_R (60 ).pas
Replace Components with Scrap in COBJ Records.pas
Replace Substring.pas
Replaces_aRecord_with_bRecord_in_aLevel (64 ).pas
Resource_Library_For_TES_Edit_Scripting (1 ).pas
Restore Material Swap Fields.pas
RESTRUCTURE_OTFT_RECORDS_Debug_if_debug (14 ).pas
Returns_A_List_Of_All_Container_Forms_T (12 ).pas
Returns_the_BOD_slot_associated_with_th (24 ).pas
Reverses_a_string_function_ReverseStrin (44 ).pas
Search Elements by Group.pas
Search Elements By Path.pas
Searches_for_string_within_TStringList_ (47 ).pas
serialize-command-json-itemloc.pas
serialize-command-json.pas
serialize-command.pas
Serialize.pas
SerializeJson.pas
SerializeJsonItemLoc.pas
Set ExtraDataFlag.pas
Set_Flag_Values_based_on_input_string_l (34 ).pas
Shifts_all_TForm_components_up_or_down_ (110 ).pas
Shortens_geev_function_geev_e_IInterfac (37 ).pas
Shortens_GetElementNativeValues_functio (38 ).pas
Shortens_SetElementEditValues_function_ (39 ).pas
Shorthand_To_Create_A_Form_With_A_Given (6 ).pas
Shows_A_Yes_No_Box_With_The_Specified_L (30 ).pas
Skyrim - Add keywords.pas
Skyrim - Add shadow bias to lights.pas
Skyrim - Book Covers Patch.pas
Skyrim - Check edge links in navmeshes.pas
Skyrim - Check script properties.pas
Skyrim - Clean edge links in navmeshes.pas
Skyrim - Convert BOOK to SCRL.pas
Skyrim - Convert LIGH record with mesh to STAT or MISC.pas
Skyrim - Copy book text only from master record.pas
Skyrim - Copy cells settings.pas
Skyrim - Copy VMAD subrecord.pas
Skyrim - Create patch for ClimatesOfTamriel and SoundsOfSkyrim-TheWilds.pas
Skyrim - Export and import weapons stats from spreadsheet file.pas
Skyrim - Filter by script.pas
Skyrim - Find uncompressed records.pas
Skyrim - List actors with more than one vendor faction.pas
Skyrim - List interior cells.pas
Skyrim - List old version plugins.pas
Skyrim - List used scripts.pas
Skyrim - Make outfits from inventories.pas
Skyrim - Ore Veins don't respawn.pas
Skyrim - Papyrus Resource Library.pas
Skyrim - Read Books Aloud.pas
Skyrim - Remove frequence variance from sound descriptors.pas
Skyrim - Remove invalid entries.pas
Skyrim - Reuse faces.pas
Skyrim - Set first person flags on armors affected by specific plugin.pas
Skyrim - Set HavokDontSettle flag on BOOK references.pas
Skyrim - Set HavokDontSettle flag on refs using models from list.pas
Skyrim - Show references from location.pas
Skyrim - Tree LOD files patcher.pas
Skyrim - Tweak bloom, eyes adaptation, tint.pas
Skyrim SE - Generate Large References.pas
SPECIFIC_OTFT_TYPES_INTEGER_if_slPair_C (19 ).pas
SPECIFIC_OTFT_TYPES_NO_WITHOUT_end_else (20 ).pas
SPECIFIC_OTFT_TYPES_OTHER_end_else_begi (22 ).pas
SPECIFIC_OTFT_TYPES_PRE_CHECK_Begin_deb (18 ).pas
SPECIFIC_OTFT_TYPES_SIMPLE_end_else_if_ (21 ).pas
Stuff_below_this_is_probably_added_by_y (140 ).pas
Takes_a_single_armor_keyword_and_return (74 ).pas
This_adds_a_name_value_pair_in_a_way_th (43 ).pas
This_function_will_allow_you_to_find_th (27 ).pas
This_is_just_a_ghetto_way_of_replacing_ (40 ).pas
TIER_ASSIGNMENT_slItem_Clear_Weapon_tie (52 ).pas
TIER_DETECTION_Replace_EditorID_with_Ga (53 ).pas
Translator, FO3 and FNV.pas
trees, Scale references.pas
Trims_all_the_string_in_a_list_function (78 ).pas
Unit_CustomFunctionList_pascal (3 ).pas
Unlevel Perks.pas
version, Update records form .pas
water level, Set default  in exterior cells with HasWater flag.pas
Weather Editor.pas
Worldspace browser.pas
Worldspace change height.pas
Worldspace copy landscape area to another worldspace.pas
Worldspace copy landscape.pas
Worldspace crop.pas
Worldspace displacement.pas
Worldspace move references into another worldspace.pas
Worldspace region change height.pas
Worldspace region move.pas
Worldspace scale refs position.pas