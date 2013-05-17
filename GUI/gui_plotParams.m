function status = gui_plotParams(fh, axHandle, varargin)
% GUI_PLOTPARAMS
% status = gui_plotParams(fh, axHandle)
%
% Plot frame parameters over preview image in csToolGUI
% 
% This function takes the frame param data for the frame handle fh and plots it onto
% the axes with handle axHandle. The function replaces the plotParams() method in
% csFrameBrowser in csToolGUI. When using csTool in console mode, it is reccomended
% to use the methods in csFrameBrowser instead. As this function may be called in a 
% loop, it is the callers responsibility to ensure the inputs are sanitised.
%
% ARGUMENTS:
%
% OUTPUT:
% status - A 0 indicates the operation was performed sucessfully. -1 indicates a fail
%

% Stefan Wong 2013

	%Set internal constants
	DSTR = '(gui_plotParams) :';
	NUM_STEPS = 25;		%lower is faster - can set with 'num' flag
	PLOT_RECT = true;

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'iter', 4))
					N = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'num', 3))
					NUM_STEPS = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'el', 2))
					PLOT_RECT = false;		%plot ellipse instead
				end
			end
		end
	end

	%Plot handles are used throughout this function, mainly so that configuration of
	%each plot can be split across multiple lines (my vim sessions are 90 columns)

	params = get(fh, 'winParams');
	if(isempty(params) || isequal(params, zeros(1,5)))
		fprintf('%s no params set for this frame\n', DSTR);
		status = -1;
		return;
	end
	
	%Plot centroids
	if(~exist('N', 'var'))
	    N = get(fh, 'nIters');
	end
	hold(axHandle, 'on');
	
	moments = get(fh, 'moments');
	for k = 1:N
		m = moments{k};
		% Check length
		if(length(m) < 6)
			fprintf('Not enough elements in moments for iter %d\n', k);
			status = -1;
			return;
		end
		%Plot centroid
		ph = plot(axHandle, m(2)/m(1), m(3)/m(1));
		if(k == N)
			%Plot final centroid slightly larger
			set(ph, 'Color', [1 0 0], 'MarkerSize', 16, 'LineWidth', 4, 'Marker', 'x');
		else
			set(ph, 'Color', [0 1 0], 'MarkerSize', 12, 'LineWidth', 2, 'Marker', 'x');
		end
	end
 	
	%Parametrically plot confidence region
	p  = params;
	if(PLOT_RECT)
		%plot as rectangle
		[l r t b] = gui_calcRect(p(1), p(2), p(4), p(5), p(3), NUM_STEPS);
		plot(axHandle, l(1,:), l(2,:), 'Color', [0 0 1], 'LineStyle', '--');
		plot(axHandle, r(1,:), r(2,:), 'Color', [0 0 1], 'LineStyle', '--');
		plot(axHandle, t(1,:), t(2,:), 'Color', [0 0 1], 'LineStyle', '--');
		plot(axHandle, b(1,:), b(2,:), 'Color', [0 0 1], 'LineStyle', '--');
	else
		%plot as ellipse
		e  = gui_calcEllipse(p(1), p(2), p(4), p(5), p(3), NUM_STEPS); 	
		eh = plot(axHandle, e(:,1), e(:,2));
		set(eh, 'Color', [0 0 1], 'LineStyle', '-');
	end
	hold(axHandle, 'off');
	status = 0;
	
end 	%gui_plotParams()
