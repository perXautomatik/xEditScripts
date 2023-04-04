unit UPF_Plugin_Loader;

	uses mteFunctions;

	// Init global variables:
		var

			// Main function:
				Int_CurrentQL, Int_FilesInThisQL, Int_SigsInThisQL, Int_Loop_Main: integer;
				Arr_Sigs, Arr_SigHomes, Arr_FilesInQL, Arr_SigsInQL: TStringList;

			// File creation/modification:
				File_CurrentQL, Entry_Decription: IInterface;
				Int_LoopMasters: integer;
				Arr_AddAllMasters: TStringList;

			// Sig finder sub function:
				Int_LoopSigs, Int_Loop_FindSigInFile: integer;
				Int_CurrentSigCount, Int_BestSigPos, Int_BestSigCount: integer;
				File_FindSigInFile, El_SigMaster: IInterface;
				Str_BestSigFileList, StrCurrentSigFileList: string;

	function Initialize: integer; begin

		// Startup message:
			ClearMessages();
			AddMessage( ' ' );
			AddMessage('===========================================================');
			AddMessage('                           STARTING ZEDIT PLUGIN LOADER GENERATOR');
			AddMessage('===========================================================');
			AddMessage( ' ' );

		// Init variables:
			InitSigs();
			Arr_FilesInQL := TStringList.Create;
			Arr_SigsInQL := TStringList.Create;
			Int_CurrentQL := -1;
			Quickloader_StartNext();

		// Start at QL0:

		for Int_Loop_Main := 0 to Pred(Arr_Sigs.Count) do begin

			// Get the next best sig to add:
				GetBestNextSig();

			// Add to the QL:
				Int_FilesInThisQL := Int_FilesInThisQL+Int_BestSigCount;
				Int_SigsInThisQL := Int_SigsInThisQL+1;
				if Str_BestSigFileList <> '' then
					Arr_FilesInQL[Int_CurrentQL] := Arr_FilesInQL[Int_CurrentQL]+Str_BestSigFileList;
				Arr_SigsInQL[Int_CurrentQL] := Arr_SigsInQL[Int_CurrentQL]+','+Arr_Sigs[Int_BestSigPos];
				Arr_SigHomes[Int_BestSigPos] := Int_CurrentQL;

			// Output a message showing progress:
				AddMessage( '      ' + Arr_Sigs[Int_BestSigPos]+' added to Quickloader' + IntToStr(Int_CurrentQL) + ', now at ' + IntToStr(Int_SigsInThisQL) + ' sigs/' + IntToStr(Int_FilesInThisQL) + ' files.' );

		end;

		// Create the final QL:
			Quickloader_Finish();

		// Finale message:
			AddMessage( ' ' );
			AddMessage('===========================================================');
			AddMessage('                           FINISHED ZEDIT PLUGIN LOADER GENERATOR');
			AddMessage('===========================================================');

	end;

	function Quickloader_StartNext(): null; begin
		Arr_FilesInQL.Add('');
		Arr_SigsInQL.Add('');
		Int_CurrentQL := Int_CurrentQL+1;
		Int_FilesInThisQL := 0;
		Int_SigsInThisQL := 0;
	end;

	function Quickloader_Finish(): null; begin

		// Display something to the screen:
			AddMessage( ' ' );
			AddMessage('-----------------------------------------------------------');
			AddMessage( ' ' );
			AddMessage( 'Finished calculating Quickloader' + IntToStr(Int_CurrentQL) );
			AddMessage( ' ' );
			AddMessage( IntToStr(Int_SigsInThisQL) + ' sigs: ' + Arr_SigsInQL[Int_CurrentQL]);
			AddMessage( ' ' );
			AddMessage( IntToStr(Int_FilesInThisQL) + ' files: ' + Arr_FilesInQL[Int_CurrentQL]);
			AddMessage( ' ' );

		// Create the file:
			AddMessage( 'Creating QuickLoader plugin...' );
			File_CurrentQL := FileByName('ZKVSortLoader' + IntToStr(Int_CurrentQL) + '.esp');
			if GetLoadOrder(File_CurrentQL) < 0 then File_CurrentQL := AddNewFileName('ZKVSortLoader' + IntToStr(Int_CurrentQL) + '.esp',true);
			AddMessage( ' ' );

		// Set the description:
			AddMessage( 'Setting description...' );
			Entry_Decription := Add(ElementByIndex(File_CurrentQL,0), 'SNAM', false);
			SetEditValue(Entry_Decription, 'ZKVSortLoader:' + Arr_SigsInQL[Int_CurrentQL]);
			AddMessage( ' ' );

		// Add the masters:
			AddMessage( 'Adding ' + IntToStr(Int_FilesInThisQL) + ' files as masters...' );
			Arr_AddAllMasters := TStringList.Create;
			Arr_AddAllMasters.Delimiter := ';';
			Arr_AddAllMasters.StrictDelimiter := True;
			Arr_AddAllMasters.DelimitedText := Arr_FilesInQL[Int_CurrentQL];
			for Int_LoopMasters := 0 to Pred(Arr_AddAllMasters.Count) do begin
				if Arr_AddAllMasters[Int_LoopMasters] <> '' then
					AddMasterIfMissing(File_CurrentQL,Arr_AddAllMasters[Int_LoopMasters]);

			end;
			AddMessage( ' ' );

		// Display something to the screen:
			AddMessage( 'Finished creation Quickloader' + IntToStr(Int_CurrentQL) );
			AddMessage( ' ' );
			AddMessage('-----------------------------------------------------------');
			AddMessage( ' ' );

	end;

	function GetBestNextSig(): null; begin

		Int_BestSigCount := 9999;
		for Int_LoopSigs := 0 to Pred(Arr_Sigs.Count) do begin

			// Does this signature already have a home? Move on.
				if Arr_SigHomes[Int_LoopSigs] <> -1 then
					Continue;

			// Count files with overwriting records of this sig:
				Int_CurrentSigCount:=0;
				StrCurrentSigFileList:='';
				for Int_Loop_FindSigInFile := 1 to Pred(FileCount) do begin
					// Which file are we working with?
						File_FindSigInFile := FileByIndex(Int_Loop_FindSigInFile);
					// Does this file have this sig type?:
						if Assigned(GroupBySignature(File_FindSigInFile,Arr_Sigs[Int_LoopSigs])) then begin
							// Bail if there's no conflict here:
								El_SigMaster:=ElementByIndex(GroupBySignature(File_FindSigInFile,Arr_Sigs[Int_LoopSigs]),0);
								if Equals(MasterOrSelf(El_SigMaster),El_SigMaster) then
									Continue;
							// Still here? Valid file/sig/conflict. Take note of it and all masters:
								AddFileAndMasters(Int_Loop_FindSigInFile);
						end;
					// Already have more files than a better alternative? Stop trying:
						if Int_CurrentSigCount>Int_BestSigCount then break;
				end;

			// Remember this one if it's the highest homeless so far:
				if (Int_CurrentSigCount<Int_BestSigCount) then begin
					Int_BestSigCount:=Int_CurrentSigCount;
					Int_BestSigPos:=Int_LoopSigs;
					Str_BestSigFileList:=StrCurrentSigFileList;
					// If it's zero or one, it's free/cheap lunch. Take it!
						if Int_CurrentSigCount<2 then
							exit;
				end;

		end;

		// Did the best option bust the limit? Make a new QL:
			if Int_CurrentSigCount+Int_FilesInThisQL>200 then begin
				Quickloader_Finish();
				Quickloader_StartNext();
			end;

	end;

	Function AddFileAndMasters(int_FilePosToAdd: integer): null;
		var
			Arr_MastersList: IInterface;
			Int_MasterLoop: integer;

		begin

			// Don't add duplicate entries:
				if Pos(';' + GetFileName(FileByIndex(int_FilePosToAdd)),Arr_FilesInQL[Int_CurrentQL]+StrCurrentSigFileList) > 0 then
					exit;

			// Add this plug-in to the list:
				Int_CurrentSigCount:=Int_CurrentSigCount+1;
				StrCurrentSigFileList:=StrCurrentSigFileList+';'+GetFileName(FileByIndex(int_FilePosToAdd));

			// Already have more files than a better alternative? Stop trying:
				if Int_CurrentSigCount>Int_BestSigCount then exit;

			// And iterate its masters, doing the same:
				Arr_MastersList := ElementByPath(ElementByIndex(FileByIndex(int_FilePosToAdd),0),'Master Files');
				for Int_MasterLoop := 0 to ElementCount(Arr_MastersList) - 1 do AddFileAndMasters( GetLoadOrder( FileByName( geev(ElementByIndex(Arr_MastersList, Int_MasterLoop),'MAST') ) ) + 1 );

	end;

	function InitSigs(): null; begin

		// Define the signatures to find:
			Arr_Sigs := TStringList.Create;
				Arr_Sigs.Add('ALCH');
				Arr_Sigs.Add('AMMO');
				Arr_Sigs.Add('ARMO');
				Arr_Sigs.Add('KYWD');
				Arr_Sigs.Add('SPEL');
				Arr_Sigs.Add('WEAP');
				Arr_Sigs.Add('BOOK');
				Arr_Sigs.Add('MISC');
				Arr_Sigs.Add('SLGM');

		// Start with no sigs having homes:
			Arr_SigHomes := TStringList.Create;
			for Int_LoopSigs := 0 to Pred(Arr_Sigs.Count) do begin
				Arr_SigHomes.Add(-1);
			end;

	end;

end.
