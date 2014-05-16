function varargout = csToolPatternTest(varargin)
% CSTOOLPATTERNTEST M-file for csToolPatternTest.fig
%      CSTOOLPATTERNTEST, by itself, creates a new CSTOOLPATTERNTEST or raises the existing
%      singleton*.
%
%      H = CSTOOLPATTERNTEST returns the handle to a new CSTOOLPATTERNTEST or the handle to
%      the existing singleton*.
%
%      CSTOOLPATTERNTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLPATTERNTEST.M with the given input arguments.
%
%      CSTOOLPATTERNTEST('Property','Value',...) creates a new CSTOOLPATTERNTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolPatternTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolPatternTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolPatternTest

% Last Modified by GUIDE v2.5 17-May-2014 00:26:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolPatternTest_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolPatternTest_OutputFcn, ...
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


% --- Executes just before csToolPatternTest is made visible.
function csToolPatternTest_OpeningFcn(hObject, eventdata, handles, varargin)%#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csToolPatternTest (see VARARGIN)

	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'opts', 4))
					handles.patternOpts = varargin{k+1};
				end
			end
		end
	else
		fprintf('ERROR: Not enough arguments in call to csToolPatternTest(\n');
		handles.output = -1;
		return;
	end

	% Check what we have
	if(~isfield(handles, 'patternOpts'))
		fprintf('ERROR: No options structure available\n');
		handles.output = -1;
		return;
	end

	% Create csPattern object
	if(handles.patternOpts.verbose)
		handles.patternObj = csPattern('verbose');
	else
		handles.patternObj = csPattern();
	end

	% Populate GUI elements
	% set pmImType values
	imgTypeStr = {'Column', 'Row'};
	set(handles.pmImgType, 'String', imgTypeStr);
	dFormat    = {'Dec', 'Hex'};
	set(handles.pmDataFormat, 'String', dFormat);
	clampStr   = {'Clamp to Input', 'Clamp to Output'};
	set(handles.pmClamp, 'String', clampStr);
	
	% Take values from options and place on GUI
	opts = handles.patternOpts; 	%alias to shorten code
	set(handles.etNumBins,   'String', num2str(opts.numBins));
	set(handles.etBinWidth,  'String', num2str(opts.binWidth));
	set(handles.etVecSz,     'String', num2str(opts.vecSz));
	set(handles.etMemWord,   'String', num2str(opts.mWord));
	set(handles.etImgWidth,  'String', num2str(opts.dims(1)));
	set(handles.etImgHeight, 'String', num2str(opts.dims(2)));
	
	% Set filenames
	set(handles.etImgFilename, 'String', opts.genFilename);
	set(handles.etReadFilename, 'String', opts.readFilename);
	% TODO : Input filename
	set(handles.etInputFilename, 'String', opts.inpFilename);

	% Setup preview window based on preview mode
	set(handles.axPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.axPreview, 'YTick', [], 'YTickLabel', []);
	title(handles.axPreview, 'Preview');
	%if(strcmpi(opts.previewMode, 'test', 4))
	%	set(handles.
	%else
	%	set(handles.axPreview, 'XTick', [], 'XTickLabel', []);
	%	set(handles.axPreview, 'YTick', [], 'YTickLabel', []);
	%end

	handles.refVec     = [];
	handles.errVec     = [];
	handles.pattrVec   = [];
	handles.truncRef   = [];
	handles.truncErr   = [];
	handles.truncPattr = [];
	handles.clampIdx   = 1;
	handles.errIdx     = 1;
	handles.hImg       = 0;

	% Choose default command line output for csToolPatternTest
	handles.output = hObject;
	% Update handles structure
	guidata(hObject, handles);
	% UIWAIT makes csToolPatternTest wait for user response (see UIRESUME)
	uiwait(handles.csToolPatternFig);


function varargout = csToolPatternTest_OutputFcn(hObject, eventdata, handles)%#ok<INUSL>
% Get default command line output from handles structure
	% Format output options
	% TODO : Clean up this structure....
	oStruct = struct('numBins', [], ...
		             'binWidth', [], ...
		             'vecSz', [], ...
		             'mWord', [], ...
		             'previewMode', 'test', ...
		             'dims', [], ...
		             'verbose', [], ...
		             'genFilename', [], ...
		             'readFilename', [], ...
		             'inpFilename', []);
		             
	% Save values
	oStruct.numBins      = str2double(get(handles.etNumBins, 'String'));
	oStruct.binWidth     = str2double(get(handles.etBinWidth, 'String'));
	oStruct.vecSz        = str2double(get(handles.etVecSz, 'String'));
	oStruct.mWord        = str2double(get(handles.etMemWord, 'String'));
	img_w                = str2double(get(handles.etImgWidth, 'String'));
	img_h                = str2double(get(handles.etImgHeight, 'String'));
	oStruct.dims         = [img_w img_h];
	oStruct.verbose      = handles.patternOpts.verbose;
	oStruct.genFilename  = get(handles.etImgFilename, 'String');
	oStruct.readFilename = get(handles.etReadFilename, 'String');
	oStruct.inpFilename  = get(handles.etInputFilename, 'String');
	varargout{1} = oStruct;


function csToolPatternFig_CloseRequestFcn(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
    if(isequal(get(hObject, 'waitstatus'), 'waiting'))
        %Still waiting on GUI
        uiresume(handles.csToolPatternFig);
    else
        %Ok to clean up
        delete(handles.csToolPatternFig);
    end

function bDone_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
	close(handles.csToolPatternFig);

function bBrowseFile_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
    %Browse for file to read
    oldText = get(handles.etReadFilename, 'String');
    [fname path] = uigetfile('*.dat', 'Select vector file...');
    if(isempty(fname))
        fname = oldText;
		path  = [];
    end
    set(handles.etReadFilename, 'String', sprintf('%s/%s', path, fname));
    guidata(hObject, handles);

function bRead_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	filename = get(handles.etReadFilename, 'String');
	
	fp = fopen(filename, 'r');
	if(fp == -1)
		fprintf('ERROR: Cant open file %s]\n', filename);
		return;
	end

	handles.errIdx = 1;
	% Read file and get memory word size
	mWord = str2double(get(handles.etMemWord, 'String'));
	if(get(handles.chkAutoGen, 'Value'))
		handles.pattrVec = handles.patternObj.readPatternVec(filename);
		handles.refVec   = genRefVec(length(handles.pattrVec), mWord);
		handles.errVec   = handles.patternObj.vMemPattern(handles.refVec, handles.pattrVec);
		%[handles.errVec handles.refVec]= handles.patternObj.vMemPattern(handles.pattrVec, mWord);
		handles.clampIdx = length(handles.pattrVec);
	else
		inpFilename = get(handles.etInputFilename, 'String');
		inpVec = handles.patternObj.readPatternVec(inpFilename);
		handles.pattrVec = handles.patternObj.readPatternVec(filename);
		handles.clampIdx = length(handles.pattrVec);
		% Make sure that vectors are the same lenght. If there is a problem,
		% with the output, then it will be shorter (since textscan will 
		% discard 'x' values, for instance). Therefore, make a new vector
		% the same length as the input and pad out the output vector with 
		% zeros
		if(length(handles.pattrVec) < length(inpVec))
			if(handles.patternOpts.verbose)
				fprintf('WARNING: pattern vector shorter than input vector by %d elements\n', abs(length(handles.pattrVec) - length(inpVec)));
			end
			handles.clampIdx = length(handles.pattrVec);
			pvec = zeros(1, length(inpVec));
			pvec(1:length(handles.pattrVec)) = handles.pattrVec;
			handles.pattrVec = uint32(pvec);
		end
		% Occasionally, the opposite happens
		if(length(inpVec) < length(handles.pattrVec))
			if(handles.patternOpts.verbose)
				fprintf('WARNING: input vector shorter than pattern vector by %d elements\n', abs(length(inpVec) - length(handles.pattrVec)));
			end
			handles.clampIdx = length(inpVec);
			ivec = zeros(1, length(handles.pattrVec));
			ivec(1:length(inpVec)) = inpVec;
			inpVec = uint32(ivec);
		end
		handles.refVec = inpVec;
		handles.errVec = handles.patternObj.vMemPattern(inpVec, handles.pattrVec);
		%[handles.errVec handles.refVec] = handles.patternObj.vMemPattern(handles.pattrVec, mWord, inpVec);
	end	
	
	cIdx = get(handles.pmClamp, 'Value');
	switch cIdx
		case 1
			%Clamp to input	
			handles.truncRef   = handles.refVec(1:handles.clampIdx);
			handles.truncPattr = handles.pattrVec(1:handles.clampIdx);
			handles.truncErr   = handles.errVec(1:handles.clampIdx);
			% Set ranges
			set(handles.etLowRange, 'String', '1');
			set(handles.etHighRange, 'String', num2str(handles.clampIdx));
		case 2
			%Clamp to output
			handles.truncRef   = handles.refVec;
			handles.truncPattr = handles.pattrVec;
			handles.truncErr   = handles.errVec;
			set(handles.etLowRange, 'String', '1');
			set(handles.etHighRange, 'String', num2str(length(handles.refVec)));
	end

	stats = gui_renderStats(handles.truncRef, handles.truncPattr, handles.truncErr);
	gui_renderPlot(handles.axPreview, handles.truncRef, handles.truncPattr, handles.truncErr, handles.errIdx);
	set(handles.lbPatternStats, 'String', stats);	

	fclose(fp);
	guidata(hObject, handles);

function bNextErr_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	% Check if there is an error vector first
	if(isempty(handles.truncErr))
		fprintf('No error vector set\n');
		return;
	end
	eidx = handles.errIdx;
	N    = find((handles.truncErr(eidx+1 : end) > 0), 1, 'first');
	if(isempty(N))
		return;
	end
	if((eidx + N) > length(handles.truncErr))
		handles.errIdx = length(handles.truncErr);
	else
		handles.errIdx = eidx + N;
	end

	gui_renderPlot(handles.axPreview, handles.truncRef, handles.truncPattr, handles.truncErr, handles.errIdx);

	set(handles.lbPatternStats, 'Value', handles.errIdx);
	guidata(hObject, handles);

function bPrevErr_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	if(isempty(handles.errVec))
		fprintf('No error vector set\n');
		return;
	end
	% Create alias and bounds check
	eidx = handles.errIdx; 	
	if(eidx == length(handles.truncErr))
		eidx = length(handles.truncErr) - 1;
	end
	P    = find((handles.truncErr(1 : eidx+1) > 0), 1, 'last');
	if(isempty(P))
		return;
	end
	if((eidx - P) < 1)
		handles.errIdx = 1;
	else
		handles.errIdx = eidx - P;
	end
	gui_renderPlot(handles.axPreview, handles.truncRef, handles.truncPattr, handles.truncErr, handles.errIdx);

	set(handles.lbPatternStats, 'Value', handles.errIdx);
	guidata(hObject, handles);


function lbPatternStats_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	% Jump to position
	lbIdx = get(handles.lbPatternStats, 'Value');
	handles.errIdx = lbIdx;

	gui_renderPlot(handles.axPreview, handles.truncRef, handles.truncPattr, handles.truncErr, handles.errIdx);

	guidata(hObject, handles);

function bGenerate_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	imgTypeList = get(handles.pmImgType, 'String');
	imgTypeIdx  = get(handles.pmImgType, 'String');
	imgType     = imgTypeList{imgTypeIdx};
	% Get options for hue image generation
	nBins       = str2double(get(handles.etNumBins, 'String'));
	bWidth      = str2double(get(handles.etBinWidth, 'String'));
	vecSz       = str2double(get(handles.etVecSz, 'String'));
	img_w       = str2double(get(handles.etImgWidth, 'String'));
	img_h       = str2double(get(handles.etImgHeight, 'String'));
	dims        = [img_w img_h];

	if(strncmpi(imgType, 'column', 6))
		handles.hImg = handles.patternObj.genColHistImg(dims, nBins, bWidth, vecSz);
	elseif(strncmpi(imgType, 'row', 3))
		handles.hImg = handles.patternObj.genRowHistImg(dims, nBins, bWidth);
	else
		fprintf('Unknonwn image type [%s]\n', imgType);
		return;
	end

	% Show image in preview
	imshow(handles.axPreview, hImg);
	if(strncmpi(imgType, 'column', 6))
		title(handles.axPreview, 'Column Hue Image');
	else
		title(handles.axPreview, 'Row Hue Image');
	end
	set(handles.axPreview, 'XTick', [], 'XTickLabel', []);
	set(handles.axPreview, 'YTick', [], 'YTickLabel', []);
	xlabel(handles.axPreview, []);
	ylabel(handles.axPreview, []);

	guidata(hObject, handles);

function bWrite_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	filename = get(etImgFilename, 'String');
	dfList   = get(handles.pmDataFormat, 'String');
	dfIdx    = get(handles.pmDataFormat, 'Value');
	dFormat  = dfList{dfIdx};

	fp = fopen(filename, 'w');
	if(fp == -1)
		fprintf('ERROR: Cant open file [%s]\n', filename);
		return;
	end

	if(strncmpi(dFormat, 'Dec', 3))
		fprintf(fp, '%d ', handles.hImg);
	elseif(strncmpi(dFormat, 'Hex', 3))
		fprintf(fp, '%x ', handles.hImg);
	end

	fclose(fp);
	guidata(hObject, handles);


function bScale_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	lowRange  = fix(str2double(get(handles.etLowRange, 'String')));
	highRange = fix(str2double(get(handles.etHighRange, 'String')));

	% Rescale vectors
	handles.truncRef   = handles.refVec(lowRange:highRange);
	handles.truncPattr = handles.pattrVec(lowRange:highRange);
	handles.truncErr   = handles.errVec(lowRange:highRange);
	
	if(handles.errIdx > length(handles.truncRef))
		handles.errIdx = length(handles.truncRef);
	end

	stats = gui_renderStats(handles.truncRef, handles.truncPattr, handles.truncErr);
	gui_renderPlot(handles.axPreview, handles.truncRef, handles.truncPattr, handles.truncErr, handles.errIdx);
	set(handles.lbPatternStats, 'String', stats);	
	set(handles.lbPatternStats, 'Value', handles.errIdx);
	guidata(hObject, handles);


function pmClamp_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

	clampIdx = get(handles.pmClamp, 'Value');
	switch clampIdx
		case 1
			%Clamp to input	
			handles.truncRef   = handles.refVec(1:handles.clampIdx);
			handles.truncPattr = handles.pattrVec(1:handles.clampIdx);
			handles.truncErr   = handles.errVec(1:handles.clampIdx);
		case 2
			%Clamp to output
			handles.truncRef   = handles.refVec;
			handles.truncPattr = handles.pattrVec;
			handles.truncErr   = handles.errVec;
	end
	set(handles.etLowRange, 'String', '1');
	set(handles.etHighRange, 'String', num2str(length(handles.truncRef)));
	gui_renderPlot(handles.axPreview, handles.truncRef, handles.truncPattr, handles.truncErr, handles.errIdx);

	guidata(hObject, handles);

function bSetWriteFile_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>
    oldText = get(handles.etImgFilename, 'String');
    [fname path] = uiputfile('*.dat', 'Select output file...');
    if(isempty(fname))
        fname = oldText;
		path  = [];
    end
    set(handles.etImgFilename, 'String', sprintf('%s/%s', path, fname));
    guidata(hObject, handles);


% ======== LOCAL GUI FUNCTIONS ======== %
function stats = gui_renderStats(refVec, pattrVec, errVec)

	stats = cell(1, length(refVec));
	
	for k = 1 : length(stats)
		stats{k} = sprintf('idx : [%4d] | ref: [%4d] | pattr: [%4d] | err: [%4d]', k, refVec(k), pattrVec(k), errVec(k));
	end

function gui_renderPlot(axHandle, refVec, pattrVec, errVec, idx)

	cla(axHandle);
	plot(axHandle, 1:length(refVec), refVec, 'Color', [0 1 0]);
	hold(axHandle, 'on');
	plot(axHandle, 1:length(pattrVec), pattrVec, 'Color', [0 0 1]);
	plot(axHandle, 1:length(errVec), errVec, 'Color', [1 0 0]);
	% Show current position as magenta triangle
	plot(axHandle, idx, errVec(idx), 'Color', [1 0 1], 'Marker', 'v', 'MarkerSize', 8, 'LineWidth', 4);
	hold(axHandle, 'off');
	axis(axHandle, 'tight');
	title(axHandle, 'Pattern Vector Comparison');
	legend(axHandle, 'Reference Vector', 'Pattern Vector', 'Error Vector', 'Current Position');
	xlabel(axHandle, 'Data word #');
	ylabel(axHandle, 'Data word value');


function bSetInputFile_Callback(hObject, eventdata, handles)%#ok<INUSL,DEFNU>

    %Browse for file to read
    oldText = get(handles.etInputFilename, 'String');
    [fname path] = uigetfile('*.dat', 'Select vector file...');
    if(isempty(fname))
        fname = oldText;
		path  = [];
    end
    set(handles.etInputFilename, 'String', sprintf('%s/%s', path, fname));
    guidata(hObject, handles);

% ======== CREATE FUNCTIONS ======== %
function etReadFilename_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function lbPatternStats_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etNumBins_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etBinWidth_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgHeight_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgWidth_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etVecSz_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etImgFilename_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmImgType_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmDataFormat_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etInputFilename_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etMemWord_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function pmClamp_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etLowRange_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etHighRange_CreateFcn(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

% ======== EMPTY FUNCTIONS ========= %
function etReadFilename_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etBinWidth_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etNumBins_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgHeight_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgWidth_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etVecSz_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmImgType_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etImgFilename_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function chkAutoGen_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function pmDataFormat_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etInputFilename_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etMemWord_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etLowRange_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
function etHighRange_Callback(hObject, eventdata, handles)%#ok<INUSD,DEFNU>
