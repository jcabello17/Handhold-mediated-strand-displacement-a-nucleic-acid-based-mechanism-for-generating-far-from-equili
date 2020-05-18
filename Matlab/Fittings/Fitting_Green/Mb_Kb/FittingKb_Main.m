
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This script do the analysis for systems of ODE  i.e. HHM
%Inputs: HHMb: File with 6 steps (five steady states and one kinetic)

%Outputs: Create in each file a sheet with the parameters and the modelised
%kinetic.
%Produce a graph that shows the fitted experimental data and the residuals
%normalised by the values of the modelised trajectory. 


%ASSUMPTIONS:
%Working with the output of Files_Transformation
%Javier Cabello (javic.1994@gmail.com)


%Define folder with the files
folder= uigetdir('C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos','Select Experiment folder');
%Select all the xlsx files in the selected folder (create a matrix with all
%the names.
folder2=strcat(folder,'\*.xlsx');
Files=dir(folder2);
%Give error if no xlsx files are found in the folder
if isempty(Files)
    message = sprintf('No .xlsx files were found', Files);
    uiwait(warndlg(message));return
end

[a,foldrep]= uigetfile('.xlsx','Select Kreporterfile','C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos');
foldrep=strcat(foldrep,a);
[a,foldM5]= uigetfile('.xlsx','Select M5file','C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos');
foldM5=strcat(foldM5,a);
mkdir(folder,'Matrices') % Plots folder
%%
for jjj=1:size(Files,1)
    file=getfield(Files(jjj), 'name')
    %%%%%%%%%%%%%% FITTING FOR Mb EXPERIMENTS%%%%%%%%%%%%%
            HHKbmodule(Files(jjj),folder,foldrep,foldM5); 
end


%%%%%%%      SAVING ALL PLOTS     %%%%%%%%%%
mkdir(folder,'Plots') % Plots folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = strcat(get(FigHandle, 'Name'),'.fig');
  savefig(FigHandle, strcat(folder,'\Plots\',FigName));
end
        