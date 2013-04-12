%% CSTOOLSTARTGUI
%
% Script to initialise the csTool GUI. This script generates the required structures
% and passes them into csToolGUI. 

% Stefan Wong 2012

fprintf('\n---------------------------------------------------------------\n');
fprintf('                 Starting csTool GUI                               ');
fprintf('\n---------------------------------------------------------------\n');

%Use default instantiation - change this using inbult option parser within GUI
buf   = csFrameBuffer();
seg   = csSegmenter();
track = csTracker();
csToolGUI(buf, track, seg);
