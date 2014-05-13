function varargout = csToolTrajBuf(varargin)
% CSTOOLTRAJBUF M-file for csToolTrajBuf.fig
%      CSTOOLTRAJBUF, by itself, creates a new CSTOOLTRAJBUF or raises the existing
%      singleton*.
%
%      H = CSTOOLTRAJBUF returns the handle to a new CSTOOLTRAJBUF or the handle to
%      the existing singleton*.
%
%      CSTOOLTRAJBUF('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in CSTOOLTRAJBUF.M with the given input arguments.
%
%      CSTOOLTRAJBUF('Property','Value',...) creates a new CSTOOLTRAJBUF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolTrajBuf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolTrajBuf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolTrajBuf

% Last Modified by GUIDE v2.5 13-May-2014 21:26:49

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
					   'gui_Singleton',  gui_Singleton, ...
					   'gui_OpeningFcn', @csToolTrajBuf_OpeningFcn, ...
					   'gui_OutputFcn',  @csToolTrajBuf_OutputFcn, ...
					   'gui_LayoutFcn',  [] , ...
					   'gui_Callback',   []);
	if nargin && ischar(varargin{1})
		gui_State.gui_Callback = str2func(varargin{1});
	end

	if nargout
		[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
		gui_mainfcn(gui_State, varargin{:});
	end
	% End initialization code - DO NOT EDIT


% --- Executes just before csToolTrajBuf is made visible.
function csToolTrajBuf_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

	% Choose default command line output for csToolTrajBuf
	handles.debug     = false;
	handles.trajBuf   = [];		%temporary buffer to hold extracted trajectory
	handles.compBuf   = [];
	handles.renderBuf = cell(1,1);
    handles.labBuf    = cell(1,2);
	handles.errBuf    = [];
	handles.fbIdx     = 1;
    %Parse optional arguments
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(isa(varargin{k}, 'vecManager'))
				handles.vecManager = varargin{k};
			%elseif(isa(varargin{k}, 'csFrameBuffer'))
			%	handles.frameBuf   = varargin{k};
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = true;
				elseif(strncmpi(varargin{k}, 'idx', 3))
					handles.fbIdx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'frameBuf', 8))
					handles.frameBuf = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'testBuf', 7))
					handles.testBuf = varargin{k+1};
				end
			end
		end
	end

	%Check what we have
	if(~isfield(handles, 'vecManager'))
		fprintf('ERROR: No vecManager object in csToolTrajBuf()\n');
		handles.output = -1;
		return;
	end
	if(~isfield(handles, 'frameBuf'))
		fprintf('ERROR: No frameBuf object in csToolTrajBuf()\n');
		handles.output = -1;
		return;
	end
	if(~isfield(handles, 'testBuf'))
		fprintf('ERROR: No testBuf object in csToolTrajBuf()\n');
		handles.output = -1;
		return;
	end

	%Populate GUI elements
	vmanOpts = handles.vecManager.getOpts();
	idxLabel = vmanOpts.trajLabel;
    %We might not have tracked any frames yet, so check that the parameters
    %we need are not empty before setting
    if(isempty(idxLabel))
		s = cell(1, length(vmanOpts.trajBuf));
		for k = 1:length(s)
			s{k} = '(Empty)';
		end
        set(handles.pmBufIdx, 'String', s);
        set(handles.pmBufIdx, 'Value', 1);
        set(handles.pmCompIdx, 'String', s);
        set(handles.pmCompIdx, 'Value', 1);
    else
        set(handles.pmBufIdx, 'String', idxLabel);
        set(handles.pmBufIdx, 'Value', 1);
        %Initially, set the compare buffer to the same index
        set(handles.pmCompIdx, 'String', idxLabel);
        set(handles.pmCompIdx, 'Value', 1);
        set(handles.etTrajLabel, 'String', idxLabel{1}); 	
    end
        
	% Make the default range the entire buffer
	set(handles.etRangeLow,  'String', '1');
	set(handles.etRangeHigh, 'String', num2str(handles.frameBuf.getNumFrames()));

	%Get rid of tick labels, etc
	set(handles.fig_trajPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.fig_trajPreview, 'YTick', [], 'YTickLabel', []);
	%set(handles.fig_trajErrorX,  'XTick', [], 'XTickLabel', []);
	%set(handles.fig_trajErrorX,  'YTick', [], 'YTickLabel', []);
	%set(handles.fig_trajErrorY,  'XTick', [], 'XTickLabel', []);
	%set(handles.fig_trajErrorY,  'YTick', [], 'YTickLabel', []);
	
	% Setup axes labels for error plots
	xlabel(handles.fig_trajErrorX, 'Frame #');
	ylabel(handles.fig_trajErrorX, 'Error (pixels)');
	title(handles.fig_trajErrorX, 'Error (x dimension)');
	xlabel(handles.fig_trajErrorY, 'Frame #');
	ylabel(handles.fig_trajErrorY, 'Error (pixels)');
	title(handles.fig_trajErrorY, 'Error (y dimension)');
	
	%Check that there are frames in frame buffer
	if(handles.frameBuf.getNumFrames() < 1)
		%Cant do anything without frames....
		fprintf('ERROR: No frames loaded in csTool session, exiting...\n');
		handles.output = -1;
		return;
	end

	%Place a frame on the preview region
	img = handles.frameBuf.getCurImg(handles.fbIdx);
	gui_renderPreview(handles.fig_trajPreview, img, handles.fbIdx, []);
    %Set the buffer size to be whatever size is currently in the vecManager
    %object
    set(handles.etBufSize, 'String', num2str(handles.vecManager.getTrajBufSize()));
    %Set current frame
    set(handles.etCurFrame, 'String', num2str(handles.fbIdx));

    %handles.output = hObject;
	guidata(hObject, handles);

	% UIWAIT makes csToolTrajBuf wait for user response (see UIRESUME)
	uiwait(handles.fig_trajBuf);


