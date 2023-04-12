{
	M8r98a4f2s Complex Item Sorter for FallUI (for FALLOUT 4)
	
	A more complex automatic Item Sorting Script.
	Adds language independence and many other features.
	Configuration files can be found in "..\F04Edit\Edit Scripts\M8r Complex Item Sorter" as ini files
	
	Requires: FO4Edit and Ruddy88's Simple Sorter INNR esp.
	Recommended, but not required: FallUI

	Disclaimer
	 Provided AS-IS. No warrenty included. 
	 You can use the script as intended for personal use. 
	 You are not allowed to redistribute, sell or commercialise the scripts in any way.
	
	Author 
	 M8r98a4f2
	
	Credits:
	 Ruddy88 (Author of Simple Sorter. Complex Sorter uses parts of it - Usage is granted by Ruddy88)
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
	AddMessage('Uses parts of Ruddy88 Simple Sorter (Usage granted by Ruddy88)');
	AddMessage('Uses parts of MXPF - Mator''s xEdit Patching Framework by Mator (see MXPF license under M8r Complex Item Sorter\lib\MXPF\license.txt)');
	AddMessage('============================================');
	
	// Start Complex Sorter
	ComplexSorter.run();
end;

end.
