function [status nh varargout] = init_modelHist(handles, region, idx, varargin)
% INIT_MODELHIST
% This function abstracts the details of placing a new imRegion into a csSegmenter
% object and generating a model histogram from it. This method should be called 
% whenever the imRegion property is to be modified
%
%

% Stefan Wong 2013

	%Set internal constants
	DEBUG = 0;
	rSet  = false;

	if(~isempty(varargin))
		%Parse optional inputs
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = 1;
				elseif(strncmpi(varargin{k}, 'size', 4))
					DATA_SZ = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'set', 3))
					rSet = true;
				end
			end
		end
	end

	if(~exist('DATA_SZ', 'var'))
		DATA_SZ = handles.segmenter.getDataSz();
	end

	% Sanity check arguments
	rsz = size(region);
	if(rsz(1) ~= 2 || rsz(2) ~= 2)
		fprintf('ERROR: region matrix must be 2x2 (%d x %d supplied)\n', rsz(1), rsz(2));
		status = -1;
		nh     = [];
		if(nargout > 2)
			varargout{1} = [];
		end
		return;
	end
	if(idx == 0)
		fprintf('ERROR: idx not set (equal 0)\n');
		status = -1;
		nh     = [];
		if(nargout > 2)
			varargout{1} = [];
		end
		return;
	end
	if(isempty(idx))
		fprintf('ERROR: idx not set (empty)\n');
		status = -1;
		nh     = [];
		if(nargout > 2)
			varargout{1} = [];
		end
		return;
	end

	%Once we have the correct number and type of arguments, set the model histogram
	%parameters in the csSegmenter object, and update the GUI as required
	fh      = handles.frameBuf.getFrameHandle(idx);
	img     = imread(get(fh, 'filename'), 'TIFF');
	hsv_img = rgb2hsv(img);
	hue_img = DATA_SZ .* hsv_img(:,:,1);
	if(rSet)
		handles.segmenter.setImRegion(region);
	end
	mhist = handles.segmenter.genMhist(hue_img, region, 'set');
	if(nargout > 2)
		%varargout{1} = handles.segmenter.getMhist();
        varargout{1} = mhist;
	end
	
	status = 0;
	nh     = handles;


end 	%init_modelHist()
