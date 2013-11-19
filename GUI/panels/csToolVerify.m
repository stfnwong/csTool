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

% Last Modified by GUIDE v2.5 05-Oct-2013 04:22:49

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
                elseif(strncmpi(varargin{k}, 'fh', 2))
                    handles.fh = varargin{k+1};
                elseif(strncmpi(varargin{k}, 'opts', 4))
                    handles.vfSettings = varargin{k+1};
				end
			else
				if(isa(varargin{k}, 'vecManager'))
					handles.vecManager = varargin{k};
				elseif(isa(varargin{k}, 'csFrameBuffer'))
					handles.refFrameBuf = varargin{k};
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
    if(~isfield(handles, 'vfSettings'))
        fprintf('WARNING: No settings parameter passed in - using defaults\n');
        % NOTE: Valid values for vtype in this context are
        % (backprojection, RGB, HSV, hue)
        vfSettings = struct('filename', [], 'orientation', [], 'vsize', [], 'vtype', [], 'dims', []);
        vfSettings.filename    = ' ';
        vfSettings.orientation = 'scalar';
        vfSettings.vsize       = 1;
        vfSettings.vtype       = 'backprojection';
        vfSettings.dims        = [640 480];
        handles.vfSettings     = vfSettings;
    end
	if(~isfield(handles, 'refFrameBuf'))
		fprintf('WARNING: No reference frame buffer supplied - verification not possible\n');
		% TODO : what to do about this?
		
	end

	%  TODO : Generate a new local frame buffer here for data read from disk
	fbOpts = struct('thing', [], 'other_thing', []);
	handles.testFrameBuf = csFrameBuffer(fbOpts);

	% TODO : Update this for new csFrameBuffer calls
    % Check if we have a frame handle
    if(~isfield(handles, 'fh'))
        fprintf('WARNING: No frame handle specified\n');
    end
    % Make a field for vectors
    handles.vectors = [];
	if(~exist('imsz', 'var'))
		handles.imsz = [640 480];
	else
		handles.imsz = imsz;
	end

	%Populate GUI elements
    fmtStr  = {'16', '8', '4', '2'};
    orStr   = {'row', 'col', 'scalar'};
    %typeStr = {'HSV', 'Hue', 'BP'};
	set(handles.pmVecSz, 'String', fmtStr);
	set(handles.pmVecOr, 'String', orStr);
	%set(handles.pmVecType, 'String', typeStr);
    vtStr = {'RGB', 'HSV', 'Hue', 'Backprojection'};
    set(handles.pmVecType, 'String', vtStr);
    % Set selections in GUI to match values in vfSettings

    % set filename
    set(handles.etFileName, 'String', handles.vfSettings.filename);
    
    % set format string
    switch(handles.vfSettings.vsize)
        case 16
            set(handles.pmVecSz, 'Value', 1);
        case 8
            set(handles.pmVecSz, 'Value', 2);
        case 4
            set(handles.pmVecSz, 'Value', 3);
        case 2
            set(handles.pmVecSz, 'Value', 4);
        otherwise
            set(handles.pmVecSz, 'Value', 5);
    end

    % set orientation string
    switch(handles.vfSettings.orientation)
        case 'row'
            set(handles.pmVecOr, 'Value', 1);
        case 'col' 
            set(handles.pmVecOr, 'Value', 2);
        otherwise
            set(handles.pmVecOr, 'Value', 3);
    end

    % set vector type
    switch(handles.vfSettings.vtype)
        case 'RGB'
            set(hnadles.pmVecType, 'Value', 1);
        case 'HSV'
            set(handles.pmVecType, 'Value', 2);
        case 'Hue'
            set(handles.pmVecType, 'Value', 3);
        case 'backprojection'
            set(handles.pmVecType, 'Value', 4);
        otherwise
            fprintf('Invalid vector type [%s]', handles.vfSettings.vtype);
    end

    % set image size
    dims = handles.vfSettings.dims;
    set(handles.etImageWidth,  'String', dims(1));
    set(handles.etImageHeight, 'String', dims(2));
    %set(handles.etImageWidth, 'String', num2str(handles.imsz(1)));
    %set(handles.etImageHeight, 'String', num2str(handles.imsz(2)));

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
    varargout{1} = handles.vfSettings;

