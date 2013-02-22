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

% Last Modified by GUIDE v2.5 22-Feb-2013 02:22:46


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
	% TODO: FIX THIS
	%Current dummy code for testing imrect selector
	handles.rect.rs = [];
	
	%Parse optional arguments (if any)	
	if(~isempty(varargin))
		for k = 1:length(varargin)
			%Check for objects passed in at load
			if(isa(varargin{k},     'csFrameBuffer'))
				handles.frameBuf  = varargin{k};
				handles.bufOpts   = init_scrapeOpts(handles.frameBuf);
			elseif(isa(varargin{k}, 'csTracker'))
				handles.tracker   = varargin{k};
				handles.trackOpts = init_scrapeOpts(handles.tracker);
			elseif(isa(varargin{k}, 'csSegmenter'))
				handles.segmenter = varargin{k};
				handles.segOpts   = init_scrapeOpts(handles.segmenter);
			%Check for switches
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = 1;
					handles.debug = 1;	%TODO: Clean up this handles.debug member
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
	if(~isfield(handles, 'regionStruct'))
		fprintf('Generating new regionStruct...\n');
		handles.regionStruct = init_genRegionStruct(DATA_DIR, NO_LOAD);
		if(DEBUG)
			fprintf('(DEBUG) regionStruct: \n');
			disp(handles.regionStruct);
		end
	end
	
 	% Choose default command line output for csToolGUI
	handles.output    = hObject;
	% Update handles structure
	guidata(hObject, handles);


	% =============================================================== %
	%                          csTool setup                           %
	% =============================================================== %
	set(gcf, 'Name', 'csTool - CAMSHIFT Simulation Tool');
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
	xlabel(handles.fig_mhistPreview, 'Bin');
	ylabel(handles.fig_mhistPreview, 'Value');
	%Image histogram
	cla(handles.fig_ihistPreview);
	title(handles.fig_ihistPreview, 'Image Histogram');
	xlabel(handles.fig_ihistPreview, 'Bin');
	ylabel(handles.fig_ihistPreview, 'Value');

	%Setup buttons, listboxes, etc
    handles = init_UIElements(handles);
	%handles = init_restoreFrame(handles);
	%Save handles
	guidata(hObject, handles);
    fprintf('Bringing up csTool GUI...\n');
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
	
	[frameIndex handles] = gui_stepPreview(frameIndex, handles, 'b');
	[exitflag handles]   = gui_showPreview(frameIndex, handles);
	if(exitflag == -1)
		return;
	end
	
% 	fh   = handles.frameBuf.getFrameHandle(frameIndex);
%     img  = imread(get(fh, 'filename'), handles.frameBuf.getExt());
% 	dims = size(img);
% 	if(dims(3) > 3)
% 		img = img(:,:,1:3);
% 	end
%     imshow(img, 'parent', handles.fig_framePreview);
% 	gui_setPreviewTitle(get(fh, 'filename'), handles.fig_framePreview);
	
	guidata(hObject, handles);

end 	%bBack_Callback()

% --- Executes on button press in bForward.
function bForward_Callback(hObject, eventdata, handles)  %#ok<INUSL,DEFNU>
	global frameIndex;

	if(frameIndex == 0)
        fprintf('Frame index not set (equal 0)\n');
        return;
	end
	
	[frameIndex handles] = gui_stepPreview(frameIndex, handles, 'f');
	[exitflag handles]   = gui_showPreview(frameIndex, handles);
	if(exitflag == -1)
		return;
	end
	
% 	%bounds check and modify index
% 	if(frameIndex ~= handles.frameBuf.getNumFrames())
% 		frameIndex = frameIndex + 1;
% 	end
%     set(handles.etCurFrame, 'String', num2str(frameIndex));
% 	%Also update preview - if csFrameBrowser doesn't get deprecated,
% 	%use that. Otherwise update directly here
% 	fh   = handles.frameBuf.getFrameHandle(frameIndex);
%     img  = imread(get(fh, 'filename'), handles.frameBuf.getExt());
% 	dims = size(img);
% 	if(dims(3) > 3)
% 		img = img(:,:,1:3);
% 	end
%     imshow(img, 'parent', handles.fig_framePreview);
% 	gui_setPreviewTitle(get(fh, 'filename'), handles.fig_framePreview);
	
	guidata(hObject, handles);

