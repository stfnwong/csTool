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
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = true;
				end
			end
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
		fh = handles.frameBuf.getFrameHandle(1:end);	%check - maybe replaced with N
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
                        'setappdata(handles.csToolFigure, ''canceling'', 1)');
	else
		wb = waitbar(0, sprintf('%ss...', fs), ...
                        'Name', sprintf('%s 1 - %d', fs, N), ...
                        'CreateCancelBtn', ...
                        'setappdata(handles.csToolFigure, ''canceling'', 1');
	end

	%Use this until issues with waitbar cancel button are sorted
	%if(exist('range', 'var'))
	%	wb = waitbar(0, sprintf('%ss...', fs), ...
    %                    'Name', sprintf('%s %d - %d', fs, range(1), range(2)) );
	%else
	%	wb = waitbar(0, sprintf('%ss...', fs), ...
    %                    'Name', sprintf('%s 1 - %d', fs, N) );
	%end

	status = 0;
	%Process frames in loop
	for k = 1:N
		if(getappdata(handles.csToolFigure, 'canceling'))
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
			handles.tracker.trackFrame(fh(k));
			if(DEBUG)
				%Print more detailed error messages in debug mode
				m = get(fh(k), 'moments');
				if(isempty(m{1}) || isequal(m{1}, zeros(1,5)))
					fprintf('ERROR: moments for frame %d are zero\n', k);
					status = -1;
					break;
				end
				w = get(fh(k), 'winParams');
				if(isempty(w{1}) || isequal(w{1}, zeros(1,5)))
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

                           

end 	%gui_procLoop()
