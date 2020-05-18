function   fluoNorm (Files,folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %Script designed for transforming fluorescence values to a concentration value using a calibration curve previously calculated.
    %Before it normalize all the data to the Reporter variation to account
    %for changes in temperature or photobleaching.
    %    STEPS:
    %- Obtain the % variation of the fluorescenct control from the first
    %  measurement.
    %- Divide all the data values by this variation
    %- Substract the quenched baseline as a % of the total fluorescence
    %recovered (i.e. substract all for initial value, do not substract for
    %max value of fluo, only substract a % for intermediate values.
    
    %ASSUMPTIONS: - I assume that the variation of fluorescence produced by temperature or photobleaching is proportional to the fluorescence values. 
    %             - For Reporter Controls I only obtained noisy positive
    %             controls, so I assume a measurement at the end of the
    %             st2 can give an idea of the total fluorescence variation.
    %             -The % of quenched fluo is given as a % of the total fluo
    %             recovered
    
    %Javier Cabello (javic.1994@gmail.com)


%PARAMETERS                                         
Gain_Factor_37=14610;   %(1.44e+04, 1.481e+04)for a temperature of 37 degrees and Gain 2336
Gain_Factor_25=14980;   %(1.469e+04, 1.527e+04) for a temperature of 25 degrees and Gain 2251

for jjj=1:size(Files,1)
    %Read name
    file=getfield(Files(jjj), 'name')
    ID = strsplit(file,'_');
    file=strcat(folder,'\',file);
    [data]=xlsread(file,1,'B3:BZ1000');
    [~,Wells]=xlsread(file,1,'B1:AZ1');
    Wells(end)=[];
    time=xlsread(file,1,'A2:A1000');
    Cont=[];

    timepos=size(data,1)-size(time,1);
    timepos1=num2str(timepos+2);%Obtain where the kinetic start in the file
    if contains(ID(1),'HHR')
        correction=data(:,end)/data(1,end); %For Reporter Kinetics I just assume that the variation of fluorescence is constant after the injection
                                            %Mainly because the reporter
                                            %measurements look really bad.
        correction(4:end)=correction(2);
    else
        correction=data(:,end)/data(1,end); %For the rest of the assays I just use the variation
    end
    data(:,end)=[];
    if ~isempty(Cont)
        for hhh=1:dimenx
            data(4:end,hhh)=data(4:end,hhh)./Cont(:,hhh);
        end
    else     
    data=data./correction; %Apply corrections
    end
    %%
    data= data(timepos,:).*(data-data(1,:))./(data(timepos,:)-data(1,:));%Distribution of the quenched fluo value
    %% Apply the Fluo to concentration conversion factor
    if contains(ID(end),'25')
       data=data/Gain_Factor_25;
    elseif contains(ID(end),'37')
       data=data/Gain_Factor_37; 
    else
       ERROR=file
       continue
    end
    [~,b]=find(data(end,:)<0,1,'last');
    if ~isempty(b)
        data(:,b)=0;
    end
    %% Write in a new sheet the results
    xlswrite(file,Wells,2,'B1');
    xlswrite(file,time,2,strcat('A',timepos1));
    xlswrite(file,data,2,'B2');
end
        
        