function [Err,Sv, tb] = PlotMb2(k,t,data)
%Function that just produce the theoretical trajectory of Mb

x0=[0,0,0,0,k(8),0,0];
t=t-k(6); %Fix time
tb=linspace(0,t(end),1000);
t=[0;t]; %patching....

[T,Sv] = ode15s(@(t,x)Mb(t,x,k,k(3),k(4),k(5),k(7),k(9),k(8),k(10)), tb, x0);
[T,Err] = ode15s(@(t,x)Mb(t,x,k,k(3),k(4),k(5),k(7),k(9),k(8), k(10)), t, x0);
Err(1,:)=[];%Patching to avoid initial conditions....


function dS =  Mb(t,x,k,kbind,krep,k5,a,b,fb,c) 
            
             
         
         Mb=(a-x(1)-x(2)-x(3)-x(4)-x(6)-x(7));
         TMa=(b-x(1)-x(2)-2*x(3)-x(4)-x(7));
         Rep=(c+fb-x(5)-x(6)-x(7));
         
         St2= x(1)*k(1);
         Srep= Rep*x(2)*krep;
         Stoe1= TMa*Mb*k5;
         Stoe2= x(3)*Mb*k5;
         B1= TMa*Mb*kbind;
         B2= TMa*x(4)*kbind;
         B3= x(5)*Mb*kbind;
         B4= x(5)*x(4)*kbind;
         U1= x(1)*k(2);
         U2= x(3)*k(2);
         U3= x(6)*k(2);
         U4= x(7)*k(2);
         T1= TMa*x(6)*k5;
         T2= x(3)*x(6)*k5;
         
         %(1) Template+Ma with Mb bound
         funci(1) = B1-U1-St2;        
         %(2) Template with Mab bound
         funci(2) = St2+Stoe1-Srep+Stoe2+T1+T2;
         %(3) Template+Ma with Mab bound
         funci(3) = B2-U2-Stoe2-T2;
         %(4) Mab
         funci(4) = -B4+U4-B2+U2+Stoe2;
         %(5) Reporter+Template
         funci(5) = -B3+U3-B4+U4+T1; 
         %(6) Reporter+Template with Mb bound
         funci(6) = B3-U3-T1-T2; 
         %(7) Reporter+Template with Mab bound
         funci(7) = Srep+B4-U4+T2; 
         
         dS = funci';
end
end