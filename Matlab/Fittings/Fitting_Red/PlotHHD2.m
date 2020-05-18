function [Err,Sv,tb] = PlotHHD(k,t,data)
%Function that just produce the theoretical trajectory of Mb
t=t-k(4); %Modify the time matrix
tb=linspace(0,t(end),1000);
t=[0;t]; %patching.....
x0=0; %Initial conditions 
[T,Sv] = ode45(@(t,x)Mb(t,x,k), tb , x0);
[T,Err] = ode45(@(t,x)Mb(t,x,k), t , x0);
Err(1,:)=[];%Patching to avoid initial conditions....


function dS = Mb(t,x,k) 

         FMab=(-(k(5)+k(1)+x(1)-k(2))+(((k(5)+k(1)+x(1)-k(2))^2)-4*(k(1)*(x(1)-k(2))))^(1/2))/2;  %Free Mab
         Rep= k(6)-x(1);  %Reporter
        
         %x(1) T+Ma+Mb
         funci(1) =  Rep*FMab*k(3)   ;
            
         dS = funci';
                       
        %%%%%%%%%
end
end