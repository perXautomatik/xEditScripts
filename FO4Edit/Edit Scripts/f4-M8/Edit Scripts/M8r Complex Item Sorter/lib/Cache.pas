{
	M8r98a4f2s Complex Item Sorter for FallUI - Cache module
		
	FALLOUT 4
	
	Submodule of Complex Sorter. 
	Provides differenc caches and handles them. 
	
	Disclaimer
	 Provided AS-IS. No warrenty included.
	 You can use the script as intended for personal use.
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author
	 M8r98a4f2
}

unit Cache;

var
	_cCachesStorage: TStringList;

implementation

{Init unit}
procedure init();
begin
	if not Assigned(_cCachesStorage) then 
		_cCachesStorage := TStringList.Create;
end;


{Read storage from cache system "Bulk" - which is optimized for bulk adding of unique no doubled items - no gain in first run!}
procedure initBulkStorage(cacheName:String);
var
	cachePath: String;
	cacheInfoPack: TStringList;
	cacheStorageCur, cacheStorageNew: TStringList;
begin
	if _cCachesStorage.indexOf(cacheName) > -1 then begin
		AddMessage('Cache already initialized.');
		Exit;
		end;
		
	cacheStorageCur := THashedStringList.Create;
	cacheStorageNew := TStringList.Create;

	cachePath := sComplexSorterBasePath+'cache\'+cacheName+'.cache';
	if FileExists(cachePath) then begin
		cacheStorageCur.LoadFromFile(cachePath);
		cacheStorageNew.CommaText := cacheStorageCur.CommaText;
		AddMessage('(Loaded cache storage "'+cacheName+'". Entries: '+IntToStr(cacheStorageCur.Count)+')');
		end
	else
		AddMessage('(Created new cache storage "'+cacheName+'")');
		
	// Store info pack
	cacheInfoPack := TStringList.Create;
	cacheInfoPack.addObject('cur', cacheStorageCur);
	cacheInfoPack.addObject('new', cacheStorageNew);
	cacheInfoPack.Values['path'] := cachePath;
	
	
	_cCachesStorage.addObject(cacheName, cacheInfoPack);
end;


{Returns the internal list for quick access. Dont free ;) }
function getDirectAccessCachedEntriesList(const cacheName:String):THashedStringList;
var
	cacheInfoPack: TStringList;
begin
	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	Result := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
end;

{Get one cacheInfoPack from internal caches storage}
function _getCache(const cacheName:String; var cacheInfoPack:TStringList):Boolean;
begin
	if _cCachesStorage.indexOf(cacheName) = -1 then begin 
		AddMessage('No such cache: ' + cacheName);
		Exit;
		end;
	// Found
	Result := true;
	cacheInfoPack := _cCachesStorage.Objects[_cCachesStorage.indexOf(cacheName)];
end;


{Test if a cache exists}
function existsCache(const cacheName:String):Boolean;
begin
	if Assigned(_cCachesStorage) then
		Result := _cCachesStorage.indexOf(cacheName) <> -1;
end;

{Save storage for cache system "Bulk"}
procedure save(cacheName:String; freeAndNilAfter:Boolean);
var
	i, subEntryCnt: Integer;
	cachePath: String;
	cacheInfoPack, cacheStorageCur, cacheStorageNew: TStringList;
begin
	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
		
	cachePath       := cacheInfoPack.Values['path'];
	cacheStorageCur := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];
	
	if Assigned(cacheStorageNew) then begin

		// Convert level two sublists to plain text for saving
		subEntryCnt := 0;
		if cacheInfoPack.values['isLevelTwo'] <> '' then
			for i:= 0 to cacheStorageNew.Count -1 do begin
				cacheStorageNew.ValueFromIndex[i] := cacheStorageNew.Objects[i].CommaText;
				subEntryCnt := subEntryCnt + cacheStorageNew.Objects[i].Count;
				end;
		// Save data
		cacheStorageNew.SaveToFile(cachePath);			
		if cacheInfoPack.values['isLevelTwo'] <> '' then
			AddMessage('(Save cache storage "'+cacheName+'". Entries: '+IntToStr(cacheStorageNew.Count)+'  Subentries: '+IntToStr(subEntryCnt)+')')
		else 
			AddMessage('(Save cache storage "'+cacheName+'". Entries: '+IntToStr(cacheStorageNew.Count)+')');
			
		// Clear cache? 
		if freeAndNilAfter then
			_cleanupCache(cacheName);
			
		end;
end;


{Cleanup one cache storage}
procedure _cleanupCache(cacheName: String);
var
	i: Integer;
	cacheInfoPack, cacheStorageCur, cacheStorageNew: TStringList;
begin
	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageCur := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];

	// Cleanup level two extra
	if cacheInfoPack.values['isLevelTwo'] <> '' then begin
		for i:= 0 to cacheStorageCur.Count -1 do
			cacheStorageCur.Objects[i].Free;
			
		for i:= 0 to cacheStorageNew.Count -1 do
			cacheStorageNew.Objects[i].Free;
			
		end;
		
	// Cleanup default parts
	cacheStorageCur.Free;
	cacheStorageNew.Free;
	cacheInfoPack.Free;
	_cCachesStorage.delete(_cCachesStorage.indexOf(cacheName));
end;

{Inits the level two storage (multiarray like caching with 2 idents) for bulk caches.}
procedure initLevelTwoCache(cacheName: String);
var 
	i, subEntryCnt: Integer;
	cacheInfoPack, cacheStorageCur, cacheStorageNew: TStringList;
