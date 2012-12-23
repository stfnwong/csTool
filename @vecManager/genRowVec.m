function vec = genRowVec(V, data, varargin)
% GENROWVEC
%
% Generate row vector from data. 
%
% ARGUMENTS:
%
% V - vecManager object
% data - input data. This is expected to be in bpimg format.
%
% OPTIONAL FORMATTING ARGUMENTS:
% Pass in an integer to specify the dimension of the final vector. Accepted values are
% 16, 8, 4, and 1 (for scalar data)
% If no formatting argument is passed in, scalar is assumed
%

% Stefan Wong 2012

	%Check optional arguments
	if(nargin > 1)
		fmt = varargin{1};
	else
		fmt = 1;
	end
	%get data dimension
	[h w d] = size(data);
	%get row dimension
	if(fmt ~= 16 || fmt ~= 8 || fmt ~= 4 || fmt ~= 1)
		error('Invalid formatting size %d', fmt);
	end	
	rdim = w/fmt;
	%pre-allocate vector cell and accumulate
	vec = cell(h, cdim);
	for y = 1:h;
		for x = 1:rdim;
			vec{y,x} = data(y, x:x+rdim);
		end
	end

end 	%genRowVec()
