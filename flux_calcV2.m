%Rodrigo Vargas
%University of Delaware
%email rvargas@udel.edu

%When using this function please cite the following papers:
%Vargas, R. and M. F. Allen. 2008. Dynamics of fine root, fungal rhizomorphs, and soil respiration in a mixed temperate forest: Integrating sensors and observations. Vadose Zone Journal 7:1055-1064.
%Vargas, R., D. D. Baldocchi, M. F. Allen, M. Bahn, T. A. Black, S. L. Collins, J. C. Yuste, T. Hirano, R. S. Jassal, J. Pumpanen, and J. W. Tang. 2010. Looking deeper into the soil: biophysical controls and seasonal lags of soil CO2 production and efflux. Ecological Applications 20:1569-1582.


%flux_calcV2.m
% compute the surface fluxes with Gradient method
%
% output F0   : surface CO2 flux  [mumol/m2/s]
%        Pco2 : production of CO2 at depth between CO2 sensors [mumol/m3/s]
% input  CO2  : concentrations [PPM]
%        Ts   : soil temperature [Celsiuis]
%        SVWC : volumetric soil water content
%        P    : atmospheric pressure [Kpa]
%
%  usage: [F0 Pco2]=flux_calcV2(CO2_2,CO2_8,CO2_16,Ts2,Ts8,Ts16,SVWC,P, Time)

function [F0,PR]=flux_calcV2(CO2_2,CO2_8,CO2_16,...
                             Ts2,Ts8,Ts16,SVWC,P,...
                             porosity, S)

%constants and parameters
%these need to be adjusted depending on site-specific information
%beta is a constant
% z represents the depth at which the CO2 sensors are installed…
% for this example we installed at 2 cm, 8 cm, 16 cm.

beta = 2.9;    
R=8.3144;
z=[.02 .08 .16];

    z2(1)=(z(2)+z(1))/2;
    z2(2)=(z(3)+z(1))/2;
    z2(3)=(z(3)+z(2))/2;
    
    z3(1)=(z2(2)+z2(1))/2;
    z3(2)=(z2(3)+z2(1))/2;
    z3(3)=(z2(3)+z2(2))/2;
    
    
Ts2k = Ts2 + 273.15;   %Transform T soil in Kelvin
Ts8k = Ts8 + 273.15;
Ts16k = Ts16 + 273.15;
Pa = P.* 1000;         % Transform air pressure from kPa to Pascals (Pa)

% Transform from ppm(umol mol-1) to mole concentration (umol m-3)
%Note: Air pressure should be in Pascals
C_2 =  (CO2_2.*Pa) ./(R*Ts2k);
C_8 =  (CO2_8.*Pa) ./(R*Ts8k);
C_16 = (CO2_16.*Pa)./(R*Ts16k);

% /////////////////////////////////////////////////////////////
%calculation of CO2 DIFFUSION in the soil
%The CO2 diffusion coefficient in the soil, Ds, is equal to the product of CO2 diffusion coefficient in the free air,
% Da, and the gas tortuosity factor .... Temperature(oK) Pressure (kPa)

%Da for layers Da8 (2-8 cm) Da16 (8-16 cm), Da2_16 (2-16 cm)
Da8  = (1.47e-5*((((Ts2k + Ts8k)./2)./293.15).^1.75).*(1.013e+5./(Pa)));
Da16 = (1.47e-5*((((Ts16k +Ts8k)./2)./293.15).^1.75).*(1.013e+5./(Pa)));
Da2_16 = (1.47e-5*((((Ts16k +Ts2k)./2)./293.15).^1.75).*(1.013e+5./(Pa)));


%Diffussivity calculation using Moldrup et al. model 1999

% Calculate the air-filled porosity
Ds_Da8 =  (porosity.^2).*(((porosity-((SVWC)))./porosity).^(beta.*S)).* Da8;
Ds_Da16 = (porosity.^2).*(((porosity-((SVWC)))./porosity).^(beta.*S)).* Da16;
Ds_Da2_16 = (porosity.^2).*(((porosity-((SVWC)))./porosity).^(beta.*S)).* Da2_16;


%%%%%%Calculation of the Flux at each layer%%%%%%

% calculation of CO2 flux from F8_2(8-2 cm), F16_8 (16-8 cm), F16_2 (16-2 cm)......
%Note: depth should be in meters
% z1 = 0.05..... or distance in between 0.08 and 0.02 m
% z2 = 0.09..... or distance in between 0.16 and 0.02 m
% z2 = 0.12..... or distance in between 0.16 and 0.08 m

F1 = Ds_Da8.*((C_8-C_2)./(z(2)-z(1)));
F2 = Ds_Da2_16.*((C_16-C_2)./(z(3)-z(1)));
F3 = Ds_Da16.*((C_16-C_8)./(z(3)-z(2)));


%%%%%Calculation of the Flux at soil surface%%%%


for i=1:length(F1) %Calculation of means for Node 1
    
    %length(F1)-i
    
p = polyfit(z2,[F1(i) F2(i) F3(i)], 1);

F0(i)=p(2);

end

F0=F0';

%%%%%Calculation of the soil CO2 production%%%%
% p1 = 0.07..... or distance in between 0.05 and 0.09 m
% p2 = 0.085..... or distance in between 0.05 and 0.12 m
% p3 = 0.105..... or distance in between 0.09 and 0.12 m

PR=  (F1 - F3)./(z2(3)-z2(1));


