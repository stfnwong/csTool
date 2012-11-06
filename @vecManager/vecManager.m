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
		vecdata;
		vfParams;		%verification parameters structure
		% DATA PARAMETERS
		errorTol;		%integer error tolerance in data (ie: +/- errorTol)
		dataSz;			%size of data word in FPGA
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
		function getVecFormat(T)
			%Display vector read/write formats
		end 	%getVecFormat()
	
		function readTestVec(T)
		
		end 	%readTestVec

		% ---- SETTER METHODS ----%
		% ---- setRLoc : SET READ LOCATION
		function setRLoc(T, rloc)
			if(~ischar(rloc))
				error('Read location must be path to file (string)');
			end
			T.rfilename = rloc;
		end 	%setRLoc()

		% ---- setWLoc() : SET WRITE LOCATION
		function setWLoc(T, wloc)
			if(~ischar(wloc))
				error('Write location must be path to file (string)');
			end
			T.wfilename = wloc;
		end 	%setWLoc()

	end 		%vecManager METHODS (Public)

	methods (Access = 'private')
		% ---- TEST VECTOR GENERATION ---- %
		% ---- genFrameVec() : GENERATE VECTOR FOR FRAME
		fvec = genFrameVec(T, fh, gmode);
		% ---- ge
		
		% ----- TEST VECTOR VERIFICATION ---- %
		status = verifyVec(T, vec);
	end 		%vecManager METHODS (Private)


end 		%classdef vecManager