% --- Outputs from this function are returned to the command line.
function varargout = csToolTrajBuf_OutputFcn(hObject, eventdata, handles) %#ok<INUSL> 
	handles.output = struct('vecManager', handles.vecManager, ...
                            'frameBuf',   handles.frameBuf);
	varargout{1} = handles.output;
    delete(handles.fig_trajBuf);
	%delete(hObject);

function fig_trajBuf_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    if(isequal(get(hObject, 'waitstatus'), 'waiting'))
        %Still waiting on GUI
        uiresume(handles.fig_trajBuf);
    else
        %Ok to clean up
        delete(handles.fig_trajBuf);
    end


% -------- RENDERING FUNCTIONS -------- %
function gui_renderPreview(axHandle, img, idx, filename, varargin)
	% Render the main preview screen (trajectory rendered seperately)
	%img = imread(get(fh, 'filename'), get(fh, 'ext'));
	if(~isempty(varargin))
		prevMode = varargin{1};
	else
		prevMode = 'normal';
	end
	if(isempty(filename))
		filename = sprintf('frame-%03d.file', idx);
	end

	%if(strncmpi(prevMode, 'bp', 2))
	%	%Show backprojection
	%	bpimg = vec2bpimg(get(fh, 'bpData'), 'dims', get(fh, 'dims'));
	%	imshow(bpimg, 'Parent', axHandle);
	%else
	%	imshow(img, 'Parent', axHandle);
	%end
	imshow(img, 'Parent', axHandle);
	fs = fname_parse(filename);
	if(fs.exitflag == -1)
		return;
	end
	title(axHandle, sprintf('frame %d (%s_%d)', idx, fs.filename, fs.vecNum), 'Interpreter', 'None');

function gui_renderErrorPlot(axHandle, traj, idx, varargin)
	% Render the error plot of the provided trajectories. traj must be cell array
	% We need two axes handles, one to plot errors in x, one to plot errors in y
	if(length(axHandle) < 2)
		fprintf('ERROR: Need an axes handle for each axis in error plot\n');
		return;
	end

	if(~isempty(varargin))
        for k = 1:length(varargin)
            if(ischar(varargin{k}))
                if(strncmpi(varargin{k}, 'label', 5))
                    label = varargin{k+1};
                elseif(strncmpi(varargin{k}, 'leg', 3))
                    lgnd  = varargin{k+1};
                elseif(strncmpi(varargin{k}, 'range', 5))
                    range = varargin{k+1};
                end
            end
        end
	end

	if(length(axHandle) < length(traj))
		fprintf('ERROR: More trajectories than axes handle, exiting...\n');
		return;
	end
	
	if(iscell(traj))
		if(length(traj) < 2)
			%Not enough data for errorplot (should this support > 2?)
			fprintf('traj must contain at at least 2 trajectories\n');
		else
			%Bounds check idx, axHandle
			t = traj{1};
			if(idx < 1 || idx > length(t))
				fprintf('ERROR: idx out of range (%d), exiting...\n', idx);
				return;
			end	
			for k = 1:length(axHandle)
				% Take each trajectory out of cell array, and plot x and y on 
				% seperate axis handles. To hightlight currently selected index, 
				% create a NaN array and place in the correct position the value 
				% from the trajectory array to create a stem plot with a
				% single element.
                cla(axHandle(k));
				hold(axHandle(k), 'on');
				t      = traj{k};
                if(exist('range', 'var'))
                    t = t(range(1):range(2));
                end
				sh     = stem(axHandle(k), 1:length(t), t); %t already scalar
				p      = NaN * zeros(1, length(t));
				p(idx) = t(idx);
				shp    = stem(axHandle(k), 1:length(p), p, 'v');
                set(sh, 'Color',[0 0 1], 'MarkerFaceColor',[0 1 0], 'MarkerSize', 2);
                set(shp,'Color',[0 0 1], 'MarkerFaceColor',[1 0 0], 'MarkerSize',10);
                %if(k == 1)
                %    title('Trajectory Error (x)');
                %else
                %    title('Trajectory Error (y)');
                %end
                %xlabel('Frame #');
                %ylabel('Error (pixels)');
                if(exist('lgnd', 'var'))
                    legend(sh, lgnd);       %DEPRECATED
                end
				hold(axHandle(k), 'off');
			end
		end
	else
		fprintf('traj must be cell, and contain at least 2 trajectories\n');
		return;
	end
	%guidata(hObject, handles);


