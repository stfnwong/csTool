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

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'num', 3))
			NUM_STEPS = varargin{2};
		end
	end


	%Plot handles are used throughout this function, mainly so that configuration of
	%each plot can be split across multiple lines (my vim sessions are 90 columns)

	params = get(fh, 'winParams');
	if(isempty(params{1}) || isequal(params{1}, zeros(1,5)))
		fprintf('%s no params set for this frame\n', DSTR);
		status = -1;
		return;
	end
	
	%Plot centroids
    N = get(fh, 'nIters');
	hold(axHandle, 'on');
	for k = 1:N
		thisParam = params{k};
		%Be paranoid about length
		if(length(thisParam) < 5)
			fprintf('Not enough elements in param %d\n', k);
			status = -1;
			return;
		end
		%Plot centroid
		ph     = plot(axHandle, thisParam(1), thisParam(2));
		if(k == length(params))
			%Plot final centroid slightly more prominently than others
			set(ph, 'Color', [1 0 0], 'MarkerSize', 16, 'LineWidth', 4, 'Marker','x');
		else
			set(ph, 'Color', [1 0 0], 'MarkerSize', 12, 'LineWidth', 2, 'Marker','x');
		end
	end
	
	%Parametrically plot elliptical confidence region
	p  = params{N};
	e  = gui_calcEllipse(p(1), p(2), p(4), p(5), p(3), NUM_STEPS); 	
    %DEBUG
    fprintf('e:\n');
    disp(e);
	ph = plot(axHandle, e(:,1), e(:,2));
	set(ph, 'Color', [0 0 1], 'LineStyle', '--');

	hold(axHandle, 'off');

end 	%gui_plotParams()
