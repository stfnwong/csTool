function rfig_keyPressCallback(hObject, eventdata)
% RFIG_KEYPRESSCALLBACK
% Handle keypresses for rect-test-figure

	%DEBUG:
	fprintf('rfig_keyPressCallback type : %s\n', get(hObject, 'Type'));

	switch eventdata.Character
		case 'r'
			%Check if we have a current rectangle, and if not, create a new one
			rData = get(hObject, 'UserData')
			%DEBUG:
			fprintf('hObject.UserData :\n');
			disp(rData);
			if(rData.isRect)
				%Existing rectangle, delete current one 
				fprintf('Current rect position :\n');
				disp(get(rData.rHandle, 'Position'));
				rData.isRect = 0;
				delete(rData.rHandle);
				set(hObject, 'UserData', rData);
			else
				%No rectangle - create new one
				ca = get(hObject, 'CurrentAxes');
				if(isempty(ca))
					fprintf('ERROR: hObject.CurrentAxes is empty\n');
					return;
				end
				rh = imrect(ca, [10 10 100 100]);
				addNewPositionCallback(rh, @(p) title(mat2str(p, 3)));
				crFcn = makeConstrainToRectFcn('imrect', get(ca, 'XLim'), get(ca, 'YLim'));
				setPositionConstraintFcn(rh, crFcn);
				%Write data back to hObject
				rData.isRect = 1;
				rData.rHandle = rh;
				set(hObject, 'UserData', rData);
			end
	end


end 	%rfig_keyPressCallback()
