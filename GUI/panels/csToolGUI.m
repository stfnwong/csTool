function varargout = csToolGUI(varargin)
% csToolGUI M-file for csToolGUI.fig
%      csToolGUI, by itself, creates a new csToolGUI or raises the existing
%      singleton*.
%
%      H = csToolGUI returns the handle to a new csToolGUI or the handle to
%      the existing singleton*.
%
%      csToolGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in csToolGUI.M with the given input arguments.
%
%      csToolGUI('Property','Value',...) creates a new csToolGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the csToolGUI before csToolGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolGUI_OpeningFcn via varargin.
%
%      *See csToolGUI Options on GUIDE's Tools menu.  Choose "csToolGUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolGUI

% Last Modified by GUIDE v2.5 22-Mar-2014 00:30:21


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolGUI_OutputFcn, ...
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

end     %csToolGUI()


% =============================================================== %
%                       OPENING FUNCTION                          %
% =============================================================== %
% --- Executes just before csToolGUI is made visible.
function csToolGUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolGUI (see VARARGIN)

	global frameIndex;
	global DATA_DIR;
	global ASSET_DIR;
	global DEBUG;
	%initial values of globals
	DATA_DIR    = 'data/settings';
	ASSET_DIR   = 'data/assets/frames'; 
	DEBUG       = 0;
	handles.debug = 0;			%TODO: Clean up this handles.debug member

	
    fprintf('Initialising csTool GUI....\n');
	
	%Parse optional arguments (if any)	
	if(~isempty(varargin))
		for k = 1:length(varargin)
			%Check for objects passed in at load
			if(isa(varargin{k},     'csFrameBuffer'))
				handles.frameBuf   = varargin{k};
				handles.bufOpts    = handles.frameBuf.getOpts();
			elseif(isa(varargin{k}, 'csTracker'))
				handles.tracker    = varargin{k};
				handles.trackOpts  = handles.tracker.getOpts();
			elseif(isa(varargin{k}, 'csSegmenter'))
				handles.segmenter  = varargin{k};
				handles.segOpts    = handles.segmenter.getOpts();
			elseif(isa(varargin{k}, 'vecManager'))
				handles.vecManager = varargin{k};
				handles.vecOpts    = handles.vecManager.getOpts();
			%Check for switches
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = 1;
					handles.debug = 1;
				elseif(strncmpi(varargin{k}, 'noload', 6))
					force_no_load = 1;
				else
					fprintf('Unknown switch %s, ignoring...\n', varargin{k});
				end
			end
		end
	end

	%Check if there are any global preferences from a previous session that we might
	%want to honour - eg, not loading other prefs, not buffering images, etc
	path = which(sprintf('%s/sessionvars.mat', DATA_DIR));
	if(isempty(path))
		%Use defaults
		NO_LOAD = 0;
	else
		svars = load(path);
		if(isfield(svars, 'noLoad'))
			NO_LOAD = svars.noLoad;			%TODO: Temporary - clean up
		else
			NO_LOAD = 0;
		end
	end	
	
	%TODO: Clean up this mechanism
	if(exist('force_no_load', 'var'))
		NO_LOAD = 1;
	end

	%Check which objects have been created, and init new ones if needed
	if(~isfield(handles, 'frameBuf'))
		fprintf('Generating new frame buffer...\n');
		handles.bufOpts   = init_genBufferOpts(DATA_DIR, ASSET_DIR, NO_LOAD);
		handles.frameBuf  = csFrameBuffer(handles.bufOpts);
		if(DEBUG)
			fprintf('(DEBUG) Buffer options: \n');
			disp(handles.bufOpts);
		end
	end
	if(~isfield(handles, 'tracker'))
		fprintf('Generating new tracker...\n');
		handles.trackOpts = init_genTrackerOpts(DATA_DIR, NO_LOAD);
		handles.tracker   = csTracker(handles.trackOpts);
		if(DEBUG)
			fprintf('(DEBUG) Tracker options: \n');
			disp(handles.trackOpts);
		end
	end
	if(~isfield(handles, 'segmenter'))
		fprintf('Generating new segmenter...\n');
		handles.segOpts   = init_genSegmenterOpts(DATA_DIR, NO_LOAD);
		handles.segmenter = csSegmenter(handles.segOpts);
		if(DEBUG)
			fprintf('(DEBUG) Segmenter options: \n');
			disp(handles.segOpts);
		end
	end
	if(~isfield(handles, 'vecManager'))
		fprintf('Generating new vecManager...\n');
		handles.vecOpts    = init_genVecManagerOpts(DATA_DIR, NO_LOAD);
		handles.vecManager = vecManager(handles.vecOpts);
		if(DEBUG)
			fprintf('(DEBUG) vecManager options: \n');
			disp(handles.vecOpts);
		end
	end
	if(~isfield(handles, 'testBuf'))
		fprintf('Generating test buffer...\n');
		handles.testBufOpts = init_genTestBufOpts(DATA_DIR, ASSET_DIR, NO_LOAD);
		handles.testBuf = csFrameBuffer(handles.testBufOpts);
		if(DEBUG)
			fprintf('(DEBUG) Test buffer options: \n');
			disp(handles.testBufOpts);
		end
	end

    % Load region structure 
    handles.rData = init_genRegionStruct(DATA_DIR, NO_LOAD);

	% =============================================================== %
	%                       Status and Settings                       %
	% =============================================================== %

	%Create structure for handling imregion
	p = struct('paramIndex', 1);
	handles.pData = p;		%param data
	%Hold default figure name as a property
	handles.csToolFigName = 'csTool - CAMSHIFT Simulation Tool';

	% Create or load previous options structure for sub-GUIs	
	handles.vfOpts = init_genVfOpts(DATA_DIR, NO_LOAD);
	handles.pvOpts = init_genPvOpts(DATA_DIR, NO_LOAD);
	handles.sqOpts = init_genSqOpts(DATA_DIR, NO_LOAD);
	handles.sbOpts = init_genSbOpts(DATA_DIR, NO_LOAD);
	if(DEBUG)
		fprintf('vfOpts : \n');
		disp(handles.vfOpts);
		fprintf('pvOpts :\n');
		disp(handles.pvOpts);
		fprintf('sqOpts :\n');
		disp(handles.sqOpts);
	end
    handles = init_UIElements(handles);

	% Create structure to store filenames
	fnameStruct     = struct('genPath', ' ', 'loadPath', ' ');
	handles.fnames  = fnameStruct;
	
	% =============================================================== %
	%                          csTool setup                           %
	% =============================================================== %
	set(gcf, 'Name', handles.csToolFigName);
	set(gcf, 'Units', 'Pixels');
	%Setup axes
	cla(handles.fig_framePreview);
	set(handles.fig_framePreview, 'XTick', [], 'XTickLabel', []);
	set(handles.fig_framePreview, 'YTick', [], 'YTickLabel', []);
	set(handles.fig_framePreview, 'Units', 'Pixels');
	%set(handles.fig_framePreview, 'Title', 'Frame Preview');
	title(handles.fig_framePreview, 'Frame Preview');
	
	cla(handles.fig_bpPreview);
	set(handles.fig_bpPreview,    'XTick', [], 'XTickLabel', []);
	set(handles.fig_bpPreview,    'YTick', [], 'YTickLabel', []);
	set(handles.fig_bpPreview,    'Units', 'Pixels');
	%set(handles.fig_bpPreview,    'Title', 'Backprojection Preview');
	title(handles.fig_bpPreview, 'Backprojection Preview');
	
	%Model histogram
	cla(handles.fig_mhistPreview);
	title(handles.fig_mhistPreview, 'Model Histogram');
	%xlabel(handles.fig_mhistPreview, 'Bin');
    xlabel(handles.fig_mhistPreview, []);
	ylabel(handles.fig_mhistPreview, 'Value');
	%Image histogram
	%cla(handles.fig_ihistPreview);
	%title(handles.fig_ihistPreview, 'Image Histogram');
	%xlabel(handles.fig_ihistPreview, 'Bin');
    %xlabel(handles.fig_ihistPreview, []);
	%ylabel(handles.fig_ihistPreview, 'Value');

	%Setup buttons, listboxes, etc

    %Setup window parameter text
    set(handles.etParam, 'Max', 6);
    set(handles.etParam, 'FontSize', 8);
    set(handles.etParam, 'HorizontalAlignment', 'left');
	%handles = init_restoreFrame(handles);
    fprintf('Bringing up csTool GUI...\n');
	%Try to load the previous frameIndex - this should be moved into init_UIElements
	% or another method that loads frame data from previous session
	path = which(sprintf('%s/svars.mat', DATA_DIR));
	if(isempty(path))
		frameIndex = 1;
	else
		load(path);
		frameIndex = svars.index;
	end
    fprintf('frameIndex is %d\n', frameIndex);
    set(handles.etCurFrame, 'String', num2str(frameIndex));
	
	if(handles.debug)
		fprintf('Units for figure (%s) : %s\n', get(gcf, 'Name'), get(gcf, 'Units'));
		fprintf('Units for axes (%s) : %s\n', get(handles.fig_framePreview, 'Title'), get(handles.fig_framePreview, 'Units'));
		fprintf('Units for axes (%s) : %s\n', get(handles.fig_bpPreview, 'Title'), get(handles.fig_bpPreview, 'Units'));
	end
	%Make sure frameIndex is something
	if(frameIndex == 0) 
		frameIndex = 1;
	end
	if(isempty(frameIndex))
		frameIndex = 1;
	end
	set(handles.etCurFrame, 'String', num2str(frameIndex));
	set(handles.etGoto, 'String', '1');
	
 	% Choose default command line output for csToolGUI
	handles.output    = hObject;
	% Update handles structure
	guidata(hObject, handles);
	% UIWAIT makes csToolGUI wait for user response (see UIRESUME)
	% uiwait(handles.csToolFigure);
	
