function handles = init_restoreFrame(handles)
% INIT_RESTOREFRAME
%
% Attempt to restore current frame from most recent session

	global frameIndex;
	global DATA_DIR;
	
	path = which(sprintf('%s/svars.mat', DATA_DIR));
	if(isempty(path))
		%Nothing to restore
		frameIndex = 1;
	else
		fprintf('Restoring previous session...\n');
		load(path);
		frameIndex = svars.index;
		if(svars.index == 0)
			fprintf('ERROR: Previous frameIndex was zero, not restoring buffer...\n');
			return;
		end
		%Load frameset from previous session, and place the preview and
		%backprojection of the frame at frameIndex onto the GUI.
		[handles.frameBuf status] = handles.frameBuf.loadFrameData();
		if(status == 0)
			fprintf('ERROR: Failed to load image data for previous session\n');
		else
			fh   = handles.frameBuf.getFrameHandle(frameIndex);
			fprintf('Retrieving image at %s...\n', get(fh, 'filename'));
			handles.segmenter.segFrame(fh);
			img  = imread(get(fh, 'filename'));
			dims = size(img);
			if(dims(3) > 3)
				img = img(:,:,1:3);		%still not sure why this happens...?
			end
			bpimg = handles.segOpts.dataSz ./ vec2bpimg(get(fh, 'bpvec'));
			imshow(fig_framePreview, img);
			imshow(fig_bpPreview, bpimg);
		end
	end

end		%init_restoreFrame()


