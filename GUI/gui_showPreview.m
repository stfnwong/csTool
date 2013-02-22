function [status nh] = gui_showPreview(idx, handles)
% SHOWPREVIEW
% Read the image for the frame at idx and display on the preview
% axes fig_framePreview.

% Stefan Wong 2013

	if(idx == 0)
		fprintf('idx not set (equal 0)\n');
		status = -1;
		nh     = [];
		return;
	end
	if(isempty(idx))
		fprintf('idx no set (empty)\n');
		status = -1;
		nh     = [];
		return;
	end
	fh   = handles.frameBuf.getFrameHandle(idx);
	%fprintf('Previewing frame %s (%d)...\n', get(fh, 'filename'), idx);
	img  = imread(get(fh, 'filename'), 'TIFF');
	
	dims = size(img);
	if(dims(3) > 3)
		fprintf('WARNING: Dims greater than 3, truncating...\n');s
		img = img(:,:,1:3);		%why does this happen?!?!?
	end
	imshow(img, 'parent', handles.fig_framePreview);
	gui_setPreviewTitle(get(fh, 'filename'), handles.fig_framePreview);
	status = 0;
	nh = handles;
	return;

end		%gui_showPreview