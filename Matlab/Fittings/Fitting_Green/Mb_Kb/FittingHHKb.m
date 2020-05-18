function y = FittingHHKb(k,k0,kdetach,krep,k5,t,data,a,fb,b,c,t90,Jacobian)
%The script that contains the function fitted by fminsearch when solving
%for the handhold mediated strand displacement constants.

if data(end)==0
    k(2)=0;
    k(3)=-0.001;
end

%Constrains
if  (sum(k(1:2) < 0) > 0)  || (sum(k(3) >= 0) > 0) %Boundaries obtained from STD of 20hh kbind.
    y = NaN;    % give a NaN to the result if the boundaries are not respected
    return;                % Respect!!!
end
        
        if t90==0
            if k(2)<a*0.9 || k(2)>a*1.1    
                y = NaN;
                return;
            end          
        end
        
        tf=t-k(3); %Modify the time matrix
        tf=[0;tf]; %patching....
        x0=[0,0,0,0,fb,0,0]; %Initial conditions
        
        opts = odeset('Jacobian',@(t,x)J(tf,x,[k0,kdetach],k(1),krep,k5,k(2),b,fb,c)); %Options to introduce the Jacobian 
        [~,Sv] = ode23s(@(t,x)Mb(tf,x,[k0,kdetach],k(1),krep,k5,k(2),b,fb,c), tf , x0, opts);
        Sv(1,:)=[];%Patching to avoid initial conditions....
        
        if size(Sv(:,4),1)<size(data,1)
            y=NaN; %if the solver suddenly stops, restart the function
            return;
        end
        result=Sv(:,5)+Sv(:,6)+Sv(:,7)-fb; %make a matrix with 4 results 
    %Logaritmic approach for error function
    %The error is divided by the function value to normalize for the
    %fluorescence fluctuation (Poisson distribution)->from (Winfree's Control
    %of DNA Strand Displacement Kinetics using Toehold Exchange)
    y=log10(sum(((data-result).^2)./(result+realmin)));
    

end

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
     

function Jacobian = J(t,x,k,kbind,krep,k5,a,b,fb,c)      
        
         %%%%%% Differentials CALCULATION  %%%%%%
         Mb=(a-x(1)-x(2)-x(3)-x(4)-x(6)-x(7));
         TMa=(b-x(1)-x(2)-2*x(3)-x(4)-x(7));
         Rep=(c+fb-x(5)-x(6)-x(7));
         
         St2_1= k(1);
         Srep_2=krep*Rep;                                                       Srep_567=krep*x(3);
         Stoe1_1247= k5*(-a-b+2*(x(1)+x(2)+3*x(3)/2+x(4)+x(6)/2+x(7)));         Stoe1_3= k5*(-2*a-b+3*x(1)+3*x(2)+4*x(3)+3*x(4)+2*x(6)+2*3*x(7));    Stoe1_6=k5*-TMa;     
         Stoe2_12467=k5*x(3);                                                   Stoe2_3=k5*(b-x(1)-x(2)-2*x(3)-x(4)-x(6)-x(7));
         B1_1247= kbind*(-a-b+2*(x(1)+x(2)+3*x(3)/2+x(4)+x(6)/2+x(7)));         B1_3= kbind*(-2*a-b+3*x(1)+3*x(2)+4*x(3)+3*x(4)+2*x(6)+2*3*x(7));   B1_6=kbind*-TMa;
         B2_127=kbind*x(4);                                                     B2_3=kbind*2*x(4);                                                  B2_4=kbind*TMa;
         B3_123467= kbind*x(5);                                                 B3_5= kbind*(a-x(1)-x(2)-x(3)-x(4)-x(6)-x(7));
         B4_4= x(5)*kbind;                                                      B4_5= x(4)*kbind;
         U1_1=k(2);
         U2_3=k(2);
         U3_6=k(2);
         U4_7=k(2);
         T1_1247=-x(6)*k5;                                                      T1_3=-2*x(6)*k5;                                                    T1_6=TMa*k5;
         T2_3=x(6)*k5;                                                          T2_6=x(3)*k5;
         
        
         
        Jacobian=  [B1_1247-St2_1-U1_1                      ,B1_1247                                ,B1_3                       ,B1_1247                                ,0             ,B1_6                                    ,B1_1247;
                    Stoe1_1247+Stoe2_12467+St2_1+T1_1247    ,Stoe1_1247+Stoe2_12467-Srep_2+T1_1247  ,Stoe1_3+Stoe2_3+T1_3+T2_3  ,Stoe1_1247+ Stoe2_12467+T1_1247        ,-Srep_567     ,Stoe1_6+Stoe2_12467-Srep_567+T1_6+T2_6  ,Stoe1_1247+Stoe2_12467-Srep_567+T1_1247;                                                
                    B2_127-Stoe2_12467                      ,B2_127-Stoe2_12467                     ,B2_3-U2_3-Stoe2_3-T2_3     ,B2_4-Stoe2_12467                       ,0             ,-Stoe2_12467-T2_6                       ,-Stoe2_12467+B2_127;                   
                    -B2_127                                 ,-B2_127                                ,U2_3-B2_3                  ,-B4_4-B2_4                             ,-B4_5         ,-B3_123467                              ,U4_7-B3_123467-B2_127
                    -B3_123467+T1_1247                      ,-B3_123467+T1_1247                     ,-B3_123467+T1_3            ,-B4_4-B3_123467+T1_1247                ,-B3_5-B4_5    ,-B3_123467+U3_6+T1_6                    ,U4_7-B3_123467+T1_1247
                    B3_123467-T1_1247                       ,B3_123467-T1_1247                      ,B3_123467-T1_3-T2_3        ,B3_123467-T1_1247                      ,B3_5          ,B3_123467-U3_6-T1_6-T2_6                ,B3_123467-T1_1247
                    0                                       ,-Srep_2                                ,T2_3                       ,B4_4                                   ,B4_5+Srep_567 ,Srep_567+T2_6                           ,-U4_7+Srep_567                     ];
                       
                       
        %%%%%%%%%
end