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

	if(~isempty(varargin))
		fprintf('Optional features not yet implemented\n');
	end


	%Plot handles are used throughout this function, mainly so that configuration of
	%each plot can be split across multiple lines (my vim sessions are 90 columns)

	params = get(fh, 'winParams');
	%if(isempty(params) || params == 0)
	%	fprintf('%s no params set for this frame\n', DSTR);
	%	status = -1;
	%	return;
	%end
	
	%Plot centroids
	hold(axHandle, 'on');
	for k = 1:length(params)
		thisParam = params{k};
		%Plot centroid
		ph     = plot(axHandle, thisParam(1), thisParam(2));
		if(k == length(params))
			%Plot final centroid slightly more prominently than others
			set(ph, 'Color', [1 0 0], 'MarkerSize', 16, 'LineWidth', 4);
		else
			set(ph, 'Color', [1 0 0], 'MarkerSize', 12, 'LineWidth' 2);
		end
	end
	hold(axHandle, 'off');
	
	%Plot confidence region
	fprintf('CONFIDENCE REGION PLOT TO GO WHERE THIS TEXT APPEARS!\n');

	%

end 	%gui_plotParams()
