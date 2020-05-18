 %DATA LOADING FROM THE xlsx
clc
temp=25;
if temp==37
    n=4;
else
    n=2;
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
[a,foldrep]= uigetfile('.xlsx','Select Kreporterfile','C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos');
foldrep=strcat(foldrep,a);

for jjj=1:size(Files,1)
    count=[];
    %Get the name of the file
    file=getfield(Files(jjj), 'name')
    %Add the name of the file to the folder to call the file
    file=strcat(folder,'\',file);
    [~,wells]=xlsread(file,3,'B1:CA1');
    [data,~]=xlsread(file,3,'B17:CA23');
    %Conversion of units data
    index=data(7,:)==0;
    if find(index==1)
        data(:,index)=[];
        wells(:,index)=[];
    end
    %Transform variables to real units
    data(1,:)=data(1,:)/60;
    data(2,:)=data(2,:)/60;
    data(3,:)=(data(3,:)*(10.^9))./60;
    data(5,:)=(data(5,:)*(10.^9))./60;
    data=data+eps;
    classif=data(5,:)+(data(1,:).*data(3,:)./(data(1,:)+data(2,:)));
    [~,position]=xlsread(foldrep,n,'B1:DA1');
    while ~isempty(wells)
        index=contains(wells,wells(1));
        Cl=sum(classif(index))/length(classif(index));
        Err=std(classif(index))/sqrt(length(classif(index)));
        Sp=wells(1);
        wells(index)=[];
        classif(index)=[];
        p=find(contains(position,Sp)==1);
        p=p(1); %Correction for the empty space
        if p>25 && p<52
            pos1=strcat('A',char('A'+(p-26)));
        elseif p>51 && p<78
            pos1=strcat('B',char('A'+(p-52)));
        elseif p>77
            pos1=strcat('C',char('A'+(p-78)));
        else
            pos1=char('A'+p);%Get the column
        end
        xlswrite(foldrep,Cl,n,strcat(pos1,'13'));
        xlswrite(foldrep,Err,n,strcat(pos1,'14'));
    end
end
    
    
    
    
    
    
  