function [wparam] = initParam(T, args)
% INITPARAM
% Compute the initial window parameters based on a chosen metric. This function is
% intended to allow prototyping and testing of automatic tracking from segmentation
% data.
%
% ARGUMENTS


% Stefan Wong 2013

	%Parse input arguments
	if(isempty(args))
		fprintf('ERROR: Not enough arguments in csTracker.initParam()\n');
		wparam = zeros(1,5);
		return;
	else
		%DEBUG:
		fprintf('(csTracker.initWindow -> initParam()) : args contents:\n');
		for k = 1:length(args)
			fprintf('args{%d}', k);
			disp(args{k});
			fprintf('\n');
		end
		for k = 1:length(args)
			if(ischar(args{k}))
				if(strncmpi(args{k}, 'region', 6))
					region = args{k+1};
				end
			end
		end
	end

	%Check what we have
	if(exist('region', 'var'))
		%Set the initial window naively as being the same as the region matrix
		%if(size(region) ~= [2 2])
		if(~isequal(size(region), [2 2]))
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
