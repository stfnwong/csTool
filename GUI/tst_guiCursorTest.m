function [cimg status]  = tst_guiCursorTest(axHandle, cursorPos, img, imSz, varargin)
% TST_GUICURSORTEST()
% [cmig status] = tst_guiCursorTest(axHandle, cursorPos, img, imSz)
%
% This function is for marking the cursor positon on the axes with handle axHandle.
% This functions is not intended for release, and is simply to remove some of the 
% clutter of testing the region select function, as well as automate some small 
% details
%

% Stefan Wong 2013

	img_w = imSz(1);
	img_h = imSz(2);
	
	h_line = cat(3, repmat(255, [1 img_w]), zeros(1, img_w), zeros(1, img_w));
	v_line = cat(2, repmat(255, [img_h 1]), zeros(img_h, 1), zeros(img_h, 1));

	%Check cursor pos is sensible
	if(cursorPos(1) > img_w)
		fprintf('ERROR: Cursor out of bounds in x dimension\n');
		cimg   = [];
		status = -1;
		return;
	end
	if(cursorPos(2) > img_h)
		fprintf('ERROR: Cursor out of bounds in y dimension\n');
		cimg   = [];
		status = -1;
		return;
	end

	cimg = img;
	cimg(cursorPos(2), :, :) = h_line;
	cimg(:, cursorPos(1), :) = v_line;
	return;

end 	%tst_guiCursorTest()
