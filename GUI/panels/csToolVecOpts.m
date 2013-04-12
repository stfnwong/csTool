function varargout = csToolVecOpts(varargin)
% CSTOOLVECOPTS M-file for csToolVecOpts.fig
%      CSTOOLVECOPTS, by itself, creates a new CSTOOLVECOPTS or raises the existing
%      singleton*.
%
%      H = CSTOOLVECOPTS returns the handle to a new CSTOOLVECOPTS or the handle to
%      the existing singleton*.
%
%      CSTOOLVECOPTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLVECOPTS.M with the given input arguments.
%
%      CSTOOLVECOPTS('Property','Value',...) creates a new CSTOOLVECOPTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolVecOpts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolVecOpts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolVecOpts

% Last Modified by GUIDE v2.5 07-Mar-2013 16:29:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolVecOpts_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolVecOpts_OutputFcn, ...
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


% --- Executes just before csToolVecOpts is made visible.
function csToolVecOpts_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>


	handles.debug = 0;
	
	if(isempty(varargin))
		fprintf('ERROR: Not enough arguments in csToolVecOpts, exiting...\n');
		handles.output = [];
		delete(hObject);
		return;
	else
		if(~isa(varargin{1}, 'struct'))
			fprintf('ERROR: Expecting options structure in csToolVecOpts, exiting...\n');
			handles.output = [];
			delete(hObject);
			return;
		end
		handles.vecopts = varargin{1};
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
	
	%Populate GUI
	if(~exist('mstr', 'var'))
		fprintf('WARNING: No method string in csToolVecOpts!\n');
		mstr = {'m1', 'm2', 'm3'};
	end
	vOpts = handles.vecopts;
	set(handles.pmVecFmt,    'String', mstr);
	set(handles.etDataSz,    'String', num2str(vOpts.dataSz));
	set(handles.etWfilename, 'String', vOpts.wfilename);
	set(handles.etRfilename, 'String', vOpts.rfilename);
    set(handles.chkAutoGen,  'Value',  vOpts.autoGen);
    set(handles.chkVerbose,  'Value',  vOpts.chkVerbose);
	set(handles.etDestDir,   'String', vOpts.destDir);
	%Set the pop-up menu to have the current selection
	
	
	handles.output = vOpts;		%set to input so cancel won't change anything
	% Update handles structure and wait on input
	guidata(hObject, handles);
	uiwait(handles.figVecOpts);


% --- Outputs from this function are returned to the command line.
function varargout = csToolVecOpts_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

	varargout{1} = handles.output;
	delete(handles.figVecOpts);
	
	
function bAccept_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	%Pull settings from GUI and create vecOpts struct
	dataSz = fix(str2double(get(handles.etDataSz, 'String')));
	if(isnan(dataSz) || isempty(dataSz) || isinf(dataSz))
		dataSz = 256;
		set(handles.etDataSz, 'String', '256');
	end
	errorTol  = str2double(get(handles.etErrorTol, 'String'));
	if(isnan(errorTol) || isempty(errorTol) || isinf(errorTol))
		errorTol = 0;
		set(handles.etErrorTol, 'String', '0');
	end
	%index into pmVecFmt and get string
	idx       = get(handles.pmVecFmt, 'Value');
	fmtStr    = get(handles.pmVecFmt, 'String');
	bpvecFmt  = fmtStr{idx};
	wfilename = get(handles.etWfilename, 'String');
	rfilename = get(handles.etRfilename, 'String');
	destDir   = get(handles.etDestDir,   'String');
    autoGen   = get(handles.chkAutoGen, 'Value');
    verbose   = get(handles.chkVerbose, 'Value');
	
	opts = struct('wfilename', wfilename, ...
		          'rfilename', rfilename, ...
				  'destDir'  , destDir,   ...
				  'vecdata'  , handles.vecopts.vecdata, ...
				  'vfParams' , handles.vecopts.vfParams, ...
				  'bpvecFmt' , bpvecFmt, ...
				  'errorTol' , errorTol, ...
				  'dataSz'   , dataSz,   ...
                  'autoGen'  , autoGen,  ...
				  'verbose'  , verbose );
	handles.output = opts;
	guidata(hObject, handles);
	uiresume(handles.figVecOpts);

function bCancel_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>
	%Exit without saving changes
	handles.output = handles.vecopts;
	uiresume(handles.figVecOpts);

function pmVecFmt_Callback(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>

%---------------------------------------------------------------%
%                         CREATE FUNCTIONS                      %
%---------------------------------------------------------------%

function etWfilename_CreateFcn(hObject, eventdata, handles)		%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etRfilename_CreateFcn(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etDestDir_CreateFcn(hObject, eventdata, handles) 	%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etErrorTol_CreateFcn(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
	
function etDataSz_CreateFcn(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmVecFmt_CreateFcn(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

	
%---------------------------------------------------------------%
%                          EMPTY FUNCTIONS                      %
%---------------------------------------------------------------%
function etRfilename_Callback(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
function etWfilename_Callback(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
function etDataSz_Callback(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
function etErrorTol_Callback(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
function etDestDir_Callback(hObject, eventdata, handles)	%#ok<INUSD,DEFNU>
function chkVerbose_Callback(hObject, eventdata, handles)   %#ok<INUSD,DEFNU>
function chkAutoGen_Callback(hObject, eventdata, handles)   %#ok<INUSD,DEFNU>


