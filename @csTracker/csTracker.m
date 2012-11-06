classdef csTracker 
% CSTRACKER
%
% Object tracker class for camshift tracker. This object performs target tracking 
% on the image data contained in the frame handle frHandle.

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'public')
		method;
		ROT_MATRIX;
		CORDIC_MODE;
		BP_THRESH;
	end

	% METHOD ENUM
	properties (Constant = 'true')
		MOMENT_WINACCUM = 1;
		MOMENT_IMGACCUM = 2;
		KERNEL_DENSITY  = 3;
	end

	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function T = csTracker(varargin)
		% CSTRACKER CONSTRUCTOR
		% Generate a new csTracker object

			switch nargin
				case 0
					%Default setup
					method      = 1;
					ROT_MATRIX  = 0;
					CORDIC_MODE = 0;
					BP_THRESH   = 0;
				case 1
					%Check object copy case
					if(isa(varargin{1}, 'csTracker'))
						T = varargin{1};
					else
						%Pass option structure to optParser
						ctOpt = csTracker.optParser(varargin{1});
					end
				otherwise
					error('Incorrect input arguments');
			end
		
		end 	%csTracker CONSTRUCTOR

		% ---- trackFrame() : PERFORM TRACKING ON FRAME
		function [moments wparam] = trackFrame(T, fh)
		% TRACKFRAME
		% Peform tracking computation on the frame handle contained in fh.

		%TODO: Use varagout for wparam?

			%Sanity check arguments
			if(~ishandle(fh) || ~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end

			switch T.method
				case MOMENT_WINACCUM
					[moments wparam] = winAccum(T, fh.bpimg);
				case MOMENT_IMGACCUM
					wparam           = [];
					moments          = imgAccum(T, fh.bpimg);
				case KERNEL_DENISTY
					fprintf('Not yet implemented\n');
				otherwise
					error('Invalid tracking type');
			end
		
		end 	%trackFrame()



	end 		%csTracker METHODS (Public)

	methods (Access = 'private')	
		% ---- imgAccum()   : WHOLE IMAGE MOMENT ACCUMULATION
		[moments]        = imgAccum(T, bpimg)
		% ---- winAccum()   : WINDOWED MOMENT ACCUMULATION
		[moments wparam] = winAccum(T, bpimg, varargin);
		% ---- wparamComp() : FIND WINDOW PARAMETERS FROM MOMENT SUMS
		wparam           = wparamComp(T, moments);
	end 		%csTracker METHODS (Private)

	methods (Static)
		% Option parser
		ctOpt = optParser(options)
	end 		%csTracker METHODS (Static)

end 			%classdef csTracker()
