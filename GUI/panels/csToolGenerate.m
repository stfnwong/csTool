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

% Last Modified by GUIDE v2.5 11-Aug-2013 14:49:47

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
            if(ischar(varargin{k}))
                %These are the optional arguments
                if(strncmpi(varargin{k}, 'debug', 5))
                    handles.debug = 1;
                elseif(strncmpi(varargin{k}, 'idx', 3))
                    handles.idx   = varargin{k+1};
                elseif(strncmpi(varargin{k}, 'mhist', 5))
                    handles.mhist = varargin{k+1};
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
        %delete(handles.csToolGenerateFig);
        return;
    end
    if(~isfield(handles, 'idx'))
        %Since we have been supplied no information about which frame to
        %view, start at first frame
        fprintf('WARNING: No idx parameter, setting index to 1\n');
        handles.idx = 1;
    end
    if(~isfield(handles, 'mhist'))
        %Without model histogram, can't produce mhist vec
        fprintf('WARNING; no mhist parameter, setting to 16 zeros\n');
        handles.mhist = zeros(1,16);
    end

    if(handles.debug)
        %Show the current values of input parameters
        fprintf('DEBUG: idx set to    : %d\n', handles.idx);
        fprintf('DEBUG: frameBuf size : %d\n', handles.frameBuf.getNumFrames());
    end

    %Populate GUI elements 
    vOpts  = handles.vecManager.getOpts();
    fmtStr = {'16', '8', '4', '2'};
    orStr  = {'row', 'col', 'scalar'};
    set(handles.pmVecSz, 'String', fmtStr);
    set(handles.pmVecOr, 'String', orStr);
    %Make default selection 16c
	%TODO :  Check value in vOpts
    set(handles.pmVecSz, 'Value', 1);
    set(handles.pmVecOr, 'Value', 2);
    %Set default range to be entire frameBuffer
    set(handles.etLow, 'String', '1');
    %set(handles.etHigh, 'String', num2str(get(handles.frameBuf.getNumFrames())));
    set(handles.etHigh, 'String', '1');
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
	img   = handles.frameBuf.getCurImg(handles.idx);
	fname = handles.frameBuf.getFilename(handles.idx);
    imshow(img, 'Parent', handles.figPreview);
    title(handles.figPreview, sprintf('Frame %d (%s)', handles.idx, fname));
    %Clear tickmarks from axes
    set(handles.figPreview, 'XTick', [], 'XTickLabel', []);
    set(handles.figPreview, 'YTick', [], 'YTickLabel', []);
    set(handles.etWriteFile, 'String', handles.vecManager.getWfilename());

    %Show preview of input frame
    gui_renderPreview(handles.figPreview, img, handles.idx, fname);

    % Choose default command line output for csToolGenerate
    %handles.output = hObject;
    handles.output = 0;
    % Update handles structure
    guidata(hObject, handles);
    uiwait(handles.csToolGenerateFig);



function varargout = csToolGenerate_OutputFcn(hObject, eventdata, handles) %#ok<INUSD> 

    varargout{1} = 0;

function bCancel_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    handles.output = 0;
    uiresume(handles.csToolGenerateFig);
    delete(handles.csToolGenerateFig);

function bChangePrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
 
 	%Swap preview mode
	if(strncmpi(handles.previewMode, 'img', 3))
        %Check that there is backprojection data for this frame
		if(~handles.frameBuf.hasBpData(handles.idx))
			fprintf('ERROR: No bpData in frame %d\n', handles.idx);
			return;
		end
		img = handles.frameBuf.getCurImg(handles.idx, 'bpimg');
		imshow(img, 'Parent', handles.figPreview);
		str = sprintf('Frame %d (backprojection) %s\n', idx, handles.frameBuf.getFilename(handles.idx));
		title(handles.figPreview, str);
		handles.previewMode = 'bp';
	else
		img = handles.frameBuf.getCurImg(handles.idx, 'img');
		if(isempty(img))
			fprintf('ERROR: No image data in frame %d\n', handles.idx);
			return;
		end
		imshow(img, 'Parent', handles.figPreview);
		str = sprintf('Frame %d (%s)', handles.idx, handles.frameBuf.getFilename(handles.idx));
		title(handles.figPreview, str);
		handles.previewMode = 'img';
	end

    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);
        

