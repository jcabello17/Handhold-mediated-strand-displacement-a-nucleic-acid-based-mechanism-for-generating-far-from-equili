function   xlstransf(Files,folder)
    %Script designed for transforming the csv file obtained from the plate reader BMG Clariostar into an excel file with the 
    %correct format.
    %For Baseline measurements, just remove the mean of negative controls and give the median
    %of the species and positive control
    %In the case of an injection: - remove the values before the injection
    %                             - set the time as 0 for the injection
    %                               time
    %                             - remove negative control
    %Javier Cabello (javic.1994@gmail.com)

%%

    count=[];
    %Get the name of the file
    file=getfield(Files, 'name')
    %Add the name of the file to the folder to call the file
    file=strcat(folder,'\',file);
    %Read well columns
    [~,ID1]=xlsread(file,1,'A4');
    [~,ID2]=xlsread(file,1,'B4');
    [~,ID3]=xlsread(file,1,'C4');
    ID1=regexprep(ID1,'(ID1: )','');
    ID2=regexprep(ID2,'(ID2: )','');
    ID3=regexprep(ID3,'(ID3: )','');
    ID3=strrep(ID3,'/','%');
    %ID1 module: Determine the procedure for two types of protocols: HHR and
    %HHM*
    %ID2 determine the type of analysis 
    
    %Name of the new file;
     write=char(strcat(folder,'\Writ\',ID1,'_',ID3,'_',ID2,'.xlsx'));
    
    %Read well columns
    [~,date]=xlsread(file,1,'B2');
    [~,wells]=xlsread(file,1,'A9:A104');
    Index = find(contains(wells,' '));
    %Correction if there's info at the bottom of the file. Remove everything
    %except for the first values of the string (real well values)
    if ~isempty(Index)    
        wells=wells(1:(Index(1)-1));
    end
    
    Readend=num2str(length(wells)+8); %Define the size of the data using the number of wells 
    [~,sample]=xlsread(file,1,strcat('B9:B',Readend));
    %%
    %Obtain values of Negative Control
    NControl=find(contains(sample,'Negative')); %Look if there's any negative control, and if yes, get its value
    if ~isempty(NControl) 
        ReadNControl=num2str(NControl+8); %8 is the offset of the excel file
        for h1=1:size(ReadNControl,1)
            NControlValue(h1,:)= xlsread(file,1,strcat('C',ReadNControl(h1,:),':FZZ',ReadNControl(h1,:)));
        end
        NControlValue(NControlValue==0)=[];        %Remove any empty columns(due injection,etc).
        NControlValue=mean(NControlValue,1,'omitnan'); %Do the mean between all the negative controls at each time
    end
    %%
    %Obtain values of Positive Controls
    PControl=find(contains(sample,'Positive'));
    if ~isempty(PControl)
        ReadPControl=num2str(PControl+8);
        for h1=1:size(ReadPControl,1)
            PControlValue(h1,:)= xlsread(file,1,strcat('C',ReadPControl(h1,:),':FZZ',ReadPControl(h1,:)));
        end
        PControlValue(PControlValue==0)=[];         %Remove any empty columns(due injection,etc)
        PControlValue= mean(PControlValue,1,'omitnan')-NControlValue; %Do the mean between all the positive controls and substract the negative  
    end
    %%
    %I only consider two cases. UPDATE if needed
    %For Reporter Assays
    if contains(ID1,'HHR') && contains(ID2,'St2') 
        %Read time and remove in the case of "excess"
        time=xlsread(file,1,'C8:FZZ8');
        %Read the samples
        data=xlsread(file,strcat('C9:FZZ',Readend));
        data(data==0)=[];
        time(:,size(data,2)+1:end)=[];
        %Get injection time and divide data matrix
        [~,~,raw] = xlsread(file);
        [a,b]=find(strcmp(raw,'Injection start time [s]:'));
        injection=round(cell2mat(raw(a,b+2))/60,2);
        %If there's an injection in the protocol, remove the first part of the kinetic 
        if ~isnan(injection)
            time=time-injection;
            Nremove=find(time<0);
            Nremove=Nremove(end);
            time=time(Nremove+1:end);
            data=data(:,Nremove+1:end);
            NControlValue=NControlValue(:,Nremove+1:end);
            PControlValue=PControlValue(:,Nremove+1:end);
        end
        %Remove the Negative control from all the datapoints
        if ~isempty(NControl)
            data=data-NControlValue;
        end
        xlswrite(write,time',1,'A3');
        xlswrite(write,cellstr('time'),1,'A2');
     
        
    %% For HHM assays
    elseif contains(ID1,'HHM') && contains(ID2,'St3')
        %Read time and remove in the case of NaN
        time=xlsread(file,1,'C8:FZZ8');
        %Read the samples
        data=xlsread(file,strcat('C9:FZZ',Readend));
        time(:,size(data,2)+1:end)=[];
        %Get injection time and divide data matrix
        ind=isnan(data(1,:));
        ind2=find(ind);
        %If there's an injection in the protocol, remove the first part of the kinetic 
        if ~isempty(ind2)
            injection=time(ind2(2));
            time=time(:,ind2(2)+1:end);
            data=data(:,ind2(2)+1:end);
            time=time-injection;
            %Remove the Negative control from all the datapoints
            if ~isempty(NControl)
                NControlValue=NControlValue(:,ind2(2)+1:end);
                PControlValue=PControlValue(:,ind2(2)+1:end);
                data=data-NControlValue;
            end
        else
            data=data-NControlValue;
        end
        
        xlswrite(write,time',1,'A3');
        xlswrite(write,cellstr('time'),1,'A2');
        
    %%
        
    %For the measurements that do not contain kinetics, just do the median
    else
        data=xlsread(file,1,strcat('C9:FZZ',Readend));
        if ~isempty(NControl)
            data(:,length(NControlValue)+1:end)=[];
            data=data-NControlValue;
            if ~isempty(PControl)
                PControlValue=median(PControlValue);
            end
        else
            ALERT = strcat('ALERT ',file)
            data(data==0)=[];
        end
        data=median(data,2,'omitnan');
    end
    %%
    %Remove C- and R+ columns and determine the column where the R+ control
    %will be.

    if ~isempty(NControl)
        a=[NControl;PControl];
        a=a(:)';
        data(a,:)=[];
        wells(a,:)=[];
        sample(a,:)=[];
    end
    wrpos=num2str(size(data,1)+2);
    wrpos1=str2double(wrpos);
        if wrpos1>26
            [count]=floor(wrpos1/26);
            [wrpos]=rem(wrpos1,26);
            wrpos1=wrpos;
        end
    wrpos=char(wrpos1+'A'-1);
        if ~isempty(count)
            wrpos=strcat(char(count(1)+'A'-1),wrpos);
        end
    %%
    %Writing everything inside
    if ~isempty(PControl)
        xlswrite(write,PControlValue',1,strcat(wrpos,'3'));
        xlswrite(write,cellstr('C+'),1,strcat(wrpos,'1'));
    end
    if ~isempty(date)
        xlswrite(write,date,1,'A1');
    end
    xlswrite(write,data',1,'B3');
    xlswrite(write,wells',1,'B1');
    xlswrite(write,sample',1,'B2');

