function [vectors varargout] = vecDiskRead(V, file, varargin)
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
				elseif(strncmpi(varargin{k}, 'size', 4))
					imgSize  = varargin{k+1};
				end
			end
		end
	end

	%Check what we have
	if(~exist('fname', 'var'))
		filename = V.rfilename;
	end
	if(~exist('imgSize', 'var'))
		imgSize = [640 480];
	else
		if(length(imgSize) > 2)
			fprintf('ERROR: Too many elements in imgSize, using default (640x480)\n');
			imgSize = [640 480];
		end
	end
	%If no vector orientation specified, assume scalar
	if(~exist('vecOr', 'var'))
		vecOr = 'scalar';
	end
	%If no vector size, assume 16 (this will be ignored if we are in scalar mode)
	if(~exist('vecSz', 'var'))
		vecSz = 16;
	end

	%We expect there to be N vector files, where N is the length of the vector, so 
	%if the mode isn't scalar, parse the file format and try to read N files
	if(~strcmpi(vecOr, 'scalar'))
		fn = cell(1, vecSz);
		[ef str num ext path] = fname_parse(filename, 'n');
		if(ef == -1)
			fprintf('ERROR: parse error in file %s\n', filename);
			vectors = [];
			if(nargout > 1 )
				varargout{1} = -1;
			end
			return
		end
		for k = 1:vecSz
			%[ef str num ext path] = fname_parse(filename, 'n');
			fn  = sprintf('%s/%s-%02d.%s', path, str, k, ext);
		end	
	else
		%Just check that the file parses correctly
		[ef str num ext path] = fname_parse(filename. 'n');
		if(ef == -1)
			fprintf('ERROR: parse error in file %s\n', filename);
			vectors = [];
			if(nargout > 1)
				varargout{1} = -1;
			end
			return;
		end
	end
	
	%%Get file contents
	%if(length(filename) > 1)
	%	for k = length(filename):-1:1
	%		fh(k) = fopen(filename{k}, 'r');
	%	end
	%else
	%	fh = fopen(filename, 'r');
	%end
	%%Loop over all required files, reading contents in turn
	%if(length(fh) > 1)
	%	%Allocate some memory for the vectors
	%	vectors = cell(1,length(fh));
	%	for k = 1:length(fh)
	%		%If there is a leading '@' character, skip this (its the address char for
	%		%modelsim, and is uneeded for reconstructing image)
	%		fseek(fh(k), 0);
	%		c = fread(fh(k), 1, 'uint8=>char');
	%		if(strncmpi(c, '@', 1))
	%			%Move the pointer over address char (line format: @0 02X 02X 02x...)
	%			fseek(fh(k), 4, -1);
	%		else
	%			fseek(fh(k), 0);		%go back to start
	%		end
	%		V = fread(fh(k), 'uint8', numBytes);
	%		vectors{k} = V;
	%	end	
	%else
	%	%Do reading operations but on a single file
	%	fseek(fh, 0);
	%	c = fread(c, 1, 'uint8=>char');
	%	if(strncmpi(c, '@', 1))
	%		fseek(fh, 4, -1);
	%	else
	%		fseek(fh, 0);
	%	end
	%	vectors = fread(fh, 'uint8', numBytes);
	%end	

	%%Format file contents into image data based on specified input type	
	%switch vecOr
	%	case 'row'
	%		img = formatRowVec(vectors, vecSz);
	%	case 'col'
	%		img = formatColVec(vectors, vecSz);
	%end
	


end 	%vecDiskRead()
