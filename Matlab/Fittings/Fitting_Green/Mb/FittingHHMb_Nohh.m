function y = FittingHHMb_Nohh(k,krep,k5,t,data,a,b,c,t90)
%The script that contains the function fitted by fminsearch when solving
%for the handhold mediated strand displacement constants in the case of the handhold length =0.

%In principle a good fit is expected by only fitting [Mb] and t0. Only
%toehold mediated strand displacement. But I also fit K5


%Constrains
if (sum(k(1:1+size(data,2)) < 0) > 0)  || (sum(k(2+size(data,2):1+2*size(data,2)) >= 0) > 0)   
    y = NaN;    % give a NaN to the result if the boundaries are not respected
    return;                
end

%%%%%% PREALLOCATING MATRICES  %%%%%%%%%
    result=zeros(size(data,1),size(data,2));

    for mmm=1:size(data,2)
        if t90(mmm)==0
            if k(mmm+1)<a(mmm)*0.9 || k(mmm+1)>a(mmm)*1.1    
                y = NaN;
                return;
            end          
        end
        
        tf=t-k(1+size(data,2)+mmm); %Align the time matrix with dt
        tf=[0;tf]; %This is to avoid that ode45 put the initial conditions during the first time point.
        x0=[0,0]; %Initial conditions

        [~,Sv] = ode45(@(t,x)Mb(tf,x,krep,k(1),k(mmm+1),b(mmm),c(mmm)), tf, x0);
        Sv(1,:)=[];%Patching to avoid initial conditions....
        
        if size(Sv(:,2),1)<size(data,1)
            y=NaN; %if the solver suddenly stops because of integration tolerances
            return
        end

        result(:,mmm)=Sv(:,2);
%Logaritmic approach for error function
%The error is divided by the function value to normalize for the
%fluorescence fluctuation (Poisson distribution)->from (Winfree's Control
%of DNA Strand Displacement Kinetics using Toehold Exchange)
    end
     y=log10(mean(sum(((data-result).^2)./(result+realmin)),2));

end

function dS = Mb(t,x,krep,k5,a,b,c) 
         
         v4=(a-x(1)-x(2))*(b-x(1)-x(2))*k5; %Unspecific reaction
         v5=(c-x(2))*x(1)*krep; %Consumption of reporter
         
      
                
         %(3) Activated T once Ma and Mb have polymerised
         funci(1) = v4-v5;
         %(4) Reporter
         funci(2) = v5;    
         
         dS = funci';
     end

