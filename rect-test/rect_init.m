%% RECT_INIT 
%
% Keyhandler test for imrect draw method
% Run this script in the workspace where figure handles, etc, exist

function rect_init(varargin)

	%Set default path
	path = '../data/assets/frames/sample_001.tif';

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'fig', 3))
					rfig = varargin{k+1};			
				elseif(strncmpi(varargin{k}, 'ax', 2))
					rax = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'path', 4))
					path = varargin{k+1};
				end
			end
		end
	end

	if(~exist('rfig', 'var'))
		rfig = figure('Name', 'rect-test-figure');
	else
		figure(rfig);
	end

	if(~exist('rax', 'var'))
		rax = axes('parent', rfig);
	end

	%Put an image on the axes
	img = imread(path, 'tif');
	imshow(img, 'parent', rax);

	rectData = struct('isRect', 0, 'rHandle', [], 'rRegion', []);
	disp(rectData);
	fprintf('Placing rectData into rfig.UserData...\n');
	set(rfig, 'UserData', rectData);
	set(rfig, 'WindowKeyPressFcn', @rfig_keyPressCallback);

end 	%rect_init()


function rfig_keyPressCallback(hObject, eventdata)
% RFIG_KEYPRESSCALLBACK
% Handle keypresses for rect-test-figure

	%DEBUG:
	fprintf('rfig_keyPressCallback type : %s\n', get(hObject, 'Type'));

	switch eventdata.Character
		% Create/Destroy imrect handle
		case 'r'
			%Check if we have a current rectangle, and if not, create a new one
			rData = get(hObject, 'UserData')
			%DEBUG:
			fprintf('hObject.UserData :\n');
			disp(rData);
			if(rData.isRect)
				%Existing rectangle, delete current one 
				fprintf('Current rect position :\n');
				rPos = getPosition(rData.rHandle);
				disp(rPos);
				rData.isRect = 0;
				delete(rData.rHandle);
				set(hObject, 'UserData', rData);
				%Update title
				title(get(hObject, 'CurrentAxes'), 'RECT!!!!');
			else
				%No rectangle - create new one
				ca = get(hObject, 'CurrentAxes');
				if(isempty(ca))
					fprintf('ERROR: hObject.CurrentAxes is empty\n');
					return;
				end
				rh = imrect(ca, [10 10 100 100]);
				addNewPositionCallback(rh, @(p) title(mat2str(p, 3)));
				crFcn = makeConstrainToRectFcn('imrect', get(ca, 'XLim'), get(ca, 'YLim'));
				setPositionConstraintFcn(rh, crFcn);
				%Write data back to hObject
				rData.isRect = 1;
				rData.rHandle = rh;
				set(hObject, 'UserData', rData);
				%Show in console
				fprintf('rData structure :\n');
				disp(rData);
				fprintf('Current hObject.UserData :\n');
				disp(get(hObject, 'UserData'));
			end
		% Check current rData structure
		case 'c'
			rData = get(hObject, 'UserData');
			fprintf('Current rData structure :\n');
			disp(rData);
		% Get the current position of the imrect handle
		case 'p'
			rData = get(hObject, 'UserData');
			fprintf('Current imrect position :\n');
			rPos = getPosition(rData.rHandle);
			disp(rPos);


	end


end 	%rfig_keyPressCallback()
