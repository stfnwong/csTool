function varargout = csToolSegOpts(varargin)
% CSTOOLSEGOPTS M-file for csToolSegOpts.fig
%      CSTOOLSEGOPTS, by itself, creates a new CSTOOLSEGOPTS or raises the existing
%      singleton*.
%
%      H = CSTOOLSEGOPTS returns the handle to a new CSTOOLSEGOPTS or the handle to
%      the existing singleton*.
%
%      CSTOOLSEGOPTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLSEGOPTS.M with the given input arguments.
%
%      CSTOOLSEGOPTS('Property','Value',...) creates a new CSTOOLSEGOPTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolSegOpts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolSegOpts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolSegOpts

% Last Modified by GUIDE v2.5 03-Feb-2013 01:25:49

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @csToolSegOpts_OpeningFcn, ...
                       'gui_OutputFcn',  @csToolSegOpts_OutputFcn, ...
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


% --- Executes just before csToolSegOpts is made visible.
function csToolSegOpts_OpeningFcn(hObject, eventdata, handles, varargin) %#ok <INUSD>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolSegOpts (see VARARGIN)


    %Need to pass in a handles to csSegmenter and current set of segmenter
    %options.
    if(length(varargin) < 1)
        error('No csSegmenter object in csToolSegOpts');
    else
        fprintf('DEBUG: Passing input params (csToolSegOpts)');
        if(~isa(varargin{1}, 'csSegmenter'))
            error('Incorrect parameter in csToolSegOpts (expecting csSegmenter)');
        else
            handles.segmenter = varargin{1};
        end
        if(~isa(varargin{2}, 'struct'))
            error('Incorrect parameter in csToolSegOpts (expecting options struct)');
        else
            fprintf('DEBUG: segopts:\n');
            disp(varargin{2});
            handles.segopts = varargin{2};
        end
    end

    %DEBUG
    fprintf('csToolSegOpts DEBUG:\n');
    disp(handles);
    %Do any custom initialisation
    init_lbSegMethod(handles);
    init_editTextBoxes(handles);


    % Choose default command line output for csToolSegOpts
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes csToolSegOpts wait for user response (see UIRESUME)
    % uiwait(handles.figSegOpts);


% --- Outputs from this function are returned to the command line.
function varargout = csToolSegOpts_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

    % Get default command line output from handles structure
    varargout{1} = handles.output;


%---------------------------------------------------------------%
%                 OPTIONS PANEL INTIALISATION                   %
%---------------------------------------------------------------%

function init_lbSegMethod(handles)

    %Populate list
    mstr = handles.segmenter.methodStr;
    set(handles.lbSegMethod, 'String', mstr);
    set(handles.lbSegMethod, 'Value', 1);

function init_editTextBoxes(handles)

    %Place current settings into editable text boxes
    set(handles.etBlkSz, 'String', num2str(handles.segopts.blkSz));
    set(handles.etDataSz, 'String', num2str(handles.segopts.dataSz));
    set(handles.etNBins, 'String', num2str(handles.segopts.nBins));
    %Also set checkbox
    if(handles.segopts.fpgaMode)
        set(handles.chkFPGA, 'Value', 1);
    else
        set(handles.chkFPGA, 'Value', 0);
    end
    %set(handles.chkFPGA, 'Value', handles.segopts.fpgaMode);


% --- Executes on button press in bAccept.
function bAccept_Callback(hObject, eventdata, handles)    %#ok <INUSL>

    %Pull settings from GUI, write to csSegmenter handle
    blkSz     = str2double(get(handles.etBlkSz, 'String'));
    if(isnan(blkSz) || isempty(blkSz) || isinf(blkSz))
        error('Incorrect value in block size');
    end
    nBins     = str2double(get(handles.etNBins, 'String'));
    if(isnan(nBins) || isempty(nBins) || isinf(nBins))
        error('Incorrect value in # bins');
    end
    dataSz    = str2double(get(handles.etDataSz, 'String'));
    if(isnan(dataSz) || isempty(dataSz) || isinf(dataSz))
        error('Incorrect value in data size');
    end
    segMethod = get(handles.lbSegMethod, 'Value');
    fpgaMode  = get(handles.chkFPGA, 'Value');

    %Do any parameter massaging (ie: converting from cell array)
	% TODO: How to deal with mhist?
    opts      = struct('blkSz',     blkSz, ...
                       'dataSz',    dataSz, ...
                       'nBins',     nBins, ...
                       'fpgaMode', fpgaMode, ...
                       'method',    segMethod, ...
                       'verbose',   handles.segopts.verbose, ...
                       'imRegion',  handles.segopts.imRegion, ...
					   'mhist',     handles.segopts.mhist);

    handles.segmenter = csSegmenter(opts);
	handles.output    = struct('segmenter', handles.segmenter, 'segOpts', opts);
	guidata(hObject, handles);
    close(handles.figSegOpts);

    
% --- Executes on button press in bCancel.
function bCancel_Callback(hObject, eventdata, handles)   %#ok <INUSL>
    
    %Exit GUI without saving changes
    close(handles.figSegOpts);



%---------------------------------------------------------------%
%                         CREATE FUNCTIONS                      %
%---------------------------------------------------------------%


% --- Executes during object creation, after setting all properties.
function etBlkSz_CreateFcn(hObject, eventdata, handles)  %#ok <INUSL>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function etDataSz_CreateFcn(hObject, eventdata, handles)    %#ok<INUSD,DEFNU>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function etNBins_CreateFcn(hObject, eventdata, handles)    %#ok<INUSD,DEFNU>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes during object creation, after setting all properties.
function lbSegMethod_CreateFcn(hObject, eventdata, handles) %#ok <INUSL>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%---------------------------------------------------------------%
%                          EMPTY FUNCTIONS                      %
%---------------------------------------------------------------%

% --- Executes on selection change in lbSegMethod.
function lbSegMethod_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>

% --- Executes on button press in chkFPGA.
function chkFPGA_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>

function etBlkSz_Callback(hObject, eventdata, handles)   %#ok<INUSD,DEFNU>

function etDataSz_Callback(hObject, eventdata, handles)     %#ok<INUSD,DEFNU>

function etNBins_Callback(hObject, eventdata, handles)  %#ok <INUSD,DEFNU>
