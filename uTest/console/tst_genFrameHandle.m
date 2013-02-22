%% TST_GENFRAMEHANDLE
%
% Generate a frame handle for use with unit tests.
%  


% Stefan Wong 2012

% Modify these values for the specific unit test
filename = 'uTest/assets/frame/2g1ctest_032.tif';
[fname num ext exitflag] = fname_parse(filename);
if(exitflag == -1)
	error('Problem parsing filename %s ', filename);
end

fh = csFrame();
set(fh, 'filename', filename);










