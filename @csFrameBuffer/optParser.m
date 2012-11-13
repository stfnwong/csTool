% ---- Option Parser ----- %
function opt = optParser(options)
% OPTPARSER
% Parse options for csFrameBuffer class
% 
% Options should be a cell array containing options to set up or modify the 
% properties of a csFrameBuffer object
%
% VALID OPTIONS:

	if(~iscell(options))
		error('Options must be cell array containing name/value pairs');
	end

	%Create a new options structure
	opt.nFrames = 1;
	opt.fNum    = 1;
	opt.path    = ' ';
	opt.verbose = 0;
	
	for k = 1:length(options)
		if(ischar(options{k]))
			%Check which option this is
			if(strncmpi(options{k}, 'nframes', 7))
				opt.nFrames = varargin{k+1};
			elseif(strncmpi(options{k}, 'fnum', 4))
				opt.fNum = varargin{k+1};
			elseif(strncmpi(options{k}, 'path', 4))
				if(~ischar(options{k+1}))
					error('Path must be string');
				else
					opt.path = varargin{k+1};
				end
			end
		end
	end


end 	%optParser()

