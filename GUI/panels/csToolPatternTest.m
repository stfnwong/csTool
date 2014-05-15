function varargout = csToolPatternTest(varargin)
% CSTOOLPATTERNTEST M-file for csToolPatternTest.fig
%      CSTOOLPATTERNTEST, by itself, creates a new CSTOOLPATTERNTEST or raises the existing
%      singleton*.
%
%      H = CSTOOLPATTERNTEST returns the handle to a new CSTOOLPATTERNTEST or the handle to
%      the existing singleton*.
%
%      CSTOOLPATTERNTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLPATTERNTEST.M with the given input arguments.
%
%      CSTOOLPATTERNTEST('Property','Value',...) creates a new CSTOOLPATTERNTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolPatternTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolPatternTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolPatternTest

% Last Modified by GUIDE v2.5 16-May-2014 02:26:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolPatternTest_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolPatternTest_OutputFcn, ...
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


% --- Executes just before csToolPatternTest is made visible.
function csToolPatternTest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolPatternTest (see VARARGIN)

	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'opts', 4))
					handles.patternOpts = varargin{k+1};
				end
			end
		end
	else
		fprintf('ERROR: Not enough arguments in call to csToolPatternTest(\n');
		handles.output = -1;
		return;
	end

	% Check what we have
	if(~isfield(handles, 'patternOpts'))
		fprintf('ERROR: No options structure available\n');
		handles.output = -1;
		return;
	end

	% Populate GUI elements
	% set pmImType values
	imgTypeStr = {'Column', 'Row'};
	set(handles.pmImType, 'String', imgTypeStr);
	
	% Take values from options and place on GUI
	opts = handles.patternOpts; 	%alias to shorten code
	set(handles.etNumBins,   'String', num2str(opts.numBins));
	set(handles.etBinWidth,  'String', num2str(opts.binWidth));
	set(handles.etImgWidth,  'String', num2str(opts.dims(1)));
	set(handles.etImgHeight, 'String', num2str(opts.dims(2)));

	% Setup preview window based on preview mode
	set(handles.axPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.axPreview, 'YTick', [], 'YTickLabel', []);
	title(handles.axPreview, 'Preview');
	%if(strcmpi(opts.previewMode, 'test', 4))
	%	set(handles.
	%else
	%	set(handles.axPreview, 'XTick', [], 'XTickLabel', []);
	%	set(handles.axPreview, 'YTick', [], 'YTickLabel', []);
	%end



	% Choose default command line output for csToolPatternTest
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);

	% UIWAIT makes csToolPatternTest wait for user response (see UIRESUME)
	uiwait(handles.csToolPatternFig);


function varargout = csToolPatternTest_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


function csToolPatternFig_CloseRequestFcn(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
    if(isequal(get(hObject, 'waitstatus'), 'waiting'))
        %Still waiting on GUI
        uiresume(handles.csToolVerifyFig);
    else
        %Ok to clean up
        delete(handles.csToolVerifyFig);
    end

function bDone_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	close(handles.csTooPatternFig);

function bBrowseFile_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function bRead_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

function bGenerate_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function bWrite_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function bSetWriteFile_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>




% ======== CREATE FUNCTIONS ======== %
function etReadFilename_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function lbPatternStats_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etNumBins_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etBinWidth_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgHeight_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgWidth_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etVecSz_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgFilename_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmImgType_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end


% ======== EMPTY FUNCTIONS ========= %
function etReadFilename_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etBinWidth_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etNumBins_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function lbPatternStats_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgHeight_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgWidth_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etVecSz_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmImgType_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgFilename_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>


% --- Executes on button press in bAutoGen.
function bAutoGen_Callback(hObject, eventdata, handles)
% hObject    handle to bAutoGen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
