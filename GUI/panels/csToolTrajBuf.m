function varargout = csToolTrajBuf(varargin)
% CSTOOLTRAJBUF M-file for csToolTrajBuf.fig
%      CSTOOLTRAJBUF, by itself, creates a new CSTOOLTRAJBUF or raises the existing
%      singleton*.
%
%      H = CSTOOLTRAJBUF returns the handle to a new CSTOOLTRAJBUF or the handle to
%      the existing singleton*.
%
%      CSTOOLTRAJBUF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSTOOLTRAJBUF.M with the given input arguments.
%
%      CSTOOLTRAJBUF('Property','Value',...) creates a new CSTOOLTRAJBUF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csToolTrajBuf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csToolTrajBuf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csToolTrajBuf

% Last Modified by GUIDE v2.5 17-May-2013 19:15:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csToolTrajBuf_OpeningFcn, ...
                   'gui_OutputFcn',  @csToolTrajBuf_OutputFcn, ...
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


% --- Executes just before csToolTrajBuf is made visible.
function csToolTrajBuf_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for csToolTrajBuf
handles.output = hObject;

    %Parse optional arguments
    if(~isempty(varargin))
    end
        

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes csToolTrajBuf wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = csToolTrajBuf_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
