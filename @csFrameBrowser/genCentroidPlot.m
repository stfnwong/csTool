function genCentroidPlot(T, fh)
% GENCENTROIDPLOT
%
% Plot a series of centroids for the frame handle fh

	delta = 8;
	
	cla(T.axBuffer);
	hold(T.axBuffer, 'on');
	N     = get(fh, 'nIters');
	param = get(fh, 'winParams'); 

	for k = 1:N
		p  = param{k};
		ph = plot(T.axBuffer, p(1), p(2), 'x');
		set(ph, 'Color', [1 0 0], 'MarkerSize', 8, 'LineWidth', 2);
		th = text(p(1)+delta, p(2), sprintf('Iteration %d (%d,%d)', k, p(1), p(2)));
		set(th, 'Parent', T.axBuffer);
	end

	hold(T.axBuffer, 'off');

end 	%genCentroidPlot()
