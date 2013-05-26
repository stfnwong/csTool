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

% Last Modified by GUIDE v2.5 02-May-2013 17:58:59

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
function csToolGenerate_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

    handles.debug       = 0;
	handles.status      = 0;
    handles.previewMode = 'bp';  %modes are 'img' and 'bp'
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
                    handles.frameBuf  = varargin{k};
                elseif(isa(varargin{k}, 'vecManager'))
                    handles.vecManager = varargin{k};
                end
            end
        end
    else
        fprintf('ERROR: Not enough arguments in csToolGenerate()\n');
		handles.output = -1;
        delete(handles.csToolGenerateFig);
        return;
    end

    %Check what we have
    if(~isfield(handles, 'frameBuf'))
        fprintf('ERROR: No frameBuf object in csToolGenerate()\n');
		handles.output = -1;
        %delete(handles.csToolGenerateFig);
        return;
    end
    if(~isfield(handles, 'vecManager'))
        fprintf('ERROR: No vecManager object in csToolGenerate()\n');
		handles.output = -1;
        delete(handles.csToolGenerateFig);
        return;
    end
    if(~isfield(handles, 'idx'))
        %Since we have been supplied no information about which frame to
        %view, start at first frame
        fprintf('WARNING: No idx parameter, setting index to 1\n');
        handles.idx = 1;
    end

    if(handles.debug)
        %Show the current values of input parameters
        fprintf('DEBUG: idx set to    : %d\n', handles.idx);
        fprintf('DEBUG: frameBuf size : %d\n', handles.frameBuf.getNumFrames());
    end

    %Populate GUI elements 
    vOpts  = handles.vecManager.getOpts();
    fmtStr = {'16', '8', '4', '2', 'scalar'};
    orStr  = {'row', 'col'};
    set(handles.pmVecSz, 'String', fmtStr);
    set(handles.pmVecOr, 'String', orStr);
    %Make default selection 2c
    set(handles.pmVecSz, 'Value', 4);
    set(handles.pmVecOr, 'Value', 2);
	%Check filenames in vecManager object, and load into filename field
	if(strcmpi(vOpts.wfilename, ' '))
		set(handles.etWriteFile, 'String', 'data/vectors/imvec.dat');
	else
		set(handles.etWriteFile, 'String', vOpts.wfilename);
	end

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
    imshow(img, 'Parent', handles.figPreview);
    title(handles.figPreview, sprintf('Frame %d (%s)', handles.idx, get(fh, 'filename')));
    %Clear tickmarks from axes
    set(handles.figPreview, 'XTick', [], 'XTickLabel', []);
    set(handles.figPreview, 'YTick', [], 'YTickLabel', []);

    %Place current filnames on GUI
    %TODO: Have a checkbox that toggles between using the filename with _vecdata.dat 
    %appended, or using the filename in vecManager.rfilename, vecManager.filename
    %[str num ext path exitflag] = fname_parse(get(fh, 'filename'));	%#ok
	%set(handles.etReadFile, 'String', sprintf('%s_vecdata.dat', str));
	%set(handles.etWriteFile, 'String', sprintf('%s_testdata.dat', str));
    %set(handles.etReadFile, 'String', handles.vecManager.getRfilename());
    set(handles.etWriteFile, 'String', handles.vecManager.getWfilename());

    %Show preview of input frame
    fh = handles.frameBuf.getFrameHandle(handles.idx);
    gui_renderPreview(handles.figPreview, fh, handles.previewMode, handles.idx);

    % Choose default command line output for csToolGenerate
    %handles.output = hObject;
    handles.output = 0;
    % Update handles structure
    guidata(hObject, handles);
    uiwait(handles.csToolGenerateFig);



function varargout = csToolGenerate_OutputFcn(hObject, eventdata, handles) %#ok<INUSD> 

    varargout{1} = 0;
    %varargout{1} = handles.output;
    %varargout{1} = handles.status;
    %delete(handles.csToolGenerateFig);

function bCancel_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    handles.output = 0;
    uiresume(handles.csToolGenerateFig);
    delete(handles.csToolGenerateFig);

function bChangePrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Swap preview mode
    if(strncmpi(handles.previewMode, 'img', 3))
        %Check that there is backprojection data for this frame
        fh   = handles.frameBuf.getFrameHandle(handles.idx);
        if(get(fh, 'bpSum') == 0 || isempty(get(fh, 'bpVec')))
            fprintf('ERROR: No bpData in frame %d\n', handles.idx);
            return;
        else
            bpimg = vec2bpimg(get(fh, 'bpVec'), get(fh, 'dims'));
            imshow(bpimg, 'Parent', handles.figPreview);
            str = sprintf('Frame %d (backprojection) (%s)\n', handles.idx, get(fh, 'filename'));
            title(handles.figPreview, str);
            handles.previewMode = 'img';
        end
        
    else
        fh   = handles.frameBuf.getFrameHandle(handles.idx);
        img  = imread(get(fh, 'filename'), 'TIFF');
        dims = size(img);
        if(dims(3) > 3)
            img = img(:,:,1:3);
        end
        imshow(img, 'Parent', handles.figPreview);
        title(handles.figPreview, sprintf('Frame %d (%s)', handles.idx, get(fh, 'filename')));
        handles.previewMode = 'bp';
    end

    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);
        

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
    %Update output filename if UseFrameFilename checked
    if(get(handles.chkUseFrameFilename, 'Value'))
        fh = handles.frameBuf.getFrameHandle(handles.idx);
        [ef str num] = fname_parse(get(fh, 'filename'));
        if(ef == -1)
            fprintf('ERROR: Couldnt parse filename (%s)\n', get(fh, 'filename'));
            return;
        end
        fname = sprintf('data/vectors/%s%02d', str, num);
        %fname = get(fh, 'filename');
        set(handles.etWriteFile, 'String', fname);
    end
    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);


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
    %Update output filename if UseFrameFilename checked
    if(get(handles.chkUseFrameFilename, 'Value'))
        fh = handles.frameBuf.getFrameHandle(handles.idx);
        [ef str num] = fname_parse(get(fh, 'filename'));
        if(ef == -1)
            fprintf('ERROR: Couldnt parse filename (%s)\n', get(fh, 'filename'));
            return;
        end
        fname = sprintf('data/vectors/%s%02d', str, num);
        %fname = get(fh, 'filename');
        set(handles.etWriteFile, 'String', fname);
    end
    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);

