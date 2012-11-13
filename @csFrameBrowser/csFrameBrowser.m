classdef csFrameBrowser
% CSFRAMEBROWSER
%
% Frame browser object for camshift tracker. This object contains methods to visualise
% tracking data for each frame.
%
% PROPERTIES:
% filename
% frameParams
% wparams
% PLOT_GAUSSIAN
% verbose
%
% The object also contains axes handles in which to place the various
% generated plots. The function of these is detailed below
% 
% axPreview - Axes into which preview image is placed. The preview image is
%             just the image pixels read from frameBuf(k).img
% axBuffer  - Axes into which fully detailed plot (including frame
%             parameters) is placed. This axes should correspond to the
%             largest window in a GUI implementation.
% axHist    - Axes into which histograms are plotted.
%
% METHODS:
%
%

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'private')
		%Properties for currently displayed image
		filename;       %Filename of current frame
		frameParams;    %fParam struct
		wparams;        %Window parameters for current frame
		%Internal plotting options
		PLOT_GAUSSIAN;
		verbose;
	end
	
	%Axes handles for plotting
	properties (SetAccess = 'private', GetAccess = 'public')
		axPreview;
		axBuffer;
		axHist;
	end

	methods (Access = 'public')
		% ---- CONSTRUCTOR ---- %
		function B = csFrameBrowser(varargin)
		% CSFRAMEBROWSER CONSTRUCTOR
		% B = csFrameBrowser() creates a new frame browser object

			switch nargin
				case 0
					%Do default init
					B.filename      = ' ';
					B.frameParams   = zeros(1,3);
					B.wparams       = zeros(1,5);
                    B.PLOT_GAUSSIAN = 0;
					B.verbose       = 0;
					%Default axes handles
					B.axPreview     = 0;
					B.axBuffer      = 0;
					B.axHist        = 0;
					return;
				case 1
					%Check object copy case
					if(isa(varargin{1}, 'csFrameBrowser'))
						B = varargin{1};
					else
						opts = varargin{1};
						if(~isa(opts, 'struct'))
							error('Expecting options structure');
						end
						B.PLOT_GAUSSIAN = opts.plotgaussian;
						B.verbose       = opts.verbose;
						B.filename      = ' ';
						B.frameParams   = zeros(1,3);
						B.wparams       = zeros(1,3);
						%Extract axes handles
						B.axPreview     = opts.axPreview;
						B.axBuffer      = opts.axBuffer;
						B.axHist        = opts.axHist;
					end
			end
		
		end 	%csFrameBroweser CONSTRUCTOR

		% ---- INTERFACE METHODS ---- %
		function plotFrame(T, fh)
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
            genFramePlot(T, fh);
		end 	%plotFrame()
		
		function plotPreview(T, fh, varargin)
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
			if(nargin > 2)
				if(ischar(varargin{1}))
					if(strncmpi(varargin{1}, 'bpimg', 5))
						genPrevPlot(T, fh, 'bpimg');
					end
				end
			else
				genPrevPlot(T,fh);
			end
		end
		
		function plotHist(T, fh)
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
			genHistPlot(T, fh);
		end

		% ---- GETTER METHODS ---- %
		function wparams = getCurWparams(T)
			wparams = T.wparams;
		end 	%getCurWparams()

		function fstats = getCurFParams(T)
			fstats = T.frameParams;
		end 	%getCurFStats()
		
		% ---- SETTER METHODS ---- %
		function setGaussPlot(T, gp)
			if(gp ~= 1 || gp ~= 0)
				error('Set value out of range');
			end
			T.GAUSS_PLOT = gp;
		end 	%setGaussPlot
		
		% ---- PRINT FRAME PARAMS ---- %
		function printParams(T, fh)
			%sanity check
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
		end

        % ---- DISPLAY FUNCTION ---- %
        function disp(T)
            csFrameBrower.fbrsDisplay(T);
        end
		

	end 		%csFrameBrowser METHODS (Public)

	% ---- METHODS IN FILES ---- %
	methods (Access = 'private');
		% ---- genFramePlot() : Generate frame plot
		genFramePlot(T, fh);
		% ---- genPrevPlot()  : Generate preview plot
		genPrevPlot(T,fh, varargin);
		% ---- genHistPlot()  : Generate histogram plot
		genHistPlot(T, fh);
	end 	%csFrameBrowser METHODS (Private)
	
	methods (Static)
		fbrsDisplay(T);
	end


end 		%classdef csFrameBrowser
