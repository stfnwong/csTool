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
					debu     = true;
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
		vecSz = 1;:
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

	%Open file handles and read the data from disk
	if(vecSz == 1)
		%just open one file to read
		fn = sprintf('%s/%s-%03d.%s', path, str, num, ext);
		fh = fopen(fn);
		if(fh == -1)
			fprintf('ERROR: Could not open file [%s]\n', fn);
			%No other files we could possibly use, so exit here
			vectors = [];
			if(nargout > 1)
				varargout{1} = -1;
			end
			return;
		end
	else
		fnum = num:num+vecSz;
		for n = vecSz:-1:1
			fn   = sprintf('%s/%s/-%03d.%s', path, str, fnum(k), ext);
			fh(k) = fopen(fn);
			if(fh(k) == -1)
				fprintf('ERROR: Couldn''t open file [%s]\n', fn(k));
				break;
			end
		end
	end

	%Open the files and organise into a cell array, each element containing the vector
	%stream for that file
	if(length(fh) > 1)
		vectors = cell(1, length(fh));
		for k = 1:length(fh)
			%Skip the leading '@' character, if it exists (modelsim address char)
			c = fread(fh(k), 1, 'uint8=>char');
			if(strncmp(c, '@', 1))
				fseek(fh(k), 4, -1);
			else
				fseek(fh(k), 0);
			end
			vectors{k} = fread(fh(k), 'uint8');
		end
	else
		c = fread(fh, 1, 'uint8=>char');
		if(strncmp(c, '@', 1))
			fseek(fh, 4, -1);
		else
			fseek(fh, 0);
		end
		vectors{1} = fread(fh, 'uint8');
	end

end 	%vecDiskRead()
