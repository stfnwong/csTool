function rFrame = genRandFrame(F, opts)
% GENRANDFRAME
% rFrame = genRandFrame(F, opts)
%
% Generate a random backprojection frame. Each frame contains an 
% elliptical cluster of 'target' data points. 
%
% Note that it is the callers responsibility to ensure the opts 
% structure is correctly filled.
%
% ARGUMENTS
% opts - Options structure for frame. This should contain the following
%        members.
%
%        imsz    - Image size as 2-element vector
%        loc     - Pixel location in frame to center distribution
%        tsize   - Seed for target size as 2-element vector [x y]
%        theta   - Seed for target orientation
%        npoints - Number of points to generate.
%        dist    - One of 'uniform' or 'normal'
%        dscale  - Data scaling factor
%        kernel  - If true, apply kernel function to data (TODO)
%

% Stefan Wong 2013

	imsz = opts.imsz;
	rFrame = zeros(imsz(2), imsz(1));
	% clamp number of points
	if(opts.npoints > (imsz(1) * imsz(2)) )
		opts.npoints = (imsz(1) * imsz(2)) - 1;
	end
	% clamp size
	if(opts.tsize(1) > 0.5 * imsz(1))
		opts.tsize(1) = opts.tsize(1) * 0.5;
	end
	if(opts.tsize(2) > 0.5 * imsz(2))
		opts.tsize(2) = opts.tsize(2) * 0.5;
	end

	if(strncmpi(opts.dist, 'uniform', 7))
		r     = sqrt(rand(opts.npoints, 1));
		theta = 2*pi*rand(opts.npoints, 1);
	else
		r     = sqrt(randn(opts.npoints, 1));
		theta = 2*pi*randn(opts.npoints, 1);
	end

	% Stretch into ellipse
	ex = fix(0.5 * opts.tsize(1) * r .* cos(theta) + opts.loc(1));
	ey = fix(0.5 * opts.tsize(2) * r .* sin(theta) + opts.loc(2));

	% TODO : Rather than just get non-negative points, actually shift 
	% points ?
	xidx = ex(ex > 0);
	yidx = ey(ey > 0);
	% for some reason this fails if written in one line (why..?)
	xidx = real(xidx);
	yidx = real(yidx);

	if(F.verbose)
		%fprintf('DEBUG: ex: %f, ey: %f\n', ex, ey);
	end

	% map ellipse back to backprojection image
	%rFrame(ey, ex) = opts.sfac;
	rFrame(yidx, xidx) = opts.sfac;


end 	%genRandFrame()
