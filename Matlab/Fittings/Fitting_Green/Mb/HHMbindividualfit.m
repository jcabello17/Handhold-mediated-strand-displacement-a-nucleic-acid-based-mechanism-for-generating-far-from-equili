function HHMbindividualfit(Files,folder,foldrep,foldM5)
%This script produces fitting for Complementary experiments (Mb)
%individually to check the variation in the parameters.

    %Javier Cabello (javic.1994@gmail.com)
%% Parameters to change
  kbind25=0.308487274;
  std25=0.076154229;
  kbind37=0.604643;
  std37=0.270565;

%%          GETTING FILENAMES         %%%

    
    file=getfield(Files, 'name');  
    file2=strcat(folder,'\',file);
    [data,~]=xlsread(file2,2,'B2:BZ1000'); %Exp data
    [time,~]=xlsread(file2,2,'A5:A1000'); %Time of the experiments
    ID = strsplit(file,'_');  %File Name decomposition to obtain values like Exp Temperature
    %Set time to 0
    time=time-time(1);
    
    %Some variables
    results=zeros(11,1);
    results2=zeros(11,size(data,2));
    
    if contains(ID(end),'37')
        kbind=kbind37;
        std=std37;

    elseif contains(ID(end),'25')
        kbind=kbind25;
        std=std25;
    end
    %%         Correct data removing Free Template               %%%%

    %Remove the first baseline (T free) from all measurements.
    data(3:end,:)=data(3:end,:)-data(2,:);       
        %% Beginning of the loop %%    
    for hhh=1:(size(data,2)) %Starts Loop  

        %%         EXTRACTING CONSTANTS FROM FILES               %%%%
        if hhh>25 && hhh<52
            pos1=strcat('A',char('A'+(hhh-26)));
        elseif hhh>51
            pos1=strcat('B',char('A'+(hhh-52)));
        else
            %Obtain results from the previous fittings
            pos1=char('A'+hhh);%Get the column
        end
        [sol,~]=xlsread(file2,3,strcat(pos1,'4:',pos1,'13'));
        sol=sol';
        %Remove from the kinetic any timepoint that contains a negative value.
        time2=time; 
        exper1=data(6:end,hhh); %All the experimental data removing the headers
        [a,~]=find(exper1<0);
        if ~isempty(a) 
            exper1=exper1(max(a)+1:end);
            time2(1:max(a))=[];
            time2=time2-time2(1);
        end
        
%% Obtaining t90 index (check if the reaction has finished)
                index=exper1>0.9*data(3,hhh);                      
                t90=find(index,1,'first');
                if isempty(t90)
                    t90=0;
                end
                t90ind=t90;
        
%%       DATA TO INTRODUCE IN THE FITTING SYSTEM    %%%%%%%%%%%%%
            %k(1): kmigration
            %k(2): kdetachment
            %k(3): kbinding
            %k(4): Mb concentration
            %k(5): Initial time
            FreeT=data(2,hhh);Mb=data(3,hhh);Temp=data(4,hhh);Report=data(5,hhh); %Define the concentrations with the headers
            kl=[sol(1:3),sol(7),sol(6)];
            k5=sol(5);   kreporter=sol(4);

            if FreeT<0 %If the FreeT is negative make it 0. (Noise and stuff)
                FreeT=0;
            end
            
%%%%%%%%%%%%%%%% FITTING PART %%%%%%%%%%%%%%%%%%%%%%%%
            %Using fminsearch.
            options = optimset('fminsearch'); 
            %options.PlotFcns=@optimplotfval; %This makes a plot that follows the optimization
            
            if sol(1) ==0 %Use simply as a check using the already obtained constants. 
                    k=[k5,sol(6),sol(7)]; %No fitting of kbind, k0 or unbind in this case
                    fittingfun = @(k) SecondOrderFittingHHM5(k,time2,exper1,Mb,Temp,Report,t90ind,kreporter);
                    [k,MSE]=fminsearch(fittingfun,k,options);
            else               
                    fittingfun = @(k) FittingHHMbsimp(k,kreporter,k5,time2,exper1,Mb,FreeT,Temp,Report,t90ind,kbind,std);         
                    [k,MSE] = fminsearch(fittingfun,kl,options);
            end

        %%%%%%%%%%%%%%%% FILLING SOLUTIONS MATRIX %%%%%%%%%%%%%%%%
           if sol(1)==0
                results(2:4)=0;
                results(6)=k(1);
                results(7)=k(2);
                results(8)=k(3);
            else
                results(2:4)=k(1:3);
                results(8)=k(4);
                results(7)=k(5);
                results(6)=k5;
            end

        results(1)=MSE;
        results(5)= kreporter;
        results(9)= FreeT;
        results(10)= Temp;
        results(11)= Report+FreeT;

        %%%%%%%%%%%%%%% PLOTTING PART %%%%%%%%%%%%%%%%%%%%
        figure('name',strcat(file,num2str(hhh)))
        [Err,Sv5,tb]=PlotMb(results(2:11),time2);
        pTMaMb=Err(:,1);
        pTact=Err(:,2);
        pRep=Err(:,5)+Err(:,6)+Err(:,7)-FreeT;
        timefit=time2-results(7);
        subplot(2,1,1),plot(timefit,exper1);
        hold on

        subplot(2,1,1),plot (tb,Sv5(:,5)+Sv5(:,6)+Sv5(:,7)-FreeT,'k--');
        subplot(2,1,1),plot (tb,Sv5(:,2),'b--');
        subplot(2,1,1),plot (tb,Sv5(:,1),'r--');


        title(strrep(strcat(file,'_',num2str(hhh)),'_','-'));
        ylabel('Concentration (nM)') 
        xlabel('Time (mins)')
        subplot(2,1,2),plot ((1:size(exper1,1)),((exper1-pRep))./(pRep+realmin))
        ylabel('Weighted Residuals') 
        xlabel('Data points') 
        hold off

        %clearing the variables to avoid errors
        clear pTMaMb pTact pRep pMab;
        results2(:,hhh)=results;
end
    %%%%%%%%%%%%%%% WRITING THE FILES %%%%%%%%%%%%%%%%%%%%%%%%
    xlswrite(file2,results2,3,'B16');
    xlswrite(file2,{'Error_ind'},3,'A16');
    xlswrite(file2,{'kmb_ind'},3,'A17');
    xlswrite(file2,{'kdetach_ind'},3,'A18');
    xlswrite(file2,{'kbind_ind'},3,'A19');
    xlswrite(file2,{'kreporter_ind'},3,'A20');
    xlswrite(file2,{'k5_ind'},3,'A21')
    xlswrite(file2,{'t0_ind'},3,'A22');
    xlswrite(file2,{'Concentrations_ind'},3,'A23');



end