end     %csToolGUI_OpeningFcn()


% =============================================================== %
%                    CLOSE REQUEST FUNCTION                       %
% =============================================================== %

% --- Executes when user attempts to close csToolFigure.
function csToolFigure_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% Automatically call save method before closing figure

	global DATA_DIR;
	global frameIndex;

	csToolSaveState(handles, DATA_DIR, frameIndex);
	delete(hObject);	%close figure

end		%csToolFigure_CloseRequestFcn()

% =============================================================== %
%                        OUTPUT FUNCTION                          %
% =============================================================== %

% --- Outputs from this function are returned to the command line.
function varargout = csToolGUI_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

varargout{1} = handles.output;

end     %csToolGUI_OutputFcn()

% =============================================================== %
%                        TRANSPORT PANEL                          %
% =============================================================== %

% ======================    NAVIGATION     ========================
function bBack_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	global frameIndex;

	if(frameIndex == 0)
        fprintf('Frame index not set (equal 0)\n');
        return;
	end	
	%Initialise the param index to the last param
	fh = handles.frameBuf.getFrameHandle(frameIndex);
	handles.pData.paramIndex = get(fh, 'nIters');
	[frameIndex handles] = gui_stepPreview(frameIndex, handles, 'b');
    if(handles.debug)
        [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex, 'debug');
    else
        [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex);
    end
	if(exitflag == -1)
		return;
	end	
	%[ihist] = gui_genImHist('fh', handles.frameBuf.getFrameHandle(frameIndex),'hsv');
	ihist = gui_genImHist('img', handles.frameBuf.getCurImg(frameIndex), 'hsv');	
	set(fh, 'ihist', ihist);
	if(exitflag == -1)
		return;
	end
	%[exitflag] = gui_setHistograms('ihistAx', handles.fig_ihistPreview, ...
	%	                           'ihist'  , ihist);
	%if(exitflag == -1)
	%	return;
	%end
	guidata(hObject, handles);

end 	%bBack_Callback()


function bForward_Callback(hObject, eventdata, handles)  %#ok<INUSL,DEFNU>
	global frameIndex;

	if(frameIndex == 0)
        fprintf('Frame index not set (equal 0)\n');
        return;
	end	
	%Initialise the param index to the last param
	fh = handles.frameBuf.getFrameHandle(frameIndex);
	handles.pData.paramIndex = get(fh, 'nIters');

	[frameIndex handles] = gui_stepPreview(frameIndex, handles, 'f');
    if(handles.debug)
        [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex, 'debug');
    else
        [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex);
    end
	if(exitflag == -1)
		return;
	end
	%[ihist] = gui_genImHist('fh', handles.frameBuf.getFrameHandle(frameIndex),'hsv');             
	ihist = gui_genImHist('img', handles.frameBuf.getCurImg(frameIndex), 'hsv');
	set(fh, 'ihist', ihist);
	if(exitflag == -1)
		return;
	end
	%[exitflag] = gui_setHistograms('ihistAx', handles.fig_ihistPreview, ...
	%	                           'ihist'  , ihist);
	%if(exitflag == -1)
	%	return;
	%end
	guidata(hObject, handles);

end 	%bForward_Callback()	

function bFrameFirst_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    global frameIndex;
    
    if(handles.debug)
        [exitflag handles] = gui_showPreview(handles, 'idx', 1, 'debug');
    else
        [exitflag handles] = gui_showPreview(handles, 'idx', 1);
    end
    if(exitflag == -1)
        return;
    end
    %[ihist] = gui_genImHist('fh', handles.frameBuf.getFrameHandle(1),'hsv');             
	ihist = gui_genImHist('img', handles.frameBuf.getCurImg(1));
	fh    = handles.frameBuf.getFrameHandle(1);
	set(fh, 'ihist', ihist);
	if(exitflag == -1)
		return;
	end
	%[exitflag] = gui_setHistograms('ihistAx', handles.fig_ihistPreview, ...
	%	                           'ihist'  , ihist);
	%if(exitflag == -1)
	%	return;
	%end
    %Dont forget to set frameIndex and param index
    frameIndex = 1;
	%Initialise the param index to 1
	fh = handles.frameBuf.getFrameHandle(frameIndex);
	handles.pData.paramIndex = get(fh, 'nIters');
    set(handles.etCurFrame, 'String', num2str(frameIndex));
	guidata(hObject, handles);

end     %bFrameFirst_Callback()


function bFrameLast_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    global frameIndex;
    
    N = handles.frameBuf.getNumFrames();
    if(handles.debug)
        [exitflag handles] = gui_showPreview(handles, 'idx', N, 'debug');
    else
        [exitflag handles] = gui_showPreview(handles, 'idx', N);
    end
    if(exitflag == -1)
        return;
    end
    %[ihist] = gui_genImHist('fh', handles.frameBuf.getFrameHandle(N),'hsv');             
	ihist = gui_genImHist('img', handles.frameBuf.getCurImg(N), 'hsv');
	fh    = handles.frameBuf.getFrameHandle(N);
	set(fh, 'ihist', ihist);
	%if(exitflag == -1)
	%	return;
	%end
	%[exitflag] = gui_setHistograms('ihistAx', handles.fig_ihistPreview, ...
	%	                           'ihist'  , ihist);
	%if(exitflag == -1)
	%	return;
	%end
    %Dont forget to set frameIndex and param index
    %Initialise the param index to 1
	fh = handles.frameBuf.getFrameHandle(frameIndex);
	handles.pData.paramIndex = get(fh, 'nIters');
    set(handles.etCurFrame, 'String', num2str(frameIndex));
    frameIndex = N;
	guidata(hObject, handles);

