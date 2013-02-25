function region = gui_rPos2rRegion(rPos, axHandle, varargin)
% GUI_RPOS2RREGION
% Convert imrect position to imRegion matrix
%
% ARGUMENTS:
% rPos     - Current position vector of imrect handle
% axHandle - Handle to axes on which imrect handle is placed
%
%

% Stefan Wong 2013

	xlim = fix(get(axHandle, 'XLim'));
	ylim = fix(get(axHandle, 'YLim'));
	xlim(xlim == 0) = 1;
	ylim(ylim == 0) = 1;

	%Get region limits
	xmax = rPos(1) + rPos(3);
	ymax = rPos(2) + rPos(4);
	if(xmax > xlim(2))
		xmax = xlim(2);
	end
	if(ymax > ylim(2))
		ymax = ylim(2);
	end

	region = fix([rPos(1) xmax ; rPos(2) ymax]);

end 	%gui_rPos2rRegion()
