function [status varargout] = gui_printParams(fh, varargin)
% GUI_PRINTPARAMS
% Print frame parameters in MATLAB console, or to string
% Use the 'suppress' option to prevent the string being printed to the MATLAB console.
% This is useful when you only want the actual strings returned via varargout.
%
% Stefan Wong 2013
%

	MOMENTS  = false;		%Don't print moment sums by default
	SUPPRESS = false;		%Dont suppress output
	CONCAT   = false;		%Don't concatenate strings

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'iter', 4))
					iter = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'mo', 2))
					MOMENTS = true;
				elseif(strncmpi(varargin{k}, 'sup', 3))
					SUPPRESS = true;
				elseif(strncmpi(varargin{k}, 'cat', 3))
					CONCAT = true;
				end
			end
		end
	end

	if(exist('iter', 'var'))
        %TODO: This needs to be updated to reflect the fact that wparam is
        %no longer a cell array in this version of csTool
		%Just perform this operation for a single iteration
		wparams  = get(fh, 'winParams');
		thisParam = wparams{iter};
		xc        = sprintf('xc    : %d\n', thisParam(1));
		yc        = sprintf('yc    : %d\n', thisParam(2));
		theta     = sprintf('theta : %d\n', thisParam(3)); 			
		axmaj     = sprintf('axmaj : %d\n', thisParam(4));
		axmin     = sprintf('axmin : %d\n', thisParam(5));
		str       = strcat(xc, yc, theta, axmaj, axmin);
		if(~SUPPRESS)
			fprintf('%s\n', str);
		end
		if(nargout > 1)
			varargout{1} = str;
		end
	else
		wparams = get(fh, 'winParams');
		str     = cell(1, get(fh, 'nIters'));
		for k = 1:get(fh, 'nIters')
			thisParam = wparams{k};
			xc        = sprintf('xc    : %d\n', thisParam(1));
			yc        = sprintf('yc    : %d\n', thisParam(2));
			theta     = sprintf('theta : %d\n', thisParam(3)); 			
			axmaj     = sprintf('axmaj : %d\n', thisParam(4));
			axmin     = sprintf('axmin : %d\n', thisParam(5));
			str{k}    = strcat(xc, yc, theta, axmaj, axmin);
			if(~SUPPRESS)
				fprintf('%s\n', str{k});
			end
		end
		if(nargout > 1)
			for k = 1:nargout-1
				varargout{k} = str{k};
			end
		end
		
	end
	status = 0;

	

	

	



end 	%gui_printParams()
