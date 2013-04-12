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

% Last Modified by GUIDE v2.5 05-Apr-2013 03:34:54

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

	if(isempty(varargin))
		fprintf('ERROR: Incorrect input arguments to csToolTrackOpts\n');
		handles.output = [];
		close(hObject);
		return;
	else
		if(~isa(varargin{1}, 'struct'))
			fprintf('ERROR: Expecting trackOpts structure in csToolTrackOpts\n');
			handles.output = [];
			close(hObject);
			return;
		end
		handles.trackopts = varargin{1};
		if(length(varargin) > 1)
			for k = 2:length(varargin)
				if(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = 1;
				elseif(strncmpi(varargin{k}, 'mstr', 4))
					mstr = varargin{k+1};
				end
			end
		end
	end
	tOpts = handles.trackopts;
    set(handles.lbTrackMethod, 'String', mstr);
    set(handles.lbTrackMethod, 'Value', 1);
    set(handles.etEpsilon,     'String', num2str(tOpts.epsilon));
    set(handles.etThresh,      'String', num2str(tOpts.bpThresh));
    set(handles.etMaxIter,     'String', num2str(tOpts.maxIter));
    set(handles.etSparseFac,   'String', num2str(tOpts.sparseFac));
    set(handles.chkRotMatrix,  'Value',  tOpts.rotMatrix);
    set(handles.chkCordic,     'Value',  tOpts.cordicMode);
	set(handles.chkVerbose,    'Value',  tOpts.verbose);
    set(handles.chkFixedIter,  'Value',  tOpts.fixedIter);
	%Set window size methods
	set(handles.pmWinMethod,   'String', {'Zero Moment', 'Eigenvector length'});
	handles.output = tOpts;			%default output

    guidata(hObject, handles);
    uiwait(handles.figTrackOpts);


% --- Outputs from this function are returned to the command line.
function varargout = csToolTrackOpts_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

    varargout{1} = handles.output;
	delete(hObject);

%---------------------------------------------------------------%
%                    ACCEPT/CANCEL BUTTON                       %
%---------------------------------------------------------------%

% --- Executes on button press in bAccept.
function bAccept_Callback(hObject, eventdata, handles)  %#ok <INUSL,DEFNU>

    %Collect arguments and init objects
	tOpts = handles.trackopts;
    
    %trackMethod = get(handles.lbTrackMethod, 'String');
    method      = get(handles.lbTrackMethod, 'Value');
    epsilon     = str2double(get(handles.etEpsilon, 'String'));
	if(isnan(epsilon) || isinf(epsilon) || isempty(epsilon))
		epsilon = 0;
		set(handles.etEpsilon, 'String', num2str(epsilon));
	end
    bpThresh    = str2double(get(handles.etThresh, 'String'));
    if(isnan(bpThresh) || isempty(bpThresh) || isinf(bpThresh))
        bpThresh = 0;
		set(handles.etThresh, 'String', num2str(bpThresh));
    end
    maxIter     = str2double(get(handles.etMaxIter, 'String'));
    if(isnan(maxIter) || isempty(maxIter) || isinf(maxIter))
        maxIter = 16;
		set(handles.etMaxIter, 'String', num2str(maxIter));
    end
    sparseFac   = str2double(get(handles.etSparseFac, 'String'));
    %Check values - legal values are 32, 16, 8, 4, 2, 1
    rMat        = get(handles.chkRotMatrix, 'Value');
    cordic      = get(handles.chkCordic, 'Value');
    fixedIter   = get(handles.chkFixedIter, 'Value');
	verbose     = get(handles.chkVerbose, 'Value');
	wsizeMethod = get(handles.pmWinMethod, 'Value');
    

    opts        = struct('method', method, ...
                         'epsilon', epsilon, ...
                         'bpThresh', bpThresh, ...
                         'maxIter', maxIter, ...
                         'rotMatrix', rMat, ...
                         'cordicMode', cordic, ...
                         'fixedIter', fixedIter, ...
                         'verbose', verbose, ...
                         'fParams', tOpts.fParams, ...
                         'sparseFac', sparseFac, ...
                         'wsizeMethod', wsizeMethod);
	handles.output  = opts;
	guidata(hObject, handles);
	uiresume(handles.figTrackOpts);
	
% --- Executes on button press in bCancel.
function bCancel_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    %disp(handles);
    %handles.output = handles.trackopts;
	uiresume(handles.figTrackOpts);
	%close(hObject);

% --- Executes when user attempts to close figTrackOpts.
function figTrackOpts_CloseRequestFcn(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	uiresume(handles.figTrackOpts);
	delete(handles.figTrackOpts);
	
	
function bPrintParams_Callback(hObject, eventdata, handles)	 %#ok<INUSL,DEFNU>

	%Print frame parameters in console
	fprintf('Current frame parameters :\n');
	tOpts  = handles.trackopts;
	params = tOpts.fParams;
	if(isempty(params))
		fprintf('Current no params set (empty)\n');
	else
		fprintf('xc    : %d\n', params(1));
		fprintf('yc    : %d\n', params(2));
		fprintf('theta : %d\n', params(3));
		fprintf('axmaj : %d\n', params(4));
		fprintf('axmin : %d\n', params(5));
	end
	
	
	
	
	
%---------------------------------------------------------------%
%                        CREATE FUNCTIONS                       %
%---------------------------------------------------------------%

function lbTrackMethod_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etThresh_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etMaxIter_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
	end

function etEpsilon_CreateFcn(hObject, eventdata, handles)   %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function etSparseFac_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%---------------------------------------------------------------%
%                          EMPTY FUNCTIONS                      %
%---------------------------------------------------------------%

function chkVerbose_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkCordic_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etEpsilon_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etMaxIter_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etThresh_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkRotMatrix_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkFixedIter_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function lbTrackMethod_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etSparseFac_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>


% --- Executes on selection change in pmWinMethod.
function pmWinMethod_Callback(hObject, eventdata, handles)
% hObject    handle to pmWinMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmWinMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmWinMethod


% --- Executes during object creation, after setting all properties.
function pmWinMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmWinMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
