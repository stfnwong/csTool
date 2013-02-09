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
							if(P.verbose)
								fprintf('csImProc.iSegmenter options:\n');
								disp(opts.segOpts);
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
							if(P.verbose)
								fprintf('csImProc.iTracker options:\n');
								disp(opts.trackOpts);
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
            setDefault = 0;
			for k = 1:length(varargin)
				if(isa(varargin{k}, 'csFrame'))
					fh = varargin{k};
				elseif(ischar(varargin{k}))
					if(strncmpi(varargin{k}, 'imregion', 8))
						imregion = varargin{k+1};
                    elseif(strncmpi(varargin{k}, 'setdef', 6))
                        setDefault = 1;
					elseif(strncmpi(varargin{k}, 'params', 6))
						params = varargin{k+1};
					end
				end
			end
			
			if(~exist('fh', 'var'))
				error('No initial frame handle specified');
			end
			if(~exist('imregion', 'var'))
				error('No image region specified');
			end

			if(P.verbose)
				fprintf('Reading image from %s...\n', get(fh, 'filename'));
			end
            im = imread(get(fh, 'filename'), 'TIFF');
            im = rgb2hsv(im);
			im = fix(P.iSegmenter.getDataSz().*im(:,:,1));
			P.iSegmenter.setImRegion(imregion);
			P.iSegmenter.genMhist(im);
            if(setDefault)
                xc     = fix((imregion(1,2) - imregion(1,1))/2);
                yc     = fix((imregion(2,2) - imregion(2,1))/2);
                theta  = 0;
                axmaj  = imregion(1,2) - imregion(1,1);
                axmin  = imregion(2,2) - imregion(2,1);
                wparam = [xc yc theta axmaj axmin];
                P.iTracker.setParams(wparam);
            else
				%Actually, this is a cumbersome construction... refactor?
				if(exist('params', 'var'))
					P.iTracker.setParams(params);
				else
					fprintf('WARNING: No params passed to initProc()\n');
				end
			end
			Pout = P;
			return;
		end
		
		% ---- setFParams() : EXPOSE iTracker.fParams
		function Pout = setFParams(P, params)
			P.iTracker.setParams(params);
			Pout = P;
			%Pout = P.iTracker.setPrevParams(params);
		end

        % ---- DEBUG: This function exists ONLY to test the 
        % ---- persistance of handle classes in the csImProc object
        % ---- and should NOT appear in the final code
        function Pout = procLoop(P, fh)

            %get an array of frame handles and store them in fh
            if(length(fh) < 2)
                error('No point in this test for single frame');
            end
            wb = waitbar(0, 'Processing frame data...');
            nFrames = length(fh);
            for n = 1:nFrames;
                %DEBUG
                fprintf('======== FRAME %d ========\n', n);
                fprintf('P.iTracker.fParams at start of frame\n');
                disp(P.iTracker.fParams);
                P.iSegmenter.segFrame(fh(n));
                P.iTracker.trackFrame(fh(n));
                %DEBUG
                fprintf('P.iTracker.fParams after trackFrame()\n');
                disp(P.iTracker.fParams);
                waitbar(n/nFrames, wb, sprintf('Processed frame %d/%d...', n, nFrames));
            end
            close(wb);
            Pout = P;
        end
		
        % ---- procFrame () : PROCESS A FRAME
		function Pout = procFrame(P, fh)
			%PROCFRAME
			%
			% Perform segmentation and tracking for the frame in fh. If fh
			% is vector of frame handles, procFrame automatically processes
			% each element of fh in a loop.
			
			%Sanity check inputs
			if(~isa(fh, 'csFrame'))
				error('Invalid frame handle fh');
			end
			if(length(fh) > 1)
				h = waitbar(0, sprintf('Processing frame (1/%d)...', length(fh)));
				for k = 1:length(fh)
					P.iSegmenter.segFrame(fh(k));
					P.iTracker.trackFrame(fh(k));
					waitbar(k/length(fh), h, sprintf('Processing frame (%d/%d)...', k, length(fh)));
				end
				delete(h);	%get rid of waitbar
			else
				P.iSegmenter.segFrame(fh);
				P.iTracker.trackFrame(fh);
			end
            Pout = P;
		end

		function Pout = setVerbose(P)
			P.verbose = 1;
            Pout = P;
		end
		
		% ---- GETTER METHODS ---- %

		function region = getImRegion(P)
			region = P.iSegmenter.getImRegion();
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
		spvec = buf_spEncode(bpimg, varargin);
		bpvec = buf_spDecode(spvec, varargin);
	end 		%csImProc METHODS (Static)


end 			%classdef csImProc
