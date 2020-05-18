%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Script designed to calculate the half-life of each reaction using the data
%from the HHMb_Results file.
%Output: M -> First column: Handhold-mediated strand displacement half-life
             %Second column: Toehold-mediated strand displacement half-life
             %M can be copied and pasted in the HHMb_Results file.
    %Javier Cabello (javic.1994@gmail.com)
%% Temperature selection
page=1; %Select 1 for 25 degrees and 3 for 37 degrees
%%
%%%         GETTING FILE WITH CONSTANTS          %%%
[a,foldrep]= uigetfile('.xlsx','Select Constants File','C:\Users\JC10317\OneDrive - Imperial College London\DOCTORADO\Experimentos');
foldrep=strcat(foldrep,a);

%%%          GETTING CONSTANTS        %%%
%Change page in case of different temperatures  
[KKK,KKKID]=xlsread(foldrep,page,'B1:CZ7');
M=zeros(90,2);
for i= 1:size(KKKID,2)
    k=KKK(2:end,i);
    [t,t5]=timesimulation1(k);
    M(i,:)=[t,t5];
end


