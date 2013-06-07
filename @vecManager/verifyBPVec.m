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
	
	if(strncmpi(vtype, 'row', 3) || strncmpi(vtype, 'col', 3))
		%Get a reference vector		
		[refVec status dims] = genHueVec(V, fh, vtype, val, 'scale', S_FAC);
		if(status == -1)
			fprintf('ERROR: genHueVec() produced badly-formed vector\n');
			if(nargout > 1)
				varargout{1} = -1;
			end
			return;
		end
		vdim   = dims(1) / val;
		vec    = cell(1,rdim);
		errVec = cell(1,rdim);
		numErr = 0;
		%Show a waitbar to indicate progress hasn't stalled
		total  = vdim * length(vec{0});		%Total progress
		prg    = 0;							%Current progress
		wb = waitbar(0, 'Name', 'Verifying Vector...');
		for k = 1:vdim
			rvec = refVec{k};				
			tvec = vec{k};					%test vector for element k
			evec = zeros(1,length(rvec));
			for n = 1:length(tvec)
				if(rvec(n) ~= tvec(n))
					numErr  = numErr + 1;
					evec(n) = 1;
				end
				prg = prg + 1;
				waitbar(prg/total, wb, sprintf('Verifying (%d/%d)', prg, total));
			end
			errVec{k} = evec;
		end
		delete(wb);

		if(nargout > 1)
			%Format stats for output
		end
	elseif(strncmpi(vtype, 'scalar', 6))

	else
		fprintf('ERROR: Not a valid vtype [%s]\n', vtype);
		status = -1;
		return;
	end	

end 	%verifyBPVec()
