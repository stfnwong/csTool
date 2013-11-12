function csToolSaveState(handles, DATA_DIR, frameIndex)
% CSTOOLSAVESTATE
%
% Save the current state of the csToolGUI for restoration on next startup
%

% Stefan Wong 2013
	
	%Attempt to save workspace variables before exit.
	bufOpts      = handles.bufOpts;					%#ok
	segOpts      = handles.segOpts; 	 			%#ok
	trackOpts    = handles.trackOpts;				%#ok
	vecOpts      = handles.vecManager;              %#ok
	rStruct      = handles.rData;                   %#ok

	save(sprintf('%s/bufOpts.mat', DATA_DIR),      'bufOpts');
	save(sprintf('%s/segOpts.mat', DATA_DIR),      'segOpts');
	save(sprintf('%s/trackOpts.mat', DATA_DIR),    'trackOpts');
	save(sprintf('%s/vecOpts.mat', DATA_DIR),      'vecOpts');
	save(sprintf('%s/regionStruct.mat', DATA_DIR), 'rStruct');

	%Save ui variables
	ui.highRange = get(handles.etHighRange, 'String');
	ui.lowRange  = get(handles.etLowRange, 'String');
	ui.filePath  = get(handles.etFilePath, 'String');
	ui.numFrames = get(handles.etNumFrames, 'String');
	ui.curFrame  = get(handles.etCurFrame, 'String');
	%ui.curFrame  = get(handles.etCurFrame, 'String');
	save(sprintf('%s/ui.mat', DATA_DIR), 'ui');
	%Save frame index
	svars.index = frameIndex;                       %#ok
	save(sprintf('%s/svars.mat', DATA_DIR), 'svars');
	
	
end		%csToolSaveState()
