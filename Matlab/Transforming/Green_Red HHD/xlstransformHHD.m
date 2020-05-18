function   xlstransformHHD(Files,folder)
    %Script designed for transforming the csv file obtained from the plate reader CLARISSA into an excel file with the 
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
    ID2=regexprep(ID2,'(ID2: )','');
    if contains(ID2, 'Wizard')
      cuidadin=1;
      ID3=regexprep(ID1,'(ID1: )','');
      ID3=strrep(ID3,'/','%');
      ID1='HHD';
      ID2='St4';
    else
    ID1=regexprep(ID1,'(ID1: )','');
    ID3=regexprep(ID3,'(ID3: )','');
    ID3=strrep(ID3,'/','%');
    end
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
    %Obtain values of QuenchedRed Controls
    PControl=find(contains(sample,'Positive'));
    if ~isempty(PControl)
        ReadPControl=num2str(PControl+8);
        for h1=1:size(ReadPControl,1)
            PControlValue(h1,:)= xlsread(file,1,strcat('C',ReadPControl(h1,:),':FZZ',ReadPControl(h1,:)));
        end
        PControlValue(PControlValue==0)=[];         %Remove any empty columns(due injection,etc)
        PControlValue= PControlValue-NControlValue;   
    end
    %%
    %Obtain values of Red Controls
    RedControl=find(contains(sample,'C2'));
    if ~isempty(RedControl)
        ReadRedControl=num2str(RedControl+8);
        for h1=1:size(ReadRedControl,1)
            RedControlValue(h1,:)= xlsread(file,1,strcat('C',ReadRedControl(h1,:),':FZZ',ReadRedControl(h1,:)));
        end
        RedControlValue(RedControlValue==0)=[];         %Remove any empty columns(due injection,etc)
        RedControlValue= RedControlValue-NControlValue; %Do the mean between all the positive controls and substract the negative  
    end
    %%
    %Obtain values of Green Controls
    GreenControl=find(contains(sample,'C1'));
    if ~isempty(GreenControl)
        ReadGreenControl=num2str(GreenControl+8);
        for h1=1:size(ReadGreenControl,1)
            GreenControlValue(h1,:)= xlsread(file,1,strcat('C',ReadGreenControl(h1,:),':FZZ',ReadGreenControl(h1,:)));
        end
        GreenControlValue(GreenControlValue==0)=[];         %Remove any empty columns(due injection,etc)
        GreenControlValue= GreenControlValue-NControlValue; %Do the mean between all the positive controls and substract the negative  
    end
    %%
    %I only consider two cases. UPDATE if needed
    %For Reporter Assays
    if contains(ID1,'HHD') && contains(ID2,'St4') || contains(ID1,'HHD2') && contains(ID2,'St2')
        write=char(strcat(folder,'\Writ\',ID1,'_',ID3,'_25_',ID2,'.xlsx'));
        %Read time and remove in the case of NaN
        time=xlsread(file,1,'C8:FZZ8');
        %Read the samples
        data=xlsread(file,strcat('C9:FZZ',Readend));
        time(:,size(data,2)+1:end)=[];
        data=data-NControlValue;
        
        xlswrite(write,time',1,'A3');
        xlswrite(write,cellstr('time'),1,'A2');
    %Remove C- and R+ columns and determine the column where the R+ control
    %will be.
    a=[NControl;PControl;RedControl];
    a=a(:)';
    data(a,:)=[];
    wells(a,:)=[];
    sample(a,:)=[];
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
    %Writing everything inside
        xlswrite(write,[RedControlValue',PControlValue'],1,strcat(wrpos,'3'));
        xlswrite(write,cellstr({'R+','Quenched','G+'}),1,strcat(wrpos,'1'));        
        xlswrite(write,date,1,'A1');
        xlswrite(write,data',1,'B3');
        xlswrite(write,wells',1,'B1');
        xlswrite(write,sample',1,'B2');
        

    %%
    %For the measurements that do not contain kinetics, just do the median
    else
        data=xlsread(file,1,strcat('C9:FZZ',Readend));
        if ~isempty(NControl)
            data(:,length(NControlValue)+1:end)=[];
            data=data-NControlValue;
        end
        %Red is the second pack of measurements
        if length(PControlValue)>3
            PControlValue1=median(PControlValue(1:(end/2)));
            PControlValue2=median(PControlValue((end/2):end));
            RedControlValue1=median(RedControlValue(1:(end/2)));
            RedControlValue2=median(RedControlValue((end/2):end));
            GreenControlValue1=median(GreenControlValue(1:(end/2)));
            GreenControlValue2=median(GreenControlValue((end/2):end));
            data1=median(data(:,1:(end/2)),2,'omitnan');
            data2=median(data(:,(end/2):end),2,'omitnan');
        else
            PControlValue1=PControlValue(1);
            PControlValue2=PControlValue(2);
            RedControlValue1=RedControlValue(1);
            RedControlValue2=RedControlValue(2);
            GreenControlValue1=GreenControlValue(1);
            GreenControlValue2=GreenControlValue(2);
            data1=data(:,1);
            data2=data(:,2);
        end
    %%
    %Remove C- and R+ columns and determine the column where the R+ control
    %will be.
    a=[NControl;PControl;RedControl;GreenControl];
    a=a(:)';
    data1(a,:)=[];
    data2(a,:)=[];
    wells(a,:)=[];
    sample(a,:)=[];
    wrpos=num2str(size(data1,1)+2);
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
    xlswrite(write,[RedControlValue1,PControlValue1,GreenControlValue1;RedControlValue2,PControlValue2,GreenControlValue2],1,strcat(wrpos,'3'));
    xlswrite(write,cellstr({'R+','Quenched','G+'}),1,strcat(wrpos,'1'));
    xlswrite(write,date,1,'A1');
    xlswrite(write,[data1';data2'],1,'B3')
    xlswrite(write,wells',1,'B1');
    xlswrite(write,sample',1,'B2');
end
end