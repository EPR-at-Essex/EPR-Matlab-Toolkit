function convertToEMX(dscFile, dtaFile, spcFile, parFile, scaleFactor)
% convertToEMX  Convert Bruker DSC/DTA to EMX-style SPC/PAR for WinEPR
%
%   Example of use on a spectrum - files Spectrum.DSC and Spectrum.DTA in the same 
%   folder, with multiplication by 100 - run the following in the Command Window:
%   convertToEMX('Spectrum.DSC', 'Spectrum.DTA', 'Spectrum.SPC', 'Spectrum.PAR', 100)
%   Five inputs in the command:
%     dscFile, dtaFile : input Bruker (E500/Elexsys) files
%     spcFile, parFile : output EMX files 
%     scaleFactor      : optional scale (default = 1)
%
%   EMX format produced:
%     - SPC: float32, little-endian, no header
%     - PAR: CR-only line endings, keys in this order:
%         DOS  Format
%         JSS 0
%         ANZ <points>
%         MIN <min intensity>
%         MAX <max intensity>
%         JUN G␠
%         GST <field start>
%         GSI <sweep width>
%         TITL <filename>
%         MF <microwave frequency in GHz, when MWFQ is valid>
%
% For batch conversion - see batchConvertToEMX.m

    if nargin < 5 || isempty(scaleFactor)
        scaleFactor = 1;
    end

    % --- Read DSC metadata ---
    fid = fopen(dscFile,'rt','n','latin1');
    assert(fid > 0, 'Cannot open DSC file: %s', dscFile);
    meta = containers.Map();
    while ~feof(fid)
        line = strtrim(fgets(fid));
        if isempty(line) || startsWith(line,'*') || startsWith(line,'#')
            continue;
        end
        % Split at the first whitespace run: DSC uses both tabs and spaces.
        % Keep the entire value, including spaces inside quoted text.
        parts = regexp(line, '^(\S+)\s+(.*)$', 'tokens', 'once');
        if ~isempty(parts)
            k = parts{1};
            v = strtrim(parts{2});
            if numel(v) >= 2 && v(1) == char(39) && v(end) == char(39)
                v = v(2:end-1);
            end
            meta(k) = v;
        end
    end
    fclose(fid);

    % --- Extract essentials ---
    XPTS = str2double(meta('XPTS'));
    XMIN = str2double(meta('XMIN'));
    XWID = str2double(meta('XWID'));
    BSEQ = '';
    if isKey(meta,'BSEQ'); BSEQ = meta('BSEQ'); end
    byteOrder = 'ieee-be';
    if ~isempty(BSEQ) && ~strcmpi(BSEQ,'BIG')
        byteOrder = 'ieee-le';
    end

    % --- Microwave frequency ---
    % DSC MWFQ is in Hz; EMX/WinEPR MF is in GHz.
    % Convert Hz to GHz when writing MF below so WinEPR can use the
    % correct microwave frequency for its Parameter List and g-factor tracker.
    mwFreqHz = [];
    if isKey(meta,'MWFQ')
        value = str2double(meta('MWFQ'));
        if isscalar(value) && isreal(value) && isfinite(value) && value > 0
            mwFreqHz = value;
        else
            warning('convertToEMX:InvalidMWFQ', ...
                'Invalid MWFQ in %s; MF omitted from PAR.', dscFile);
        end
    else
        warning('convertToEMX:MissingMWFQ', ...
            'No MWFQ in %s; MF omitted from PAR.', dscFile);
    end

    % --- Read DTA (float64) ---
    fid = fopen(dtaFile,'r',byteOrder);
    assert(fid > 0, 'Cannot open DTA file: %s', dtaFile);
    y = fread(fid, XPTS, 'float64=>double');
    fclose(fid);

    % --- Scale ---
    y = y * scaleFactor;

    % --- Write SPC (float32 LE) ---
    fid = fopen(spcFile,'w','ieee-le');
    assert(fid > 0, 'Cannot create SPC file: %s', spcFile);
    fwrite(fid, single(y), 'float32');
    fclose(fid);

    % --- Write PAR (CR-only, fixed order) ---
    ymin = min(y);
    ymax = max(y);
    [~, nm, ~] = fileparts(spcFile);
    lines = {
        'DOS  Format'
        'JSS 0'
        sprintf('ANZ %d', XPTS)
        sprintf('MIN %.6f', ymin)
        sprintf('MAX %.6f', ymax)
        'JUN G '
        sprintf('GST %.6e', XMIN)
        sprintf('GSI %.6e', XWID)
        sprintf('TITL %s', nm)
    };
    if ~isempty(mwFreqHz)
        lines{end+1} = sprintf('MF %.15g', mwFreqHz / 1e9);
    end
    fid = fopen(parFile,'wb');                            % control \r
    assert(fid > 0, 'Cannot create PAR file: %s', parFile);
    for i = 1:numel(lines)
        fwrite(fid, [lines{i} char(13)], 'char');         % CR only
    end
    fclose(fid);

    fprintf('EMX conversion complete. Scale = %.3g\n  -> %s\n  -> %s\n', ...
        scaleFactor, spcFile, parFile);
end
