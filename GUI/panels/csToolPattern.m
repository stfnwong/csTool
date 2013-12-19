function varargout = csToolPattern(varargin)
% CSTOOLPATTERN M-file for csToolPattern.fig
%      CSTOOLPATTERN, by itself, creates a new CSTOOLPATTERN or raises the existing
%      singleton*.
%
%      H = CSTOOLPATTERN returns the handle to a new CSTOOLPATTERN or the handle to
%      the existing singleton*.
%
%      CSTOOLPATTERN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLPATTERN.M with the given input arguments.
%
%      CSTOOLPATTERN('Property','Value',...) creates a new CSTOOLPATTERN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolPattern_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolPattern_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolPattern

% Last Modified by GUIDE v2.5 16-Dec-2013 15:35:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolPattern_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolPattern_OutputFcn, ...
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


function csToolPattern_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

    if(~isempty(varargin))
		for k = 1:length(varargin)
			if(isa(varargin{k}, 'csFrameBuffer'))
				handles.frameBuf = varargin{k};
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'idx', 3))
					handles.fidx = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					handles.verbose = true;
				end
			end
		end
    end

	%Check input arguments
	if(~isfield(handles, 'verbose'))
		handles.verbose = false;
	end
	if(~isfield(handles, 'frameBuf'))
		fprintf('ERROR: No csFrameBuffer object specified, exiting...\n');
		return;
	end
	if(~isfield(handles, 'fidx'))
		fprintf('WARNING: No frame index set, defaulting to 1...\n');
		handles.fidx = 1;
	end


	% Set up GUI elements
	set(handles.etErrThresh, 'String', '0');
	% Set histogram generation defaults to 16x16 - bufsize 128
	set(handles.etBufSize, 'String', '128');
	set(handles.etNbins, 'String', '16');
	set(handles.etBinWidth, 'String', '16');
	set(handles.axPatternRes, 'XTick', [], 'XTickLabel', []);
	set(handles.axPatternRes, 'YTick', [], 'YTickLabel', []);
	% Set defaults for data variables needed in this scope
	handles.ihist   = [];
	handles.pattern = [];

    handles.output = hObject;
    guidata(hObject, handles);
    uiwait(handles.csToolPatternFig);



% ======== FILE SELECTION FUNCTIONS ======== %
function varargout = csToolPattern_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
    varargout{1} = handles.output;
	delete(hObject);


function bInputFile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Get input filename
	oldPath = get(handles.etInputFile, 'String');
	[fname path] = uigetfile('*.dat', 'Select testbench input file...');
	if(isempty(fname))
		fname = oldPath;
		path  = '';
	end
	set(handles.etInputFile, 'String', sprintf('%s%s', path, fname));
	guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);

function bOutputFile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    % Get output filename
    oldPath = get(handles.etOutputFile, 'String');
    [fname path] = uigetfile('*.dat', 'Select testbench output file...');
    if(isempty(fname))
        fname = oldPath;
		path  = '';
    end
    set(handles.etOutputFile, 'String', sprintf('%s%s', path, fname));
    guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);

function bPatternFile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Select file to write pattern to
	oldPath = get(handles.etPatternFile, 'String');
	[fname path] = uiputfile('*.dat', 'Select file to write pattern to...');
	if(isempty(fname))
		fname = oldPath;
		path  = '';
	end
	set(handles.etPatternFile, 'String', sprintf('%s%s', path, fname));
	guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);


function bVerify_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	%Call vpattr and compare functions
	
	% Check inputs 
	idelim = get(handles.etInpDelim, 'String');
	if(isempty(idelim))
		idelim = ' ';
	end
	odelim = get(handles.etOutDelim, 'String');
	if(isempty(odelim))
		odelim = ' ';
	end
	ifile = get(handles.etInputFile, 'String');
	ofile = get(handles.etOutputFile, 'String');
	if(isempty(ifile))
		fprintf('ERROR: No input file or invalid filename [%s]\n', ifile);
	end
	if(isempty(ofile))
		fprintf('ERROR: No output file of invalid filename [%s]\n', ofile);
	end
	% csTool version of vpattr() has options structure rather than text parser
	if(get(handles.chkForce, 'Value'))
		opts.force = true;
	else
		opts.force = false;
	end
	if(get(handles.chkError, 'Value'))
		opts.errOnly = true;
	else
		opts.errOnly = false;
	end
	if(isempty(get(handles.etErrThresh, 'String')))
		opts.errThresh = 0;
	else
		opts.errThresh = fix(str2double(get(handles.etErrThresh, 'String')));
	end

	% Generate options structure
	opts.idelim = idelim;
	opts.odelim = odelim;
	opts.ah     = handles.axPatternRes;

	[ivec ovec cvec nerr ef] = vpattr_cstool(ifile, ofile, opts); %#ok
	if(ef == -1)
		fprintf('ERROR in vpattr_cstool()\n');
		return;
	end

	% Plot results
	guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);
	