function bNext_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    
	%Bounds check and increment frame index
    N = handles.frameBuf.getNumFrames();
    if(handles.idx < N)
        handles.idx = handles.idx + 1;
		if(strncmpi(handles.previewMode, 'img', 3))
			img = handles.frameBuf.getCurImg(handles.idx, 'img');
		else
			img = handles.frameBuf.getCurImg(handles.idx, 'bpimg');
		end
		filename = handles.frameBuf.getFilename(handles.idx);
        gui_renderPreview(handles.figPreview, img, handles.idx, filename);
	else
        handles.idx = N;
    end
    %Update output filename if UseFrameFilename checked
    if(get(handles.chkUseFrameFilename, 'Value'))
		filename = handles.frameBuf.getFilename(handles.idx);
		fs = fname_parse(filename);
		if(fs.exitflag == -1)
            fprintf('ERROR: Couldnt parse filename (%s)\n', filename);
            return;
		end
        fname = sprintf('data/vectors/%s%02d', fs.filename, fs.vecNum);
        %fname = get(fh, 'filename');
        set(handles.etWriteFile, 'String', fname);
    end
    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);


function bPrev_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    
	%Bounds check and decrement frame index
    if(handles.idx > 1)
        handles.idx = handles.idx - 1;
		if(strncmpi(handles.previewMode, 'img', 3))
			img = handles.frameBuf.getCurImg(handles.idx, 'img');
		else
			img = handles.frameBuf.getCurImg(handles.idx, 'bpimg');
		end
		filename = handles.frameBuf.getFilename(handles.idx);
        gui_renderPreview(handles.figPreview, img, handles.idx, filename);
    else
        handles.idx = 1;
    end
    %Update output filename if UseFrameFilename checked
    if(get(handles.chkUseFrameFilename, 'Value'))
		filename = handles.frameBuf.getFilename(handles.idx);
		fs = fname_parse(filename);
		if(fs.exitflag == -1)
            fprintf('ERROR: Couldnt parse filename (%s)\n', filename);
            return;
		end
        fname = sprintf('data/vectors/%s%02d', fs.filename, fs.vecNum);
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
	
    vstr   = get(handles.pmVecOr, 'String');
    vidx   = get(handles.pmVecOr, 'Value');
    vtype  = vstr{vidx};
	valstr = get(handles.pmVecSz, 'String');
    val    = valstr{get(handles.pmVecSz, 'Value')};
    if(strncmpi(vtype, 'scalar', 6))
        fmt = 's';
    elseif(strncmpi(vtype, 'row', 3))
        fmt = strcat(num2str(val), 'r');
    else
        fmt = strcat(num2str(val), 'c');
    end
	val = fix(str2double(val));

	if(get(handles.chkGenRange, 'Value'))
		lr = fix(str2double(get(handles.etLow,  'String')));
		hr = fix(str2double(get(handles.etHigh, 'String')));
		if(isnan(lr) || isnan(hr))
			fprintf('ERROR: Non-number value in range\n');
			range = [1 1];
		else
			range = [lr hr];
		end
	else
		range = [1 1];
	end

	% Generate filename(s)
	filename = handles.frameBuf.getFilename(range(1));
	fs = fname_parse(filename);
	if(fs.exitflag == -1)
		fprintf('ERROR: parse error in filename %s\n', filename);
		return;
	end
	if(range(2) > 1)
		fname = cell(1, range(2));
		for k = range(1) : range(2)
			fname{k} = sprintf('%s-%03d.dat', fs.filename, k);
		end
	else
		fname{1} = sprintf('%s.dat', fs.filename);
	end

	% TODO : For now hard code scale at 256 - add GUI control for this
	scale = 256;

	% Generate vectors as required
	for idx = range(1) : range(2)

		% Format options structure
		opts = struct('vtype', vtype, ...
			          'val', val, ...
			          'scale', scale, ...
			          'fname', fname{idx});
		
		% --- RGB Vector --- %
		if(get(handles.chkRGB, 'Value'))
			if(handles.debug)
				fprintf('Generating RGB Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
			end
			img = handles.frameBuf.getCurImg(idx, 'img');
			handles.vecManager.writeImgVec(img, opts, 'rgb');
			%handles.vecManager.writeRGBVec(fh, 'fmt', fmt, 'file', fname);
		end

		% --- Hue Vector --- %
		if(get(handles.chkHue, 'Value'))
			if(handles.debug)
				fprintf('Generating Hue Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
			end
			img = handles.frameBuf.getCurImg(idx, 'img');
			img = rgb2hsv(img);
			img = img(:,:,1);
			handles.vecManager.writeImgVec(img, opts, 'hue');
			%handles.vecManager.writeHueVec(fh, 'fmt', fmt, 'file', fname);
		end

		% ---- HSV Vector ---- %
		if(get(handles.chkHSV, 'Value'))
			if(handles.debug)
				fprintf('Generating HSV Vec (%s) for frame %s\n', fmt, get(fh, 'filename'));
			end
			img = handles.frameBuf.getCurImg(idx, 'img');
			img = rgb2hsv(img);
			handles.vecManager.writeImgVec(img, opts, 'hsv');
			%handles.vecManager.writeHSVVec(fh, 'fmt', fmt, 'file', fname);
		end

		% ---- Backprojection Vector ---- %
		if(get(handles.chkBP, 'Value'))
			if(handles.debug)
				fprintf('Generating BPVec (%s) for frame %s\n', fmt, get(fh, 'filename'))
			end
			img = handles.frameBuf.getCurImg(idx, 'bpimg');
			handles.vecManager.writeImgVec(img, opts, 'bp');
			%handles.vecManager.writeBPVec(fh, 'fmt', fmt, 'file', fname);
		end

		%Write mhist to same location, appending -mhist.dat
		if(get(handles.chkMhist, 'Value'))
			fs = fname_parse(get(handles.etWriteFile, 'String'));
			if(fs.exitflag == -1)
				fprintf('ERROR: parse error generating mhist\n');
				return;
			end
			fn = sprintf('%s%s-mhist.%s', path, str, ext);
			ef = write_mhist(fn, handles.mhist);
			if(ef == -1)
				return;
			end
		end
	end

    guidata(hObject, handles);
    uiresume(handles.csToolGenerateFig);
    delete(handles.csToolGenerateFig);

function bGenMhist_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    %Take Current model histogram and produce a vector that can be used in
    %a Verilog Testbench
    %TODO: have a seperate field for mhist name?
    
    fname = sprintf('%s-mhist.dat', handles.frameBuf.getFilename(handles.idx));
    fp    = fopen(fname);
    if(fp == -1)
       fprintf('ERROR: Unable to open file [%s]\n', fname);
        return;
    end
    fprintf('Writing model histogram...\n');
    fwrite(fp, '@0 ');      %write modelsim address
    for k = 1:length(handles.mhist)
        fwritw(fp, '%2X ', handles.mhist(k));
    end
    fclose(fp);
    fprintf('...done\n');

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

function gui_renderPreview(axHandle, img, idx, filename)

	imshow(img, 'Parent', axHandle);
	fs = fname_parse(filename);
	if(fs.exitflag == -1)
		return;
	end
	
	dims = size(img);
	title(axHandle, sprintf('Frame %d (%s_%d) [%d x %d]', idx, fname, num, dims(2), dims(1), 'Interpreter', 'None'));
	


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
delete(hObject);


% --- Executes on button press in bUIgetfile.
function bUIgetfile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    %Take filename and path from uigetfile, and place into etWriteFile
    %String field
    oldPath = get(handles.etWriteFile, 'String');
    [fname path] = uiputfile('*.dat', 'Save Vector As...');
    if(isempty(fname))
        fname = oldPath;
    end
    set(handles.etWriteFile, 'String', sprintf('%s%s', path, fname));
    guidata(hObject, handles);



function chkGenRange_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkAppendNum_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etLow_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etHigh_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkMhist_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function etLow_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function etHigh_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