end     %bFrameLast_Callback()

function bGoto_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	global frameIndex;

	%Get the index of the frame to goto
	idx = str2double(get(handles.etGoto, 'String'));
	fmx = handles.frameBuf.getNumFrames();
	if(idx < 1 || idx > fmx)
		fprintf('ERROR: Goto frame outside range\n');
		fprintf('Must be between 1 and %d\n', fmx);
		return;
	end
	
    if(handles.debug)
        [exitflag handles] = gui_showPreview(handles, 'idx', idx, 'debug');
    else
        [exitflag handles] = gui_showPreview(handles, 'idx', idx);
    end
	if(exitflag == -1)
		return;
	end
	[ihist] = gui_genImHist('fh', handles.frameBuf.getFrameHandle(frameIndex), 'hsv');
	if(exitflag == -1)
		return;
	end
	%[exitflag] = gui_setHistograms('ihistAx', handles.fig_ihistPreview, ...
	%	                           'ihist'  , ihist);
	%if(exitflag == -1)
	%	return;
	%end
	%frameIndex = idx;
	%Update GUI
	set(handles.etCurFrame, 'String', num2str(idx));
	
	guidata(hObject, handles);
		
end		%bGoto_Callback()


%Seems intuitive that if you modify the current frame text that the tool
%should navigate to that frame
function etCurFrame_Callback(hObject, eventdata, handles)	%#ok>INUSD,DEFNU>

    global frameIndex;

    idx = str2double(get(hObject, 'String'));
    %Check bounds
    if(idx < 1 || idx > handles.frameBuf.getNumFrames())
        fprintf('ERROR: cannot seek to frame %d, invalid\n', idx);
    else
        frameIndex = idx;
    end
    
    guidata(hObject, handles);

end     %etCurFrame_Callback()

% ============================ LOAD ===================================

function bLoad_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% BLOAD_CALLBACK
% Load nFrames from location specified by filename

    global frameIndex;

	if(frameIndex == 0)
		frameIndex = 1;
	end
	filename  = get(handles.etFilePath, 'String');
	numFrames = fix(str2double(handles.etNumFrames, 'String'));
	[handles.frameBuf ef nf] = handles.frameBuf.loadFrameData(filename, numFrames);
	if(ef == -1)
		return;
	end
	fprintf('Read %d frames into buffer\n', nf);

    %Re-check the frame index - this is caused by an incorrect value for
    %the frameIndex variable being set on startup. Invesigate preferences
    %files for culprit
    if(frameIndex > handles.frameBuf.getNumFrames())
        fprintf('WARNING: frameIndex exceeds buffer size - getting last frame\n');
        frameIndex = handles.frameBuf.getNumFrames() - 1;
    end
	if(handles.debug)
		[exitflag nh] = gui_showPreview(handles, 'idx', frameIndex, 'debug');
	else
		[exitflag nh] = gui_showPreview(handles, 'idx', frameIndex);
	end
	if(exitflag == -1)
		return;
	end
	handles = nh;
	
	guidata(hObject, handles);

end     %bLoad_Callback()

% =========================== SEGMENT ===================================

function bSegFrame_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Call segmentation procedure for this frame only
	global frameIndex;

	fh = handles.frameBuf.getFrameHandle(frameIndex);

    handles.segmenter.segFrame(fh);
    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'fh', fh, 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'fh', fh, 'seg');
    end
	if(status == -1)
		return;
	end
	handles = nh;
	
	guidata(hObject, handles);

end 	%bSegFrame_Callback()

% --- Executes on button press in bSegRange.
function bSegRange_Callback(hObject, eventdata, handles)    %#ok<INUSL,DEFNU>
	
	%Pull values out of range boxes
    sFrame = fix(str2double(get(handles.etLowRange, 'String')));
    eFrame = fix(str2double(get(handles.etHighRange, 'String')));
	if (eFrame < sFrame)
        fprintf('ERROR: (SegRange) End frame is before start frame\n');
        return;
	end
	%Turn off interface during processing
	handles = gui_ifaceEnable(handles, 'off');
	if(handles.debug)
		status = gui_procLoop(handles, 'range', [sFrame eFrame], 'seg', 'debug');
	else
		status = gui_procLoop(handles, 'range', [sFrame eFrame], 'seg');
	end
	if(status == -1)
		%Turn interface back on
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
    %Show preview of final frame
    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'idx', eFrame, 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'idx', eFrame, 'seg');
    end
	if(status == -1)
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	handles = nh;
	%Turn interface back on 
	handles = gui_ifaceEnable(handles, 'on');
	%Check if we want to auto-generate vector files
	if(handles.vecManager.checkAutoGen())
		%Call vecmanager	
	end

	guidata(hObject, handles);
	
end 	%bSegRange_Callback()

function bSegAll_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>
	
	%Turn off interface during processing
	handles = gui_ifaceEnable(handles, 'off');
	if(handles.debug)
		status = gui_procLoop(handles, 'seg', 'debug');
	else
		status = gui_procLoop(handles, 'seg');
	end
	if(status == -1)
		%Turn interface back on 
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end	
	%Show preview of final frame
    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'idx', handles.frameBuf.getNumFrames(), 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'idx', handles.frameBuf.getNumFrames(), 'seg');
    end
	if(status == -1)
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	handles = nh;
	%Turn interface back on 
	handles = gui_ifaceEnable(handles, 'on');
	guidata(hObject, handles);
	
end		%bSegAll_Callback()

% =========================== TRACK ===================================

function bTrackFrame_Callback(hObject, eventdata, handles)  %#ok<INUSL,DEFNU>

    global frameIndex;

    %Try using procloop with a single frame
    handles = gui_ifaceEnable(handles, 'off');
    fh = handles.frameBuf.getFrameHandle(frameIndex);
    handles.tracker.trackFrame(fh);
    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'fh', fh, 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'fh', fh, 'seg');
    end
    if(status == -1)
        %Turn interface back on
        handles = gui_ifaceEnable(handles, 'on');
        guidata(hObject, handles);
        return;
    end
    handles = nh;
    handles = gui_ifaceEnable(handles, 'on');

    guidata(hObject, handles);

end     %bTrackFrame_Callback()

function bTrackRange_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

    %global frameIndex;
    
	%Track selected frames
	sFrame = fix(str2double(get(handles.etLowRange, 'String')));
    eFrame = fix(str2double(get(handles.etHighRange, 'String')));
	if(eFrame < sFrame)
        fprintf('ERROR: (TrackRange) End frame is before start frame\n');
        return;
	end
    %Get tracking window for previous frame
