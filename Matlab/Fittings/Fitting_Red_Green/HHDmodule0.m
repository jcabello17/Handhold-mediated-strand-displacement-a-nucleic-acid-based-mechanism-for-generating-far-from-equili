function HHDmodule(Files,folder,foldrep)
    %This script produces fitting for non-handhold detachment experiment
    %First some variables are estimated
    %t0=Time is harder to estimate for this ones. I set the time to 0 and
    %do a linear regression with "regression" for the data points until the
    %halflife.
    %[]o=Initial concentrations are obtained from the fluorescence values
    %of the steady states
    %K=The
        %Output Constants: (k=fitted)
    %Javier Cabello (javic.1994@gmail.com)

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
    [time,~]=xlsread(file2,2,'A7:A1000'); %Time of the experiments
    ID = strsplit(file,'_'); %File Name decomposition to obtain values like Exp Temperature
            
    %Remove the first baseline (T free) from all measurements.
    data(1:3,:)=data(1:3,:)-data(1,:);
    [a,~]=find(data(5:end,:)<0,1,'last');
    %Remove first rows if there's any negative values
    if ~isempty(a)
        data(6:5+a,:)=[];
        time(1:(a))=[];
    end
   
    %%%           PREALLOCATING VARIABLES         %%%
    sol=zeros(6,size(data,2));
    MSEHH=zeros(1,size(data,2));

    %Set time to 0
    time=time-time(1);
    %% Beginning of the loop %%
    for hhh=1:size(data,2)

            %Obtaining the point at which the kinetic is >0.9 to assign an estimated k0
            fpoint=data(4,hhh); %Final concentrations
            index=data(7:end,hhh)>0.9*fpoint;
            t90ind=find(index,1,'first');
            t90=time(t90ind);
            exper=data(7:end,hhh);
            Mab=data(2,hhh);Report=data(6,hhh);

   %% Initial time estimation
            %Fit a regression line from t50 to 0 and assume that is the
            %time = 0 
            %Of course there will be an overestimation, but that's fine. If
            %the fitting doesn't work check other condition.
            index=data(7:end,hhh)>0.5*fpoint;                      
            t50ind=find(index,1,'first'); 
                if ~isempty(t50ind)
                    cocoloco=t50ind;
                else
                    cocoloco=length(time); 
                end
                [~,dcoco]=regression(time(1:cocoloco)',exper(1:cocoloco)');
                while dcoco<=0 %In case the noise is bigger than the kinetic
                    cocoloco=cocoloco*2;
                    [~,dcoco]=regression(time(1:cocoloco)',exper(1:cocoloco)');
                end
                %Calculate the time from the first point.
                testim=-(exper(1)/dcoco);
                %In case there's no kinetic
                if isnan(testim)
                    testim=-0.001;
                end
            %Reaction Constant estimation    
            %If the reaction does not reach t90 use another approximation
            %Consider the last value of the kinetic and estimate the t
            k0=-log((Mab/Report)+(10*(1-(Mab/Report))))/(t90*(Mab-Report));

            
            %%
                    %Constants:
            %k(1): k5 (unspecific)
            %k(2): Initial time
            %k(3): Monomer (M5) amount
  
            k=[k0,testim,data(2,hhh)];
            fittingfun = @(k) SecondOrderFittingHHD(k,time,exper,Mab,Report,t90ind);
          
             %%%%%%%%%%%%%%%% FITTING PART %%%%%%%%%%%%%%%%%%%%%%%%
            options = optimset('fminsearch'); 
            %options.PlotFcns=@optimplotfval;
            [k,MSE] = fminsearch(fittingfun,k,options);
            sol(1:3,hhh)=k; %Fitted k,initial time and concentration M5
            sol(4,hhh)=Report;
            MSEHH(:,hhh)=MSE;%Records the error
            
            %%%%%%%%%%%%%%% PLOTTING PART %%%%%%%%%%%%%%%%%%%%
            time2=time-sol(2,hhh); %The time points of the experimental data
            time1=linspace(0,time2(end),1000); %Time to produce a general trajectory
            functioncomp = @(k) k(3).*(1-exp(k(1).*(time1).*(k(3)-k(4))))./(1-(k(3)/k(4))*exp(k(1).*(time1).*(k(3)-k(4))));
            functionexp = @(k) k(3).*(1-exp(k(1).*(time2).*(k(3)-k(4))))./(1-(k(3)/k(4))*exp(k(1).*(time2).*(k(3)-k(4))));
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
            

        end
        
        %%%%%%%%%%%%%%% WRITING THE FILES %%%%%%%%%%%%%%%%%%%%%%%%
        xlswrite(file2,wells,3,'B2');
        xlswrite(file2,MSEHH,3,'B3');
        xlswrite(file2,sol,3,'B4');
        xlswrite(file2,{'Error'},3,'A3');
        xlswrite(file2,{'k'},3,'A4');
        xlswrite(file2,{'t0'},3,'A5');
        xlswrite(file2,{'Concentrations'},3,'A6');