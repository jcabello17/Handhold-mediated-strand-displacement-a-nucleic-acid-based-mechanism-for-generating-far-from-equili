v.5 of Fitting functions
The purpose of these functions is to use the .xlsx files produced by the Transforming Scripts (See previous folder).
From these files, the scripts do a fitting using the function fminsearch of the kinetics in these files.
The parameters are estimated from the conditions of the experiments and the measured concentrations in the experiments.


I recommend doing the fittings in groups of 5-6 files, so the output plots do not blow-up your computer.

>Fitting_Green HHR and HHM5: Used for the reporter assays (HHR) and the toehold mediated displacement (HHM5). Obtain the reporter rate and the toehold rate.
			     Mb: Fit experiments in groups of 4 replicas at different concentrations. Used for the handhold mediated displacement experiments (HHMb). Obtain three constants kbind (rate of binding to the handhold) kdetach (rate of detaching from the handhold) and k0 (rate of the displacement when bound).
	>HHR and M5
	!!!!!!!!!INSTRUCTIONS for fitting RQ (HHR) experiments:
		-Run Fitting_Main. It will ask for the folder with your Merged files (RQ)
		-First fit the RQ files to obtain the krep values.
		-It will ask you for the file with the constant krep.If you are going to fit RQ experiments, select any file.
		-Run the script and then open HHRmodule: Change "round" variable to 2. You can also change the kmean value (with the one you obtained), that will be used as initial condition for the fittings in round 2
		-Run for the second round, and then change "round" variable to 3. Fitting finished
		-Now each excel file will contain the result from the fitting and the trajectory of the fitted line in page 4. A subfolder with the plots is also created.  
     
	!!!!!!!!!INSTRUCTIONS for fitting Toehold-mediated (HHM5) experiments:
		-Run Fitting_Main. It will ask for the folder with your Merged files (Toehold-mediated)
		-Dump the results from your RQ fittings to an excel file with the same structure as Results_Reporters. You can use the script ValueFillerHHRM5 to dump into the empty Results_Reporters file.
		-It will ask you for the file with the constant krep.Select the Results_Reporters.xlxs file.
		-Run the script (It will take some time to fit everything) and then open HH5module: Change "round" variable to 2.
		-Run for the second round, and then change "round" variable to 3. Fitting finished.
     		-Now each excel file will contain the result from the fitting and the trajectories of the expected reacted reporter concentration and reacted target. A subfolder with the plots is also created.  
     		-Dump the result from your fitting into Results_M5.xlsx with the script ValueFillerHHR/M5.

		       ->>Fitting_Main: Fitting_Module (For both kind of experiments)
					Load the experiments folder and the file where you store the kreporter values! (Not necessary for HHR fittings).
			>>HHM5module: Fitting of HHM5 experiments. Needs Krep, give K5
			>>HHRmodule:Fitting of HHR experiments. Give krep
			>>PlotM5: Produce trajectories with the obtained constants, for plotting them.
			>>SecondOrderFittingHHM5: The function that is minimised with fminsearch. Produce trajectories with ode45 using a model of 2 ODE
			>>SecondOrderFittingHHR: he function that is minimised with fminsearch.
		       ->>ValueFillerHHR: Dump the results from the HHR fittings in Results_Reporter
						Run directly, it will ask for the folder with the results and the file where to dump the results.	
		       ->>ValueFillerHHM5: Dump the results from the HHM5 fittings in Results_M5
						Run directly, it will ask for the folder with the results and the file where to dump the results.	
	
	>Mb_kb These functions are used to calculate the "fixed" kbind for the experiments
	Fixed Km -> 10^10.Fixed Kdetach -> 10^-20
	!!!!!!!!!!INSTRUCTIONS for fitting handhold-mediated (HHMb) experiments to obtain kb.
	       	-Separate the files in the handhold-mediated experiments with handhold=20 and toehold bigger than 1.
		-Run fittingKb_Main.It will ask for the folder with the files and Results RQ and M5.
		-After it finishes, enter in HHKbmodule and change the variable "round" to 2 and run again.
		-Get the results of kb from the files and calculate its mean and Std to use it in the Handhold-mediated fittings.	

		       ->>FittingKb_Main:Used for fitting HHMb experiments.It requires a file that contains the kreporter and the k5 constants.
						Produces a matrix of results for all the initial conditions tested during the fittings and also writes and plots the results.
			>>HHKbmodule:Fitting of the HHMb experiments, needs krep and k5.
			>>FittingHHKb: The function minimised by fminsearch. It contains an ODE system of 7 equations. Trajectories produced with ode23s.
			>>PlotMb: Produce trajectories for the fitted line to plot them.

	>Mb. These functions are used to calculate the kmigration and kdetach for each condition.
	!!!!!!!!!INSTRUCTIONS for fitting handhold-mediated (HHMb) experiment.
		-Run FittingMb_Main. It will ask for the folder with your Merged files (Handhold-mediated) and for Results_Reporters and Results_M5. Aditionally it will ask for the file containing all the expected kdetach values as initial conditions: Estimated_Kdetach.xlsx
		-open HHMbmodule and introduce the mean kbinding values and their stdev for 25 and 37 (The ones you obtained from HHMb_kb).
		-ALSO introduce the addres where you will have the file Estimated_Kdetach. 
		-Run the script (It will take some time to fit everything) and then open HHMbmodule: Change "round" variable to 2.
		-Run for the second round, and then change "round" variable to 3. Fitting finished. (Some conditions require 2 fittings at round 3 to reach to the local minimum, so run it twice)
     		-Now each excel file will contain the result from the fitting and the trajectories of the expected reacted reporter concentration and reacted target. A subfolder with the plots is also created and a file with all the different results from the different kmigration initial conditions (Matrices.xlsx). 
		-Change the "indiv" parameter to 1 in the file FittingMb_Main.m to start the individual fitting of each trace. It will save these in each file in page 3 under the previous results. It will also produce individual plots of the fittings. These results were used to calculate the error of the fitted parameters.
		-Be sure to also introduce the kbind mean and std in "HHMbindividualfit.m"
		-Dump all the results in Results_Mb with the function ValueFillerMb
			>>FittingHHMb:The function minimised by fminsearch. It contains an ODE system of 7 equations. Trajectories produced with ode23s.
			>>FittingHHMb_Nohh:Version of the previous function when the handhold is of length 0. It only fits time and Mb concentration.
			>>FittingHHMbsimp:The function minimised by fminsearch when individually fitting. It contains an ODE system of 7 equations. Trajectories produced with ode23s.
		       ->>FittingMb_Main:Used for fitting HHMb experiments.
					It requires a file that contains the kreporter and the k5 constants.
					Produces a matrix of results for all the initial conditions tested during the fittings and also writes and plots the one with less error.
			>>HHMbmodule: One of the functions called by FittingMb_Main. Fit the trajectories in groups of 4.
			>>HHMbindividualfit:One of the functions called by FittingMb_Main. Fit the trajectories individually.
			>>PlotMb:Produce trajectories for plotting the fitting.
			>>SecondOrderFittingHHM5:FittingHHMb_Nohh but for the invidual fittings.
			>>ValueFillerMb:Move the results from the fitted folders in the Results_Mb file.
			>>ValueFillerInd:Move the results from the individual fittings to Results_Mb file.

