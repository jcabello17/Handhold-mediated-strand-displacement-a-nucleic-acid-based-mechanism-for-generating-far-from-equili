function HHMbmodule(Files,folder,foldrep,foldM5)
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
  round=1 %1 for 1st round, 2 for 2nd and 3 for third
  kbind25=0.308487274;
  std25=0.076154229;
  kbind37=0.604643;
  std37=0.270565;
  %REMEMBER TO INTRODUCE THE LOCATION OF THE FILE Estimated_Kdetach!
  detachfile='C:\Users\IDK\OneDrive - Imperial College London\Doc\Paper\Data\Original_files\Raw_files\Estimated_Kdetach.xlsx';

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

    %%         EXTRACTING CONSTANTS                %%%%
    
    k0=1;
    
    if round==2 || round==3
    k00=xlsread(file2,3,'B4:BZ4');  %min-1  
    kdetach2=xlsread(file2,3,'B5:BZ5');
    kb0=xlsread(file2,3,'B6:BZ6');
    k50=xlsread(file2,3,'B8:BZ8');
    tet=xlsread(file2,3,'B9:BZ9');
    Mb0=xlsread(file2,3,'B10:BZ10');
    end
    
    if contains(ID(end),'37')
         TID='37';
        
        [KKK,KKKID]=xlsread(foldrep,2,'B11:CZ12');   %Kreporter: Read all the constants for each temperature
        [KK5,KK5ID]=xlsread(foldM5,2,'A11:CZ12');     %K5: Read all the constants for each temperature
        kbind=kbind37; %nM-1.min-1 obtained from previous fittings
        std=std37;
        [KKdet,KKdetID]=xlsread(detachfile,4,'B1:I7'); 
        spID=[8,2,0];
    elseif contains(ID(end),'25')
        TID='25';

        [KKK,KKKID]=xlsread(foldrep,1,'B11:CZ12'); %Kreporter: Read all the constants for each temperature
        [KK5,KK5ID]=xlsread(foldM5,1,'A11:CZ12'); %K5: Read all the constants for each temperature
        kbind= kbind25;%nM-1.min-1 obtained from previous fittings
        std=std25; 
        [KKdet,KKdetID]=xlsread(detachfile,3,'B1:I7'); 
        spID=[8,5,3,2,1,0];
        
    end

      
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
            
            
            

%% Beginning of the loop %%    
    %for    hhh=1:(size(data,2)/4) %Starts Loop that read in group of 4 (same amount of replicas)
    for hhh=6
    hhb=hhh*4; 
            
            
    exper=data(6:end,hhb-3:hhb); %All the experimental data removing the headers
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
            contains(KKKID,speciesrep(hhb));
            kreporter=KKK(ans);
            kreporter=kreporter(1); %Getting the 1st ensures that you get the correct one (If ID=0 also 10 and 20 will be positive, but 1st is the correct)
            
            contains(KK5ID,species(hhb)); 
            k5=KK5(ans);
            kk5ID=KK5ID(ans);
            kk5ID=kk5ID{1};
            k5=k5(1); 
            
        %% ESTIMATION OF PARAMETERS  %%
            p=strsplit(species{hhb},'%');%Obtaining length of handhold
            spacer=str2num(p{2}); %Obtain length of spacer

            sp=find(spID==spacer);
            hh=find(contains(KKdetID,p{1}));
            kdetach=KKdet(sp,hh(1));
            kdetach=kdetach*kbind;
            handhold=str2num(p{1});

           
      
    
            %% Initial time estimation
            %Fit a regression line from t50 to 0 and assume that is the
            %time = 0 
            %Of course there will be an overestimation, but that's fine. If
            %the fitting doesn't work check other condition.
            testim=zeros(1,4);
            t90ind=zeros(1,4);
            for ci=1:4
                index=exper(:,ci)>0.5*data(3,hhb-4+ci);                      
                t50ind=find(index,1,'first'); 
                index=exper(:,ci)>0.9*data(3,hhb-4+ci);
                t90=find(index,1,'first');
                if isempty(t90)
                    t90=0;
                end
                t90ind(ci)=t90;
                if ~isempty(t50ind)
                    cocoloco=t50ind;
                else
                    cocoloco=length(time2); 
                end
                [~,dcoco]=regression(time2(1:cocoloco)',exper(1:cocoloco,ci)');
                if dcoco<=0 %In case the noise is bigger than the kinetic
                    testim(ci)=-0.001;
                end
                %Calculate the time from the first point.
                testim(ci)=-(exper(1,+ci)/dcoco);
                %In case there's no kinetic
                if isnan(testim(ci))
                    testim(ci)=-0.001;
                end
            end
            
          
