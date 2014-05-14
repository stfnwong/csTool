classdef csPattern < handle
% CSPATTERN
%
% Pattern generation and verification class

	properties

	end

	methods (Access = 'public')
		% CONSTRUCTOR
		function P = csPattern(varargin)
			% TODO :  Once there are some properties, fill in this
			% constructor framework
			switch nargin
				case 0
					% Initialise
				case 1
					% Copy
				otherwise
					error('Incorrect arguments to csPattern constructor');
			end
		end 	%csPattern()

		% ========= GENERATE HISTOGRAM TEST IMAGES ========= %
		function hImg = genRowHistImg(P, dims, nBins, bWidth)
		% GENROWHISTIMG
		% Generate row oriented histogram test image
		%
		% ARGUMENTS:
		% P      - csPattern class object
		% dims   - 1x2 vector of image dimensions [w h]
		% nBins  - Number of bins in histogram
		% bWidth - Width of bin in image histogram
		%
		% OUTPUTS:
		% hImg   - A dims(2) x dims(1) matrix containing hue pixels in
		%          test pattern order

			hImg  = zeros(dims(2), dims(1));
			ihist = zeros(1, nBins);

			for n = 1 : length(ihist)
				ihist(n) = (n-1)*bWidth;
			end
			
			% Generate waitbar
			t = dims(1) * dims(2);
			p = 1;
			wb = waitbar(0, sprintf('Generating row hue pattern (0/%d)', t), 'Name', 'Generating row hue pattern');

			hIdx = 1;
			% Generate row hue image
			for ypix = 1 : dims(2)
				for xpix = 1 : dims(1)
					hImg(ypix, xpix) = ihist(hIdx)+1;
					hIdx = hIdx + 1;
					if(hIdx > length(ihist))
						hIdx = 1;
					end
					% Update waitbar
					p = p + 1;
					waitbar(p/t, wb, sprintf('Generating row hue pattern (%d/%d)', p, t));
				end
			end

			delete(wb);

		end 	%genRowHistImg()

		function hImg = genColHistImg(P, dims, nBins, bWidth, vecSz)
		% GENCOLHISTIMAGE
		% Generate column-oriented histogram test image
		%
		% ARGUMENTS:
		% P      - csPattern class object
		% dims   - 1x2 vector of image dimensions [w h]
		% nBins  - Number of bins in histogram
		% bWidth - Width of bin in image histogram
		% vecSz  - Size of vector in pipeline. This must be a number
		%          divisible by dims(2) (height dimension) of image
		%
		% OUTPUTS:
		% hImg   - A dims(2) x dims(1) matrix containing hue pixels in
		%          test pattern order
	

			hImg  = zeros(dims(2), dims(1));
			ihist = zeros(1, nBins);
			
			for n = 1 : length(ihist)
				ihist(n) = (n-1)*bWidth;
			end

			% Need to check that the height is divisble by columns
			if(mod(dims(2), vecSz) ~= 0)
				fprintf('ERROR: vector size (%d) is not a multiple of image height (%d)\n', vecSz, dims(2));
				hImg = [];
				return;
			end

			cdim = dims(2) / vecSz;

			%Set up waitbar 
			t = cdim * dims(1);
			p = 1;
			wb = waitbar(0, sprintf('Generating column hue pattern (0/%d)', t), 'Name', 'Generating column hue pattern');

			% Generate column hue image
			hIdx = 1;
			for ypix = 1 : cdim
				for xpix = 1 : dims(1)
					hImg(((ypix-1)*vecSz+1:ypix*vecSz), xpix) = repmat(ihist(hIdx)+1, vecSz, 1);
					hIdx = hIdx + 1;
					if(hIdx > length(ihist))
						hIdx = 1;
					end
					% Update waitbar
					p = p + 1;
					waitbar(p/t, wb, sprintf('Generating column hue pattern (%d/%d)', p, t));
				end
			end

			delete(wb);
		end 	%genColHistImg()

		% ========= VERIFY MEMORY PATTERN TEST========= %
		function [errVec varargout] = vMemPattern(P, pattrVec, mWord, varargin)
		% VMEMPATTERN
		% Verify memory pattern for FIFO switching test
		%
		% This function verifies a pattern vector from a bank 
		% switched memory. Data values are written into the memory
		% starting at zero and incrementing to the size of the 
		% memory word. Comparing the input and output shows locations
		% where the pattern is dropped or interrupted, indicating a 
		% timing error. The reference pattern vector can be passed in
		% or generated automatically. Auto-generation is performed by
		% creating a new vector the same length as the pattern vector,
		% and looping a word over it wrapping at mWord;
		%
		% ARGUMENTS
		% P - csPattern object
		% pattrVec - Pattern vector read from RTL testbench. This should
		%            be a 1xN vector as long as the data stream
		% mWord    - Size of memory word used in test.
		%
		% OUTPUTS
		% errVec   - Error vector. 

			if(~isempty(varargin))
				refPattern = varargin{1};
			else
				refPattern = zeros(1, length(pattrVec));
				rw = 0;
				for n = 1 : length(refPattern)
					refPattern(n) = rw;
					rw = rw + 1;
					if(rw >= mWord)
						rw = 0;
					end
				end
			end

			errVec = abs(pattrVec - refPattern);
			if(nargout > 1)
				varargout{1} = refPattern;
			end

		end 	%vMemPattern()

	end 	%methods (public)

end 	%csPattern