end 	%bForward_Callback()	

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
	
	fh    = handles.frameBuf.getFrameHandle(idx);
	img   = imread(get(fh, 'filename'), handles.frameBuf.getExt());
	dims  = size(img);
	if(dims(3) > 3)
		img = img(:,:,1:3);
	end
	%Set the new frameIndex
    frameIndex = idx;
    set(handles.etCurFrame, 'String', num2str(idx));
    imshow(img, 'parent', handles.fig_framePreview);
    %If there is a bpvec in the current frame handle, show in preview
	bpimg = vec2bpimg(get(fh, 'bpVec'));
	if(numel(bpimg) ~= 0)
        %TODO: fparams call goes here
        imshow(bpimg, 'parent', handles.fig_bpPreview);
	end
	gui_setPreviewTitle(get(fh, 'filename'), handles.fig_framePreview);
	
	guidata(hObject, handles);
	
end		%bGoto_Callback()

% ============================ LOAD ===================================

function bLoad_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% BLOAD_CALLBACK
% Load nFrames from location specified by filename

    global frameIndex;

	if(frameIndex == 0)
		frameIndex = 1;
	end
	filename = get(handles.etFilePath, 'String');
	nFrames  = str2double(get(handles.etNumFrames, 'String'));
	[exitflag nh] = gui_loadFrames(filename, nFrames, handles);
	if(exitflag == -1)
		return;
	end
	handles = nh;
	[exitflag nh] = gui_showPreview(frameIndex, handles);
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
    %Show previews
    bpimg = vec2bpimg(get(fh, 'bpVec'));
    imshow(handles.fig_bpPreview, bpimg);
	
	guidata(hObject, handles);

end 	%bSegFrame_Callback()

% --- Executes on button press in bSegRange.
function bSegRange_Callback(hObject, eventdata, handles)    %#ok<INUSL,DEFNU>
	
	%Pull values out of range boxes
    sFrame = fix(str2double(get(handles.etLowRange, 'String')));
    eFrame = fix(str2double(get(handles.etHighRange, 'String')));
    if(eFrame < sFrame)
        fprintf('ERROR: (SegRange) End frame is before start frame\n');
        return;
    end

    fh = handles.frameBuf.getFrameHandle(sFrame:eFrame);

    for k = 1:length(fh)
        handles.segmenter.segFrame(fh(k));
    end
    %Show preview of final frame
    img   = imread(get(fh(k), 'filename'));
    bpimg = vec2bpimg(get(fh(k)), 'bpVec');
    imshow(handles.figPreview, img);
    imshow(handles.fig_bpPreview, bpimg);
	
	guidata(hObject, handles);
	
end 	%bSegRange_Callback()

function bSegAll_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	%Segment every frame in buffer
	
	for k = 1:handles.frameBuf.getNumFrames()
		fh = handles.frameBuf.getFrameHandle(k);
		handles.segmenter.segFrame(fh);
	end
	
	%Show preview of final frame
	img   = imread(get(fh, 'filename'), handles.frameBuf.getExt());
	bpimg = vec2bpimg(get(fh, 'bpvec'));
	imshow(img, 'parent', handles.fig_framePreview);
	%TODO: fparams call goes here
	imshow(bpimg, 'parent', handles.fig_bpPreview);
	
	guidata(hObject, handles);

end		%bSegAll_Callback()




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


