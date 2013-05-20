function status = verifyBPVec(V, fh, vec, varargin)
% VERIFYBPVEC
%
% [status] = verifyBPVec(V, fh, vec, varargin);
%
% Verify a backprojection vector generated from a Verilog Testbench against the data
% for that frame (in fh)
%
% ARGUMENTS
% V   - vecManager class
% fh  - Frame handle to verify againsta
% vec - Testbench vector to verify
%
% OPTIONAL ARGUMENTS
% 'type', ['row', 'col'] - Orientation of vector (default: col)
% 'sparse', fac          - Verify this as sparse vector reduced by fac
%                          NOTE: valid values for fac are 16, 8, 4

% Stefan Wong 2012


	vtype   = 'col';
	sparse = 0;
	%Parse optional arguments
	if(nargin > 3)
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'type', 4))
					if(~ischar(varargin{k+1}))
						error('Type must be string (row or col');
					else
						vtype = varargin{k+1};
					end
				elseif(strncmpi(varargin{k}, 'sparse', 6))
					fac    = varargin{k+1};
					if(fac ~= 16 || fac ~= 8 || fac ~= 4)
						error('Invalid value for fac (must be 16, 8, or 4)');
					end
					sparse = 1;
				end
			end
		end
	end

	%Get backprojection data from fh
	bpvec = get(fh, 'bpvec');
	

end 	%verifyBPVec()
