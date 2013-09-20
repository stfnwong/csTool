function [moments] = winAccumWeight(T, bpvec, trackWindow)
% WINACCUMWEIGHT
% [moments] = winAccumWeight(T, bpvec, trackWindow)
%




	
	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'force', 5))
			FORCE = true;
		end
	end

	%Sanity check arguments
	if(isempty(wparam))
		%No window parameters supplied - compute new ones
		if(T.verbose)
			fprintf('No window parameters supplied, computing from moments...\n');
		end
		moments = imgAccum(T, bpimg);
	else
		%Check wparam
		if(numel(wparam) == 0)
			fprintf('%s no data in wparam\n', T.pStr);
			moments = zeros(1,5);
			return;
		end
	end




	if(T.ROT_MATRIX)
		%Make aliases 
		xc    = wparam(1);
		yc    = wparam(2);
		theta = wparam(3);
		axmaj = wparam(4);
		axmin = wparam(5);
		xlim  = [(xc - axmaj) (xc + axmaj)];
		ylim  = [(yc - axmin) (yc + axmin)];
		%Clean up edges of bounding region
		xlim(xlim > dims(1)) = dims(1);
		xlim(xlim < 1)       = 1;
		ylim(ylim > dims(2)) = dims(2);
		ylim(ylim < 1)       = 1;
		%Initialise moment sums
		M00 = 0; M10 = 0; M01 = 0; M11 = 0; M20 = 0; M02 = 0;
		%Check bpvec type for bpval data
		bpdim = size(bpvec);
		if(bpdim(1) == 3)
			%Use bpval instead of 1
			for k = 1:length(bpvec)
				if(bpvec(1,k) >= xlim(1) && bpvec(1,k) <= xlim(2) && ...
                   bpvec(2,k) >= ylim(1) && bpvec(2,k) <= ylim(2))
					%Pixel is in window
					M00 = M00 + bpvec(3,k);
					M10 = M10 + bpvec(1,k)  * bpvec(3,k);
					M01 = M01 + bpvec(2,k)  * bpvec(3,k);
					M11 = M11 + (bpvec(1,k) .* bpvec(2,k)) * bpvec(3,k);
					M20 = M20 + (bpvec(1,k) .* bpvec(1,k)) * bpvec(3,k);
					M02 = M02 + (bpvec(2,k) .* bpvec(2,k)) * bpvec(3,k);
				end
			end
		else
			%Find pixels within window region of vector
			for k = 1:length(bpvec)
				if(bpvec(1,k) >= xlim(1) && bpvec(1,k) <= xlim(2) && ...
				   bpvec(2,k) >= ylim(1) && bpvec(2,k) <= ylim(2))
					%This pixel is in window
					M00 = M00 + 1;
					M10 = M10 + bpvec(1,k);
					M01 = M01 + bpvec(2,k);
					M11 = M11 + bpvec(1,k) .* bpvec(2,k);
					M20 = M20 + bpvec(1,k) .* bpvec(1,k);
					M02 = M02 + bpvec(2,k) .* bpvec(2,k);
				end
			end
		end
		%if(exist('spstat', 'var'))
		%	M00 = M00 * spstat.fac;
		%end
		moments = [M00 M10 M01 M11 M20 M02];
	else
		fprintf('Linear Constraint not yet implemented\n');
		moments = zeros(1,5);
		return;
	end


end 	%winAccumWeight()
