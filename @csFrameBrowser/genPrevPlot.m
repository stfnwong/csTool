function genPrevPlot(T, fh, varargin)
% GENPREVPLOT - csFrameBrowser
%
% Generate preview plot for the frame with handle fh
% This method takes the raw image data stored in fh.img and places it into
% the axes handle at T.axPreview

% Stefan Wog 2012

	%Check that required axes handles are setup right
	if(~ishandle(T.axPreview))
		error('T.axPreview not set or invalid axes handle');
	end
	plotBp = 0;
	if(nargin > 2)
        if(varargin{1} == 1)
            plotBp = 1;
        end
	end
	cla(T.axPreview);
	if(plotBp)
		ih = imshow(fh.bpImg);
        set(ih, 'Parent', T.axPreview);
		title(T.axPreview, sprintf('Backprojection of %s', fh.filename));
		axis(T.axPreview, 'tight');
	else
		ih = imshow(fh.img);
        set(ih, 'Parent', T.axPreview);
		title(T.axPreview, sprintf('%s', fh.filename));
		axis(T.axPreview, 'tight');
	end

end		%genPrevPlot()
