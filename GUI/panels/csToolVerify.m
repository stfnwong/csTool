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

% Last Modified by GUIDE v2.5 15-Dec-2013 20:16:01

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
	%set(handles.pmVecClass, 'String', typeStr);
    vtStr = {'RGB', 'HSV', 'Hue', 'Backprojection'};
    set(handles.pmVecClass, 'String', vtStr);
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
	% Also make sure that etNumFiles has same value as vsize
	vstr = get(handles.pmVecSz, 'String');
	vidx = get(handles.pmVecSz, 'Value');
	vsz  = vstr{vidx};
	set(handles.etNumFiles, 'String', vsz);

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
            set(handles.pmVecClass, 'Value', 2);
        case 'Hue'
            set(handles.pmVecClass, 'Value', 3);
        case 'backprojection'
            set(handles.pmVecClass, 'Value', 4);
        otherwise
            fprintf('Invalid vector type [%s]', handles.vfSettings.vtype);
			fprintf('Setting to backprojection\n');
			set(handles.pmVecClass, 'Value', 4);
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
	refImg   = handles.refFrameBuf.getCurImg(handles.idx);
	rParams  = handles.refFrameBuf.getWinParams(handles.idx);
	rMoments = handles.refFrameBuf.getMoments(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, 'Reference', rParams, rMoments);

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
	uiresume(handles.csToolVerifyFig);
	delete(handles.csToolVerifyFig);


% ---------- TRANSPORT CONTROLS -------- %	
function bPrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	
	handles.idx = handles.idx - 1;
	if(handles.idx < 1)
		handles.idx = 1;
	end
	refImg    = handles.refFrameBuf.getCurImg(handles.idx);
	testImg   = handles.testFrameBuf.getCurImg(handles.idx);
	errImg    = abs(refImg - testImg);
	refTitle  = sprintf('Reference frame %d', handles.idx);
	testTitle = sprintf('Test frame %d', handles.idx);
	errTitle  = sprintf('Error frame %d', handles.idx);
	tParams   = handles.testFrameBuf.getWinParams(handles.idx);
	tMoments  = handles.testFrameBuf.getMoments(handles.idx);
	rParams   = handles.refFrameBuf.getWinParams(handles.idx);
	rMoments  = handles.refFrameBuf.getMoments(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, refTitle, rParams, rMoments);
	gui_updatePreview(handles.figPreviewTest, testImg, testTitle, tParams, tMoments);
	gui_updatePreview(handles.figError, errImg, errTitle, [], []);
	nh = gui_updateParams(handles);
	handles = nh;

	guidata(hObject, handles);
	uiresume(handles.csToolVerifyFig);

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	handles.idx = handles.idx + 1;
	% Clip to test buffer limit since we dont care about frames we can't
	% verify in this context
	if(handles.idx > handles.testFrameBuf.getNumFrames())
		handles.idx = handles.testFrameBuf.getNumFrames();
	end
	refImg    = handles.refFrameBuf.getCurImg(handles.idx);
	testImg   = handles.testFrameBuf.getCurImg(handles.idx);
	errImg    = abs(refImg - testImg);
	refTitle  = sprintf('Reference frame %d', handles.idx);
	testTitle = sprintf('Test frame %d', handles.idx);
	errTitle  = sprintf('Error frame %d', handles.idx);
	tParams   = handles.testFrameBuf.getWinParams(handles.idx);
	tMoments  = handles.testFrameBuf.getMoments(handles.idx);
	rParams   = handles.refFrameBuf.getWinParams(handles.idx);
	rMoments  = handles.refFrameBuf.getMoments(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, refTitle, rParams, rMoments);
	gui_updatePreview(handles.figPreviewTest, testImg, testTitle, tParams, tMoments);
	gui_updatePreview(handles.figError, errImg, errTitle, [], []);
	nh = gui_updateParams(handles);
	handles = nh;

	guidata(hObject, handles);	
	uiresume(handles.csToolVerifyFig);

