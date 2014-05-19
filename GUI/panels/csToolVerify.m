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

% Last Modified by GUIDE v2.5 19-May-2014 12:34:39

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
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'imsz', 4))
					imsz = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = true;
                elseif(strncmpi(varargin{k}, 'fh', 2))
                    handles.fh = varargin{k+1};
                elseif(strncmpi(varargin{k}, 'opts', 4))
                    handles.vfSettings = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'frameBuf', 8))
					handles.refFrameBuf = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'testBuf', 7))
					handles.testFrameBuf = varargin{k+1};
				end
			else
				if(isa(varargin{k}, 'vecManager'))
					handles.vecManager = varargin{k};
				%elseif(isa(varargin{k}, 'csFrameBuffer'))
				%	handles.refFrameBuf = varargin{k};
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
	% If there is no test frame buffer then create a new one
	if(~isfield(handles, 'testFrameBuf'))
		fprintf('WARNING: No testFrameBuf specified, cloning reference buffer options\n');
		tOpts = handles.refFrameBuf.getOpts();
		handles.testFrameBuf = csFrameBuffer(tOpts);
	end
	handles.testBufRead = false;

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
    fmtStr     = {'16', '8', '4', '2'};
    orStr      = {'row', 'col', 'scalar'};
	dataFmtStr = {'hex', 'dec'}; 	%TODO : binary
	delimStr   = {'Space', 'Comma'};
    %typeStr = {'HSV', 'Hue', 'BP'};
	set(handles.pmVecSz,   'String', fmtStr);
	set(handles.pmVecOr,   'String', orStr);
	set(handles.pmDataFmt, 'String', dataFmtStr);
	set(handles.pmDelimiter, 'String', delimStr);
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
            set(handles.pmVecClass, 'Value', 1);
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
	handles.vclass = handles.vfSettings.vtype;

    % set image size
    dims = handles.vfSettings.dims;
	
    set(handles.etImageWidth,  'String', dims(1));
    set(handles.etImageHeight, 'String', dims(2));

	% Setup reference preview figure
	set(handles.figPreviewRef,   'XTick', [], 'XTickLabel', []);
	set(handles.figPreviewRef,   'YTick', [], 'YTickLabel', []);
	title(handles.figPreviewRef, 'Reference');
	% Setup test preview figure
	set(handles.figPreviewTest,  'XTick', [], 'XTickLabel', []);
	set(handles.figPreviewTest,  'YTick', [], 'YTickLabel', []);
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

	handles.status = 0;
	handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
	uiwait(handles.csToolVerifyFig);

% ======== OUTPUT FUNCTION  ======== %	
function varargout = csToolVerify_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
	handles.output = struct('frameBuf', handles.refFrameBuf, ...
		                    'testBuf', handles.testFrameBuf, ...
		                    'vfSettings', handles.vfSettings, ...
		                    'status', handles.status);
	varargout{1} = handles.output;

	% ======== CLOSE REQUEST FUNCTION ======== %
function csToolVerifyFig_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    if(isequal(get(hObject, 'waitstatus'), 'waiting'))
        %Still waiting on GUI
        uiresume(handles.csToolVerifyFig);
    else
        %Ok to clean up
        delete(handles.csToolVerifyFig);
    end


function bDone_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Exit the panel
	handles.status = 0;
	close(handles.csToolVerifyFig);


function pmVecClass_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	vcIdx  = get(handles.pmVecClass, 'Value');
	vcStr  = get(handles.pmVecClass, 'String');
	vcType = vcStr{vcIdx};
	
	if(strncmpi(vcType, 'RGB', 3))
		handles.vclass = 'RGB';
	elseif(strncmpi(vcType, 'HSV', 3))
		handles.vclass = 'HSV';
	elseif(strncmpi(vcType, 'Hue', 3))
		handles.vclass = 'Hue';
	elseif(strncmpi(vcType, 'backprojection', 14))
		handles.vclass = 'backprojection';
	else
		return;
	end

	guidata(hObject, handles);


