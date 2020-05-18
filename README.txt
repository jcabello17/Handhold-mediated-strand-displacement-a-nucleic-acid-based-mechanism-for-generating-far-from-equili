Welcome to my data repository!
This repository comes with the paper: 
Handhold-mediated strand displacement: a nucleic acid-based mechanism for generating far-from-equilibrium assemblies through templated reactions
Javier Cabello-Garcia, Wooli Bae, Guy-Bart V. Stan and Thomas E. Ouldridge*
Department of Bioengineering and Centre for Synthetic Biology, Imperial College London, London, U.K.
*e-mail: t.ouldridge@imperial.ac.uk 

------------------
FOLDERS
------------------
>Matlab:	Contains the scripts used during the anaysis of the experiments
	>>Fitting versions: 	All the scripts used during the fitting. Read the README inside folder for further clarification.
	>>Transforming: 	All the scripts used to merge the experimental files. Read the README inside folder for further clarification.
		
>Original_files:	.csv files that contain the experimental data
	>>Raw_files:	The files that have to be merged using the scripts in the Matlab/Transforming files
			They already contain the modifications described in Raw_files_modifications.txt
			They are organised by type of experiment
		>>>Detachment:			The experiments that analyse the handhold detachment. Transformed with Matlab/Transforming/Green_Red_HHD
			>>>>Noisy:			Inside this folder there are the first iterations used to estimate Keq. Their values where still used on the final results.
			>>>>Reporter:			0/2/3 experiment. Fitted with a different script to obtain the value of kreporter.
		>>>Detachment_without_RQ	The experiments that analyse the handhold detachment in the absence of reporter RQ. Transformed with Matlab/Transforming/Red_HHD2
		>>>Handhold_mediated_25		Handhold mediated displacement characterisations at 25 degrees C. Transformed with Matlab/Transforming/Green
		>>>Handhold_mediated_37		Handhold mediated displacement characterisations at 37 degrees C. Transformed with Matlab/Transforming/Green
		>>>RQ_25			Reporter reaction characterisations at 25 degrees C. Transformed with Matlab/Transforming/Green
		>>>RQ_37			Reporter reaction characterisations at 37 degrees C. Transformed with Matlab/Transforming/Green
		>>>Specific			Specific production of duplexes determined by their handholds. This files were merged manually (See README in Original_Files/Raw_files/Specific
		>>>Toehold_mediated_25		Toehold mediated displacement characterisations at 25 degrees C. Transformed with Matlab/Transforming/Green
		>>>Toehold_mediated_37		Toehold mediated displacement characterisations at 37 degrees C. Transformed with Matlab/Transforming/Green
		And some files, that serve as template to fill from the fittings (They are required for Handhold_Mediated_Strand_Displacement fitting):
			>>>Estimated_Kdetach.xlsx
			>>>Results_M5
			>>>Results_Reporter 	
		Read the README in the fittings folder for further clarification on their use.
	
>Results: The results obtained and published in the paper
		It contains the same folders as Original_files/Raw_files
		It also contains the results from all characterisations ordered in several files:
	>>Estimated_Kdetach.xlsx: Free energies calculated for each handhold condition and its value with respect of k_bind
	>>Results_kb.xlsx: Results from the fitting of 20 nt handholds and toeholds longer than 1 nt.
	>>Results_M5.xlsx: Results from the fitting of toehold_mediated strand displacement systems.
	>>Results_Mb.xlsx: Results from the fitting of handhold medaited strand displacement systems. The file contain the results for each temperature at the units given by the script (1/nm.min) and at a different pages, the constants at standard units (1/M.s)
	>>Results_Reporter.xlsx: Results from the fitting of RQ assays.

>Figures:The folder containing all the archives from where plots where created.