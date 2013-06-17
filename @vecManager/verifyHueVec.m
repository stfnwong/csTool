function [status varargout] = verifyHueVec(V, fh, vec, varargin)
% VERIFYHUEVEC
% [status (...OPTIONAL...)] = verifyHueVec(V, fh, vec, varargin)
%
% Verify the hue vector vec against the contents of the frame handle fh.
%
% ARGUMENTS
% V - vecManager object
% fh - Frame handle to verify against
% vec - Vector of hue data to verify
%
% OPTIONAL ARGUMENTS
% 'type', ['row', 'col', 'scalar'] - Orientation of vector (default: scalar)
% 'val', [16, 8, 4, 2, 1]          - Length of vector (default: 1)
% 'sparse', fac                    - Verify as sparse, with factor fac (valid factors
%                                    are 64, 32, 16, 8, 4, 2, 1)
% OUTPUTS
% status - -1 if unsuccessful, 0 otherwise
% 
% OPTIONAL OUTPUTS
% vec    - Return the error vector to the caller
% errVec - Return the error vector to the caller. The error vectors is a 3xN matrix, 
%          where N is the number of errors in the test, row 1 is the reference vector
%          value, row 2 the test vector value, and row 3 is the position in the vector
%          stream where the error occured. For test vectors that are agglomerated 
%          (ie: they are testing a non-scalar value in the CAMShift pipeline), the
%          errVec matrix may be a cell array. The purpose in each position of the
%          array is the same, but the number of entries will depend on the vector size
%

% Stefan Wong 2013


	vtype   = 'scalar';
	val     = 1;
	vsparse = 0;
	debug   = false;
	
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'type', 4))
					vtype = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'val', 3))
					val   = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'sparse', 6))
					vsparse = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'scale', 5))
					scale   = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					debug = true;
				end
			end
		end
	end

	%Sanity check what we have
	if(~ischar(vtype))
		fprintf('ERROR: type must be string\n');
		status = -1;
		if(nargout > 1)
			varargout{1} = [];
		end
		return;
	end
	if(exist('scale', 'var'))
		if(ischar(scale))
			if(strncmpi(scale, 'def', 3))
				S_FAC = 256;
			end
		else
			S_FAC = scale;
		end
	else
		S_FAC = 256;	%Most common case, so default to this
	end

	%Perform verification step
	if(strncmpi(vtype, 'row', 3) || strncmpi(vtype, 'col', 3))
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
		%Generate a hue vector to compare against
		[refVec status dims] = genHueVec(V, fh, 'scalar', 1, 'scale', S_FAC);
		if(status == -1)
			fprintf('ERROR: genHueVec() produced badly-formed vector\n');
			status = -1;
			if(nargout > 1)
				varargout{1} = -1;
			end
			vec = [];
			return;
		end
		%Potentially all the elements could be wrong, so over-allocate here and
		%trim the result later
		errVec = zeros(3,length(vec)); 
		numErr = 0;
		%Get a waitbar so that we have some vague notion the process is working
		wb = waitbar(0, 'Name', 'Verifying hue vector');
		for k = 1:length(vec)
			if(refVec(k) ~= vec(k))
				numErr = numErr + 1;
				errVec(:, numErr) = [refVec(k) vec(k) k]';
			end
			waitbar(k/length(vec), wb, ...
			sprintf('Verifying [%s] (%d/%d)', get(fh,'filename'),k, length(vec)));
		end
		delete(wb);

		%Trim errVec
		if(numErr < 1)
			errVec = [];		%turns out the vector was correct
		elseif(numErr < length(errVec))
			errVec = errVec(1:numErr);
		end

		if(nargout > 1)
			%Format stats for caller
		end
		return;
				
	else
		fprintf('ERROR: Not a valid vtype [%s]\n', vtype);		
		status = -1;
		return;
	end





end 	%verifyHueVec
