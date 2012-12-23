function drawPrevPlot(B, fh, varargin)
% DRAWPREVPLOT - csFrameBrowser
%
% Generate preview plot for the frame with handle fh
% This method takes the raw image data stored in fh.img and places it into
% the axes handle at B.axPreview

% Stefan Wong 2012

	%Check that required axes handles are setup correctly
	if(~ishandle(B.axPreview))
		error('B.axPreview not set or invalid axes handle');
	end
	plotBp = 0;
	if(nargin > 2)
        if(varargin{1} == 1)
            plotBp = 1;
        end
	end
	if(plotBp)
		imshow(fh.bpImg, 'Parent', B.axPreview);
		% -- DEBUG --
		if(~ishandle(B.axPreview))
			error('SOMEHOW GOT TO IMSHOW() WITH INVALID AXES HANDLE!');
		end
		title(B.axPreview, sprintf('Backprojection of %s', fh.filename));
		axis(B.axPreview, 'tight');
	else
		fn  = get(fh, 'filename');
		img = imread(fn, 'tif');
		imshow(img, 'Parent', B.axPreview);
		% -- DEBUG --
		if(~ishandle(B.axPreview))
			error('SOMEHOW GOT TO IMSHOW() WITH INVALID AXES HANDLE!');
		end		
		title(B.axPreview, sprintf('%s', fh.filename));
		axis(B.axPreview, 'tight');
	end
	% -- DEBUG --
	if(B.verbose)
		fprintf('PLACED BACKPROJECTION IMAGE ONTO AXES HANDLE %f\n', B.axPreview);
	end

end		%drawPrevPlot()
