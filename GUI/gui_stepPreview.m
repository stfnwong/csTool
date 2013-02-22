function [newIndex nh] = gui_stepPreview(idx, handles, dir)
% STEPPREVIEW
% (Transport panel callback) Step preview forward in the direction
% specified by dir. 
%

% Stefan Wong 2013

	if(strncmpi(dir, 'f', 1))
		DIR = 1;
	elseif(strncmpi(dir, 'b', 1))
		DIR = 0;
	else
		DIR = 0;
	end
	
	%Bounds check and modify index
	if(DIR)
		if(idx ~= handles.frameBuf.getNumFrames())
			newIndex = idx + 1;
		else
			newIndex = idx;
		end
	else
		if(idx ~= 1)
			newIndex = idx - 1;
		else
			newIndex = idx;
		end
	end
    set(handles.etCurFrame, 'String', num2str(newIndex));
	nh = handles;

end		%gui_stepPreview()