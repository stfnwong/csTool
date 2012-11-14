classdef csSegmenter
% CSSEGMENTER
%
% Segmentation object for camshift tracker. This object performs target segmentation
% using the method specified in S.method, where S is the segmenter object.

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
		%global settings
		mGenVec;			%Methods generate vectors
		verbose;
	end

	% Internal ENUM for method
	properties (Constant = true)
		HIST_BP_IMG   = 1;
		HIST_BP_BLOCK = 2;
		HIST_BP_ROW   = 3;
	end

	methods (Access = 'public');
		% ---- CONSTRUCTOR ---- %
		function S = csSegmenter(varargin)

			switch nargin
				case 0
					%Default histogram properties
					S.DATA_SZ   = 256;
					S.BLK_SZ    = 16;
					S.N_BINS    = 16;
					S.FPGA_MODE = 0;
					%Default internals
					S.method    = 1;
					S.mhist     = zeros(1, S.N_BINS);
					S.imRegion  = zeros(2,2);
                case 1
                    %Object copy case
                    if(isa(varargin{1}, 'csSegmenter'))
                        S = varargin{1};
                    %elseif(iscell(varargin{1}))
                    else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts        = varargin{1};
						S.DATA_SZ   = opts.dataSz;
						S.BLK_SZ    = opts.blkSz;
						S.FPGA_MODE = opts.fpgaMode;
						S.N_BINS    = opts.nBins;
						S.method    = opts.method;
						S.mhist     = opts.mhist;
						S.imRegion  = opts.imRegion;
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
	
		% ---- disp(T) : DISPLAY METHOD
		function disp(T)
			csSegmenter.segDisplay(T);
		end 	%disp()

		% --- genMhist() : GENERATE NEW MODEL HISTOGRAM
		function Tout = genMhist(T, img)

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
			Tout       = T;
			Tout.mhist = t_mhist;
			return;
			
		end 	%genMhist()

		% ---- INTERFACE METHODS ----- %
		function segFrame(T, fh)
			% segFrame(T, fh)
			%
			% perform specified segmentation on frame with handle fh
			im = rgb2hsv(fh.img);
			im = fix(T.DATA_SZ .* im(:,:,1));
			switch T.method
				case T.HIST_BP_IMG
					[bpimg rhist] = hbp_img(T, im, T.mhist);
				case T.HIST_BP_BLOCK
					[bpimg rhist] = hbp_block(T, im, T.mhist);
				case T.HIST_BP_ROW
					[bpimg rhist] = hbp_row(T, im, T.mhist);
				case T.PCA
					fprintf('Currently not implemented\n');
				otherwise
					error('Invalid segmentation method in T.method');
			end
			%Write frame data
			bpsum = sum(sum(bpimg));
			fh.setBpSum(bpsum);
			fh.setBpImg(bpimg);
			fh.setRHist(rhist);

		end 	%frameSegment()

		% ---- SETTER METHODS ----- %
		function T = setImRegion(T, imregion)
		% SETIMREGION
		%
		% Set a new image region to generate model histogram from
	
			%Perform sanity check in imregion	
			sz = size(imregion);
			if(sz(1) ~= 2 || sz(2) ~= 2)
				error('imregion must be 2x2 matrix');
			end
			T.imRegion = imregion;
			
		end 	%setImRegion()
		
		% ---- setDataSz() : SET WORD SIZE FOR FPGA MODE 
		function T = setDataSz(T, size)
		
			if(isdouble(size))
				size = uint8(size);
			end
			T.DATA_SZ = size;
		end 	%setDataSize()

		% ---- setSegMethod() : SET SEGMENTATION METHOD 

	end 		%csSegmenter METHODS (Public)


	% ---- METHODS IN FILES ---- % 
	methods (Access = 'private')
		% ---- hbp_img()   : HISTOGRAM BACKPROJECTION OVER IMAGE
		[bpimg rhist] = hbp_img(T, img, mhist);
		% ---- hbp_block() : HISTOGRAM BACKPROJECTION PER BLOCK
		[bpimg rhist] = hbp_block(T, img, mhist);
		% ---- hbp_row()   : HISTOGRAM BACKPROJECTION PER ROW
		[bpimg rhist] = hbp_row(T, img, mhist);
	end 		%csSegmenter METHODS (Private)

	methods (Static)
		%Options parser
		sOpt = optParser(options);
		%display function
		segDisplay(T);
	end 		%csSegmenter METHODS (Static)


end 			%csSegmenter classdef
