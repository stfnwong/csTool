function varargout = csToolTrajBuf(varargin)
% CSTOOLTRAJBUF M-file for csToolTrajBuf.fig
%      CSTOOLTRAJBUF, by itself, creates a new CSTOOLTRAJBUF or raises the existing
%      singleton*.
%
%      H = CSTOOLTRAJBUF returns the handle to a new CSTOOLTRAJBUF or the handle to
%      the existing singleton*.
%
%      CSTOOLTRAJBUF('CALLBACK',hObject,eventData,handles,...) calls the local
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

% Last Modified by GUIDE v2.5 19-May-2013 16:29:49

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
function csToolTrajBuf_OpeningFcn(hObject, eventdata, handles, varargin)

	% Choose default command line output for csToolTrajBuf
	handles.debug     = false;
	handles.trajBuf   = [];		%temporary buffer to hold extracted trajectory
	handles.renderBuf = cell(1,1);
	handles.errBuf    = [];
	handles.fbIdx     = 1;
    %Parse optional arguments
    if(~isempty(varargin))
		for k = 1:length(varargin)
			if(isa(varargin{k}, 'vecManager'))
				handles.vecManager = varargin{k};
			elseif(isa(varargin{k}, 'csFrameBuffer'))
				handles.frameBuf   = varargin{k};
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = true;
				end
			end
		end
	end

	%Check what we have
	if(~isfield(handles, 'vecManger'))
		fprintf('ERROR: No vecManager object in csToolTrajBuf()\n');
		handles.output = -1;
		return;
	end
	if(~isfield(handles, 'frameBuf'))
		fprintf('ERROR: No frameBuf object in csToolTrajBuf()\n');
		handles.output = -1;
		return;
	end

	%Populate GUI elements
	vmanOpts = handles.vecManager.getOpts();
	idxLabel = vmanOpts.trajLabel;
	set(handles.pmBufIdx, 'String', idxLabel);
	set(handles.pmBufIdx, 'Value', 1);
	set(handles.etTrajLabel, 'String', idxLabel{1}); 	
	% Make the default range the entire buffer
	set(handles.etRangeLow,  'String', '1');
	set(handles.etRangeHigh, 'String', num2str(handles.frameBuf.getNumFrames()));

	%Get rid of tick labels, etc
	set(handles.fig_trajPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.fig_trajPreview, 'YTick', [], 'YTickLabel', []);
	set(handles.fig_trajErrorX,  'XTick', [], 'XTickLabel', []);
	set(handles.fig_trajErrorX,  'YTick', [], 'YTickLabel', []);
	set(handles.fig_trajErrorY,  'XTick', [], 'XTickLabel', []);
	set(handles.fig_trajErrorY,  'YTick', [], 'YTickLabel', []);
	
	%Check that there are frames in frame buffer
	if(handles.frameBuf.getNumFrames() < 1)
		%Cant do anything without frames....
		fprintf('ERROR: No frames loaded in csTool session, exiting...\n');
		handles.output = -1;
		return;
	end

    handles.output = hObject;
	guidata(hObject, handles);

	% UIWAIT makes csToolTrajBuf wait for user response (see UIRESUME)
	% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = csToolTrajBuf_OutputFcn(hObject, eventdata, handles) 
	handles.output = struct('vecManager', handles.vecManager, ...
                            'frameBuf',   handles.frameBuf);
	varargout{1} = handles.output;

% -------- RENDERING FUNCTIONS -------- %
function gui_renderPreview(axHandle, fh, idx)
	% Render the main preview screen (trajectory rendered seperately)
	img = imread(get(fh, 'filename'), get(fh, 'ext'));
	dims = size(img);
	if(dims(3) > 3)
		img = img(:,:,1:3);
	end
	imshow(img, 'Parent', axHandle);
	[ef fname num] = fname_parse(get(fh, 'filename'));
	if(ef == -1)
		return;
	end
	title(axHandle, sprintf('frame %d (%s_%d)', idx, fname, num);

function gui_renderErrorPlot(axHandle, traj, idx, varargin);
	% Render the error plot of the provided trajectories. traj must be cell array
	% We need two axes handles, one to plot errors in x, one to plot errors in y
	if(length(axHandle) < 2)
		fprintf('ERROR: Need an axes handle for each axis in error plot\n');
		return;
	end

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'label', 5))
			label = varargin{2};
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
			t = trak{1};
			if(idx < 1 || idx > length(t))
				fprintf('ERROR: idx out of range, exiting...\n');
				return;
			end	
			for k = 1:length(axHandle)
				% Take each trajectory out of cell array, and plot x and y on 
				% seperate axis handles. To hightlight currently selected index, 
				% create a NaN array and place in the correct position the value 
				% from the trajectory array, then modify the properties of this single
				% element stem
				hold(axHandle(k), 'on');
				t      = traj{k};
				sh     = stem(axHandle(k), 1:length(t), t(k,:));
				p      = NaN * zeros(1, length(t));
				p(idx) = t(k,idx);
				shp    = stem(axHandle(k), 1:length(p), p);
				set(sh, 'Color',[0 0 1], 'MarkerFaceColor',[0 1 0], 'MarkerSize', 2);
				set(shp,'Color',[0 0 1], 'MarkerFaceColor',[1 0 0], 'MarkerSize',10);
				hold(axHandle(k), 'off');
			end
		end
	else
		fprintf('traj must be cell, and contain at least 2 trajectories\n');
		return;
	end
	guidata(hObject, handles);


