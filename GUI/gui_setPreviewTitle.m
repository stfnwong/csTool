function gui_setPreviewTitle(fTitle, fHandle)
% SETPREVIEWTITLE
% Set the preview axes title. By default, this is taken to be the last component of 
% the frame handle filename. (Further options may be forthcoming in the future)
%

% Stefan Wong 2013

	if(isempty(fTitle))
		t = title(fHandle, 'No segmentation data for this frame');
	else
		[str num ext p f] = fname_parse(fTitle, 'n');	%#ok
		t = title(fHandle, sprintf('%s_%03d.%s', str, num, ext));
	end
	set(t, 'Interpreter', 'None');

end 	%gui_setPreviewTitle()
