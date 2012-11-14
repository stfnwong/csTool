classdef csImProc
% CSIMPROC
%
% Image Processor class for camshift tracker. This object creates an image processor 
% which contains methods to segment and track a target through a series of frames

% Stefan Wong 2012

	properties (SetAccess = 'private', GetAccess = 'private')
		trackType;
		segType;
		%Internal objects
		iSegmenter;
		iTracker;
		verbose;
	end

	%String equivalents of tracking type enumeration
	properties (Constant = true)
		trackStr = {'Moment Accumulation', ...
			        'Kernel Density Estimation'};
		segStr   = {'Histogram Backprojection', ...
			        'Principal Component Analysis'};
	end
	
	methods 
		% ---- CONSTRUCTOR ---- %
		function P = csImProc(varargin)

			switch nargin
				case 0
					P.trackType  = 1;
					P.segType    = 1;
					P.iSegmenter = csSegmenter();
					P.iTracker   = csTracker();
					P.verbose    = 0;
				case 1
					%Object copy case
					if(isa(varargin{1}, 'csImProc'))
						P = varargin{1};
					%elseif(iscell(varargin{1}))
						%Options cell, send to parser
						%ipOpt = csImProc.optParser(varargin{1});
					else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts        = varargin{1};
						P.trackType = opts.trackType;
						P.segType   = opts.segType;
						P.verbose   = opts.verbose;
						%Check for segmenter options
						if(isa(opts.segOpts, 'struct'))
							if(opts.verbose)
								fprintf('Parsing segmenter options...\n');
							end
							P.iSegmenter = csSegmenter(opts.segOpts);
						else
							P.iSegmenter = csSegmenter();
						end
						%Check for tracker options
						if(isa(opts.trackOpts, 'struct'))
							if(opts.verbose)
								fprintf('Parsing tracker options...\n');
							end
							P.iTracker   = csTracker(opts.trackOpts);
						else
							P.iTracker   = csTracker();
						end
					end
				otherwise
					error('Incorrect number of arguments');
			end

		end 	%csImProc CONSTRUCTOR
		
		% ---- TRACKING AND SEGMENTING CALLS ---- %
		% These method wrap the corresponding function in either the
		% segmenter or tracker objects
		
		function Pout = initProc(P, varargin)
			%INITPROC
			%
			% Perform processing initialisations for csImProc object
			
			%Check arguments
			for k = 1:length(varargin)
				if(isa(varargin{k}, 'csFrame'))
					fh = varargin{k};
				elseif(ischar(varargin{k}))
					if(strncmpi(varargin{k}, 'imregion', 8))
						imregion = varargin{k+1};
					end
				end
			end
			
			if(~exist('fh', 'var'))
				error('No initial frame handle specified');
			end
			if(~exist('imregion', 'var'))
				error('No image region specified');
			end
			Pout = P;
			im = rgb2hsv(fh.img);
			im = fix(P.iSegmenter.getDataSz().*im(:,:,1));
			Pout.iSegmenter = P.iSegmenter.setImRegion(imregion);
			Pout.iSegmenter = P.iSegmenter.genMhist(im);
			return;
		end
		
		% ---- setFParams() : EXPOSE iTracker.fParams
		function Pout = setFParams(P, params)
			P.iTracker = P.iTracker.setPrevParams(params);
			Pout = P;
			%Pout = P.iTracker.setPrevParams(params);
		end
		
		function Pout = procFrame(P, fh)
			%FRAMEPROC
			%
			% Perform segmentation and tracking on a single frame
			
			%Sanity check inputs
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end
			Pout = P;
			Pout.iSegmenter.segFrame(fh);
			Pout.iTracker.trackFrame(fh);
			%DEBUG
			fprintf('fh.winParams{end}\n');
			disp(fh.winParams{end});
			Pout.iTracker = P.iTracker.setPrevParams(fh.winParams{end});
		end

		function P = setVerbose(P)
			P.verbose = 1;
		end
		
		function mhist = getCurMhist(P)
			mhist = P.iSegmenter.getMhist();
		end
		
		function params = getTrackerFParams(P)
			params = P.iTracker.fParams;
		end

		% ---- Display function ---- %
		function disp(P)
			csImProc.dispImProc(P);
		end
	end 		%csImProc METHODS (Public)
	
	% ---- METHODS IN FILES ---- %
	methods (Static)
		%Display function
		dispImProc(P);
		%Option parser
		ipOpt = optParser(options);
	end 		%csImProc METHODS (Static)


end 			%classdef csImProc