function bPattrVerify_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

	if(isempty(handles.ihist))
		fprintf('ERROR: No histogram data for file, exiting...\n');
		return;
	end
	if(isempty(handles.data))
		fprintf('ERROR: No data for file, exiting...\n');
		return;
	end

	% Generate options structure
	opts.verbose = handles.verbose;
	if(isempty(get(handles.etNbins, 'String')))
		opts.nbins = 16;
	else
		opts.nbins = fix(str2double(get(handles.etNbins, 'String')));
	end
	if(isempty(get(handles.etBinWidth, 'String')))
		opts.bwidth = 16;
	else
		opts.bwidth = fix(str2double(get(handles.etBinWidth, 'String')));
	end

	opts.delim = ' ';	

	guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);

function bGenerate_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Generate pattern file - this should really be called 'write'

	if(isempty(handles.data) && isempty(handles.ihist))
		fprintf('ERROR: No histogram or other data in buffer, exiting...\n');
		return;
	end
	if(isempty(get(handles.etPatternFile, 'String')))
		fprintf('ERROR: No filename specified, exiting...\n');
		return;
	end
	% Write file	
	fname = get(handles.etPatternFile, 'String');
	fp    = fopen(fname, 'w');
	if(fp == -1)
		fprintf('ERROR: Unable to open file [%s]\n', fname);
		return;
	end


	%VERBOSE = opts.verbose;
	%bmin    = opts.bmin;
	%nbins   = opts.nbins;
	%bwidth  = opts.bwidth;
	%refdata = opts.refdata;
	%delim   = opts.delim;

	guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);

function bHistData_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Generate pattern file
	oldPath = get(handles.etHistDataFile, 'String');
	[fname path] = uigetfile('.*dat', 'Select ihist output file...');
	if(isempty(fname))
		fname = oldPath;
		path  = '';
	end
	set(handles.etHistDataFile, 'String', sprintf('%s%s', path, fname));
	guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);

function bGenHist_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Generate histogram file
	
	if(isempty(get(handles.etNbins, 'String')))
		opts.nBins = 16;
	else
		opts.nBins = fix(str2double(get(handles.etNbins, 'String')));
	end
	if(isempty(get(handles.etBinWidth, 'String')))
		opts.binWidth = 16;
	else
		opts.binWidth = fix(str2double(get(handles.etBinWidth, 'String')));
	end
	if(isempty(get(handles.etBufSize, 'String')))
		opts.bufSize = 128;
	else
		opts.bufSize = fix(str2double(get(handles.etBufSize, 'String')));
	end
	opts.bufOffset = 0;	%TODO : <- Create option for this

	if(get(handles.chkCurFrame, 'Value'))
		fh   = handles.frameBuf.getFrameHandle(handles.fidx);
		data = get(fh, 'bpVec');
	else
		data = vecReadGeneral(fname);
	end
	handles.ihist = ihistgen_cstool(data, opts);

	guidata(hObject, handles);
	uiresume(handles.csToolPatternFig);


% ======== EMPTY FUNCTIONS ======== %

function etInputFile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etOutputFile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etPatternFile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etInpDelim_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etOutDelim_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkError_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkForce_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etErrThresh_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etHistDataFile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etBufSize_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etNbins_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function etBinWidth_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkCurFrame_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function etInputFile_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function etOutputFile_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function etPatternFile_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function etInpDelim_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function etOutDelim_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function etErrThresh_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function etHistDataFile_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function etNbins_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function etBinWidth_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function etBufSize_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
