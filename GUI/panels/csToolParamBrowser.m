function varargout = csToolParamBrowser(varargin)
% CSTOOLPARAMBROWSER M-file for csToolParamBrowser.fig
%      CSTOOLPARAMBROWSER, by itself, creates a new CSTOOLPARAMBROWSER or raises the existing
%      singleton*.
%
%      H = CSTOOLPARAMBROWSER returns the handle to a new CSTOOLPARAMBROWSER or the handle to
%      the existing singleton*.
%
%      CSTOOLPARAMBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLPARAMBROWSER.M with the given input arguments.
%
%      CSTOOLPARAMBROWSER('Property','Value',...) creates a new CSTOOLPARAMBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolParamBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolParamBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolParamBrowser

% Last Modified by GUIDE v2.5 27-Mar-2013 23:04:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolParamBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolParamBrowser_OutputFcn, ...
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


% --- Executes just before csToolParamBrowser is made visible.
function csToolParamBrowser_OpeningFcn(hObject, eventdata, handles, varargin)	%#ok<INUSL>

	handles.debug = false;
	handles.status = 0;

	%Parse optional parameters (if any)
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'fb', 2))
					handles.frameBuf = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'idx', 3))
					handles.idx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					handles.debug = true;
				end
			end
		end
	end
	
	%Make sure we have required args
	if(~isfield(handles, 'frameBuf'))
		fprintf('ERROR: No frameBuf field specified\n');
		return;
	end
	if(~isfield(handles, 'idx'))
		fprintf('ERROR: No frame index field specified\n');
		return;
	end
	handles.param = 1;		%This could also be read from GUI I suppose...

    %Set GUI elements 
    %fh = handles.frameBuf.getFrameHandle(handles.idx);
    set(handles.etParamData, 'Max', 12);
    set(handles.etParamData, 'HorizontalAlignment', 'left');
    set(handles.etParamData, 'FontSize', 9);

    %Setup axes
    set(handles.figPreview, 'XTick', [], 'XTickLabel', []);
    set(handles.figPreview, 'YTick', [], 'YTickLabel', []);
    %Place initial preview in figure
    cstParam_ShowPreview(handles);
    %status = cstParam_ShowPreview(handles)
    str = cstParam_FmtParamString(handles);
    set(handles.etParamData, 'String', str);

	handles.output = hObject;
	guidata(hObject, handles);

	uiwait(handles.csToolParamBrowser);


% --- Outputs from this function are returned to the command line.
function varargout = csToolParamBrowser_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>

    %Do this just to keep MATLAB as silent as possible
    switch nargout
        case 1
            varargout{1} = handles.idx;
        case 2
            if(handles.debug)
                fprintf('csToolParamBrowser got nargout %d\n', nargout);
            end
            varargout{1} = handles.idx;
            varargout{2} = handles.status;
    end
	%delete(handles.csToolParamBrowser);


function bPrevFrame_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx - 1;
	%silently clip index to within range
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames())
		idx = handles.frameBuf.getNumFrames();
	end
	handles.idx = idx;
    fh = handles.frameBuf.getFrameHandle(handles.idx);
    status = cstParam_ShowPreview(handles);
    if(status == -1)
        return;
    end
    str = cstParam_FmtParamString(handles);
    set(handles.etParamData, 'String', str);
    [exitflag fname num] = fname_parse(get(fh, 'filename'));
    if(exitflag == -1)
        return;
    end
    %set(handles.figPreview, 'Title', fname, 'Interpreter', 'None');
    title(handles.figPreview, sprintf('%s_%d', fname, num), 'Interpreter', 'None');
	guidata(hObject, handles);
	

	uiresume(handles.csToolParamBrowser);

function bNextFrame_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx + 1;
	%silently clip index to within range
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames())
		idx = handles.frameBuf.getNumFrames();
	end
	handles.idx = idx;
    fh = handles.frameBuf.getFrameHandle(handles.idx);
    status = cstParam_ShowPreview(handles);
    if(status == -1)
        return;
    end
    str = cstParam_FmtParamString(handles);
    set(handles.etParamData, 'String', str);
    [exitflag fname num] = fname_parse(get(fh, 'filename'));
    if(exitflag == -1)
        return;
    end
    %set(handles.figPreview, 'Title', fname, 'Interpreter', 'None');
    title(handles.figPreview, sprintf('%s_%d', fname, num), 'Interpreter', 'None');
	guidata(hObject,handles);

	uiresume(handles.csToolParamBrowser);
	
