function [vec varargout] = catVecStream(V, vtype, val, varargin)
% CATVECSTREAM
% [vec (..OPTIONS..)] = catVecStream(V, [..OPTIONS..])
% Concatenate a set of vector streams together into a cell array for verification.
% The function can operate in several modes. Pass in the filename of the first in a 
% numbered series of vectors ending in _NNN.dat (where NNN is the number in the 
% series) and a number K to read and catVecStream() will attempt to read K files from
% disk. Alteratively, pass in a cell array of filenames, and catVecStreams() will 
% attempt to read files and concatenate in the array order.
%
% ARGUMENTS
% V     - vecManager object
% vtype - Type of vector to concatenate into ['row', 'col', 'scalar']
% val   - Length to concatenate vector to 
%
% OPTIONAL ARGUMENTS
% 'fname' - Name of vector file to read
% 'seq'   - Read in sequentially numbered vectors
% 'num'   - Number of sequential vectors to read 
% 'list'  - Pass in a list of filenames as a cell array
%
% OUTPUTS
% vec - Cell array of concatenated vectors


% Stefan Wong 2013

	seq = false;
	list = false;
	debug = false;

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'seq', 3))
					seq = true;
					list = false;
				elseif(strncmpi(varargin{k}, 'list', 4))
					seq = false;
					list = true;
				elseif(strncmpi(varargin{k}, 'num', 3))
					N    = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fname', 5))
					fname = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					debug = true;
				end
			end
		end
	end

	%Check what we have
	if(~exist('fname', 'var'))
		fprintf('ERROR: No filename specified, aborting...\n');
		vec = [];
		if(nargout > 1)
			for k = 1:nargout-1
				varargout{k} = [];
			end
		end
		return;
	end
	
	%Read data from disk
	if(seq)

	elseif(list)
	
	end

	%Perform concatenation
	switch(vtype)
		case 'row'
		case 'col'
		case 'scalar'
		otherwise
			fprintf('ERROR: Not a valid vtype (%s)\n', vtype);
			vec = [];			
			if(nargout > 1)
				varargout{1} = -1;
			end
	end


end 	%catVecStream()
