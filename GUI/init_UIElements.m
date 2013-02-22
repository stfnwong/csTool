function handles = init_UIElements(handles)
% INIT_UIELEMENTS
%
% Set UI elements to display settings held internally within option strucutres, etc

% Stefan Wong 2013

	global ASSET_DIR;
	global DATA_DIR;

	mstr = handles.tracker.methodStr;
	set(handles.trackMethodList, 'String', mstr);
	set(handles.trackMethodList, 'Value', 1);
	mstr = handles.segmenter.methodStr;
	set(handles.segMethodList, 'String', mstr);
	set(handles.segMethodList, 'Value', 1);
	path = which(sprintf('%s/ui.mat', DATA_DIR));
	if(isempty(path))
		%Use defaults
		set(handles.etHighRange, 'String', 64);
		set(handles.etLowRange, 'String', 1);
		set(handles.etFilePath, 'String', sprintf('%s/sample.tif', ASSET_DIR));
		set(handles.etNumFrames, 'String', 64);
	else
		load(path);
		set(handles.etHighRange, 'String', ui.highRange);
		set(handles.etLowRange, 'String', ui.lowRange);
		set(handles.etFilePath, 'String', ui.filePath);
		set(handles.etNumFrames, 'String', ui.numFrames);
	end
	
	return;
	
end		%init_UIElements()

