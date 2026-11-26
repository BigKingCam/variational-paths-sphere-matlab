function output_validation_report(reportFcn, opts)
%OUTPUT_VALIDATION_REPORT Display and/or save validation output.
%
% reportFcn - Function handle for the validation report.
%
% Name-value options:
%   report   - Display report in Command Window (default: true)
%   save     - Save report to text file (default: false)
%   filename - Destination file path (required if save = true)

arguments (Input)
    reportFcn (1,1) function_handle
    opts.report (1,1) logical = true
    opts.save (1,1) logical = false
    opts.filename (1,1) string = ""
end

% Nothing to do if both options are disabled
if ~opts.report && ~opts.save
    return;
end

% Capture the report function's console output
reportText = evalc('reportFcn()');

% Display in Command Window
if opts.report
    fprintf('%s', reportText);
end

% Save to text file
if opts.save

    if strlength(opts.filename) == 0
        error('A filename must be provided when save=true.');
    end

    % Create destination folder if necessary
    folder = fileparts(opts.filename);

    if strlength(folder) > 0 && ~isfolder(folder)
        mkdir(folder);
    end

    % Open file for writing
    fid = fopen(opts.filename, 'w');

    if fid == -1
        error('Unable to open file: %s', opts.filename);
    end

    % Ensure file is closed even if writing fails
    cleanup = onCleanup(@() fclose(fid));

    fprintf(fid, '%s', reportText);
end

end