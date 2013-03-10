function tVec = bufGetTraj(FB, varargin)
% BUFGETTRAJ
% Extract the tracjectory of target in frames. By default, bufGetTraj returns the 
% trajectory of all frames stored in the csFrameBuffer object FB. To get the 
% trajectory over a specified range of frames, pass the 'range' option followed by
% a 1x2 row vector of the form [start end] where start and end are the limits of the
% required range. This value is automatically bounds checked and clipped
%

% Stefan Wong 2013

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'range', 5))
			range = varargin{2};
			if(~isequal(size(range), [1 2]))
				fprintf('Incorrect format in range, must be 1x2 row vector\n');
				tVec = [];
				return;
			end
			%Bounds check range
			if(range(1) < 1)
				range(1) = 1;
			end
			if(range(2) > FB.nFrames)
				range(2) = FB.nFrames;
			end
		end
	else
		range = [1 FB.nFrames];
	end

	tVec = zeros(2, range(2));		%Pre-allocate array
	fh   = FB.getFrameHandle(range(1):range(2));
	for k = 1:range(2)
		param     = get(fh(k), 'winParams');
		tVec(:,k) = [param(1) ; param(2)];
	end 
		

end 	%bufGetTraj