% ---------- KEYPRESS FUNCTION -------- %	
function csToolVerifyFig_KeyPressFcn(hObject, eventdata, handles) %#ok<DEFNU>

	switch eventdata.Character
		case 'f'
			if(handles.idx < handles.testFrameBuf.getNumFrames())
				handles.idx = handles.idx+1;
			else
				handles.idx = handles.testFrameBuf.getNumFrames();
			end
			
			refTitle  = sprintf('Reference frame %d', handles.idx);
			testTitle = sprintf('Test frame %d', handles.idx);
			errTitle  = sprintf('Error frame %d', handles.idx);
			[refImg testImg errImg] = gui_getImg(handles.refFrameBuf, handles.testFrameBuf, handles.idx, handles.vclass);
			[rParams rMoments tParams tMoments] = gui_getParams(handles.refFrameBuf, handles.testFrameBuf, handles.idx);
			gui_updatePreview(handles.figPreviewRef, refImg, refTitle, rParams, rMoments);
			gui_updatePreview(handles.figPreviewTest, testImg, testTitle, tParams, tMoments);
			gui_updatePreview(handles.figError, errImg, errTitle, [], []);
			nh = gui_updateParams(handles);
			handles = nh;

		case 'b'
			if(handles.idx > 1)
				handles.idx = handles.idx - 1;
			else
				handles.idx = 1;
			end

			refTitle  = sprintf('Reference frame %d', handles.idx);
			testTitle = sprintf('Test frame %d', handles.idx);
			errTitle  = sprintf('Error frame %d', handles.idx);
			[refImg testImg errImg] = gui_getImg(handles.refFrameBuf, handles.testFrameBuf, handles.idx, handles.vclass);
			[rParams rMoments tParams tMoments] = gui_getParams(handles.refFrameBuf, handles.testFrameBuf, handles.idx);
			gui_updatePreview(handles.figPreviewRef, refImg, refTitle, rParams, rMoments);
			gui_updatePreview(handles.figPreviewTest, testImg, testTitle, tParams, tMoments);
			gui_updatePreview(handles.figError, errImg, errTitle, [], []);
			nh = gui_updateParams(handles);
			handles = nh;

		case 'r'

	end

	guidata(hObject, handles);

% ---------- TRANSPORT CONTROLS -------- %	
function bPrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	
	handles.idx = handles.idx - 1;
	if(handles.idx < 1)
		handles.idx = 1;
	end
	%refImg    = handles.refFrameBuf.getCurImg(handles.idx);
	%testImg   = handles.testFrameBuf.getCurImg(handles.idx);
	%errImg    = abs(refImg - testImg);
	%

	refTitle  = sprintf('Reference frame %d', handles.idx);
	testTitle = sprintf('Test frame %d', handles.idx);
	errTitle  = sprintf('Error frame %d', handles.idx);

	%tParams   = handles.testFrameBuf.getWinParams(handles.idx);
	%tMoments  = handles.testFrameBuf.getMoments(handles.idx);
	%rParams   = handles.refFrameBuf.getWinParams(handles.idx);
	%rMoments  = handles.refFrameBuf.getMoments(handles.idx);
	[refImg testImg errImg] = gui_getImg(handles.refFrameBuf, handles.testFrameBuf, handles.idx, handles.vclass);
	[rParams rMoments tParams tMoments] = gui_getParams(handles.refFrameBuf, handles.testFrameBuf, handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, refTitle, rParams, rMoments);
	gui_updatePreview(handles.figPreviewTest, testImg, testTitle, tParams, tMoments);
	gui_updatePreview(handles.figError, errImg, errTitle, [], []);
	nh = gui_updateParams(handles);
	handles = nh;
	% Write parameters to text box

	guidata(hObject, handles);

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	handles.idx = handles.idx + 1;
	% Clip to test buffer limit since we dont care about frames we can't
	% verify in this context
	if(handles.idx > handles.testFrameBuf.getNumFrames())
		handles.idx = handles.testFrameBuf.getNumFrames();
	end
	%refImg    = handles.refFrameBuf.getCurImg(handles.idx);
	%testImg   = handles.testFrameBuf.getCurImg(handles.idx);
	%errImg    = abs(refImg - testImg);
	refTitle  = sprintf('Reference frame %d', handles.idx);
	testTitle = sprintf('Test frame %d', handles.idx);
	errTitle  = sprintf('Error frame %d', handles.idx);
	%tParams   = handles.testFrameBuf.getWinParams(handles.idx);
	%tMoments  = handles.testFrameBuf.getMoments(handles.idx);
	%rParams   = handles.refFrameBuf.getWinParams(handles.idx);
	%rMoments  = handles.refFrameBuf.getMoments(handles.idx);
	[refImg testImg errImg] = gui_getImg(handles.refFrameBuf, handles.testFrameBuf, handles.idx, handles.vclass);
	[rParams rMoments tParams tMoments] = gui_getParams(handles.refFrameBuf, handles.testFrameBuf, handles.idx);
	gui_updatePreview(handles.figPreviewRef, refImg, refTitle, rParams, rMoments);
	gui_updatePreview(handles.figPreviewTest, testImg, testTitle, tParams, tMoments);
	gui_updatePreview(handles.figError, errImg, errTitle, [], []);
	nh = gui_updateParams(handles);
	handles = nh;

	guidata(hObject, handles);	

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

	%refImg    = handles.refFrameBuf.getCurImg(handles.idx);
	%testImg   = handles.testFrameBuf.getCurImg(handles.idx);
	%errImg    = abs(refImg - testImg);
	[refImg testImg errImg] = gui_getImg(handles,refFrameBuf, handles.testFrameBuf, handles.idx, handles.vclass);
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

