function varargout = csToolGenerate(varargin)
% CSTOOLGENERATE M-file for csToolGenerate.fig
%      CSTOOLGENERATE, by itself, creates a new CSTOOLGENERATE or raises the existing
%      singleton*.
%
%      H = CSTOOLGENERATE returns the handle to a new CSTOOLGENERATE or the handle to
%      the existing singleton*.
%
%      CSTOOLGENERATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLGENERATE.M with the given input arguments.
%
%      CSTOOLGENERATE('Property','Value',...) creates a new CSTOOLGENERATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolGenerate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolGenerate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolGenerate

% Last Modified by GUIDE v2.5 19-Mar-2013 11:31:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolGenerate_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolGenerate_OutputFcn, ...
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


% --- Executes just before csToolGenerate is made visible.
function csToolGenerate_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INSUL>

    handles.debug       = 0;
	handles.status      = 0;
    handles.previewMode = 'img';  %modes are 'img' and 'bp'
    %Parse 'optional' arguments
    if(~isempty(varargin))
        for k = 1:length(varargin)
            if(ischar(varargin))
                %These are the optional arguments
                if(strncmpi(varargin{k}, 'debug', 5))
                    handles.debug = 1;
                elseif(strncmpi(varargin{k}, 'idx', 3))
                    handles.idx   = varargin{k+1};
                end
            else
                %These are the mandatory arguments
                if(isa(varargin{k}, 'csFrameBuffer'))
                    handles.frameuBuf  = varargin{k};
                elseif(isa(varargin{k}, 'vecManager'))
                    handles.vecManager = varargin{k};
                end
            end
        end
    else
        fprintf('ERROR: Not enough arguments in csToolGenerate()\n');
		handles.status = -1;
        delete(handles.csToolGenerateFig);
        return;
    end

    %Check what we have
    if(~isfield(handles, 'frameBuf'))
        fprintf('ERROR: No frameBuf object in csToolGenerate()\n');
		handles.status = -1;
        delete(handles.csToolGenerateFig);
        return;
    end
    if(~isfield(handles, 'vecManager'))
        fprintf('ERROR: No vecManager objcet in csToolGenerate()\n');
		handles.status = -1;
        delete(handles.csToolGenerateFig);
        return;
    end
    if(~isfield(handles, 'idx'))
        %Since we have been supplied no information about which frame to
        %view, start at first frame
        fprintf('WARNING: No idx parameter, setting index to 1\n');
        handles.idx = 1;
    end

    %Populate GUI elements 
    fmtStr = {'16', '8', '4', '2', 'scalar'};
    orStr  = {'row', 'col'};
    set(handles.pmVecSz,String, fmtStr);
    set(handles.pmVecOr.String, orStr);

    %Check that there are frames in the frame buffer
    if(handles.frameBuf.getNumFrames() < 1)
        %Can't do anything anyway, since no frames loaded (and therefore no
        %segmentation or tracking data)
        fprintf('ERROR: No frames loaded in csTool session, exiting...\n');
        delete(handles.csToolGenerateFig);
        return;
    end
    %Load preview of figure
    fh   = handles.frameBuf.getFrameHandle(handles.idx);
    img  = imread(get(fh, 'filename'), 'TIFF');
    dims = size(img);
    if(dims(3) > 3)
        img = img(:,:,1:3);
    end
    imshow(handles.figPreview, img);
    title(handles.figPreview, sprintf('Frame %d (%s)', idx, get(fh, 'filename')));
    %Clear tickmarks from axes
    set(handles.figPreview, 'XTick', [], 'XTickLabel', []);
    set(handles.figPreview, 'YTick', [], 'YTickLabel', []);

    % Choose default command line output for csToolGenerate
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    uiwait(handles.csToolGenerateFig);



function varargout = csToolGenerate_OutputFcn(hObject, eventdata, handles) %#ok<INUSL> 

    varargout{1} = handles.output;
    %varargout{1} = handles.status;
    delete(handles.csToolGenerateFig);

function bCancel_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %handles.output = status;
    uiresume(handles.csToolGenerateFig);

function bChangePrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Swap preview mode
    if(strncmpi(handles.previewMode, 'img', 3))
        fh   = handles.frameBuf.getFrameHandle(handles.idx);
        img  = imread(get(fh, 'filename'), 'TIFF');
        dims = size(img);
        if(dims(3) > 3)
            img = img(:,:,1:3);
        end
        imshow(handles.figPreview, img);
        title(handles.figPreview, sprintf('Frame %d (%s)', handles.idx, get(fh, 'filename')));
    else
        %Check that there is backprojection data for this frame
        fh   = handles.frameBuf.getFrameHandles(handles.idx);
        if(get(fh, 'bpSum') == 0 || isempty(get(fh, 'bpVec')))
            fprintf('ERROR: No bpData in frame %d\n', handles.idx);
            return;
        else
            bpimg = bpvec2img(get(fh, 'bpVec'), get(fh, 'dims'));
            imshow(handles.figPreview, bpimg);
            str = sprintf('Frame %d (backprojection) (%s)\n', handles.idx, get(fh, 'filename'));
            title(handles.figPreview, str);
        end
    end

    guidata(hObject, handles);
        

function bNext_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Bounds check and increment frame index
    N = handles.frameBuf.getNumFrames();
    if(handles.idx < N)
        handles.idx = handles.idx + 1;
        idx = handles.idx;      %Just to make gui_renderPreview string shorter
        fh  = handles.frameBuf.getFrameHandle(idx);
        gui_renderPreview(handles.figPreview, fh, handles.previewMode, idx);    
	else
        handles.idx = N;
    end
    guidata(hObject, handles);


function bPrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Bounds check and decrement frame index
    if(handles.idx > 1)
        handles.idx = handles.idx - 1;
        idx = handles.idx; %Just to make gui_renderPreview string shorter
        fh  = handles.frameBuf.getFrameHandle(idx);
        gui_renderPreview(handles.figPreview, fh, handles.previewMode, idx);
    else
        handles.idx = 1;
    end
    guidata(hObject, handles);

function bGenerate_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    
    %Gather up all the options and generate the selected vectors

    %What format do we want to pass to vecManager?
    %To avoid having two sets of parsers, just make strings that the
    %command line vecManager would accept out of the drop-down box
    %arguments
    ftype = get(handles.pmVecOr, 'Value');
    val   = get(handles.pmVecSz, 'Value');
    if(strncmpi(ftype, 'row', 3))
        fmt = strcat(val, 'r');
    else
        fmt = strcat(val, 'c');
    end
    fh    = handles.frameBuf.getFrameHandle(handles.idx);
    
    if(get(handles.chkRGB, 'Value'))
        if(handles.debug)
            fprintf('Generating RGB Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
        end
        handles.vecManager.writeRGBVec(fh, fmt);
    end
    if(get(handles.chkHue, 'Value'))
        if(handles.debug)
            fprintf('Generating Hue Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
        end
        handles.vecManager,writeHueVec(fh, fmt);
    end
    if(get(handles.chkHSV, 'Value'))
        if(handles.debug)
            fprintf('Generating HSV Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
        end
        handles.vecManager.writeHSVVec(fh, fmt);
    end
    if(get(handles.chkBP, 'Value'))
        if(handles.debug)
            fprintf('Generating BPVec (%s) for frame %s\n', fmt, get(fh, 'filename'))
        end
        handles.vecManager.writeBPVec(fh, fmt);
    end

    guidata(hObject, handles);


    
% =============================================================== %
%                          RENDER PREVIEW                         %
% =============================================================== %

function gui_renderPreview(axHandle, fh, mode, idx)

    if(strncmpi(mode, 'img', 3))
        img  = imread(get(fh, 'filename'), 'TIFF');
        dims = size(img);
        if(dims(3) > 3)
            img = img(:,:,1:3);
        end
        imshow(axHandle, img);
        title(axHandle, sprintf('Frame %d (%s)', idx, get(fh, 'filename')));
    else
        %Check that there is backprojection data for this frame
        if(get(fh, 'bpSum') == 0 || isempty(get(fh, 'bpVec')))
            fprintf('ERROR: No bpData in frame %d\n', idx);
            return;
        else
            bpimg = bpvec2img(get(fh, 'bpVec'), get(fh, 'dims'));
            imshow(axHandle, bpimg);
            str = sprintf('Frame %d (backprojection) (%s)\n', idx, get(fh, 'filename'));
            title(axHandles, str);
        end
    end


function pmVecSz_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function pmVecOr_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etWriteFile_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etReadFile_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function chkHSV_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkHue_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkBP_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecSz_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function pmVecOr_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etReadFile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etWriteFile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkRGB_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>