%     if(frameIndex > 1)
%         prevFrame = handles.frameBuf.getFrameHandle(frameIndex - 1);
% 		params    = get(prevFrame, 'winParams');
%         %Also need to check that there is actually segmentation data
%         if(isempty(params{1}) || isequal(params{1}, zeros(1,5)))
%             %Need to get initial params anyway
%             %Probably ought to check here that rData exists and it set, etc
%             [status pParam] = handles.tracker.initWindow('region', handles.rData.rRegion);
%             if(status == -1)
%                 fprintf('Error setting wparam\n');
%                 return;
%             end
%         elseif(get(prevFrame, 'nIters') == 0)
%             [status pParam] = handles.tracker.initWindow('region', handles.rdata.rRegion);
%             if(status == -1)
%                 fprintf('Error settings wparam\n');
%                 return;
%             end
%         else
%             pParam    = params;
%         end
%     end
	%Turn off interface
	range = [sFrame eFrame];		%shorten call
	handles = gui_ifaceEnable(handles, 'off');
	if(handles.debug)
		status = gui_procLoop(handles, 'range', range, 'track', 'debug');
	else
		status = gui_procLoop(handles, 'range', range, 'track');
	end
	if(status == -1)
		%Turn interface back on 
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	
	%Show preview of final frame
    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'idx', eFrame, 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'idx', eFrame, 'seg');
    end
	if(status == -1)
		%Turn interface back on 
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	handles = nh;
	handles = gui_ifaceEnable(handles, 'on');
	guidata(hObject, handles);
	
end		%bTrackRange_Callback()

function bTrackAll_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	%Track every frame in buffer
	handles = gui_ifaceEnable(handles, 'off');
	if(handles.debug)
		status = gui_procLoop(handles, 'track', 'debug');
	else
		status = gui_procLoop(handles, 'track');
	end
	if(status == -1)
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end

	%Show preview of final frame
    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'idx', handles.frameBuf.getNumFrames(), 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'idx', handles.frameBuf.getNumFrames(), 'seg');
    end
	if(status == -1)
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	handles = nh;
	handles = gui_ifaceEnable(handles, 'on');
	guidata(hObject, handles);

end		%bTrackAll_Callback()

% =========================== PROCESS ===================================


function bProcRange_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	global frameIndex;

	%Segment and then track selected frames
	sFrame = fix(str2double(get(handles.etLowRange, 'String')));
    eFrame = fix(str2double(get(handles.etHighRange, 'String')));
	R      = [sFrame eFrame];
	if(eFrame < sFrame)
        fprintf('ERROR: (TrackRange) End frame is before start frame\n');
        return;
	end
	handles = gui_ifaceEnable(handles, 'off');
	if(handles.debug)
		if(handles.rData.rFrame ~= sFrame)
			[ef wparam] = handles.tracker.initWindow('region', handles.rData.rRegion);
			if(ef == -1)
				return;
			end
			status = gui_procLoop(handles, 'range', R, 'param', wparam, 'proc', 'debug');
		else
			status = gui_procLoop(handles, 'range', R, 'proc', 'debug');	
		end
	else
		if(handles.rData.rFrame ~= sFrame)
			[ef wparam] = handles.tracker.initWindow('region', handles.rData.rRegion);
			if(ef == -1)
				return;
			end
			status = gui_procLoop(handles, 'range', R, 'param', wparam, 'proc');
		else
			status = gui_procLoop(handles, 'range', R, 'proc');
		end
	end
	if(status == -1)
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	
	%Show preview of final frame
    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'idx', eFrame, 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'idx', eFrame, 'seg');
    end
	if(status == -1)
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	handles = nh;
	handles = gui_ifaceEnable(handles, 'on');
	guidata(hObject, handles);

end		%bProcRange_Callback()

function bProcAll_Callback(hObject, eventdata, handles)		%#ok<INUSL,DEFNU>
	
	%Segment and then track all frames	
	if(handles.debug)
		status = gui_procLoop(handles, 'proc', 'debug');
	else
		status = gui_procLoop(handles, 'proc');
	end
	if(status == -1)
		return;
	end
	handles = gui_ifaceEnable(handles, 'off');
	%Show preview of final frame
    if(handles.debug)
    	[status nh] = gui_showPreview(handles, 'idx', handles.frameBuf.getNumFrames(), 'seg', 'debug');
    else
        [status nh] = gui_showPreview(handles, 'idx', handles.frameBuf.getNumFrames(), 'seg');
    end
	if(status == -1)
		handles = gui_ifaceEnable(handles, 'on');
		guidata(hObject, handles);
		return;
	end
	handles = nh;
	handles = gui_ifaceEnable(handles, 'on');
	guidata(hObject, handles);

end		%bProcAll_Callback

% =========================== GENERATE ===================================

function bGenerate_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>
	%Call generate gui
	
	global frameIndex;
	mhist = handles.segmenter.getMhist();
	fprintf('Current rRegion data : \n');
	disp(handles.rData.rRegion);
	if(handles.debug)

		status = csToolGenerate(handles.frameBuf, handles.vecManager, 'idx', frameIndex, 'debug', 'mhist', mhist, 'initpos', handles.rData.rPos);
	else	
		status = csToolGenerate(handles.frameBuf, handles.vecManager, 'idx', frameIndex, 'mhist', mhist, 'initpos', handles.rData.rPos);
	end
	if(status == -1)
		return;
	end

end


% =============================================================== %
%                       PARAMETER BROWSER                         %
% =============================================================== %

function bParamPrev_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	global frameIndex;
	
	pidx = handles.pData.paramIndex - 1;
	fh  = handles.frameBuf.getFrameHandle(frameIndex);
	%check range
	if(pidx < 1)
		pidx = 1;
	end
	if(pidx > get(fh, 'nIters'))
		fprintf('Param index out of bounds (overflow), clipped to %d\n', get(fh, 'nIters'));
	end

    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'fh', fh, 'idx', frameIndex, 'param', pidx, 'debug');
    else
        [status nh] = gui_showPreview(handles, 'fh', fh, 'idx', frameIndex, 'param', pidx);
    end
    if(status == -1)
        return;
    end
    handles = nh;

	%status = gui_plotParams(fh, handles.fig_bpPreview, 'iter', idx);
	%if(status == -1)
	%	return;
	%end
	if(get(handles.chkShowTraj, 'Value'));
		tvec = handles.frameBuf.bufGetTraj();
		status = gui_plotTraj(handles.fig_bpPreview, tvec, frameIndex);
		if(status == -1)
			return;
		end
	end
	%Update frame position string
	%paramString = sprintf('Iter : %d / %d', idx, get(fh, 'nIters'));
	%set(handles.etParam, 'String', paramString);
	
	handles.pData.paramIndex = pidx;
	guidata(hObject, handles);

end

function bParamNext_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	global frameIndex;	
	
	pidx = handles.pData.paramIndex + 1;
	fh  = handles.frameBuf.getFrameHandle(frameIndex);
    if(handles.debug)
        fprintf('pData.paramIndex : %d\n', pidx);
    end
	%check range
	if(pidx > get(fh, 'nIters'))
		pidx = get(fh, 'nIters');
	end
	if(pidx > get(fh, 'nIters'))
		fprintf('Param index out of bounds (overflow), clipped to %d\n', get(fh, 'nIters'));
	end

    if(handles.debug)
        [status nh] = gui_showPreview(handles, 'fh', fh, 'idx', frameIndex, 'param', pidx, 'debug');
    else
        [status nh] = gui_showPreview(handles, 'fh', fh, 'idx', frameIndex, 'param', pidx);
    end
    if(status == -1)
        return;
    end
    handles = nh;
	
	%status = gui_plotParams(fh, handles.fig_bpPreview, 'iter', pidx);
	%if(status == -1)
	%	return;
	%end
	if(get(handles.chkShowTraj, 'Value'));
		tvec = handles.frameBuf.bufGetTraj();
		status = gui_plotTraj(handles.fig_bpPreview, tvec, frameIndex);
		if(status == -1)
			return;
		end
	end
	%Update frame position string
	%paramString = sprintf('Iter : %d / %d', idx, get(fh, 'nIters'));
	%set(handles.etParam, 'String', paramString);

	handles.pData.paramIndex = pidx;
	guidata(hObject, handles);
