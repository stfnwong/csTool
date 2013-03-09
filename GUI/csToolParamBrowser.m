function varargout = csToolParamBrowser(varargin)
% CSTOOLPARAMBROWSER M-file for csToolParamBrowser.fig
%      CSTOOLPARAMBROWSER, by itself, creates a new CSTOOLPARAMBROWSER or raises the existing
%      singleton*.
%
%      H = CSTOOLPARAMBROWSER returns the handle to a new CSTOOLPARAMBROWSER or the handle to
%      the existing singleton*.
%
%      CSTOOLPARAMBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLPARAMBROWSER.M with the given input arguments.
%
%      CSTOOLPARAMBROWSER('Property','Value',...) creates a new CSTOOLPARAMBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolParamBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolParamBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolParamBrowser

% Last Modified by GUIDE v2.5 09-Mar-2013 20:58:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolParamBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolParamBrowser_OutputFcn, ...
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


% --- Executes just before csToolParamBrowser is made visible.
function csToolParamBrowser_OpeningFcn(hObject, eventdata, handles, varargin)	%#ok<INUSL>

	handles.debug = false;
	handles.status = 0;

	%Parse optional parameters (if any)
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'fb', 2))
					handles.frameBuf = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'idx', 3))
					handles.idx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = true;
				end
			end
		end
	end
	
	%Make sure we have required args
	if(~isfield(handles, 'frameBuf'))
		fprintf('ERROR: No frameBuf field specified\n');
		return;
	end
	if(~isfield(handles, 'idx'))
		fprintf('ERROR: No frame index field specified\n');
		return;
	end
	handles.param = 1;		%This could also be read from GUI I suppose...

	handles.output = hObject;
	guidata(hObject, handles);

	uiwait(handles.csToolParamBrowser);


% --- Outputs from this function are returned to the command line.
function varargout = csToolParamBrowser_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

	varargout{1} = handles.idx;
	varargout{2} = handles.status;
	delete(handles.csToolParamBrowser);


function bPrevFrame_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx - 1;
	%silently clip index to within range
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames())
		idx = handles.frameBuf.getNumFrames();
	end
	handles.idx = idx;
	guidata(hObject, handles);
	

	uiresume(handles.csToolParamBrowser);

function bNextFrame_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx + 1;
	%silently clip index to within range
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames())
		idx = handles.frameBuf.getNumFrames();
	end
	handles.idx = idx;
	guidata(hObject,handles);

	uiresume(handles.csToolParamBrowser);
	
function bPrevParam_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx;
	%Bonuds check idx
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames());
		idx = handles.frameBuf.getNumFrames();
	end
	fh    = handles.frameBuf.getFrameHandle(idx);
	N     = get(fh, 'nIters');
	pidx  = handles.param - 1;
	%Bounds check parameter index
	if(pidx < 1)
		pidx = 1;
	end
	if(pidx > N)
		pidx = N;
	end
	[status pstr] = gui_printParams(fh, 'iter', pidx, 'sup');
	if(status == -1)
		return;
	end
	set(handles.tParamText, 'String', pstr);
	handles.param = pidx;
	guidata(hObject, handles);
	
	uiresume(handles.csToolParamBrowser);


function bNextParam_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx;
	%Bonuds check idx
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames());
		idx = handles.frameBuf.getNumFrames();
	end
	fh    = handles.frameBuf.getFrameHandle(idx);
	N     = get(fh, 'nIters');
	pidx  = handles.param + 1;
	%Bounds check parameter index
	if(pidx < 1)
		pidx = 1;
	end
	if(pidx > N)
		pidx = N;
	end
	[status pstr] = gui_printParams(fh, 'iter', pidx, 'sup');
	if(status == -1)
		return;
	end
	set(handles.tParamText, 'String', pstr);
	handles.param = pidx;
	guidata(hObject, handles);
	
	uiresume(handles.csToolParamBrowser);

function bDone_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	uiresume(handles.csToolParamBrowser);
	delete(handles.csToolParamBrowser);


function csToolParamBrowser_CloseRequestFcn(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	uiresume(handles.csToolParamBrowser);
	delete(hObject);




