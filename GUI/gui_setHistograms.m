function [status varargout] = gui_setHistograms(varargin)
% GUI_SETHISTOGRAMS
% Place data onto histogram axes 
%
% Since the histogram axes need to be updated for every segmented frame, and basically
% every time the transport panel is used, this function takes all of the operations
% needed to do that and puts them in this file so that csToolGUI.m doesn't get 
% overloaded with calls. Rather than update all axes whenever a relevant button is 
% pressed, this function requires the axes and frame handles, and histograms to be
% specified as name/value pairs.
%
% If the ihist or mhist variables have multiple rows, then each row is taken to be
% a histogram of a seperate channel. If the ihist or mhist variables are cell arrays,
% then each element of the cell array is taken to be a histogram of a seperate
% channel, and gui_setHistogram will plot each hist  on top of the other with different
% coloured markers. By default, the histograms will be plotted as R, G, and B in that
% order.
%
%
% ARGUMENTS:
% 'mhistAx', ah  - Handle to axes for model histogram
% 'ihistAx', ah  - Handle to axes for image histogram
% 'mhist', mhist - Model histogram data
% 'ihist', ihist - Image histogram data
% 'fpgaMode'     - Use naive histogram routine in $CSTOOL_DIR/util (default: use 
%                  MATLAB hist() function)

% Stefan Wong 2013

	%Set internal defaults
	FPGA_MODE = 0;
	DEBUG     = 0;
	DSTR      = 'DEBUG (gui_setHistogram) : ';

	%Parse args
	if(isempty(varargin))
		fprintf('ERROR: Not enough arguments in gui_setHistograms\n');
		status = -1;
		return;
	else
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'mhistAx', 7))
					mhistAx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'ihistAx', 7))
					ihistAx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'mhist', 5))
					mhist = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'ihist', 5))
					ihist = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fpgaMode', 8))
					FPGA_MODE = 1;
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = 1;
				end
			end
		end
	end

	%Check which arguments we have
	if(exist('mhistAx', 'var') && ~exist('mhist', 'var'))
		fprintf('ERROR: Specified mhistAx but no mhist\n');
		status = -1;
		return;
	end
	if(exist('ihistAx', 'var') && ~exist('ihist', 'var'))
		fprintf('ERROR: Specified ihistAx but no ihist\n');
		status = -1;
		return;
	end

	%Show debugging messages (if required)
	if(DEBUG)
		if(exist('mhistAx', 'var'))
			fprintf('%s got mhistAx %f\n', DSTR, mhistAx);
		end
		if(exist('ihistAx', 'var'))
			fprintf('%s got ihistAx %f\n', DSTR, ihistAx);
		end
		if(exist('mhist', 'var'))
			fprintf('%s got mhist (%d bins)\n', DSTR, length(mhist));
		end
		if(exist('ihist', 'var'))
			fprintf('%s got ihist (%d bins)\n', DSTR, length(ihist));
		end
	end

	%Generate model histogram output
	if(exist('mhistAx', 'var'))
		if(iscell(mhist))
			ih1 = stem(mhistAx, mhist{1}, 'Color', [1 0 0]);
			hold(mhistAx, 'on');
			if(length(mhist) > 1)
				ih2 = stem(mhistAx, mhist{2}, 'Color', [0 1 0]);
				if(length(mhist) > 2)
					ih3 = stem(mhistAx, mhist{3}, 'Color', [0 0 1]);
				end
			end
			hold(mhistAx, 'off');	
		else
			%Ensure histogram is row vector
			dims = size(mhist);
			if(dims(1) > 3 || dims(1) > dims(2))
				mhist = mhist';
				dims  = size(mhist);
			end
			ih1 = stem(mhistAx, mhist(1,:), 'Color', [1 0 0]);
			hold(mhistAx, 'on');
			if(dims(1) > 1)
				ih2 = stem(mhistAx, mhist(2,:), 'Color', [0 1 0]);
				if(dims(1) > 2)
					ih3 = stem(mhistAx, mhist(3,:), 'Color', [0 0 1]);
				end
			end
			hold(mhistAx, 'off');
		end
		if(nargout > 1)
		%Generate an array of stem handles with the same dimension as mhist
			switch(length(mhist))
				case 1
					varargout{1} = ih1;
				case 2
					varargout{1} = [ih1 ih2];
				case 3
					varargout{1} = [ih1 ih2 ih3];
			end
		end
	end	

	%Generate image histogram output
	if(exist('ihistAx', 'var'))
		if(iscell(ihist))
			ih1 = stem(ihistAx, ihist{1}, 'Color', [1 0 0]);
			hold(ihistAx, 'on');
			if(length(mhist) > 1)
				ih2 = stem(ihistAx, ihist{2}, 'Color', [0 1 0]);
				if(length(mhist) > 2)
					ih3 = stem(ihistAx, ihist{3}, 'Color', [0 0 1]);
				end
			end
			hold(ihistAx, 'off');
		else
			%Ensure histogram is row vector	
			dims = size(ihist);
			if(dims(1) > 3 || dims(1) > dims(2))
				ihist = ihist';
				dims  = size(ihist);
			end
			ih1  = stem(ihistAx, ihist(1,:), 'Color', [1 0 0]);
			hold(ihistAx, 'on');
			if(dims(1) > 1)
				ih2 = stem(ihistAx, ihist(2,:), 'Color', [0 1 0]);
				if(dims(1) > 2)
					ih3 = stem(ihistAx, ihist(3,:), 'Color', [0 0 1]);
				end
			end
			hold(ihistAx, 'off');
		end
		%Generate and array of handles with the same dimension as ihist
		if(nargout > 1)
			switch length(mhist)
				case 1
					varargout{1} = ih1;
				case 2
					varargout{1} = [ih1 ih2];
				case 3
					varargout{1} = [ih1 ih2 ih3];
			end
		end		
	end		
			
	%if(exist('ihistAx', 'var'))
	%	hist(ihistAx, ihist, length(ihist));
	%end
	status = 0;	


end 	%gui_setHistograms()
