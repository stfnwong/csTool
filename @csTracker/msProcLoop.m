function [status tOutput] = msProcLoop(T, bpimg, trackWindow, opts)
% SELMETHOD
% status = msProcLoop(T, bpimg, trackWindow, opts)
%
% Perform specified tracking operation on the backprojection image bpimg.
% csTracker.msProcLoop() performs the tracking method specified in T.method 
% on the backprojection image bpimg.
%
% The value in T.FIXED_ITER determines the kind of tracking loop to use. If 
% T.FIXED_ITER is 1, the tracking will perform T.MAX_ITER loops for every 
% frame. This can be useful to see that there are no side effects to 
% overtracking in the FPGA. If T.FIXED_ITER is 0, the tracking will continue
% until eps is less than T.EPSILON in each dimension of eps (e.g: eps(1) <
% T>EPSILON && eps(2) < T.EPSILON)

% Stefan Wong 2013


	if(isfield(opts, 'dims'))
		dims = opts.dims;
	end

	%Allocate memory to store all intermediate results
	tVec     = zeros(2, T.MAX_ITER);
	fmoments = cell(1, T.MAX_ITER);	

	% ==== PRE-ALLOCATION STAGE ==== %
	% Load any data needed in the loop here
	if(T.method == T.SPARSE_WINDOW || T.method == T.SPARSE_IMG)
		[spvec spstat] = buf_spEncode(bpimg, opts.bpsum, 'auto', 'rt', 'trim', 'sz', T.SPARSE_FAC);
		if(isempty(spstat))
			status  = -1;
			tOutput = [];
			return;
		end
		if(T.verbose)
			if(spstat.numZeros > 0)
				fprintf('WARNING: Zeros in spvec\n');
			end
			fprintf('spvec has %d elements\n', spstat.bpsz);
			fprintf('spfac is %d\n', spstat.fac);
		end
		%Check spvec
		if(sum(sum(spvec)) == 0)
			fprintf('ERROR: spvec has no bpdata\n');
			status  = -1;
			tOutput = [];
			return;
		end
	elseif(T.method == T.MOMENT_WINVEC)

		% TODO : Where to specify bpvec if no frame handle available?
		if(opts.conv_vec)
			bpvec = vec2bpimg(bpimg, 'dims', dims);
		else
			bpvec = bpimg;		% the vector was passed in as image param
		end
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
				status  = -1;
				tOutput = [];
				return;
			case T.SPARSE_WINDOW
                %To avoid crashing csTool, perform a more graceful exit if
                %we dont have spvec by this point
                if(~exist('spvec', 'var'))
                    fprintf('ERROR: spvec panic!\n');
                    status  = -1;
					tOutput = [];
                    return;
                end
				moments = winAccumVec(T, spvec, trackWindow, dims, 'sp', spstat, 'zm', opts.zmtrue);
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
				status  = -1;
				tOutput = [];
				return;
		end

		if(T.verbose)
            fprintf('Moments (loop %2d) : ', n);
            disp(moments);
		end
		%Store intermediate results
		fmoments{n} = moments;
		%tVec(:,n)   = [moments(1) ; moments(2)];

		% Shift window position
		trackWindow(1) = moments(2) / moments(1);
		trackWindow(2) = moments(3) / moments(1);
		tVec(:,n)      = [trackWindow(1) ; trackWindow(2)];

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
	end

	%Check that we did converge, and if not report
	cverge =  abs(tVec(:,n) - tVec(:,n-1));
	%NOTE: For some reason, MATLAB reject the below test with a scalar AND
	%operator (&&). This does not occur if the same test is run from
	%command line
	if(cverge(1) > T.EPSILON & cverge(2) > T.EPSILON)
		fprintf('WARNING: tVec failed to converge in %d iters\n', T.MAX_ITER);
	end

	%Compute new window parameters
	wparam = wparamComp(T, moments);
	%wparam = wparamCompB(T, moments);
	%wparam = wparamCompCS(T, moments);
	%DEBUG: - Get rid of NaNs by force
	wparam(isnan(wparam)) = 1;

	if(T.verbose)
		fprintf('wparam :');
		disp(wparam);
		fprintf('\n');
	end
	%Enforce minimum windw size contraint (2x2 minimum)
	if(wparam(4) < 2 || isnan(wparam(4)))
		wparam(4) = 2;
	end
	if(wparam(5) < 2 || isnan(wparam(5)))
		wparam(5) = 2;
	end
	%Check wparam
	if(wparam(4) > dims(1))
		wparam(4) = dims(2);
		if(T.verbose)
			fprintf('%s clipped wparam(4) to %d\n', T.pStr, dims(2));
		end
	end
	if(wparam(4) < 1)
		wparam(4) = 1;
		if(T.verbose)
			fprintf('%s clipped wparam(4) to 1 \n', T.pStr);
		end
	end
	if(wparam(5) > dims(1))
		wparam(5) = dims(1);
		if(T.verbose)
			fprintf('%s clipped wparam(5) to %d \n', T.pStr, dims(1));
		end
	end
	if(wparam(5) < 1)
		wparam(5) = 1;
		if(T.verbose)
			fprintf('%s clipped wparam(5) to 1 \n', T.pStr);
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
		fprintf('wparam:\n');
		disp(wparam);
	end

	if(exist('spstat', 'var'))
		if(spstat.fac > 1)
			issparsevec = 1;
			spfac       = spstat.fac;
		else
			issparsevec = 0;
			spfac       = 1;
		end
	else
		issparsevec = 0;
		spfac       = 0;
	end
	% Return structure with csFrame parameters
	tOutput = struct('tvec', tVec, ...
		             'winparams', wparam, ...
		             'moments', {fmoments}, ...
		             'niters', n, ...
		             'method', T.methodStr{T.method}, ... 
		             'issparsevec', issparsevec, ...
		             'sparsefac', spfac );
	status = 0;
	
end 	%msProcLoop()
