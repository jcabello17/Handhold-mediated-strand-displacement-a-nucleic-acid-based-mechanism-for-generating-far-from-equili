function y = SecondOrderFittingHHD(k,t,data,a,b,t90)
%The script that contains the function fitted by fminsearch when solving
%Reporter constants.

%Constrains
if  k(1) < 0  || k(2)>=0   || k(3)<0 
   y = NaN;    % give a NaN to the result if the boundaries are not respected
return;                % Respect!!!
end
%Second order reaction analytical solution
function2 = @(k,t) k(3).*(1-exp(k(1).*(t-k(2)).*(k(3)-b)))./(1-(k(3)/b)*exp(k(1).*(t-k(2)).*(k(3)-b)));
%Logaritmic approach for error function
%The error is divided by the function value to normalize for the
%fluorescence fluctuation (Poisson distribution)->from (Winfree's Control
%of DNA Strand Displacement Kinetics using Toehold Exchange)
y=log10(sum((((data-function2(k,t)).^2)./function2(k,t))));