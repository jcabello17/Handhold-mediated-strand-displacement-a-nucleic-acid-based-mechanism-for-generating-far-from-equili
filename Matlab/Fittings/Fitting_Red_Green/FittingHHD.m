
function y = FittingHHD(k,t,data,a,b,c,fb,t90)
%The script that contains the function fitted by fminsearch when solving
%Reporter constants.
%Constrains
%% KREPORTER2
kreporter=0.042839695;
%%
if  k(1) < 0  || k(2)>=0   || k(3)<0 
   y = NaN;    % give a NaN to the result if the boundaries are not respected
return;                % Respect!!!
end
 if k(3)<a*0.80 || k(3)>a*1.20   
     y = NaN;
   return;
 end          
tf=t-k(2); %Modify the time matrix
tf=[0;tf]; %patching....
%eq=(-(c+k(1)-k(3))+(((c+k(1)-k(3))^2)-4*(-k(1)*k(3)))^(1/2))/2;
%x0=[eq,0]; %Initial conditions 
x0=[0];
[~,Sv] = ode45(@(t,x)Mb(tf,x,k,kreporter,a,b,c,fb), tf , x0);
Sv(1,:)=[];%Patching to avoid initial conditions....
%Logaritmic approach for error function
%The error is divided by the function value to normalize for the
%fluorescence fluctuation (Poisson distribution)->from (Winfree's Control
%of DNA Strand Displacement Kinetics using Toehold Exchange)
y=log10(sum((((data-Sv).^2)./Sv+realmin)));

function dS = Mb(t,x,k,krep,a,b,c,fb) 
         
         Munbound=(-(c+fb+k(1)+x(1)-k(3))+(((c+fb+k(1)+x(1)-k(3))^2)-4*(k(1)*(x(1)-k(3))))^(1/2))/2;  %Free Mab
         Rep= b-x(1);  %Reporter
        
         %x(1) T+Ma+Mb
         funci(1) =  Rep*Munbound*krep;
            
         dS = funci';
end
end