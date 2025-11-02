If you are, like myself, have been using for years WinEPR installed on a range of computers, and now have to use Xepr (which is only installed on the single computer that runs an Elexsys spectrometer), and if you have, like myself, more reasons to prefer WinEPR, then you might want to routinely convert *.DSC / *.DTA EPR spectra to the *.spc /*.par format. The two *.m files are exactly for that.  

The convertToEMX.m file converts a single spectrum – two files Spectrum.DSC and Spectrum.DTA, placed in the same folder where the convertToEMX.m is, into two files Spectrum.SPC and Spectrum.PAR, in the same folder.  But this job is also available from the Xepr, provided you multiplied the original *.DSC / *.DTA spectrum by a large factor, say 1000.

The same convertToEMX.m works as a function with batchConvertToEMX.m, which is much more convenient option to work on either single or many spectra placed in the folder named Input Spectra. The converted spectra will appear in the folder Output Spectra.

Happy converting!

Dima Svistunenko
