function sim = TRSSA_Helper(p, Sys, Exp, Opt, Am, Bprime, h, Bohr)
roC1 =     p(1); % Spin density on C1
theta =    p(2);
abp =      p(3); % "angle between protons" - angle in degrees from the blue methylen proton to the pink one, anti-clockwise   
cAm =      p(4);

% Calculations
gonro=[                                           % the matrix for calculation of gi as polynomes of roC1
 0         0         0        -0.035874 2.021596; %
 2.959522 -5.037794  3.108621 -0.832102 2.086360; %  
-0.340110  0.634324 -0.441050  0.136320 1.986354];%
a5=[roC1.^4;roC1.^3;roC1.^2;roC1;1];              % vector of different powers of roC1
g = gonro*a5;                                     % the g-values in a column 
gx = g(1,1);                                      % individual values
gy = g(2,1);                                      %
gz = g(3,1);                                      %
giso = mean(g);                                   % isotropic component 

GaussToMHz= giso*Bohr/h/10000/1000000;            % Gauss to MHz conversion factor, in MHz/G, 10^4 converts from T to G, 10^6 - from Hz to MHz

K=(1/gy-1/gx)/(1/gz-1/gy);                        % the K-value

% The matrix for calculation of BASIC linewidth components deltaHbi from K, in Gauss
widthonK=[                                      
-18.49  129.51	-331.31  362.86  -138.47;       %
-6.6	48	    -125.07	 135.15   -47.64;       %
-3.45	27.61	 -77.59	  88.82	  -32.27];      %
a6=[K.^4;K.^3;K.^2;K;1];                        % vector of different powers of K
deltaHb=widthonK*a6;                            % delta H BASIC, a column
deltaH=deltaHb+[Am; Am; Am]+[cAm; cAm; cAm];    % delta H, a column of full width components
deltaHx=deltaH(1,1)*GaussToMHz;                 % Individual values of deltaH in MHz
deltaHy=deltaH(2,1)*GaussToMHz;                 %
deltaHz=deltaH(3,1)*GaussToMHz;                 %

q1=theta;           % theta for the blue proton, in degrees   
q2=theta-abp;       % theta for the pink proton, in degrees

if q2<-90           % conditional statement for the A parallel to A perpendicular ratio calculation (for beta2 proton)
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


% System

Sys.g = [gx gy gz];   

Sys.HStrain = [deltaHx deltaHy deltaHz];

Sys.A = [Ab1Para Ab1Perp Ab1Perp; 
         Ab2Para Ab2Perp Ab2Perp;
         25.9    8.1     20.5; 
         25.9    8.1     20.5; 
          7.5    5.0      1.5; 
          7.5    5.0      1.5
         ]; 

Sys.AFrame = [euler11 euler12 euler13;
              euler21 euler22 euler23; 
              -23.0 0 0; 
               23.0 0 0; 
              -40 0 0; 
               40 0 0    
              ]*pi/180;

    [~, simRaw] = pepper(Sys, Exp, Opt);  

    global spc_global
    num = sum(spc_global(:) .* simRaw(:));
    den = sum(simRaw(:) .* simRaw(:));
    scale = num / den;

    sim = simRaw * scale;
end