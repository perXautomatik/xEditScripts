{
	M8r98a4f2s Complex Item Sorter for FallUI
		based on Ruddy88's VIS-G Auto Patcher
	FALLOUT 4
	
	A more complex automatic Item Sorting Script. 
	Adds language indepence.
	Configuration files can be found in "..\F04Edit\Edit Scripts\M8r Complex Item Sorter" as ini files
	
	Requires: FO4Edit, Ruddy88's Simple Sorter, MXPF and FallUI.

	Disclaimer
	 Provided AS-IS. No warrenty included. 
	 You can use the script as intended for personal use. 
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author 
	 M8r98a4f2
	
	Credits:
	 Rudy88 (Author of original script)
	 Neeanka (Author of DEF_INV)
	 Valdacil (Author of DEF_UI)
	 MatorTheEternal (Author of MXPF)
	 The full F04Edit team
	 Bethesda (Fallout 4)
	
	Hotkey: Ctrl+Y
}

unit UserScriptEx;
uses 'M8r Complex Item Sorter/lib/ComplexSorter';

/////////////////
//    Main     //
/////////////////
function Initialize: Integer;
begin
	AddMessage('============================================');
	AddMessage('M8r Complex Item Sorter (Edition for FallUI)');
	AddMessage('============================================');
	
	// Start Complex Sorter
	ComplexSorter.run();
end;

end.