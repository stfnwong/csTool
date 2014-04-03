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
	PLOT_TRAJ = false;

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
				%elseif(strncmpi(varargin{k}, 'seg', 3))
				%	seg = 1;
                elseif(strncmpi(varargin{k}, 'param', 5))
                    pidx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'traj', 4))
					PLOT_TRAJ = true;
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = 1;
				end
			end
		end
	end

	% TODO : deprecate passing in frame handle
	
	%Sanity check
	if(~exist('idx', 'var') && ~exist('fh', 'var'))
		fprintf('ERROR: none of idx or var set correctly, exiting... \n');
		status = -1;
		nh     = [];
		return;
	end
	
	% Bounds check idx and get frame handle.
	if(idx == 0)
		fprintf('ERROR: idx not set (equal 0)\n');
		status = -1;
		nh     = [];
		return;
	end
	if(isempty(idx))
		fprintf('ERROR: idx no set (empty)\n');
		status = -1;
		nh     = [];
		return;
	end
	fh  = handles.frameBuf.getFrameHandle(idx);
	img = handles.frameBuf.getCurImg(idx);
	%set(fh, 'dims', [dims(2) dims(1)]);
	imshow(img, 'parent', handles.fig_framePreview);
	gui_setPreviewTitle(get(fh, 'filename'), handles.fig_framePreview);

	%If there is segmentation data, show this as well
	

	if(handles.frameBuf.hasBpData(idx))
		bpimg = handles.frameBuf.getCurImg(idx, 'mode', 'bp');
		if(get(handles.chkShowSparse, 'Value'))
            %Check if this is a sparse vector, and show as such in preview
            if(handles.frameBuf.isSparseVec(idx))
                [spvec spstat] = buf_spEncode(bpimg, 'auto', 'rt', 'trim', 'sz', handles.frameBuf.getSparseFac(idx));
                if(spstat.numZeros == 0)
                    bpimg = vec2bpimg(spvec, 'dims', bpdims);
                end
            end
		end
		%Be sure that the data returned correctly
		if(isempty(bpimg) || numel(bpimg) == 0)
			fprintf('ERROR: Incorrect bpvec conversion in gui_showPreview()..\n');
			status = -1;
			nh     = handles;
			return;
		end
		imshow(bpimg, 'parent', handles.fig_bpPreview);
	end

	if(PLOT_TRAJ)
		%Plot a certain amount of frames before and after the current one 
        tVec = gui_getTraj(handles.frameBuf, 'trim');
        gui_plotTraj(handles.fig_framePreview, tVec, frameIndex);
	else
		%If there is tracking data, overlay this onto segmentation data 
		%and place window parameter data onto gui
		params = handles.frameBuf.getWinParams(idx);
		%If the first element is empty, then the rest will also be empty
		%(similarly for zero)
		if(isempty(params) ||isequal(params, zeros(1,length(params))))
			%fprintf('No params set for this frame\n');
			set(handles.etParam, 'String', 'No window parameters set for this frame');
		else
            if(~exist('idx', 'var'))
                fprintf('WARNING: No idx parameter in gui_showPreview()!!!\n');
                idx = 1;
            end
			moments = handles.frameBuf.getMoments(idx);
			niters  = handles.frameBuf.getNiters(idx);
			dims    = handles.frameBuf.getDims(idx);
			bpsum   = handles.frameBuf.getBpSum(idx);
			gui_plotParams(handles.fig_bpPreview, params, moments, niters);
			if(exist('params', 'var'))
				params = handles.frameBuf.getWinParams(idx);
			end
			if(~exist('pidx', 'var'))
				pidx = 1;
			end
			[str status] = gui_setWinParams(pidx, params, moments, niters, dims, bpsum);
			if(status == 0)
				set(handles.etParam, 'String', str);
			end
		end
	end
	status = 0;
	nh     = handles; 

end		%gui_showPreview()
