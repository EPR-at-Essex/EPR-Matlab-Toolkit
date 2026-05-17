%TRSSA-Y for Lg radical (X-band) [Davies & Puppo, 1992]         
clear; clc;
data = readmatrix('Experimental.txt');    % Reads my exper data file, saved as two columns, B and spc
B = data(:,1);
spc = data(:,2);

% Instrumental parameters ------------------------------------------------
Exp.mwFreq = 9.474;              % MW frequency, GHz
Exp.Range = [333.68 342.13];     % Field range, mT
Exp.nPoints = 1024;              % Number of data points

% Define global variable for use in Helper
global spc_global;
spc_global = spc;

% Define static parameters 
Am=1;               % modulation amplitude in Gauss
Bprime= 58*0.92;    % the B'' in MaConnell relationship, the literature value of 58 G (Fessenden and Schuler, 1963), is scaled by a factor of 0.92 in TRSSA
h = planck;         % Planck constant in m^2 kg / s (or J s)
Bohr = 9.27401E-24; % Bohr magneton in J/T 

% System parameters ------------------------------------------------------
Sys.S = 1/2;
Sys.Nucs = '1H,1H,1H,1H,1H,1H';

Opt.Method='perturb'; 

% Parameter ranges for fitting
FitParam = @(p) TRSSA_Helper(p, Sys, Exp, Opt, Am, Bprime, h, Bohr);  % function handle
       % roC1   theta    abp     cAm 
       % p(1)    p(2)    p(3)    p(4)        
start = [0.41    43      119     0.0];         
lower = [0.39    40      118    -1.5];      
upper = [0.42    46      120     1.5];      

esfit(spc, FitParam, start, lower, upper);
