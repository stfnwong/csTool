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
		STRICT_AXES_TEST;
	end
	
	%Axes handles for plotting
	%TODO: Test if using figure handles and extracting the children for
	%plotting is better than using the axes handles directly. This is to
	%address the mysterious self un-setting preview axes handle
	properties (SetAccess = 'private', GetAccess = 'public')
% 		figPreview;
% 		figBuffer;
% 		figHist;
		axPreview;
		axBuffer;
		axHist;
		verbose;	%Be verbose (print debug messages)
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
						if(ishandle(opts.axPreview))
							B.axPreview    = opts.axPreview;
						else
							fprintf('WARNING: Invalid handle in opts.axPreview\n');
							B.axPreview     = 0;
						end
						if(ishandle(opts.axBuffer))
							B.axBuffer      = opts.axBuffer;
						else
							fprintf('WARNING: Invalid handle in opts.axBuffer\n');
							B.axBuffer      = 0;
						end
						if(ishandle(opts.axHist))
							B.axHist        = opts.axHist;
						else
							fprintf('WARNING: Invalid handle in opts.axHist\n');
							B.axHist        = 0;
						end
					end
			end
		
		end 	%csFrameBroweser CONSTRUCTOR

		% ---- INTERFACE METHODS ---- %
		function plotFrame(B, fh)
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
            drawFramePlot(B, fh);
		end 	%plotFrame()
		
		function plotPreview(B, fh, varargin)
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
			if(nargin > 2)
				if(ischar(varargin{1}))
					if(strncmpi(varargin{1}, 'bpimg', 5))
						drawPrevPlot(B, fh, 1);
					end
				end
			else
				drawPrevPlot(B,fh);
			end
		end
		
		function plotHist(B, fh)
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
			drawHistPlot(B, fh);
		end
		
		% -- Methods for printing data in console
		function printTrackData(fh, varargin)
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle');
			end
			if(length(fh) > 1)
				%Print data for each frame handle in turn
			else
				winParams = get(fh, 'winParams');
				fprintf('xc    : %f\n', winParams(1));
				fprintf('yc    : %f\n', winParams(2));
				fprintf('theta : %f\n', winParams(3));
				fprintf('axmaj : %f\n', winParams(4));
				fprintf('axmin : %f\n', winParams(5));
			end
		end		%printTrackData()

		% ---- GETTER METHODS ---- %
		function wparams = getCurWparams(B)
			wparams = B.wparams;
		end 	%getCurWparams()

		function fstats = getCurFParams(B)
			fstats = B.frameParams;
		end 	%getCurFStats()
		
		% ---- SETTER METHODS ---- %
		% Set axes handles
		function Bout = setAxPreview(B, axPreview)
			if(~ishandle(axPreview))
				error('Invalid handle axPreview');
			end
			Bout = B;
			Bout.axPreview = axPreview;
		end		%setAxPreview()
		
		function Bout = setAxBuffer(B, axBuffer)
			if(~ishandle(axBuffer))
				error('Invalid handle axBuffer');
			end
			Bout = B;
			Bout.axBuffer = axBuffer;
		end
		
		function Bout = setAxHist(B, axHist)
			if(~ishandle(axHist))
				error('Invalid handle axHist');
			end
			Bout = B;
			Bout.axHist = axHist;
		end
		
		function setGaussPlot(B, gp)
			if(gp ~= 1 || gp ~= 0)
				error('Set value out of range');
			end
			B.GAUSS_PLOT = gp;
		end 	%setGaussPlot
		
% 		% ---- PRINT FRAME PARAMS ---- %
% 		function printParams(T, fh)
% 			%sanity check
% 			if(~isa(fh, 'csFrame'))
% 				error('Invalid frame handle');
% 			end
% 		end

        % ---- DISPLAY FUNCTION ---- %
        function disp(T)
            csFrameBrowser.fbrsDisplay(T);
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
