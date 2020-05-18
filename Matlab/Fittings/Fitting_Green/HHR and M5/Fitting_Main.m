%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This script do the analysis for simple 2nd order reactions i.e. HHR and
%HHM5 files
%Inputs: HHR: File with 4 steps (three steady states and one kinetic)
        %HHM5: File with 6 steps (five steady states and one kinetic)
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
foldrep=strcat(foldrep,'/',a);
%%
%%ID(1) determines which fitting to apply.
for jjj=1:size(Files,1)
    file=getfield(Files(jjj), 'name')
    ID = strsplit(file,'_');
    %%%%%%%%%%%%%% FITTING FOR REPORTER EXPERIMENTS%%%%%%%%%%%%%
        if contains(ID(1),'HHR')
            HHRmodule(Files(jjj),folder);

    %%%%%%%%%%%%%%   FITTING FOR M5 EXPERIMENTS    %%%%%%%%%%%%%%%%
        elseif contains(ID(1),'HHM5')
            HHM5module(Files(jjj),folder,foldrep);

        end           
end

%%

%%%%%%%      SAVING ALL PLOTS     %%%%%%%%%%
mkdir(folder,'Plots') % Plots folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = strcat(get(FigHandle, 'Name'),'.fig');
  savefig(FigHandle, strcat(folder,'\Plots\',FigName));
  close(FigHandle);
end
        
    
    
        
        
        
        
        
       
       