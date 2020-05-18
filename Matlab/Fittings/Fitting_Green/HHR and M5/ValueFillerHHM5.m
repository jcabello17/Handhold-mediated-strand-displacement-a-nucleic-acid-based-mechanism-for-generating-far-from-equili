% for Reporter constant and toehold mediated
%DATA LOADING FROM THE xlsx
clc
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
[a,foldrep]= uigetfile('.xlsx','Select Kreporterfile','C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos');
foldrep=strcat(foldrep,a);
%%
for jjj=1:size(Files,1)
    count=[];
    %Get the name of the file
    file=getfield(Files(jjj), 'name')
    ID = strsplit(file,'_'); %File Name decomposition to obtain values like Exp Temperature
    if contains(ID(end),'25')
        page=1;
    elseif contains(ID(end),'37')
        page=2;
    end
    %Add the name of the file to the folder to call the file
    file=strcat(folder,'\',file);
    [~,wells]=xlsread(file,1,'B2:DA2');
    [data,~]=xlsread(file,3,'B4:DA4');
    [~,position]=xlsread(foldrep,page,'B1:DA1');
    while ~isempty(wells)
        Sp=wells(1);
        data2=data(1:4);
        wells(1:4)=[];
        data(:,1:4)=[];
        p=find(contains(position,Sp)==1);
        p=p(1); 
            if p>25 && p<52
                pos1=strcat('A',char('A'+(p-26)));
            elseif p>51 && p<78
                pos1=strcat('B',char('A'+(p-52)));
            elseif p>77
                pos1=strcat('C',char('A'+(p-78)));
            else
                pos1=char('A'+p);%Get the column
            end
        if contains(ID(end-1),'5%8%7(2)')'
            xlswrite(foldrep,data2',page,strcat(pos1,'6')); %%%%%%%%%%%%%%%%%%%%%!!!!!!!!!!! CHANGE DEPENDING ON THE TEMPERATURE1
        else
            xlswrite(foldrep,data2',page,strcat(pos1,'2')); %%%%%%%%%%%%%%%%%%%%%!!!!!!!!!!! CHANGE DEPENDING ON THE TEMPERATURE1
        
        end    
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%