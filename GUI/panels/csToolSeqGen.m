function varargout = csToolSeqGen(varargin)
% CSTOOLSEQGEN M-file for csToolSeqGen.fig
%      CSTOOLSEQGEN, by itself, creates a new CSTOOLSEQGEN or raises the existing
%      singleton*.
%
%      H = CSTOOLSEQGEN returns the handle to a new CSTOOLSEQGEN or the handle to
%      the existing singleton*.
%
%      CSTOOLSEQGEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLSEQGEN.M with the given input arguments.
%
%      CSTOOLSEQGEN('Property','Value',...) creates a new CSTOOLSEQGEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolSeqGen_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolSeqGen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolSeqGen

% Last Modified by GUIDE v2.5 18-Feb-2014 12:01:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolSeqGen_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolSeqGen_OutputFcn, ...
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


% --- Executes just before csToolSeqGen is made visible.
function csToolSeqGen_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolSeqGen (see VARARGIN)


	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'genopts', 7))
					handles.genOpts = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					handles.verbose = true;
				elseif(strncmpi(varargin{k}, 'init', 4))
					initFrame = varargin{k+1};
				end
			else
				if(isa(varargin{k}, 'csFrameBuffer'))
					handles.frameBuf = varargin{k};
				end
			end
		end
	end

	% Check what we have
	if(~exist('initFrame', 'var'))
		initFrame = 1;
	end
	if(~isfield('genOpts', handles) || isempty(handles.genOpts))
		if(handles.verbose)
			fprintf('WARNING: No generation opts specified, using defaults\n');
		end

		genOpts = struct('imsz', [640 480], ...
			             'nframes', 64, ...
			             'maxspd', 32, ...
			             'dist', 'normal', ...
			             'npoints', 128, ...
			             'sfac', 1, ...
			             'wRes', 1, ...
			             'tsize', [64 64], ...
			             'loc', 0.5*[640 480], ...
			             'theta', 0 );
		handles.genOpts = genOpts;
	end
	if(~isfield('frameBuf', handles))
		% Generate a new csFrameBuffer
		if(handles.verbose)
			fprintf('WARNING: No csFrameBuffer specified, generating new buffer\n');
		end
		fbOpts = struct('nFrames', handles.genOpts.nframes, ...
			            'path', [], ...
			            'ext', 'TIF', ...
			            'fNum', 1, ...
			            'fName', [], ...
			            'renderMode', 1, ...
			            'verbose', handles.verbose );
		handles.frameBuf = csFrameBuffer(fbOpts);	
	end

	% Populate GUI elements
	set(handles.etNumPoints, 'String', num2str(handles.genOpts.npoints));
	set(handles.etNumFrames, 'String', num2str(handles.genOpts.nframes));
	set(handles.etScaleFac,  'String', num2str(handles.genOpts.sfac));
	set(handels.etWRes,      'String', num2str(handles.genOpts.wRes));
	set(handles.etMaxSpeed,  'String', num2str(handles.genOpts.maxspd));
	set(handles.etImgWidth,  'String', num2str(handles.genOpts.imsz(1)));
	set(handles.etImgHeight, 'String', num2str(handles.genOpts.imsz(2)));
	set(handles.etLocX,      'String', num2str(handles.genOpts.loc(1)));
	set(handles.etLocY,      'String', num2str(handles.genOpts.loc(2)));
	distStr = {'normal', 'uniform'};
	set(handles.pmDistribution, 'String', distStr);
	if(strncmpi(handles.genOpts.dist, 'normal', 6))
		set(handles.pmDistribution, 'Value', 1);
	else
		set(handles.pmDistribution, 'Value', 2);
	end

	% Setup preview axes
	set(handles.figPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.figPreview, 'YTick', [], 'YTickLabel', []);

	handles.fbIdx = initFrame;
	set(handles.etFrame, 'String', num2str(handles.fbIdx));
	set(handles.etCurFrame, 'String', num2str(handles.fbIdx));
	handles.cancelled = 0;
	% Choose default command line output for csToolSeqGen
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);
	uiwait(handles.csToolSeqGen);


