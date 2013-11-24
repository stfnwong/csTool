function status = bufDiskRead(FB, fh, filename)
% BUFDISKREAD
% status = bufDiskRead(FB, filename)
%
% Read frame data from disk
%
% ARGUMENTS:
% FB       - csFrameBuffer object
% fh       - csFrame handle to write data to
% filename - Name of *.mat file to read
% 
% OUTPUTS
% status   - Returns -1 if file doesn't exist, 0
%            otherwise.

% Stefan Wong 2013

	% Check that file exists
	if(exist(filename, 'file') ~= 2)
		status = -1;
		return;
	end

	frameStruct = load(filename);
	set(fh, 'img',       frameStruct.img);
	set(fh, 'bpImg',     frameStruct.bpImg);
	set(fh, 'bpVec',     frameStruct.bpVec);
	set(fh, 'bpSum',     frameStruct.bpSum);
	set(fh, 'rhist',     frameStruct.rhist);
	set(fh, 'ihist',     frameStruct.ihist);
	set(fh, 'winParams', frameStruct.winParams);
	set(fh, 'winInit',   frameStruct.winInit);
	set(fh, 'moments',   frameStruct.moments);
	set(fh, 'nIters',    frameStruct.nIters);
	set(fh, 'tVec',      frameStruct.tVec);
	set(fh, 'dims',      frameStruct.dims);
	set(fh, 'isSparse',  frameStruct.isSparse);
	set(fh, 'sparseFac', frameStruct.sparseFac);
	set(fh, 'filename',  frameStruct.filename);
	set(fh, 'method',    frameStruct.method);

	status = 0;

end 	%bufDiskRead()
