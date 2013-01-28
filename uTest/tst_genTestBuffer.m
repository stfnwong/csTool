%% TST_GENTESTBUFFER
%
% Automatically populate and test a csFrameBuffer and csFrameBrowser object
% for use in other unit tests.
%
% The fbrs_opts and fbuf_opts structs are assumed to already exist in the
% workspace with the above names before the script is run. 
%
% Stefan Wong 2012


%Check for options in workspace 
if(~exist('fbuf_opts', 'var'))
	error('tst_genTestBuffer requires fbu_opts struct in workspace');
end
if(~exist('fbrs_opts', 'var'))
	error('tst_genTestBuffer requires fbrs_opts struct in workspace');
end
%Do sanity check on structures
if(~isa(fbuf_opts, 'struct'))
	error('Invalid options structure fbuf_opts');
end
if(~isa(fbrs_opts, 'struct'))
	error('Invalid options structure fbrs_opts');
end

%Generate objects and populate
fprintf('\n----------------------------------------------------------------\n');
fprintf('TST_GENTESTBUFFER:\n');
fprintf('----------------------------------------------------------------\n');
fprintf('Generating buffer objects...\n');
fbuf          = csFrameBuffer(fbuf_opts);
fbrs          = csFrameBrowser(fbrs_opts);
fprintf('...done\n');
fprintf('Loading buffer....\n');
[fbuf status] = loadFrameData(fbuf);
if(status == 0)
	error('Failed to load data from %s', fbuf.showPath());
else
	fprintf('Successfully read %d files\n', fbuf_opts.nFrames);
end
%Randomly read some frames from buffer
if(fbuf_opts.nFrames > 24)
	N = fix(fbuf_opts.nFrames / 8);
else
	N = 4;
end
fprintf('Previewing %d random frames...\n', N);
sVec = fix(fbuf_opts.nFrames.*rand(1,N));
sVec(sVec == 0) = 1;		%Get rid of zero values

for k = 1:length(sVec)
	if(fbuf.verbose)
		disp(fbrs);
	end
	fprintf('Generating preview for figure %d [%d of %d]\n', sVec(k), k, length(sVec));
	fh = fbuf.getFrameHandle(sVec(k));
	fbrs.plotPreview(fh);
	pause(1);
end
fprintf('...done\n');
fprintf('\n----------------------------------------------------------------\n');