function gui_renderTraj(axHandle, traj, idx)
	%Place the trajectory on the specified axes handle
	hold(axHandle, 'on');
	if(iscell(traj))
		if(length(traj) < 2)
			%Still only one trajectory
			t  = traj{1};
			if(idx < 1 || idx > length(t))
				fprintf('ERROR: idx out of bounds\n');
				return;
			end
			ph = plot(axHandle, t(1,:), t(2,:), 'x');
			set(ph, 'Color', [0 1 0], 'MarkerSize', 10, 'LineWidth', 2);
			%Plot the current index differently
			ih = plot(axHandle, t(1,idx), t(2,idx));
			set(ih, 'Color', [1 0 0], 'MarkerSize', 14, 'LineWidth', 4);
		else	
			for k = 1:length(traj)
				t  = traj{k};
				if(idx < 1 || idx > length(t))
					fprintf('ERROR: idx out of bounds\n');
					return;
				end
				hold(axHandle, 'on');
				ph = plot(axHandle, t(1,:), t(2,:), 'x');
				set(ph, 'Color', [0 1 0], 'MarkerSize', 10, 'LineWidth', 2);
				%Plot the current index differently
				ih = plot(axHandle, t(1,idx), t(2,idx));
				set(ih, 'Color', [1 0 0], 'MarkerSize', 14, 'LineWidth', 4);
				hold(axHandle, 'off');
			end
		end
	else
		%Only one trajectory to plot
		plot(axHandle, traj(1,:), traj(2,:), 'x', 'Color', [1 0 0], 'MarkerSize', 14, 'LineWidth', 2);
	end
	hold(axHandle, 'off');

% Use this method to pre-compute the error value for use in a textbox	
function errBuf = gui_precompError(traj1, traj2, varargin)
	%Sanity check
	if(length(traj1) ~= length(traj2))
		fprintf('ERROR: trajectory lengths must be equal\b');
		errBuf = [];
		return;
	end

	errBuf = abs(traj1 - traj2);

function gui_renderText(pErr, pTraj)
	% Update the textbox with trajectory information

function gui_updateTrajlist(hObject, eventdata, handles)
	% Update the trajectory listbox whenver labels are changed or the buffer 
	% is resized
	

% -------- CALLBACK FUNCTIONS -------- %

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Bounds check and increment frame index
	N = handles.frameBuf.getNumFrames();
	if(handles.fbIdx < N)
		handles.fbIdx = handles.fbIdx + 1;
		fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
		gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
	else
		handles.fbIdx = N;
	end
	guidata(hObject, handles);

function bPrev_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Bounds check and decrement frame index
	if(handles.fbIdx > 1)
		handles.fbIdx = handles.fbIdx - 1;
		fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
		gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
	else
		handles.fbIdx = 1;
	end
	guidata(hObject, handles);


function bWrite_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
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

	guidata(hObject, handles);

function bRead_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Read data out of buffer at current index and place on preview axes.
	traj = handles.vecManager.readTrajBuf(handles.fbIdx);
	

function bTrajExtract_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Extract current trajectory from frame buffer
	lRange = str2double(get(handles.etRangeLow, 'String'));
	hRange = str2double(get(handles.etRangeHigh, 'String'));
	range  = [lRange hRange];
	handles.trajBuf = handles.frameBuf.getTraj(range);

	% Also show trajectory in preview
	gui_renderTraj(handles.fig_trajPreview, handles.trajBuf);

	guidata(hObject, handles);

function bSetLabel_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Write just the label into the vecManager object
	label = get(handles.etTrajLabel, 'String');
	idx   = get(handles.pmBufIdx, 'Value');
	handles.vecManager = handles.vecManager.writeTrajBufLabel(idx, label);	

	guidata(hObject, handles);


% ---- UNUSED CALLBACKS ---- %
function etTrajLabel_Callback(hObject, eventdata, handles)%#ok<INUSD, DEFNU>
function etRangeLow_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etRangeHigh_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmBufIdx_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

% -------- CREATE FUNCTIONS ------- %
function etTrajLabel_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmBufIdx_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etRangeLow_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etRangeHigh_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in bDone.
function bDone_Callback(hObject, eventdata, handles)
% hObject    handle to bDone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
