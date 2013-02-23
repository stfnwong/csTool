%% RECTTEST
%
% Test of imrect functions

function gui_rectTest()
	%Generate handles struct
	handles.rf = [];
	%Generate figure handle
	if(~exist('rfig', 'var'))
		rfig = figure('Name', 'imrect() figure');
		set(rfig, 'WindowButtonDownFcn', {rfig_wbDown, handles});
		set(rfig, 'WindowButtonUpFcn',   {rfig_wbUp, handles});
		set(rfig, 'WindowKeyPressFcn',   {fig_keyPress, handles});
	else
		figure(rfig);
	end
	%Generate axes handle
	if(~exist('rax', 'var'))
		rax = axes('parent', rfig);
	end
	%Add axes and figure handles
	handles.axHandle  = rax;
	handles.figHandle = rfig;
end





function rfig_wbDown(hObject, eventdata, handles)

	cPos = fix(get(hObject, 'CurrentPoint'));
	handles.rf = imrect(handles.axHandle, [cPos(1) cPos(2) 4 4]);
	addNewPositionCallback(handles.rf, @(p) title(handles.axHandle, mat2str(p, 3)));
	handles.fcn = makeConstrainToRectFcn('imrec', get(handles.axHandle, 'XLim'), get(handles.axHandle, 'YLim'));
	setPositionConstraintFcn(handles.rf, handles.fcn);

end

function rfig_wbUp(hObject, eventdata, handles)

end

function rfig_keyPress(hObject, eventdata, handles)

	switch eventdata.Character
		case 'r'
	end
end