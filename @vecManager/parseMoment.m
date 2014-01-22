function [moments niters] = parseMoment(V, fname, varargin)
% MOMENTPARSE
% Parse out the moment data from a text file

	MAX_ITER  = 16;
	NUM_ITERS = 16;

	for k = 1 : length(varargin)
		if(ischar(varargin{k}))
			if(strcmpi(varargin{k}, 'max', 3))
				MAX_ITER = varargin{k+1};
			elseif(strncmpi(varargin{k}, 'num', 3))
				NUM_ITERS = varargin{k+1};
			end
		end
	end

	moments = cell(1,NUM_ITERS);
	fp = fopen(fname, 'r');
	if(fp == -1)
		fprintf('ERROR (parseMoment) Cant open file [%s]\n', fname);
		moments = [];
		niters  = -1;
		return;
	end

	niters = 1;
	while(niters < MAX_ITER)
		mvec = fscanf(fp, '%u ', 6);
		moments{niters} = mvec;
		% Check if there is another line of data
		c = fread(fp, '%c', 1);
		if(strncmpi(c, '\n', 1))
			niters = niters + 1;
		else
			break;
		end
	end


end 	%parseMoment
