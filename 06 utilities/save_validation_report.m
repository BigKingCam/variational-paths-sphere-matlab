function save_validation_report(filename, reportFcn)
%SAVE_VALIDATION_REPORT Save console output from a report function.
%
% filename  - Destination .txt file
% reportFcn - Function handle executing the report

arguments (Input)
    filename (1,1) string
    reportFcn (1,1) function_handle
end

% Ensure the destination directory exists
folder = fileparts(filename);

if strlength(folder) > 0 && ~isfolder(folder)
    mkdir(folder);
end

% Capture report output as text
reportText = evalc('reportFcn()');

% Print report to console
fprintf('%s', reportText);

% Write the captured output to the file
fid = fopen(filename, 'w');

if fid == -1
    error('Unable to open report file: %s', filename);
end

cleanup = onCleanup(@() fclose(fid));

fprintf(fid, '%s', reportText);

end