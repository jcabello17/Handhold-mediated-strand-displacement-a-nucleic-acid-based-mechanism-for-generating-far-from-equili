function y = SecondOrderFittingHHM5(k,t,data,a,b,c,t90,krep)
%The script that contains the function fitted by fminsearch when solving
%for strand displacement constants.

%Constrains
if  k(1) < 0  || k(2)>=0   || k(3)<0 
   y = NaN;    % give a NaN to the result if the boundaries are not respected
return;                % Respect!!!
end
%If the reaction is not finished, extra boundaries are added just to avoid
%the script giving crazy values to the M5 concentrations
if t90==0
    if k(3)<0.9*a || k(3)>1.1*a 
        y=NaN;
        return; %Respect!!!
    end
end

t=t-k(2); %Modify the time matrix
t=[0;t]; %patching....

x0=[0,0]; %Initial conditions
[T,Sv] = ode45(@(t,x)M5(t,x,k,krep,b,c), t, x0);
Sv(1,:)=[];%Patching to avoid initial conditions....

if size(Sv(:,2),1)<size(data,1)
    y=NaN; %if the solver suddenly stops, restart the function
    return
end


%Logaritmic approach for error function
%The error is divided by the function value to normalize for the
%fluorescence fluctuation (Poisson distribution)->from (Winfree's Control
%of DNA Strand Displacement Kinetics using Toehold Exchange)
y=log10(mean((((data-Sv(:,2)).^2)./Sv(:,2))));
end

function dS = M5(t,x,k,krep,b,c)

         v1= (k(1)*(b-x(1)-x(2))*(k(3)-x(1)-x(2))); %Formation of Template activated
         v2= krep*(c-x(2))*x(1); %Formation of Reporter
         
         funci(1) = v1-v2;
         funci(2) = v2;
         dS = funci';
     end