>Fitting_Red_Green: Used for the detachment assays that include the RQ reporter
	!!!!!!!!!INSTRUCTIONS: Open Fitting_Main and change the value of the variable reporter to 1.
			-Run the script selecting the folder where you have the merged file for 0%2%3 and fit it.
			-Calculate the mean of the produced krep2 and copy it.
			-Paste krep2 in the file "FittingHHD" and set the variable "reporter" to 0 in "Fitting_Main"
			-Run the script, and select the rest of your files. Remember to also fit the noisy trajectories.
			-For 20%0%0 the fitting result is utter crap because nothing happens.
			       ->Fitting_Main:The file to open
				>FittingHHD:The file with the ODE model
				>HHDmodule: The file called by Fitting Main
				>HHDmodule0:The file called by Fitting Main to fit the reporter
				>PlotHHD:Produce trajectories for the plot
				>PlotM5:Produce trajectories for the reporter plot
				>SecondOrderFittingHHDThe file with the ODE model for reporter fitting

>Fitting_Red: Used for the detachment assays that do not include the RQ reporter
	!!!!!!!!!INSTRUCTIONS:Simply open FittingHHD2, put the kreporter value and run the script as in Fitting_Red_Green.	
			       ->Fitting_Main: The main file
				>FittingHHD2: The file with the ODE model
				>HHD2module: The file called by Fitting Main
				>PlotHHD2: Produce trajectories for the plot

>TimeCalculation: Produce the half-lives for each condition given the parameters in Results_Mb.
	!!!!!!!!!INSTRUCTIONS: Run the file ReactionTime selecting the Results_Mb file.
			-Set parameter page to 1 or 3 depending on the results you want. page=1 for 25 degrees and =2 for 37 degrees.
			-The result for the toehold and handhold half-lives is not written anywhere. Is just stored in the variable M. From there you can just paste it wherever you want.
			-The handhold-mediated half-lives for trajectories without handhold and toehold=0 are bugged. Do not consider them.
				>ReactionTime: Main file. Produce the variable M that contains the half-lives of handhold-mediated strand displacement in the first column and toehold in the second. With conditions in the same order as they appear in Results_Mb.
				>timesimulation1: Where the solved ODE system is.



