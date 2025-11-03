function batchConvertToEMX(scaleFactor)
% batchConvertToEMX  Convert all DSC/DTA in "Input Spectra" folder to EMX-style SPC/PAR in "Output Spectra".
% One input - scaling factor, for example 1000 times magnification: batchConvertToEMX(1000)
% Set the default value for the scaling factor in line 14: scaleFactor = 1000;
%
% Folder layout (relative to this .m file):
%   ./Input Spectra   -> place .DSC/.DTA here
%   ./Output Spectra  -> results go here
%
% Requires convertToEMX.m on the MATLAB path (same folder is fine, does not need to be open).

    if nargin < 1 || isempty(scaleFactor)
        scaleFactor = 1000;
    end

    % Resolve the folder that contains this .m file
    thisFile = mfilename('fullpath');
    thisDir  = fileparts(thisFile);

    inDir  = fullfile(thisDir, 'Input Spectra');
    outDir = fullfile(thisDir, 'Output Spectra');

    if ~isfolder(inDir)
        error('Input folder not found: %s', inDir);
    end
    if ~isfolder(outDir)
        mkdir(outDir);
    end

    dscList = dir(fullfile(inDir, '*.DSC'));
    if isempty(dscList)
        fprintf('No .DSC files found in: %s\n', inDir);
        return;
    end

    fprintf('\nBatch EMX conversion\nInput : %s\nOutput: %s\nScale : %.3g\n', ...
            inDir, outDir, scaleFactor);
    fprintf('------------------------------------------------------\n');

    for k = 1:numel(dscList)
        [~, base] = fileparts(dscList(k).name);
        dscFile = fullfile(inDir,  [base '.DSC']);
        dtaFile = fullfile(inDir,  [base '.DTA']);

        if ~isfile(dtaFile)
            fprintf('⚠️  Skipping %-20s (missing .DTA)\n', base);
            continue;
        end

        spcFile = fullfile(outDir, [base '.SPC']);  % same base name
        parFile = fullfile(outDir, [base '.PAR']);

        try
            convertToEMX(dscFile, dtaFile, spcFile, parFile, scaleFactor);
            fprintf('✓ Converted %-20s -> %s\n', base, [base '.SPC']);
        catch ME
            fprintf('❌ Error %-20s : %s\n', base, ME.message);
        end
    end

    fprintf('------------------------------------------------------\nDone.\n');
end


