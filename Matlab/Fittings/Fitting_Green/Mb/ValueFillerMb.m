clc
TEMPERATURE=25;
if TEMPERATURE==37
    n=3;
    
else
    n=1;
end
%Define a default folder
folder= uigetdir('C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos','Select Experiment folder');
%Select all the xlsx files in the selected folder (create a matrix with all
%the names).

Files=dir(strcat(folder,'\*.xlsx'));
%Give error if no xlsx files are found in the folder
if isempty(Files)
    message = sprintf('No .xlsx files were found', Files);
    uiwait(warndlg(message));return
end
%Select file to save data
[a,foldrep]= uigetfile('.xlsx','Select K5file','C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos');
foldrep=strcat(foldrep,a);

for jjj=1:size(Files,1)
    count=[];
    %Get the name of the file
    file=getfield(Files(jjj), 'name')
    %Add the name of the file to the folder to call the file
    file=strcat(folder,'\',file);
    [~,wells]=xlsread(file,1,'B2:BA2');
    [data,~]=xlsread(file,3,'B3:BA8');
    [~,position]=xlsread(foldrep,n,'A1:DA1');
    while ~isempty(wells)
        index=contains(wells,wells(1));
        data2=data(:,index);
        Sp=wells(1);
        wells(index)=[];
        data(:,index)=[];
        p=find(contains(position,Sp)==1);
        p=p(1)+1; 
            if p>26 && p<53
                pos1=strcat('A',char('A'+(p-27)));
            elseif p>52 && p<79
                pos1=strcat('B',char('A'+(p-53)));
            elseif p>78
                pos1=strcat('C',char('A'+(p-79)));
            else
                pos1=char('A'+p-1);%Get the column
            end
        xlswrite(foldrep,data2(:,1),n,strcat(pos1,'2'));
        

    end
end