function [status nh] = gui_loadFrames(filename, numFrames, handles)
% LOADFRAMES
% Load specified frames into frame buffer. This function is intended to
% move the loading logic for csToolGUI out of the GUI file. Any UI method
% or event callback that requires frames to be loaded should use this
% method rather than implement the logic within the csToolGUI.m file.
%
% ARGUMENTS:
% filename  - Path of file to read 
% numFrames - Number of frames to read
%
% OUTPUTS
% status    - 0 if no errors, -1 if errors
%

% Stefan Wong 2013

	handles.frameBuf = handles.frameBuf.setNFrames(numFrames);
    handles.frameBuf = handles.frameBuf.parseFilename(filename);
	
	fprintf('Loading %d frames from %s...\n', numFrames, filename);
    [handles.frameBuf exitflag] = handles.frameBuf.loadFrameData();
	if(exitflag == 0)
        fprintf('ERROR: Failed to load data into frame buffer\n');
		status = -1;
		return;
	end
	%Update the etNumFrames string
	set(handles.etHighRange, 'String', num2str(numFrames));
	status = 0;
	nh = handles;
	

end		%loadFrames()