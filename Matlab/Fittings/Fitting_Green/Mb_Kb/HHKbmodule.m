function HHkbmodule(Files,folder,foldrep,foldM5)
%This script produces fitting for Complementary experiments (Mb)
%First some variables are estimated
%t0=Time is harder to estimate for this ones. I set the time to 0 and
%do a linear regression with "regression" for the data points until the
%halflife and then I use as t0 the median of all of them.
%[]o=Initial concentrations are obtained from the fluorescence values
%of the steady states
%K=The
    %Output Constants: (k=fitted)
            %k(1): kmigration
            %k(2): kdetachment
            %k(3): kbinding
            %k(4): Mb concentration
            %sol(5): Template concentration
            %sol(6): Reporter concentration
            %k(7): Initial time

    %Javier Cabello (javic.1994@gmail.com)
%%
%Parameter to change
round=2 %1 for round 1 and 2 for round 2.
%%          GETTING FILENAMES         %%%
    file=getfield(Files, 'name');  
    file2=strcat(folder,'\',file);
    [~,species]=xlsread(file2,1,'A2:BZ2');
        %Obtaining parameters of the experiment
        for i=1:size(species,2)
            contnt=species{i};
            speciesrep{i}=contnt(1:end-2); %Create a matrix that contains the species of each well
        end
    [~,wells]=xlsread(file2,2,'B1:BZ1'); %Read the wells
    [data,~]=xlsread(file2,2,'B2:BZ1000'); %Exp data
    [time,~]=xlsread(file2,2,'A5:A1000'); %Time of the experiments
    ID = strsplit(file,'_');  %File Name decomposition to obtain values like Exp Temperature
    
        %% LOAD Thermodyn.PARAMETERS 

    %Just assuming that k bind is always 3*10^6 M-1.s-1
    kbind=1; %nM-1.min-1 obtained from previous fittings
    k0=10^10; %min-1   
    kdetach=10^-20;
   
      
%%         Correct data removing Free Template               %%%%
     
    %Remove the first baseline (T free) from all measurements.
    data(3:end,:)=data(3:end,:)-data(2,:);
    
%%           PREALLOCATING MATRICES AND VARIABLES     %%%
    sol=zeros(10,size(data,2)); %Matrix that will contain all the constants
    MSEHH=zeros(1,size(data,2)); %The mean error matrix 
    completedfT=zeros(size(data,1)-5,size(data,2));
    completedTMaMb=zeros(size(data,1)-5,size(data,2));
    completedTact=zeros(size(data,1)-5,size(data,2));
    completedRep=zeros(size(data,1)-5,size(data,2));
            
    %Set time to 0
    time=time-time(1);
  %%         EXTRACTING CONSTANTS FROM OTHER FILES               %%%%
    %Obtain Kreporter and K5 from other files that should be prepared

    %Kreporter: Read all the constants for each temperature
if contains(ID(end),'37')
         TID='37';
        
        [KKK,KKKID]=xlsread(foldrep,2,'B11:CZ12');   %Kreporter: Read all the constants for each temperature
        [KK5,KK5ID]=xlsread(foldM5,2,'A11:CZ12');     %K5: Read all the constants for each temperature
   
    elseif contains(ID(end),'25')
        TID='25';
        
        [KKK,KKKID]=xlsread(foldrep,1,'B11:CZ12'); %Kreporter: Read all the constants for each temperature
        [KK5,KK5ID]=xlsread(foldM5,1,'A11:CZ12'); %K5: Read all the constants for each temperature
end

    if round==2
        kb0=xlsread(file2,3,'B6:BZ6');
        tet=xlsread(file2,3,'B9:BZ9');
        Mb0=xlsread(file2,3,'B10:BZ10');
    end
            

%% Beginning of the loop %%    
    for hhh=1:size(data,2) %Starts Loop that read data 
            
            
    exper=data(6:end,hhh); %All the experimental data removing the headers
    time2=time;

%Remove from the kinetic any timepoint that contains a negative value.
    [a,~]=find(exper(:,:)<0);
    if ~isempty(a) 
        exper(1:max(a),:)=[];
        time2(1:max(a))=[];
        time2=time2-time2(1);
    end

    
    %% DEFINING Krep and K5 FOR THE EXPERIMENT %%%%%%%%%%
            %Using the ID of the 4th well of each group
            contains(KKKID,speciesrep(hhh));
            kreporter=KKK(ans);
            kreporter=kreporter(1); %Getting the 1st ensures that you get the correct one (If ID=0 also 10 and 20 will be positive, but 1st is the correct)
            
            contains(KK5ID,species(hhh)); 
            k5=KK5(ans);
            kk5ID=KK5ID(ans);
            kk5ID=kk5ID{1};
            k5=k5(1); 
            
      
    
            %% Initial time estimation
            %Fit a regression line from t50 to 0 and assume that is the
            %time = 0 
            %Of course there will be an overestimation, but that's fine. If
            %the fitting doesn't work check other condition.
            testim=zeros(1,4);
            t90ind=zeros(1,4);
                index=exper(:)>0.5*data(3,hhh);                      
                t50ind=find(index,1,'first'); 
                index=exper(:)>0.9*data(3,hhh);
                t90=find(index,1,'first');
                if isempty(t90)
                    t90=0;
                end
                t90ind=t90;
                if ~isempty(t50ind)
                    cocoloco=t50ind;
                else
                    cocoloco=length(time2); 
                end
                [~,dcoco]=regression(time2(1:cocoloco)',exper(1:cocoloco)');
                if dcoco<=0 %In case the noise is bigger than the kinetic
                    testim=-0.001;
                end
                %Calculate the time from the first point.
                testim=-(exper(1)/dcoco);
                %In case there's no kinetic
                if isnan(testim)
                    testim=-0.001;
                end
          
%%       DATA TO INTRODUCE IN THE FITTING SYSTEM    %%%%%%%%%%%%%
            %k(1): kmigration
            %k(2): kdetachment
            %k(3): kbinding
            %k(4-7): Mb concentration
            %k(8-11): Initial time
            FreeT=data(2,hhh);Mb=data(3,hhh);Temp=data(4,hhh);Report=data(5,hhh); %Define the concentrations with the headers
            if round==2
                k=[kb0(hhh),Mb0(hhh),tet(hhh)];
            else
                 k=[kbind,Mb,testim];
            end
            if find(FreeT<0,1) %If the FreeT is negative make it 0. (Noise and stuff)
                FreeT(find(FreeT<0))=0;
            end
            
%%%%%%%%%%%%%%%% FITTING PART %%%%%%%%%%%%%%%%%%%%%%%%
            %Using fminsearch.
            options = optimset('fminsearch'); 
            options.PlotFcns=@optimplotfval; %This makes a plot that follows the optimization
            fittingfun = @(k) FittingHHKb(k,k0,kdetach,kreporter,k5,time2,exper,Mb,FreeT,Temp,Report,t90ind);
            [k,MSE] = fminsearch(fittingfun,k,options);            
            MSEHH(:,hhh)=MSE;
            %%%%%%%%%%%%%%%% FILLING SOLUTIONS MATRIX %%%%%%%%%%%%%%%%
            sol(1,hhh)=k0;
            sol(2,hhh)=kdetach;
            sol(3,hhh)=k(1);
            sol(6,hhh)=k(3);
            sol(7,hhh)=k(2);
            sol(5,hhh)= k5;
            sol(4,hhh)= kreporter;
            sol(8,hhh)=FreeT; sol(9,hhh)=Temp; sol(10,hhh)=Report;

            %%%%%%%%%%%%%%% PLOTTING PART %%%%%%%%%%%%%%%%%%%%
            figure('name',strcat(file,num2str(hhh)))
                [Err,Sv5,tb]=PlotMb(sol(:,hhh),time2,exper);
                pTMaMb=Err(:,1);
                pTact=Err(:,2);
                pRep=Err(:,5)+Err(:,6)+Err(:,7)-FreeT(:);
                timefit=time2-sol(6,hhh);
                subplot(2,1,1),plot(timefit,exper);
                hold on

                subplot(2,1,1),plot (tb,(Sv5(:,5)+Sv5(:,6)+Sv5(:,7)-FreeT(:)),'k--');
                subplot(2,1,1),plot (tb,Sv5(:,2),'b--');
                subplot(2,1,1),plot (tb,Sv5(:,1),'r--');
                
     
            title(strrep(strcat(file,'_',species{hhh},'_',num2str(hhh)),'_','-'));
            ylabel('Concentration (nM)') 
            xlabel('Time (mins)')
            subplot(2,1,2),plot ((1:size(exper,1)),(exper-pRep)./(pRep+realmin))
            ylabel('Weighted Residuals') 
            xlabel('Time (mins)') 
            hold off
            
           %clearing the variables to avoid errors
            clear pTMaMb pTact pRep;
   end
        %%%%%%%%%%%%%%% WRITING THE FILES %%%%%%%%%%%%%%%%%%%%%%%%
        xlswrite(file2,wells,3,'B2');
        xlswrite(file2,MSEHH,3,'B3');
        xlswrite(file2,sol,3,'B4');
        xlswrite(file2,{'Error'},3,'A3');
        xlswrite(file2,{'kmb'},3,'A4');
        xlswrite(file2,{'kdetach'},3,'A5');
        xlswrite(file2,{'kbind'},3,'A6');
        xlswrite(file2,{'kreporter'},3,'A7');
        xlswrite(file2,{'k5'},3,'A8')
        xlswrite(file2,{'t0'},3,'A9');
        xlswrite(file2,{'Concentrations'},3,'A10');
        xlswrite(file2,species,3,'B1');       
end        