function bPrevParam_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx;
	%Bonuds check idx
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames());
		idx = handles.frameBuf.getNumFrames();
	end
	fh    = handles.frameBuf.getFrameHandle(idx);
	N     = get(fh, 'nIters');
	pidx  = handles.param - 1;
	%Bounds check parameter index
	if(pidx < 1)
		pidx = 1;
	end
	if(pidx > N)
		pidx = N;
	end
	%[status pstr] = gui_printParams(fh, 'iter', pidx, 'sup');
	%if(status == -1)
	%	return;
	%end
	%set(handles.tParamText, 'String', pstr);
    str = cstParam_FmtParamString(handles);
    set(handles.etParamData, 'String', str);
	handles.param = pidx;
	guidata(hObject, handles);
	
	uiresume(handles.csToolParamBrowser);


function bNextParam_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	idx = handles.idx;
	%Bonuds check idx
	if(idx < 1)
		idx = 1;
	end
	if(idx > handles.frameBuf.getNumFrames());
		idx = handles.frameBuf.getNumFrames();
	end
	fh    = handles.frameBuf.getFrameHandle(idx);
	N     = get(fh, 'nIters');
	pidx  = handles.param + 1;
	%Bounds check parameter index
	if(pidx < 1)
		pidx = 1;
	end
	if(pidx > N)
		pidx = N;
	end
	%[status pstr] = gui_printParams(fh, 'iter', pidx, 'sup');
	%if(status == -1)
	%	return;
	%end
	%set(handles.tParamText, 'String', pstr);
    str = cstParam_FmtParamString(handles);
    set(handles.etParamData, 'String', str);
	handles.param = pidx;
	guidata(hObject, handles);
	
	uiresume(handles.csToolParamBrowser);

function bDone_Callback(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	uiresume(handles.csToolParamBrowser);
	delete(handles.csToolParamBrowser);


function csToolParamBrowser_CloseRequestFcn(hObject, eventdata, handles)	%#ok<INUSL,DEFNU>

	uiresume(handles.csToolParamBrowser);
	delete(hObject);

function str = cstParam_FmtParamString(handles)   
    %Format string containing parameter data.
    fh = handles.frameBuf.getFrameHandle(handles.idx);
    N  = handles.frameBuf.getNumFrames();
    
    %get data to appear in string
    moments = get(fh, 'moments');
    wparam  = get(fh, 'winParams');
    m       = moments{handles.param};
    if(length(m) == 6)
        xc = m(2)/m(1);
        yc = m(3)/m(1);
    else
        %Normalised
        xc = m(1);
        yc = m(2);
    end
    theta   = wparam(3);
    axmaj   = wparam(4);
    axmin   = wparam(5);

    %Title string
    st = sprintf('Frame : %s (%d/%d)', get(fh, 'filename'), handles.idx, N);
    sp = sprintf('Param : (%d/%d)', handles.param, get(fh, 'nIters'));
    if(get(fh, 'isSparse'))
        sd = sprintf('Sparse : yes\nFactor : %d', get(fh, 'sparseFac'));
    else
        sd = sprintf('Sparse : no');
    end
    dims = get(fh, 'dims');
	%TODO: The string naming convention used here needs an update...
    ss = sprintf('Frame reports dims [%dx%d]', dims(1), dims(2));
	sn = sprintf('Iterations in frame ; %d', get(fh, 'nIters'));
    s1 = sprintf('xc : %.1f, yc : %.1f', xc ,yc);
    s2 = sprintf('theta : %.1f', theta);
    s3 = sprintf('axmaj : %.1f', axmaj);
    s4 = sprintf('axmin : %.1f', axmin);

    str = {st, sp, ' ', sd, ss, sn, ' ', s1, s2, s3, s4};

    %uiresume(handles.csToolParamBrowser);

function status = cstParam_ShowPreview(handles)

    fh = handles.frameBuf.getFrameHandle(handles.idx);
    bpvec = get(fh, 'bpVec');
    bpdims = get(fh, 'dims');
    bpimg  = vec2bpimg(bpvec, bpdims);
    if(isempty(bpimg) || numel(bpimg) == 0)
        fprintf('ERROR: Incorrect bpvec conversion in cstParam_ShowPreview()\n');
        status = -1;
        return;
    end
    status = gui_plotParams(fh, handles.figPreview, 'num', handles.param);
    if(status == -1)
        fprintf('Formatting issue in gui_plotParams()\n');
        return;
    end
    imshow(bpimg, 'parent', handles.figPreview);
    status = 0;
    


function etParamData_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>

function etParamData_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
