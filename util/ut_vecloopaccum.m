function moments = ut_vecloopaccum(bpvec, varargin)
% UT_VECLOOPACCUM
% Accumulate vector with loops. This function is intended to serve as a
% rerference accumulation count.
%
% Stefan Wong 2013

	%Check dimension of bpvec (needs to be row oriented)
	bpsz = size(bpvec);
	if(bpsz(1) ~= 2)
		error('bpvec must be 2xN matrix');
	end

	if(~isempty(varargin))
		%See if we have a region matrix option
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'region', 6))
					region = varargin{k+1};
				%More to come...
				end
			end
		end
	end

	%Check what we have
	if(exist('region', 'var'))
		xmin = region(1,1);
		xmax = region(1,2);
		ymin = region(2,1);
		ymax = region(2,2);
		rlo = [xmin ymin]';
		rhi = [xmax ymax]';

		M00 = 0; M10 = 0; M01 = 0; M11 = 0; M20 = 0; M02 = 0;
		for k = 1:length(bpvec)
			if(bpvec(:,k) >= rlo & bpvec(:,k) <= rhi)
				%Compute moment sums
				M00 = M00 + 1;
				M10 = M10 + bpvec(1,k);
				M01 = M01 + bpvec(2,k);
				M11 = M11 + bpvec(1,k) * bpvec(2,k);
				M20 = M20 + bpvec(1,k) * bpvec(1,k);
				M02 = M02 + bpvec(2,k) * bpvec(2,k);
			end
		end

		moments = [M00 M10 M01 M11 M20 M02];

	else
		%Assume that the current bpvec is already filtered
		M00 = 0; M10 = 0; M01 = 0; M11 = 0; M20 = 0; M02 = 0;
		M00 = length(bpvec);
		for k = 1:length(bpvec)
			M10 = M10 + bpvec(1,k);
			M01 = M01 + bpvec(2,k);
			M11 = M11 + bpvec(1,k) * bpvec(2,k);
			M20 = M20 + bpvec(1,k) * bpvec(1,k);
			M02 = M02 + bpvec(2,k) * bpvec(2,k);
		end
	end

end 	%ut_vecloopaccum():w



