%% TST_GENBUFOPTS
%
% Generate a set of basic options for csFrameBuffer and csFrameBrowser
% objects. 

%Path to asset directories
path = 'uTest/assets/frames/2g1ctest';

% ---- TEST PARAMETERS ---- %
nSamp = 4;		%number of frames to test
%Use a predefined stock region for generating histogram in this test
region = [200 332 ; 109 257];

%Setup figure handles for csFrameBrowser
if(~exist('prevFig', 'var'))
	fprintf('Generating figure prevFig...');
	prevFig = figure('Name', 'Image Preview');
	fprintf(' done\n');
end
if(~exist('browseFig', 'var'))
	fprintf('Generating figure browseFig... ');
	browseFig = figure('Name', 'Image Browser');
	fprintf(' done\n');
end
if(~exist('histFig', 'var'))
	fprintf('Generating figure histFig... ');
	histFig = figure('Name', 'Image Histograms');
	fprintf(' done\n');
end
%Setup axis handles for csFrameBrowser
if(~exist('prevAx', 'var'))
	fprintf('Generating axes handle prevAxes... ');
	prevAx = axes('Parent', prevFig);
	if(~ishandle(prevAx))
		error('Invalid axes handle prevAx');
	end
	fprintf(' done\n');
end
set(prevFig, 'CurrentAxes', prevAx);
if(~exist('browseAx', 'var'))
	fprintf('Generating axes handle browseAx... ');
	browseAx = axes('Parent', browseFig);
	if(~ishandle(browseAx))
		error('Invalid axes handle browseAx');
	end
	fprintf(' done\n');
end
set(browseFig, 'CurrentAxes', browseAx);
if(~exist('histAx', 'var'))
	fprintf('Generating axes handle histAx... ');
	histAx = axes('Parent', histFig);
	if(~ishandle(histAx))
		error('Invalid axes handle histAx');
	end
	fprintf(' done\n');
end
set(histFig, 'CurrentAxes', histAx);

% ---- OPTIONS STRUCTURES FOR OBJECTS ---- %
%Setup options for csFrameBuffer, csFrameBrowers options
fbuf_opts = struct('nFrames', 64,   ...
                   'path', path,    ...
                   'ext', 'tif',    ...
                   'fNum', 274,     ...
                   'verbose', 1);
fbrs_opts = struct('axPreview', prevAx,   ...
	               'axBuffer',  browseAx, ...
				   'axHist',    histAx,   ...
				   'plotgaussian', 1,     ...
				   'verbose',      1);
%Show options structures in console
fprintf('fbuf_opts struct:\n');
disp(fbuf_opts);
fprintf('fbrs_opts struct:\n');
disp(fbrs_opts);