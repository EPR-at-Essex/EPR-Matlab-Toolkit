%TRSSA-Y for Lg radical (X-band) [Davies & Puppo, 1992]         
clear; clc;
data = readmatrix('Experimental.txt');    % Reads the experimental data file, saved as two columns, B and spc
B = data(:,1);                            % Magnetic field values, mT
spc = data(:,2);                          % Spectrum values points

% Instrumental parameters ------------------------------------------------
Exp.mwFreq = 9.474;              % MW frequency, GHz
Exp.Range = [333.68 342.13];     % Field range, mT
Exp.nPoints = 1024;              % Number of data points

% Simulation parameters --------------------------------------------------
roC1= 0.41;         % spin density on C1, must be between 0.35 and 0.42 (no units)
theta= 43.0;        % theta, degrees; should be between -90 and +90 degrees
abp= 118;           % "angle between protons", dergeres - angle from the blue methylen proton to the pink one, anti-clockwise   
Am=1;               % modulation amplitude, Gauss
cAm = 0;            % positive or negative correction value to Am, Gauss

q1=theta;           % theta for the blue proton, degrees   
q2=theta-abp;       % theta for the pink proton, degrees
Bprime= 58*0.92;    % the B'' in MaConnell relationship, G. It might be varied around the literature value of 58 G (Fessenden and Schuler, 1963).
h = planck;         % Planck constant in m^2 kg / s (or J s)
Bohr = 9.27401E-24; % Bohr magneton in J/T 

% Making two 1024 row columns: five simulation parameters (the rest are zeros) and simulated spectrum - to be pasted to Excel
a0=[roC1, theta, abp, Am, cAm]'; % makes a 5 line column of input parameters of the simulates spectrum        
b0=zeros(1019,1);   % makes a column of 1019 zeros (to be omplemented with the five above variables to total 1024 rows
A0=[a0;b0];         % Merges the two above into a 1024 rows column with the 5 first of the input parameters

% The matrix for calculation of gi as polynomes of roC1 ------------------
gonro=[                                            
 0          0         0        -0.035874 2.021596; %
 2.959522  -5.037794  3.108621 -0.832102 2.086360; %  
-0.340110   0.634324 -0.441050  0.136320 1.986354];%
a5=[roC1.^4;roC1.^3;roC1.^2;roC1;1];            % vector of different powers of roC1
g=gonro*a5;                                     % the g-values in a column 
gx=g(1,1);                                      % individual values
gy=g(2,1);                                      %
gz=g(3,1);                                      %
giso=mean(g);                                   % irotropic component 

GaussToMHz= giso*Bohr/h/10000/1000000;          % Gauss to MHz conversion factor, in MHz/G, 10^4 converts from T to G, 10^6 - from Hz to MHz

K=(1/gy-1/gx)/(1/gz-1/gy);                      % the K-value

% The matrix for calculation of BASIC linewidth components deltaHbi from K, in Gauss
widthonK=[                                      
-18.49  129.51	-331.31  362.86  -138.47;       %
 -6.6	 48	    -125.07	 135.15   -47.64;       %
 -3.45	 27.61	 -77.59	  88.82	  -32.27];      %
a6=[K.^4;K.^3;K.^2;K;1];                        % vector of different powers of K
deltaHb=widthonK*a6;                            % delta H BASIC, a column
deltaH=deltaHb+[Am; Am; Am]+[cAm; cAm; cAm];    % delta H, a column of full width components
deltaHx=deltaH(1,1)*GaussToMHz;                 % Individual values of deltaH in MHz
deltaHy=deltaH(2,1)*GaussToMHz;                 %
deltaHz=deltaH(3,1)*GaussToMHz;                 %

if q2<-90               % conditional statement for the A parallel to A perpendicular ratio calculation (for beta2 proton)
    a7 = abs(q2+180);   
else
    a7 = abs(q2);       
end
Ab1ParaToPerp = 1.118994587 + 0.000009365 * exp(0.161812523*abs(q1));   % The ratio of A parallel to A perpendicular for beta1 proton (the blue one)
Ab2ParaToPerp = 1.118994587 + 0.000009365 * exp(0.161812523*a7);        % The ratio of A parallel to A perpendicular for beta2 proton (the pink one)

Ab1iso = roC1*Bprime*((cos(q1*pi/180))^2)*GaussToMHz;                   % The iso component of the A-value of the beta 1 proton, from MaConnell relationship                       
Ab2iso = roC1*Bprime*((cos(q2*pi/180))^2)*GaussToMHz;                   % The iso component of the A-value of the beta 2 proton, from MaConnell relationship

Ab1Perp = 3*Ab1iso/(2+Ab1ParaToPerp);                                   % A perpendicular for beta 1 proton
Ab1Para = Ab1ParaToPerp * Ab1Perp;                                      % A parallel for beta 1 proton

Ab2Perp = 3*Ab2iso/(2+Ab2ParaToPerp);                                   % A perpendicular for beta 2 proton
Ab2Para = Ab2ParaToPerp * Ab2Perp;                                      % A parallel for beta 2 proton

euler11 = 32.4*sin(q1*pi/180);                                          % Euler angles for proton beta1
euler12 = 32.2*cos(q1*pi/180)^3;                                        %
euler13 = 86.4*cos(q1*pi/180)^2;                                        %

euler21 = 32.4*sin(q2*pi/180);                                          % Euler angles for proton beta2
euler22 = 32.2*cos(q2*pi/180)^3;                                        %
euler23 = 86.4*cos(q2*pi/180)^2;                                        %

% System and Optional paramters: -----------------------------------------
Sys.S = 1/2;
Sys.g = [gx gy gz];
Sys.HStrain = [deltaHx deltaHy deltaHz];
Sys.Nucs = '1H,1H,1H,1H,1H,1H';
Sys.A = [Ab1Para Ab1Perp Ab1Perp; 
         Ab2Para Ab2Perp Ab2Perp;
         25.9 8.1 20.5; 
         25.9 8.1 20.5; 
          7.5 5.0 1.5; 
          7.5 5.0 1.5
         ]; 
Sys.AFrame = [euler11 euler12 euler13;
              euler21 euler22 euler23; 
              -23.0 0 0; 
               23.0 0 0; 
              -40 0 0; 
               40 0 0    
              ]*pi/180;
Opt.Method='perturb'; 

% Pepper -----------------------------------------------------------------
[F,int] = pepper(Sys,Exp,Opt);   % defines field and intensities as two rows
ScaleExp = 0.5;                  % Scaling factor for experimental spectrum when plotting the two together

% Plot graph -------------------------------------------------------------
plot(F, int, B, spc*ScaleExp);
xlim([333.69 342.12]);
xlabel('Magnetic field (mT)');
% ylabel('Intensity');
title('Tyr Radical EPR Spectrum');
grid on;

% AA_SimSpec formulation -------------------------------------------------
data = [F(:) int(:)];            % transposes into two columns
AA_SimSpec = [A0,int(:)];        % makes a two column  x 1024/512 rows matrix - to copy-paste into Excel (viewing) file


