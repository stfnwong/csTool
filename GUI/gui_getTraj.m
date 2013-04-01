function [tVec varargout] = gui_getTraj(frameBuf, varargin)
% GUI_GETTRAJ
% status = gui_getTraj(frameBuf, [...OPTIONS...])
% Get trajectory vector for csToolGUI.
%

% Stefan Wong 2013

	TRIM  = false;
	DEBUG = false;
	FIX   = false;		%maintain a fixed number of points ahead and behind frame
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'range', 5))
					range = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'trim', 4))
					TRIM = true;
				elseif(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = true;
				elseif(strncmpi(varargin{k}, 'fix', 3))
					FIX = true;
					fw  = varargin{k+1};		%frame window
				end
			end
		end
	end

	%Sanity check
	if(~isa(frameBuf, 'csFrameBuffer'))
		fprintf('ERROR: frameBuf not a valid csFrameBuffer\n',
		tVec = [];
		if(nargout > 1)
			status = -1;
		end
		return;
	end

	%Check optional arguments
	if(~exist('range', 'var'))
		range = [1 frameBuf.getNumFrames()];
	end
	
	if(FIX)
		%maintain a trajcetory that is a fixed number of frames ahead and behind
		%of current frame.
		idx = fw(2);	
		N   = frameBuf.getNumFrames();
		if(idx < 1)
			if(fw(1) > N)
				range = [1 N];
			else
				range = [1 fw(1)];
			end
		elseif(idx > N)
			if(fw(1) > N)
				range = [1 N];
			else
				range = [N-fw(1) N];
			end
		else
			range = [idx-fw(1) idx+fw(1)];
			if(idx + fw(1) > N)
				range(2) = N;
			end
			if(idx - fw(1) < 1)
				range(1) = 1;
			end
		end
	end

	tVec = zeros(2, range(2));
	for k = range(1):range(2)
		fh      = frameBuf.getFrameHandle(k);
		wparam = get(fh, 'winParam'); 
		if(sum(wparam) == 0 || numel(wparam) == 0)
			%No parameters for this frame
			if(DEBUG)
				fprintf('No parameters in frame %d\n', k);
			end
			if(TRIM)
				tVec = tVec(:,1:k);
			end
			break;
		else
			tVec(1,k) = wparam(1);
			tVec(2,k) = wparam(2);
		end
	end

end 	%gui_geTraj()
