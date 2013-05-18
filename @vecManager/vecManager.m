classdef vecManager
% VECMANAGER
%
% Manage test vectors for Verilog/VHDL testbenches.
%
% TODO: Document

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'private')
		wfilename;
		rfilename;
		destDir;
		vecdata;
		vfParams;		%verification parameters structure
		bpvecFmt;		%character code for backprojection vector format
		% TRAJECTORY PARAMETERS
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
					V.trajBuf   = cell(1,1);
					V.trajLabel = cell(1,1);
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
						V.trajBuf   = opts.trajBuf;
						V.trajLabel = opts.trajLabel;
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
                          'trajBuf',   V.trajBuf, ...
                          'trajLabel', V.trajLabel, ...
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
				if(strncmpi(varargin(1}, 'keep', 4)))
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
			if(~isempty(varargin))
				if(strncmpi(varargin{1}, 'label', 5))
					if(~ischar(varargin{2}))
						fprintf('Label must be string\n');
					else
						V.trajLabel{idx} = varargin{2};
					end
				end
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
			
		end 	%writeTrajBufLabel()
		% ---- Read data out of trajectory buffer at index idx ---- %
		function data = readTrajBuf(V, idx)
		% READTRAJBUF
		% Read data out of trajectory buffer from index idx
			if(idx < 1 || idx > length(V.trajBuf))
				fprintf('ERROR: idx (%d) out of bounds, must be [1 - %d]\n', idx, length(V.trajBuf));
				Vout = V;
				return;
			end
			data = V.trajBuf{idx};
		end 	%readTrajBuf()

		% ---- PROCESSING METHODS ---- %
		% These methods provide one level of indirection to the methods in files.
		% Each file method operates on a single file handle at a time, and so the
		% responsibility to stripe out the file handles is placed with the methods
		% here 

		%NOTES ON ARCHITECTURE
		% Or 'why does are there so many similar functions?'
		%
		% I have though about consolidating the various vector functions here in the
		% vecManager class into a single function that has all the common parsing and
		% vector looping components, with some kind of parser or options system that
		% selects the different vector types to write. However (at least for now) I've
		% decided to leave these seperate, even though large parts of them are similar
		% Before explaining why, let me just note that originally I wanted to have it
		% so that the actual vector formatting was in a seperate file, partly to keep
		% this class definition short, and partly so that the actual vector generation
		% didn't have to deal with striping vectors, parsing arguments, and so on. 
		% This implied that there should be one level of indireciton in the class 
		% definition, which strips out all the frame handles, and deals with any
		% options that are passed in, and then calls the 'dumb' vector generation 
		% method with those options, possibly in a loop.
		%
		% I've decided for the time being that it is actually cleaner to have multiple
		% similar methods because tracking vectors are actually a bit different to 
		% RGB/HSV/Hue vectors. It could be that there is a writeColourVec() method at
		% some point that takes a string argument that specifies the particular type
		% of vector to use (but not a tracking vector), which basically has to do
		% a switch before the loop unrolls the frame handle vector
		%
		% To some extent, this argument is undermined by the implementation of 
		% vecDiskWrite()
		
		function [ftype val] = parseFmt(V, fmt) %#ok
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

		% -------- WRITERGBVEC() ------- %
		function writeRGBVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end
			
			%Parse optional arguments
			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'fmt', 3))
							fmt = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'file', 4))
							fname = varargin{k+1};
						end
					end
				end
			end
			
			% Check what we have
			if(exist('fmt', 'var'))
				[opts.type opts.val] = parseFmt(V,fmt);
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end	
			
			if(length(fh) > 1)
				for k = 1:length(fh)
					vec  = genRGBVec(V, fh(k), opts);
					if(~exist('fname', 'var'))
						[ef str num] = fname_parse(get(fh(k), 'filename'), 'n'); %#ok
						fname = sprintf('%s%02d', str, num);
					end
					vecname = {sprintf('%s.dat', fname)};
					vecDiskWrite(V, vec, 'fname', vecname);
				end	
			else
				vec = genRGBVec(V, fh, opts);
				if(~exist('fname', 'var'))
					[ef str num] = fname_parse(get(fh, 'filename'), 'n'); %#ok
					fname = sprintf('%s%02d', str, num);
				end
				vecname{1} = sprintf('%s.dat', fname);
                vecDiskWrite(V, vec, 'fname', vecname);
			end
		end 	%writeRGBVec()

		% -------- WRITEHSVVEC() ------- %
		function writeHSVVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end

			%Parse optional arguments 
			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'fmt', 3))
							fmt = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'file', 4))
							fname = varargin{k+1};
						end
					end
				end
			end

			%if(exist('fmt','var'))
			%	[vtype val] = parseFmt(V,fmt);
			%else
			%	vtype = 'scalar';
			%	val   = 0;
			%end
		
			if(length(fh) > 1)	
				for k = 1:length(fh)
					vec  = genHSVVec(fh(k));
					if(~exist('fname', 'var'))
						[ef str num] = fname_parse(get(fh(k), 'filename'), 'n'); %#ok
						fname = sprintf('%s%02d', str, num);
					end
                    vecnames    = cell(1,3);
					vecnames{1} = sprintf('%s-hue-frame%02d.dat', fname, k);
					vecnames{2} = sprintf('%s-sat-frame%02d.dat', fname, k);
					vecnames{3} = sprintf('%s-val-frame%02d.dat', fname, k);
					vecDiskWrite(V, vec, 'fname', vecnames);
				end
			else
				vec = genHSVVec(fh);
				if(~exist('fname', 'var'))
					[ef str num] = fname_parse(get(fh, 'filename'), 'n'); %#ok
					fname = sprintf('%s%02d', str, num);
				end
                vecname    = cell(1,3); %NOTE: M-Lint didn't complain about this line
				vecname{1} = sprintf('%s-hue.dat', fname);
				vecname{2} = sprintf('%s-sat.dat', fname);
				vecname{3} = sprintf('%s-val.dat', fname);
                vecDiskWrite(V, vec, 'fname', vecname);
			end
					
		end 	%writeHSVVec()

		% -------- WRITEHUEVEC() ------- %
		function writeHueVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end

			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'fmt', 3))
							fmt = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'file', 4))
							fname = varargin{k+1};
						end
					end
				end
			end
	
			if(exist('fmt', 'var'))
				[vtype val] = parseFmt(V,fmt);
			else
				vtype = 'scalar';
				val   = 0;
			end

			if(length(fh) > 1)
				for k = 1:length(fh)
					%DEBUG: Test with 256 scale factor
					vec = genHueVec(fh(k), vtype, val, 'scale', 256);
					if(~exist('fname', 'var'))
						%Format a string based on filename of original frame
						[ef str num] = fname_parse(get(fh(k), 'filename'), 'n'); %#ok
						fname = sprintf('%s%02d', str, num);
					end
					for n = length(vec):-1:1
						vecnames{n} = sprintf('%s-vec%02.dat', fname, n);
					end
					vecDiskWrite(V, vec, 'fname', vecnames);
				end
			else
				%DEBUG: Test with 256 scale factor
				vec  = genHueVec(V, fh, vtype, val, 'scale', 256);
				if(~exist('fname', 'var'))
					%Format a string from original filename
					[ef str num] = fname_parse(get(fh, 'filename'), 'n');  %#ok
					fname = sprintf('%s%02d', str, num);
				end
				for n = length(vec):-1:1
					vecnames{n} = sprintf('%s-vec%02d.dat', fname, n);
				end
                vecDiskWrite(V, vec, 'fname', vecnames);
			end
		end 	%writeHueVec()
		
		% -------- WRITEBPVEC() ------- %
		function writeBPVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end

			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'fmt', 3))
							fmt = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'file', 4))
							fname = varargin{k+1};
						end
					end
				end
			end
		
			if(exist('fmt', 'var'))
				[vtype val] = parseFmt(V,fmt);
			else
				vtype = 'scalar';
				val   = 0;
			end	
			
			if(length(fh) > 1)
				for k = 1:length(fh)
					vec  = genBPVec(fh(k), vtype, val);
					if(~exist('fname', 'var'))
						[ef str num] = fname_parse(get(fh(k), 'filename')); %#ok
						fname = sprintf('%s%02d', str, num);
					end
					for n = length(vec):-1:1
						vecnames{n} = sprintf('%s-vec%02d.dat', fname, n);
					end					
					vecDiskWrite(V, vec, 'fname', vecnames);
				end
			else
				vec = genBPVec(fh, vtype, val);
				if(~exist('fname', 'var'))
					[ef str num] = fname_parse(get(fh, 'filename'), 'n'); %#ok
					fname = sprintf('%s%02d', str, num);
				end
				for n = length(vec):-1:1
					vecnames{n} = sprintf('%s-vec%02d.dat', fname, n);
				end
                vecDiskWrite(V, vec, 'fname', vecnames);
			end
		end 	%writeBPVec()

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

	end 		%vecManager METHODS (Public)

	methods (Access = 'private')
		% Parse Format
		%[ftype val] = parseFmt(V,fmt);
		% ---- TEST VECTOR GENERATION ---- %
		% ---- genFrameVec() : GENERATE VECTOR FOR FRAME
		         vecDiskWrite(V, data, varargin);			%commit data to disk
		vec    = vecDiskRead(V, file, varargin);
		vec    = genTrackingVec(fh);
		[vec varargout] = genBPVec(fh, vtype, val);
        [vec varargout] = genHueVec(fh, vtype, val, varargin);
        vec    = genHSVVec(fh, varargin);
		vec    = genRGBVec(fh, varargin);
		vec    = genBpImgData(V, bpImg, varargin);
		vec    = genBpVecData(V, bpVec, varargin);
		% ----- TEST VECTOR VERIFICATION ---- %
		status = verifyTrackingVec(V, fh, vec);
		status = verifyHSVVec(V, fh, vec);
		status = verifyBPVec(V, fh, vec, varargin);
		
	end 		%vecManager METHODS (Private)


end 		%classdef vecManager
