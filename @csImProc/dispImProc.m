function dispImProc(I)
% DISPIMPROC
%
% Display contents of csImProc object

% Stefan Wong 2012

	fprintf('\n -------- csImProc -------\n');
	fprintf('csImProc.trackType = %s\n', I.trackStr{I.trackType});
	fprintf('csImProc.segType   = %s\n', I.segStr{I.segType});
	fprintf('csImProc.verbose   = %d\n', I.verbose);
	if(I.verbose)
		%Also display sub-objects
		fprintf('\n[csImProc.csSegmenter]:\n');
		disp(I.iSegmenter);
		fprintf('\n[csImProc.csTracker]:\n');
		disp(I.iTracker);
	end
	fprintf('\n');

end