function gui_renderTraj(axHandle, traj, idx, col, varargin)
	% Place the trajectory traj on the axes axHandle highlighting index idx
    %error(nargchk(3,3,nargin));

    if(~isempty(varargin))
        for k = 1:length(varargin)
            if(ischar(varargin{k}))
                if(strncmpi(varargin{1}, 'tag', 3))
                    plotTag = varargin{2};
                elseif(strncmpi(varargin{k}, 'range', 5))
                    range = varargin{k+1};
                end
            end
        end
    end

    if(isempty(col))
        col = [0 1 0];
    end

	%Bounds check our index
	if(idx < 1 || idx > length(traj))
		fprintf('ERROR: index (%d) out of bounds [1 %d]\n', idx, length(traj));
		return;
	end
	%Also check the trajectory is well formed
	tsz = size(traj);
	if(tsz(1) ~= 2)
		fprintf('ERROR: Trajectory data not well formed (first dim must be 2)\n');
		return;
	end
    %Perform range extraction, if requested
    if(exist('range', 'var'))
        traj = traj(range(1):range(2), :);
    end
	hold(axHandle, 'on');
	ph = plot(axHandle, traj(1,:), traj(2,:), 'v-'); 	%main trajectory
	set(ph, 'Color', col, 'MarkerSize', 8, 'LineWidth', 1);
	ih = plot(axHandle, traj(1,idx), traj(2,idx), 'x');		%index point
	set(ih, 'Color', [1 0 0], 'MarkerSize', 16, 'LineWidth', 2);
    set(ph, 'Tag', plotTag);
	hold(axHandle, 'off');


% Use this method to pre-compute the error value for use in a textbox	
function errBuf = gui_precompError(traj1, traj2, varargin) %#ok<DEFNU>
	%Sanity check
	if(length(traj1) ~= length(traj2))
		fprintf('ERROR: trajectory lengths must be equal\b');
		errBuf = [];
		return;
	end

	errBuf = abs(traj1 - traj2);

function stats = gui_renderText(pErr, pTraj) 
	% Update the textbox with trajectory information (CHANGED: to a
	% listbox - format the string as cell array and pass to listbox)
        if(isempty(pErr))
            %just place the trajectory information in listbox
            stats = cell(1, length(pTraj));
            for k = 1:length(stats)
                stats{k} = sprintf('[%3d] x: %3.2f y: %3.2f', k, pTraj(1,k), pTraj(2,k));
            end
        else
            %format the string to have error terms on end
            if(length(pErr) ~= length(pTraj))
                fprintf('ERROR: Lengths must match (pErr: %d, pTraj: %d)\n', length(pErr), length(pTraj));
                return;
            end
            stats = cell(1, length(pTraj));
            for k = 1:length(stats)
                stats{k} = sprintf('[%3d] x: %3.2f y: %3.2f | err(x): %3.2f err(y): %3.2f', k, pTraj(1,k), pTraj(2,k), pErr(1,k), pErr(2,k));
            end
        end