function csToolFigure_WindowButtonDownFcn(hObject, eventdata, handles) %#ok <INUSL>

	%DEBUG:
	fprintf('BUTTON DOWN!\n');

	%Perform hit test
	axHandles = [handles.fig_framePreview handles.fig_bpPreview];
	cPos      = get(hObject, 'CurrentPoint');
	if(handles.debug)
		[hit ah] = gui_axHitTest(axHandles, hObject, cPos, 'd');
	else
		[hit ah] = gui_axHitTest(axHandles, hObject, cPos);
	end
	
	if(hit)
		if(handles.debug)
			fprintf('WINDOWBUTTONDOWNFCN\n');
			fprintf('Button down within region!\n');
		end
		%Check which axes we hit
		imrs = handles.regionStruct;
		imrs.start_point     = cPos;
		imrs.axHandle        = ah;
		handles.regionStruct = imrs;
		%When we hit an axes, draw rectangle on figure
		%xi = cPos(1,1);
		%yi = cPos(2,2);
		%if(~isa(handles.rect.rs, 'imrect') || ~isfield(handles.rect, 'rs'))
		if(~isfield(handles, 'rect'))
			%DEBUG
			fprintf('Creating new rect handle\n');
			rh           = imrect(ah, [cPos(1) cPos(2) 64 64]);
			addNewPositionCallback(rh, @(p) title(mat2str(p, 3)));
			crFcn        = makeConstrainToRectFcn('imrect', get(ah, 'XLim'), get(ah, 'YLim'));
			setPositionConstraintFcn(rh, crFcn);
			%Place into rs struct
			rs.rh        = rh;
			rs.xi        = cPos(1);
			rs.yi        = cPos(2);
			rs.handle    = rh;
			handles.rect = rs;		%Save struct
		else
			%DEBUG
			fprintf('Rect handle exists\n');
		end
	end
	
	guidata(hObject, handles);

end		%csToolFigure_WindowButtonDownFcn()


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function csToolFigure_WindowButtonUpFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	%global frameIndex;
	
	axHandles = [handles.fig_framePreview handles.fig_bpPreview];
	cPos      = get(hObject, 'CurrentPoint');
	if(handles.debug)
		[hit ah] = gui_axHitTest(axHandles, hObject, cPos, 'd');
	else
		[hit ah] = gui_axHitTest(axHandles, hObject, cPos);
	end
	
	if(hit)
		if(handles.debug)
			fprintf('WINDOWBUTTONUPFCN\n');
			fprintf('Button up within region\n');
		end
		%Did we start drawing a rectangle?
		if(isfield(handles, 'rect'))
			r = handles.rect;
			if(isfield(r, 'rh'))
				fprintf('rect.rh exists\n');
			end
			fprintf('rect handle exists\n');
		end	
	end
		
% 		imrs = handles.regionStruct;
% 		if(imrs.axHandle ~= -1)
% 			%if this isn't the same axes, then not a valid operation
% 			if(imrs.axHandle == ah)
% 				imrs.end_point = cPos;
% 				imrs.imRegion  = fix([imrs.start_point ; imrs.end_point]);
% 				if(handles.debug)
% 					fprintf('imRegion:\n');
% 					disp(imrs.imRegion);
% 				end
% 				%Set imRegion in segmenter here
% 				handles.regionStruct = imrs;
% 			end
% 			%delete(handles.rect.rh);
% 			%delete(handles.rect);
% 		else
% 			%Not a valid axes
% 			delete(handles.rect.rh)
% 			rmfield(handles.rect);
% 		end

	%Unset the WindowButtonMotionFcn 
	%set(hObject, 'WindowButtonMotionFcn', '');
	guidata(hObject, handles);

end 	%csToolFigure_WindowButtonUpFcn()

% =============== MOTION FUNCTION ================
function csToolFigure_WindowButtonMotionFcn(hObject, eventdata, handles)	%#ok

	if(isfield(handles, 'rect'))
		%Modify the current imrect handle
		
	end
	
	guidata(hObject, handles);

