function status = gui_setHistTitle(handles, varargin)
% SETHISTTITLE
% Set the histogram axes title. If no arguments are specified, gui_setHistTitle set
% the model histogram title to 'Model Histogram' and the image histogram title to
% 'Image Histogram'. To specifiy a different title, pass in a name/value pair for
% the axes to change.
%
% ARGUMENTS:
% 'iTitle', title - Title for image histogram axes
% 'mTitle', title - Title for model histogram axes
%

% Stefan Wong 2013

	if(isempty(varargin))
		%Use defaults
		title(handles.fig_mhistPreview, 'Model Histogram');
		%title(handles.fig_ihistPreview, 'Image Histogram');
		status = 0;
		return;
	else
		%Parse input arguments
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'iTitle', 6))
					iTitle = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'mTitle', 6))
					mTitle = varargin{k+1};
				end
			end
		end

		% Sanity check what we have
		if(exist('iTitle', 'var'))
			if(~ischar(iTitle))
				fprintf('ERROR: ihist title must be string\n');
				status = -1;
				return;
			end
		end
		if(exist('mTitle', 'var'))
			if(~ischar(mTitle))
				fprintf('ERROR: mhist title must be string\n');
				status = -1;
				return;
			end
		end
		% Set titles
		%if(~exist('iTitle', 'var'))
		%	title(handles.fig_ihistPreview, 'Image Histogram');
		%else
		%	title(handles.fig_ihistPreview, iTitle);
		%end
		if(~exist('mTitle', 'var'))
			title(handles.fig_mhistPreview, 'Model Histogram');
		else
			title(handles.fig_mhistPreview, mTitle);
		end
	end					
		

end 	%gui_setHistTitle()