function gui_updatePreview(axHandle, img, idx, traja, trajb, trajErr, varargin)

    if(~isempty(varargin))
        for k = 1:length(varargin)
            if(ischar(varargin{k}))
                if(strncmpi(varargin{k}, 'label', 5))
                    lab = varargin{k+1};
                elseif(strncmpi(varargin{k}, 'range', 5))
                    range = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fname', 5))
					filename = varargin{k+1};
                end
            end
        end
    end

    %Check what we have
    if(~exist('lab', 'var'))
        lab = {'Trajectory A', 'Trajectory B'};
    else
        if(isempty(lab{1}))
            lab{1} = 'Trajectory A';
        end
        if(isempty(lab{2}))
            lab{2} = 'Trajectory B';
        end
    end
	if(~exist('filename', 'var'))
		filename = sprintf('frame-%03d.file', idx);
	end
	%Pass all 3 axes handles here to save having really long lines at the caller
	if(length(axHandle) < 3)
		fprintf('ERROR: Pass in all axes handles in the following order\n');
		fprintf('axHandle(1) : fig_trajPreview\n');
		fprintf('axHandle(2) : fig_trajErrorX\n');
		fprintf('axHandle(3) : fig_trajErrorY\n');
	end
	%Update the fig_trajPreview axes
	gui_renderPreview(axHandle(1), img, idx, filename);

    if(~isempty(traja))
        gui_renderTraj(axHandle(1), traja, idx, [0 1 0], 'tag', 'pTraj1');
    end
    if(~isempty(trajb))
        gui_renderTraj(axHandle(1), trajb, idx, [0 0 1], 'tag', 'pTraj2');
    end
    %Heres a (somewhat complicated) way to get the legend to be correct
    %every time
	%TODO : This actually doesnt work EVERY time
    axc = get(axHandle(1), 'Children');
    n   = 1;
    for k = 1:length(axc)
        if(strncmpi(get(axc(k), 'tag'), 'pTraj1', 6))
            lgnd(n) = axc(k);   %#ok<AGROW>
            n = n + 1;
        elseif(strncmpi(get(axc(k), 'tag'), 'pTraj2', 6))
            lgnd(n) = axc(k);   %#ok<AGROW>
            n = n + 1;
        end
    end
    if(exist('lgnd', 'var'))
        if(length(lgnd) > 1)
            legend(lgnd, lab{1}, lab{2});
        else
            legend(lgnd, lab{1});
        end
    end
    if(~isempty(trajErr))
        t = {trajErr(1,:), trajErr(2,:)};
        gui_renderErrorPlot([axHandle(2) axHandle(3)], t, idx);
    end
	

% -------- CALLBACK FUNCTIONS -------- %

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Bounds check and increment frame index
	N = handles.frameBuf.getNumFrames();
	if(handles.fbIdx < N)
		handles.fbIdx = handles.fbIdx + 1;
		img = handles.frameBuf.getCurImg(handles.fbIdx);
		%fh = handles.frameBuf.getFrameHandle(handles.fbIdx
		%gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
		ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
		ta  = handles.trajBuf;
		tb  = handles.compBuf;
        err = handles.errBuf;
		gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);
	else
		handles.fbIdx = N;
	end
    %Update text positon
    if(~isempty(handles.trajBuf) || ~isempty(handles.compBuf))
        set(handles.lbTrajStats, 'Value', handles.fbIdx);
    end
    %Update current frame text
    set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
	guidata(hObject, handles);

function bPrev_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Bounds check and decrement frame index
	if(handles.fbIdx > 1)
		handles.fbIdx = handles.fbIdx - 1;
		%fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
		img = handles.frameBuf.getCurImg(handles.fbIdx);
		%gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
		ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
		ta  = handles.trajBuf;
		tb  = handles.compBuf;
        err = handles.errBuf;
		gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);
	else
		handles.fbIdx = 1;
	end
    if(~isempty(handles.trajBuf) || ~isempty(handles.compBuf))
        set(handles.lbTrajStats, 'Value', handles.fbIdx);
    end
    %Update current frame text
    set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
	guidata(hObject, handles);



function bLast_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Go straight to the last frame
    handles.fbIdx = handles.frameBuf.getNumFrames();
    %Update previews
    %fh  = handles.frameBuf.getFrameHandle(handles.fbIdx);
	img = handles.frameBuf.getCurImg(handles.fbIdx);
    ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
    ta  = handles.trajBuf;
    tb  = handles.compBuf;
    err = handles.errBuf;
    gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);

    %Update text position
    if(~isempty(handles.trajBuf) || ~isempty(handles.compBuf))
        set(handles.lbTrajStats, 'Value', handles.fbIdx);
    end
    set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
    guidata(hObject, handles);


function bFirst_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Go straight to the first frame
    handles.fbIdx = 1;
    %Update previews
    %fh  = handles.frameBuf.getFrameHandle(handles.fbIdx);
	img = handles.frameBuf.getCurImg(handles.fbIdx);
    ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
    ta  = handles.trajBuf;
    tb  = handles.compBuf;
    err = handles.errBuf;
    gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);

    %Update text position
    if(~isempty(handles.trajBuf) || ~isempty(handles.compBuf))
        set(handles.lbTrajStats, 'Value', handles.fbIdx);
    end
    set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
    guidata(hObject, handles);


