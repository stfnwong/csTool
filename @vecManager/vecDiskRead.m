function [vectors varargout] = vecDiskRead(V, varargin)
% VECDISKREAD
%
% ARGUMENTS
% V - vecManager object
% file - Filename to read vectors from. If this is the first in a series of files 
% (for example a set of backprojection vectors), the filename should be numbered with
% the first in the series to read.
%
% OPTIONAL ARGUMENTS
% 'fname', filename - Filename to read vectors from. If this is the first in a series
%                     of files (for example a set of backprojection vectors), the 
%                     filename should be numbered with the first in the series to 
%                     read). If no filename parameter is specified, vecDiskRead() 
%                     will use the filename in V.rfilename.
% 
% 'sz', size        - Size of vector. This property is used to determine the number 
%                     of files to read from disk. If no size is specified, scalar is  
%                     assumed.
%
% OUTPUTS
% vectors           - An array containing the data stream, or a cell array, each 
%                     element of which contains one data stream. The size of the cell
%                     array is normally vecSz, however if some of the files cannot be
%                     read, vecDiskRead() will attempt to open as many files as it 
%                     can. In this case, the size is equal to the number of files 
%                     successfully opened. vecDiskRead() will return the status code
%                     2 in this case (if requested)
% 
% OPTIONAL OUTPUTS
% status            - Equals 0 if no issues found, -1 if an error, and 2 if some of 
%                     the files could not be read. 
%

% Stefan Wong 2012

	debug = false;

	%Parse optional arguments, if any
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin))
				if(strncmpi(varargin{k}, 'fname', 5))
					filename = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'sz', 2))
					vecSz    = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					debug    = true;
				end
			end
		end
	end

	%Check what we have
	if(~exist('fname', 'var'))
		filename = V.rfilename;
	end
	%If no vector size, assume scalar
	if(~exist('vecSz', 'var'))
		vecSz = 1;
	end

	%Attempt to parse the filename here. If this step fails, the filename isn't in the
	%proper format anyway, so bail
	[ef str num ext path] = fname_parse(filename, 'n');
	if(ef == -1)
		fprintf('ERROR: parse error in [%s], filename not valid format\n', filename);
		vectors = [];
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

	if(vecSz > 1)
		vectors = cell(1, vecSz);
	else
		vectors = cell(1,1);
	end	

	% Attempt to open files, placing data into cell array as we go
	k = 1;
	for n = num:(num+vecSz)
		fn = sprintf('%s/%s/-%03d.%s', path, str, n, ext);
		fh = fopen(fn);
		if(fh == -1)
			fprintf('ERROR: Couldn''t open file [%s]\n', fn(k));
			break;
		end
		%Skip the leading '@' character, if it exists (modelsim address char)
		c = fread(fh, 1, 'uint8=>char');
		if(strncmp(c, '@', 1))
			fseek(fh, 4, -1);
		else
			fseek(fh, 0);
		end
		vectors{k} = fread(fh, 'uint8');
		k = k + 1;
	end
	if(n < vecSz)
		%We didn't manage to read all files, format error code and return what we have
		fprintf('Read %d of %d files\n', n, vecSz);
		if(nargout > 1)
			varargout{1} = 2;
		end
		vectors = vectors{1:n};
	else
		if(nargout > 1)
			varargout{1} = 0;
		end
	end

end 	%vecDiskRead()


