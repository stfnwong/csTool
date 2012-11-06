classdef csSegmenter
% CSSEGMENTER
%
% Segmentation object for camshift tracker. This object performs target segmentation
% using the method specified in S.method, where S is the segmenter object.

%TODO: Document properly

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'private')
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
	properties (Constant = 'true')
		HIST_BP = 1;
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
					

		end 	%csSegmenter CONSTRUCTOR

		% ---- GETTER METHODS ----- %
	
		% ---- disp(T) : DISPLAY METHOD
		function disp(T)
			tDisplay(T);
		end 	%disp()

		% --- getMhist() : GENERATE NEW MODEL HISTOGRAM
		function mhist = getMhist(T, img)

			if(isempty(T.imRegion))
				error('Empty region in T.imRegion');
			end
			%Get region limits
			xmin  = T.imRegion(1,1);
			xmax  = T.imRegion(1,2);
			ymin  = T.imRegion(2,1);
			ymax  = T.imRegion(2,2);
			%Generate histogram bins
			bin   = T.N_BINS.*(1:T.N_BINS);
			mhist = zeros(1,T.N_BINS);
			%Find histogram	
			for y = ymin : ymax
				for x = xmin : xmax
					idx = find(bins > img(y,x), 1, 'first');
					mhist(idx) = mhist(idx) + 1;
				end
			end
			%Normalise histogram
			mhist = mhist ./ max(max(mhist));
			if(T.FPGA_MODE)
				mhist = fix(T.DATA_SZ.*mhist);
			end
			%Set mhist data in segmenter object
			T.mhist = mhist;
			
		end 	%getMhist()

		% ---- INTERFACE METHODS ----- %
		function frameSegment(T, fh)

			%Sanitise input
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
			
			switch T.method
				case HIST_BP
					%Perform histogram backprojection	
				case PCA
					fprintf('Currently not implemented\n');
				otherwise
					error('Invalid segmentation method in T.method');
			end

		end 	%frameSegment()

		% ---- SETTER METHODS ----- %
		function setImRegion(T, imregion)
		% SETIMREGION
		%
		% Set a new image region to generate model histogram from
	
			%Perform sanity check in imregion	
			sz = size(imregion)
			if(sz(1) ~= 2 || sz(2) ~= 2)
				error('imregion must be 2x2 matrix');
			end
			T.imRegion = imregion;
			
		end 	%setImRegion()
		
		% ---- setDataSz() : SET WORD SIZE FOR FPGA MODE 
		function setDataSz(T, size)
		
			if(isdouble(size))
				error('Data size must be integer');
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
		tDisplay(T);
	end 		%csSegmenter METHODS (Static)


end 			%csSegmenter classdef
