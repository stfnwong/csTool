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

% Last Modified by GUIDE v2.5 20-May-2013 21:10:34

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
				elseif(strncmpi(varargin{k}, 'idx', 3))
					handles.fbIdx = varargin{k+1};
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

	%Place a frame on the preview region
	fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
	gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);

    handles.output = hObject;
	guidata(hObject, handles);

	% UIWAIT makes csToolTrajBuf wait for user response (see UIRESUME)
	uiwait(handles.fig_trajBuf);


% --- Outputs from this function are returned to the command line.
function varargout = csToolTrajBuf_OutputFcn(hObject, eventdata, handles) %#ok<INUSL> 
	handles.output = struct('vecManager', handles.vecManager, ...
                            'frameBuf',   handles.frameBuf);
	varargout{1} = handles.output;
	delete(hObject);

% -------- RENDERING FUNCTIONS -------- %
function gui_renderPreview(axHandle, fh, idx, varargin)
	% Render the main preview screen (trajectory rendered seperately)
	%img = imread(get(fh, 'filename'), get(fh, 'ext'));
	if(~isempty(varargin))
		prevMode = varargin{1};
	else
		prevMode = 'normal';
	end

    img = imread(get(fh, 'filename'), 'TIFF');
	dims = size(img);
	if(dims(3) > 3)
		img = img(:,:,1:3);
	end
	if(strncmpi(prevMode, 'bp', 2))
		%Show backprojection
		bpimg = vec2bpimg(get(fh, 'bpData'), get(fh, 'dims'));
		imshow(bpimg, 'Parent', axHandle);
	else
		imshow(img, 'Parent', axHandle);
	end
	[ef fname num] = fname_parse(get(fh, 'filename'));
	if(ef == -1)
		return;
	end
	title(axHandle, sprintf('frame %d (%s_%d)', idx, fname, num));

function gui_renderErrorPlot(axHandle, traj, idx, varargin)
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
			t = traj{1};
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
	%guidata(hObject, handles);


function gui_renderTraj(axHandle, traj, idx)
	% Place the trajectory traj on the axes axHandle highlighting index idx
	
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
	hold(axHandle, 'on');
	ph = plot(axHandle, traj(1,:), traj(2,:), 'v-'); 	%main trajectory
	set(ph, 'Color', [0 1 0], 'MarkerSize', 10, 'LineWidth', 2);
	ih = plot(axHandle, t(1,idx), t(2,idx), 'x');		%index point
	set(ih, 'Color', [1 0 0], 'MarkerSize', 14, 'LineWidth', 4);
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

function gui_renderText(pErr, pTraj) %#ok<DEFNU>
	% Update the textbox with trajectory information

function gui_updateTrajlist(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	% Update the trajectory listbox whenver labels are changed or the buffer 
	% is resized

function gui_updatePreview(axHandle, fh, idx, traja, trajb)
	%Pass all 3 axes handles here to save having really long lines at the caller
	if(length(axHandle) < 3)
		fprintf('ERROR: Pass in all axes handles in the following order\n');
		fprintf('axHandle(1) : fig_trajPreview\n');
		fprintf('axHandle(2) : fig_trajErrorX\n');
		fprintf('axHandle(3) : fig_trajErrorY\n');
	end
	%Update the fig_trajPreview axes
	gui_renderPreview(axHandle(1), fh, idx);
	gui_renderTraj(axHandle(1), traja, idx);
	gui_renderTraj(axHandle(1), trajb, idx);
	%Update the error plots
	t  = {traja, trajb};
	gui_renderErrorPlot([axHandle(1) axHandle(2)], t, idx);
	

% -------- CALLBACK FUNCTIONS -------- %

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Bounds check and increment frame index
	N = handles.frameBuf.getNumFrames();
	if(handles.fbIdx < N)
		handles.fbIdx = handles.fbIdx + 1;
		fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
		%gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
		ah = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
		ta = handles.trajBuf;
		tb = handles.compBuf;
		gui_updatePreview(ah, fh, handles.fbIdx, ta, tb);
	else
		handles.fbIdx = N;
	end
	guidata(hObject, handles);
	uiresume(handles.fig_trajBuf);

function bPrev_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Bounds check and decrement frame index
	if(handles.fbIdx > 1)
		handles.fbIdx = handles.fbIdx - 1;
		fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
		%gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
		ah = [handles.fig_trajPreview handles.fig_trajErrorX handles.fig_trajErrorY];
		ta = handles.trajBuf;
		tb = handles.compBuf;
		gui_updatePreview(ah, fh, handles.fbIdx, ta, tb);
	else
		handles.fbIdx = 1;
	end
	guidata(hObject, handles);
	uiresume(handles.fig_trajBuf);

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
	uiresume(handles.fig_trajBuf);

function bRead_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Reading data out of the vecManager trajectory buffer causes the csToolTrajBuf 
	% local tracjectory buffer to be overwritten with its contents
	traj = handles.vecManager.readTrajBuf(handles.fbIdx);
	handles.trajBuf = traj;
	%Also update the gui
	%gui_updatePreview()
	
	guidata(hObject, handles);
	uiresume(handles.fig_trajBuf);

function bTrajExtract_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Extract current trajectory from frame buffer
	lRange = str2double(get(handles.etRangeLow, 'String'));
	hRange = str2double(get(handles.etRangeHigh, 'String'));
	range  = [lRange hRange];
	handles.trajBuf = handles.frameBuf.getTraj(range);

	% Also show trajectory in preview
	gui_renderTraj(handles.fig_trajPreview, handles.trajBuf);

	guidata(hObject, handles);
	uiresume(handles.fig_trajBuf);

function bSetLabel_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Write just the label into the vecManager object
	label = get(handles.etTrajLabel, 'String');
	idx   = get(handles.pmBufIdx, 'Value');
	handles.vecManager = handles.vecManager.writeTrajBufLabel(idx, label);	
	if(handles.debug)
		fprintf('Wrote label [%s] to index (%d)\n', label, idx);
	end
	guidata(hObject, handles);
	uiresume(handles.fig_trajBuf);

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
	fh             = handles.frameBuf.getFrameHandle(handles.fbIdx);
	handles.errBuf = abs(traja - trajb);
	gui_renderPreview(handles.fig_trajPreview, fh, handles.fbIdx);
	gui_renderTraj(handles.fig_trajPreview, traja, handles.fbIdx);
	gui_renderTraj(handles.fig_trajPreview, trajb, handles.fbIdx);
	%Save current selection to trajectory buffer
	handles.trajBuf = traja;
	handles.compBuf = trajb;
		
	guidata(hObject, handles);
	uiresume(handles.fig_trajBuf);



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
	uiresume(handles.fig_trajBuf);

function menu_formSubplot_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Create a new figure with all data plotted for use in papers, reports, etc
	
	fPrev  = figure('Name', 'Trajectory Results');
	fErr   = figure('Name', 'Trajectory Error');
	axPrev = axes('Parent', fPrev);
	axErr  = axes('Parent', fErr);
	
	
	guidata(hObject, handles);
	uiresume(handles.fig_trajBuf);



% ---- UNUSED CALLBACKS ---- %
function etTrajLabel_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etRangeLow_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etRangeHigh_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmBufIdx_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function bDone_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmCompIdx_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function chkCompCur_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function menu_Buffer_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etTrackingStats_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function menu_data_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>


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

function etTrackingStats_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
