%% TST_TRACKINGNOIMPROC
% 
% Correctness test for tracking routine. 
% This test creates standalone csTracker and csSegmenter objects, and runs a tracking
% test on a series of frames to check the correctness of both the algorithm and the 
% csFrameBrowser
% 
% Stefan Wong 2012
%

TST_START_FRAME = 1;
TST_NUM_FRAMES  = 32;

tst_genBufOpts;
tst_genTestBuffer;
%Get tracker, segmenter

[tracker ~]   = f_tstTracker();
[segmenter ~] = f_tstSegmenter();

%Start tracking process
fprintf('\n-------------------------------\n');
fprintf('Starting segmentation and tracking test...\n');
fprintf('\n-------------------------------\n');

%Get frame handles
for k = TST_START_FRAME + TST_NUM_FRAMES : -1 : TST_START_FRAME
	fh(k) = fbuf.getFrameHandle(k);
end

wb = waitbar(0, sprintf('Starting frame processing (0/%d)...', TST_NUM_FRAMES));
for k = TST_START_FRAME : TST_START_FRAME + TST_NUM_FRAMES
	segmenter.segFrame(fh(k));
	%Check segmentation
	sz = size(get(fh(k), 'bpVec'));
	if(sz(1) == 0 || sz(2) == 0)
		delete(wb);
		error('fh(%d) has bpVec size 0 in one or more dimensions\n', k);
	end
	tracker.trackFrame(fh(k));
	waitbar(k/(k+TST_NUM_FRAMES), wb, sprintf('Processing frame (%d/%d)', ...
                                                k, k+TST_NUM_FRAMES)); 
end

delete(wb);
fprintf('...Segmentation and Tracking complete.\n\n');

% Read data back from frame browser

for k = TST_START_FRAME : TST_START_FRAME + TST_NUM_FRAMES
	fbrs.plotFrame(fh(k));
	fbrs.plotHist(fh(k));
	pause(1);
end