function bGoto_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Check value in textbox
    
    idx = str2double(get(handles.etGoto, 'String'));
    if(idx < 1 || idx > handles.frameBuf.getNumFrames())
        return;
    end
    handles.fbIdx = idx;
    %Update previews
	img = handles.frameBuf.getCurImg(handles.fbIdx);
    ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
    ta  = handles.trajBuf;
    tb  = handles.compBuf;
    err = handles.errBuf;
    gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);

    %Update text position
    if(~isempty(handles.trajBuf) || ~isempty(handles.compBuf))
        set(handles.lbTrajStats, 'Value', handles.fbIdx);
    end
    set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
    guidata(hObject, handles);



function bWrite_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Write current trajectory (from buffer) to specified index in vecManager
	if(isempty(handles.trajBuf) || numel(handles.trajBuf) == 0)
		fprintf('No data in intermediate trajectory buffer\n');
		fprintf('Press (Extract Trajectory) to get trajectory currently in frameBuf\n');
		return;
	end

	idx   = get(handles.pmBufIdx, 'Value');
	label = get(handles.etTrajLabel, 'String');
	handles.vecManager = handles.vecManager.writeTrajBuf(idx, handles.trajBuf);
	handles.vecManager = handles.vecManager.writeTrajBufLabel(idx, label);	
    fprintf('[csToolTrajBuf] : Write compBuf to index %d of trajectory buffer\n', idx);
    %Refresh the drop-down boxes
    labelString = handles.vecManager.getTrajBufLabel('all');
    set(handles.pmBufIdx, 'String', labelString);
    set(handles.pmCompIdx, 'String', labelString);
    %Update the label buffer
    clab = handles.vecManager.getTrajBufLabel(get(handles.pmCompIdx, 'Value'));
    handles.labBuf{1} = label;
    handles.labBuf{2} = clab;

	guidata(hObject, handles);

function bRead_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Read data out of the vecManager trajectory buffer at the specified
	% index. Place data into compare buffer (handles.compBuf)
    idx  = get(handles.pmBufIdx, 'Value');
	traj = handles.vecManager.readTrajBuf(idx);
	handles.compBuf = traj;
    fprintf('[csToolTrajBuf] : placed trajectory at index %d into compare buffer\n', handles.fbIdx);
    %Also update GUI
    ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
	img = handles.frameBuf.getCurImg(handles.fbIdx);
    ta  = handles.trajBuf;
    tb  = handles.compBuf;
    err = handles.errBuf;
    gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);
    %Update Text region
    if(~isempty(handles.trajBuf) && ~isempty(handles.compBuf))
        pErr = abs(handles.trajBuf - handles.compBuf);
    else
        pErr = [];
    end
    stats = gui_renderText(pErr, handles.compBuf);
    set(handles.lbTrajStats, 'String', stats);
    set(handles.lbTrajStats, 'Value', handles.fbIdx);
    %Update the trajectory label box each time a new trajectory is read
    nLabel = handles.vecManager.getTrajBufLabel(get(handles.pmBufIdx, 'Value'));
    set(handles.etTrajLabel, 'String', nLabel);
    %Update the label buffer
    clab   = handles.vecManager.getTrajBufLabel(get(handles.pmCompIdx, 'Value'));
    handles.labBuf{1} = nLabel;
    handles.labBuf{2} = clab;
    
	guidata(hObject, handles);

function bGetRef_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Extract current trajectory from frame buffer and place into trajectory
	%buffer.
	lRange = str2double(get(handles.etRangeLow, 'String'));
	hRange = str2double(get(handles.etRangeHigh, 'String'));
	range  = [lRange hRange];
	handles.trajBuf = handles.frameBuf.getTraj(range);

	% Also show trajectory in preview
    %fh  = handles.frameBuf.getFrameHandle(handles.fbIdx);
	img = handles.frameBuf.getCurImg(handles.fbIdx);
    ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
    ta  = handles.trajBuf;
    tb  = handles.compBuf;
    err = handles.errBuf;
    gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);
	%gui_renderTraj(handles.fig_trajPreview, handles.trajBuf);
    %Set the trajectory name
    trajLab = get(handles.etTrajLabel, 'String');
    idx     = get(handles.pmBufIdx, 'Value');
    handles.vecManager = handles.vecManager.writeTrajBufLabel(idx, trajLab);
    %Update listbox with trajectory values
    if(~isempty(handles.trajBuf) && ~isempty(handles.compBuf))
        pErr = abs(handles.trajBuf - handles.compBuf);
    else
        pErr = [];
    end
    stats = gui_renderText(pErr, handles.trajBuf);
    set(handles.lbTrajStats, 'String', stats);
    set(handles.lbTrajStats, 'Value', handles.fbIdx);
    nLabel = handles.vecManager.getTrajBufLabel(get(handles.pmBufIdx, 'Value'));
    set(handles.etTrajLabel, 'String', nLabel);

	guidata(hObject, handles);