end

function bParamBrowse_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	%Call the parameter browser
	global frameIndex;
	
	if(handles.debug)
		[idx status] = csToolParamBrowser('fb', handles.frameBuf, 'idx', frameIndex, 'debug');
	else
		[idx status] = csToolParamBrowser('fb', handles.frameBuf, 'idx', frameIndex);
	end
	if(status == -1)
		return;
	end
	frameIndex = idx;
	
	guidata(hObject, handles);

end

% =============================================================== %
%                        METHOD SELECTION                         %
% =============================================================== %

% --- Executes on selection change in segMethodList.
function segMethodList_Callback(hObject, eventdata, handles) %#ok <INUSL>

	segMethod = get(handles.segMethodList, 'Value');
	handles.segmenter.setSegMethod(segMethod);
    handles.segOpts.method = segMethod;
	guidata(hObject, handles);

end 	%segMethodList_Callback()


% --- Executes on selection change in trackMethodList.
function trackMethodList_Callback(hObject, eventdata, handles) %#ok <INUSL>

	trackMethod = get(hObject, 'Value');
	handles.tracker.setTrackMethod(trackMethod);
    handles.trackOpts.method = trackMethod;
	guidata(hObject, handles);

end 	%trackMethodList_Callback()


% =============================================================== %
%                  REGION SELECTION CALLBACK                      %
% =============================================================== %

% CURRENTLY MOVED TO KEYHANDLER
% At a later stage, this might be reinstated, however due to MATLAB being
% basically a massive pain, that could be unlikely

function csToolFigure_WindowButtonDownFcn(hObject, eventdata, handles) %#ok <INUSL>

end		%csToolFigure_WindowButtonDownFcn()

function csToolFigure_WindowButtonUpFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

end 	%csToolFigure_WindowButtonUpFcn()


% =============================================================== %
%                      UIELEMENT CALLBACKS                        %
% =============================================================== %


% ================ KEY HANDLER CALLBACK =============== 
function csToolFigure_KeyPressFcn(hObject, eventdata, handles)	%#ok<DEFNU>
% hObject    handle to csToolFigure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

%TODO: Alphabetise these

	global frameIndex;
	global DATA_DIR;

	switch eventdata.Character
		case 'l'
			%Load frames with current settings
			if(frameIndex == 0)
				frameIndex = 1;
			end
            filename  = get(handles.etFilePath, 'String');
			numFrames = fix(str2double(get(handles.etNumFrames, 'String')));
			[handles.frameBuf ef nf] = handles.frameBuf.loadFrameData(filename, numFrames);
			if(ef == -1)
				return;
			end
			if(handles.debug)
				fprintf('Read %d frames into buffer\n', nf);
			end
		case 's'
			if(length(eventdata.Modifier) == 1 && strncmpi(eventdata.Modifier{:}, 'control', 7))
				%Save
				fprintf('Saving current settings....\n');
				csToolSaveState(handles, DATA_DIR, frameIndex);
			else
				%Segment all frames
				fprintf('Segmenting frames 1-%d\n', handles.frameBuf.getNumFrames());
			end
		case 'f'
			%Seek frame forward
			[frameIndex handles] = gui_stepPreview(frameIndex, handles, 'f');
            if(handles.debug)
                [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex, 'debug');
            else
                [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex);
            end
			if(exitflag == -1)
				return;
			end
		case 'b'
			%Seek frame backward
			[frameIndex handles] = gui_stepPreview(frameIndex, handles, 'b');
            if(handles.debug)
                [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex, 'debug');
            else
                [exitflag handles]   = gui_showPreview(handles, 'idx', frameIndex);
            end
			if(exitflag == -1)
				return;
			end
		case 'd'
			%Dump all filenames from frameBuf
			for k = 1:handles.frameBuf.getNumFrames()
				fh = handles.frameBuf.getFrameHandle(k);
				fprintf('fh(%d) filename : %s\n', k, get(fh, 'filename'));
			end
		case 'D'
			%Dump dimensions of current frame
			fh   = handles.frameBuf.getFrameHandle(frameIndex);
			dims = get(fh, 'dims');
			fprintf('Dimension of frame %d : [%d x %d] (file - %s)\n', frameIndex, ...
				                             dims(1), dims(2), get(fh, 'filename'));
		
		% ================ IMREGION SELECTION KEYS ================ %
		case 'r'
			rData = handles.rData;
			if(rData.rExist)
				%Get position and compute axis-space coords, then clear
