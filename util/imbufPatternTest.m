function [status varargout] = imbufPatternTest(vtype, val, vec, varargin)
% IMBUFPATTERNTEST
% [status (..OPTIONS..)] = imbufPatternTest(vtype, val, vec, [..OPTIONS..])
%
% Verify pattern test output against reference vector
%
% ARGUMENTS
%
% OPTIONAL ARGUMENTS
% 'ref', refVec - Use the reference vector refVec
% 'gen', fname  - Generate the reference vector from the data in the file with name
%                 fname. If both this and ref option is specified, this option takes
%                 precedence.
%
%

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'ref', 3))
					refVec = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'gen', 3))
					genVec = true;
					fname  = varargin{k+1};
				end
			end
		end
	end

	%Check input arguments
	if(genVec)
		%Sanity check arguments
		if(~ischar(fname))
			fprintf('ERROR: Filename fname must be string\n');
			status = -1;
			if(nargout > 1)
				varargout{1} = [];
			end
			return;
		end
		
	elseif(exist('refVec', 'var'))

	end

	%By here, we should have a well-formed vector ready to test

	switch(vtype)
		case 'row'
		case 'col'
		case 'scalar'
		otherwise
			fprintf('%s - not a valid vtype\n', vtype);
	end

end 	%imbufPatternTest
