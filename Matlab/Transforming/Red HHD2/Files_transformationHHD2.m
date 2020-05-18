%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Script designed for transforming the csv file obtained from the plate readers of the lab when doing characterisation analysis. 
%Group the files according to their ID.
%Create a file that contains a time column at its left, the well position
%in the first row, the pre-init values in the next row (depending on the protocol) and the final value
%in the 3rd row. The next rows is just the kinetics.

%Save data in a folder inside the folder you read

%ASSUMPTIONS:
%1-The data are in csv files
%3-The kinetic can have injections. (One per file).
%4-The endpoint is added after with the other files.
%5-Time starts at C7
%6-The files are labelled with three ID'S at A4,B4 and C4 of the form: ID1: Protocol name
%ID2: Step	ID3: Samples

%Javier Cabello (javic.1994@gmail.com)
%%
%DATA LOADING FROM THE CSV
clc
%Define a default folder
folder= uigetdir('C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos','Select Experiment folder');
%Select all the csv files in the selected folder (create a matrix with all
%the names).

Files=dir(strcat(folder,'\*.CSV'));
% %Give error if no xlsx files are found in the folder
if isempty(Files)
    message = sprintf('No .CSV files were found', Files);
    uiwait(warndlg(message));return
end
%Select new folder to save files
mkdir(folder,'Writ')
%%
%Create excel files
for jjj=1:size(Files,1)
   xlstransformHHD2(Files(jjj),folder)
end
%%
mkdir(folder,'Merg')
folder2=strcat(folder,'\Writ');
folder3=strcat(folder,'\Merg');
Files=dir(strcat(folder2,'\*.xlsx'));
%%
%Merge the different steps of the same experiments
filemergHHD2(Files,folder2,folder3);
%%
%Give a value for the concentration using the calibration curve
Files=dir(strcat(folder3,'\*.xlsx'));
fluonormHHD2(Files,folder3);