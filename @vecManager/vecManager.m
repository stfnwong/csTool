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

	properties (SetAcess = 'private', GetAccess = 'public')
		verbose;
	end

	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function V = vecManager(varargin)
			
			switch nargin
				case 0
					%Default init
				case 1
					if(isa(varargin{1}, vecManager))
						V = varargin{1};
					end
				otherwise
					error('Incorrect constructor arguments');
			end
		end 	%vecManager() CONSTRUCTOR

		% ---- GETTER METHODS ---- %
		function getVecFormat(V)
			%Display vector read/write formats
		end 	%getVecFormat()
	
		function readTestVec(V)
		
		end 	%readTestVec

		% ---- SETTER METHODS ----%
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
		
		function [type val] = parseFmt(V, fmt)
		% PARSEFMT
		% [type val] = parseFmt(fmt)
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
					type = 'col';
					val  = 16;
				case '8c'
					type = 'col';
					val  = 8;
				case '4c'
					type = 'col';
					val  = 4;
				case '16r'
					type = 'row';
					val  = 16;
				case '8r'
					type = 'row'
					val  = 8;
				case '4r'
					type = 'row
					val  = 4;
				otherwise
					type = 'scalar'
					val  = 0;	
			end
		end 	%parseFmt()

		function writeRGBVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh'n);
			end
			
			%Parse optional arguments
			if(nargin > 2)
				[opts.type opts.val] = parseFmt(V, varargin{1});
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end	
			
			if(length(fh) > 1)
				for k = 1:length(fh)
					opts.num = k;
					%Change the trailing number in the filename	
					vec = genRGBRaster(V, fh(k), opts);
				end	
			else
				vec = genRGBRaster(V, fh, opts);
			end
		end 	%writeRGBVec()

		function writeHSVVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end

			if(nargin > 2)
				[opts.type opts.val] = parseFmt(V, varargin{1});
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end
		
			if(length(fh) > 1)	
				for k = 1:length(fh)
					vec      = genHSVRaster(V, fh(k), opts);
					%write vector here
				end
			else
				vec = genHSVRaster(V, fh, opts)
			end
					
		end 	%writeHSVVec()

		function writeHueVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end
	
			if(nargin > 2)
				[opts.type opts.val] = parseFmt(V, varargin{1});
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end

			if(length(fh) > 1)
				for k = 1:length(fh)
					vec = genHueVec(V, fh(k), opts);
					vecDiskWrite(V, vec);
				end
			else
				vec = genHueVec(V, fh, opts);
			end
		end 	%writeHueVec()

		function writeBPVec(V, fh, varargin)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end
		
			if(nargin > 2)
				[opts.type opts.val] = parseFmt(V, varargin{1});
			else
				opts.type = 'scalar';
				opts.val  = 0;
			end	
			
			if(length(fh) > 1)
				for k = 1:length(fh)
					vec      = genBPVec(V, fh(k), opts);a
					%write vector here
				end
			else
				vec = genBPVec(V, fh, opts);
			end
		end 	%writeBPVec()

		function writeTrackingVec(V, fh)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end

			if(length(fh) > 1)
				for k = 1:length(fh)
					vec = genTrackingVec(V, fh(k), k);
					%write vector here
				end
			else
				vec = genTrackingVec(V, fh);
			end
		end 	%writeTrackingVec()

	end 		%vecManager METHODS (Public)

	methods (Access = 'private')
		% ---- TEST VECTOR GENERATION ---- %
		% ---- genFrameVec() : GENERATE VECTOR FOR FRAME
		       vecDiskWrite(V, data, varargin);			%commit data to disk
		fvec = genFrameVec(T, fh, gmode);
		data = genBPVec(V, fh, fmt, varargin);
		data = genBpImgData(V, bpImg, varargin);
		data = genBpVecData(V, bpVec, varargin);
		% ----- TEST VECTOR VERIFICATION ---- %
		status = verifyVec(T, vec);
	end 		%vecManager METHODS (Private)


end 		%classdef vecManager
