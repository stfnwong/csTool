function status = writeVecData(V, data, varargin)
% WRITEVECDATA
%
% status = writeVecData(V, data, ... [optional arguments])
%
% Write backprojection data to file. By default, this writes data into 16 seperate 
% files with the name specified in V.wfilename appended with the digits 00 - 15. 
% This behaviour and the output filename can be overwritten by passing optional 
% formatting arguments to writeVecData.
%
% ARGUMENTS
% V - vecManager object
% data - Backprojection data to write to file
% 
% OPTIONAL FORMATTING ARGUMENTS
%
%

% Stefan Wong 2012

	if(nargin > 1)
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'fname', 5))
					fname = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fmt', 3))
					fmt = varargin{k+1};
				end
			end
		end
	end

end 	%writeVecData()
