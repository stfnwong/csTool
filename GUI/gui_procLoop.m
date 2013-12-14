function [status] = gui_procLoop(handles, varargin)
% GUI_PROCLOOP
% Handle processing loops for GUI callbacks.
% This function implements routines to do processing loops in csToolGUI. Since the 
% format of all processing loops is the same, this cuts down on editing and debugging
% issues, as well as making the csToolGUI.m file smaller.
%
% ARGUMENTS
% handles    - csToolGUI handles structure

% Stefan Wong 2013

	%Set internal constants
	TRACK = false;
	SEG   = false;
	DEBUG = false;
	FORCE = false;
	DSTR  = 'DEBUG (gui_procLoop) :';

	if(isempty(varargin))
		fprintf('ERROR: Not enough input arguments\n');
		status = -1;
		return;
	else
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'range', 5))
					range = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'track', 5))
					TRACK = true;
				elseif(strncmpi(varargin{k}, 'seg', 3))
					SEG   = true;
				elseif(strncmpi(varargin{k}, 'proc', 4))
					SEG   = true;
					TRACK = true;
				elseif(strncmpi(varargin{k}, 'param', 5))
					initParam = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'force', 5))
					FORCE = true;
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = true;
				end
			end
		end
	end

	% Sanity check arguments
	if(~exist('initParam', 'var'))

		if(exist('range', 'var') && range(1) > 1)
			pIters = handles.frameBuf.getNiters(range(1) - 1);
			if(FORCE)
				if(pIters < 1)
					N = 1;
				else
					N = pIters;
				end
				pParams   = handles.frameBuf.getWinParams(range(1) - 1);
				initParam = pParams(N);
			else
				if(TRACK)
					if(pIters == 0)
						fprintf('No iterations occured in param (frame %d)\n', range(1));
						status = -1;
						return;
					end
					pParams = handles.frameBuf.getWinParams(range(1)-1);
					if(isequal(pParams, zeros(1,length(pParams))));
						fprintf('frame %d has zero params\n', range(1));
						status = -1;
						return;
					end
					initParam = pParams;
				end
			end
		else
			rData = handles.rData;
			[status wparam] = handles.tracker.initWindow('region', rData.rRegion);
			if(status == -1)
				fprintf('ERROR (gui_procLoop) : wparam not correctly set\n');
				return;
			end
			if(isequal(wparam, zeros(1, length(wparam))))
				fprintf('ERROR (gui_procLoop) : csTracker.initWindow() returned zero wparam\n');
				status = -1;
				return;
			end
			fprintf('Setting initial wparam to:\n');
			disp(wparam);
		end
	else
		% Check that the specified parameter is well formed
		if(length(initParam) < 5)
			fprintf('ERROR: value in initParam has < 5 elements, exiting...\n');
			status = -1;
			return;
		end
		if(isequal(initParam, zeros(1,5)))
			fprintf('ERROR: value in initParam is zeroed, exiting...\n');
			status = -1;
			return;
		end
	end


	%Format a string for waitbar that represents the operation being performed
	if(TRACK && SEG)
		fs = 'Processing frame';
	elseif(TRACK && ~SEG)
		fs = 'Tracking frame';
	elseif(~TRACK && SEG)
		fs = 'Segmenting frame';
	else
		fprintf('ERROR: None of TRACK or SEG set in gui_procLoop(), exiting\n');
		status = -1;
		return;
	end

	if(~exist('range', 'var'))
		range = [1 handles.frameBuf.getNumFrames()];
	end

	if(DEBUG)
		if(TRACK)
			fprintf('%s got TRACK option\n', DSTR);
		end
		if(SEG)
			fprintf('%s got SEG option\n', DSTR);
		end
	end
	
	if(DEBUG)
		if(exist('range', 'var'))
			fprintf('%s got range input [%d : %d]\n', DSTR, range(1), range(2));
		end
	end

	%Make sure our waitbar has the right text for the operation
	if(exist('range', 'var'))
		wb = waitbar(0, sprintf('%ss...', fs), ...
    	                'Name', sprintf('%s %d - %d', fs, range(1), range(2)), ...
                        'CreateCancelBtn', ...
                        'setappdata(gcbf, ''canceling'', 1)');
	else
		wb = waitbar(0, sprintf('%ss...', fs), ...
                        'Name', sprintf('%s 1 - %d', fs, N), ...
                        'CreateCancelBtn', ...
                        'setappdata(gcbf, ''canceling'', 1');
	end

	status = 0;
	N = range(2);		% for compatability
	%Process frames in loop
	for k = range(1) : N
		if(getappdata(wb, 'canceling'))
			fprintf('Cancelled %s at frame %d (%d left)\n', fs, k, N-k);
			status = -1;
			break;
		end
		waitbar(k/N, wb, sprintf('%s (%d/%d)...', fs, k, N));

		% =============== SEGMENTATION ================ %
		if(SEG && handles.frameBuf.getRenderMode == 0)
			img     = handles.frameBuf.getCurImg(k, 'img');
			hsv_img = rgb2hsv(img);
			hue_img = hsv_img(:,:,1);
			[bpvec bpsum rhist] = handles.segmenter.segFrame(hue_img);
			params  = struct('bpvec',bpvec,'bpsum',bpsum,'rhist',rhist);
			handles.frameBuf = handles.frameBuf.setFrameParams(k, params);
		end
		%Check this frame has been segmented
		if(~handles.frameBuf.hasBpData(k))
			fprintf('ERROR: frame %d has no backprojected pixels\n', k);
			fprintf('gui_procLoop() exiting with %d frames unprocessed\n', N-k);
			delete(wb);
			status = -1;
			return;
		end

		% =============== TRACKING ================ %
		if(TRACK)
			if(~handles.frameBuf.hasBpData(k))
                fprintf('[gui_procLoop()] : No backprojection data in frame %s, exiting...\n', handles.frameBuf.getFilename(k));
                delete(wb);
                status = -1;
                return;
			end

			%Get frame parameters from previous frame
			if(k == 1)
				%If we didn't specify an initial parameter, gui_procLoop will have 
				%placed a winparam in csTracker.fParams. If we specified a param, 
				%pass that param into the trackFrame() method
				bpimg = handles.frameBuf.getCurImg(k, 'bpimg');	
				if(exist('initParam', 'var'))
					% TODO : Pass extra parameters for sparse tracking
					[st tOpts] = handles.tracker.trackFrame(bpimg, 'wpos', initParam, 'zm', handles.frameBuf.getZeroMoment(k));
				else
					[st tOpts] = handles.tracker.trackFrame(bpimg, 'zm', handles.frameBuf.getZeroMoment(k));
				end
				if(st == 0)
					handles.frameBuf = handles.frameBuf.setFrameParams(k, tOpts);
				end
			else
				pParam = handles.frameBuf.getWinParams(k-1);
				pIters = handles.frameBuf.getNiters(k-1);
				%Check parameters
				if(pIters < 1)
					if(FORCE)
						fprintf('INFO: nIters < 1, forcing to 1\n');
						M = 1;
					else
						fprintf('ERROR: nIters < 1 in frame %s\n', handles.frameBuf.getFilename(k-1));
						status = -1;
						delete(wb);
						return;
					end
				else
					M = pIters;
				end
				
				if(isequal(pParam, zeros(1,5)))
					if(FORCE)
						%Forcing this doesn't make that much sense, so just 
						%to the %most sensible thing in context - take the 
						%values from rRegion %and compute with the initial 
						%window
						[status pParam] = handles.tracker.initWindow('region', handles.rData.rRegion);
						if(status == -1)
							fprintf('Even with force, no dice for wparam\n');
							delete(wb);
							return;
						end
					else
						fprintf('param %d of frame %s is zeros\n', M, get(fh(k-1), 'filename'));
						delete(wb);
						return;
					end
				end
				bpimg      = handles.frameBuf.getCurImg(k, 'bpimg');
				[st tOpts] = handles.tracker.trackFrame(bpimg, 'wpos', pParam, 'zm', handles.frameBuf.getZeroMoment(k));
				if(st == -2)
					%This error code indicates that we will quit the loop early,
					%returning control to the GUI
					fprintf('ERROR: Tracking returned status code -2\n');
					status = -1;
					delete(wb);
					return;
				end
				% Update frame handles
				handles.frameBuf = handles.frameBuf.setFrameParams(k, tOpts);
				% Update target location in segmenter
				curParam = handles.frameBuf.getWinParams(k);
				xyPrev   = [curParam(1) curParam(2)];
				handles.segmenter.setXYPrev(xyPrev);
			end	 
			if(DEBUG)
				%Print more detailed error messages in debug mode
				m = handles.frameBuf.getMoments(k);
				if(isempty(m{1}) || isequal(m{1}, zeros(1,5)))
					fprintf('ERROR: moments for frame %d are zero\n', k);
					status = -1;
					break;
				end
				w = handles.frameBuf.getWinParams(k);
				if(isempty(w) || isequal(w, zeros(1,5)))
					fprintf('ERROR: winParams for frame %d are zero\n', k);
					status = -1;
					break;
				end
			else
				if(handles.tracker.getStatus() == -1)
					fprintf('ERROR: frame %d generated invalid window parameters\n', k);
					fprintf('gui_procLoop() exiting with %d frames unprocessed\n', N-k);
					status = -1;
					break;
				end
			end
		end
	end
	delete(wb);

	%Service any pending jobs here (such as prediction reporting, etc)

                           

end 	%gui_procLoop()
