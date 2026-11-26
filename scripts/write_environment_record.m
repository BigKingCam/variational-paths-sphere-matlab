function write_environment_record()
%WRITE_ENVIRONMENT_RECORD Save installed MATLAB version and product list.
% Run from any directory after adding repository/scripts to MATLAB path.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
outputFile = fullfile(projectRoot, 'docs', 'matlab_environment.txt');
fid = fopen(outputFile, 'w');
if fid < 0
    error('write_environment_record:File', 'Cannot open %s.', outputFile);
end
cleaner = onCleanup(@() fclose(fid));
fprintf(fid, 'MATLAB version: %s\n', version());
fprintf(fid, 'MATLAB release: %s\n\n', version('-release'));
products = ver();
for k = 1:numel(products)
    fprintf(fid, '%s | version %s\n', products(k).Name, products(k).Version);
end
fprintf('Wrote %s\n', outputFile);
end
