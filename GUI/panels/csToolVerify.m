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

% Last Modified by GUIDE v2.5 22-Nov-2013 15:48:05

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

	% TODO : There should probably be a method in here to save results to 
	% disk (need a sub-gui to visualise results?)

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
		return;		%TODO : Modify this outcome?
		
	end

	% Copy the parameters out of the reference frame buffer and use those
	% until we are provided with more information about verification
	tOpts = handles.refFrameBuf.getOpts();
	handles.testFrameBuf = csFrameBuffer(tOpts);

	% TODO : Update this for new csFrameBuffer calls
    % Check if we have a frame handle
    if(~isfield(handles, 'fh'))
        fprintf('WARNING: No frame handle specified\n');
		fprintf('Frame handle input is now deprecated\n');
    end
    % Make a field for vectors
    handles.vectors = [];
	if(~exist('imsz', 'var'))
		handles.imsz = [640 480];
	else
		handles.imsz = imsz;
	end
	% Set internal frame index variable
	handles.idx = 1;

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
	set(handles.etGoto, 'String', num2str(handles.idx));
	set(handles.etNumFiles, 'String', num2str(handles.vfSettings.vsize));
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
            set(handles.pmVecSz, 'Value', 1);
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
			fprintf('Setting to backprojection\n');
			set(handles.pmVecType, 'Value', 4);
    end

    % set image size
    dims = handles.vfSettings.dims;
	
    set(handles.etImageWidth,  'String', dims(1));
    set(handles.etImageHeight, 'String', dims(2));

	% Setup reference preview figure
	set(handles.figPreviewRef,  'XTick', [], 'XTickLabel', []);
	set(handles.figPreviewRef,  'YTick', [], 'YTickLabel', []);
	title(handles.figPreviewRef, 'Reference');
	% Setup test preview figure
	set(handles.figPreviewTest, 'XTick', [], 'XTickLabel', []);
	set(handles.figPreviewTest, 'YTick', [], 'YTickLabel', []);
	title(handles.figPreviewTest, 'Preview');
	% Setup error figure
	set(handles.figError,   'XTick', [], 'XTickLabel', []);
	set(handles.figError,   'YTick', [], 'YTickLabel', []);
	title(handles.figError, 'Error');

	% Show first reference figure in GUI
	refImg = handles.refFrameBuf.getCurImg(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, 'Reference');

    % Choose default command line output for csToolVerify
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
	uiwait(handles.csToolVerifyFig);

% ======== OUTPUT FUNCTION  ======== %	
function varargout = csToolVerify_OutputFcn(hObject, eventdata, handles) %#ok<INUSD>
    %varargout{1} = handles.vfSettings;
	varargout{1} = 0;	%TODO :  temporary - THIS MUST BE FIXED

	% ======== CLOSE REQUEST FUNCTION ======== %
function csToolVerifyFig_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    if(isequal(get(hObject, 'waitstatus'), 'waiting'))
        %Still waiting on GUI
        uiresume(handles.csToolVerifyFig);
    else
        %Ok to clean up
        delete(handles.csToolverifyFig);
    end


function bDone_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Exit the panel
	delete(handles.csToolVerifyFig);
	uiresume(handles.csToolVerifyFig);


% ---------- TRANSPORT CONTROLS -------- %	
function bPrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	
	handles.idx = handles.idx - 1;
	if(handles.idx < 1)
		handles.idx = 1;
	end
	refImg  = handles.refFrameBuf.getCurImg(handles.idx);
	testImg = handles.testFrameBuf.getCurImg(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, []);
	gui_updatePreview(handles.figPreviewTest, testImg, []);
	gui_updatePreview(handles.figError, abs(refImg - testImg), []);

	guidata(hObject, handles);
	uiresume(handles.csToolVerifyFig);

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	handles.idx = handles.idx + 1;
	% Clip to test buffer limit since we dont care about frames we can't
	% verify in this context
	if(handles.idx > handles.testFrameBuf.getNumFrames())
		handles.idx = handles.testFrameBuf.getNumFrames();
	end
	refImg  = handles.refFrameBuf.getCurImg(handles.idx);
	testImg = handles.testFrameBuf.getCurImg(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, []);
	gui_updatePreview(handles.figPreviewTest, testImg, []);
	gui_updatePreview(handles.figError, abs(refImg - testImg), []);

	guidata(hObject, handles);	
	uiresume(handles.csToolVerifyFig);

function bGoto_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	destIdx = fix(str2double(get(handles.etGoto, 'String')));
	% Clamp at buffer limits
	if(isnan(destIdx) || isempty(desIdx))
		fprintf('ERROR: Invalid index %s\n', get(handles.etGoto, 'String'));
		return;
	end
	if(destIdx < 1)
		destIdx = 1;
	end
	if(destIdx > handles.refFrameBuf.getNumFrames())
		destIdx = handles.refFrameBuf.getNumFrames();
	end
	handles.idx = destIdx;

	refImg  = handles.refFrameBuf.getCurImg(handles.idx);
	testImg = handles.testFrameBuf.getCurImg(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, []);
	gui_updatePreview(handles.figPreviewTest, testImg, []);
	gui_updatePreview(handles.figError, abs(refImg - testImg), []);

	guidata(hObject, handles);
	uiresume(handles.csToolVerifyFig);

