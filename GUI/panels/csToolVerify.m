function varargout = csToolVerify(varargin)
% CSTOOLVERIFY M-file for csToolVerify.fig
%      CSTOOLVERIFY, by itself, creates a new CSTOOLVERIFY or raises the existing
%      singleton*.
%
%      H = CSTOOLVERIFY returns the handle to a new CSTOOLVERIFY or the handle to
%      the existing singleton*.
%
%      CSTOOLVERIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLVERIFY.M with the given input arguments.
%
%      CSTOOLVERIFY('Property','Value',...) creates a new CSTOOLVERIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolVerify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolVerify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolVerify

% Last Modified by GUIDE v2.5 28-May-2013 21:18:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolVerify_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolVerify_OutputFcn, ...
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


% --- Executes just before csToolVerify is made visible.
function csToolVerify_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolVerify (see VARARGIN)

	handles.debug = false;
	handles.status = 0;

    if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin))
				if(strncmpi(varargin{k}, 'imsz', 4))
					imsz = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = true;
				end
			else
				if(isa(varargin{k}, 'vecManager'))
					handles.vecManager = varargin{k};
				end
			end
		end
    end

	%Check what we have
	if(~isfield(handles, 'vecManager'))
		fprintf('ERROR: No vecManager object in csToolVerify\n');
		delete(handles.csToolVerifyFig);
		return;
	end
	if(~exist('imsz', 'var'))
		handles.imsz = [640 480];
	else
		handles.imsz = imsz;
	end

	%Populate GUI elements
    fmtStr  = {'16', '8', '4', '2', 'scalar'};
    orStr   = {'row', 'col', 'scalar'};
    typeStr = {'HSV', 'Hue', 'BP'};
	set(handles.pmVecSz, 'String', fmtStr);
	set(handles.pmVecOr, 'String', orStr);
	%set(handles.pmVecType, 'String', typeStr);

	%Setup preview figure
	set(handles.figPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.figPreview, 'YTick', [], 'YTickLabel', []);

    % Choose default command line output for csToolVerify
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

	% UIWAIT makes csToolVerify wait for user response (see UIRESUME)
	% uiwait(handles.csToolVerifyFig);



function varargout = csToolVerify_OutputFcn(hObject, eventdata, handles) %#ok<INUSL> 
    varargout{1} = handles.output;

function bDone_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Exit the panel
	delete(hObject);
    
function bRead_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Call VecManager options to read and re-format vector from file
	filename     = get(handles.etFileName, 'String');
	filename     = slashkill(filename);		%get rid of slashes
	%DEBUG:
	fprintf('(DEBUG)filename - [%s]\n', filename);
    vtype        = get(handles.pmVecOr, 'String');
    vidx         = get(handles.pmVecSz, 'Value');
    vstr         = get(handles.pmVecSz, 'String');
    if(strncmpi(vstr, 'scalar', 6))
        vsize = 1;
    else
        vsize = fix(str2double(vstr{vidx}));
    end
	[vectors ef] = handles.vecManager.readVec('fname', filename, 'sz', vsize, 'vtype', vtype{vidx});
	if(ef == -1)
		fprintf('ERROR: Failed to read vector in file [%s]\n', filename);
		return;
	end
	%img      = handles.vecManager.assemVec(vectors, 'vecfmt', 'scalar'); 
	img          = handles.vecManager.formatVecImg(vectors, 'vecFmt', 'scalar');

	%Show image in preview area
	imshow(img, 'Parent', figPreview);
    %switch(vtype)
    %    case 'row'
    %    case 'col'
    %    case 'scalar'
    %    otherwise
    %        %No real way to get here, but in case I do something while
    %        %debugging or the like...
    %        fprintf('Not a valid vector type (%s)\n', vtype);
    %end

function bGetFile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Browse for file to read
    oldText = get(handles.etFileName, 'String');
    [fname path] = uigetfile('*.dat', 'Select vector file...');
    if(isempty(fname))
        fname = oldText;
		path  = '.';
    end
    set(handles.etFileName, 'String', sprintf('%s/%s', path, fname));
    guidata(hObject, handles);

function pmVecOr_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecSz_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etFileName_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etFileName_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function pmVecSz_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function pmVecOr_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end





