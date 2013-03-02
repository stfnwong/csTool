function nh = gui_ifaceEnable(handles, state)
% GUI_IFACEENABLE
% Enable or disable the csTool GUI (for example, during a processing
% operation. Pass the handles structure and either an on/off string or a
% 1/0 number to enable/disable the GUI
%

% Stefan Wong 2013


	if(ischar(state))
		if(strncmpi(state, 'on', 2))
			ENABLE = true;
		else
			ENABLE = false;
		end
	else
		if(state > 0)
			ENABLE = true;
		else
			ENABLE = false;
		end
	end
	
	if(ENABLE)
		%Get interface objects and enable them
		ifaceObj = findobj(handles.csToolFigure, 'Enable', 'off');
		set(ifaceObj, 'Enable', 'on');
		set(handles.csToolFigure, 'Name', handles.csToolFigName);
	else
		ifaceObj = findobj(handles.csToolFigure, 'Enable', 'on');
		set(ifaceObj, 'Enable', 'off');
		set(handles.csToolFigure, 'Name', 'Segmenting, please wait...');
	end

	nh = handles;
	
end		%gui_ifaceEnable()