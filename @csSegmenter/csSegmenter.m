classdef csSegmenter < handle
% CSSEGMENTER
%
% Segmentation object for camshift tracker. This object performs target segmentation
% using the method specified in S.method, where S is the segmenter object.
%
% PROPERTIES:
%
% method    - Segmentation Method to use for the frame. Strings describing each method
%             are stored in the methodStr property. 
% mhist     - Model Histogram to use for segmentation
% imRegion  - Region of image to generate model histogram from (region containing 
%             target)
% N_BINS    - Number of bins to use in histogram (default: 16)
% DATA_SZ   - Size of hue data word (default: 256)
% BLK_SZ    - Size of block to use for block-based segmentation methods (default: 16)
% FPGA_MODE - Use FPGA specific modelling constructs (eg, fixed point arithmetic, 
%             iterative structures, etc). Slower, but often closer to verilog 
%             simulation
% verbose   - Be verbose
%
% METHODS
% For more detailed help about a specific method, type help 'methodname'
%
% csSegmenter - (constructor)  create a new csSegmenter object
% getMhist    - Return model histogram vector 
% getImRegion - Return region matrix
% getDataSz   - Return current data size
% genMhist    - Generate new mhist using internal imRegion matrix
% segFrame    - Segment the frame associated with frame handle fh
%

%TODO: Document properly

