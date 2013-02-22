function [hit ah varargout] = gui_axHitTest(axHandles, figHandle, cPos, varargin)
% GUI_AXHITTEST
% Test which (if any) image display axes in csTool have been clicked on. 
% It is the callers responsibility to ensure that arguments to this function are well
% formed. Paranoid callers may wish to set the 'force' option, which ensures that 
% axes handles are using pixel units with an associated overhead.
%
% ARGUMENTS:
% axHandles - Array containing handles to all axes in csTool.
% figHandle - Handle to csToolGUI figure.
% cPos      - Click position generated in callback.
% (OPTIONAL)
% 'debug'   - Pass this string to print debugging messages.
% 'force'   - Enforce that axes units must be pixels 
%
% OUTPUTS:
% hit    - 1 if the click is within the region, 0 otherwise
% ah     - Handle to axes that passed hit test. If click was not within axes, this 
%          value will be -1.
% status - Add the output status to obtain further information about hit (to be 
%          implemented in future edition)
%

% Stefan Wong 2013

	DEBUG = 0;
	FORCE = 0;

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(strncmpi(varargin{k}, 'd', 1))
				DEBUG = 1;
			elseif(strncmpi(varargin{k}, 'f', 1))
				FORCE = 1;
			end
		end
	end

	if(FORCE)
		%Ensure that units are in pixels
		for k = 1:length(axHandles)
			if(~strncmpi(get(axHandles(k), 'Units'), 'Pixels', 6))
				set(axHandles(k), 'Units', 'Pixels');
			end
		end
		if(~strncmpi(get(fh, 'Units'), 'Pixels', 6))
			set(fh, 'Units', 'Pixels');
		end
	end
	
	figPos = get(figHandle, 'Position');
	if(DEBUG)
		fprintf('\n');
		%fprintf('cPos:    [%f %f]\n', cPos(1), cPos(2));
		fprintf('figPos (%s): \n', get(figHandle, 'Name'));
		fprintf('[%f %f %f %f] \n', figPos(1), figPos(2), figPos(3), figPos(4));
	end

	for k = 1:length(axHandles)
		axPos = get(axHandles(k), 'Position');
		if(DEBUG)
			fprintf('axPos (axes handle %f):\n', axHandles(k));
			fprintf('[%f %f %f %f]\n', axPos(1), axPos(2), axPos(3), axPos(4));
		end
		%Test bounds for this axes
		if(cPos(1) > axPos(1) && cPos(2) > axPos(2) && ...
           cPos(1) < axPos(1)+axPos(3) && cPos(2) < axPos(2)+axPos(4))
			if(DEBUG)
				fprintf('Hit on axes %f\n', axHandles(k));
			end
			hit = 1;
			ah  = axHandles(k);
			%varargout{1} = status;		%to be implemented in future version
			return;
		end
	end
	% Not in any of the axes in csToolGUI
	if(DEBUG)
		fprintf('No hits\n');
	end
	hit = 0;
	ah  = -1;
	if(nargout > 2)
		status = 0;		%Not yet implemented
	end
			   
end 	%gui_regionSelect
