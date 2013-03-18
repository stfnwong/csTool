function moments = imgAccumVec(T, bpvec, varargin)
% IMGACCUMVEC
% moments = imgAccumVec(T, bpvec)
% moments = imgAccumVec(T, bpvec, [..OPTIONS..])
%
% Perform image accumlation on backprojection vector bpvec
%
%


% Stefan Wong 2013

	if(~isempty(varargin))
		if(strncmpi(varargin{1}, 'sp', 2))
			spstat = varargin{2};
		end
	end


	% Do checks
	if(length(bpvec) < 1)
		fprintf('ERROR: No pixels in bpvec\n');
		moments = zeros(1,5);
		return;
	end

	%Do accumulation
	if(exist('spstat', 'var'))
		M00 = length(bpvec) * spstat.fac;
	else
		M00 = length(bpvec);
	end
	M10 = sum(bpvec(1,:));
	M01 = sum(bpvec(2,:));
	M11 = sum(bpvec(1,:) .* bpvec(2,:));
	M20 = sum(bpvec(1,:) .* bpvec(1,:));
	M02 = sum(bpvec(2,:) .* bpvec(2,:));
	
	moments = [M00 M10 M01 M11 M20 M02];	


end 