end		%csToolFigure_WindowButtonMotionFcn()

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

	global frameIndex;
	global DATA_DIR;

	switch eventdata.Character
		case 'l'
			%Load frames with current settings
			if(frameIndex == 0)
				frameIndex = 1;
			end
			filename = get(handles.etFilePath, 'String');
			nFrames  = str2double(get(handles.etNumFrames, 'String'));
			[exitflag nh] = gui_loadFrames(filename, nFrames, handles);
			if(exitflag == -1)
				return;
			end
			handles = nh;
			[exitflag nh] = gui_showPreview(frameIndex, handles);
			if(exitflag == -1)
				return;
			end
			handles = nh;
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
			[exitflag handles]   = gui_showPreview(frameIndex, handles);
			if(exitflag == -1)
				return;
			end
		case 'b'
			%Seek frame backward
			[frameIndex handles] = gui_stepPreview(frameIndex, handles, 'b');
			[exitflag handles]   = gui_showPreview(frameIndex, handles);
			if(exitflag == -1)
				return;
			end
		case 'd'
			%Dump all filenames from frameBuf
			for k = 1:handles.frameBuf.getNumFrames()
				fh = handles.frameBuf.getFrameHandle(k);
				fprintf('fh(%d) filename : %s\n', k, get(fh, 'filename'));
			end
		case 'R'
			%Select rectangle as imRegion
			if(isfield(handles, 'rect'))
				fprintf('Deleting rect handle\n');
				%Be paranoid about structure field check in case a
				%parameter fails to initialise correctly in the callback
				r = handles.rect;
				if(isfield(r, 'rh'))
					delete(handles.rect.rh);
				else
					fprintf('WARNING: No rh field in handles.rect\n');
				end
				handles = rmfield(handles, 'rect');
				set(hObject, 'WindowButtonMotionFcn', '');
			else
				%DEBUG
				fprintf('No rect field in handles struct\n');
			end
		case 'r'
			if(isfield(handles, 'rect'))
				%Get data from imrect, then clear field
				rPos = fix(getPosition(handles.rect));
				fprintf('imRegion is set as :\n');
				disp(rPos);
				handles.segmenter.setImRegion(rPos);
				delete(handles.rect);
				handles = rmfield(handes.rect);
			else
				%Set a new imrect
				fprintf('Setting new imrect object...\n');
				bounds = [get(handles.fig_framePreview, 'XLim') ...
						  get(handles.fig_framePreview, 'YLim')];
				rh  = imrect(handles.fig_framePreview, [bounds(1)/2 bounds(2)/2 64 64]);
				addNewPositionCallback(rh, @(p) title(mat2str(p,3)));
				fcn = makeConstrainToRectFcn('imrect', bounds(1), bounds(2));
				setPositionConstraintFcn(rh, fcn);
				handles.rect = rh;
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
	handles.segmenter.setVerbose(state);
	handles.tracker.setVerbose(state);
	handles.frameBuf.setVerbose(state);
% 	if(state)
% 		handles.segmenter.setVerbose(1);
% 		handles.tracker.setVerbose(1);
% 	else
% 		handles.segmenter.setVerbose(0);
% 		handles.tracker.setVerbose(0);
% 	end

end     %chkVerbose_Callback()

% --------------------------------------------------------------------
function menu_FileSave_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	
	fprintf('Saving state...\n');
	csToolSaveState(handles);
	fprintf('...done\n');
	
end     %menu_FileSave_Callback()

% --- Executes on button press in bSegOpts.
function bSegOpts_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	if(handles.debug)
		ss = csToolSegOpts(handles.segmenter, handles.segOpts, 'debug');
	else
		ss = csToolSegOpts(handles.segmenter, handles.segOpts);
	end
	if(~isa(ss, 'struct'))
		fprintf('WARNING: csToolSegOpts returned non-struct output\n');
		return;
	end
	%Update handles and UI elements
	handles.segmenter = ss.segmenter;
	handles.segOpts   = ss.segOpts;
	set(handles.segMethodList, 'Value', segOpts.method);
	guidata(hObject, handles);

end     %bSegOpts_Callback()

% --- Executes on button press in bTrackOpts.
function bTrackOpts_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	if(handles.debug)
		ts = csToolTrackOpts(handles.tracker, handles.trackOpts, 'debug');
	else
		ts = csToolTrackOpts(handles.tracker, handles.trackOpts);
	end
	if(~isa(ts, 'struct'))
		fprintf('WARNING: csToolTrackOpts returned non-struct output\n');
		return;
	end
	%Update handles and UI elements
	handles.tracker   = ts.tracker;
	handles.trackOpts = ts.trackOpts;
	set(handles.trackMethodList, 'Value', trackOpts.method);
	guidata(hObject, handles);
	

end     %bTrackOpts_Callback()

% --------------------------------------------------------------------
function menu_Debug_Callback(hObject, eventdata, handles) %#ok <INUSD,DEFNU>
% hObject    handle to menu_Debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end     %menu_Debug_Callback()

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
function etFilePath_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
end     %etFilePath_Callback()
function etGoto_Callback(hObject, eventdata, handles)		%#ok<INUSD,DEFNU>
end		%etGoto_Callback()
function etCurFrame_Callback(hObject, eventdata, handles)	%#ok>INUSD,DEFNU>
end     %etCurFrame_Callback()



