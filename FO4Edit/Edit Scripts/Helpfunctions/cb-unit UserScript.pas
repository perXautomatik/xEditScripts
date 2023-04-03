unit UserScript;
uses dubhfunctions;

function Process(e: IInterface): integer;
var 
orginalName: string;
  m: IInterface;
begin
  if not ElementExists(e, 'FULL') and not ElementExists(e, 'EDID') then
    Exit;


// --------------------------------------------------------------------
// Returns true/false if a string is in a TStringList
// --------------------------------------------------------------------
function InStringList(const s: String; const l: TStringList): Boolean;


// --------------------------------------------------------------------
// Return whether a string matches a RegEx pattern
// --------------------------------------------------------------------
function RegExMatches(ptrn, subj: String): Boolean;

// --------------------------------------------------------------------
// Recursively add value of named field to list
// --------------------------------------------------------------------
procedure RecursiveAddToList(e: IInterface; elementName: String; results: TStringList);

// --------------------------------------------------------------------
// AddMessage
// --------------------------------------------------------------------
procedure Log(const s: String);

{
  FileSelect:
  Creates a form for the user to select a file to be used.
  
  Example usage:
  UserFile := FileSelect('Select the file you wish to use below: ');
}
function FileSelect(prompt: string): IInterface;

// --------------------------------------------------------------------
// Copies a record as an override to a file
// --------------------------------------------------------------------
procedure AddOverrideToFile(const f: IwbFile; const r: IInterface);

// --------------------------------------------------------------------
// Adds a form to a formlist
// --------------------------------------------------------------------
procedure AddRecordToFormList(const f, r: IInterface);

// --------------------------------------------------------------------
// Converts a Formlist or Leveled List to a TStringList
// --------------------------------------------------------------------
function ListObjectToTStringList(e: IInterface): TStringList;

end;

end.