%%       DATA TO INTRODUCE IN THE FITTING SYSTEM    %%%%%%%%%%%%%
            %k(1): kmigration
            %k(2): kdetachment
            %k(3): kbinding
            %k(4-7): Mb concentration
            %k(8-11): Initial time
            FreeT=data(2,hhb-3:hhb);Mb=data(3,hhb-3:hhb);Temp=data(4,hhb-3:hhb);Report=data(5,hhb-3:hhb); %Define the concentrations with the headers
            
            if find(FreeT<0,1) %If the FreeT is negative make it 0. (Noise and stuff)
                FreeT(find(FreeT<0))=0;
            end
if round==1
            k=[k0,kdetach,kbind,Mb,testim];
            
elseif round==2 || round==3

            testim=tet(hhb-3:hhb);
            k=[k00(hhb),kdetach2(hhb),kb0(hhb),Mb0(hhb-3:hhb) ,testim];

end
            
%%%%%%%%%%%%%%%% FITTING PART %%%%%%%%%%%%%%%%%%%%%%%%
            %Using fminsearch.
            options = optimset('fminsearch'); 
            %options.PlotFcns=@optimplotfval; %This makes a plot that follows the optimization

            if handhold ==0 %Use simply as a check using the already obtained constants. 
                 if round==1   
                    k=[k5,data(3,hhb-3:hhb),testim]; %No fitting of kbind, k0 or unbind in this case
                 elseif round==2 || round==3
                    k=[k50(hhb),Mb0(hhb-3:hhb),testim];
                 end
                    cl=find(exper(1,:)==0);
                    %Correction for 3 size kinetics handhold 0
                    if find (exper(1,:)==0)
                        k(cl+5)=[];
                        k(cl+1)=[];
                        exper(:,cl)=[];
                        FreeT(cl)=[];
                        Mb(cl)=[];
                        Report(cl)=[];
                        t90ind(cl)=[];
                        Temp(cl)=[];   
                    end

                    fittingfun = @(k) FittingHHMb_Nohh(k,kreporter,k5,time2,exper,Mb,Temp,Report,t90ind);
                    [k,MSE]=fminsearch(fittingfun,k,options);
                    
                    %Restore the 4th column handhold 0
                if ~isempty(cl)

                    if cl==4
                        k=[k(1:cl),0,k(1+cl:3+cl),-0.01];
                        exper=[exper,zeros(size(exper,1),1)];
                        FreeT=[FreeT(1:(cl-1)),0];
                        Mb=[Mb(1:(cl-1)),0];
                        Report=[Report(1:(cl-1)),0];
                        t90ind=[t90ind(1:(cl-1)),0];
                        Temp=[Temp(1:(cl-1)),0];

                    else
                        k=[k(1:cl),0,k(1+cl:3+cl),-0.01,k(4+cl:7)];
                        exper=[exper(:,1:cl-1),zeros(size(exper,1),1),exper(:,cl:3)];
                        FreeT=[FreeT(1:cl-1),0,FreeT(cl:3)];
                        Mb=[Mb(1:(cl-1)),0,Mb(cl:3)];
                        Report=[Report(1:(cl-1)),0,Report(cl:3)];
                        t90ind=[t90ind(1:(cl-1)),0,t90ind(cl:3)];
                        Temp=[Temp(1:(cl-1)),0,Temp(cl:3)];  
                    end
                end
                    
            else
                cl=find(exper(1,:)==0);
            %Correction for 3 size kinetics
            if find (exper(1,:)==0)
                k(cl+7)=[];
                k(cl+3)=[];
                exper(:,cl)=[];
                FreeT(cl)=[];
                Mb(cl)=[];
                Report(cl)=[];
                t90ind(cl)=[];
                Temp(cl)=[];   
            end
                fittingfun = @(k) FittingHHMb(k,std,kbind,kreporter,k5,time2,exper,Mb,FreeT,Temp,Report,kdetach,t90ind,round);
                kmatrix=[]; MSEmatrix=[];klmatrix=[];
                
 %Starting iteration
    if round==1
                 for hc1=1:10
              
    %%%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                  
                    k(1)=0.0000001*10^(hc1);
                    [kres,MSE] = fminsearch(fittingfun,k,options);
                    klmatrix=[klmatrix;k(1:3)];
                    kmatrix=[kmatrix;kres];
                    MSEmatrix=[MSEmatrix;MSE];
                    
                 end
                 
    elseif round==2||round==3
                    [kres,MSE] = fminsearch(fittingfun,k,options);
                    
                    klmatrix=[klmatrix;k(1:3)];
                    kmatrix=[kmatrix;kres];
                    MSEmatrix=[MSEmatrix;MSE];
    end
                [~,hcl]=(min(MSEmatrix));  %Select the fitting with less error
                MSE=MSEmatrix(hcl);
                k=kmatrix(hcl,:);
                hhm=1;
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{''},1,'A2');
                [~,miau]=xlsread(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),hhm,'A1');
                %Restore the 4th column
                if ~isempty(cl)

                    if cl==4
                        k=[k(1:2+cl),0,k(3+cl:5+cl),-0.01];
                        exper=[exper,zeros(size(exper,1),1)];
                        FreeT=[FreeT(1:(cl-1)),0];
                        Mb=[Mb(1:(cl-1)),0];
                        Report=[Report(1:(cl-1)),0];
                        t90ind=[t90ind(1:(cl-1)),0];
                        Temp=[Temp(1:(cl-1)),0];

                    else
                        k=[k(1:2+cl),0,k(3+cl:5+cl),-0.01,k(6+cl:9)];
                        exper=[exper(:,1:cl-1),zeros(size(exper,1),1),exper(:,cl:3)];
                        FreeT=[FreeT(1:cl-1),0,FreeT(cl:3)];
                        Mb=[Mb(1:(cl-1)),0,Mb(cl:3)];
                        Report=[Report(1:(cl-1)),0,Report(cl:3)];
                        t90ind=[t90ind(1:(cl-1)),0,t90ind(cl:3)];
                        Temp=[Temp(1:(cl-1)),0,Temp(cl:3)];  
                  end
                end
                while ~isempty(miau)
                    hhm=hhm+1;
                    xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{''},hhm,'A2');
                    [~,miau]=xlsread(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),hhm,'A1');
                end
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{'Initial Param'},hhm,'A1');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),klmatrix',hhm,'B1');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{'Residuals'},hhm,'A4');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),MSEmatrix',hhm,'B4');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{'k0'},hhm,'A5');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{'kdetach'},hhm,'A6');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{'Mb'},hhm,'A7');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),{'t0'},hhm,'A11');
                xlswrite(strcat(folder,'\','Matrices','\',kk5ID,'%',TID,'_Matrices.xlsx'),kmatrix',hhm,'B5');
            end
            
            clear cl       
           
            %%%%%%%%%%%%%%%% FILLING SOLUTIONS MATRIX %%%%%%%%%%%%%%%%
           if handhold==0
                sol(1:3,hhb-3:hhb)=0;
                sol(6:7,hhb-3:hhb)=[k(6:9);k(2:5)];
                sol(5,hhb-3:hhb)= k(1);
                sol(11,hhb-3:hhb)=k(1)-k5;
            else
                sol(1:2,hhb-3:hhb)=[k(1:2)',k(1:2)',k(1:2)',k(1:2)'];
                sol(3,hhb-3:hhb)=k(3);
                sol(6:7,hhb-3:hhb)=[k(8:11);k(4:7)];
                sol(5,hhb-3:hhb)= k5;
            end
            
            sol(4,hhb-3:hhb)= kreporter;
            sol(8,hhb-3:hhb)=FreeT; sol(9,hhb-3:hhb)=Temp; sol(10,hhb-3:hhb)=Report;

            %Fitted k,initial time and concentration M5%
            MSEHH(1,hhb-3:hhb)=MSE;


            %%%%%%%%%%%%%%% PLOTTING PART %%%%%%%%%%%%%%%%%%%%
            figure('name',strcat(file,num2str(hhh)))
            for mmm=hhb-3:hhb
                [Err,Sv5,tb]=PlotMb(sol(:,mmm),time2);
                pTMaMb(:,mmm-hhb+4)=Err(:,1);
                pTact(:,mmm-hhb+4)=Err(:,2);
                pRep(:,mmm-hhb+4)=Err(:,5)+Err(:,6)+Err(:,7)-FreeT(mmm-hhb+4);
                timefit=time2-sol(6,mmm);
                subplot(2,1,1),plot(timefit,exper(:,mmm-hhb+4));
                hold on

                subplot(2,1,1),plot (tb,(Sv5(:,5)+Sv5(:,6)+Sv5(:,7)-FreeT(mmm-hhb+4)),'k--');
                subplot(2,1,1),plot (tb,Sv5(:,2),'b--');
                subplot(2,1,1),plot (tb,Sv5(:,1),'r--');
% % 
% %                 
            end
            title(strrep(strcat(file,'_',species{hhb},'_',num2str(hhh)),'_','-'));
            ylabel('Concentration (nM)') 
            xlabel('Time (mins)')
            subplot(2,1,2),plot ((1:size(exper,1)),mean(((exper-pRep(:,1:4)))./(pRep(:,1:4)+realmin),2))
            ylabel('Weighted Residuals') 
            xlabel('Data point') 
            hold off
            
            if ~isempty(a)
                pTMaMb(size(exper,1)+1:size(time,1),:)=0;
                pTact(size(exper,1)+1:size(time,1),:)=0;
                pRep(size(exper,1)+1:size(time,1),:)=0;
            end
            %%%%Saving the kinetics for writing
            completedTMaMb(:,hhb-3:hhb)=pTMaMb;
            completedTact(:,hhb-3:hhb)=pTact;
            completedRep(:,hhb-3:hhb)=pRep;
            
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

        
        %Modelled trajectory writing in page 4
        xlswrite(file2,{'Reporter'},4,'A1');
        xlswrite(file2,wells,4,'B2');
        xlswrite(file2,{'Time not corrected'},4,'A2');
        xlswrite(file2,time,4,'A3');
        xlswrite(file2,completedRep,4,'B3')
        
        %Modelled trajectory of MbTemplate in page 6
        xlswrite(file2,{'TMaMb'},5,'A1');
        xlswrite(file2,wells,5,'B2');
        xlswrite(file2,{'Time not corrected'},5,'A2');
        xlswrite(file2,time,5,'A3');
        xlswrite(file2,completedTMaMb,5,'B3')
        
        %Modelled trajectory of Activated Template in page 7
        xlswrite(file2,{'Tactive'},6,'A1');
        xlswrite(file2,wells,6,'B2');
        xlswrite(file2,{'Time not corrected'},6,'A2');
        xlswrite(file2,time,6,'A3');
        xlswrite(file2,completedTact,6,'B3');
        
        
end