function [status nh] = gui_showPreview(handles, varargin)
% SHOWPREVIEW
% Show image associated with a frame handle in preview axes.
% This function has been re-written with to accomodate situations where the frame
% handle is already in the caller context, and we therefore need no bother obtaining
% it a second time. Pass the string 'fh' followed by the frame handle.
%
% If the frame handle is not in the context, pass in 'idx' followed by the frame index
% of the current frame, and gui_shoPreview() will read in the correct frame handle 
% and display

% Stefan Wong 2013

	%Set internal constants
	DEBUG = 0;
	DSTR  = 'DEBUG (gui_showPreview) :';

	if(isempty(varargin))
		fprintf('ERROR: Not enough input arguments in gui_showPreview()\n');
		status = -1;
		nh     = [];
		return;
	else
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'idx', 3))
					idx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fh', 2))
					fh = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'seg', 3))
					seg = 1;
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = 1;
				end
			end
		end
	end
	
	%Sanity check
	if(~exist('idx', 'var') && ~exist('fh', 'var'))
		fprintf('ERROR: none of idx or var set correctly, exiting... \n');
		status = -1;
		nh     = [];
		return;
	end
	%Check what we have. If somehow we passed in both a frame handle and and index,
	%give preference to the frame handle (and save a load)

	
	if(exist('fh', 'var'))
		img = imread(get(fh, 'filename'), 'TIFF');
	elseif(exist('idx', 'var'))
		%Bounds check idx, then get frame handle and read image
		if(idx == 0)
			fprintf('ERROR: idx not set (equal 0)\n');
			status = -1;
			nh     = [];
			return;
		end
		if(isempty(idx))
			fprintf('ERROR: idx not set (empty)\n');
			status = -1;
			nh     = [];
			return;
		end
		fh  = handles.frameBuf.getFrameHandle(idx);
		img = imread(get(fh, 'filename'), 'TIFF');
	end
	%Bounds check image and display in preview figure
	dims = size(img);
	if(dims(3) > 3)
		fprintf('WARNING: Truncating dims in gui_showPreview()\n');
		img = img(:,:,1:3);
	end
	set(fh, 'dims', [dims(2) dims(1)]);
	imshow(img, 'parent', handles.fig_framePreview);
	gui_setPreviewTitle(get(fh, 'filename'), handles.fig_framePreview);

	%if(exist('seg', 'var'))

	%If there is segmentation data, show this as well
	if(get(fh, 'bpSum') ~= 0)
		bpvec  = get(fh, 'bpVec');
		bpdims = get(fh, 'dims');
		bpimg  = vec2bpimg(bpvec, bpdims);
		%Be sure that the data returned correctly
		if(isempty(bpimg) || numel(bpimg) == 0)
			fprintf('ERROR: Incorrect bpvec conversion in gui_showPreview()..\n');
			status = -1;
			nh     = handles;
			return;
		end
		imshow(bpimg, 'parent', handles.fig_bpPreview);
	end 
	%If there is tracking data, overlay this onto segmentation data
	disp(get(fh));
	params = get(fh, 'winParams');
	%If the first element is empty, then the rest will also be empty
	%(similarly for zero)
	if(isempty(params) ||isequal(params, zeros(1,length(params))))
		fprintf('No params set for this frame\n');
	else
		gui_plotParams(fh, handles.fig_bpPreview);
	end
	status = 0;
	nh     = handles; 

end		%gui_showPreview()
