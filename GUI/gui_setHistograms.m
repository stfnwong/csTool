function status = gui_setHistograms(varargin)
% GUI_SETHISTOGRAMS
% Place data onto histogram axes 
%
% Since the histogram axes need to be updated for every segmented frame, and basically
% every time the transport panel is used, this function takes all of the operations
% needed to do that and puts them in this file so that csToolGUI.m doesn't get 
% overloaded with calls. Rather than update all axes whenever a relevant button is 
% pressed, this function requires the axes and frame handles, and histograms to be
% specified as name/value pairs
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

	if(exist('mhistAx', 'var'))
		hist(mhistAx, mhist, length(mhist));
	end
	if(exist('ihistAx', 'var'))
		hist(ihistAx, ihist, length(ihist));
	end
	status = 0;	


end 	%gui_setHistograms()