function bGetTest_Callback(hObject, eventdata, handles) %#okINUSL,DEFNU>
	% Get trajectory from test buffer
	% TODO : Sort out trajectory get	
	lRange = str2double(get(handles.etRangeLow, 'String'));
	hRange = str2double(get(handles.etRangeHigh, 'String'));
	range  = [lRange hRange];
	handles.trajBuf = handles.testBuf.getTraj(range);

	% Also show trajectory in preview
    %fh  = handles.testBuf.getFrameHandle(handles.fbIdx);
	img = handles.testBuf.getCurImg(handles.fbIdx);
    if(isempty(img))
        fprintf('ERROR: No data in test buffer\n');
        return;
    end
    ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
    ta  = handles.trajBuf;
    tb  = handles.compBuf;
    err = handles.errBuf;
    gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);
	%gui_renderTraj(handles.fig_trajPreview, handles.trajBuf);
    %Set the trajectory name
    trajLab = get(handles.etTrajLabel, 'String');
    idx     = get(handles.pmBufIdx, 'Value');
    handles.vecManager = handles.vecManager.writeTrajBufLabel(idx, trajLab);
    %Update listbox with trajectory values
    if(~isempty(handles.trajBuf) && ~isempty(handles.compBuf))
        pErr = abs(handles.trajBuf - handles.compBuf);
    else
        pErr = [];
    end
    stats = gui_renderText(pErr, handles.trajBuf);
    set(handles.lbTrajStats, 'String', stats);
    set(handles.lbTrajStats, 'Value', handles.fbIdx);
    nLabel = handles.vecManager.getTrajBufLabel(get(handles.pmBufIdx, 'Value'));
    set(handles.etTrajLabel, 'String', nLabel);

	guidata(hObject, handles);

function bSetLabel_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Write just the label into the vecManager object
	label = get(handles.etTrajLabel, 'String');
	idx   = get(handles.pmBufIdx, 'Value');
	handles.vecManager = handles.vecManager.writeTrajBufLabel(idx, label);
	if(handles.debug)
		fprintf('Wrote label [%s] to index (%d)\n', label, idx);
	end
    %Refresh the drop-down boxes
    labelString = handles.vecManager.getTrajBufLabel('all');
    set(handles.pmBufIdx, 'String', labelString);
    set(handles.pmCompIdx, 'String', labelString);
    %Update the handle buffer
    blab = handles.vecManager.getTrajBufLabel(get(handles.pmBufIdx, 'Value'));
    clab = handles.vecManager.getTrajBufLabel(get(handles.pmCompIdx, 'Value'));
    handles.labBuf{1} = blab;
    handles.labBuf{2} = clab;

	guidata(hObject, handles);

function bCompare_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Plot the two selected trajectories in the preview axes and modify GUI
	% properties as needed to display trajectory information
	
	%Get trajectory A
	taidx = get(handles.pmBufIdx, 'Value');
	traja = handles.vecManager.readTrajBuf(taidx);
	%Get trajectory B
	if(get(handles.chkCompCur, 'Value'))
		%Extract the current trajectory from frame buffer and store in next empty 
		%index in vecManager
		lr    = str2double(get(etRangeLow, 'String'));
		hr    = str2double(get(etRangeHigh, 'String'));
		trajb = handles.frameBuf.getTraj([lr hr]);
	else
		%Use the trajectory selected in comp menu
		tbidx = get(handles.pmCompIdx, 'Value');
		trajb = handles.vecManager.readTrajBuf(tbidx);
	end

	%Pre compute error terms and render
	%fh  = handles.frameBuf.getFrameHandle(handles.fbIdx);
	img = handles.frameBuf.getCurImg(handles.fbIdx);
    ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
    err = abs(traja - trajb);
    gui_updatePreview(ah, img, handles.fbIdx, traja, trajb, err, 'label', handles.labBuf);
	handles.errBuf = err;
    % DEPRECATED
	%gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
	%gui_renderTraj(handles.fig_trajPreview, traja, handles.fbIdx, [0 1 0]);
	%gui_renderTraj(handles.fig_trajPreview, trajb, handles.fbIdx, [0 0 1]);
    %Render error plot
    %ah = [handles.fig_trajErrorX handles.fig_trajErrorY];
    %traj = {traja, trajb};
    %gui_renderErrorPlot(ah, traj, handles.fbIdx);
	%Save current selection to trajectory buffer
	handles.trajBuf = traja;
	handles.compBuf = trajb;
    %Update text area
    stats = gui_renderText(handles.errBuf, handles.compBuf);
    set(handles.lbTrajStats, 'String', stats);
    set(handles.lbTrajStats, 'Value', handles.fbIdx);
    %Update the trajectory label box each time a new trajectory is read
    nLabel = handles.vecManager.getTrajBufLabel(get(handles.pmBufIdx, 'Value'));
    set(handles.etTrajLabel, 'String', nLabel);
    %Update the label buffer
    clab   = handles.vecManager.getTrajBufLabel(get(handles.pmCompIdx, 'Value'));
    handles.labBuf{1} = nLabel;
    handles.labBuf{2} = clab;

	% Find average error and display
	avgX = sum(err(1,:)) / length(err);
	avgY = sum(err(2,:)) / length(err);
	set(handles.etAvgErrX, 'String', sprintf('%3.2f', avgX));
	set(handles.etAvgErrY, 'String', sprintf('%3.2f', avgY));
	% Find standard deviation and display
	stdX = std(err(1,:));
	stdY = std(err(2,:));
	set(handles.etStdDevX, 'String', sprintf('%3.2f', stdX));
	set(handles.etStdDevY, 'String', sprintf('%3.2f', stdY));
		
	guidata(hObject, handles);

