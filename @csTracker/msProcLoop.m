function status = msProcLoop(T, fh, trackWindow)
% SELMETHOD
% status = msProcLoop(T, fh, trackWindow)
%
% Perform specified tracking operation on the frame handle fh.
% csTracker.msProcLoop() performs the tracking method specified in T.method 
% on the frame contained in the frame handle fh.
%
% The value in T.FIXED_ITER determines the kind of tracking loop to use. If 
% T.FIXED_ITER is 1, the tracking will perform T.MAX_ITER loops for every 
% frame. This can be useful to see that there are no side effects to 
% overtracking in the FPGA. If T.FIXED_ITER is 0, the tracking will continue
% until eps is less than T.EPSILON in each dimension of eps (e.g: eps(1) <
% T>EPSILON && eps(2) < T.EPSILON)

% Stefan Wong 2013

	%Do a quick sanity check on trackWindow
	if(isempty(trackWindow))
		fprintf('ERROR: empty trackWindow in csTracker.msProcLoop()\n');
		status = -1;
		return;
	end

	%Allocate memory to store all intermediate results
	tVec     = zeros(2, T.MAX_ITER);
	fmoments = cell(1, T.MAX_ITER);	

	% ==== PRE-ALLOCATION STAGE ==== %
	% Load any data needed in the loop here
	if(T.method == T.MOMENT_WINACCUM || T.method == T.MOMENT_IMGACCUM)
		bpimg = vec2bpimg(get(fh, 'bpVec'), get(fh, 'dims'));
	elseif(T.method == T.SPARSE_WINDOW || T.method == T.SPARSE_IMG)
		if(get(fh, 'isSparse') == 0)
			bpimg          = vec2bpimg(get(fh, 'bpVec'), get(fh, 'dims'));
			[spvec spstat] = buf_spEncode(bpimg, 'auto', 'trim');
			if(T.verbose)
				if(spstat.numZeros > 0)
					fprintf('WARNING: Zeros in spvec\n');
				end
			end
			zmtrue         = length(get(fh, 'bpVec'));
			%Check spvec
			if(sum(sum(spvec)) == 0)
				fprintf('ERROR: spvec has no bpdata\n');
				status = -1;
				return;
			end
		end
		dims = get(fh, 'dims');
	elseif(T.method == T.MOMENT_WINVEC)
		bpvec = get(fh, 'bpVec'); 
		dims  = get(fh, 'dims');
	end

	% ======== MEANSHIFT PROCESSING LOOP ======== %
	for n = 1:T.MAX_ITER
		switch T.method
			case T.MOMENT_WINACCUM	
				moments = winAccumImg(T, bpimg, trackWindow);	
			case T.MOMENT_IMGACCUM
				moments = imgAccum(T, bpimg);
			case T.KERNEL_DENSITY
				fprintf('Not yet implemented\n');
				status = -1;
				return;
			case T.SPARSE_WINDOW
				moments = winAccumVec(T, spvec, trackWindow, dims, 'sp', spstat, 'zm', zmtrue);
			case T.SPARSE_IMG
				moments = imgAccumVec(T, spvec, 'sp', spstat);
			case T.MOMENT_WINVEC
				moments = winAccumVec(T, bpvec, trackWindow, dims);	
			otherwise
				fprintf('Not yet implemented\n');
				status = -1;
				return;
		end
		%DEBUGGING:
		disp(moments);
		%Store intermediate results
		fmoments{n} = moments;
		tVec(:,n)   = [moments(1) ; moments(2)];
		if(~T.FIXED_ITER && n > 1)
			%If we converge early, quit the loop
			cverge = abs(tVec(:,n) - tVec(:,n-1));
			if(cverge(1) > T.EPSILON && cverge(2) < T.EPSILON)
				if(T.verbose)
					fprintf('Converged on loop %d\n', n);
				end
				break;
			end
		end	
	end

	%Check that we did converge, and if not report
	%if(abs(tVec(:,n) - tVec(:,n-1)) > T.EPSILON * ones(2,1))
	cverge =  abs(tVec(:,n) - tVec(:,n-1));
	%NOTE: For some reason, MATLAB reject the below test with a scalar AND
	%operator (&&). This does not occur if the same test is run from
	%command line
	if(cverge(1) > T.EPSILON & cverge(2) > T.EPSILON)
		fprintf('WARNING: tVec failed to converge in %d iters\n', T.MAX_ITER);
	end

	%Compute new window parameters
	wparam = wparamComp(T, moments);
	%DEBUG:
	disp(wparam);
	%DEBUG: Make window size function of zeroth moment
	%Here we need to check if we have the zmtrue variable, and based the window size
	%computation off of that if we do
	if(exist('zmtrue', 'var'))
		wparam(4) = fix(sqrt(zmtrue));
		wparam(5) = fix(sqrt(zmtrue));
	else
		wparam(4) = fix(sqrt(moments(1)));
		wparam(5) = fix(sqrt(moments(1)));
	end
	%Check wparam
	dims = get(fh, 'dims');
	if(wparam(4) > dims(1))
		wparam(4) = dims(2);
		if(T.verbose)
			fprintf('%s clipped wparam(4) to %d (%s)\n', T.pStr, dims(2), get(fh, 'filename'));
		end
	end
	if(wparam(4) < 1)
		wparam(4) = 1;
		if(T.verbose)
			fprintf('%s clipped wparam(4) to 1 (%s)\n', T.pStr, get(fh, 'filename'));
		end
	end
	if(wparam(5) > dims(1))
		wparam(5) = dims(1);
		if(T.verbose)
			fprintf('%s clipped wparam(5) to %d (%s)\n', T.pStr, dims(1), get(fh, 'filename'));
		end
	end
	if(wparam(5) < 1)
		wparam(5) = 1;
		if(T.verbose)
			fprintf('%s clipped wparam(5) to 1 (%s)\n', T.pStr, get(fh, 'filename'));
		end
	end
	%Write data out to frame handle
	set(fh, 'tVec', tVec);
	set(fh, 'winParams', wparam);
	set(fh, 'moments', fmoments);
	set(fh, 'nIters', n);
	set(fh, 'method', T.methodStr{T.method});

	status = 0;
	
end 	%msProcLoop()
