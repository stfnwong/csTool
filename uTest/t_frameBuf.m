%% FRAME BUFFER TEST
%
% This script tests that the csFrameBuffer object can load data from disk, and that
% the frame browser can display data in the frame buffer.

% Stefan Wong 2012

%Make sure workspace only has data for this test
close all; clear classes; clear all;
%Path to asset directories
path = 'uTest/assets/frames/2g1ctest';

% ---- TEST PARAMETERS ---- %
nSamp = 8;		%number of frames to test
%Use a predefined stock region for generating histogram in this test
region = [200 332 ; 109 257];

%Setup figure handles for csFrameBrowser
if(~exist('prevFig', 'var'))
	prevFig = figure('Name', 'Image Preview');
end
if(~exist('browseFig', 'var'))
	browseFig = figure('Name', 'Image Browser');
end
if(~exist('histFig', 'var'))
	histFig = figure('Name', 'Image Histograms');
end
%Setup axis handles for csFrameBrowser
if(~exist('prevAx', 'var'))
	prevAx = axes('Parent', prevFig);
end
set(prevFig, 'CurrentAxes', prevAx);
if(~exist('browseAx', 'var'))
	browseAx = axes('Parent', browseFig);
end
set(browseFig, 'CurrentAxes', browseAx);
if(~exist('histAx', 'var'))
	histAx = axes('Parent', histFig);
end
set(histFig, 'CurrentAxes', histAx);
%Setup options for csFrameBuffer, csFrameBrowers options
fbuf_opts = struct('nFrames', 64,   ...
                   'path', path,    ...
                   'ext', 'tif',    ...
                   'fNum', 102,     ...
                   'verbose', 1);
fbrs_opts = struct('axPreview', prevAx,   ...
	               'axBuffer',  browseAx, ...
				   'axHist',    histAx,   ...
				   'plotgaussian', 1,     ...
				   'verbose',      1);
% Get a new frame buffer and frame browser
fbuf = csFrameBuffer(fbuf_opts);
fbrs = csFrameBrowser(fbrs_opts);
%load data
[fbuf status] = loadFrameData(fbuf);
if(status == 0)
	error('Failed to load data from %s', fbuf.showPath());
else
	fprintf('Sucessfully read files from %s to %s\n', ...
		                 fbuf.showPath('start'), fbuf.showPath('end'));
end
%Get sample vector contaning random indicies of image to plot
sVec = fix(fbuf_opts.nFrames.*rand(1,nSamp));
figure(prevFig);
for k = 1:length(sVec)
	fprintf('Generating preview for figure %d...\n', sVec(k));
	fh = fbuf.getFrameHandle(sVec(k));
	fbrs.plotPreview(fh);
	pause(2);
end