% Stefan Wong 2012

	properties (SetAccess = private, GetAccess = private)
		method;
		mhist;
		bghist;			%Used in the online discriminative feature mode
		imRegion;	
		%Histogram properties
		N_BINS;
		DATA_SZ;
		BLK_SZ;
		FPGA_MODE;
		BP_THRESH; %if bin value less than this value, zero out pixel
		mhistThresh;
		GEN_BP_VEC;
		BPIMG_BIT_DEPTH;
		rowLen;        % Length of a row in the row backprojection method
		XY_PREV;
		%Kernel Weighting parameters
		kBandwidth;		%Bandwidth of kernel in pixels
		kWeight;		% Whether or not to perform kernel weighting
		kQuant;			%Quantisation of bandwith LUT (in bits)
		kScale;			%Scaling factor for kernel profile
		KW_LUT;		%Kernel weighting lookup table
		%Parameters for online discriminative tracking
		BG_MODE;		% 0=normal, 1=online disriminative mode
		BG_WIN_SZ;		%How much to expand window by to encompass window
		WIN_REGION;
		% Parameters for prediction window
		predWin;
		%global settings
		mGenVec;			%Methods generate vectors
		verbose;
	end

	% Internal ENUM for method
	properties (Constant = true, GetAccess = 'public')
		HIST_BP_IMG           = 1;
		HIST_BP_BLOCK         = 2;
		HIST_BP_ROW           = 3;
		HIST_BP_BLOCK_SPATIAL = 4;
		HIST_BP_ROW_SPATIAL   = 5;
		%Method strings
		methodStr     = {'Pixel-Wise HBP', ...
                         'Block-Wise HBP', ...
                         'Row-Wise HBP', ...
			             'Block-Wise HBP (Spatially Weighted)', ...
			             'Row-Wise HBP (Spatially Weighted)'
                        };
		modeStr       = {'Normal mode', ...
                         'FPGA Mode (binary)', ...
                         'FPGA Mode (2-bit)', ...
                         'FPGA Mode (4-bit)'};
	end

	methods (Access = 'public');
		% ---- CONSTRUCTOR ---- %
		function S = csSegmenter(varargin)
		% CSSEGMENTER (Constructor)
		% Create a new csSegmenter object
		%
		% S = csSegmenter(...)
		%
		% ARGUMENTS:
		%
		% If no arguments are passed in, a csSegmenter is created with 
		% default initialisations. To customise on creation, pass an 
		% options structure
		% as the only argument to csSegmeter() with the following fields:
		%
		% 		opts = {
		%				S.DATA_SZ    = size of data word in FPGA
		%				S.BLK_SZ     = size of block for blockwise processing
		%				S.FPGA_MODE  = use FPGA specific modelling constructs
		%				S.GEN_BP_VEC = generate bpvec instead of bpimg
		%				S.N_BINS     = number of bins in histogram
		%				S.method     = segmentatation method
		%				S.mhist      = 1 x N_BINS array of model histogram values
		%				S.imRegion   = imregion matrix
		%				}
		%

			switch nargin
				case 0
					%Default histogram properties
					S.DATA_SZ         = 256;
					S.BLK_SZ          = 16;
					S.N_BINS          = 16;
					S.FPGA_MODE       = 0;
					S.BP_THRESH       = 0;
					S.mhistThresh    = 0;
					%S.GEN_BP_VEC = 0;
					%Default internals
					S.BPIMG_BIT_DEPTH = 1;
					S.rowLen          = 0;
					% Kernel weighting properties
					S.kBandwidth      = 1;
					S.kWeight         = 1;
					S.kQuant          = 1;
					S.kScale          = 1;
					S.KW_LUT          = zeros(1, S.kQuant);
					S.XY_PREV         = zeros(1,2);
					S.BG_MODE         = 0;
					S.BG_WIN_SZ       = 0;
					S.WIN_REGION      = [128 128];
					S.predWin         = zeros(1,4);
					S.method          = 1;
					S.mhist           = zeros(1, S.N_BINS);
					S.imRegion        = zeros(2,2);
                case 1
                    %Object copy case
                    if(isa(varargin{1}, 'csSegmenter'))
                        S = varargin{1};
                    %elseif(iscell(varargin{1}))
                    else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts              = varargin{1};
						S.DATA_SZ         = opts.dataSz;
						S.BLK_SZ          = opts.blkSz;
						S.FPGA_MODE       = opts.fpgaMode;
						S.BP_THRESH       = opts.bpThresh;
						S.mhistThresh     = opts.mhistThresh;
						%S.GEN_BP_VEC = opts.gen_bpvec;
						S.BPIMG_BIT_DEPTH = opts.bitDepth;
						S.rowLen          = opts.rowLen;
						% Kernel weighting parameters
						S.kBandwidth      = opts.kBandwidth;
						S.kWeight         = opts.kWeight;
						S.kQuant          = opts.kQuant;
						S.kScale          = opts.kScale;
						% Only copy LUT if it exists
						if(isfield(opts, 'kwLut'))
							S.KW_LUT      = opts.kwLut;
						end
						
						if(isfield(opts, 'xyPrev'))
							S.XY_PREV     = opts.xyPrev;
						end
						if(isfield(opts, 'predWin'))
							S.predWin     = opts.predWin;
						end
						S.BG_MODE         = opts.bgMode;
						S.BG_WIN_SZ       = opts.bgWinSize;
						S.WIN_REGION      = opts.winRegion; %TODO
						S.N_BINS          = opts.nBins;
						S.method          = opts.method;
						S.mhist           = opts.mhist;
						S.imRegion        = opts.imRegion;
                    end
                otherwise
                    error('Incorrect arguments to constructor');
			end
		end 	%csSegmenter CONSTRUCTOR

		% ======== SAVEOBJ METHOD ======== %
		function seg = saveobj(S)
			seg.DATA_SZ         = S.DATA_SZ;
			seg.BLK_SZ          = S.BLK_SZ;
			seg.FPGA_MODE       = S.FPGA_MODE;
			seg.BP_THRESH       = S.BP_THRESH;
			seg.mhistThresh    = S.mhistThresh;
			seg.BPIMG_BIT_DEPTH = S.BPIMG_BIT_DEPTH;
			seg.rowLen          = S.rowLen;
			seg.kBandwidth      = S.kBandwidth;
			seg.kWeight         = S.kWeight;
			seg.kQuant          = S.kQuant;
			seg.kScale          = S.kScale;
			seg.KW_LUT          = S.KW_LUT;
			seg.XY_PREV         = S.XY_PREV;
			seg.BG_MODE         = S.BG_MODE;
			seg.BG_WIN_SZ       = S.BG_WIN_SZ;
			seg.WIN_REGION      = S.WIN_REGION;
			seg.N_BINS          = S.N_BINS;
			seg.method          = S.method;
			seg.mhist           = S.mhist;
			seg.imRegion        = S.imRegion;
		end 	%savobj()

		function S = reload(S, seg)
			S.DATA_SZ           = seg.DATA_SZ;
			S.BLK_SZ            = seg.BLK_SZ;
			S.FPGA_MODE         = seg.FPGA_MODE;
			S.BP_THRESH         = seg.BP_THRESH;
			S.mhistThresh      = seg.mhistThresh;
			S.BPIMG_BIT_DEPTH   = seg.BPIMG_BIT_DEPTH;
			S.rowLen            = seg.rowLen;
			S.kBandwidth        = seg.kBandwidth;
			S.kWeight           = seg.kWeight;
			S.kQuant            = seg.kQuant;
			S.KW_LUT            = seg.KW_LUT;
			S.XY_PREV           = seg.XY_PREV;
			S.BG_MODE           = seg.BG_MODE;
			S.BG_WIN_SZ         = seg.BG_WIN_SZ;
			S.WIN_REGION        = seg.WIN_REGION;
			S.N_BINS            = seg.N_BINS;
			S.method            = seg.method;
			S.mhist             = seg.mhist;
			S.imRegion          = seg.imRegion;
		end 	%reload()

		% ---- GETTER METHODS ----- %
		function mhist = getMhist(S)
			mhist = S.mhist;
		end	
	
		function dataSz = getDataSz(S)
			dataSz = S.DATA_SZ;
		end

        function region = getImRegion(S)
            region = S.imRegion;
        end

		function verbose = getVerbose(S)
			verbose = S.verbose;
		end

		% TODO : Deprecate this?
		function bitDepth =  getBitDepth(S)
			bitDepth =  S.BPIMG_BIT_DEPTH;
		end

		function kBandwidth = getKBandwidth(S)
			kBandwidth = S.KERNEL_BANDWIDTH;
		end

		function xyPrev = getXYPrev(S)
			xyPrev = S.XY_PREV;
		end

		function kwLut = getKernelLUT(S)
			kwLut = S.KW_LUT;
		end

		% ---- disp(T) : DISPLAY METHOD
		function disp(S)
			csSegmenter.segDisplay(S);
		end 	%disp()

		% ---- getOpts() : GET A COMPLETE OPTIONS STRUCT (for csToolGUI)
		function opts = getOpts(S)
			opts = struct('dataSz'  ,   S.DATA_SZ,   ...
                          'blkSz'   ,   S.BLK_SZ,    ...
                          'nBins'   ,   S.N_BINS,    ...
                          'fpgaMode',   S.FPGA_MODE, ...
                          'bpThresh',   S.BP_THRESH, ...
				          'mhistThresh', S.mhistThresh, ...
						  'bitDepth',   S.BPIMG_BIT_DEPTH, ...
				          'rowLen',     S.rowLen, ...
						  'kBandwidth', S.kBandwidth, ...
						  'kWeight',    S.kWeight, ...
						  'kQuant',     S.kQuant, ...
						  'kScale',     S.kScale, ...
						  'kwLut',      S.KW_LUT, ...
						  'xyPrev',     S.XY_PREV, ...
                          'method'  ,   S.method,   ...
                          'mhist'   ,   S.mhist,    ...
                          'bgMode',     S.BG_MODE,  ...
                          'bgWinSize',  S.BG_WIN_SZ, ...
				          'winRegion',  S.WIN_REGION, ...
                          'imRegion',   S.imRegion, ...
                          'verbose' ,   S.verbose );
		end 	%getOpts()

		% --- genMhist() : GENERATE NEW MODEL HISTOGRAM
		function varargout = genMhist(S, img, imRegion, varargin)

			if(~isempty(varargin))
				if(strncmpi(varargin{1}, 'set', 3))
					hSet = true; 	%save histogram in S.mhist
				end
			else
				hSet = false; %dont save (and presumably return hist to caller)
			end

			if(isempty(imRegion))
				if(isempty(S.imRegion))
					fprintf('ERROR: No imRegion at call time or in object\n');
					return;
				else
					fprintf('No imregion parameter specified, using internal\n');
					imRegion = S.imRegion;
				end
			end
			%Get region limits
			xmin  = imRegion(1,1);
			xmax  = imRegion(1,2);
			ymin  = imRegion(2,1);
			ymax  = imRegion(2,2);
			%Generate histogram bins
			bins   = S.N_BINS.*(1:S.N_BINS);
			t_mhist = zeros(1,S.N_BINS);
			%Find histogram	
			for y = ymin : ymax
				for x = xmin : xmax
					idx = find(bins > img(y,x), 1, 'first');
					t_mhist(idx) = t_mhist(idx) + 1;
				end
			end
			%Normalise histogram
			t_mhist = t_mhist ./ max(max(t_mhist));
			if(S.FPGA_MODE)
				t_mhist = fix(S.DATA_SZ.*t_mhist);
			end
			%Set mhist data in segmenter object
			if(hSet)
				S.mhist = t_mhist;
			end
			if(nargout > 0)
				varargout{1} = t_mhist;
			end
			
		end 	%genMhist()

		% ---- INTERFACE METHODS ----- %
		function [bpvec bpsum rhist] = segFrame(S, img, varargin)
			% CSSEGMENTER.SEGFRAME
			% segFrame(S, fh, [..NORMALISE..])
			%
			% Segment the hue image img using the method specified in
			% S.method
			% Pass in the string 'norm' to normalise to range of DATA_SZ
			% parameter

			NORM = false;	
			if(~isempty(varargin))
				for k = 1:length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'norm', 4))
							NORM = true;
						elseif(strncmpi(varargin{k}, 'wparam', 6))
							wparam = varargin{k+1};
						end
					end
				end
			end

			if(NORM)
				img = img.* S.DATA_SZ;
			end

			switch S.method
				case S.HIST_BP_IMG
					[bpvec rhist] = hbp_img(S, img, S.mhist);
					if(S.BG_MODE)
						[bgvec bg_rhist] = hbp_img(S, img, S.bghist);
					end
				case S.HIST_BP_BLOCK
					[bpvec rhist] = hbp_block(S, img, S.mhist);
					if(S.BG_MODE)
						[bgvec bg_rhist] = hbp_block(S, img, S.bghist);
					end
				case S.HIST_BP_ROW
					[bpvec rhist] = hbp_row(S, img, S.mhist);
					if(S.BG_MODE)
						[bgvec bg_rhist] = hbp_row(S, img, S.bghist);
					end
				case S.HIST_BP_BLOCK_SPATIAL
					if(~exist('wparam', 'var'))
						wparam = zeros(1, 5);
					end
					[bpvec rhist] = hbp_block_spatial(S, img, S.mhist, wparam);
				case S.HIST_BP_ROW_SPATIAL
					if(~exist('wparam', 'var'))
						wparam = zeros(1, 5);
					end
					[bpvec rhist] = hbp_row_spatial(S, img, S.mhist, wparam);
				case S.PCA
					fprintf('Currently not implemented\n');
				otherwise
					error('Invalid segmentation method in S.method');
			end
			if(S.verbose)
				fprintf('Ratio hist for frame %s : ', get(fh, 'filename'))
				disp(rhist);
			end
       		%Write frame data
			%bpsum = sum(sum(bpvec)) / S.kQuant;
			bpsum = length(bpvec);
			if(S.verbose)
				fprintf('bpSum : %f\n', bpsum);
			end
		end 	%segFrame()

		% ---- SETTER METHODS ----- %
		function setImRegion(S, imregion)
		% SETIMREGION
		%
		% Set a new image region to generate model histogram from. The 
        % region should be specified in a 2x2 matrix of the form:
        %
        %        region = [xmin xmax ; ymin ymax] 
        %
	
			%Perform sanity check in imregion	
			sz = size(imregion);
			if(sz(1) ~= 2 || sz(2) ~= 2)
				error('imregion must be 2x2 matrix');
			end
			S.imRegion = imregion;
			
		end 	%setImRegion()
		
		% ---- setDataSz() : SET WORD SIZE FOR FPGA MODE 
		function setDataSz(S, size)
		
			if(isdouble(size))
				size = uint8(size);
			end
			S.DATA_SZ = size;
		end 	%setDataSize()

		% ---- setSegMethod() : SET SEGMENTATION METHOD 
        function setSegMethod(S, method)
            S.method = method;
        end     %setSegMethod();

		function setVerbose(S, verbose)
			S.verbose = verbose;
		end

		function setXYPrev(S, xyPrev)
			if(length(xyPrev) ~= 2)
				fprintf('ERROR: xyPrev must be 2 element vector\n');
				return;
			end
			S.XY_PREV = xyPrev;
		end 	%setXYPrev()

		% ---- Generate a new lookup table ---- %
		function genKernelLUT(S, varargin)
			% GENKERNELLUT
			% Pass in parameters as name/value pairs to override internal
			% values. If no values supplies, values in object used. If 
			% some arguments are supplied but not others, the internal 
			% object values are used for the unsupplied arguments

			if(~isempty(varargin))
				for k = 1 : length(varargin)
					if(ischar(varargin{k}))
						if(strncmpi(varargin{k}, 'scale', 5))
							scale = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'quant', 5))
							quant = varargin{k+1};
						elseif(strncmpi(varargin{k}, 'bw', 2))
							bw    = varargin{k+1};
						end
					end
				end

				% Check what we have
				if(~exist('scale', 'var'))
					scale = S.kScale;
				end
				if(~exist('quant', 'var'))
					quant = S.kQuant;
				end
				if(~exist('bw', 'var'))
					bw    = S.kBandwidth;
				end
				S.KW_LUT = gen_kernel_lut(S, scale, bw, quant);
			else
				S.KW_LUT = gen_kernel_lut(S, S.kScale, S.kBandwidth, S.kQuant);
			end

		end 	% genKernelLUT

		% ---- Lookup kernel weight in table --- %

	end 		%csSegmenter METHODS (Public)


	% ---- METHODS IN FILES ---- % 
	methods (Access = 'private')
		% ---- hbp_img()   : HISTOGRAM BACKPROJECTION OVER IMAGE
		[bpdata rhist] = hbp_img(S, img, mhist);
		% ---- hbp_block() : HISTOGRAM BACKPROJECTION PER BLOCK
		[bpdata rhist] = hbp_block(S, img, mhist);
		% ---- hbp_row()   : HISTOGRAM BACKPROJECTION PER ROW
		[bpdata rhist] = hbp_row(S, img, mhist);
		% ---- Spatially weighted block and row backprojection
		[bpdata rhist] = hbp_block_spatial(S, img, mhist, wparam);
		[bpdata rhist] = hbp_row_spatial(S, img, mhist, wparam);
		bpimg          = hbp(S, img, rhist, varargin);
		wpixel         = kernelLookup(S, pixel, varargin);
		klut           = gen_kernel_lut(S, scale, bw, quant, varargin);
	end 		%csSegmenter METHODS (Private)

	methods (Static)
		%Options parser
		sOpt = optParser(options);
		%display function
		segDisplay(S);
		
		function seg = loadobj(S)
			seg = csSegmeneter();
			seg = reload(seg, S);
		end 	%loadobj()
	end 		%csSegmenter METHODS (Static)


end 			%csSegmenter classdef
