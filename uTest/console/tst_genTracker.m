%% TST_GENTRACKER
%
% Create csTracker object. Modify options strucutre in this script to suit test
%
% Stefan Wong 2012
%


track_opts  = struct('method',     1, ...
	                 'verbose',    1, ...
	                 'rotMatrix',  1, ...
					 'fparams',    [], ...
					 'cordicMode', 0, ...
					 'bpThresh',   0, ...
					 'fixedIter',  1, ...
					 'maxIter',    2, ...
					 'epsilon',    0);
tst_Tracker = csTracker(track_opts);
