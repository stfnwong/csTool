classdef csPattern < handle
% CSPATTERN
%
% Pattern generation and verification class
%
% PROPERTIES
% verbose - Sets verbose mode
%
% METHODS
% genRowHistImg  - Generate a hue image for testing histogram in row
%                  oriented backprojection pipeline.
% genColHistImg  - Generate a hue image for testing histogram in column
%                  oriented backprojection pipeline.
% vMemePattern   - Verify pattern data for memory switching test
% readPatternVec - Read a memory pattern vector from disk

	properties
		verbose; %set verbose mode
	end

	methods (Access = 'public')
		% CONSTRUCTOR
		function P = csPattern(varargin)
			% TODO :  Once there are some properties, fill in this
			% constructor framework
			switch nargin
				case 0
					% Initialise
					P.verbose = false;
				case 1
					% Copy
					if(isa(varargin{1}, 'csPattern'))
						P = varargin{1};
					else
						if(strncmpi(varargin{1}, 'verbose', 7))
							P.verbose = true;
						else
							P.verbose = false;
						end
					end	
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

		% ========= GENERATE REFERENCE VECTOR ======== %
		function refVec = genRefVec(P, vecLen, mWord)

			refVec = zeros(1, vecLen);
			
			rw = 0;
			for n = 1 : length(refVec)
				refVec(n) = rw;
				rw = rw + 1;
				if(rw > mWord)
					rw = 0;
				end
			end

		end 	%genRefVec()

		% ========= VERIFY MEMORY PATTERN TEST========= %
		function [errVec varargout] = vMemPattern(P, refVec, pattrVec)
		% VMEMPATTERN
		% Verify memory pattern for FIFO switching test
		%
		% ARGUMENTS
		% P        - csPattern object
		% refVec   - Reference vector
		% pattrVec - Pattern vector
		%
		% OUTPUTS
		% errVec   - Error vector. 
	
			errVec = abs(refVec - pattrVec);

		end 	%vMemPattern()

		% ==== Read pattern data from disk ==== 
		function [patternVec] = readPatternVec(P, fname)
		% READPATTERNVEC
		% Read pattern vector from disk.
		%
		% ARGUMENTS
		% P     - csPattern object
		% fname - Filename for pattern data

			fp = fopen(fname, 'r');
			if(fp == -1)
				fprintf('ERROR: Cant open file [%s]\n', fname);
				patternVec = [];
				return;
			end

			% Read pattern vector data
			[patternVec N] = textscan(fp, '%u32', 'Delimiter', ' ');
			if(P.verbose)
				fprintf('Read %d data points from file [%s]\n', N, fname);
			end
			fclose(fp);
			patternVec = cell2mat(patternVec)';

		end 	%readPatternVec()


	end 	%methods (public)

end 	%csPattern