function bGoto_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	destIdx = fix(str2double(get(handles.etGoto, 'String')));
	% Clamp at buffer limits
	if(isnan(destIdx) || isempty(destIdx))
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

	refImg    = handles.refFrameBuf.getCurImg(handles.idx);
	testImg   = handles.testFrameBuf.getCurImg(handles.idx);
	errImg    = abs(refImg - testImg);
	refTitle  = sprintf('Reference frame %d', handles.idx);
	testTitle = sprintf('Test frame %d', handles.idx);
	errTitle  = sprintf('Error frame %d', handles.idx);
	tParams   = handles.testFrameBuf.getWinParams(handles.idx);
	tMoments  = handles.testFrameBuf.getMoments(handles.idx);
	rParams   = handles.refFrameBuf.getWinParams(handles.idx);
	rMoments  = handles.refFrameBuf.getMoments(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, refTitle, rParams, rMoments);
	gui_updatePreview(handles.figPreviewTest, testImg, testTitle, tParams, tMoments);
	gui_updatePreview(handles.figError, errImg, errTitle, [], []);
	nh = gui_updateParams(handles);
	handles = nh;

	guidata(hObject, handles);
	uiresume(handles.csToolVerifyFig);

% -------- GUI RENDERING FUNCTIONS -------- %
function gui_updatePreview(axHandle, img, figTitle, params, moments)
	% axHandle should be vector of axis handles
	
	imshow(img, 'Parent', axHandle);
	if(~isempty(figTitle))
		title(axHandle, figTitle);
	end

	if(~isequal(params, zeros(1,5)) || ~isempty(params) && ...
	   ~isequal(moments, zeros(1,6)) || ~isempty(moments))
		% Plot parameters
		%vstr = get(handles.pmVecSz, 'String');
		%vidx = get(handles.pmVecSz, 'Value');
		%vsz  = vstr{vidx};
		vsz  = 16;			% TODO : Change this!!!!
		ef   = gui_plotParams(axHandle, params, moments, vsz);
		if(ef == -1)
			%fprintf('ERROR: Couldnt plot params in frame %d\n', handles.idx);
			return;
		end
		%[l r t b] = gui_calcRect(params(1), params(2), params(4), params(5), params(3), 20);
		%plot(axHandle, 
	end

function nh = gui_updateParams(handles)
	% This function is only responsible for writing the parameter text
	% to the GUI. There should be a seperate function for formatting the 
	% parameter data correctly
	
	%handles.etRefParams / handles.etTestParams

	refParams   = handles.refFrameBuf.getWinParams(handles.idx);
	refMoments  = handles.refFrameBuf.getMoments(handles.idx);
	testParams  = handles.testFrameBuf.getWinParams(handles.idx);
	testMoments = handles.testFrameBuf.getMoments(handles.idx);

	% Format text
	paramTitle    = sprintf('Window parameters :');
	momentTitle   = sprintf('Frame Moments :');
	if(~isempty(refParams))
		refParamStr = sprintf('%f ', refParams);
	else
		refParamStr = [];
	end
	if(~isempty(refMoments))
		refMomentStr = sprintf('%f ', refMoments);
	else
		refMomentStr = [];
	end
	if(~isempty(testParams))
		testParamStr = sprintf('%f ', testParams);
	else
		testParamStr = [];
	end
	if(~isempty(testMoments))
		testMomentStr = sprintf('%f ', testMoments);
	else
		testMomentStr = [];
	end

	refText       = {paramTitle, refParamStr,  momentTitle, refMomentStr};
	testText      = {paramTitle, testParamStr, momentTitle, testMomentStr};
	set(handles.etRefParams, 'String', refText);
	set(handles.etTestParams, 'String', testText);
	nh = handles;

	return;


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
	vclist   = get(handles.pmVecClass, 'String');
	vcidx    = get(handles.pmVecClass, 'Value');
	vclass   = vclist{vcidx};
	numFiles = fix(str2double(get(handles.etNumFiles, 'String')));
	
	if(isnan(numFiles))
		fprintf('ERROR: Cant interpret number of files [%s]\n', get(handles.etNumFiles, 'String'));
		return;
	end
	% TODO : Write a routine to make sure the files are on disk
	chk = checkFiles(filename, 'nframe', numFiles, 'nvec', vsize);
	if(chk.exitflag == -1)
		fprintf('ERROR: In file (%d/%d), vector (%d/%d) [%s]\n', chk.errFrame, numFiles, chk.errVec, vsize, filename);
		return;
	end

	% Setup test frame buffer
	handles.testFrameBuf = handles.testFrameBuf.initFrameBuf(numFiles);
	ps = fname_parse(filename);
	if(ps.exitflag == -1)
		fprintf('ERROR: unable to parse file [%s]\n', filename);
		return;
	end

	% Read files in loop
	for N = 1 : numFiles
		fn = sprintf('%s%s-frame%03d-vec%03d.%s', ps.path, ps.filename, N, 1, ps.ext);
		[vectors ef] = handles.vecManager.readVec('fname', fn, 'sz', vsize, 'vtype', vtype);
		if(ef == -1)
			fprintf('ERROR: Failed to read vector in file [%s]\n', fn);
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
			case 'Backprojection'
				dataSz = 256;
			otherwise
				dataSz = 256;
		end

		if(iscell(vectors) && strncmpi(vtype, 'scalar', 6))
			img = handles.vecManager.formatVecImg(vectors{1}, 'vecFmt', 'scalar', 'dataSz', dataSz, 'scale');
		else
			img = handles.vecManager.formatVecImg(vectors, 'vecFmt', vtype, 'dataSz', dataSz, 'scale');
		end
		% Rescale image
		sc   = range(range(handles.refFrameBuf.getCurImg(handles.idx)));
		img  = imgRescale(img, sc);
		% Format dims and place vector into buffer
		dims = size(img);
		dims = [dims(2) dims(1)];	
		if(strncmpi(vclass, 'backprojection', 14))
			bpvec = bpimg2vec(img, 'bpval');
			handles.testFrameBuf = handles.testFrameBuf.loadVectorData(bpvec, N, vclass, 'dims', dims);
		else
			handles.testFrameBuf = handles.testFrameBuf.loadVectorData(img, N, vclass, 'dims', dims);
		end

		% Automatically check for param or moment files
		paramFname = sprintf('%s%s-frame%03d-params.dat', ps.path, ps.filename, ps.frameNum);
		if(exist(paramFname, 'file') == 2)
			fprintf('Found parameter file [%s]\n', paramFname);
			fp = fopen(paramFname, 'r');
			if(fp == -1)
				fprintf('ERROR: Cant open file %s...\n', paramFname);
			else
				params = fread(fp, 5, 'uint32');
				opts   = struct('winparams', params);
				handles.testFrameBuf = handles.testFrameBuf.setFrameParams(handles.idx, opts);
				fclose(fp);
			end
		end
		momentFname = sprintf('%s%s-frame%03d-moments.dat', ps.path, ps.filename, ps.frameNum);
		if(exist(momentFname, 'file') == 2)
			fprintf('Found moment file [%s]\n', momentFname);
			fp = fopen(momentFname, 'r');
			if(fp == -1)
				fprintf('ERROR: Cant open file %s\n', momentFname);
			else
				moments = fread(fp, 6, 'uint32');
				opts    = struct('moments', moments);
				handles.testFrameBuf = handles.testFrameBuf.setFrameParams(handles.idx, opts);
				fclose(fp);
			end
		end

	end
	% Convert to bpvec and save into test buffer
    handles.vectors = vectors;

	% Preview final image
	refImg   = handles.refFrameBuf.getCurImg(handles.idx);
	rParams  = handles.refFrameBuf.getWinParams(handles.idx);
	rMoments = handles.regFrameBuf.getMoments(handles.idx);
    % TODO :  Still a problem here with size(vec) in vec2bpimg()
	testImg  = handles.testFrameBuf.getCurImg(handles.idx);
	tParams  = handles.testFrameBuf.getWinParams(handles.idx);
	tMoments = handles.testFrameBuf.getMoments(handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, 'Reference', rParams, rMoments);
	gui_updatePreview(handles.figPreviewTest, testImg, 'Test Data', tParams, tMoments);
	gui_updatePreview(handles.figError, abs(refImg - testImg), 'Error Image', [], []);

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
    

function pmVecSz_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	% Update the numFiles edit text box whenever this property changes
	vecList = get(handles.pmVecSz, 'String');
	vecIdx  = get(hadnles.pmVecSz, 'Value');
	vecSz   = vecList{vecIdx};
	set(handles.etNumFiles, 'String', vecSz);


% -------- EMPTY FUNCTIONS -------- %
function etImageHeight_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etImageWidth_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecOr_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etFileName_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecClass_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etNumFiles_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etGoto_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etTestParams_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etRefParams_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

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

function pmVecClass_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
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

function etTestParams_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etRefParams_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end