function varargout = csToolSeqGen_OutputFcn(hObject, eventdata, handles)%#ok<INUSL>
	handles.output = struct('status', handles.cancelled, ...
		                    'frameBuf', handles.frameBuf, ...
		                    'genOpts',  handles.genOpts );
	varargout{1} = handles.output;

function csToolSeqGen_CloseRequestFcn(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
    if(isequal(get(hObject, 'waitstatus'), 'waiting'))
        %Still waiting on GUI
        uiresume(handles.csToolSeqGen);
    else
        %Ok to clean up
        delete(handles.csToolSeqGen);
    end


% ======== RENDER GUI PREVIEW ======== %
function gui_updatePreview(ah, fh)
	% Update preview window with generated frame handle contents
	
	vecdata = get(fh, 'bpVec');
	vecimg  = vec2bpimg(vecdata, 'dims', get(fh, 'dims'));
	imshow(vecimg, 'Parent', ah);
	

% ======= BUTTON CALLBACKS ======== %
%
function bPrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Bounds check and decrement frame index
	if(handles.fbIdx > 1)
		handles.fbIdx = handles.fbIdx - 1;
		fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
		gui_updatePreview(handles.figPreview, fh);
	else
		handles.fbIdx = 1;
	end
	set(handles.etCurFrame, 'String', num2str(handles.fbIdx));

	guidata(hObject, handles);
	uiresume(handles.csToolSeqGen);

function bNext_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Bounds check and increment frame index
	N = handles.frameBuf.getNumFrames();
	if(handles.fbIdx < N)
		handles.fbIdx = handles.fbIdx + 1;
		fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
		gui_updatePreview(handles.figPreview, fh);
	else
		handles.fbIdx = N;
	end
	set(handles.etCurFrame, 'String', num2str(handles.fbIdx));

	guidata(hObject, handles);
	uiresume(handles.csToolSeqGen);

function bFirst_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	handles.fbIdx = 1;
	fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
	gui_updatePreview(handles.figPreview, fh);
	set(handles.etCurFrame, 'String', num2str(handles.fbIdx));

	guidata(hObject, handles);
	uiresume(handles.csToolSeqGen);

function bLast_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	handles.fbIdx = handles.frameBuf.getNumFrames();
	fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
	gui_updatePreview(handles.figPreview, fh);
	set(handles.etCurFrame, 'String', num2str(handles.fbIdx));

	guidata(hObject, handles);
	uiresume(handles.csToolSeqGen);

function bGoto_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Jump to specified frame 
	fn = fix(str2double(get(handles.etFrame, 'String')));

	if(fn < 1)
		fn = 1;
	end
	if(fn > handles.frameBuf.getNumFrames())
		fn = handles.frameBuf.getNumFrames();
	end
	handles.fbIdx = fn;
	fh = handles.frameBuf.getFrameHandle(fn);
	gui_updatePreview(handles.figPreview, fh);
	set(handles.etCurFrame, 'String', num2str(handles.fbIdx));

	guidata(hObject, handles);
	uiresume(handles.csToolSeqGen);

function bGenerate_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Generate Random Sequence

	handles = gui_disable(handles, 'off');
	% Format options structure
	npoints = fix(str2double(get(handles.etNumPoints, 'String')));
	nframes = fix(str2double(get(handles.etNumFrames, 'String')));
	sfac    = fix(str2double(get(handles.etScaleFac,  'String')));
	wRes    = fix(str2double(get(handles.etWRes,      'String')));
	maxspd  = fix(str2double(get(handles.etMaxSpeed,  'String')));
	img_w   = fix(str2double(get(handles.etImgWidth,  'String')));
	img_h   = fix(str2double(get(handles.etImgHeight, 'String')));
	distidx = get(handles.pmDistribution, 'Value');
	diststr = get(handles.pmDistribution, 'String');
	dist    = diststr{distidx};
	imsz    = [img_w img_h];
	loc_x   = fix(str2double(get(handles.etLocX,      'String')));
	loc_y   = fix(str2double(get(handles.etLocY,      'String')));
	loc     = [loc_x loc_y];

	opts    = struct('imsz', imsz, ...
	                 'nframes', nframes, ...
		             'maxspd', maxspd, ...
		             'dist', dist, ...
		             'npoints', npoints, ...
		             'sfac', sfac, ...
		             'wRes', wRes, ...
		             'theta', 0, ...
		             'tsize', [64 64], ...
		             'loc', loc, ...
		             'kernel', [] );
	
	handles.frameBuf = handles.frameBuf.genRandSeq('opts', opts);
	handles = gui_disable(handles, 'on');
	
	%handles.framBuf.genRandSeq('imsz', opts.imsz, ...
	%	                       'nframes', opts.nframes, ...
	%	                       'maxspd', opts.maxspd, ...
	%	                       'dist', opts.dist, ...
	%	                       'npoints', opts.npoints, ...
	%	                       'sfac', opts.sfac, ...
	%	                       'theta', opts.theta );
	
	handles.genOpts = opts;
	% Update preview
	fh = handles.frameBuf.getFrameHandle(handles.fbIdx);
	gui_updatePreview(handles.figPreview, fh);

	guidata(hObject, handles);
	uiresume(handles.csToolSeqGen);

function bDone_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	%handles.output = struct('status', 0, ...
	%	                    'frameBuf', handles.frameBuf, ...
	%	                    'genOpts', handles.genOpts );
	handles.cancelled = 0;
	uiresume(handles.csToolSeqGen);
	close(handles.csToolSeqGen);

function bCancel_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	%handles.output = struct('status', -1, ...
	%	                    'frameBuf', handles.frameBuf, ...
	%	                    'genOpts', handles.genOpts);
	handles.cancelled = -1;
	uiresume(handles.csToolSeqGen);
	close(handles.csToolSeqGen);

function figPreview_ButtonDownFcn(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	% Generate new location on button click
	img_w = fix(str2double(get(handles.etImgWidth, 'String')));
	img_h = fix(str2double(get(handles.etImgHeight, 'String')));

% ======== DISABLE GUI WHILE RENDERING ======== %

function nh = gui_disable(handles, state)
	% Disable GUI elements (for example, during processing)
	
	if(ischar(state))
		if(strncmpi(state, 'on', 2))
			ENABLE = true;
		else
			ENABLE = false;
		end
	else
		if(state > 0)
			ENABLE = true;
		else
			ENABLE = false;
		end
	end

	if(ENABLE)
		ifaceObj = findobj(handles.csToolSeqGen, 'Enable', 'off');
		set(ifaceObj, 'Enable', 'on');
		set(handles.csToolSeqGen, 'Name', 'csToolSeqGen');
	else
		ifaceObj = findobj(handles.csToolSeqGen, 'Enable', 'on');
		set(ifaceObj, 'Enable', 'off');
		set(handles.csToolSeqGen, 'Name', 'Processing...');
	end

	nh = handles;



% ======== CREATE FUNCTIONS ======== %
% --- Executes during object creation, after setting all properties.
function etMaxSpeed_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etScaleFac_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etNumFrames_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgHeight_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etNumPoints_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgWidth_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmDistribution_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etFrame_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etCurFrame_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etLocX_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etLocY_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end


% ======== EMPTY FUNCTIONS ======== %

function etNumPoints_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgWidth_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgHeight_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etNumFrames_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etScaleFac_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etMaxSpeed_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmDistribution_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etFrame_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etCurFrame_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etLocY_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etLocX_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>



function etWRes_Callback(hObject, eventdata, handles)
% hObject    handle to etWRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etWRes as text
%        str2double(get(hObject,'String')) returns contents of etWRes as a double


% --- Executes during object creation, after setting all properties.
function etWRes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etWRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
