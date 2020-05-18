function [Err,Sv,t5] = PlotM5(k,t,data)
%Function that just produce the theoretical trajectory of M5

x0=[0,0];
t=t-k(3); %Fix time
t5=linspace(0,t(end),1000);
t=[0;t]; %Patching for the initial conditions.
[T,Sv] = ode45(@(t,x)M5(t,x,k), t5, x0); %Trajectory to draw
[T,Err] = ode45(@(t,x)M5(t,x,k), t, x0); %Trajectory to calculate errors
Err(1,:)=[]; %Eliminate initial conditions
     function dS = M5(t,x,k)
         funci(1) = k(1)*(k(5)-x(1)-x(2))*(k(4)-x(1)-x(2))-k(2)*(k(6)-x(2))*x(1);
         funci(2) = k(2)*(k(6)-x(2))*x(1);
         dS = funci';
     end
end