% 				if(~ishandle(rData.rHandle))
% 					fprintf('ERROR: No data in rData.rHandle\n');
% 					rData.rExist = 0;
% 					%Get rid of handle so we dont get multiple rectangles
% 					delete(rData.rHandle);
% 					handles.rData = rData;
% 					guidata(hObject, handles);
% 					return;
% 				end
				rPos    = getPosition(rData.rHandle);
				%Convert to region
				nRegion = gui_rPos2rRegion(rPos, handles.fig_framePreview);
				rData.rExist = 0;
				rData.rPos = rPos;		%Actually, this requires some massaging first...
				rData.rFrame = str2double(get(handles.etCurFrame, 'String'));
				rData.rRegion = nRegion;
				if(handles.debug)
					fprintf('Current rData :\n');
					disp(rData);
				end
				handles.rData = rData;
				%Set imRegion in segmenter and create model histogram
				[status nh mhist] = init_modelHist(handles, rData.rRegion, frameIndex, 'set');
				if(status == -1)
					return;
				end
				handles = nh;
				%Set initial winparams for tracking
                if(handles.debug)
                    fprintf('Setting initial window region\n');
                    [status wparam] = handles.tracker.initWindow('region', rData.rRegion);
                    if(status == -1)
                        fprintf('ERROR: wparam not correctly set\n');
                    else
                        fprintf('Wparam set as [%d %d %d %d %d]\n', ...
                        wparam(1), wparam(2), wparam(3), wparam(4), wparam(5));
                    end
                else
                    status = handles.tracker.initWindow('region', rData.rRegion);
                    if(status == -1)
                        fprintf('ERROR: wparam not correctly set\n');
                    end
                end
				%Update histogram axes
				%[ihist] = gui_genImHist('fh', handles.frameBuf.getFrameHandle(frameIndex), 'hsv');
				ihist = gui_genImHist('img', handles.frameBuf.getCurImg(frameIndex), 'hsv');
				%ihist = [r g b];
				gui_setHistograms('mhistAx', handles.fig_mhistPreview, ...
					              'mhist', mhist);
				%Restore title
				fh = handles.frameBuf.getFrameHandle(frameIndex);
				title(handles.fig_framePreview, get(fh, 'filename'));
				status = gui_setHistTitle(handles);
				if(status == -1)
					fprintf('Title not correctly set\n');
					return;
				end
                %Everything complete, delete handle
                delete(rData.rHandle);
			else
				%Create new rect
				if(isempty(rData.rPos))
					xl = fix(get(handles.fig_framePreview ,'XLim'));
					xl(xl == 0) = 1;
					yl = fix(get(handles.fig_framePreview, 'YLim'));
					yl(yl == 0) = 1;
					nPos = [((xl(2)/2)-64) ((yl(2)/2)-64) 64 64];
				else
					nPos = rData.rPos;
				end
				%Create new imrect handle and populate rData structure
				rh = imrect(handles.fig_framePreview, nPos);
				addNewPositionCallback(rh, @(p) title(handles.fig_framePreview, mat2str(p,3)));
				crFcn = makeConstrainToRectFcn('imrect', ...
					    get(handles.fig_framePreview, 'XLim'), ...
						get(handles.fig_framePreview, 'YLim'));
				setPositionConstraintFcn(rh, crFcn);
				rData.rExist = 1;
				rData.rHandle = rh;
				handles.rData = rData;
			end
			%What are the values in rData?
			if(handles.debug)
				fprintf('rData struct :\n');
				disp(rData);
			end

			% ================ LAUNCH GENERATE SCREEN ================ %
		case 'g'
			mhist = handles.segmenter.getMhist();
			ef = csToolGenerate(handles.frameBuf, handles.vecManager, 'idx', frameIndex, 'mhist', mhist, 'initpos', handles.rData.rPos);
			if(ef == -1)
				fprintf('ERROR: Error in csToolGenerate()\n');
				return;
			end
			% ================ LAUNCH VERIFY SCREEN ================ %
		case 'v'
			%imsz = handles.frameBuf.getDims(frameIndex);
			% TODO : Add options strucutre
			ef = csToolVerify(handles.vecManager, 'opts', handles.vfOpts, 'frameBuf', handles.frameBuf, 'testBuf', handles.testBuf);
			%ef = csToolVerify('vecManager', handles.vecManager, 'imsz', imsz);
			if(ef == -1)
				fprintf('ERROR: Error in csToolVerify()\n');
				return;
			end
			handles.frameBuf = ef.frameBuf;
			handles.testBuf  = ef.testBuf;
			handles.vfOpts   = ef.vSettings;

            % ================ LAUNCH RANDOM SEQUENCE SCREEN ================ %
		case 'y'
			if(handles.debug)
				sgOpts = csToolSeqGen('genopts', handles.sqOpts, 'debug');
			else
				sgOpts = csToolSeqGen('genopts', handles.sqOpts);
			end
			if(sgOpts.status ~= -1)
                % TODO : Re-write structure names on csToolSeqGen side
				handles.sqOpts  = sgOpts.genOpts;
				handles.frameBuf = sgOpts.frameBuf;
				if(handles.debug)
					fprintf('(DEBUG) : Sequence options\n');
					disp(sgOpts);
					disp(sgOpts.frameBuf);
					disp(sgOpts.genOpts);
				end
			end
            % ================ LAUNCH TRAJECTORY BUFFER ================ %
        case 't'
            if(handles.debug)
                tbstruct = csToolTrajBuf('frameBuf', handles.frameBuf, 'testBuf', handles.testBuf,  handles.vecManager, 'idx', frameIndex, 'debug');
            else
                tbstruct = csToolTrajBuf('frameBuf', handles.frameBuf, 'testBuf', handles.testBuf,  handles.vecManager, 'idx', frameIndex);
            end
            %Check structure fields
            %NOTE: ANOTHER STUPID BUG!!!!
            % Even though we can break here and manually evaluate the fields of the
            % struct in the console, verifying that in fact, vecManager is a field
            % of tbstruct, MATLAB insists in this script that it does not exist and
            % therefore we cannot check that the struct actually did return what we
            % said it would. Therfore, just assume that csToolTrajBuf() got it
            % right (a feat a don't trust MATLAB to acheive) and assign the values
            % directly.
            if(handles.debug)
                fprintf('Writing new frameBuf, vecManager...\n');
            end
            handles.frameBuf   = tbstruct.frameBuf;
            handles.vecManager = tbstruct.vecManager;

            if(handles.debug)
                fprintf('Current vecManager options : \n');
                disp(handles.vecManager.getOpts);
            end

            % ================ LAUNCH BUFFER PREVIEW ================ %
		case 'p'
			prStr = csToolBufPreview(handles.frameBuf, 'opts', handles.pvOpts, 'idx', frameIndex);
			if(prStr.exitflag ~= -1)
				handles.pvOpts = prStr.pvOpts;
				handles.frameBuf   = prStr.frameBuf;
				if(handles.debug)
					fprintf('csToolBufPreview settings :\n');
					disp(handles.pvOpts);
					disp(handles.frameBuf);
				end
			end

        

	end
	
	guidata(hObject, handles);

end		%csToolFigure_KeyPressFcn()

function chkVerbose_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>
% hObject    handle to chkVerbose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkVerbose

	state = get(hObject, 'Value');	
	if(handles.debug)
		fprintf('(DEBUG) verbose value : %d\n', state);
	end
	handles.segmenter.setVerbose(state);
	handles.tracker.setVerbose(state);
	handles.frameBuf.setVerbose(state);
	handles.vecManager.setVerbose(state);

	guidata(hObject, handles);

end     %chkVerbose_Callback()

% --------------------------------------------------------------------
function menu_FileSave_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	
	fprintf('Saving state...\n');
	csToolSaveState(handles);
	fprintf('...done\n');
	
end     %menu_FileSave_Callback()

% =============================================================== %
%                         CALL SUB-GUIS                           %
% =============================================================== %

function bSegOpts_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	sOpts = handles.segmenter.getOpts();
	mstr  = handles.segmenter.methodStr;
	if(handles.debug)
		ss = csToolSegOpts(sOpts, 'mstr', mstr, 'debug');
	else
		ss = csToolSegOpts(sOpts, 'mstr', mstr);
	end
	if(~isa(ss, 'struct'))
		%fprintf('WARNING: csToolSegOpts returned non-struct output\n');
		return;
	end
	%Update handles and UI elements
	handles.segmenter = csSegmenter(ss);
	handles.segOpts   = ss;
	handles.segmenter.genKernelLUT();
	set(handles.segMethodList, 'Value', ss.method);
	guidata(hObject, handles);

         end     %bSegOpts_Callback()

% --- Executes on button press in bTrackOpts.
function bTrackOpts_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	%Update trackOpts with latest struct
	tOpts = handles.tracker.getOpts();
	mstr  = handles.tracker.methodStr;
	if(handles.debug)
		ts = csToolTrackOpts(tOpts, 'mstr', mstr, 'debug');
	else
		ts = csToolTrackOpts(tOpts, 'mstr', mstr);
	end
	if(~isa(ts, 'struct'))
		%fprintf('ERROR: csToolSegOpts returned non-struct output\n');
		return;
	end
	handles.tracker  = csTracker(ts);
	handles.trackOpts = ts;
    if(handles.debug)
        fprintf('DEBUG: trackOpts - \n');
        disp(handles.trackOpts);
    end
	set(handles.trackMethodList, 'Value', ts.method);
	guidata(hObject, handles);
	

end     %bTrackOpts_Callback()

function bVecOpts_Callback(hObject, eventdata, handles)		%#ok<INUSL,DEFNU>

	%Update vecManager with latest struct
	vOpts = handles.vecManager.getOpts();
	mstr  = handles.vecManager.fmtStr;
	if(handles.debug)
		vs = csToolVecOpts(vOpts, 'mstr', mstr, 'debug');
	else
		vs = csToolVecOpts(vOpts, 'mstr', mstr);
	end
	%sanity check
	if(~isa('vs', 'struct'))
		%fprintf('ERROR: csTooVecOpts returned non-struct output\n');
		return;
	end
	handles.vecManager = vecManager(vs);
	handles.vecOpts    = vs;
	
	guidata(hObject, handles);
	
end		%bvecOpts_Callback()

% --------------------------------------------------------------------
function menu_Debug_Callback(hObject, eventdata, handles) %#ok <INUSD,DEFNU>

end     %menu_Debug_Callback()

function menu_DebugFrameStat_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%Print statistics (particuarly segmentation statistics) for the currently
%selected frame

	global frameIndex;
	
	fh = handles.frameBuf.getFrameHandle(frameIndex);
	fprintf('Data for frame %d :\n', frameIndex);
	disp(fh);

end		%menu_DebugFrameStat_Callback

% --------------------------------------------------------------------
function menu_DebugShow_Callback(hObject, eventdata, handles) %#ok <INUSD,DEFNU>
% Show csTool internals in console
        
    fprintf('\nCSTOOL INTERNALS\n');
    disp(handles);
    fprintf('Segmeter options\n');
    segopt = handles.segOpts;
    disp(segopt);
    trackopt = handles.trackOpts;
    fprintf('Tracker options\n');
    disp(trackopt);
    fprintf('Buffer options\n');
    disp(handles.bufOpts);
    fprintf('Objects\n\n');
    fprintf('Tracker\n');
    disp(handles.tracker);
    fprintf('Segmenter\n');
    disp(handles.segmenter);
    fprintf('Buffer\n');
    disp(handles.buffer);

end     %menu_DebugShow_Callback()


function menu_ClearWparam_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>
	%Reset all moment and wparam data in frames
	N  = handles.frameBuf.getNumFrames();
	fh = handles.frameBuf.getFrameHandle(1:N);
	fprintf('Clearing moment and wparam data...\n');
	wb = waitbar(0, sprintf('Clearing param data...'), ...
				'Name', sprintf('Clearing 1 - %d', N), ...
				'CreateCancelBtn', ...
				'setappdata(gcbf, ''canceling'', 1)');
	for k = 1:length(fh)
		if(getappdata(wb, 'canceling'))
			fprintf('Cancelled param clear at frame %d (%d left)\n', k, N-k);
			break;
		end
		waitbar(k/N, wb, sprintf('Clearing param data (%d/%d)...', k, N));
		set(fh(k), 'winParams', zeros(1,5));
		set(fh(k), 'moments', cell(1,1));
		set(fh(k), 'nIters', 0);
	end
	fprintf('...done\n');
	
end

% =============================================================== %
%                       CREATE FUNCTIONS                          %
% =============================================================== %

function etNumFrames_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
	end
end     %etNumFrames_CreateFcn()
function segMethodList_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end 	%segMethodList_CreateFcn()
function trackMethodList_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    	set(hObject,'BackgroundColor','white');
	end
end 	%trackMethodList_CreateFcn()
function etFilePath_CreateFcn(hObject, eventdata, handles) %#ok <INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end     %etFilePath_CreateFcn()
function etLowRange_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
	end
end     %etLowRange_CreateFcn()
function etHighRange_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end     %etHigh_CreateFcn()
function etGoto_CreateFcn(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
end		%etGoto_CreateFcn()
function etCurFrame_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end     %etCurFrame_CreateFcn()

% =============================================================== %
%                       CALLBACK FUNCTIONS                        %
% =============================================================== %

function chkShowTraj_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

end		%chkShowTraj_Callback()

function etNumFrames_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end     %etNumFrames_Callback()
function etHighRange_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end     %etHigh_Callback()
function etLowRange_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end     %etLowRange_Callback()
function menu_File_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end     %menu_File_Callback()
function menu_FileLoad_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end     %menu_FileLoad_Callback()
function menu_Data_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end
function etFilePath_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end     %etFilePath_Callback()
function etGoto_Callback(hObject, eventdata, handles)		%#ok<INUSD,DEFNU>
end		%etGoto_Callback()


function menu_debugShowHandles_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>
	fprintf('Current handles struct contents :\n');
	disp(handles);
end		%menu_debugShowHandles()

function menu_enableHandles_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>
	handles = gui_ifaceEnable(handles, 'on');
	guidata(hObject, handles);

end


% =============================================================== %
%                  SMALL UTILITY FUNCTIONS                        %
% =============================================================== %


% --- Executes on button press in bVerify.
function bVerify_Callback(hObject, eventdata, handles) %#ok <INUSD,DEFNU>
    %TODO: Call the verify panel
    global frameIndex;

	imsz = handles.frameBuf.getDims(frameIndex);
	ef = csToolVerify(handles.vecManager, 'opts', handles.vfOpts, 'frameBuf', handles.frameBuf, 'testBuf', handles.testBuf);
	%if(handles.debug)
	%    ef = csToolVerify('vecManager', handles.vecManager, 'imsz', imsz, 'debug', 'opts', handles.vfOpts);
	%else
	%	ef = csToolVerify('vecManager', handles.vecManager, 'imsz', imsz, 'opts', handles.vfOpts);
	%end
	if(~isstruct(ef) && ef == -1)
		fprintf('ERROR: csToolVerify returned status -1\n');
		return;
	else
		handles.vfOpts   = ef.vfSettings;
		handles.frameBuf = ef.frameBuf;
		handles.testBuf  = ef.testBuf;
        if(handles.debug)
            fprintf('csToolVerify opts:\n');
            disp(ef);
        end
	end

	guidata(hObject, handles);
	
end     %bVerify_Callback()

% --- Executes on button press in chkShowSparse.
function chkShowSparse_Callback(hObject, eventdata, handles) %#ok <INUSD,DEFNU>
end     %chkShowSparse_Callback()

% --------------------------------------------------------------------
function menu_Tracking_Callback(hObject, eventdata, handles) %#ok <INUSL,DEFNU>
end     %menu_Tracking_Callback()

% --------------------------------------------------------------------
function menu_DumpTraj_Callback(hObject, eventdata, handles) %#ok <INUSL,DEFNU>
    %Dump trajectory to file
    %NOTE: At this time, the trajectory is dumped for the range given in
    %the main panel. This menu can (and should) bring up a new panel that
    %gives finer control over the required trajectory

    sFrame = fix(str2double(get(handles.etLowRange, 'String')));
    eFrame = fix(str2double(get(handles.etHighRange, 'String')));
    R      = [sFrame eFrame];

    if(eFrame < sFrame)
        fprintf('ERROR: (TrackRange) End frame is before start frame\n');
        return;
    end
    if(eFrame > handles.frameBuf.getNumFrames())
        fprintf('ERROR: end frame exceeds buffer size\n');
        return;
    end
    handles = gui_ifaceEnable(handles, 'off');
    wb = waitbar(0, 'Dumping Trajectory...');
    
    traj = zeros(2, length(R));
    for k = sFrame:eFrame
        fh        = handles.frameBuf.getFrameHandle(k);
        wparam    = get(fh, 'winParams');
        %Load into traj matrix
        traj(1,k) = wparam(1);
        traj(2,k) = wparam(2);
        waitbar(k/length(R), wb, sprintf('Grabbing frame %d of %d...', k, length(R)));
    end
    delete(wb);
    %Write results to file
    %NOTE: For now, the file is hardcoded. This should be another option
    %added to a panel for this feature

    fp = fopen('data/traj.dat', 'w');
    fprintf('Writing data to file...\n');
    wb = waitbar(0, 'Writing trajectory file...');

    %First row is traj(1,:)
    for k = 1:length(traj)
        fprintf(fp, '%f ', traj(1,k));
        waitbar(k/2*length(traj), wb, sprintf('Writing vector %d of %d...', k, 2*length(traj)));
    end
    fprintf(fp, '\n');
    %Second row is traj(2,:)
    for k = 1:length(traj)
        fprintf(fp, '%f ', traj(2,k));
        waitbar(k+length(traj)/2*length(traj), wb, sprintf('Writing vector %d of %d...', ...
                                                   k, 2*length(traj)));
    end

    %for k = 1:length(traj)
    %    fprintf(fp, '%f, %f\n', traj(1,k), traj(2,k));
    %    waitbar(k/length(traj), wb, sprintf('Writing vector %d of %d...', k, length(traj)));
    %end
    fclose(fp);
    delete(wb);

    handles = gui_ifaceEnable(handles, 'on');

    guidata(hObject, handles);      %Might not need to save this anyway...
    
    
end     %menu_DumpTraj_Callback()

% --------------------------------------------------------------------
function menu_trackOptions_Callback(hObject, eventdata, handles) %#ok <INUSL,DEFNU>
	%Update trackOpts with latest struct
	tOpts = handles.tracker.getOpts();
	mstr  = handles.tracker.methodStr;
	if(handles.debug)
		ts = csToolTrackOpts(tOpts, 'mstr', mstr, 'debug');
	else
		ts = csToolTrackOpts(tOpts, 'mstr', mstr);
	end
	if(~isa(ts, 'struct'))
		%fprintf('ERROR: csToolSegOpts returned non-struct output\n');
		return;
	end
	handles.tracker  = csTracker(ts);
	handles.tracOpts = ts;
	set(handles.trackMethodList, 'Value', ts.method);
	guidata(hObject, handles);
end     %menu_trackOptions_Callback(0


% --- Executes on button press in bUIgetfile.
function bUIgetfile_Callback(hObject, eventdata, handles) %#ok <INUSL,DEFNU>
    %Save the original contents of the text box in case we cancel, or the
    %result returns empty
    oldText = get(handles.etFilePath, 'String');
    [fname path] = uigetfile('*.tif', 'Select image file...');
    if(isempty(fname))
        fname = oldText;
    end
    set(handles.etFilePath, 'String', sprintf('%s%s', path, fname));

    guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over bUIgetfile.
end     %bUIgetfile_Callback()

% function bUIgetfile_ButtonDownFcn(hObject, eventdata, handles) %#ok <INUSL,DEFNU>
%     
% Take result from file browse and place into etFilePath
%     [fname path] = uigetfile('*.tif', 'Select image file...');
%     set(handles.etFilePath, 'String', sprintf('%s%s', path, fname));
% 
%     guidata(hObject, handles);
% 
% end     %bUIgetfile_ButtonDownFcn()


% --------------------------------------------------------------------
function menu_SaveFigures_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Save the currently displayed figures in the main window to disk

    fnamePreview = 'data/figure_preview.tif';
    fnameBpimg   = 'data/bp_img_preview.tif';
    saveas(handles.fig_framePreview, fnamePreview, 'tif');
    saveas(handles.fig_bpPreview, fnameBpimg, 'tif');

end     %menu_SaveFigures_Callback()


% --------------------------------------------------------------------
function menu_launchFigure_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Show the frame preview and backprojection preview in seperate
    %(full-size) figures

    figure('Name', 'Frame Preview');
    %take existing contents of fig_framePreview and place in figure
    figure('Name', 'Backprojection Preview');
    %take existing contents of fig_bpPreview and place in figure
end     %menu_launchFigure_Callback()


% --------------------------------------------------------------------
function menu_trajBuf_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU
    %Launch the trajectory browser (csToolTrajBuf)
    
	global frameIndex;

    if(handles.debug)
        tbstruct = csToolTrajBuf('frameBuf', handles.frameBuf, 'testBuf', handles.testBuf, handles.vecManager, 'idx', frameIndex, 'debug');
    else
        tbstruct = csToolTrajBuf('frameBuf', handles.frameBuf, 'testBuf', handles.testBuf,  handles.vecManager, 'idx', frameIndex);
    end
    %Check structure fields
    %NOTE: ANOTHER STUPID BUG!!!!
    % Even though we can break here and manually evaluate the fields of the
    % struct in the console, verifying that in fact, vecManager is a field
    % of tbstruct, MATLAB insists in this script that it does not exist and
    % therefore we cannot check that the struct actually did return what we
    % said it would. Therfore, just assume that csToolTrajBuf() got it
    % right (a feat a don't trust MATLAB to acheive) and assign the values
    % directly.
    if(handles.debug)
        fprintf('Writing new frameBuf, vecManager...\n');
    end
    handles.frameBuf   = tbstruct.frameBuf;
    handles.vecManager = tbstruct.vecManager;

	if(handles.debug)
		fprintf('Current vecManager options : \n');
		disp(handles.vecManager.getOpts);
	end
    
    guidata(hObject, handles);
end 


% --------------------------------------------------------------------
function menu_Pattern_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	if(handles.debug)
	    ef = csToolPattern(handles.frameBuf, 'debug');
	else
		ef = csToolPattern(handles.frameBuf);
	end
    if(ef == -1)
        fprintf('ERROR: Something went wrong in csToolPattern()\n');
        return;
    end

    guidata(hObject, handles);

end     %menu_Pattern_Callback()


% --------------------------------------------------------------------
function menu_ModelHistogram_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    % Write model histogram to disk
    ef = wrModelHist(handles.frameBuf, 'mhist', handles.segmenter.getMhist());
    if(ef == -1)
        fprintf('Error writing model histogram to disk\n');
        return;
    end

    guidata(hObject, handles);

end     %menu_ModelHistogram()


% --------------------------------------------------------------------
function menu_Generate_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    % Vector generation routines
end     %menu_Generate()


% --------------------------------------------------------------------
function menu_genRandBp_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	% Bring up csToolSeqGen GUI
	if(handles.debug)
		sgOpts = csToolSeqGen('genopts', handles.sqOpts, 'debug');
	else
		sgOpts = csToolSeqGen('genopts', handles.sqOpts);
	end

	if(sgOpts.status ~= -1)
		handles.sqOpts  = sgOpts.genOpts;
		handles.frameBuf = sgOpts.frameBuf;
		if(handles.debug)
			fprintf('(DEBUG) : Sequence options\n');
			disp(sgOpts);
			disp(sgOpts.frameBuf);
			disp(sgOpts.genOpts);
		end
	end

	guidata(hObject, handles);

end     %menu_genRandBp()


% --------------------------------------------------------------------
function menu_SaveBufData_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	global frameIndex;
	sbOpts = csToolSaveBuf(handles.frameBuf, handles.segmenter, 'idx', frameIndex, 'opts', handles.sbOpts);

	if(sbOpts.status == -1)
		% Operation was cancelled
		if(handles.debug)
			fprintf('(DEBUG) : Got cancelled flag in sbOpts\n');
			disp(sbOpts);
			disp(sbOpts.opts);
		end
	else
		handles.sbOpts    = sbOpts.opts;
		handles.frameBuf  = sbOpts.frameBuf;
		handles.segmenter = sbOpts.segmenter;
		if(handles.debug)
			fprintf('sbOpts :\n');
			disp(sbOpts);
		end
	end




end