% -------- GUI RENDERING FUNCTIONS -------- %
function gui_updatePreview(axHandle, img, figTitle)
	% axHandle should be vector of axis handles
	
	imshow(img, 'Parent', axHandle);
	if(~isempty(figTitle))
		title(axHandle, figTitle);
	end


% -------- PROCESSING / VERIFICATION -------- 5

function bRead_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Call VecManager options to read and re-format vector from file
	filename = get(handles.etFileName, 'String');
	filename = slashkill(filename);		%get rid of slashes
    vtlist   = get(handles.pmVecOr, 'String'); %list of vector types
    vtidx    = get(handles.pmVecOr, 'Value');
    vtype    = vtlist{vtidx};
    vslist   = get(handles.pmVecSz, 'String'); %list of vector sizes
    vsidx    = get(handles.pmVecSz, 'Value');
    vsize    = fix(str2double(vslist{vsidx}));
	numFiles = fix(str2double(get(handles.etNumFiles, 'String')));
	
	if(isnan(numFiles))
		fprintf('ERROR: Cant interpret number of files [%s]\n', get(handles.etNumFiles, 'String'));
		return;
	end
	% TOOD : Write a routine to make sure the files are on disk
	chk = checkFiles(filename, 'nframe', numFiles, 'nvec', vsize);
	if(chk.exitflag == -1)
		fprintf('ERROR: In file (%d/%d), vector (%d/%d) [%s]\n', chk.errFrame, numFiles, chk.errVec, vsize, filename);
		return;
	end

	% Setup test frame buffer
	handles.testFrameBuf = handles.testFrameBuf.initFrameBuf(numFiles);
	% Read files in loop
	for N = 1 : numFiles
		% TODO : Need to adjust filename here for frame param	
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

		if(iscell(vectors) && strncmpi(vtype, 'scalar', 6))
			img = handles.vecManager.formatVecImg(vectors{1}, 'vecFmt', 'scalar', 'dataSz', dataSz, 'scale');
		else
			img = handles.vecManager.formatVecImg(vectors, 'vecFmt', vtype, 'dataSz', dataSz, 'scale');
		end
		% Format dims
		dims = size(img);
		dims = [dims(2) dims(1)];	%put into csFrame format	
		% Load this vector into test frame buffer
		if(strncmpi(vtype, 'backprojection', 14))
			bpvec = bpimg2vec(img, 'bpval');
			handles.testFrameBuf = handles.testFrameBuf.loadVectorData(bpvec, N, vtype, 'dims', dims);
		else
			handles.testFrameBuf = handles.testFrameBuf.loadVectorData(img, N, vtype, 'dims', dims);
		end
	end
	% TODO : Need to place vectors into frame buffer - this might require a 
	% new method in the csFrameBuffer class
	
	% Convert to bpvec and save into test buffer
    handles.vectors = vectors;
	
	% Preview final image
	refImg  = handles.refFrameBuf.getCurImg(handles.idx);
	testImg = handles.testFrameBuf.getCurImg(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, 'Reference');
	gui_updatePreview(handles.figPreviewTest, testImg, 'Test Data');
	gui_updatePreview(handles.figError, abs(refImg - testImg), 'Error Image');


	%imshow(img, 'Parent', handles.figPreviewTest);
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

    vtlist = get(handles.pmVecOr, 'String');
    vtidx  = get(handles.pmVecOr, 'Value');
    vtype  = vtlist{vtidx};
    vslist = get(handles.pmVecSz, 'String');
    vsidx  = get(handles.pmVecSz, 'Value');
    vsize  = vslist{vsidx};

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
	uiresume(csToolVerifyFig);

function bPatternVerify_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    % Perform a pattern verification
    % TODO : Put this in top menu bar (with a sub GUI)

    guidata(hObject, handles);
	uiresume(csToolVerifyFig);
    
%function [ef errNum errFile] = numFilesCheck(numFiles, filenamr)
%
%	% Check the files to be read actually exist
%	ps = fname_parse(filename);
%	if(ps.exitflag == -1)
%		fprintf('ERROR: Unable to parse filename %s\n', filename);
%		ef      = -1;
%		errNum  = 1;
%		errFile = filename;
%		return;
%	end



% -------- EMPTY FUNCTIONS -------- %
function etImageHeight_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etImageWidth_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecOr_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecSz_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etFileName_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecType_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etNumFiles_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etGoto_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

% -------- CREATE FUNCTIONS -------- %
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

function etNumFiles_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etGoto_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
