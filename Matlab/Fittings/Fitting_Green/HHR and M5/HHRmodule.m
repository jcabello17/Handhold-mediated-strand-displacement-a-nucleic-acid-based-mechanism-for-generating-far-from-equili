function HHRmodule(Files,folder)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %This script produces fitting for Reporter experiments
    %First some variables are estimated
    %t0=Since the injection time is known, t0 is = time(1) is used. Not other estimations.
    %[]o=Initial concentrations are obtained from the fluorescence values
    %of the steady states
    %K=The first approximation to the constant is obtained from the half
    %life of the reaction.
    %Output Constants: (k=fitted)
            %k(1): kreporter
            %k(2): Initial time
            %k(3): Template concentration
            %sol(4): Reporter concentration
                   
    %Javier Cabello (javic.1994@gmail.com)
%%    %PARAMETERS TO MODIFY:
    round=1 %This can be 1 for the first round of fitting,2 for the second round and 3 for the third.
    Meank=0.3; %The mean k_Rep calculated for the second round of fittings (Was basically the same for 25 and 37 degrees).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %Read the file
    file=getfield(Files, 'name');
    file2=strcat(folder,'\',file);
    [~,wells]=xlsread(file2,2,'B1:BZ1');
    [data,~]=xlsread(file2,2,'B2:BZ1000');
    [time,~]=xlsread(file2,2,'A5:A1000');
    t0=time(1);
    time=time-time(1);
    if round==3
    kb0=xlsread(file2,3,'B4:BZ4');
    tet=xlsread(file2,3,'B5:BZ5');
    Mb0=xlsread(file2,3,'B6:BZ6');
    end
    %%%     PREALLOCATING VARIABLES     %%%
            sol=zeros(4,size(data,2));
            MSEHH=zeros(1,size(data,2));
            completed=zeros(length(time),size(data,2));
            %% Starts the loop for each kinetic 
    for hhh=1:size(data,2)
            %% Parameter estimation
            %Obtaining the point at which the kinetic is >0.5 to assign the
            %weigth and an estimated k0
            fpoint=data(2,hhh); %Final concentrations
            index=data(4:end,hhh)>0.9*fpoint;
            t=find(index,1,'first');
            if isempty(t)
                ERROR='INCOMPLETE KINETIC'
            end
            t90=time(t); %Time at which 90% is reached
            %For the estimation I will consider a 2order reaction with
            %equal concentration of both reagents.
            Incumb=data(2,hhh);Report=data(3,hhh); Incumb0=Incumb; %Temp & Report is used to avoid a big variation from the calculated value during fitting.
            if round==1
                k0=-log((10-9*(Incumb/Report)))/(t90*(Incumb-Report)); 
            elseif round==2
                k0=Meank;
            else
                k0=kb0(hhh);
                t0=-tet(hhh);
                Incumb0=Mb0(hhh);    
            end
            %t0 doesn't require estimation since we know the injection time.
            %%
            %Constants:
            %k(1): kreporter
            %k(2): Initial time
            %k(3): Incumbent amount
            exper=data(4:end,hhh);
            k=[k0,-t0,Incumb0];
            fittingfun = @(k) SecondOrderFittingHHR(k,time,exper,Incumb,Report,t);
            
             %%%%%%%%%%%%%%%% FITTING PART %%%%%%%%%%%%%%%%%%%%%%%%
            options = optimset('fminsearch'); 
            %options.PlotFcns=@optimplotfval; %Option to follow graphically
            %the fitting.
            [k,MSE] = fminsearch(fittingfun,k,options);
            sol(1:3,hhh)=k; %Fitted k,concentrations and initial time saved in a constant
            sol(4,hhh)=Report;
            MSEHH(:,hhh)=MSE; %Records  the error

            %%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%
            time2=time-sol(2,hhh); %The time points of the experimental data
            time1=linspace(0,time2(end),1000); %Time to produce a general trajectory
            functioncomp = @(k) k(3).*(1-exp(k(1).*(time1).*(k(3)-k(4))))./(1-(k(3)/k(4))*exp(k(1).*(time1).*(k(3)-k(4)))); %experimental trajectory
            functionexp = @(k) k(3).*(1-exp(k(1).*(time2).*(k(3)-k(4))))./(1-(k(3)/k(4))*exp(k(1).*(time2).*(k(3)-k(4)))); %Fitting trajectory
            figure('name',strcat(file,num2str(hhh)))
            subplot(2,1,1),plot(time2,exper);
            hold on
            subplot(2,1,1),plot (time1,functioncomp(sol(:,hhh)),'k--');
            title(strrep(strcat(file,num2str(hhh)),'_','-'));
            ylabel('Concentration (nM)') 
            xlabel('Time (mins)') 
            subplot(2,1,2),plot (time2,(exper-functionexp(sol(:,hhh)))./functionexp(sol(:,hhh)));
            ylabel('Weighted Residuals') 
            xlabel('Time (mins)') 
            hold off
            completed(:,hhh)=functionexp(sol(:,hhh));
        end
        
        %%%%%%%%%%%%%%% WRITING THE FILES %%%%%%%%%%%%%%%%%%%%%%%%
        xlswrite(file2,wells,3,'B2');
        xlswrite(file2,MSEHH,3,'B3');
        xlswrite(file2,sol,3,'B4');
        xlswrite(file2,{'Error'},3,'A3');
        xlswrite(file2,{'k'},3,'A4');
        xlswrite(file2,{'t0'},3,'A5');
        xlswrite(file2,{'Concentrations'},3,'A6');
        
        %Modelled trajectory writing in page 4
        xlswrite(file2,wells,4,'B2');
        xlswrite(file2,time,4,'A3');
        xlswrite(file2,completed,4,'B3')