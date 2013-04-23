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

% Last Modified by GUIDE v2.5 05-Mar-2013 00:05:56

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
% CSTOOLSEGIOPTS_OPENINGFCN
% Start the csToolSegOpts GUI panel. 
%
% USAGE:
% ss = csToolSegOpts(segOpts)
% 
% ARGUMENTS
% segOpts   - Segmenter options structure containing setup for 
%
% OUTPUTS:
% ss        - Structure containing new csSegmenter options
%

% Stefan Wong 2013

	handles.debug = 0;

	if(isempty(varargin))
		fprintf('ERROR: incorrect input arguments to csToolSegOpts\n');
		handles.output = [];
		close(hObject);
		return;
	else
		if(~isa(varargin{1}, 'struct'))
			fprintf('ERROR: Expecting segOpts structure in csToolSegOpts\n');
			handles.output = [];
			close(hObject);
			return;
		end
		handles.segopts = varargin{1};
		if(length(varargin) > 1)
			for k = 2:length(varargin)
				if(strncmpi(varargin{k}, 'mstr', 4))
					mstr = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = 1;
				end
			end
		end
	end
    
    %Populate list
	sOpts = handles.segopts;
	if(~exist('mstr', 'var'))
		fprintf('WARNING: No method string !\n');
		mstr = {'m1', 'm2', 'm3'};
	end
    set(handles.lbSegMethod, 'String', mstr);
    set(handles.lbSegMethod, 'Value', 1);
    %Place current settings into editable text boxes
    set(handles.etBlkSz, 'String', num2str(sOpts.blkSz));
    set(handles.etDataSz, 'String', num2str(sOpts.dataSz));
    set(handles.etNBins, 'String', num2str(sOpts.nBins));
    %This if/else construction is an attempt to suppress the 'checkbonx
    %control requires a scalar value' warning
    if(sOpts.verbose)
        set(handles.chkVerbose, 'Value', 1);
    else
        set(handles.chkVerbose, 'Value', 0);
    end
    %Also set checkbox
    if(sOpts.fpgaMode)
        set(handles.chkFPGA, 'Value', 1);
    else
        set(handles.chkFPGA, 'Value', 0);
    end
    %set(handles.chkFPGA, 'Value', sOpts.fpgaMode);

    % Choose default command line output for csToolSegOpts
    handles.output = sOpts;
    guidata(hObject, handles);
    % UIWAIT makes csToolSegOpts wait for user response (see UIRESUME)
    uiwait(hObject);

% --- Outputs from this function are returned to the command line.
function varargout = csToolSegOpts_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

    varargout{1} = handles.output;
	delete(handles.figSegOpts);


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
	verbose   = get(handles.chkVerbose, 'Value');

    %Do any parameter massaging (ie: converting from cell array), copy mhist
	%from old parameters, copy mhist
	%from old parameters
	opts      = struct('blkSz',     blkSz, ...
                       'dataSz',    dataSz, ...
                       'nBins',     nBins, ...
                       'fpgaMode', fpgaMode, ...
                       'method',    segMethod, ...
                       'verbose',   verbose, ...
                       'imRegion',  handles.segopts.imRegion, ...
					   'mhist',     handles.segopts.mhist);
	if(handles.debug)
		%Show opts in console
		fprintf('Curent options structure: \n');
		disp(opts);
	end

    %handles.segmenter = csSegmenter(opts);
	handles.output    = opts;
	guidata(hObject, handles);
	uiresume(handles.figSegOpts);
    
% --- Executes on button press in bCancel.
function bCancel_Callback(hObject, eventdata, handles)   %#ok <INUSL>
    %Exit GUI without saving changes
	handles.output = handles.segopts;
	uiresume(handles.figSegOpts);

% --- Executes when user attempts to close figSegOpts.
function figSegOpts_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	uiresume(handles.figSegOpts);
	delete(handles.figSegOpts);
	
	
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


function lbSegMethod_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
function chkFPGA_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
function etBlkSz_Callback(hObject, eventdata, handles)   %#ok<INUSD,DEFNU>
function etDataSz_Callback(hObject, eventdata, handles)     %#ok<INUSD,DEFNU>
function etNBins_Callback(hObject, eventdata, handles)  %#ok <INUSD,DEFNU>
function chkVerbose_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

