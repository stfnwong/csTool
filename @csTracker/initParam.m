function [wparam] = initParam(T, args)
% INITPARAM
% Compute the initial window parameters based on a chosen metric. This function is
% intended to allow prototyping and testing of automatic tracking from segmentation
% data.
%
% ARGUMENTS


% Stefan Wong 2013

	%Parse input arguments
	if(isempty(varargin))
		fprintf('ERROR: Not enough arguments in csTracker.initParam()\n');
		status = -1;
		return;
	else
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'region', 6))
					region = varargin{k+1};
				%More to come
				end
			end
		end
	end

	%Check what we have
	if(exist('region', 'var'))
		%Set the initial window naively as being the same as the region matrix
		if(size(region) ~= [2 2])
			if(T.verbose)
				fprintf('ERROR: region matrix must be 2x2\n');
			end
			wparam = zeros(1,5);
			return;
		end
		%Pull variables out for clarity
		xmin   = region(1,1);
		xmax   = region(1,2);
		ymin   = region(2,1);
		ymax   = region(2,2);
		xc     = (xmin + xmax) / 2;
		yc     = (ymin + ymax) / 2;
		theta  = 0;
		axmaj  = xmax - xc;
		axmin  = ymax - yc;
		wparam = [xc yc theta axmaj axmin];
		return;
	else
		fprintf('ERROR: Non-region method not currently implemented\n');
		wparam = zeros(1,5);
		return;
	end


end 	%initParam()