begin
	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageCur := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];
	
	// Init level two
	if cacheInfoPack.values['isLevelTwo'] <> '' then begin
		AddMessage('Cache is already level two');
		Exit;
		end;
	cacheInfoPack.values['isLevelTwo'] := '1';

	subEntryCnt := 0;
	for i:= 0 to cacheStorageCur.Count -1 do begin
		cacheStorageCur.Objects[i] := THashedStringList.Create;
		cacheStorageCur.Objects[i].CommaText := cacheStorageCur.ValueFromIndex[i];
		end;
	for i:= 0 to cacheStorageNew.Count -1 do begin
		cacheStorageNew.Objects[i] := TStringList.Create;
		cacheStorageNew.Objects[i].CommaText := cacheStorageNew.ValueFromIndex[i];
		subEntryCnt := subEntryCnt + cacheStorageNew.Objects[i].Count;
		end;
	AddMessage('(Inited cache level two subsystem for "'+cacheName+'". Subentries: '+IntToStr(subEntryCnt)+')')
		
end;

{Saves bulk entry for cache storage "Bulk"}
procedure SetEntry(const cacheName, cacheIdent, newCacheEntry:String );
var 
	existingIndex:Integer;
	cacheInfoPack, cacheStorageCur, cacheStorageNew: TStringList;
begin
 	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageCur := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];

	if newCacheEntry = '' then
		newCacheEntry := 'INVALID';
	existingIndex := cacheStorageCur.IndexOfName(cacheIdent);
	if existingIndex = -1 then
		existingIndex := cacheStorageNew.Add(cacheIdent+'=1');

	cacheStorageNew.ValueFromIndex[existingIndex] := newCacheEntry
end;


{Gets a level two entry from cache. Returns if the entry exists (if createIfNotExists is false or level one cache not exists) }
function getEntrySetLevelTwo(const cacheName, cacheIdent:String; createIfNotExists:Boolean; 
				var sectionCacheCur:THashedStringList; var sectionCacheNew: TStringList ):Boolean;
var
	cacheIndex: Integer;
	cacheInfoPack, cacheStorageCur, cacheStorageNew: TStringList;
begin
 	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageCur := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];

	cacheIndex := cacheStorageCur.indexOfName(cacheIdent);
	if cacheIndex = -1 then begin
		if not createIfNotExists then 
			Exit;
		//AddMessage('ADD empty set: '+cacheIdent);
		cacheIndex := cacheStorageCur.addObject(cacheIdent+'=NEW_ENTRY',THashedStringList.Create);
		cacheStorageNew.addObject(cacheIdent+'=NEW_ENTRY',TStringList.Create);
		end;
	Result := true;
	sectionCacheCur := cacheStorageCur.Objects[cacheIndex];
	sectionCacheNew := cacheStorageNew.Objects[cacheIndex];
end;


{Gets a cache entry from a level two cache}
function getEntryLevelTwo(const cacheName, cacheIdentL1, cacheIdentL2:String):String;
var
	cacheIndexL1: Integer;
	cacheInfoPack, cacheStorageCur: TStringList;
	sectionCacheCur: TStringList;
begin
 	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageCur := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
	
	// Search
	cacheIndexL1 := cacheStorageCur.indexOfName(cacheIdentL1);
	if cacheIndexL1 = -1 then 
		Exit;
	sectionCacheCur := cacheStorageCur.Objects[cacheIndexL1];
	Result := sectionCacheCur.values[cacheIdentL2];
end;


{Sets a level two cache entry - The main index must exist, returns false on non existance}
function setEntryLevelTwo(const cacheName, cacheIdentL1, cacheIdentL2:String; newCacheEntry:String;
	var sectionCacheCur:THashedStringList; var sectionCacheNew:TStringList ):Boolean;
var
	cacheIndexL1, cacheIndexL2: Integer;
	cacheInfoPack, cacheStorageCur, cacheStorageNew: TStringList;
	//sectionCacheNew: TStringList;
begin
 	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageCur := cacheInfoPack.Objects[cacheInfoPack.indexOf('cur')];
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];

	// Search
	cacheIndexL1 := cacheStorageCur.indexOfName(cacheIdentL1);
	if cacheIndexL1 = -1 then 
		AddMessage('doesnt exist');
	if cacheIndexL1 = -1 then 
		Exit;
	Result := true;
	sectionCacheCur := cacheStorageCur.Objects[cacheIndexL1];
	sectionCacheNew := cacheStorageNew.Objects[cacheIndexL1];
	
	cacheIndexL2 := sectionCacheCur.IndexOfName(cacheIdentL2);
	// New entry?
	if cacheIndexL2 = -1 then
		cacheIndexL2 := sectionCacheNew.Add(cacheIdentL2+'=1');
	
	// Set
	sectionCacheNew.ValueFromIndex[cacheIndexL2] := newCacheEntry;
end;


{Returns sum of level two entries}
function getLevelTwoEntriesCount(const cacheName:String; removeValAndTaintCount:Boolean):Integer;
var 
	i:Integer;
	cacheInfoPack, cacheStorageCur, cacheStorageNew: TStringList;
begin
 	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];
	Result := 0;
	for i := 0 to cacheStorageNew.Count - 1 do
		Result := Result + cacheStorageNew.Objects[i].Count;
	// Remove count for validation str and taints
	if removeValAndTaintCount then 
		Result := Result - cacheStorageNew.Count * 2;
end;

{Returns count of cache entries}
function getEntriesCount(const cacheName:String):Integer;
var 
	cacheInfoPack, cacheStorageNew: TStringList;
begin
 	// Get cache info
	if not _getCache(cacheName, cacheInfoPack) then
		Exit;
	cacheStorageNew := cacheInfoPack.Objects[cacheInfoPack.indexOf('new')];
	Result := cacheStorageNew.Count;
end;


{Cleanup unit}
procedure cleanup();
	var i:Integer;
begin
	FreeAndNil(_cCachesStorage);
end;

end.