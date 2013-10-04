function errVec = bpErrVec(V, vectors, refvec, varargin)
% BPERRVEC
% Generate error vector for backrprojection output from verilog testbench
% 

% TODO : Genericise this method
% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'vtype', 5))
					vtype  = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bufsz', 5))
					bufsz  = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'fh', 2))
					fh     = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'imsz', 4))
					imsz   = varargin{k+1};
				end
			end
		end
	end

	% Check what we have
	if(~exist('vtype', 'var'))
		vtype = 'row';
	end
	if(~exist('bufsz', 'var'))
		bufsz  = 16;
	end
	if(~exist('imsz', 'var'))
		imsz   = [640 480];
	end

	% Need cell arrays to 
	if(~iscell(vectors))
		fprintf('ERROR: vectors must be cell array\n');
		errVec = [];
		return;
	end
	if(~iscell(refvec))
		fprintf('ERROR: refvec must be cell array\n');
		errVec = [];
		return;
	end

	vimg    = assemVec(V, vectors, 'vecfmt', vtype, 'imsz', imsz);
	rimg    = assemVec(V, refvec, 'vecfmt', vtype, 'imsz', imsz);
	vstream = zeros(1, imsz(1) * imsz(2));
	rstream = zeros(1, imsz(1) * imsz(2));

	% Scalarise images
	t  = imsz(1) * imsz(2);
	wb = waitbar(0, 'Scalarising vectors...', 'Name', 'Scalarising vectors...');
	n  = 1;
	for y = 1 : imsz(1)
		for x = 1 : imsz(2)
			vstream(n) = vimg(y,x);
			rstream(n) = rimg(y,x);
			n = n + 1;
			waitbar(n/t, wb, sprintf('Scalarising vector (%d/%d)', n, t));
		end
	end
	delete(wb);

	errVec = abs(vstream - rstream);

	%img = zeros(dims(2), dims(1));

	%switch (vtype)
	%	case 'row'

	%		n = 1;
	%		for y = 1 : imsz(2)
	%			x = 1;
	%			for k = 1 : length(vec)
	%				vk = vectors{k};
	%				img(y,x) = vk(n * x);
	%			end
	%			n = n + 1;
	%			x = x + 1;
	%			if(x > imsz(2))
	%				x = 1;
	%			end
	%		end
	%		% Re-arrange image into 

	%	case 'col'

	%		for k = 1 : length(vectors)
	%			vk = vectors{k};
	%			ridx = 

	%	case 'scalar'

	%	otherwise
	%		fprintf('ERROR: Not a valid vector type [%s]\n', vtype);
	%		errVec = [];
	%		return;
	%end
	

end 	%bpErrVec()
