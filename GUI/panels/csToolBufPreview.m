function varargout = csToolBufPreview(varargin)
% CSTOOLBUFPREVIEW M-file for csToolBufPreview.fig
%      CSTOOLBUFPREVIEW, by itself, creates a new CSTOOLBUFPREVIEW or raises the existing
%      singleton*.
%
%      H = CSTOOLBUFPREVIEW returns the handle to a new CSTOOLBUFPREVIEW or the handle to
%      the existing singleton*.
%
%      CSTOOLBUFPREVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLBUFPREVIEW.M with the given input arguments.
%
%      CSTOOLBUFPREVIEW('Property','Value',...) creates a new CSTOOLBUFPREVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolBufPreview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolBufPreview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolBufPreview

% Last Modified by GUIDE v2.5 25-Nov-2013 02:23:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolBufPreview_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolBufPreview_OutputFcn, ...
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


function csToolBufPreview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolBufPreview (see VARARGIN)

	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(isa('csFrameBuffer', varargin{k}))
				handles.frameBuf = varargin{k};
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'idx', 3))
					handles.idx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'lfile', 5))
					handles.loadFilename = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'sfile', 5))
					handles.saveFilename = varargin{k+1};
				end
			end
		end
	end

	% Check what we have
	if(~isfield(handles, 'frameBuf'))
		fprintf('ERROR: no csFrameBuffer specified, exiting\n');
		handles.output = -1;
		return;
	end
	if(~isfield(handles, 'idx'))
		handles.idx = 1;
	end
	if(~isfield(handles, 'loadFilename'))
		handles.loadFilename = 'loadfile.mat';
	end
	if(~isfield(handles, 'saveFilename'))
		handles.saveFilename = 'savefile.mat';
	end

	% TODO : Correctly initialised all parameters

	% Populate GUI elements
	set(handles.etGoto,     'String', '1');
	set(handles.etCurrent,  'String', num2str(handles.idx));
	set(handles.etSaveLow,  'String', '1');
	set(handles.etSaveHigh, 'String', num2str(handles.frameBuf.getNumFrames()));	

	set(handles.etLoadLow,  'String', '1');
	set(handles.etLoadHigh, 'String', num2str(handles.frameBuf.getNumFrames()))

	% Set file paths
	set(handles.etLoadFilename, 'String', handles.loadFilename);
	set(handles.etSaveFilename, 'String', handles.saveFilename);

	% Setup figure
	set(handles.figPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.figPreview, 'YTick', [], 'YTickLabel', []);

	% Show preview of current frame index
	img = handles.frameBuf.getCurImg(handles.idx);
	imshow(img, 'Parent', handles.figPreview);

	% Choose default command line output for csToolBufPreview
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);

	% UIWAIT makes csToolBufPreview wait for user response (see UIRESUME)
	% uiwait(handles.csToolBufPreview);


function varargout = csToolBufPreview_OutputFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	varargout{1} = handles.output;















function bSave_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

	lr = fix(str2double(get(handles.etSaveLow,  'String')));
	hr = fix(str2double(get(handles.etSaveHigh, 'String')));
	if(lr < 1)
		lr = 1;
	end
	if(hr > handles.frameBuf.getNumFrames())
		hr = handles.frameBuf.getNumFrames();
	end

	range = [lr hr];
	%filename = get(handles.etSaveFilename, 'String');
	handles.frameBuf = handles.frameBuf.saveBufData(range);

	guidata(hObject, handles);
	uiresume(csToolBufPreview);

function bSaveFile_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	% TODO : Add a uigetfile here








function bLoad_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	
	







function bLoadFile_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	% TODO : Add a uigetfile here


% ======== TRANSPORT PANEL ======== %

function bPrev_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	handles.idx = handles.idx - 1;
	if(handles.idx < 1)
		handles.idx = 1;
	end
	img = handles.frameBuf.getCurImg(handles.idx);
	imshow(img, 'Parent', handles.figPreview);
	title(handles.figPreview, sprintf('Frame %d', handles.idx));

	guidata(hObject, handles);
	uiresume(csToolBufPreview);


function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	handles.idx = handles.idx + 1;
	if(handles.idx > handles.frameBuf.getNumFrames())
		handles.idx = handles.framBuf.getNumFrames();
	end
	img = handles.frameBuf.getCurImg(handles.idx);
	imshow(img, 'Parent', handles.figPreview);
	title(handles.figPreview, sprintf('Frame %d', handles.idx));
	
	guidata(hObject, handles);
	uiresume(csToolBufPreview);


function bGoto_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	idx = fix(str2double(get(handles.etGoto, 'String')));
	if(isempty(idx) || isnan(idx))
		fprintf('Invalid idx\n');
		return;
	end
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames())
		idx = handles.frameBuf.getNumFrames();
	end

	handles.idx = idx;
	img = handles.frameBuf.getCurImg(handles.idx);
	imshow(img, 'Parent', handles.figPreview);
	title(handles.figPreview, sprintf('Frame %d', handles.idx));

	guidata(hObject, handles);
	uiresume(csToolBufPreview);













% ======== EMPTY FUNCTIONS ======== %
function etGoto_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

function etCurrent_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etLoadFilename_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etSaveFilename_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etSaveLow_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etSaveHigh_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etLoadLow_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etLoadHigh_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

% ======== CREATE FUNCTIONS ======== %


function etLoadFilename_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etLoadLow_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etCurrent_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end


function etLoadHigh_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end


function etGoto_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etSaveLow_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etSaveFilename_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etSaveHigh_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