function bGenerate_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    
    %Gather up all the options and generate the selected vectors

    %What format do we want to pass to vecManager?
    %To avoid having two sets of parsers, just make strings that the
    %command line vecManager would accept out of the drop-down box
    %arguments
    ftype = get(handles.pmVecOr, 'Value');
	vstr  = get(handles.pmVecSz, 'String');
    %val   = vstr(get(handles.pmVecSz, 'Value'));
    val   = vstr{get(handles.pmVecSz, 'Value')};
    if(strncmpi(ftype, 'scalar', 6))
        fmt = 'scalar';
    elseif(strncmpi(ftype, 'row', 3))
        fmt = strcat(num2str(val), 'r');
    else
        fmt = strcat(num2str(val), 'c');
    end
    fh    = handles.frameBuf.getFrameHandle(handles.idx);
    fname = get(handles.etWriteFile, 'String');
	%Set the filename in the vecManager object as well 
	%TODO: Update the internal file handling scheme to automatically generate 
	%properly numbered files
	handles.vecManager = handles.vecManager.setWLoc(fname);
    
    if(get(handles.chkRGB, 'Value'))
        if(handles.debug)
            fprintf('Generating RGB Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
        end
        handles.vecManager.writeRGBVec(fh, 'fmt', fmt, 'file', fname);
    end
    if(get(handles.chkHue, 'Value'))
        if(handles.debug)
            fprintf('Generating Hue Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
        end
        handles.vecManager.writeHueVec(fh, 'fmt', fmt, 'file', fname);
    end
    if(get(handles.chkHSV, 'Value'))
        if(handles.debug)
            fprintf('Generating HSV Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
        end
        handles.vecManager.writeHSVVec(fh, 'fmt', fmt, 'file', fname);
    end
    if(get(handles.chkBP, 'Value'))
        if(handles.debug)
            fprintf('Generating BPVec (%s) for frame %s\n', fmt, get(fh, 'filename'))
        end
        handles.vecManager.writeBPVec(fh, 'fmt', fmt, 'file', fname);
    end

    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);
    delete(handles.csToolGenerateFig);

function chkUseFrameFilename_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Modify the value of rfilename and wfilename when this is checked 

    chk = get(handles.chkUseFrameFilename, 'Value');

    if(chk)
        %Convert output filename to match frame filename
        fh    = handles.frameBuf.getFrameHandle(handles.idx);
        fname = sprintf('%s-vec.dat', get(fh, 'filename'));
    else
        fname = handles.vecManager.getWfilename();
    end
    set(handles.etWriteFile, 'String', fname);

    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);
    
% =============================================================== %
%                          RENDER PREVIEW                         %
% =============================================================== %

function gui_renderPreview(axHandle, fh, prevMode, idx)

    if(strncmpi(prevMode, 'img', 3))
        img  = imread(get(fh, 'filename'), 'TIFF');
        dims = size(img);
        if(dims(3) > 3)
            img = img(:,:,1:3);
        end
        imshow(img, 'Parent', axHandle);
        [exitflag fname num] = fname_parse(get(fh, 'filename'));
        if(exitflag == -1)
            return;
        end
        title(axHandle, sprintf('Frame %d (%s_%d)', idx, fname, num), 'Interpreter', 'None');
    else
        %Check that there is backprojection data for this frame
        if(get(fh, 'bpSum') == 0 || isempty(get(fh, 'bpVec')))
            fprintf('ERROR: No bpData in frame %d\n', idx);
            return;
        else
            bpimg = vec2bpimg(get(fh, 'bpVec'), get(fh, 'dims'));
            imshow(bpimg, 'Parent', axHandle);
            [exitflag fname num] = fname_parse(get(fh, 'filename'));
            if(exitflag == -1)
                return;
            end
            str = sprintf('Frame %d (backprojection) (%s_%d)\n', idx, fname, num);
            title(axHandle, str, 'Interpreter', 'None');
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


% --- Executes when user attempts to close csToolGenerateFig.
function csToolGenerateFig_CloseRequestFcn(hObject, eventdata, handles) %#ok <INUSL,DEFNU>
% hObject    handle to csToolGenerateFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in bUIgetfile.
function bUIgetfile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    %Take filename and path from uigetfile, and place into etWriteFile
    %String field
    [fname path] = uiputfile('*.dat', 'Save Vector As...');
    set(handles.etWriteFile, 'String', sprintf('%s%s', path, fname));
    guidata(hObject, handles);

