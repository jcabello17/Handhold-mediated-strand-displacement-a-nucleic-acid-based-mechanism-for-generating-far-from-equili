%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
%%
for jjj=1:size(Files,1)
    file=getfield(Files(jjj), 'name')
    ID = strsplit(file,'_');
    %%%%%%%%%%%%%% FITTING FOR REPORTER EXPERIMENTS%%%%%%%%%%%%%
            HHD2module(Files(jjj),folder);
end

%%
%%%%%%%      SAVING ALL PLOTS     %%%%%%%%%%
mkdir(folder,'Plots') % Plots folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = strcat(get(FigHandle, 'Name'),'.fig');
  savefig(FigHandle, strcat(folder,'\Plots\',FigName));
end
        
    
    
        
        
        
        
        
       
       