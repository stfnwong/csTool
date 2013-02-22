function varargout = csToolTrackOpts(varargin)
% CSTOOLTRACKOPTS M-file for csToolTrackOpts.fig
%      CSTOOLTRACKOPTS, by itself, creates a new CSTOOLTRACKOPTS or raises the existing
%      singleton*.
%
%      H = CSTOOLTRACKOPTS returns the handle to a new CSTOOLTRACKOPTS or the handle to
%      the existing singleton*.
%
%      CSTOOLTRACKOPTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLTRACKOPTS.M with the given input arguments.
%
%      CSTOOLTRACKOPTS('Property','Value',...) creates a new CSTOOLTRACKOPTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolTrackOpts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolTrackOpts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolTrackOpts

% Last Modified by GUIDE v2.5 22-Feb-2013 22:18:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolTrackOpts_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolTrackOpts_OutputFcn, ...
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


% --- Executes just before csToolTrackOpts is made visible.
function csToolTrackOpts_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolTrackOpts (see VARARGIN)

	handles.debug = 0;
    %Get segmenter object
    if(length(varargin) < 1)
        error('Expecting handles structure in csToolTrackOpts');
	else
		if(~isa(varargin{1}, 'csTracker'))
            error('Incorrect parameter in csToolTrackOpts (expecting csTracker)');
        else
            handles.tracker = varargin{1};
		end
		if(~isa(varargin{2}, 'struct'))
            error('Incorrect parameter in csToolTrackOpts (expecting options structure)');
        else
            handles.trackopts = varargin{2};
		end
		if(length(varargin) > 2)
			if(strncmpi(varargin{3}, 'debug', 5))
				handles.debug = 1;
			end
		end
    end

    %init_lbTrackMethod(handles);
    %init_editTextBoxes(handles);
	mstr = handles.tracker.methodStr;
    set(handles.lbTrackMethod, 'String', mstr);
    set(handles.lbTrackMethod, 'Value', 1);
    set(handles.etEpsilon,     'String', num2str(handles.trackopts.epsilon));
    set(handles.etThresh,      'String', num2str(handles.trackopts.bpThresh));
    set(handles.etMaxIter,     'String', num2str(handles.trackopts.maxIter));
    set(handles.chkRotMatrix,  'Value',  handles.trackopts.rotMatrix);
    set(handles.chkCordic,     'Value',  handles.trackopts.cordicMode);
    set(handles.chkFixedIter,  'Value',  handles.trackopts.fixedIter);
	
    % Choose default command line output for csToolTrackOpts
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes csToolTrackOpts wait for user response (see UIRESUME)
    uiwait(handles.figTrackOpts);


% --- Outputs from this function are returned to the command line.
function varargout = csToolTrackOpts_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

	if(handles.debug)
		fprintf('Value of handles.output...\n');
		t = handles.output;
		disp(t);
	end
    varargout{1} = handles.output;
	delete(handles.figTrackOpts);

%---------------------------------------------------------------%
%                      LOCAL INITIALISATION                     %
%---------------------------------------------------------------%

%function init_lbTrackMethod(handles)
%function init_editTextBoxes(handles)

%---------------------------------------------------------------%
%                    ACCEPT/CANCEL BUTTON                       %
%---------------------------------------------------------------%

% --- Executes on button press in bAccept.
function bAccept_Callback(hObject, eventdata, handles)  %#ok <INUSL,DEFNU>

    %Collect arguments and init objects
    
    %trackMethod = get(handles.lbTrackMethod, 'String');
    method      = get(handles.lbTrackMethod, 'Value');
    epsilon     = str2double(get(handles.etEpsilon, 'String'));
    if(isnan(epsilon) || isempty(epsilon) || isinf(epsilon))
        error('Incorrect value in epsilon');
    end
    bpThresh    = str2double(get(handles.etThresh, 'String'));
    if(isnan(bpThresh) || isempty(bpThresh) || isinf(bpThresh))
        error('Incorrect value in Backprojection Threshold');
    end
    maxIter     = str2double(get(handles.etMaxIter, 'String'));
    if(isnan(maxIter) || isempty(maxIter) || isinf(maxIter))
        error('Incorrect value in max iter');
    end
    rMat        = get(handles.chkRotMatrix, 'Value');
    cordic      = get(handles.chkCordic, 'Value');
    fixedIter   = get(handles.chkFixedIter, 'Value');

    opts        = struct('method', method, ...
                         'epsilon', epsilon, ...
                         'bpThresh', bpThresh, ...
                         'maxIter', maxIter, ...
                         'rotMatrix', rMat, ...
                         'cordicModic', cordic, ...
                         'fixedIter', fixedIter, ...
                         'verbose', handles.trackopts.verbose, ...
                         'fParams', handles.trackopts.fParams);
    
    handles.tracker = csTracker(opts);
	handles.output  = struct('tracker', handles.tracker, 'trackOpts', opts);
	guidata(hObject, handles);
	%Call close request
	figTrackOpts_CloseRequestFcn(hObject, eventdata, handles);

% --- Executes on button press in bCancel.
function bCancel_Callback(hObject, eventdata, handles) %#ok<DEFNU>

    %disp(handles);
    handles.output = struct('tracker', handles.tracker, 'trackOpts', handles.trackOpts);
	figTrackOpts_CloseRequestFcn(hObject, eventdata, handles);

% --- Executes when user attempts to close figTrackOpts.
function figTrackOpts_CloseRequestFcn(hObject, eventdata, handles)	%#ok<INUSD>

	if(isequal(get(hObject, 'waitstatus'), 'waiting'))
		uiresume(hObject);
	else
		delete(hObject);
	end
	
	
%---------------------------------------------------------------%
%                        CREATE FUNCTIONS                       %
%---------------------------------------------------------------%


% --- Executes during object creation, after setting all properties.
function lbTrackMethod_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function etThresh_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function etMaxIter_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function etEpsilon_CreateFcn(hObject, eventdata, handles)   %#ok<INUSD,DEFNU>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%---------------------------------------------------------------%
%                          EMPTY FUNCTIONS                      %
%---------------------------------------------------------------%

% --- Executes on button press in chkCordic.
function chkCordic_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function etEpsilon_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function etMaxIter_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function etThresh_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

% --- Executes on button press in chkRotMatrix.
function chkRotMatrix_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

% --- Executes on button press in chkFixedIter.
function chkFixedIter_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

% --- Executes on selection change in lbTrackMethod.
function lbTrackMethod_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>



