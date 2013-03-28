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
                          'errorTol',  V.errorTol,  ...
                          'autoGen',   V.autoGen,   ...
                          'chkVerbose', V.verbose,  ...
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
		
		function [ftype val] = parseFmt(fmt)
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
					val  = 4;
				case '16r'
					ftype = 'row';
					val  = 16;
				case '8r'
					ftype = 'row';
					val  = 8;
				case '4r'
					ftype = 'row';
					val  = 4;
				otherwise
					ftype = 'scalar';
					val  = 0;	
			end
		end 	%parseFmt()

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
				[opts.type opts.val] = parseFmt(V, fmt);
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end	
			
			if(length(fh) > 1)
				for k = 1:length(fh)
					vec  = genRGBVec(V, fh(k), opts);
					if(exist('fname', 'var'))
						dest = sprintf('%s-frame%03d', fname, k);
					else
						dest = sprintf('%s-frame%02d', V.filename, k);
					end
					vecDiskWrite(V, vec, 'dest', dest);
				end	
			else
				vec = genRGBVec(V, fh, opts);
                vecDiskWrite(V, vec);
			end
		end 	%writeRGBVec()

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

			if(exist('fmt','var'))
				[opts.type opts.val] = parseFmt(V, fmt);
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end
		
			if(length(fh) > 1)	
				for k = 1:length(fh)
					vec  = genHSVVec(V, fh(k), opts);
					if(exist('fname', 'var'))
						dest = sprintf('%s-frame%03d', fname, k);
					else
						dest = sprintf('%s-frame%03d', V.filename, k);
					end
					vecDiskWrite(V, vec, 'dest', dest); 
				end
			else
				vec = genHSVVec(V, fh, opts);
                vecDiskWrite(V, vec);
			end
					
		end 	%writeHSVVec()

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
				[opts.type opts.val] = parseFmt(V, fmt);
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end

			if(length(fh) > 1)
				for k = 1:length(fh)
					data = get(fh, 'bpVec');
					vec  = genHueVec(V, data, opts);
					if(exist('fname', 'var')
						dest = sprintf('%s-frame%02d', fname, k);
					else
						dest = sprintf('%s-frame%02d', V.filename, k);
					end
					vecDiskWrite(V, vec, 'dest', dest);
				end
			else
				data = get(fh, 'bpVec'); 
				vec  = genHueVec(V, data, opts);
                vecDiskWrite(V, vec);
			end
		end 	%writeHueVec()

		function writeBPVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end

			if(~isempty(varargin))
				for k = 1:length(varargin))
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
				[opts.type opts.val] = parseFmt(V, fmt);
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end	
			
			if(length(fh) > 1)
				for k = 1:length(fh)
					data = vec2bpimg(get(fh(k), 'bpVec'));
					vec  = genBPVec(V, data, opts);
					if(exist('fname', 'var'))
						dest = sprintf('%s-frame%02d', fname, k);
					else
						dest = sprintf('%s-frame%02d', V.filename, k);
					end
					vecDiskWrite(V, vec, 'dest', dest);
				end
			else
				data = vec2bpimg(get(fh, 'bpVec'));
				vec = genBPVec(V, data, opts);
                vecDiskWrite(V, vec);
			end
		end 	%writeBPVec()

		function writeTrackingVec(V, fh)
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
		% ---- TEST VECTOR GENERATION ---- %
		% ---- genFrameVec() : GENERATE VECTOR FOR FRAME
		         vecDiskWrite(V, data, varargin);			%commit data to disk
		vec    = vecDiskRead(V, file, varargin);
		vec    = genTrackingVec(fh);
		vec    = genBPVec(fh, fmt, varargin);
        vec    = genHueVec(fh, opts);
        vec    = genHSVVec(fh, opts);
		vec    = genBpImgData(V, bpImg, varargin);
		vec    = genBpVecData(V, bpVec, varargin);
		% ----- TEST VECTOR VERIFICATION ---- %
		status = verifyTrackingVec(V, fh, vec);
		status = verifyHSVVec(V, fh, vec);
		status = verifyBPVec(V, fh, vec, varargin);
		
	end 		%vecManager METHODS (Private)


end 		%classdef vecManager
