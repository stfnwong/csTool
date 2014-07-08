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

% Last Modified by GUIDE v2.5 07-Jul-2014 14:48:20

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
    % Populate Drop-down menus
    qStr = {'1', '4', '8', '16', '32', '64'};
    set(handles.pmKernelQuant, 'String', qStr);
    switch(sOpts.kQuant)
        case 1
            set(handles.pmKernelQuant, 'Value', 1);
        case 4
            set(handles.pmKernelQuant, 'Value', 2);
        case 8
            set(handles.pmKernelQuant, 'Value', 3);
        case 16
            set(handles.pmKernelQuant, 'Value', 4);
        case 32 
            set(handles.pmKernelQuant, 'Value', 5);
        case 64
            set(handles.pmKernelQuant, 'Value', 6);
        otherwise
            fprintf('Invalid kQuant value [%d], setting to 1\n', sOpts.kQuant);
    end
    sStr = {'1', '2', '4', '8', '16', '32', '64', 'kQuant'};
    set(handles.pmKernelScale, 'String', sStr);
    switch(sOpts.kScale)
        case 1
            set(handles.pmKernelScale, 'Value', 1);
        case 2
            set(handles.pmKernelScale, 'Value', 2);
        case 4
            set(handles.pmKernelScale, 'Value', 3);
        case 8 
            set(handles.pmKernelScale, 'Value', 4);
        case 16
            set(handles.pmKernelScale, 'Value', 5);
        case 32
            set(handles.pmKernelScale, 'Value', 6);
        case 64
            set(handles.pmKernelScale, 'Value', 7);
        otherwise
            set(handles.pmKernelScale, 'Value', 8);
    end
    bStr = {'16', '32', '64', '128', '256'};
    set(handles.pmKernelBandwidth, 'String', bStr);
    switch(sOpts.kBandwidth)
        case 16
            set(handles.pmKernelBandwidth, 'Value', 1);
        case 32
            set(handles.pmKernelBandwidth, 'Value', 2);
        case 64
            set(handles.pmKernelBandwidth, 'Value', 3);
        case 128
            set(handles.pmKernelBandwidth, 'Value', 4);
        case 256
            set(handles.pmKernelBandwidth, 'Value', 5);
        otherwise
            fprintf('Invalid bandwidth [%d], using 32\n',sOpts.kBandwidth);
            set(handles.pmKernelBandwidth, 'Value', 1);
    end
    % NOTE : This parameter should be deprecated after testing
    bdStr = {'1', '4', '8', '16'};
    set(handles.pmBitDepth, 'String', bdStr);
    %Select bit depth from object 
    % TODO : Dont hard-code this if possible
    if(sOpts.bitDepth == 1)
        set(handles.pmBitDepth, 'Value', 1);
    elseif(sOpts.bitDepth == 4)
        set(handles.pmBitDepth, 'Value', 2);
    elseif(sOpts.bitDepth == 8)
        set(handles.pmBitDepth, 'Value', 3);
    elseif(sOpts.bitDepth == 16)
        set(handles.pmBitDepth, 'Value', 4);
    else
        fprintf('ERROR: Unsupported bit depth %d, setting to 1\n', sOpts.bitDepth);
        set(handles.pmBitDepth, 'Value', 1);
    end
    set(handles.lbSegMethod, 'String', mstr);
    set(handles.lbSegMethod, 'Value', sOpts.method);
    %Place current settings into editable text boxes
    set(handles.etBlkSz, 'String', num2str(sOpts.blkSz));
    set(handles.etDataSz, 'String', num2str(sOpts.dataSz));
    set(handles.etNBins, 'String', num2str(sOpts.nBins));
    set(handles.etBPTHRESH, 'String', num2str(sOpts.bpThresh));
    %This if/else construction is an attempt to suppress the 'checkbonx
    %control requires a scalar value' warning
    if(sOpts.verbose == 1)
        fprintf('segOpts.verbose checked\n');
        set(handles.chkVerbose, 'Value', 1);
    else
        set(handles.chkVerbose, 'Value', 0);
    end
    %Also set checkbox
    if(sOpts.fpgaMode == 1)
        fprintf('segOpts.fpgaMode checked\n');
        set(handles.chkFPGA, 'Value', 1);
    else
        set(handles.chkFPGA, 'Value', 0);
    end
    if(sOpts.kWeight == 1)
        fprintf('segOpts.kWeight checked\n');
        set(handles.chkWeight, 'Value', 1);
    else
        set(handles.chkWeight, 'Value', 0);
    end
    %set(handles.chkFPGA, 'Value', sOpts.fpgaMode);

	% Set size value to whatever is in options
	set(handles.etXSize, 'String', num2str(sOpts.winRegion(1)));
	set(handles.etYSize, 'String', num2str(sOpts.winRegion(2)));
	% Set row length
	set(handles.etRowLength, 'String', num2str(sOpts.rowLen));
	set(handles.etMhistThresh, 'String', num2str(sOpts.mhistThresh));

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
    blkSz      = str2double(get(handles.etBlkSz, 'String'));
    if(isnan(blkSz) || isempty(blkSz) || isinf(blkSz))
        error('Incorrect value in block size');
    end
    nBins      = str2double(get(handles.etNBins, 'String'));
    if(isnan(nBins) || isempty(nBins) || isinf(nBins))
        error('Incorrect value in # bins');
    end
    dataSz     = str2double(get(handles.etDataSz, 'String'));
    if(isnan(dataSz) || isempty(dataSz) || isinf(dataSz))
        error('Incorrect value in data size');
    end
    bpThresh   = str2double(get(handles.etBPTHRESH, 'String'));
    % Get bpimg bit depth
    bdSel      = get(handles.pmBitDepth, 'Value');
    bdStr      = get(handles.pmBitDepth, 'String');
    bitDepth   = fix(str2double(bdStr{bdSel}));
    segMethod  = get(handles.lbSegMethod, 'Value');
    fpgaMode   = get(handles.chkFPGA, 'Value');
	verbose    = get(handles.chkVerbose, 'Value');
    
    % Get kernel weighting properties
    kWeight    = get(handles.chkWeight, 'Value');
    
    kbwSel     = get(handles.pmKernelBandwidth, 'Value');
    kbwString  = get(handles.pmKernelBandwidth, 'String');
    kBandwidth = fix(str2double(kbwString{kbwSel}));
    
    kqSel      = get(handles.pmKernelQuant, 'Value');
    kqString   = get(handles.pmKernelQuant, 'String');
    kQuant     = fix(str2double(kqString{kqSel}));
    
    ksSel      = get(handles.pmKernelScale, 'Value');
    ksString   = get(handles.pmKernelScale, 'String');
    if(strncmpi(ksString{ksSel}, 'kQuant', 6))
        kScale = kQuant;
    else
        kScale = fix(str2double(ksString{ksSel}));
    end
    win_x = fix(str2double(get(handles.etXSize, 'String')));
   	win_y = fix(str2double(get(handles.etYSize, 'String')));	
	winRegion = [win_x win_y];
    
	rowLen = fix(str2double(get(handles.etRowLength, 'String')));
	mhistThresh = str2double(get(handles.etMhistThresh, 'String'));

    %Do any parameter massaging (ie: converting from cell array), copy mhist
	%from old parameters, copy mhist
	%from old parameters
	%TODO: BG_WIN_SZ and BG_MODE are not (at time of writing) implemented fully, so 
	%these should be passed the dummy values of 0 for the time being
	opts      = struct('blkSz',     blkSz, ...
                       'dataSz',    dataSz, ...
                       'nBins',     nBins, ...
                       'fpgaMode',  fpgaMode, ...
                       'bpThresh',  bpThresh, ...
		               'mhistThresh', mhistThresh, ...
                       'bitDepth',  bitDepth, ...
		               'rowLen',    rowLen, ...
                       'kBandwidth', kBandwidth, ...
                       'kWeight',    kWeight, ...
                       'kQuant',     kQuant, ...
                       'kScale',     kScale, ...
                       'method',    segMethod, ...
                       'bgMode',    0, ...
                       'bgWinSize', 0, ...
		               'winRegion', winRegion, ...
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

function etBlkSz_CreateFcn(hObject, eventdata, handles)  %#ok <INUSL>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
	end

function etDataSz_CreateFcn(hObject, eventdata, handles)    %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etNBins_CreateFcn(hObject, eventdata, handles)    %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function etBPTHRESH_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pmBitDepth_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function lbSegMethod_CreateFcn(hObject, eventdata, handles) %#ok <INUSL>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function pmKernelQuant_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pmKernelScale_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pmKernelBandwidth_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etYSize_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etXSize_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etRowLength_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etMhistThresh_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
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
function pmBitDepth_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etBPTHRESH_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkWeight_Callback(hObject, eventdata, handles) %#ok>INUSD,DEFNU>
function pmKernelQuant_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmKernelScale_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmKernelBandwidth_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etXSize_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etYSize_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etRowLength_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etMhistThresh_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>



