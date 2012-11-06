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
		ipSegmenter;
		ipTracker;
	end

	methods (SetAccess = 'public')
		% ---- CONSTRUCTOR ---- %
		function ip = csImProc(varargin)

			switch nargin
				case 0
					trackType     = 1;
					segType       = 1;
					procSegmenter = csSegmenter();
					procTracker   = csTracker();
				case 1
					%Object copy case
					if(isa(varargin{1}, 'csImProc'))
						ip = varargin{1};
					elseif(iscell(varargin{1}))
						%Options cell, send to parser
						ipOpt = csImProc.optParser(varargin{1});
					else
						error('Incorrect constructor options');
					end
				otherwise
					error('Incorrect number of arguments');
			end

		end 	%csImProc CONSTRUCTOR
	end 		%csImProc METHODS (Public)

	% 

	methods (SetAccess = 'private')

	end 		%csImProc METHODS (Private)
	
	% ---- METHODS IN FILES ---- %
	methods (Static)
		%Option parser
		ipOpt = optParser(options);
	end 		%csImProc METHODS (Static)


end 			%classdef csImProc
