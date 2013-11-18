function vec = genTrackingVec(V, fh)
% GENTRACKINGVEC
% Generate test vector of tracking data for the frame given by fh. If fh is a vector 
% of frame handles, vec will be returned as a cell array of frame parameters.
%


% TODO : Completely re-write this component

% Stefan Wong 2012

	if(length(fh) > 1)
		%Format a cell array
		vec = cell(1, length(fh));
		for k = 1:length(fh)
			vec{k} = get(fh, 'winParams');
		end

	else
		vec = get(fh, 'winParams');
	end


end 	%genTrackingVec()
