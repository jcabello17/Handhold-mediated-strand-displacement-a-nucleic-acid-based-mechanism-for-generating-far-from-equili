v.2 of file transforming functions

The purpose of these functions is to use the .csv files produced by the default export of MARS.
The system takes a group of csv files that belongs to the same experiment, normalises its fluorescence,
joins them in order and use a calibration curve to produce a correspondece between fluorescence and reagents concentrations.

Functions:
File_Transform: Main file to run. Select the folder where you have your .csv files
xlstransform: remove negative control and produce xlsx files, called as the exp ID1_ID2_ID3 in a folder called Writ
filemerg: Merge the scripts with the same name in order in a new file called ID1_ID2
fluonorm: normalize the fluorescence with the positive control and create a new sheet with the correspondet product concentration.


Experiment files from CLARIOSTAR should have inside three ID's. The convention used is:
ID1: Type of experiment (i.e. HHR (Reporter experiment) HHMb (Specific reaction experiment) etc) Relevant during xlstransform to determine which step contains the kinetic.
ID2: Species and temperature (i.e. 0%0%7_25, for >3 species it contains the date). Relevant for fluonorm to select the calibration curve with the temperature.
ID3: Number of the experiment step (i.e. St_1, St_2....). Relevant for the merging and to select the treatment.    