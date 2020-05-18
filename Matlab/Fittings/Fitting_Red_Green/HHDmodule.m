function HHDmodule(Files,folder,foldrep)
    %This script produces fitting for Non-complementary experiments
    %First some variables are estimated
    %t0=Time is harder to estimate for this ones. I set the time to 0 and
    %do a linear regression with "regression" for the data points until the
    %halflife.
    %[]o=Initial concentrations are obtained from the fluorescence values
    %of the steady states
    %K=The
        %Output Constants: (k=fitted)
            %k(1): kunspecific (k5)
            %k(2): initial time
            %k(3): Monomer concentration
            %sol(4):Template concentration 
            %sol(5):Reporter Concentration 
    
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
            
    %%%           PREALLOCATING VARIABLES         %%%
    sol=zeros(6,size(data,2));
    MSEHH=zeros(1,size(data,2));

    %Set time to 0
    time=time-time(1);
    reporterval=0.042839695;
    %% Beginning of the loop %%
    for hhh=1:size(data,2)
        MSI=zeros(1,1);
        kl=zeros(1,3);
            %Obtaining the point at which the kinetic is >0.9 to assign an estimated k0
            fpoint=data(4,hhh); %Final concentrations
            index=data(7:end,hhh)>0.9*fpoint;
            t90ind=find(index,1,'first');
            t90=time(t90ind);
            T=data(1,hhh);
            if T<0
                T=0;
            end
            data(1:3,hhh)=data(1:3,hhh)-data(1,hhh);
            exper=data(7:end,hhh);
            Mab=data(2,hhh);Report=data(6,hhh);Template=data(3,hhh);

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
            

            
            %%
                    %Constants:

                k=[5,testim,data(2,hhh)];
                
                fittingfun = @(k) FittingHHD(k,time,exper,Mab,Report,Template,T,t90ind);
                

                 %%%%%%%%%%%%%%%% FITTING PART %%%%%%%%%%%%%%%%%%%%%%%%
                options = optimset('fminsearch'); 
                options.PlotFcns=@optimplotfval;
                [k,MSE] = fminsearch(fittingfun,k,options);
                %k(1)=10^8;

            
            sol(1:2,hhh)=[k(1),k(3)]; 
            sol(3,hhh)=reporterval;
            sol(5,hhh)=Template;
            sol(6,hhh)=Report;
            sol(4,hhh)=k(2);
            MSEHH(:,hhh)=MSE;%Records the error
            
            %%%%%%%%%%%%%%% PLOTTING PART %%%%%%%%%%%%%%%%%%%%
            [Err,Sv5,tb]=PlotHHD(sol(:,hhh),time,exper);
            time2=time-sol(4,hhh); %The time points of the experimental data
            time1=linspace(0,time2(end),1000); %Time to produce a general trajectory
            figure('name',strcat(file,num2str(hhh)))
            subplot(2,1,1),plot(time2,exper);
            hold on
            subplot(2,1,1),plot (time2,Err,'k--');
            title(strrep(strcat(file,num2str(hhh)),'_','-'));
            ylabel('Concentration (nM)') 
            xlabel('Time (mins)') 
            subplot(2,1,2),plot ((1:size(exper,1)),((exper-Err))./(Err+realmin));
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
        xlswrite(file2,{'kreporter'},3,'A6');
        xlswrite(file2,{'Mab'},3,'A5');
        xlswrite(file2,{'t0'},3,'A7');
        xlswrite(file2,{'Concentrations'},3,'A8');