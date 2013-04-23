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
		imRegion;	
		%Histogram properties
		N_BINS;
		DATA_SZ;
		BLK_SZ;
		FPGA_MODE;
		GEN_BP_VEC;
		%global settings
		mGenVec;			%Methods generate vectors
		verbose;
	end

	% Internal ENUM for method
	properties (Constant = true, GetAccess = 'public')
		HIST_BP_IMG   = 1;
		HIST_BP_BLOCK = 2;
		HIST_BP_ROW   = 3;
		%Method strings
		methodStr     = {'Pixel-Wise HBP', ...
                         'Block-Wise HBP', ...
                         'Row-Wise HBP'
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
		% If no arguments are passed in, a csSegmenter is created with default 
		% initialisations. To customise on creation, pass an options structure
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
					S.DATA_SZ    = 256;
					S.BLK_SZ     = 16;
					S.N_BINS     = 16;
					S.FPGA_MODE  = 0;
					%S.GEN_BP_VEC = 0;
					%Default internals
					S.method     = 1;
					S.mhist      = zeros(1, S.N_BINS);
					S.imRegion   = zeros(2,2);
                case 1
                    %Object copy case
                    if(isa(varargin{1}, 'csSegmenter'))
                        S = varargin{1};
                    %elseif(iscell(varargin{1}))
                    else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts         = varargin{1};
						S.DATA_SZ    = opts.dataSz;
						S.BLK_SZ     = opts.blkSz;
						S.FPGA_MODE  = opts.fpgaMode;
						%S.GEN_BP_VEC = opts.gen_bpvec;
						S.N_BINS     = opts.nBins;
						S.method     = opts.method;
						S.mhist      = opts.mhist;
						S.imRegion   = opts.imRegion;
                    end
                otherwise
                    error('Incorrect arguments to constructor');
			end
		end 	%csSegmenter CONSTRUCTOR

		% ---- GETTER METHODS ----- %
		function mhist = getMhist(T)
			mhist = T.mhist;
		end	
	
		function dataSz = getDataSz(T)
			dataSz = T.DATA_SZ;
		end

        function region = getImRegion(T)
            region = T.imRegion;
        end

		function verbose = getVerbose(T)
			verbose = T.verbose;
		end
	
		% ---- disp(T) : DISPLAY METHOD
		function disp(T)
			csSegmenter.segDisplay(T);
		end 	%disp()

		% ---- getOpts() : GET A COMPLETE OPTIONS STRUCT (for csToolGUI)
		function opts = getOpts(S)
			opts = struct('dataSz'  , S.DATA_SZ,   ...
                          'blkSz'   , S.BLK_SZ,    ...
                          'nBins'   , S.N_BINS,    ...
                          'fpgaMode', S.FPGA_MODE, ...
                          'method'  , S.method,   ...
                          'mhist'   , S.mhist,    ...
                          'imRegion', S.imRegion, ...
                          'verbose' , S.verbose );
		end 	%getOpts()

		% --- genMhist() : GENERATE NEW MODEL HISTOGRAM
		function genMhist(T, img)

			if(isempty(T.imRegion))
				error('Empty region in T.imRegion');
			end
			%Get region limits
			xmin  = T.imRegion(1,1);
			xmax  = T.imRegion(1,2);
			ymin  = T.imRegion(2,1);
			ymax  = T.imRegion(2,2);
			%Generate histogram bins
			bins   = T.N_BINS.*(1:T.N_BINS);
			t_mhist = zeros(1,T.N_BINS);
			%Find histogram	
			for y = ymin : ymax
				for x = xmin : xmax
					idx = find(bins > img(y,x), 1, 'first');
					t_mhist(idx) = t_mhist(idx) + 1;
				end
			end
			%Normalise histogram
			t_mhist = t_mhist ./ max(max(t_mhist));
			if(T.FPGA_MODE)
				t_mhist = fix(T.DATA_SZ.*t_mhist);
			end
			%Set mhist data in segmenter object
			T.mhist = t_mhist;
			
		end 	%genMhist()

		% ---- INTERFACE METHODS ----- %
		function segFrame(T, fh)
			% CSSEGMENTER.SEGFRAME
			% segFrame(S, fh)
			%
			% Segment image specified in frame handle fh using the method specified in
			% S.method.
			%
			% In the current version, the image is read from disk from within this
			% method
			if(T.verbose)
				fprintf('Reading image from %s...\n', get(fh, 'filename'));
			end
            im = imread(get(fh, 'filename'), 'TIFF');
			im = rgb2hsv(im);
			im = fix(T.DATA_SZ .* im(:,:,1));
			%Check for dims property, and set if empty
			if(isempty(get(fh, 'dims')))
				sz   = size(im);
				dims = [sz(2) sz(1)];
				set(fh, 'dims', dims);
				if(T.verbose)
					fprintf('Set dims as [%dx%d]\n', dims(1), dims(2));
				end
			else
				dims = get(fh, 'dims');
				if(T.verbose)
					fprintf('Read dims as [%dx%d]\n', dims(1), dims(2));
				end
			end
			switch T.method
				case T.HIST_BP_IMG
					[bpvec rhist] = hbp_img(T, im, T.mhist);
				case T.HIST_BP_BLOCK
					[bpvec rhist] = hbp_block(T, im, T.mhist);
				case T.HIST_BP_ROW
					[bpvec rhist] = hbp_row(T, im, T.mhist);
				case T.PCA
					fprintf('Currently not implemented\n');
				otherwise
					error('Invalid segmentation method in T.method');
			end
			if(T.verbose)
				fprintf('Ratio hist for frame %s : ', get(fh, 'filename'))
				disp(rhist);
			end
       		%Write frame data
			bpsum = sum(sum(bpvec));
            set(fh, 'bpSum', bpsum);
            set(fh, 'bpVec', bpvec);
            set(fh, 'rhist', rhist);	
		end 	%frameSegment()

		% ---- SETTER METHODS ----- %
		function setImRegion(T, imregion)
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
			T.imRegion = imregion;
			
		end 	%setImRegion()
		
		% ---- setDataSz() : SET WORD SIZE FOR FPGA MODE 
		function setDataSz(T, size)
		
			if(isdouble(size))
				size = uint8(size);
			end
			T.DATA_SZ = size;
		end 	%setDataSize()

		% ---- setSegMethod() : SET SEGMENTATION METHOD 
        function setSegMethod(T, method)
            T.method = method;
        end     %setSegMethod();

		function setVerbose(T, verbose)
			T.verbose = verbose;
		end

	end 		%csSegmenter METHODS (Public)


	% ---- METHODS IN FILES ---- % 
	methods (Access = 'private')
		% ---- hbp_img()   : HISTOGRAM BACKPROJECTION OVER IMAGE
		[bpdata rhist] = hbp_img(T, img, mhist);
		% ---- hbp_block() : HISTOGRAM BACKPROJECTION PER BLOCK
		[bpdata rhist] = hbp_block(T, img, mhist);
		% ---- hbp_row()   : HISTOGRAM BACKPROJECTION PER ROW
		[bpdata rhist] = hbp_row(T, img, mhist);
	end 		%csSegmenter METHODS (Private)

	methods (Static)
		%Options parser
		sOpt = optParser(options);
		%display function
		segDisplay(T);
	end 		%csSegmenter METHODS (Static)


end 			%csSegmenter classdef
