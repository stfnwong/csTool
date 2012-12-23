%% SEGMENTATION AND TRACKING TEST
% This test instantiates a csFrameBuffer, reads data into in from a set
% path, and performs a basic segmentation and tracking pass with some
% default parameters

% Stefan Wong 2012

%Make sure workspace only has data for this test
close all; clear classes; clear all;
%Path to asset directories
path = 'uTest/assets/frames/2g1ctest';

% ---- TEST PARAMETERS ---- %
nSamp = 4;		%number of frames to test
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

% ---- OPTIONS STRUCTURES FOR OBJECTS ---- %
%Setup options for csFrameBuffer, csFrameBrowers options
fbuf_opts = struct('nFrames', 4,   ...
                   'path', path,    ...
                   'ext', 'tif',    ...
                   'fNum', 274,     ...
                   'verbose', 1);
fbrs_opts = struct('axPreview', prevAx,   ...
	               'axBuffer',  browseAx, ...
				   'axHist',    histAx,   ...
				   'plotgaussian', 1,     ...
				   'verbose',      1);
%Setup options for csTracker, csSegmenter, and csImproc objects
% Note that the csImProc options can contain option structures for the
% tracker and segmenter sub-components
seg_opts    = struct('dataSz',  256, ...
	                 'blkSz',    16, ...
					 'nBins',    16, ...
					 'fpgaMode',  1, ...
					 'method',    1, ...
                     'gen_bpvec', 0, ...
					 'mhist', zeros(1,16, 'uint8'), ...
					 'imRegion', region );
track_opts  = struct('method',     1, ...
	                 'verbose',    1, ...
	                 'rotMatrix',  1, ...
					 'cordicMode', 0, ...
					 'bpThresh',   0, ...
					 'fixedIter',  1, ...
					 'maxIter',    2, ...
					 'epsilon',    0);
improc_opts = struct('trackType',  1, ...
	                 'segType',    1, ...
					 'segOpts',   seg_opts, ...
					 'trackOpts', track_opts, ...
					 'verbose',    1);
fprintf('Generating objects...\n');
% Get a new frame buffer and frame browser
fbuf   = csFrameBuffer(fbuf_opts);
fbrs   = csFrameBrowser(fbrs_opts);
% Get a new image processor
imProc = csImProc(improc_opts);
%load data
[fbuf status] = loadFrameData(fbuf);
if(status == 0)
	error('Failed to load data from %s', fbuf.showPath());
else
	fprintf('Sucessfully read files from %s to %s\n', ...
		                 fbuf.showPath('start'), fbuf.showPath('end'));
end
%Get sample vector contaning random indicies of image to plot
fprintf('\nPreviewing %d random frames...\n\n', nSamp);
sVec = fix(fbuf_opts.nFrames.*rand(1,nSamp));
sVec(sVec == 0) = 1;
figure(prevFig);
for k = 1:length(sVec)
	fprintf('Generating preview for figure %d...\n', sVec(k));
	fh = fbuf.getFrameHandle(sVec(k));
	fbrs.plotPreview(fh);
	pause(1);
end

% Setup model histogram
fprintf('Getting model histogram...\n');
imProc = imProc.initProc(fbuf.getFrameHandle(1), 'imregion', region, 'setdef');
%Check that region was set correctly
fprintf('imProc.getImRegion() :\n');
disp(imProc.getImRegion());
%Show model histogram in console
mhist  = imProc.getCurMhist();
disp(mhist);

% ---- Segment and track frames ---- %
fprintf('Starting segmentation and tracking test...\n');

%Generate array of frame handles
for k = fbuf_opts.nFrames:-1:1
    fh(k) = fbuf.getFrameHandle(k);
end
%Process frames in procLoop()
fprintf('Processing frames...\n');
imProc = imProc.procLoop(fh);
%Plot result of nSamp random frames
fprintf('\nPlotting data for %d random frames...\n\n', nSamp);
sVec = fix(fbuf_opts.nFrames.*rand(1,nSamp));
sVec(sVec == 0) = 1;
for k = 1:length(sVec)
	fprintf('Plotting data for frame %d...\n', sVec(k));
	fhCur = fbuf.getFrameHandle(sVec(k));
	fbrs.plotFrame(fhCur);
	pause(3);
end




% ---- OLD FRAME PROCESSING 
% for n = 1:nFrames;
% 	fprintf('FRAME %d:\n', n);
% 	if(n == 1)
% 		fhCur  = fbuf.getFrameHandle(n);
% 		imProc = imProc.procFrame(fhCur);
% 	else
% 		%TODO: this method of setting initial window params seems
% 		%pretty clunky....
% 		%fhPrev = fbuf.getFrameHandle(n-1);
% 		fhCur  = fbuf.getFrameHandle(n);
% 		%fhCur.setInitParams(fhPrev.winParams{end});
% 		imProc = imProc.procFrame(fhCur);
% 	end
% 	%DEBUG
% 	fprintf('imProc.iTracker.fParams for frame %d\n', n);
% 	imProc.getTrackerFParams()
% 	waitbar(n/nFrames, wb, sprintf('Processed frame %d/%d...', n, nFrames));
% end

