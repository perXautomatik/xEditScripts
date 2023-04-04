unit CustomFunctionList;

{
```pascal
```
}
{ General Notes
  If the code says it expects 'end;' but finds 'end of file' check that 'if' statements are followed by 'then' and 'for' statement are followed by 'do'
}


var
	slGlobal, slProcessTime: TStringList;
	selectedRecord: IInterface;

	Recipes,MaterialList, TempPerkListExtra:TStringList;
	Ini: TMemIniFile;
	HashedList, HashedTemperList: THashedStringList;

	ignoreEmpty, disallowNP: boolean;
	DisKeyword, disWord: TStringList;

	defaultOutputPlugin: string;
	defaultGenerateEnchantedVersions, defaultReplaceInLeveledList, defaultAllowDisenchanting, ProcessTime: boolean;
	defaultBreakdownEnchanted, defaultBreakdownDaedric, defaultBreakdownDLC, defaultGenerateRecipes, Constant: boolean;
	defaultChanceBoolean, defaultAutoDetect, defaultBreakdown, defaultOutfitSet, defaultCrafting, defaultTemper: boolean;
	defaultChanceMultiplier, defaultEnchMultiplier, defaultItemTier01, defaultItemTier02, defaultItemTier03: integer;
	defaultItemTier04, defaultItemTier05, defaultItemTier06, defaultTemperLight, defaultTemperHeavy: integer;
	firstRun: boolean;


