function genHistPlot(T, fh)
% GENHISTPLOT
%
% Generate histogram plots for the data associated with the frame handle fh
%

% Stefan Wong 2012

	%Check axes handles
	if(~ishandle(T.axHist))
		error('T.axHist not set or invalid axes handle');
	end
	cla(T.axHist);
	%Subplot handles
	sp = ones(1,2);
	%Get ratio histogram
	rhist = fh.rhist;
	sp(1) = subplot(2,1,1);
	stem(sp(1), 1:length(rhist), rhist, 'Color', [0 1 0]);
	title(sp(1),  'Ratio Histogram')
	xlabel(sp(1), 'Bins');
	ylabel(sp(1), 'Count');
	set(sp(1), 'Parent', get(T.axHist, 'Parent'));
	%Get model histogram
	mhist = T.iSegmenter.getMhist();
	sp(2) = subplot(2,1,2);
	stem(sp(2), 1:length(mhist), mhist, 'Color', [0 0 1]);
	title(sp(2), 'Model Histogram');
	xlabel(sp(2), 'Bins');
	ylabel(sp(3), 'Count');
	set(sp(2), 'Parent', get(T.axHist, 'Parent'));
	

end