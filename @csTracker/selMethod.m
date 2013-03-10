function status = selMethod(T, fh, trackWindow)
% SELMETHOD
% status = selMothod(T, fh, trackWindow)
%
% Perform specified tracking operation on the frame handle fh.
% csTracker.selMethod() performs the tracking method specified in T.method 
% on the frame contained in the frame handle fh.
%
% The value in T.FIXED_ITER determines the kind of tracking loop to use. If 
% T.FIXED_ITER is 1, the tracking will perform T.MAX_ITER loops for every 
% frame. This can be useful to see that there are no side effects to 
% overtracking in the FPGA. If T.FIXED_ITER is 0, the tracking will continue
% until eps is less than T.EPSILON in each dimension of eps (e.g: eps(1) <
% T>EPSILON && eps(2) < T.EPSILON)

	%Do a quick sanity check on trackWindow
	if(isempty(trackWindow))
		fprintf('ERROR: empty trackWindow in csTracker.selMethod()\n');
		status = -1;
		return;
	end

	if(T.FIXED_ITER)
		%Allocate memory
		tVec     = zeros(2, T.MAX_ITER);
		fwparam  = cell(1, T.MAX_ITER);
		fmoments = cell(1, T.MAX_ITER);
		for n = 1:T.MAX_ITER
			switch T.method
				case T.MOMENT_WINACCUM
					%Get bpimg
					bpimg = vec2bpimg(get(fh,'bpVec'), get(fh,'dims'));
					[moments wparam] = winAccumImg(T, bpimg, wpos);
				case T.MOMENT_IMGACCUM
					wparam           = [];
					moments          = imgAccum(T, get(fh, 'bpVec'));
				case T.KERNEL_DENSITY
					fprintf('Not yet implemented\n');
				otherwise
					error('Invalid tracking type');
			end
			%Write out results
			tVec(:,n)   = [moments(1) ; moments(2)];
			fwparam{n}  = wparam;
			fmoments{n} = moments;
			%Get initial window position for next frame
			%wpos        = wparam;		
			%TODO: Place a test here for early convergence?
			% BAIL if no pixels in window
			if(sum(moments) == 0)
				fprintf('No pixels in previous window (iter %d) - ending loop\n', n);
				break;
			end
		end
		
	else
		%For now, preallocate twice MAX_ITER for tVec
		tVec     = zeros(1, T.MAX_ITER * 2);
		fwparam  = cell(1, T.MAX_ITER * 2);
		fmoments = cell(1, T.MAX_ITER * 2);
		%Converge until tVec(n) - tVec(n-1) < T.EPSILON
		n   = 1;
		eps = [T.EPSILON + 1; T.EPSILON + 1];
		while( eps(1) > T.EPSILON && eps(2) > T.EPSILON)
			switch T.method
				case T.MOMENT_WINACCUM
					[moments wparam] = winAccum(T, ...
												get(fh, 'bpVec'), ...
												wpos, ...
												get(fh, 'dims'));
				case T.MOMENT_IMGACCUM
					wparam           = [];
					moments          = imgAccum(T, get(fh, 'bpVec'));
				case T.KERNEL_DENSITY
					fprintf('Not yet implemented\n');
				otherwise
					error('Invalid tracking type');
			end
			%Write out results
			tVec(:,n)   = [moments(1) ; moments(2)];
			fwparam{n}  = wparam; 
			fmoments{n} = moments;
			%Compute new eps
			if(n == 1)
				eps = tVec(:,1);
			else
				eps = tVec(:,n) - tVec(:,n-1);
			end
			n = n + 1;
			if(n > T.MAX_ITER)
				fprintf('WARNING: Failed to converge in %d iters\n', T.MAX_ITER);
				break;
			end
		end
	end
		%Calculate final window position and size
		
		%Write data out to frame handle
		set(fh, 'tVec',      tVec);
		set(fh, 'winParams', fwparam);
		set(fh, 'moments',   fmoments);
		if(sum(moments) ~= 0)
			T.fParams = fwparam{n};
		end
end 	%trackFrame()
