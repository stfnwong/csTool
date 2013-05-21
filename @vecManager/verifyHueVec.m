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
	switch(vtype)
		% Data stream coming out of testbenches should be a series of scalar pixel 
		% values. The vector will be split across multiple files, and pointer will
		% advance each stream (ie: each vector element) simultaneously. 
		case 'row'
			[refVec status dims] = genHueVec(V, fh, vtype, val, 'scale' S_FAC);
			if(status == -1)
				fprintf('ERROR: genHueVec() produced badly-formed vector\n');
				if(nargout > 1)
					varargout{1} = -1;
				end
				vec = [];
				return;
			end
			%dims should have format [w h]
			rdim = dims(1) / val;
			vec  = cell(1,rdim);


		case 'col'
			[refVec status dims] = genHueVec(V, fh, vtype, val, 'scale', S_FAC);
			if(status == -1)
				fprintf('ERROR: genHueVec() produced badly-formed vector\n');
				if(nargout > 1)
					varargout{1} = -1;
				end
				vec = [];
				return;
			end
			cdim   = dims(2) / val;
			vec    = cell(1,cdim);
			errVec = cell(1,cdim);		%trim this array at the end of operation 
			for k = 1:cdim
				%Extract current cell from reference array and compare to elements 
				%of the test array 
			end

		case 'scalar'
			%Generate a hue vector to compare against
			[refVec status dims] = genHueVec(V, fh, 'scalar', 1, 'scale', S_FAC);
			if(status == -1)
				fprintf('ERROR: genHueVec() produced badly-formed vector\n';
				if(nargout > 1)
					varargout{1} = -1;
				end
				vec = [];
				return;
			end
			%TODO: Further massaging here
			errVec = zeros(1,length(vec));
			numErr = 0;
			for k = 1:length(vec)
				if(refVec(k) ~= vec(k))
					numErr = numErr + 1;
					errVec(numErr) = 1;
				end
			end
	
			%Trim errVec
			if(numErr < 1)
				errVec = [];
			elseif(numErr < length(errVec))
				errVec = errVec(1:numErr);
			end
				
			
		otherwise
			fprintf('ERROR: Invalid type %s\n', vtype);
	end





end 	%verifyHueVec
