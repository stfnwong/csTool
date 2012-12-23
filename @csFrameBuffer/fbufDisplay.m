function fbufDisplay(fb)
%FBUFDISPLAY
%
% Show csFrameBuffer in console

% Stefan Wong 2012

	if(~isa(fb, 'csFrameBuffer'))
		error('Argument not csFrameBuffer object');
	end
    fprintf('csFrameBuffer:\n');
    %Show buffer
    if(fb.nFrames == 0)
        fprintf('WARNING: Frame Buffer not set\n');
    else
        fprintf('csFrameBuffer.nFrames = %d\n', fb.nFrames);
        fsz = size(fb.frameBuf(1).img);
        fprintf('Frame size: %d x %d\n', fsz(2), fsz(1));
    end
    %Show path
    if(fb.path == ' ')
        fprintf('WARNING: csFrameBuffer.path not set\n');
    else
        fprintf('csFrameBuffer.path : %s\n', fb.path);
    end
    %Show extension
    if(fb.ext == ' ')
        fprintf('WARNING: csFrameBuffer.ext not set\n');
    else
        fprintf('csFrameBuffer.ext : %s\n', fb.ext);
    end
    %Show frame number
    fprintf('csFrameBuffer.fNum = %d\n', fb.fNum);
    if(fb.verbose == 1)
        fprintf('csFrameBuffer verbose mode on\n');
    else
        fprintf('csFrameBuffer verbose mode off\n');
    end

end 	%fbufDisplay()
