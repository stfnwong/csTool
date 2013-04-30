function [varargout] = blockramVs(imsz, vlen, sfac, range, varargin)
% BLOCKRAMVS
% Show the memory usage of row vs column for a given scaling factor over a give range
% of targets. 
%
% ARGUMENTS
% imsz  - Vector of image size (in [h w] form)
% vlen  - Length of vectorised dimension (in practise, 16 or 8)
% sfac  - Scaling factor to use. Set this to 1 to use a non-scaling buffer
% range - Low and high number of pipelines to compare. E.X: passing in the argument
%         [5 20] will compare resource usage for 5,6,7,...,20 pipelines. If this value
%         is a scalar, the range is assumed to be [1 N], where N is the scalar
%
% OUTPUTS (OPTIONAL)
% varargout{1} - Structure of detailed row statistics
% varargout{2} - Structure of detailed column statistics
%

% Stefan Wong 2013

	PLOT = false;

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'fig', 3))
					ah = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'plot', 4))
					PLOT = true;
				end
			end
		end
	end

	%check optional arguments
	if(exist('ah', 'var'))
		if(~ishandle(ah))
			fprintf('ERROR: ah (%f) not valid figure handle\n', ah);
			if(nargout > 1)
				for k = 1:nargout
					varargout{k} = [];
				end
			end
			return;
		end
	end

	if(length(range) < 2)
		range = [1 range];
	end
	
	if(length(imsz) ~= 2)
		fprintf('ERROR: imsz must be 2 element vector\n');
		if(nargout > 0)
			for k = 1:nargout
				varargout{k} = [];
			end
		end
		return;
	end

	rowbits = zeros(1, length(range(1):range(2)));
	colbits = zeros(1, length(range(1):range(2)));

	for k = range(1):range(2);
		rowbits(k) = blockramEst(imsz, 'row', vlen, k, sfac);
		colbits(k) = blockramEst(imsz, 'col', vlen, k, sfac);
	end

	%Fit line through points
	disp(range)
	xrng   = 1:length(range(1):range(2));
	fprintf('length(xnrg) = %d\n', length(xrng));
	fprintf('length(rowbits) = %d\n', length(rowbits));
	rcoeff = polyfit(xrng, rowbits, 1);
	ccoeff = polyfit(xrng, colbits, 1);
	x_int  = fzero(@(x) polyval(rcoeff - ccoeff, x), 3);
	y_int  = polyval(rcoeff, x_int);
	

	if(PLOT)
		if(~exist('ah', 'var'))
			%Plot onto new axes handle
			ah = axes();
		end
		hold(ah, 'on');
		rp = plot(ah, 1:range(2), rowbits);
		cp = plot(ah, 1:range(2), colbits);
		set(rp, 'Color', [1 0 0], 'Marker', 'v', 'MarkerSize', 2);
		set(cp, 'Color', [0 0 1], 'Marker', 'x', 'MarkerSize', 2);
		rf = plot(1:length(x_int), x_int, 'go', 1:length(y_int), y_int, 'c*');
		title('Row vs Column RAM usage as # pipelines increases');
		xlabel('Number of pipelines');
		ylabel('BlockRAM required (bits)');
		legend('Row Orientation', 'Column Orientation', 'x_int', 'y_int');
		hold(ah, 'off');
	end

	if(nargout > 0)
		stats = {rowbits, colbits};
		for k = 1:nargout
			varargout{k} = stats{k};
		end
	end

end 	%blockramVs()
