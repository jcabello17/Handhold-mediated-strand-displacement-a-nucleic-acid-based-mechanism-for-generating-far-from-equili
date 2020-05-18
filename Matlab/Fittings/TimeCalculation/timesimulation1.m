%This function uses the parameters (k) from the file HHMb_resuls.xlsx to
%produce the half-life of handhold mediated strand displacement (t) and for
%toehold-mediated strand displacement (t5).
%It calculates t with the whole reaction model, for Invader=6,
%Target/Incumbent=10 and reporter=1000 nM to make the reporter reaction
%instantaneous.
    %Javier Cabello (javic.1994@gmail.com)

function [t,t5]=timesimulation(k)
a=6; %Invader
b=10; %Target/Incumbent
c=1000; %RQ
%c=15;
Init = 0; %Initial time
Final=2e+5; %Final simulation time -> This tend to break the odesolver. Was set to maximum expected time for a toehold=0 reaction.

tf=[0, Final];
x0=[0,0,0,0,0,0,0]; %Init conditions
%Simulation with all ODEs
Opt    = odeset('Events', @Stop1);
[Tb,Sv] =ode23s(@(t,x)Full_reaction(t,x,k,a,b,c),tf,x0,Opt);
t=Tb(end);

%Analytical solution for a 2nd order reaction.
function2 = @(k)log(2-(a/b))/(k*(b-a));
t5=function2(k(5));
end

%STOP condition. When the reacted species are equal or more than 3.
    function [value, isterminal, direction] = Stop1(T, dS)
    value      = double((dS(5)+dS(6)+dS(7))>= 3);
    isterminal = 1;   % Stop the integration
    direction  = 0;
    end
    
    %The model
    function dS = Full_reaction(t,x,k,a,b,c) 
         %Species
         Mb=(a-x(1)-x(2)-x(3)-x(4)-x(6)-x(7));
         TMa=(b-x(1)-x(2)-2*x(3)-x(4)-x(7));
         Rep=(c-x(5)-x(6)-x(7));
         
         St2= x(1)*k(1);
         Srep= Rep*x(2)*k(4);
         Stoe1= TMa*Mb*k(5);
         Stoe2= x(3)*Mb*k(5);
         B1= TMa*Mb*k(3);
         B2= TMa*x(4)*k(3);
         B3= x(5)*Mb*k(3);
         B4= x(5)*x(4)*k(3);
         U1= x(1)*k(2);
         U2= x(3)*k(2);
         U3= x(6)*k(2);
         U4= x(7)*k(2);
         T1= TMa*x(6)*k(5);
         T2= x(3)*x(6)*k(5);
         
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
     


                   