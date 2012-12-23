%% LAST MINUTE DEMO OF CAMSHIFT CONVERGENCE
%
% For M2VIP2012 slides
%


clf;

MAX_ITER          = 8;
ELLIPTICAL_BOUNDS = 1;
SAVE_FIGURES      = 1;
PATH = 'data/meanshift/';
if(ELLIPTICAL_BOUNDS)
    FILENAME = 'ellipse';
else
    FILENAME = 'box';
end

if(~exist('data', 'dir'))
    mkdir('data');
end
if(~exist('data/meashift', 'dir'))
    mkdir('data/meanshift');
end


%Get figure and axes handles
% ---- MAIN FIGURE HANDLE ---- %
if(~exist('msfig', 'var'))
    fprintf('Creating meanshift figure...\n');
    msfig = figure('Name', 'Meanshift Convergence');
end
axtest = get(get(msfig, 'Children'), 'Type');
if(strncmpi(axtest, 'axes', 4))
    msax = get(msfig, 'Children');
else
    msax = axes('Parent', msfig);
end
if(~ishandle(msax))
    error('msax not valid axes handle');
end
% ---- ITERATION FIGURE HANDLE ---- %
if(SAVE_FIGURES)
    if(~exist('iterfig', 'var'))
        fprintf('Creating iteration figure....\n');
        iterfig = figure('Name', 'Meanshift Iteration');
    end
    axtest = get(get(iterfig, 'Children'), 'Type');
    if(strncmpi(axtest, 'axes', 4))
        iterax = get(iterfig, 'Children');
    else
        iterax = axes('Parent', iterfig);
    end
    if(~ishandle(iterax))
        error('iterax not valid axes handle');
    end
    cla(iterax);
end

% ---- GENERATE DATA ---- %

for frame = 1:NUM_FRAMES;
    %Get the current frame data
    fdata = imread(sprintf('%s%s.tif', PATH, FILENAME), 'tif');
    %Use m16_* functions to perform backprojection
end

N      = 200;
X      = abs([randn(1,N) ; randn(1,N)]);
%set a random initial location and standard window size
w0     = 0.1 .* [randn(1) ; randn(1)] + mean(mean(X));
sz0    = [0.5 0.5];
wparam = [w0(1) w0(2) 0 sz0(1) sz0(2)];
%Show data
hold(msax, 'on');



hold(msax, 'off');
