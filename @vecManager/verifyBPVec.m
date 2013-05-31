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

	debug   = false;
	vsparse = false;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'type', 4))
					vtype = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'val', 3))
					val   = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'scale', 5))
					scale = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'sparse', 6))
					vsparse = true;
				elseif(strncmpi(varargin{k}, 'debug', 5))
					debug   = true;
				end
			end
		end
	end

	%Check what we have
	if(~exist('vtype', 'var'))
		vtype = 'scalar';
	end
	if(~exist('val', 'var'))
		val = 1;
	end
	if(~exist('scale', 'var'))
		S_FAC = 256;
	end
	
	% ======== VERIFICATION ========
	switch(vtype)
		case 'row'
			[refVec status dims] = genBPVec(V, fh, vtype, val, 'scale', S_FAC);
			if(status == -1)
				fprintf('ERROR: genBPVec() prodced badly-formed vector\n');
				if(nargout > 1)
					varargout{1} = -1;
				end
				return;
			end
			rdim = 
		case 'col'
		case 'scalar'
		otherwise
			fprintf('ERROR: [%s] not a valid vtype\n', vtype);
			status = -1;
			return;
	end
			

end 	%verifyBPVec()
