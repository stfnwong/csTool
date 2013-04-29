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

	%Do sanity check on arguments
	if(~exist('initParam', 'var'))

		%Take parameters from the frame before the first in our loop. If we are
		%processing all the frames, generate a parameter from the region value in 
		%handles.rData

		if(exist('range', 'var') && range(1) > 1)
			pFrame = handles.frameBuf.getFrameHandle(range(1) - 1);
			%Go through and check the parameter is well formed
			if(FORCE)
				%MAKE IT SO!
				if(get(pFrame, 'nIters') < 1)
					N = 1;
				else
					N = get(pFrame, 'nIters');
				end
				p         = get(pFrame, 'winParams');
				initParam = p{N};
			else
				%Actually check
				if(get(pFrame, 'nIters') == 0)
					fprintf('No iterations occured in param (frame %d)\n', range(1));
					status = -1;
					return;
				end
				if(isequal(get(pFrame, 'winParams'), zeros(1,5)))
					fprintf('frame %d has zero param\n', range(1));
					status = -1;
					return;
				end
                initParam  = get(pFrame, 'winParams');
				%p         = get(pFrame, 'winParams');
				%initParam = p{get(pFrame, 'nIters')};
                
			end	
		else
			rData = handles.rData;
			[status wparam] = handles.tracker.initWindow('region', rData.rRegion);
			if(status == -1)
				fprintf('ERROR: wparam not correctly set\n');
				return;
			end
			if(isequal(wparam, zeros(1,5)))
				fprintf('ERROR: csTracker.initWindow() returned zero wparam\n');
				status = -1;
				return;
			end	
			fprintf('Setting initial wparam to :\n');
			disp(wparam);
		end		
	else
		%Check that the specified param is well formed
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

	if(DEBUG)
		if(TRACK)
			fprintf('%s got TRACK option\n', DSTR);
		end
		if(SEG)
			fprintf('%s got SEG option\n', DSTR);
		end
	end

	%If range variable doesn't exist, assume we want to process all frames
	if(exist('range', 'var'))
		if(~isequal(size(range), [1 2]))
			fprintf('ERROR: Size must be 1x2 vector, exiting\n');
			status = -1;
			return;
		end
		fh = handles.frameBuf.getFrameHandle(range(1):range(2));
	else
		N  = handles.frameBuf.getNumFrames();
		fh = handles.frameBuf.getFrameHandle(1:N);
	end
	
	if(DEBUG)
		if(exist('range', 'var'))
			fprintf('%s got range input [%d : %d]\n', DSTR, range(1), range(2));
		end
	end

	N  = length(fh);
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
	%Process frames in loop
	for k = 1:N
		if(getappdata(wb, 'canceling'))
			fprintf('Cancelled %s at frame %d (%d left)\n', fs, k, N-k);
			status = -1;
			break;
		end
		waitbar(k/N, wb, sprintf('%s (%d/%d)...', fs, k, N));
		if(SEG)
			handles.segmenter.segFrame(fh(k));
		end
		%Check this frame has been segmented
		if(get(fh(k), 'bpSum') == 0)
			fprintf('ERROR: frame %d has no backprojected pixels.\n', k);
			fprintf('gui_procLoop() exiting with %d frames unprocessed\n', N-k);
			status = -1;
			break;
		end
		if(TRACK)
            %Check that there is backprojection data in this frame
            if(numel(get(fh(k), 'bpVec')) == 0 || sum(sum(get(fh(k), 'bpVec'))) == 0)
                fprintf('No backprojection data in frame %s, exiting...\n', get(fh(k), 'filename'));
                delete(wb);
                status = -1;
                return;
            end
			%Get frame parameters from previous frame
			if(k == 1)
				%If we didn't specify an initial parameter, gui_procLoop will have 
				%placed a winparam in csTracker.fParams. If we specified a param, 
				%pass that param into the trackFrame() method
				if(exist('initParam', 'var'))
					handles.tracker.trackFrame(fh(k), initParam);
				else
					handles.tracker.trackFrame(fh(k));
				end
			else
				%TODO: Finish this branch
				pParam = get(fh(k-1), 'winParams');
				%Check parameters
				if(get(fh(k-1), 'nIters') < 1)
					if(FORCE)
						fprintf('INFO: nIters < 1, forcing to 1\n');
						M = 1;
					else
						fprintf('ERROR: nIters < 1 in frame %s\n', get(fh(k-1), 'filename'));
						status = -1;
						delete(wb);
						return;
					end
				else
					M = get(fh(k-1), 'nIters');
				end
				
				if(isequal(pParam, zeros(1,5)))
					if(FORCE)
						%Forcing this doesn't make that much sense, so just to the 
						%most sensible thing in context - take the values from rRegion
						%and compute with the initial window
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
				%All parameters checked - run the actual tracker on this
				%frame
				trFlag = handles.tracker.trackFrame(fh(k), pParam);
				if(trFlag == -2)
					%This error code indicates that we will quit the loop early,
					%returning control to the GUI
					fprintf('ERROR: Tracking returned status code -2\n');
					status == -1;
					delete(wb);
					return;
				end
			end	 
			if(DEBUG)
				%Print more detailed error messages in debug mode
				m = get(fh(k), 'moments');
				if(isempty(m{1}) || isequal(m{1}, zeros(1,5)))
					fprintf('ERROR: moments for frame %d are zero\n', k);
					status = -1;
					break;
				end
				w = get(fh(k), 'winParams');
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
