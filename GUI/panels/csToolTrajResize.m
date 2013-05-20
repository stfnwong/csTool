function varargout = csToolTrajResize(varargin)
% CSTOOLTRAJRESIZE M-file for csToolTrajResize.fig
%      CSTOOLTRAJRESIZE, by itself, creates a new CSTOOLTRAJRESIZE or raises the existing
%      singleton*.
%
%      H = CSTOOLTRAJRESIZE returns the handle to a new CSTOOLTRAJRESIZE or the handle to
%      the existing singleton*.
%
%      CSTOOLTRAJRESIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLTRAJRESIZE.M with the given input arguments.
%
%      CSTOOLTRAJRESIZE('Property','Value',...) creates a new CSTOOLTRAJRESIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolTrajResize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolTrajResize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolTrajResize

% Last Modified by GUIDE v2.5 20-May-2013 13:30:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolTrajResize_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolTrajResize_OutputFcn, ...
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


% --- Executes just before csToolTrajResize is made visible.
function csToolTrajResize_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.debug = false;
	%Need to get a vecManager object from caller, and return a vecManager object
	%to caller
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(isa(varargin{k}, 'vecManager'))
				handles.vecManager= varargin{k};
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = true;
				end
			end
		end
	else
		fprintf('ERROR: csToolTrajResize requires at least vecManager argument\n');
		return;
	end

	if(~isfield(handles, 'vecManager'))
		fprintf('ERROR: No vecManager field in csToolTrajResize.handles\n');
		return;
	end

	%Populate GUI elements
	vmanOpts = handles.vecManager.getOpts();
	set(handles.etBufSize, 'String', num2str(length(vmanOpts.trajBuf)));
	%Show current buffer contents in listbox
	set(handles.lbBufContents, 'String', vmanOpts.trajLabel);	
    %Make warning invisible initially
    set(handles.tWarning, 'Visible', 'off');

	% Choose default command line output for csToolTrajResize
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);

	% UIWAIT makes csToolTrajResize wait for user response (see UIRESUME)
	uiwait(handles.figBufResize);


% --- Outputs from this function are returned to the command line.
function varargout = csToolTrajResize_OutputFcn(hObject, eventdata, handles) 

	if(isfield(handles, 'vecManager'))
		varargout{1} = handles.vecManager;
	else
		varargout{1} = handles.output;
	end
	delete(hObject);

function bResize_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	%Commit the changes and exit
	bufSize = str2double(get(handles.etBufSize, 'String'));
	if(bufSize < 1)
		fprintf('ERROR: Buffer size must be > 0\n');
		return;
	end
	if(get(handles.chkKeep, 'Value'))
		handles.vecManager = handles.vecManager.setTrajBufSize(bufSize, 'keep');
	else
		handles.vecManager = handles.vecManager.setTrajBufSize(bufSize);
	end
	guidata(hObject, handles);
	uiresume(handles.figBufResize);

function bCancel_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	%Exit without making changes
	uiresume(handles.figBufResize);

function etBufSize_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Check the buffer size and display warning
	sz = handles.vecManager.getTrajBufSize();
	b  = str2double(get(handles.etBufSize, 'String'));
	if(b < sz)
		set(handles.tWarning, 'Visible', 'on');
	else
		set(handles.tWarning, 'Visible', 'off');
	end	
	guidata(hObject, handles);
	uiresume(handles.figBufResize);

% -------- UNUSED CALLBACKS ------- %
function chkKeep_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function lbBufContents_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

% -------- CREATE FUNCTIONS -------- %
function etBufSize_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function lbBufContents_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
