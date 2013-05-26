function vectors = vecDiskRead(V, file, varargin)
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

	%Parse filename 
	[ef str num ext path] = vname_parse(filename, 'n');
	if(ef == -1)
		fprintf('ERROR: Unable to parse vector filename %s\n', filename);
		vec = [];
		return;
	end
	if(vsize > 1)
		%We need to read a set of files
		filename = cell(1,vsize);
		for k = 1:vsize
			filename{k} = sprintf('%s%s-vec%02d.%s', path, str, k, ext);
		end
	end
	%Compute the expected size of the vector based on input parameters
	switch vecOr
		case 'row'
			numBytes = imgSize(1) / vecSz;
		case 'col'
			numBytes = imgSize(2) / vecSz;
	end

	%Get file contents
	if(length(filename) > 1)
		for k = length(filename):-1:1
			fh(k) = fopen(filename{k}, 'r');
		end
	else
		fh = fopen(filename, 'r');
	end
	%Loop over all required files, reading contents in turn
	if(length(fh) > 1)
		%Allocate some memory for the vectors
		vectors = cell(1,length(fh));
		for k = 1:length(fh)
			%If there is a leading '@' character, skip this (its the address char for
			%modelsim, and is uneeded for reconstructing image)
			fseek(fh(k), 0);
			c = fread(fh(k), 1, 'uint8=>char');
			if(strncmpi(c, '@', 1))
				%Move the pointer over address char (line format: @0 02X 02X 02x...)
				fseek(fh(k), 4, -1);
			else
				fseek(fh(k), 0);		%go back to start
			end
			V = fread(fh(k), 'uint8', numBytes);
			vectors{k} = V;
		end	
	else
		%Do reading operations but on a single file
		fseek(fh, 0);
		c = fread(c, 1, 'uint8=>char');
		if(strncmpi(c, '@', 1))
			fseek(fh, 4, -1);
		else
			fseek(fh, 0);
		end
		vectors = fread(fh, 'uint8', numBytes);
	end	

	%Format file contents into image data based on specified input type	
	switch vecOr
		case 'row'
			img = formatRowVec(vectors, vecSz);
		case 'col'
			img = formatColVec(vectors, vecSz);
	end
	


end 	%vecDiskRead()
