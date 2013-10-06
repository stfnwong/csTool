function varargout = patternVerify(V, vec, refvece, varargin)
% PATTERNVERIFY
% Verify pipeline pattern data for column buffer, backprojection, and so on.
%
% ARGUMENTS
%
%
% OUTPUTS
%

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'vtype', 5))
					vtype = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'vsz', 3))
					vsz = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'dtype', 5))
					dtype = varargin{k+1};
				end
			end
		end
	end

	% Check what we have
	if(~ischar(fname))
		fprintf('ERROR (patternVerify): pattern vector filename must be string\n');
		if(nargout > 0)
			varargout{1} = -1;
		end
		return;
	end

	if(~exist('vtype', 'var'))
		fprintf('Setting vtype to scalar...\n');
		vtype = 'scalar';
	end
	if(~exist('vsz', 'var'))
		fprintf('Setting vector size to 1...\n');
		vsz = 1;
	end
	% check for datatype to read 
	if(~exist('dtype', 'var'))
		dtype = '%u8';
	end

	[pvector status] = vecDiskRead(V, fname);





end 	%patternVerify()