function bResize_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Resize the trajectory buffer in vecManager object
    bufSize = fix(str2double(get(handles.etBufSize, 'String')));
    if(get(handles.chkKeep, 'Value'))
        handles.vecManager = handles.vecManager.setTrajBufSize(bufSize, 'keep');
    else
        handles.vecManager = handles.vecManager.setTrajBufSize(bufSize);
    end
    guidata(hObject, handles);

function menu_bufSize_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Re-size the trajectory buffer in vecManager (this requires a sub-menu)

	if(handles.debug)
		V = csToolTrajResize(handles.vecManager, 'debug');
	else
		V = csToolTrajResize(handles.vecManager);
	end
	if(~isa(V, 'vecManager') || isempty(V))
		fprintf('ERROR: vecManager object from csToolTrajResize incomplete\n');
		return;
	end
    
	guidata(hObject, handles);

% Build into this GUI the notion of range, so that when we adjust the value
% in either of these boxes, only entires within the ranges are displayed on
% in the preview area, error plot etc
function etRangeLow_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etRangeHigh_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function menu_save_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Save all available data to disk
    DATA_DIR  = 'data/settings';
    trajData  = handles.vecManager.readTrajBuf('all');
    trajLabel = handles.vecManager.getTrajBufLabel('all');
    fprintf('Saving trajectory data...\n');
    wb = waitbar(0, 'Saving trajectories from buffer', ...
                    'Name', 'Saving Trajectory Data');
    for k = 1:length(trajData)
        if(~isempty(trajData{k}))
            tData = trajData{k};    %#ok
            save(sprintf('%s/trajBuf-%02d', DATA_DIR, k), 'tData');
        end
        if(~isempty(trajLabel{k}))
            tLabel = trajLabel{k};  %#ok
            save(sprintf('%s/trajLabel-%02d', DATA_DIR, k), 'tLabel');
        end
        waitbar(k/length(trajData), wb, 'Saving Trajectory Data...');
    end
    delete(wb);
    fprintf('...done\n');
            

function menu_load_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Load variables from disk
    DATA_DIR = 'data/settings';
    tbLen    = handles.vecManager.getTrajBufSize();
    for k = 1:tbLen
        fname = sprintf('%s/trajBuf-%02d', DATA_DIR, k);
        if(exist(fname, 'file') == 2)
            load(fname);
        end
    end
	guidata(hObject, handles);


