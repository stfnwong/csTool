%% FRAME BUFFER TEST
%
% This script tests that the csFrameBuffer object can load data from disk, and that
% the frame browser can display data in the frame buffer.

% Stefan Wong 2012

%Path to asset directories
path = '../assets/frames/2g1ctest_';
%Get axes handle
if(exist('ah', 'var'))
	axes(ah);
else
	ah = axes();
end
%Setup options for csFrameBuffer, csFrameBrowers options
fbuf_opts = struct('nFrames', 64, ...
                   'path', path,  ...
                   'ext', 'tif',  ...
                   'fNum', 1,     ...
                   'verbose', 1);
fbrs_opts = struct('axhandle', ah, 'plotgaussian', 1, 'verbose', 1);
% Get a new frame buffer and frame browser
fbuf = csFrameBuffer(fbuf_opts);
fbrs = csFrameBrowser(fbrs_opts);
%load data
if(~fbuf.loadFrameData())
	error('Failed to load frame data at %s', fbuf.showPath());
else
	fprintf('Loaded frame data from %s\n', fbuf.showPath());
end