function bDone_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Exit the panel
	delete(handles.csToolVerifyFig);
    
function bRead_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Call VecManager options to read and re-format vector from file
	filename     = get(handles.etFileName, 'String');
	filename     = slashkill(filename);		%get rid of slashes

    vtlist       = get(handles.pmVecOr, 'String');
    vtidx        = get(handles.pmVecOr, 'Value');
    vtype        = vtlist{vtidx};
    vslist       = get(handles.pmVecSz, 'String');
    vsidx        = get(handles.pmVecSz, 'Value');
    vsize        = vslist{vsidx};

	% TODO : Read in a loop
    
	[vectors ef] = handles.vecManager.readVec('fname', filename, 'sz', vsize, 'vtype', vtype);
	if(ef == -1)
		fprintf('ERROR: Failed to read vector in file [%s]\n', filename);
		return;
	end
    % Set up data size based on vector type
    % NOTE This should be settable - dont forget to redo
    switch(vtype)
        case 'RGB'
            dataSz = 1;
        case 'HSV'
            dataSz = 1;
        case 'Hue'
            dataSz = 256;
        case 'backprojection'
            dataSz = 256;
        otherwise
            dataSz = 256;
    end

	%img      = handles.vecManager.assemVec(vectors, 'vecfmt', 'scalar'); 
	if(iscell(vectors) && strncmpi(vtype, 'scalar', 6))
		img = handles.vecManager.formatVecImg(vectors{1}, 'vecFmt', 'scalar', 'dataSz', dataSz, 'scale');
	else
		img = handles.vecManager.formatVecImg(vectors, 'vecFmt', vtype, 'dataSz', dataSz, 'scale');
	end
    handles.vectors = vectors;
	%Show image in preview area
	imshow(img, 'Parent', handles.figPreview);
    guidata(hObject, handles);

function bGetFile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Browse for file to read
    oldText = get(handles.etFileName, 'String');
    [fname path] = uigetfile('*.dat', 'Select vector file...');
    if(isempty(fname))
        fname = oldText;
		path  = '';
    end
    set(handles.etFileName, 'String', sprintf('%s/%s', path, fname));
    guidata(hObject, handles);

function bCheckCurFrame_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    % Run verification routine against frame currently displayed in main
    % GUI.

    % We cant check against nothing, make sure there is a frame handle
    if(~isfield(handles, 'fh'))
        fprintf('ERROR: No frame handle present, exiting\n');
        return;
    end
    % Check that we have a vector
    if(isempty(handles.vectors))
        fprintf('ERROR: No vectors read into handles.vectors, exiting\n');
        return;
    end

    vtlist       = get(handles.pmVecOr, 'String');
    vtidx        = get(handles.pmVecOr, 'Value');
    vtype        = vtlist{vtidx};
    vslist       = get(handles.pmVecSz, 'String');
    vsidx        = get(handles.pmVecSz, 'Value');
    vsize        = vslist{vsidx};

    switch(vtype)
        case 'RGB'
        case 'HSV'
        case 'Hue'
        case 'backprojection'
            status = handles.vecManager.verifyBPVec(handles.fh, vectors, 'type', vtype, 'val', vsize);
    end
    if(status == -1)
        % Since we got error status, discard results
        fprintf('ERROR: status in verifyVec, exiting\n');
        return;
    end
    
    guidata(hObject, handles);

function bPatternVerify_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    % Perform a pattern verification
    % TODO : Put this in top menu bar (with a sub GUI)

    guidata(hObject, handles);
    


% -------- EMPTY FUNCTIONS -------- %
function etImageHeight_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etImageWidth_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecOr_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecSz_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etFileName_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecType_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

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

function etImageWidth_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etImageHeight_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pmVecType_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end




