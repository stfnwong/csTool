function [status nh varargout] = gui_loadFrames(handles, filename, numFrames)
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

	LOAD_ALL = false;
	if(ischar(numFrames))
		if(strncmpi(numFrames, 'all', 3))
			LOAD_ALL = true;
		end
	end

	if(LOAD_ALL)
		%Parse filename to get format
		[ef str num ext path] = fname_parse(filename);
		if(ef == -1)
			fprintf('ERROR: Couldnt parse filename %s\n', filename);
			status = -1;
			return;
		end
		fs = sprintf('%s%s_%03d.%s', path, str, num, ext);
		fprintf('Loading all files from %s onwards...\n', fs);
		handles.frameBuf = handles.frameBuf.parseFilename(filename);
		[handles.frameBuf exitflag nf] = handles.frameBuf.loadFrameData('all');
		if(exitflag == -1)
			fprintf('ERROR: Failed to load data into frame buffer\n');
			status = -1;
			return;
		end
        fprintf('Loaded %d frames into buffer\n', nf);
		%Pass the number of frames back up the call tree if requested
		if(nargout > 2)
			varargout{1} = nf;
		end
	else
		handles.frameBuf = handles.frameBuf.setNFrames(numFrames);
		handles.frameBuf = handles.frameBuf.parseFilename(filename);
		
		fprintf('Loading %d frames from %s...\n', numFrames, filename);
		[handles.frameBuf exitflag] = handles.frameBuf.loadFrameData();
		if(exitflag == -1)
			fprintf('ERROR: Failed to load data into frame buffer\n');
			status = -1;
			return;
		end
		%Update the etNumFrames string
		set(handles.etHighRange, 'String', num2str(numFrames));
	end

	status = 0;
	nh = handles;
end		%loadFrames()
