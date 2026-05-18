The files in this module are intended for simulation of tyrosyl radical EPR spectra using the Tyrosyl Radical Spectra Simulation Algorithm (TRSSA) [1-4]. The algorithm relies on EasySpin [5], a MATLAB toolbox for EPR spectroscopy simulation and analysis, and reduces the number of independent input parameters required for simulation of a tyrosyl radical spectrum to just two values. Conventional EasySpin simulations of tyrosyl radical spectra typically require specification of about 40 Hamiltonian parameters. In contrast, TRSSA requires only: a) the spin density on atom C1 of the tyrosine residue and b) the rotation angle of the phenol ring.

There are three ***.m** files intended to be run in MATLAB. The file **TRSSA_Y_simulate.m** allows simulation of a spectrum stored as **Experimental.txt** (explore the format of this text file when setting your own experimental spectrum to simulate) with the input parameters specified manually. The file **TRSSA_Y_fit.m**, which works together with the helper function **TRSSA_Helper.m**, allows automated fitting when starting values and parameter variation ranges are specified.

The Excel file **Compare different simulations.xlsx** is a useful tool for storing and comparing different simulations.

The instruction file **Instructions_Y_with_fitting_.docx** provides guidance on use of the package. It is written for users with approximately undergraduate-level background and assumes no prior knowledge of EPR spectroscopy.

[1]	D. A. Svistunenko, M. T. Wilson, C. E. Cooper. Tryptophan or tyrosine? On the nature of the amino acid radical formed following hydrogen peroxide treatment of cytochrome c oxidase. Biochim Biophys Acta 2004, 1655, 372-80.

[2]	D. A. Svistunenko, C. E. Cooper. A new method of identifying the site of tyrosyl radicals in proteins. Biophys J 2004, 87, 582-95.

[3]	D. A. Svistunenko. Reaction of haem containing proteins and enzymes with hydroperoxides: The radical view. Biochim Biophys Acta 2005, 1707, 127-55.

[4]	A. K. Chaplin, T. M. Chicano, B. V. Hampshire, M. T. Wilson, M. A. Hough, D. A. Svistunenko, J. A. R. Worrall. An aromatic dyad motif in dye decolourising peroxidases has implications for free radical formation and catalysis. Chemistry 2019, 25, 6141-53.

[5]	S. Stoll, A. Schweiger. EasySpin, a comprehensive software package for spectral simulation and analysis in EPR. J Magn Reson 2006, 178, 42-55.

