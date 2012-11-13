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
		function I = csImProc(varargin)

			switch nargin
				case 0
					I.trackType  = 1;
					I.segType    = 1;
					I.iSegmenter = csSegmenter();
					I.iTracker   = csTracker();
					I.verbose    = 0;
				case 1
					%Object copy case
					if(isa(varargin{1}, 'csImProc'))
						I = varargin{1};
					%elseif(iscell(varargin{1}))
						%Options cell, send to parser
						%ipOpt = csImProc.optParser(varargin{1});
					else
						if(~isa(varargin{1}, 'struct'))
							error('Expecting options structure');
						end
						opts        = varargin{1};
						I.trackType = opts.trackType;
						I.segType   = opts.segType;
						I.verbose   = opts.verbose;
						%Check for segmenter options
						if(isa(opts.segOpts, 'struct'))
							if(opts.verbose)
								fprintf('Parsing segmenter options...\n');
							end
							I.iSegmenter = csSegmenter(opts.segOpts);
						else
							I.iSegmenter = csSegmenter();
						end
						%Check for tracker options
						if(isa(opts.trackOpts, 'struct'))
							if(opts.verbose)
								fprintf('Parsing tracker options...\n');
							end
							I.iTracker   = csTracker(opts.trackOpts);
						else
							I.iTracker   = csTracker();
						end
					end
				otherwise
					error('Incorrect number of arguments');
			end

		end 	%csImProc CONSTRUCTOR
		
		% ---- TRACKING AND SEGMENTING CALLS ---- %
		% These method wrap the corresponding function in either the
		% segmenter or tracker objects
		
		function T = initProc(T, varargin)
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
			im = rgb2hsv(fh.img);
			im = fix(T.iSegmenter.getDataSz().*im(:,:,1));
			T.iSegmenter = T.iSegmenter.setImRegion(imregion);
			T.iSegmenter = T.iSegmenter.genMhist(im);
			
		end
		
		function frameProc(T, fh)
			%FRAMEPROC
			%
			% Perform segmentation and tracking on a single frame
			
			%Sanity check inputs
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end
			T.iSegmenter.frameSegment(fh);
			T.iTracker.trackFrame(fh);
		end

		function T = setVerbose(T)
			T.verbose = 1;
		end
		
		function mhist = getCurMhist(T)
			mhist = T.iSegmenter.getMhist();
		end


		% ---- Display function ---- %
		function disp(I)
			csImProc.dispImProc(I);
		end
	end 		%csImProc METHODS (Public)
	
	% ---- METHODS IN FILES ---- %
	methods (Static)
		%Display function
		dispImProc(I);
		%Option parser
		ipOpt = optParser(options);
	end 		%csImProc METHODS (Static)


end 			%classdef csImProc
