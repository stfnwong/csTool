%% TST_GENIMPROC
%
% Generate a generic set of options for a csImProc object and instantiate
% that object. This script is intended for use in unit testing for the
% csTool framework.

fprintf('\n----------------------------------------------------------------\n');
fprintf('TST_GENIMPROC:\n');
fprintf('----------------------------------------------------------------\n');
fprintf('Generating option structures...\n');

seg_opts    = struct('dataSz',  256, ...
	                 'blkSz',    16, ...
					 'nBins',    16, ...
					 'fpgaMode',  1, ...
					 'method',    1, ...
                     'gen_bpvec', 1, ...
					 'mhist', zeros(1,16, 'uint8'), ...
					 'imRegion', region );
track_opts  = struct('method',     1, ...
	                 'verbose',    1, ...
	                 'rotMatrix',  1, ...
					 'fparams',    [], ...
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

imProc = csImProc(improc_opts);
