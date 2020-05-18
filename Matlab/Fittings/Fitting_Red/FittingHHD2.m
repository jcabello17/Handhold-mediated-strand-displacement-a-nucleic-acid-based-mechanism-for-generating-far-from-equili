function y = SecondOrderFittingHHD(k,t,data,a,b,c,t90)
%The script that contains the function fitted by fminsearch when solving
%Reporter constants.
kreporter=0.042839695;
%k(1)=10^8;
%Constrains
if  k(1) < 10^6  || k(2)>=0   || k(3)<0 
   y = NaN;    % give a NaN to the result if the boundaries are not respected
return;                % Respect!!!
end
% if t90==0
            if k(3)<a*0.8 || k(3)>a*1.20   
                y = NaN;
                return;
            end          
% end
tf=t-k(2); %Modify the time matrix
tf=[0;tf]; %patching....
x0=0; %Initial conditions 
[~,Sv] = ode45(@(t,x)Mb(tf,x,k,kreporter,a,b,c), tf , x0);
Sv(1,:)=[];%Patching to avoid initial conditions....
%Logaritmic approach for error function
%The error is divided by the function value to normalize for the
%fluorescence fluctuation (Poisson distribution)->from (Winfree's Control
%of DNA Strand Displacement Kinetics using Toehold Exchange)
y=log10(mean((((data-Sv).^2)./Sv+realmin)));

function dS = Mb(t,x,k,krep,a,b,c) 
         
         FMab=(-(c+k(1)+x(1)-k(3))+(((c+k(1)+x(1)-k(3))^2)-4*(k(1)*(x(1)-k(3))))^(1/2))/2;  %Free Mab
         Rep= b-x(1);  %Reporter
        
         %x(1) T+Ma+Mb
         funci(1) =  Rep*FMab*krep   ;
            
         dS = funci';
end
end