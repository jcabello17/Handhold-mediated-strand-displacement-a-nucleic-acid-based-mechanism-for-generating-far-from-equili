function   fluonorm (Files,folder)
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
Gain_Factor_Green=13190;  %(12980 13390) at 25 gain 2230

Gain_Factor_Red=14000;  %(1.371e+04, 1.43e+04)for a temperature of 25 degrees and Gain 2816



for jjj=1:size(Files,1)
    %Read name
    file=getfield(Files(jjj), 'name')
    ID = strsplit(file,'_');
    file=strcat(folder,'\',file);
    [data]=xlsread(file,1,'B3:BZ1000');
    [~,Wells]=xlsread(file,1,'B1:AZ1');
    Wells(end-2:end)=[];
    time=xlsread(file,1,'A2:A1000');

    timepos=size(data,1)-size(time,1);
    timepos1=num2str(timepos+2);%Obtain where the kinetic start in the file
    correctionRed=data(:,end-1)/data(1,end-1); %For the rest of the assays I just use the variation
    data(:,end-1)=[];
    data=data./correctionRed; %Apply corrections
    
    %Substract Baseline
    data=data-data(1,:);
    
    RatioAnnealed=data(2,end)/data(4,end);
    initRed=data(6,:).*RatioAnnealed;
    data(:,end)=[];
    initRed(end)=[];
 
    
    %Correction in Red
    data(2:end,:)=data(4,:).*(data(2:end,:)-initRed)./(data(4,:)-initRed); %Distribution of the quenched fluo value

    %% Apply the Fluo to concentration conversion factor
       data=data/Gain_Factor_Red;
       
    %% Write in a new sheet the results
    xlswrite(file,Wells,2,'B1');
    xlswrite(file,time,2,'A6');
    xlswrite(file,data,2,'B2');
    xlswrite(file,{'Red species'},2,'A2');
end
        
        