% -------- GUI RENDERING FUNCTIONS -------- %
function gui_updatePreview(axHandle, img, figTitle, params, moments)
	% Clear figure first?
	cla(axHandle);	
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
		ef   = gui_plotParams(axHandle, params, moments, 1, vsz);
		if(ef == -1)
			%fprintf('ERROR: Couldnt plot params in frame %d\n', handles.idx);
			return;
		end
		%plot(axHandle, 
	end

function nh = gui_updateParams(handles)
	% This function is only responsible for writing the parameter text
	% to the GUI. There should be a seperate function for formatting the 
	% parameter data correctly
	
	%handles.etRefParams / handles.etTestParams

	refParams   = handles.refFrameBuf.getWinParams(handles.idx);
	refMoments  = handles.refFrameBuf.getMoments(handles.idx);
	refNiters   = handles.refFrameBuf.getNiters(handles.idx);
	%refNiters   = handles.refFrameBuf.getNiters(handles.idx);
	if(handles.testBufRead)
	   testParams  = handles.testFrameBuf.getWinParams(handles.idx);
	   testMoments = handles.testFrameBuf.getMoments(handles.idx);
	   testNiters  = handles.testFrameBuf.getNiters(handles.idx);
	else
	   testParams  = [];
	   testMoments = [];
	   testNiters  = [];
	end

	 %Format text
	refTitle      = sprintf('Reference frame');
	testTitle     = sprintf('Test frame');
	paramTitle    = sprintf('xc    yc    theta  width  length');
	momentTitle   = sprintf('zm    xm    ym     xym    xxm    yym');
	%errTitle      = sprintf('Parameter error :\n');
	if(~isempty(refParams))
		refParamStr = sprintf('%4.2f ', fix(refParams));
		%refParamErr = abs(refParams - testParams);
	else
		refParamStr = [];
	end
	if(~isempty(refMoments))
		% TODO : Add control to make Moment display selectable
		refMomentStr = sprintf('[%.0f] ', refMoments{1});
	else
		refMomentStr = [];
	end
	if(~isempty(refNiters))
		refNiterString = sprintf('iters : %d', refNiters);
	else
		refNiterString = [];
	end
	if(~isempty(testParams))
		testParamStr = sprintf('[%4.2f] ', testParams);
	else
		testParamStr = [];
	end
	if(~isempty(testMoments))
		testMomentStr = sprintf('[%.0f] ', testMoments{1});
	else
		testMomentStr = [];
	end
	if(~isempty(testNiters))
		testNiterString = sprintf('iters : %d', testNiters);
	else
		testNiterString = [];
	end

	% Show error terms for window parameters as well
	
	refText       = {refTitle, paramTitle, refParamStr,  momentTitle, refMomentStr, refNiterString};
	testText      = {testTitle, paramTitle, testParamStr, momentTitle, testMomentStr, testNiterString};
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
	dfmtStr  = get(handles.pmDataFmt, 'String');
	dfmtidx  = get(handles.pmDataFmt, 'Value');
	dataFmt  = dfmtStr{dfmtidx};
	delimStr = get(handles.pmDelimiter, 'String');
	delimIdx = get(handles.pmDelimiter, 'Value');
	delimSel = delimStr{delimIdx};

	if(strncmpi(delimSel, 'space', 5))
		delim = ' ';
	elseif(strncmpi(delimSel, 'comma', 5))
		delim = ',';
	else
		delim = ' ';
	end
	
	if(isnan(numFiles))
		fprintf('ERROR: Cant interpret number of files [%s]\n', get(handles.etNumFiles, 'String'));
		return;
	end
	% Only need to do file check if there is more than one file
	if(numFiles > 1)
		chk = checkFiles(filename, 'nframe', numFiles, 'nvec', vsize, 'vcheck');
		if(chk.exitflag == -1)
			fprintf('ERROR: In file (%d/%d), vector (%d/%d) [%s]\n', chk.errFrame, numFiles, chk.errVec, vsize, filename);
			return;
		end
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
		[vectors ef] = handles.vecManager.readVec('fname', fn, 'sz', vsize, 'vtype', vtype, 'dmode', dataFmt, 'delim', delim);
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
			img = handles.vecManager.formatVecImg(vectors{1}, 'vecFmt', 'scalar', 'dataSz', dataSz, 'scale', 'dmode', dataFmt);
		else
			img = handles.vecManager.formatVecImg(vectors, 'vecFmt', vtype, 'dataSz', dataSz, 'scale', 'dmode', dataFmt);
		end
		% Rescale image
		%sc   = range(range(handles.refFrameBuf.getCurImg(handles.idx)));
		%img  = imgRescale(img, sc);
		%sc  = handles.refFrameBuf.getDataSz(handles.idx);
        %img = imgRescale(img, sc);
		img = imgRescale(img, dataSz);
		% Format dims and place vector into buffer
		dims = size(img);
		dims = [dims(2) dims(1)];	
		if(strncmpi(vclass, 'backprojection', 14))
			[bpvec bpsum] = bpimg2vec(img, 'bpval');
			fParams = struct('bpvec', bpvec, ...
				             'bpsum', bpsum, ...
				             'dims', dims, ...
				             'hasImgData', false);
			handles.testFrameBuf = handles.testFrameBuf.setFrameParams(N, fParams);
		else
			fParams = struct('img', img, ...
				             'dims', dims, ...
				             'hasImgData', true);
			handles.testFrameBuf = handles.testFrameBuf.setFrameParams(N, fParams);
		end

		% Automatically check for parameter file
		paramFname = sprintf('%s%s-frame%03d-wparam.dat', ps.path, ps.filename, N);
		if(exist(paramFname, 'file') == 2)
			fprintf('Found parameter file [%s]\n', paramFname);
			wparams = handles.vecManager.readParams(paramFname, 'wparam');
			%Make sure wparam is row vector
			wsz     = size(wparams);
			if(wsz(1) > wsz(2))
				wparams = wparams';
			end
			%if(handles.debug)
				fprintf('Read wparam for frame %d\n', N);
				disp(wparams);
			%end
			opts    = struct('winparams', wparams);
			handles.testFrameBuf = handles.testFrameBuf.setFrameParams(N, opts);
		end
		% Automatically check for moment file
		momentFname = sprintf('%s%s-frame%03d-moments.dat', ps.path, ps.filename, N);
		if(exist(momentFname, 'file') == 2)
			fprintf('Found moment file [%s]\n', momentFname);
			% Just use defaults of 16 iters
			mdata = handles.vecManager.readParams(momentFname, 'moment');
			%if(handles.debug)
				fprintf('Read moments for frame %d\n', N);
                disp(mdata.moments{mdata.niters});
			%end
			opts    = struct('moments', {mdata.moments}, 'nIters', mdata.niters);
			handles.testFrameBuf = handles.testFrameBuf.setFrameParams(N, opts);
		end

	end
	% Convert to bpvec and save into test buffer
    handles.vectors     = vectors;
	handles.testBufRead = true;

	% Preview final image
	%refImg   = handles.refFrameBuf.getCurImg(handles.idx);
	rParams  = handles.refFrameBuf.getWinParams(handles.idx);
	rMoments = handles.refFrameBuf.getMoments(handles.idx);
    % TODO :  Still a problem here with size(vec) in vec2bpimg()
	%testImg  = handles.testFrameBuf.getCurImg(handles.idx);
	tParams  = handles.testFrameBuf.getWinParams(handles.idx);
	tMoments = handles.testFrameBuf.getMoments(handles.idx);
    %errImg   = abs(double(refImg) - double(testImg));
	[refImg testImg errImg] = gui_getImg(handles.refFrameBuf, handles.testFrameBuf, handles.idx, handles.vclass);
	gui_updatePreview(handles.figPreviewRef, refImg, 'Reference', rParams, rMoments);
	gui_updatePreview(handles.figPreviewTest, testImg, 'Test Data', tParams, tMoments);
	gui_updatePreview(handles.figError, errImg, 'Error Image', [], []);

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

function bPatternVerify_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    % Perform a pattern verification
    % TODO : Put this in top menu bar (with a sub GUI)

    guidata(hObject, handles);
    

function pmVecSz_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	% Update the numFiles edit text box whenever this property changes
	vecList = get(handles.pmVecSz, 'String');
	vecIdx  = get(hadnles.pmVecSz, 'Value');
	vecSz   = vecList{vecIdx};
	set(handles.etNumFiles, 'String', vecSz);
	guidata(hObject, handles);

% Get params for GUI update
function [rParams rMoments tParams tMoments] = gui_getParams(refFrameBuf, testFrameBuf, idx)
	
	tParams   = testFrameBuf.getWinParams(idx);
	tMoments  = testFrameBuf.getMoments(idx);
	rParams   = refFrameBuf.getWinParams(idx);
	rMoments  = refFrameBuf.getMoments(idx);

% Generate error image
function [refImg testImg errImg] = gui_getImg(refFrameBuf, testFrameBuf, idx, vclass)

	%handles.vclass
	% TODO : If the class is set as backprojection, then get 
	% backprojection images and find difference.
	% If hue, get the hue image... and so on
	
	switch(vclass)
		case 'RGB'
			refImg  = refFrameBuf.getCurImg(idx, 'mode', 'rgb');
			testImg = testFrameBuf.getCurImg(idx, 'mode', 'rgb');
			errImg  = [];
		case 'HSV'
			refImg  = refFrameBuf.getCurImg(idx, 'mode', 'hsv');
			testImg = testFrameBuf.getCurImg(idx, 'mode', 'hsv');
			errImg  = [];
		case 'Hue'
			refImg  = refFrameBuf.getCurImg(idx, 'mode', 'hue');
			testImg = refFrameBuf.getCurImg(idx, 'mode', 'hue');
			if(~isempty(refImg) && ~isempty(testImg))
				errImg  = abs(refImg - testImg);
			else
				errImg = [];
			end

		case 'backprojection'
			refImg  = refFrameBuf.getCurImg(idx, 'mode', 'bp');
			testImg = testFrameBuf.getCurImg(idx, 'mode', 'bp');
			% TODO : Trial normalising the image here
			refImg  = imgNorm(refImg);
			testImg = imgNorm(testImg);
            if(~isempty(refImg) && ~isempty(testImg))
                errImg  = abs(refImg - testImg);
            else
                errImg = [];
            end

		otherwise
			refImg  = [];
			testImg = [];
			errImg  = [];
	end

% -------- EMPTY FUNCTIONS -------- %
function etImageHeight_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etImageWidth_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecOr_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etFileName_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function etNumFiles_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etGoto_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etTestParams_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etRefParams_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmDataFmt_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmDelimiter_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>

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

function pmDataFmt_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmDelimiter_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
