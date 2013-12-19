function varargout = csToolSaveBuf(varargin)
% CSTOOLSAVEBUF M-file for csToolSaveBuf.fig
%      CSTOOLSAVEBUF, by itself, creates a new CSTOOLSAVEBUF or raises the existing
%      singleton*.
%
%      H = CSTOOLSAVEBUF returns the handle to a new CSTOOLSAVEBUF or the handle to
%      the existing singleton*.
%
%      CSTOOLSAVEBUF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLSAVEBUF.M with the given input arguments.
%
%      CSTOOLSAVEBUF('Property','Value',...) creates a new CSTOOLSAVEBUF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolSaveBuf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolSaveBuf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolSaveBuf

% Last Modified by GUIDE v2.5 16-Dec-2013 21:54:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolSaveBuf_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolSaveBuf_OutputFcn, ...
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


% --- Executes just before csToolSaveBuf is made visible.
function csToolSaveBuf_OpeningFcn(hObject, eventdata, handles, varargin)%#ok<INUSL>

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(isa(varargin{k}, 'csFrameBuffer'))
				handles.frameBuf = varargin{k};
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'idx', 3))
					handles.idx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'opts', 4))
					handles.opts = varargin{k+1};
				end
			end
		end
	end

	% Check what we have
	if(~isfield(handles, 'frameBuf'))
		fprintf('ERROR: No csFrameBuffer object specified\n');
		handles.output = -1;
		return;
	end
	if(~isfield(handles, 'idx'))
		fprintf('No frame index specified - using 1\n');
		handles.idx = 1;
	end

	% If supplied, transfer options from main GUI
	if(exist('opts', 'var'))
		set(handles.etWriteFile, 'String', opts.writeFile);
		set(handles.etReadFile,  'String', opts.readFile);
	else
		set(handles.etWriteFile, 'String', 'data/bufdata/frame');
		set(handles.etReadFile,  'String', 'data/bufdata/frame');
	end

	% Set up GUI
	set(handles.axBufPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.axBufPreview, 'YTick', [], 'YTickLabel', []);	
	set(handles.etCurFrame,   'String', num2str(handles.idx));
	set(handles.etGoto,       'String', '1');

	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);

	% UIWAIT makes csToolSaveBuf wait for user response (see UIRESUME)
	uiwait(handles.csToolSaveBufFig);


function varargout = csToolSaveBuf_OutputFcn(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	varargout{1} = handles.output;









function bGetWriteFile_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Set write file
	oldPath = get(handles.etWriteFile, 'String');
	[fname path] = uiputfile('*.dat', 'Select file to write pattern to...');
	if(isempty(fname))
		fname = oldPath;
		path  = '';
	end
	set(handles.etWriteFile, 'String', sprintf('%s%s', path, fname));
	guidata(hObject, handles);
	uiresume(handles.csToolSaveBufFig);

function bWrite_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Write file to disk
	
	ps = fname_parse(get(handles.etWriteFile, 'String'));
	if(ps.exitflag == -1)
		fprintf('ERROR: Cant parse filename [%s]\n', get(handles.etWriteFile, 'String'));
		return;
	end
	
	guidata(hObject, handles);
	uiresume(handles.csToolSaveBufFig);

function bGetReadFile_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Set write file
	oldPath = get(handles.etReadFile, 'String');
	[fname path] = uiputfile('*.dat', 'Select file to write pattern to...');
	if(isempty(fname))
		fname = oldPath;
		path  = '';
	end
	set(handles.etReadFile, 'String', sprintf('%s%s', path, fname));
	guidata(hObject, handles);
	uiresume(handles.csToolSaveBufFig);


function bRead_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Create a new csFrameBuffer object and read data into it from disk
	
	guidata(hObject, handles);
	uiresume(handles.csToolSaveBufFig);

function bPrev_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	
	handles.idx = handles.idx - 1;
	if(handles.idx < 1)
		handles.idx = 1;
	end
	% Update GUI preview
	img = handles.frameBuf.getCurImg(handles.idx);
	imshow(img, 'Parent', handles.axBufPreview);

	guidata(hObject, handles);
	uiresume(handles.csToolSaveBufFig);

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	handles.idx = handles.idx + 1;
	if(handles.idx > handles.frameBuf.getNumFrames())
		handles.idx = handles.frameBuf.getNumFrames();
	end
	% Update GUI preview
	img = handles.frameBuf.getCurImg(handles.idx);
	imshow(img, 'Parent', handles.axBufPreview);

	guidata(hObject, handles);
	uiresume(handles.csToolSaveBufFig);

function bGoto_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	
	handles.idx = fix(str2double(get(handles.etGoto, 'String')));
	if(handles.idx < 1)
		handles.idx = 1;
	end
	if(handles.idx > handles.frameBuf.getNumFrames())
		handles.idx = handles.frameBuf.getNumFrames();
	end
	
	% Update GUI preview
	img = handles.frameBuf.getCurImg(handles.idx);
	imshow(img, 'Parent', handles.axBufPreview);

	guidata(hObject, handles);
	uiresume(handles.csToolSaveBufFig);








% ======== CREATE FUNCTIONS ======== %

function etReadFile_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etWriteFile_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etCurFrame_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etGoto_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

% ======== EMPTY FUNCTIONS ======== %

function etGoto_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etCurFrame_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etReadFile_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etWriteFile_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
