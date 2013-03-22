function status = gui_plotTraj(axHandle, tVec, idx, varargin)
% GUI_PLOTTRAJ
% [status] = gui_plotTraj(axHandle, tVec, idx);
% Superimpose meanshift trajectory on image. This function plots the trajectory given
% in tVec on the axes with handle axHandle.
%

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = true;
				elseif(strncmpi(varargin{k}, 'range', 5))
					range = varargin{k+1};
				end
			end
		end
	end

	%If there is no range parameter, assume that tVec extends over the entire
	%frameBuffer contents. Otherwise, we need to map the tVec against the frameBuf
	%position
	if(~exist('range', 'var'))
		range = 1:length(tVec);
	end

	hold(axHandle, 'on');
	for k = 1:length(tVec);
		ph = plot(axHandle, tVec(1,k), tVec(2,k));
		if(range(k) == idx)
			%Plot the current frame more prominently
			set(ph, 'Marker', 'x', 'Color', [1 0 0 ],'MarkerSize',20,'LineWidth'4);
		else
			set(ph, 'Marker', 'o', 'Color',[0 1 0], 'MarkerSize',16,'LineWidth', 1);
		end	
	end
	hold(axHandle, 'off');
	status = 0;
		


end 	%gui_plotTraj