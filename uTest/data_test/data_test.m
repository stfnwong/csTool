%% DATA_TEST
% Write a parser to test file handling routines

%Get some data
N      = 64;
tdata = fix(256.*rand(1,N));
% Write data out to file
fr_file = 'fread_testdata.dat';
fid = fopen(fr_file, 'w');
fprintf('Writing data to file %s....\n', fr_file);
fprintf(fid, 'len %d\n', N);
for k = 1:length(tdata)
    fprintf(fid, '%d', tdata(k));
end
fclose(fid);
fprintf('...done\n');

% PARSER
fid = fopen(fr_file, 'r');
tline = fgets(fid);
if(strncmpi(tline, 'len', 3))
    c = '\0';
    while(c ~= ' ')
        %fseek(fid, 1, 'cof');
        c = fscanf(fid, '%c');
    end
    fseek(fid, 1, 'cof');
    N = fscanf(fid, '%d');
    fprintf('N set to %d\n', N);
    %Move to newline 
    while(~strncmpi(c, '\n', 1))
        c = fscanf(fid, '%c');
    end
end
A   = fread(fid, N);
fclose(fid);