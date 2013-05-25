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
	%if(isempty(trackWindow))
	%	fprintf('ERROR: empty trackWindow in csTracker.msProcLoop()\n');
	%	status = -1;
	%	return;
	%end

	%Allocate memory to store all intermediate results
	tVec     = zeros(2, T.MAX_ITER);
	fmoments = cell(1, T.MAX_ITER);	

	% ==== PRE-ALLOCATION STAGE ==== %
	% Load any data needed in the loop here
	if(T.method == T.MOMENT_WINACCUM || T.method == T.MOMENT_IMGACCUM)
		bpimg = vec2bpimg(get(fh, 'bpVec'), get(fh, 'dims'));
	elseif(T.method == T.SPARSE_WINDOW || T.method == T.SPARSE_IMG)
		%if(get(fh, 'isSparse') == 0)
			bpimg          = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'));
			[spvec spstat] = buf_spEncode(bpimg, 'auto', 'rt', 'trim', 'sz', T.SPARSE_FAC);
            if(isempty(spstat))
                status = -1;
                return;
            end
			if(T.verbose)
				if(spstat.numZeros > 0)
					fprintf('WARNING: Zeros in spvec\n');
				end
                if(spstat.fac > 1)
                    fprintf('fac: %d (frame %s)\n', spstat.fac, get(fh, 'filename'));
                end
                fprintf('spvec has %d elements\n', spstat.bpsz);
			end
			zmtrue         = length(get(fh, 'bpVec'));
			%Check spvec
			if(sum(sum(spvec)) == 0)
				fprintf('ERROR: spvec has no bpdata\n');
				status = -1;
				return;
			end
		%end
		dims = get(fh, 'dims');
	elseif(T.method == T.MOMENT_WINVEC)
		bpvec = get(fh, 'bpVec'); 
		dims  = get(fh, 'dims');
	end

	% ======== MEANSHIFT PROCESSING LOOP ======== %
	ctemp = [trackWindow(1) trackWindow(2)];
	if(T.verbose)
		fprintf('Set temp centroid as [%d %d]\n', ctemp(1), ctemp(2));
	end
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
                %A BUG IS HERE
                %To avoid crashing csTool, perform a more graceful exit if
                %we dont have spvec by this point
                if(~exist('spvec', 'var'))
                    fprintf('ERROR: spvec panic!\n');
                    status = -1;
                    return;
                end
				moments = winAccumVec(T, spvec, trackWindow, dims, 'sp', spstat, 'zm', zmtrue);
			case T.SPARSE_IMG
				moments = imgAccumVec(T, spvec, 'sp', spstat);
			case T.MOMENT_WINVEC
				moments = winAccumVec(T, bpvec, trackWindow, dims);	
			case T.ONLINE_SELECTION
				fprintf('UNDER CONSTRUCTION\n');
			case T.SPARSE_ONLINE_SELECTION
				fprintf('UNDER CONSTRUCTION\n');
			otherwise
				fprintf('Not yet implemented\n');
				status = -1;
				return;
		end
		%DEBUGGING:
		if(T.verbose)
            fprintf('Moments (loop %2d) : ', n);
            disp(moments);
        end
		%Store intermediate results
		fmoments{n} = moments;
		tVec(:,n)   = [moments(1) ; moments(2)];
		% ========================================================================= %
		% CONVERGENCE TEST: Test here to see if we should exit the loop
		% ========================================================================= %
		if(~T.FIXED_ITER && n > 1)
			%If we converge early, quit the loop
			cverge = abs(tVec(:,n) - tVec(:,n-1));
			if(cverge(1) < T.EPSILON && cverge(2) < T.EPSILON)
				if(T.verbose)
					fprintf('Converged on loop %d\n', n);
				end
				break;
			end
		end	
		% ========================================================================= %

		%Continously resize?
		if(T.WSIZE_CONT)
			%Save previous centroid
			%cTemp = [trackWindow(1) trackWindow(2)];
			trackWindow = wparamComp(T, moments);
			switch(T.WSIZE_METHOD)
				case T.ZERO_MOMENT
					if(exist('spstat', 'var'))
						trackWindow(4) = fix(sqrt(moments(1)) * spstat.fac);
						trackWindow(5) = fix(sqrt(moments(1)) * spstat.fac);
					else
						trackWindow(4) = fix(sqrt(moments(1)));
						trackWindow(5) = fix(sqrt(moments(1)));
					end	
				case T.EIGENVEC
					%Make window size based on semi-major/semi-minor axes of ellipse
					%Enfore minimum window size
					%NOTE: Attempting half the semi axis length
					trackWindow(4) = trackWindow(4);
					trackWindow(5) = trackWindow(5);
				case T.HALF_EIGENVEC
					trackWindow(4) = trackWindow(4) / 2;
					trackWindow(5) = trackWindow(5) / 2;

				otherwise
					fprintf('ERROR: No such window size method, using zero moment...\n');
					trackWindow(4) = fix(sqrt(moments(1)));
					trackWindow(5) = fix(sqrt(moments(1)));
			end
			%Enforce minimum window size (2x2)
			if(trackWindow(4) < 2 || isnan(trackWindow(4)))
				trackWindow(4) = 2;
			end
			if(trackWindow(5) < 2 || isnan(trackWindow(5)))
				trackWindow(5) = 2;
			end
			%If xc, yc are zero, NaN, or Inf, use previous values so that window 
			%remains in place. We also check if both the centroid locations
			%are at one, as this is a common error condition. In the case
			%the the value is actually one, there should be a smooth
			%transition from the previous frame into this one (as that
			%assumption is build into the tracker) and so recovering the
			%previous frame will still give an acceptable result)
			if(isnan(trackWindow(1)) || isnan(trackWindow(2)) || ...
               isinf(trackWindow(1)) || isinf(trackWindow(2)) || ...
               trackWindow(1) == 0   || trackWindow(2) == 0   || ...
               (trackWindow(1) == 1  && trackWindow(2) == 1))
				trackWindow(1) = ctemp(1);
				trackWindow(2) = ctemp(2);
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
	%DEBUG: - Get rid of NaNs by force
	wparam(isnan(wparam)) = 1;

	% ==== WINDOW SIZING ROUTINE ==== %	
	switch(T.WSIZE_METHOD)
		case T.ZERO_MOMENT
			if(exist('spstat', 'var'))
				wparam(4) = fix(sqrt(moments(1)) * spstat.fac);
				wparam(5) = fix(sqrt(moments(1)) * spstat.fac);
			else
				wparam(4) = fix(sqrt(moments(1)));
				wparam(5) = fix(sqrt(moments(1)));
			end
		case T.EIGENVEC
			%Value are already correct in wparamComp
		case T.HALF_EIGENVEC
			%Make window size based on semi-major/semi-minor axes of ellipse
			%NOTE: Trying half the semi-axis size
			wparam(4) = wparam(4) / 2;
			wparam(5) = wparam(5) / 2;
		otherwise
			fprintf('ERROR: No such window size method, using zero moment...\n');
			wparam(4) = fix(sqrt(moments(1)));
			wparam(5) = fix(sqrt(moments(1)));
	end
	%Enforce minimum windw size contraint (2x2 minimum)
	if(wparam(4) < 2 || isnan(wparam(4)))
		wparam(4) = 2;
	end
	if(wparam(5) < 2 || isnan(wparam(5)))
		wparam(5) = 2;
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
	%If by this point there are zero, NaN, or infinities in the centroid, then use
	%values from previous loop (so that window shrinks but stays in place)
	
	if(isnan(wparam(1)) || isnan(wparam(2)) || wparam(1) == 0 || wparam(2) == 0 || ...
       (wparam(1) == 1 && wparam(2) == 1))
		wparam(1) = ctemp(1);
		wparam(2) = ctemp(2);
	end	
	if(T.verbose)
		fprintf('wparam for %s\n', get(fh, 'filename'));
		disp(wparam);
	end
	%Write data out to frame handle
	set(fh, 'tVec', tVec);
	set(fh, 'winParams', wparam);
	set(fh, 'moments', fmoments);
	set(fh, 'nIters', n);
	set(fh, 'method', T.methodStr{T.method});
	%Set sparse parameter
    if(exist('spstat', 'var'))
		if(spstat.fac > 1)
			set(fh ,'isSparse', 1);
            set(fh, 'sparseFac', spstat.fac);
		else
			set(fh ,'isSparse', 0);
		end
	else
        %Set here in case the frame was previously tracked as sparse and is
        %now tracked as windowed accumulation, etc
        set(fh, 'isSparse', 0);
        set(fh, 'sparseFac', 0);
    end

	status = 0;
	
end 	%msProcLoop()