function menu_formSubplot_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Create a new figure with all data plotted for use in papers, reports, etc

	%Don't bother doing this if we haven't got any data in the trajectory
    %and compare buffers.
    if(isempty(handles.trajBuf) || isempty(handles.compBuf))
        fprintf('ERROR; Both trajBuf and compBuf must be set\n');
        return;
    end

    % Format data as required
    rl  = str2double(get(handles.etRangeLow, 'String'));
    rh  = str2double(get(handles.etRangeHigh, 'String'));
    if(rl < 1)
        fprintf('ERROR: low range < 1\n');
        return;
    end
    if(rh > handles.frameBuf.getNumFrames())
        fprintf('ERROR: high range > num frames (%d)\n', handles.frameBuf.getNumFrames());
        return;
    end
    %fh    = handles.frameBuf.getFrameHandle(handles.fbIdx);
    %img   = imread(get(fh, 'filename'), 'TIFF');
	img   = handles.frameBuf.getCurImg(handles.fbIdx);
    traja = handles.trajBuf(:, rl:rh);
    trajb = handles.compBuf(:, rl:rh);
    err   = handles.errBuf(:, rl:rh);
    %Show trajectory preview
	figure('Name', 'Trajectory Results');
    %axPrev = axes('Parent', fPrev);

    imshow(img);
    hold on;
    plot(traja(1,:), traja(2,:), 'x-', 'Color', [0 0 1], ...
         'MarkerFaceColor', [1 0 0], 'MarkerSize', 12);
	axis tight;
    plot(trajb(1,:), trajb(2,:), 'x-', 'Color', [0 1 0], ...
         'MarkerFaceColor', [1 0 0], 'MarkerSize', 12);
	axis tight;
    hold off;
    title('Target Trajectory');
    legend(sprintf('%s', handles.labBuf{1}), sprintf('%s', handles.labBuf{2}));
    
    %Show error preview
	figure('Name', 'Trajectory Error');
	%axErr  = axes('Parent', fErr);
    subplot(2,1,1);
    stem(1:length(err), err(1,:), 'Marker', 'v', ...
         'MarkerFaceColor', [1 0 0], 'Color', [0 0 1], 'MarkerSize', 8);
    title('Trajectory Error (x-axis)');
    xlabel('Frame #'); ylabel('Error (pixels)');
    subplot(2,1,2);
    stem(1:length(err), err(2,:), 'Marker', 'v', ...
         'MarkerFaceColor', [1 0 0], 'Color', [0 0 1], 'MarkerSize', 8);
    title('Trajectory Error (y-axis)');
    xlabel('Frame #'); ylabel('Error (pixels)');
	
	
	guidata(hObject, handles);

% --- Executes on key press with focus on fig_trajBuf and none of its controls.
function fig_trajBuf_KeyPressFcn(hObject, eventdata, handles) %#ok<DEFNU>
    % Add some keyboard shortcuts for this subpanel for quicker navigation,
    % etc
	% TODO : The frame indexing methods are just cut/paste of bNext and bPrev
	
	switch eventdata.Character
		case 'f'
			%Move frame forward
			N = handles.frameBuf.getNumFrames();
			if(handles.fbIdx < N)
				handles.fbIdx = handles.fbIdx + 1;
				img = handles.frameBuf.getCurImg(handles.fbIdx);
				%fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
				%gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
				ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
				ta  = handles.trajBuf;
				tb  = handles.compBuf;
				err = handles.errBuf;
				gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);
			else
				handles.fbIdx = N;
			end
			%Update text positon
			if(~isempty(handles.trajBuf) || ~isempty(handles.compBuf))
				set(handles.lbTrajStats, 'Value', handles.fbIdx);
			end
			%Update current frame text
		    set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
		case 'b'
			%Move frame back
			% Bounds check and decrement frame index
			if(handles.fbIdx > 1)
				handles.fbIdx = handles.fbIdx - 1;
				img = handles.frameBuf.getCurImg(handles.fbIdx);
				%fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
				%gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
				ah  = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
				ta  = handles.trajBuf;
				tb  = handles.compBuf;
				err = handles.errBuf;
				gui_updatePreview(ah, img, handles.fbIdx, ta, tb, err, 'label', handles.labBuf);
			else
				handles.fbIdx = 1;
			end
			if(~isempty(handles.trajBuf) || ~isempty(handles.compBuf))
				set(handles.lbTrajStats, 'Value', handles.fbIdx);
			end
			%Update current frame text
			set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
		case 'w'
			%Write to currently selected buffer
		case 'r'
			%Read from currently selected buffer
		case 'c' 
			%Compare currently selected buffers
		case 'g'
			%Get current trajectory
	end

	guidata(hObject, handles)


function bDone_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
    %Close figure and return to main GUI
    close(handles.fig_trajBuf);

% ---- UNUSED CALLBACKS ---- %
function etTrajLabel_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmBufIdx_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function lbTrajStats_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmCompIdx_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function chkCompCur_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function menu_Buffer_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etTrackingStats_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function menu_data_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkKeep_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etBufSize_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etCurFrame_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etGoto_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etAvgErrX_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etAvgErrY_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etStdDevX_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etStdDevY_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

% -------- CREATE FUNCTIONS ------- %
function etTrajLabel_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmBufIdx_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etRangeLow_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etRangeHigh_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pmCompIdx_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function lbTrajStats_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etBufSize_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etCurFrame_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etGoto_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etAvgErrX_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etAvgErrY_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etStdDevY_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etStdDevX_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%function bTrajExtract_ButtonDownFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
