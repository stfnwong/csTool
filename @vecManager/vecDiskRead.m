function vec = vecDiskRead(V, file, varargin)
% VECDISKREAD
%

% Stefan Wong 2012


	%Parse optional arguments, if any
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin))
				if(strncmpi(varargin{k}, 'fname', 5))
					filename = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'sz', 2))
					vecSz    = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'or', 2))
					vecOr    = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fmt', 3))
					vecFmt   = varargin{k+1};
				end
			end
		end
	end

	%Check what we have
	if(~exist('fname', 'var'))
		filename = V.rfilename;
	end

	%If the vecSz parameter is specified (and is not scalar) or the vecFmt parameter
	%is specified, parse this to determine the size of the vector (this is the number 
	%of files that need to be opened to recover the data)
	if(exist('fmt', 'var'))
		[vtype vsize] = parseFmt(V, fmt);
	else
		if(~exist('vecSz', 'var') || ~exist('vecOr', 'var'))
			fprintf('ERROR: Format not specified\n');
			vec = [];
			return;
		end
		%Check that parameters are legal
		if(vecSz ~= 32 || vecSz ~= 16 || vecSz ~= 8 || vecSz ~= 4 || vecSz ~= 2)
			%Not a legal value
		else
			vsize = vecSz;		%use alias to simplify coding
		%TODO: Decide what to do with type alias
		if(strncmpi(vecOr, 'row', 3))
			vtype = 'row';
		elseif(strncmpi(vecOr, 'col', 3))
			vtype = 'col';
		else
			fprintf('ERROR: Unsupported vtype %s\n', vecOr);
			vec = [];
			return;
		end
	end

	%Get file contents
	fh = fopen(filename, 'r');
	%If there is an address specifier at the start, skip over this	
	
	%Format file contents into image data based on specified input type	

	


end 	%vecDiskRead()
