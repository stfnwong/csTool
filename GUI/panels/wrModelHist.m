function varargout = wrModelHist(varargin)
% WRMODELHIST M-file for wrModelHist.fig
%      WRMODELHIST, by itself, creates a new WRMODELHIST or raises the existing
%      singleton*.
%
%      H = WRMODELHIST returns the handle to a new WRMODELHIST or the handle to
%      the existing singleton*.
%
%      WRMODELHIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WRMODELHIST.M with the given input arguments.
%
%      WRMODELHIST('Property','Value',...) creates a new WRMODELHIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wrModelHist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wrModelHist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wrModelHist

% Last Modified by GUIDE v2.5 17-Aug-2013 21:09:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wrModelHist_OpeningFcn, ...
                   'gui_OutputFcn',  @wrModelHist_OutputFcn, ...
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


% --- Executes just before wrModelHist is made visible.
function wrModelHist_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL,DEFNU>

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(isa(varargin{k}, 'csFrameBuffer'))
				handles.frameBuf = varargin{k};
			elseif(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'mhist', 5))
					handles.mhist = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'ver', 3))
					handles.verbose = true;
				end
			end
		end
	end

	%Check inputs
	if(~isfield(handles, 'frameBuf'))
		fprintf('WARNING: No csFrameBuffer specified, additional options not available\n');
		handles.frameBuf = [];
	end
	if(~isfield(handles, 'mhist'))
		fprintf('WARNING: Mo model histogram specified, using default (all zeros)\n');
		handles.mhist = zeros(1,16);
	end
	if(~isfield(handles, 'verbose'))
		handles.verbose = false;
	end
	% Set up GUI elements
	set(handles.etScale, 'String', '256');
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);
	uiwait(handles.figModelHist);



function varargout = wrModelHist_OutputFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Write model histogram file to disk
	varargout{1} = -1;
	delete(hObject);


function bWrite_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Write data to disk
	if(isempty(handles.mhist))
		fprintf('ERROR: No data in model histogram, exiting...\n');
		return;
	end
	if(handles.verbose)
		if(sum(handles.mhist) == 0)
			fprintf('WARNING: model histogram all zeros\n');
		end
	end
	if(isempty(get(handles.etFileName, 'String')))
		fprintf('ERROR: No filename specified\n');
		return;
	end
	fname = get(handles.etFileName, 'String');
	fp = fopen(fname, 'w');
	if(fp == -1)
		fprintf('ERROR: Couldn''t open file [%s]\n', fname);
		return;
	end
	if(get(handles.chkModelSim, 'Value'))
		fprintf(fp, '@0 ');
	end
	mhist = handles.mhist;
	sf = fix(str2double(get(handles.etScale, 'String')));
	if(isempty(sf) || (sf == 0))
		fprintf('No scale specified - writing as is\n');
		for k = 1 : length(mhist)
			if(get(handles.chkModelSim, 'Value'))
				fprintf(fp ,'%X ', mhist(k));
			else
				fprintf(fp, '%f ', mhist(k));
			end
		end
	else
		mhist = sf.*mhist;
		for k = 1 : length(mhist)
			fprintf(fp, '%X ', mhist(k));
		end
	end
	fprintf('...done\n');

	fclose(fp);
	guidata(hObject, handles);
	delete(handles.figModelHist);
	
function bSelectFile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	oldPath = get(handles.etFileName, 'String');
	[fname path] = uiputfile('*.dat', 'Select output file...');
	if(isempty(fname))
		fname = oldPath;
		path  = '';
	end
	set(handles.etFileName, 'String', sprintf('%s%s', path, fname));
	guidata(hObject, handles);
	uiwait(handles.figModelHist);

function bCancel_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
	% Close figure without writing
	delete(handles.figModelHist);


% ================ UNUSED FUNCTIONS =============== %
function etFileName_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
function etScale_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
function chkModelSim_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

function etFileName_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end

function etScale_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end


