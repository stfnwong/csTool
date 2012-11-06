classdef csFrameBrowser
% CSFRAMEBROWSER
%
% Frame browser object for camshift tracker. This object contains methods to visualise
% tracking data for each frame.

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'private')
		%Properties for currently displayed image
		filename;
		frameParams; %fParam struct
		wparams;
		%Internal plotting options
		PLOT_GAUSSIAN;
	end

	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function B = csFrameBrowser(varargin)
		% CSFRAMEBROWSER CONSTRUCTOR
		% B = csFrameBrowser() creates a new frame browser object

			switch nargin
				case 0:
					%Do default init
					filename   = ' ';
					frameStats = zeros(1,3);
					wparams    = zeros(1,5);
					return;
				case 1
					%Check object copy case
					if(isa(varargin{1}, 'csFrameBrowser'))
						B = varargin{1};
					end
			end
		
		end 	%csFrameBroweser CONSTRUCTOR

		% ---- INTERFACE METHODS ---- %
		function plotFrame(T, fh)
	
		end 	%plotFrame()

		% ---- GETTER METHODS ---- %
		function wparams = getCurWparams(T)
			wparams = T.wparams;
		end 	%getCurWparams()

		function fstats = getCurFStats(T)
			fstats = T.frameStats;
		end 	%getCurFStats()

		% ---- SETTER METHODS ---- %
		function setGaussPlot(T, gp)
			if(gp ~= 1 || gp ~= 0)
				error('Set value out of range');
			end
			T.GAUSS_PLOT = gp;
		end 	%setGaussPlot
		

	end 		%csFrameBrowser METHODS (Public)

	% ---- METHODS IN FILES ---- %
	methods (Access = 'private');
		% ---- genPlot() : Generate frame plot
		status = genPlot(T, fh);
	end 	%csFrameBrowser METHODS (Private)


end 		%classdef csFrameBrowser
