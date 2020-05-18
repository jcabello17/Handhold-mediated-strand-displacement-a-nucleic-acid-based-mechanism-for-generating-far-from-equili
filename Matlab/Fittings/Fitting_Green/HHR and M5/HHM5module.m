function HHM5module(Files,folder,foldrep)
    %This script produces fitting for Non-complementary experiments
    %First some variables are estimated
    %t0=Time is harder to estimate for this ones. I set the time to 0 and
    %do a linear regression with "regression" for the data points until the
    %halflife.
    %[]o=Initial concentrations are obtained from the fluorescence values
    %of the steady states
    %K=The        %Output Constants: (k=fitted)
            %k(1): kunspecific (k5)
            %k(2): initial time
            %k(3): Monomer concentration
            %sol(4):Template concentration 
            %sol(5):Reporter Concentration 
    
    %Javier Cabello (javic.1994@gmail.com)

    %% PARAMETERS TO MODIFY:
    round=3 %This can be 1 for the first round of fitting,2 for the second round and 3 for the third.
    
    %%          GETTING FILENAMES         %%%
    file=getfield(Files, 'name');
    file2=strcat(folder,'\',file);
    [~,species]=xlsread(file2,1,'A2:BZ2');
        %Obtaining parameters of the experiment
        for i=1:size(species,2)
            contnt=species{i};
            species{i}=contnt(1:end-2); %Create a matrix that contains the species of each well
        end
    [~,wells]=xlsread(file2,2,'B1:BZ1');%Read the wells
    [data,~]=xlsread(file2,2,'B2:BZ1000'); %Exp data
    [time,~]=xlsread(file2,2,'A5:A1000'); %Time of the experiments
    ID = strsplit(file,'_'); %File Name decomposition to obtain values like Exp Temperature
            
    %%%  Read the file that contains Kreporter%%%
    %Choose depending of the temperature
    if contains(ID(end),'37')
        [KKK,KKKID]=xlsread(foldrep,2,'B11:AA12');
    elseif contains(ID(end),'25')
        [KKK,KKKID]=xlsread(foldrep,1,'B11:AA12');
    end
         
    %Remove the first baseline (T free) from all measurements.
    data(3:end,:)=data(3:end,:)-data(2,:);
    [a,~]=find(data(5:end,:)<0,1,'last');
    %Remove first rows if there's any negative values
    if ~isempty(a)
        data(6:5+a,:)=[];
        time(1:(a))=[];
    end
   
    %%%           PREALLOCATING VARIABLES         %%%
    sol=zeros(6,size(data,2));
    MSEHH=zeros(1,size(data,2));
    completed5=zeros(size(data,1)-5,size(data,2));
    completedT=zeros(size(data,1)-5,size(data,2));

    %Set time to 0
    time=time-time(1);
    
    if round==2 || round==3
        k50=xlsread(file2,3,'B4:BZ4');
        tet=xlsread(file2,3,'B6:BZ6');
        Targ0=xlsread(file2,3,'B7:BZ7');
    end
    %% Beginning of the loop %%
    for hhh=29

            %%%%%%%% DEFINING K REPORTER FOR THE EXPERIMENT %%%%%%%%%%
            contains(KKKID,species(hhh));
            kreporter=KKK(ans);
            kreporter=kreporter(1); %Getting the 1st ensures that you get the correct one (If ID=0 also 10 and 20 will be positive, but 1st is the correct)
            
            %Obtaining the point at which the kinetic is >0.9 to assign an estimated k0
            fpoint=data(3,hhh); %Final concentrations
            index=data(6:end,hhh)>0.9*fpoint;
            t90ind=find(index,1,'first');
            exper=data(6:end,hhh);
            M5=data(3,hhh);Target=data(4,hhh);Report=data(5,hhh); %M5 and Temp provide the measured values of the reagents. They're used to avoid a big drift from them during the fitting.
            M50=M5;
   %% Initial time estimation
            %Fit a regression line from t50 to 0 and assume that is the
            %time = 0 
            %Of course there will be an overestimation, but that's fine. If
            %the fitting doesn't work check other condition.
            index=data(6:end,hhh)>0.5*fpoint;                      
            t50ind=find(index,1,'first'); 
                if ~isempty(t50ind)
                    cocoloco=t50ind;
                    [~,dcoco]=regression(time(1:cocoloco)',exper(1:cocoloco)');
                while dcoco<=0 %In case the noise is bigger than the kinetic
                    cocoloco=cocoloco*2;
                    [~,dcoco]=regression(time(1:cocoloco)',exper(1:cocoloco)');
                end
                else
                    cocoloco=length(time); 
                    [~,dcoco]=regression(time(1:cocoloco)',exper(1:cocoloco)');

                end
                %Calculate the time from the first point.
                t0=-(exper(1)/dcoco);
                %In case there's no kinetic
                if isnan(t0)
                    t0=-0.001;
                end
            %Reaction Constant estimation    
            %If the reaction does not reach t90 use another approximation
            %Consider the last value of the kinetic and estimate the t

                if isempty(t90ind)
                    k0=-log((M5/Target)+((fpoint/data(end,hhh))*(1-(M5/Target))))/((time(end)-t0)*(M5-Target));
                    t90ind=0;   
                else
                    t90=time(t90ind); %Time at which 90% is reached
                    k0=-log((M5/Target)+(10*(1-(M5/Target))))/((t90-t0)*(M5-Target));
                end
            if round==2
                piripi=floor((hhh+3)/4);
                k0=median(k50(4*piripi-3:4*piripi));
                if exper(end)==0
                    k0=0;
                end
            elseif round==3
                k0=k50(hhh);
                t0=tet(hhh);
                M50=Targ0(hhh);   
            end
            %%
                    %Constants:
            %k(1): k5 (unspecific)
            %k(2): Initial time
            %k(3): Monomer (M5) amount
  
            k=[k0,t0,M50];
            fittingfun = @(k) SecondOrderFittingHHM5(k,time,exper,M5,Target,Report,t90ind,kreporter);
          
             %%%%%%%%%%%%%%%% FITTING PART %%%%%%%%%%%%%%%%%%%%%%%%
            options = optimset('fminsearch'); 
            %options.PlotFcns=@optimplotfval;
            [k,MSE] = fminsearch(fittingfun,k,options);
            if isnan(k(1)) && round==1
                k(1)=0;
            end
            sol(1:3,hhh)=k; %Fitted k,initial time and concentration M5
            sol(4,hhh)=Target; sol(5,hhh)=Report;
            MSEHH(:,hhh)=MSE;%Records the error
            
            %Adding the kreporter used in the assay to the sol matrix
            sol(3:6,hhh)=sol(2:5,hhh);
            sol(2,hhh)=kreporter;
            
            %%%%%%%%%%%%%%% PLOTTING PART %%%%%%%%%%%%%%%%%%%%
            [Err5,Sv5,tlin]=PlotM5(sol(:,hhh),time,exper);%Give the theoretical trajectory for a given time and the long trajectory.
            figure('name',strcat(file,num2str(hhh)))
            timefit=time-sol(3,hhh);
            subplot(2,1,1),plot(timefit,exper); %Experimental data plot
            
            hold on
            subplot(2,1,1),plot (tlin,Sv5(:,2),'k--'); %Plot the ideal trajectory (Reporter)
            subplot(2,1,1),plot (tlin,Sv5(:,1),'b--'); %Plot the ideal trajectory (Tactivated)
            title(strrep(strcat(file,num2str(hhh)),'_','-'));
            ylabel('Concentration (nM)') 
            xlabel('Time (mins)') 
            
            subplot(2,1,2),plot (timefit,(exper-Err5(:,2))./Err5(:,2)) %Plot the weighted residuals
            ylabel('Weighted Residuals') 
            xlabel('Time (mins)') 
            hold off
            %Save the trajectories for writing in the excel file.
            completed5(:,hhh)=Err5(:,2)';
            completedT(:,hhh)=Err5(:,1)';
            

        end
        
        %%%%%%%%%%%%%%% WRITING THE FILES %%%%%%%%%%%%%%%%%%%%%%%%
        xlswrite(file2,wells,3,'B2');
        xlswrite(file2,MSEHH,3,'B3');
        xlswrite(file2,sol,3,'B4');
        xlswrite(file2,{'Error'},3,'A3');
        xlswrite(file2,{'k5'},3,'A4');
        xlswrite(file2,{'kreporter'},3,'A5')
        xlswrite(file2,{'t0'},3,'A6');
        xlswrite(file2,{'Concentrations'},3,'A7');
        xlswrite(file2,{'Reporter-FreeTemplate'},3,'A9');
        xlswrite(file2,species,3,'B1');
        %Modelled trajectory writing in page 4
        xlswrite(file2,wells,4,'B2');
        xlswrite(file2,{'Reporter'},4,'A1');
        xlswrite(file2,{'Time'},4,'A2');
        xlswrite(file2,time,4,'A3');
        xlswrite(file2,completed5,4,'B3')
        
        %Modelled trajectory of Activated Template in page 5
        xlswrite(file2,wells,5,'B2');
        xlswrite(file2,{'Activated Template'},4,'A1');
        xlswrite(file2,{'Time'},4,'A2');
        xlswrite(file2,time,5,'A3');
        xlswrite(file2,completedT,5,'B3')