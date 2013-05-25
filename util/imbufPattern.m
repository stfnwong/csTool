function [vec varargout] = imbufPatternGen(vtype, val, varargin)
% IMBUFPATTEN
% [vec (..OPTIONS..)] = imbufPatternGen(vtype, val, [..OPTIONS..])
%
% Pattern tester for image buffer. This function generates patterns for testing 
% various kinds of concatenating buffers in the CSoC pipeline.
%
% ARGUMENTS
% vtype - Vector type to test ['row', 'col', 'scalar']
% val   - Length of vector
%
% OPTIONAL ARGUMENTS
% 'fname', name - Pass the string 'fname' followed by a filename to write the pattern
%                 test vector to disk using the specified vector type options. 
%                 


% Stefan Wong 2013
       
	debug = false;          

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'fname', 5))
					filename = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					debug = true;
				end
			end
		end
	end

	switch(vtype)
		case 'row' 
		case 'col'	
		case 'scalar'
		otherwise
			fprintf('%s - not a valid vtype\n', vtype);
			vec = [];
			if(nargout > 1)
				varargout{1} = [];
			end
	end




end 	%imbufPatternGen()
