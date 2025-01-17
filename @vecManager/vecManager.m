classdef vecManager
% VECMANAGER
%
% Manage test vectors for Verilog/VHDL testbenches.
%
% TODO : Document

% TODO : Have variable sized trajectory buffer

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'private')
		wfilename;
		rfilename;
		destDir;
		vecdata;
		vfParams;		%verification parameters structure
		bpvecFmt;		%character code for backprojection vector format
		% TRAJECTORY PARAMETERS
		bufSize;
		trajBuf;
		trajLabel;		%labels for GUI
		% DATA PARAMETERS
		errorTol;		%integer error tolerance in data (ie: +/- errorTol)
		dataSz;			%size of data word in FPGA
	end 	

	properties (SetAccess = 'private', GetAccess = 'public')
		autoGen;
		verbose;
		fmtStr = {'scalar', '4c', '8c', '16c', '4r', '8r', '16r'};
	end

	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function V = vecManager(varargin)
			
			switch nargin
				case 0
					%Default init
					V.wfilename = ' ';	
					V.rfilename = ' ';
					V.destDir   = ' ';
 					V.vecdata   = [];
					V.vfParams  = [];
					V.bpvecFmt  = 'scalar';
					V.bufSize   = 8;
					V.trajBuf   = cell(1, V.bufSize);
					V.trajLabel = cell(1, V.bufSize);
					V.errorTol  = 0;
					V.dataSz    = 256;
					V.autoGen   = 0;
					V.verbose   = 0;
				case 1
					if(isa(varargin{1}, 'vecManager'))
						V = varargin{1};
					else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts = varargin{1};
						V.wfilename = opts.wfilename;
						V.wfilename = opts.rfilename;
						V.destDir   = opts.destDir;
						V.vecdata   = opts.vecdata;
						V.vfParams  = opts.vfParams;
						V.bpvecFmt  = opts.bpvecFmt;
						%V.trajBuf   = opts.trajBuf;
						%V.trajLabel = opts.trajLabel;
						V.bufSize   = opts.bufSize;
						V.trajBuf   = cell(1,opts.bufSize);
						V.trajLabel = cell(1, opts.bufSize);
						V.errorTol  = opts.errorTol;
						V.dataSz    = opts.dataSz;
						V.autoGen   = opts.autoGen;
						V.verbose   = opts.verbose;
					end
				otherwise
					error('Incorrect constructor arguments');
			end
		end 	%vecManager() CONSTRUCTOR

		% ---- GETTER METHODS ---- %
		%Getter for csToolGUI
		function opts = getOpts(V)
			opts = struct('wfilename', V.wfilename, ...
                          'rfilename', V.rfilename, ...
                          'destDir',   V.destDir,   ...
                          'vecdata',   V.vecdata,   ...
                          'vfParams',  V.vfParams,  ...
                          'bpvecFmt',  V.bpvecFmt,  ...
				          'bufSize',   V.bufSize, ...
                          'trajBuf',   {V.trajBuf}, ...
                          'trajLabel', {V.trajLabel}, ...
                          'errorTol',  V.errorTol,  ...
                          'autoGen',   V.autoGen,   ...
                          'chkVerbose',V.verbose,  ...
                          'dataSz',    V.dataSz );
		end		%getOpts()

		function wfilename = getWfilename(V)
			wfilename = V.wfilename;
		end

		function rfilename = getRfilename(V)
			rfilename = V.rfilename;
		end

		function data = readParams(V, fname, ptype, varargin)
		% READPARAMS
		% Read parameter data (non-frame data) from disk.

			fp = fopen(fname, 'r');
			if(fp == -1)
				fprintf('ERROR (vecManager.readParams) Cant open file [%s]\n', fname);
				data = [];
				return;
			end

			if(strncmpi(ptype, 'moment', 6))
				MAX_ITER  = 16;
				NUM_ITERS = 16;

				for k = 1 : length(varargin)
					if(ischar(varargin{k}))
						if(strcmpi(varargin{k}, 'max', 3))
							MAX_ITER = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'num', 3))
							NUM_ITERS = varargin{k+1};
						end
					end
				end

				moments = cell(1,NUM_ITERS);

				niters = 1;
				while(niters < MAX_ITER)
					mvec = fscanf(fp, '%u ', 6);
					moments{niters} = mvec;
					% Check if there is another line of data
					c = fscanf(fp, '%c', 1);
					if(strncmpi(c, '\n', 1))
						niters = niters + 1;
					else
						break;
					end
				end
				data = struct('moments', {moments}, 'niters', niters);
			else
				% Read one line parameter data for this frame
				data = fscanf(fp, '%u', 5);
			end
			
		end 	%readParams()

		%---- Read vector data from disk ---- %
		function [vecdata varargout] = readVec(V, varargin)
		% READVEC
		% This method wraps the vecDiskRead() method to read sets of vector data
		% out of Verilog testbenches back from disk. This is done to prevent 
		% this class definition from becoming overly long.

			DSTR = '[vecManager.readVec()] : ';
			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'fname', 5))
							fname = varargin{k+1};
                        elseif(strncmpi(varargin{k}, 'vtype', 5))
                            vtype = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'dtype', 5))
							dtype = varargin{k+1};
							fprintf('(readVec) dtype set to [%s]\n', dtype);
						elseif(strncmpi(varargin{k}, 'dmode', 5))
							dmode = varargin{k+1};
							fprintf('(readVec) dmode set to [%s]\n', dmode);
						elseif(strncmpi(varargin{k}, 'delim', 5))
							delim = varargin{k+1};
							fprintf('(readVec) delim set to [%s]\n', delim);
						elseif(strncmpi(varargin{k}, 'sz', 2)) %no. elemn in vector
							sz    = varargin{k+1};
							fprintf('(readVec) size set to %d\n', sz);
						elseif(strncmpi(varargin{k}, 'offset', 6))
							of    = varargin{k+1};	%which file of the seq. to read
						end
					end
				end	
			end

			%Check what we have. For filename and vector sizer, if we don't know 
			%just use what we have in the vecManager buffer and hope that it works.
			if(~exist('fname', 'var'))
				fname = V.rfilename;
			end
			if(~exist('of', 'var'))
				of = 0;
			end
            if(~exist('vtype', 'var'))
                vtype = 'scalar';
            end
			if(~exist('sz', 'var'))
				if(exist('vtype', 'var') && strncmpi(vtype, 'scalar', 6))
					sz = 1;
				else
					sz = V.dataSz;
				end
			end
			if(~exist('dtype', 'var'))
				dtype = '%u8';
				fprintf('%s set dtype to [%s]\n', DSTR, dtype);
			end
			if(~exist('dmode', 'var'))
				dmode = 'dec';
			end
			if(~exist('delim', 'var'))
				delim = ' ';
			end
			% TODO : Format an options strcuture for vecDiskRead
			vopts = struct('dtype', dtype, ...
				           'dmode', dmode, ...
				           'delim', delim);

			%if(sz == 1)
            if(strncmpi(vtype, 'scalar', 6))
				[vecdata{1} ref] = vecDiskRead(V, fname, vopts);
				if(ref == -1)
					fprintf('%s error in file [%s]\n', DSTR, fname);
					if(nargout > 1)
						varargout{1} = -1;
					end
					return;
				end
                if(nargout > 1)
                    varargout{1} = 0;
                end
                return;
            end

			% Allocate memory and read files in sequence
			vecdata = cell(1, sz);
			% Parse filename
			ps = fname_parse(fname, 'veconly');
			if(ps.exitflag)
				fprintf('%s unable to parse filename [%s], exiting...\n', DSTR, fname);
				vecdata = [];
				if(nargout > 1)
					varargout{1} = -1;
				end
				return;
			end

			wb = waitbar(0, sprintf('Reading vector (0/%d)', length(vecdata)), 'Name', 'Reading vector data...');

			for n = 1 : length(vecdata)
				fn = sprintf('%s%s-vec%03d.%s', ps.path, ps.filename, n, ps.ext);
				[vecdata{n} ref] = vecDiskRead(V, fn, vopts);
				if(ref == -1)
					fprintf('%s error in vector stream %d\n', DSTR, n);
					delete(wb);
					if(nargout > 1)
						varargout{1} = -1;
					end
					return;
				end
				waitbar(n/length(vecdata), wb, sprintf('Reading vector (%d/%d)', n, length(vecdata)));
			end
			delete(wb);

			% If we get to here status is fine
			if(nargout > 1)
				varargout{1} = 0;
			end

		end 	%readVec()
	
		% -------- TRAJECTORY BUFFER -------- %
		
		% ---- Get size of trajectory buffer ---- %
		function sz = getTrajBufSize(V)
			sz = length(V.trajBuf);
		end 	

		% ---- Read data out of trajectory buffer at index idx ---- %
		function data = readTrajBuf(V, idx)
		% READTRAJBUF
		% Read data out of trajectory buffer from index idx. idx can be a scalar to
		% address a single index, a vector to address particular indicies, or a range
		% to address between [rl rh]. Passing the string 'all' as idx causes the 
		% entire cell array to be returned
		%
		
			if(strncmpi(idx, 'all', 3))
				data = V.trajBuf;
			elseif(isscalar(idx))
				if(idx < 1 || idx > length(V.trajBuf))
					fprintf('ERROR: idx (%d) out of bounds, must be [1 - %d]\n', idx, length(V.trajBuf));
					data = [];
					return;
				end
				data = V.trajBuf{idx};
			else
				if(length(idx) > 2)
					data = cell(1, length(idx));
					for k = 1:length(idx)
						data{k} = V.trajBuf{idx(k)};
					end
				else
					data = cell(1, length(idx(1):idx(2)));
					n    = 1;
					for k = idx(1):idx(2)
						data{n} = V.trajBuf{k};
						n = n +1;
					end
				end
			end

		end 	%readTrajBuf()

		% ---- Read labels out of trajectory buffer ---- %
		function label = getTrajBufLabel(V, idx)
		% READTRAJBUFLABEL
		% Read label out of label buffer from index idx. idx can be a scalar to
		% address a single index, a vector to address particular indicies, or a range
		% to address between [rl rh]. Passing the string 'all' as idx causes the 
		% entire cell array to be returned
		
			if(strncmpi(idx, 'all', 3))
				label = V.trajLabel;
			elseif(isscalar(idx))
				if(idx < 1 || idx > length(V.trajLabel))
					fprintf('ERROR: idx (%d) out of bounds, must be [1 - %d]\n', idx, length(V.trajLabel))
					label = [];
					return;
				end
				label = V.trajLabel{idx};
			else
				if(length(idx) > 2)
					label = cell(1, length(idx));
					for k = 1:length(idx)
						label{k} = V.trajLabel{idx(k)};
					end
				else
					label = cell(1, length(idx(1):idx(2)));
					n     = 1;
					for k = idx(1):idx(2)
						label{n} = V.trajBuf{k};
					end
				end
			end
	
		end 	%readTrajLabel()

		function auto = checkAutoGen(V)
			auto = V.autoGen;
		end

		% ---- SETTER METHODS ----%

		% ---- setVerbose ------- %
		function Vout = setVerbose(V, verbose)
			V.verbose = verbose;
			Vout      = V;
		end 	%setVerbose()
			
		% ---- setRLoc : SET READ LOCATION
		function VM = setRLoc(V, rloc)
			if(~ischar(rloc))
				error('Read location must be path to file (string)');
			end
			V.rfilename = rloc;
			VM = V;
		end 	%setRLoc()

		% ---- setWLoc() : SET WRITE LOCATION
		function VM = setWLoc(V, wloc)
			if(~ischar(wloc))
				error('Write location must be path to file (string)');
			end
			V.wfilename = wloc;
			VM = V;
		end 	%setWLoc()

		% ---- setDestDir() ; SET DESTINATION DIRECTORY
		function VM = setDestDir(V, dir)
			if(~ischar(dir))
				error('Destination Directory must be path to file (string)');
			end
			V.destDir = dir;
			VM = V;
		end 	%setDestDir()

		% ---- METHODS FOR TRAJECTORY BUFFER ---- %
		function Vout = setTrajBufSize(V, N, varargin)
		% SETTRAJBUFSIZE
		% Set the size of the trajectory buffer (how many trajectory slots are
		% available). Pass the string 'keep' to try and keep the buffer contents.
		% If the new buffer size is smaller than the old buffer, keep will attempt
		% to save as many elements as possible, discarding elements that spill over 
		% the buffer end.
		
			if(N < 1)
				fprintf('Size must be positive integer\n');
				Vout = V;
				return;
			end

			if(~isempty(varargin))
				if(strncmpi(varargin{1}, 'keep', 4))
					%Try and keep the old buffer contents
					temp = cell(2, length(V.trajBuf));
					for k = 1:length(V.trajBuf)
						temp{1,k} = V.trajBuf{k};
						temp{2,k} = V.trajLabel{k};
					end
					V.trajBuf   = cell(1,N);
					V.trajLabel = cell(1,N);
					if(N < length(temp))
						fprintf('WARNING: New buffer is smaller than old, some contents will not be retained\n');
					end
					for k = 1:N
						V.trajBuf{k}   = temp{1,k};
						V.trajLabel{k} = temp{2,k};
					end
				end
			else
				V.trajBuf   = cell(1,N);
				V.trajLabel = cell(1,N);
			end
			Vout = V;
		end 	%setTrajBufSize()

		% ---- Write new data into trajectory buffer ---- %
		function Vout = writeTrajBuf(V, idx, data, varargin)
		% WRITETRAJBUF
		% Write a new array into the trajectory buffer at index idx
			if(idx < 1 || idx > length(V.trajBuf))
				fprintf('ERROR: idx (%d) out of bounds, must be [1 - %d]\n', idx, length(V.trajBuf));
				Vout = V;
				return;
			end

			V.trajBuf{idx} = data;
			Vout = V;

		end 	%writeTrajBuf()

		% ---- Write only the label to the trajLabel buffer ---- %
		function Vout = writeTrajBufLabel(V, idx, label)
		% WRITETRAJBUFLABEL
		% Write just the label without the data
			if(idx < 1 || idx > length(V.trajLabel))
				fprintf('ERROR: idx (%d) out of bounds, must be [1 - %d]\n', idx, length(V.trajLabel));
				Vout = V;
				return;
			end
			if(~ischar(label))
				fprintf('ERROR: Label must be string\n');
				Vout = V;
				return;
			end
			V.trajLabel{idx} = label;
            Vout = V;
			
		end 	%writeTrajBufLabel()
	
		function Vout = clearTrajBuf(V, idx)
		% CLEARTRAJBUF
		% Clear the trajectory buffer contents at index idx. idx can be either a 
		% scalar to delete a single element, a vector to delete multiple elements,
		% or a range to delete all elements between [rl rh]. Pass the string 'all'
		% as the argument to idx to clear all elements of the buffer. Cleared 
		% elements of the buffer are set to the empty string. The corresponding 
		% label is also cleared

			if(strncmpi(idx, 'all', 3))	
				for k = 1:length(V.trajBuf)
					V.trajBuf{k}   = [];
					V.trajLabel{k} = [];
				end
			elseif(isscalar(idx))
				if(idx < 1 || idx > length(V.trajBuf))
					fprintf('ERROR: idx (%d) out of range, must be [1 - %d]\n', idx, length(V.trajBuf))
					Vout = V;
					return;
				end
				V.trajBuf{idx}   = [];
				V.trajLabel{idx} = [];
			else
				if(length(idx) > 2)
					for k = 1:length(idx)
						V.trajBuf{idx(k)}   = [];
						V.trajLabel{idx(k)} = [];		
					end
				else
					for k = idx(1):idx(2)
						V.trajBuf{k}   = [];
						V.trajLabel{k} = [];
					end
				end
			end
			Vout = V;

		end 	%clearTrajBuf()
			
		% ---- PROCESSING METHODS ---- %
		% These methods provide one level of indirection to the methods in files.
		% Each file method operates on a single file handle at a time, and so the
		% responsibility to stripe out the file handles is placed with the methods
		% here 

		function [ftype val] = parseFmt(V, fmt) %#ok<INUSL>
		% PARSEFMT
		% [ftype val] = parseFmt(fmt)
		%
		% Parse a formatting code for vector generation
		% Formatting codes are of the form :
		%
		% '16c', '8c', '4c' for column vectors
		% '16r', '8r', '4r' for row vectors
		%
		%  For scalar data, enter an empty or invalid formatting code
			switch(fmt)
				case '16c'
					ftype = 'col';
					val  = 16;
				case '8c'
					ftype = 'col';
					val  = 8;
				case '4c'
					ftype = 'col';
					val = 4;
				case '2c'
					ftype = 'col';
					val  = 2;
				case '16r'
					ftype = 'row';
					val  = 16;
				case '8r'
					ftype = 'row';
					val  = 8;
				case '4r'
					ftype = 'row';
					val  = 4;
				case '2r'
					ftype = 'row';
					val = 2;
				otherwise
					ftype = 'scalar';
					val  = 0;	
			end

		end 	%parseFmt()

		% ---- Reassemble a vector into an image
		function img = formatVecImg(V, vec, varargin)
		% FORMATVECIMG
		% img = formatVecImg(V, vec, [..OPTIONS..])
		%
		% This method is a wrapper for assemVec. 
		%
		% ARGUMENTS:
		% V - vecManager object
		% vec - vector to assemble
		%
		% OPTIONAL ARGUMENTS
		% imsz - Size to generate output image for (default: 640x480)
		% vecfmt - Orientation format of vector, (default: scalar)
		% vecsz  - Size of vector (default: array size)
		%
		% see also assemVec, parseFmt

		% TODO : Re-write this method to be simpler	
			SCALE = false;	
			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'imsz', 4))
							imSz = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'vecfmt', 6))
							vecFmt = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'vecsz', 5))
							vecSz = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'datasz', 6) || ...
							   strncmpi(varargin{k}, 'sz', 2))
							DATASZ = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'scale', 5))
							SCALE = true;
						end
					end
				end
			end

			if(~exist('imSz', 'var'))
				imSz = [640 480];
				if(V.verbose)
					fprintf('imSz : [%d x %d]\n', imSz(1), imSz(2));
				end
			end
			if(~exist('vecFmt', 'var'))
				vecFmt = 'scalar';
				if(V.verbose)
					fprintf('vecFmt : %s\n', vecFmt);
				end
			end
			if(~exist('vecSz', 'var'))
				vecSz = length(vec);
				if(V.verbose)
					fprintf('vecSz : %d\n', vecSz);
				end
			end
			if(~exist('DATASZ', 'var'))
				DATASZ = 256;
				if(V.verbose)
					fprintf('DATASZ : %d\n', DATASZ);
				end
			end

			% TODO : Re-factor assemVec() to take options structure or similar
			%If variables not assigned, have assemVec() use internal defaults
			if(exist('imSz', 'var') && exist('vecFmt', 'var') && exist('vecSz', 'var'))
				img = assemVec(V, vec, 'imsz', imSz, 'vecfmt', vecFmt, 'vecsz', vecSz);
			else
				img = assemVec(V, vec);
			end

			if(SCALE)
				fprintf('Scaling by %d...\n', DATASZ);
				img = img.*DATASZ;
			end	

		end 	%formatVecImg()



		function [status varargout] = writeImgVec(V, img, opts, vecType)
		% WRITEIMGVEC
		% status = writeImgVec(V, img, opts)
		%
		% Generic function for writing test vectors to disk
		% 
		% ARGUMENTS
		%
		% V    - vecManager object
		% img  - Image data to generate vector from.
		% opts - Structure containing vector generation options. The opts structure
		%        contains the following fields
		%
		%        vtype  : orientation of vector, one of 'row', 'col' or 'scalar'
		%        val    : size of vector
		%        scale  : scaling factor for image data
		%        fname  : filename to write to disk
		%
		% vecType - Output type of vecto. Can be one of
		%
		%        'rgb'  : Generate RGB vectors (3 components)
		%        'hsv'  : Generate HSV vectors (3 components)
		%        'hue'  : Generate hue vector split into [val] files
		%        'bp'   : Generate backprojection vector split into [val] files
		%
		% OUTPUTS
		% status - Returns -1 if operation fails, 0 otherwise
		%

		% Stefan Wong 2013

			if(~ischar(vecType))
				fprintf('ERROR (writeImgVec) : vecType must be string\n');
				status = -1;
				return;
			end

			% TODO : Get rid of these checks
			% Do sanity check on options
			if(~isfield(opts, 'vtype') || isempty(opts.vtype))
				opts.vtype = 'scalar';
			end
			if(~isfield(opts, 'val') || isempty(opts.val))
				opts.val   = 0;
			end	
			if(~isfield(opts, 'scale') || isempty(opts.scale))
				opts.scale = 256;
			end
			% This check might be excessive
			if(~isfield(opts, 'fname') || isempty(opts.fname))
				opts.fname = 'genvec.dat';
			end
			if(~isfield(opts, 'vsim'))
				opts.vsim = false;
			end
			% TODO : Add vsim option to GUI and update structures as required

			% Generate correct vector for this type
			switch vecType
				% ==== RGB ==== %
				case 'rgb'
					vec = genRGBVec(V, img, opts.vtype, opts.val);
					%vecname = sprintf('%s.dat', opts.fname);
					vecDiskWrite(V, vec, 'fname', {opts.fname}, 'vsim', opts.vsim);
				% ==== HSV === %
				case 'hsv'
					vec = genHueVec(V, img);
					vecname{1} = sprintf('%s-hue.dat', opts.fname);
					vecname{2} = sprintf('%s-sat.dat', opts.fname);
					vecname{3} = sprintf('%s-val.dat', opts.fname);
					vecDiskWrite(V, vec, 'fname', vecname, 'vsim', opts.vsim);
				% ==== HUE ==== %
				case 'hue'
					vec = genHueVec(V, img, opts.vtype, opts.val, 'scale', opts.scale);
					if(strncmpi(opts.vtype, 'scalar', 6))
						vecDiskWrite(V, {vec}, 'fname', {opts.fname}, 'vsim', opts.vsim);
					else
						for n = length(vec):-1:1
							vecnames{n} = sprintf('%s-vec%03d.dat', opts.fname, n);
						end
						vecDiskWrite(V, vec, 'fname', vecnames, 'vsim', opts.vsim);
					end
				% ==== BACKPROJECTION ==== %
				case 'bp'
					vec = genBPVec(V, img, opts.vtype, opts.val);
					if(strncmpi(opts.vtype, 'scalar', 6))
						vecDiskWrite(V, {vec}, 'fname', {opts.fname}, 'vsim', opts.vsim);
					else
						for n = length(vec):-1:1
							vecnames{n} = sprintf('%s-vec%03d.dat', opts.fname, n);
						end
						vecDiskWrite(V, vec, 'fname', vecnames, 'vsim', opts.vsim, '1b');
					end

				otherwise
					fprintf('ERROR: Not a supported vectype [%s]', vecType);
					status = -1;
					return;
			end

			status = 0;
			if(nargout > 1)
				varargout{1} = vec;
			end
			return;

		end 	%writeImgVec()


		% -------- WRITE TRACKING VECTOR -------- %
		% TODO : Make trajectory vector a parameter (which means that this 
		% function basically just commits the data to disk)
		function writeTrackingVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end

			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'file', 4))
							fname = varargin{k+1};
						end
					end
				end
			end

			if(length(fh) > 1)
				for k = 1:length(fh)
					data = get(fh(k), 'bpVec');
					vec  = genTrackingVec(V, data, k);
					if(exist('fname', 'var'))
						dest = sprintf('%s-frame%02d', fname, k);
					else
						dest = sprintf('%s-frame%02d', V.filename, k);
					end
					vecDiskWrite(V, vec, 'dest', dest);
				end
			else
				%data = get(fh, 'bpVec');
				vec = genTrackingVec(V, fh);
                vecDiskWrite(V, vec);
			end
		end 	%writeTrackingVec()

		% -------- Inject an error into the frame data -------- %
		function errFrame = injectError(V, frame, errType, errOpts)

			switch(errType)
				case 'noise'
					%injectNoise(V, imVec, offset, imsz);
				case 'offset'
					%injectOffset(V, imVec, offset, imsz)
				otherwise
					fprintf('Invalid errType [%s]\n', errType);
					errFrame = [];
					return
			end
		end 	%injectError()

	end 		%vecManager METHODS (Public)

	methods (Access = 'private')
		% Parse Format
		%[ftype val] = parseFmt(V,fmt);
		% ---- TEST VECTOR GENERATION ---- %
		% ---- genFrameVec() : GENERATE VECTOR FOR FRAME
		status           = vecDiskWrite(V, data, varargin);	%commit data to disk
		[vec varargout]  = vecDiskRead(V, fname, varargin);
		[moments niters] = parseMoment(V, fname, varargin);
		vec              = genTrackingVec(V, fh);
		[vec varargout]  = genBPVec(V ,fh, vtype, val);
        [vec varargout]  = genHueVec(V, fh, vtype, val, varargin);
        vec              = genHSVVec(V, fh, varargin);
		vec              = genRGBVec(V, fh, vtype, val, varargin);
		vec              = genBpImgData(V, bpImg, varargin);
		vec              = genBpVecData(V, bpVec, varargin);
		filenames        = genVecFilenames(V, fh, fname, fmt);
		% ----- TEST VECTOR VERIFICATION ---- %
		status           = verifyTrackingVec(V, fh, vec);
		%status           = verifyHSVVec(V, fh, vec);
		%status           = verifyBPVec(V, fh, vec, varargin);
		[stat varargout] = genErrVec(V, vectors, refvec, varargin);
		[stat varargout] = verifyVector(V, fh, vec, varargin);
		img              = assemVec(V, vectors, varargin);
		[s varargout]    = verifyHueVec(V, fh, vec, varargin);
		
	end 		%vecManager METHODS (Private)


end 		%classdef vecManager
