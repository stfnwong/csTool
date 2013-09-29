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
				elseif(strncmpi(varargin{k}, 'imsz',4))
					imsz = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'cp', 2))
					cp   = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'ah', 2))
					ah   = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'filename', 8))
					filename = varargin{k+1};
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
		val = length(vec);
	end
	if(~exist('scale', 'var'))
		S_FAC = 256;
	end
	if(~exist('cp', 'var'))
		cp = 20;			%time in nanoseconds
	end
	if(~exist('filename', 'var'))
		filename = 'errvec-timing-report.txt';
	end

	% Check that this is a valid frame handle
	if(~isa(fh, 'csFrame'))
		fprintf('ERROR: fh not a valid frame handle\n');
		status = -1;
		return;
	end
	% Get backprojection vector
	bpvec = get(fh, 'bpVec');
	if(~exist('imsz', 'var'))
		%Use value in frame handle
		imsz = get(fh, 'dims');
	end
	if(isempty(bpvec))
		fprintf('ERROR: No backprojection data in frame [%s]\n', get(fh, 'filename'));
		status = -1;
		return;
	end
	% Make sure that vector is cell array
	if(~iscell(vec))
		fprintf('ERROR: vec must be cell array\n');
		status = -1;
		return;
	end

	% TODO : Make this method generic, add a case here to choose the reference
	% vector to generate and call the resulting method from csToolVerify()

	[refvec status dims] = genBPVec(V, fh, vtype, val, 'scale', S_FAC); %#ok
	errVec = bpErrVec(V, vec, refvec, 'vtype', vtype, 'imsz', imsz);
	numErr = length(find(errVec > 0));
	fprintf('numErr - %d\n', numErr);
	
	% Write error results to disk
	fp = fopen(filename, 'w');
	if(fp ~= -1)
		errPos = find(errVec > 0)';
		for k = 1 : length(errPos)
			fprintf(fp, '[%d] : err = %f\n', cp*errPos(k), errVec(errPos(k)));
		end
		fclose(fp);
	else
		fprintf('ERROR: Couldn''t open file [%s], skipping report\n', filename);
	end

	% Plot results - if we dont have a figure handle generate one now
	if(~exist('ah', 'var'))
		ah = axes();
	end
	hold on;
	plot(ah, 1:length(vec), vec, 'gx', 'MarkerSize', 8);
	plot(ah, 1:length(refvec), refvec, 'b.', 'MarkerSize', 8);
	plot(ah, 1:length(errVec), 'rx', 'MarkerSize', 8);
	axis tight;
	hold off;
	title('Error Vector');
	xlabel('Pixel');
	ylabel('Error Magnitude');

	status = 0;
	
	
	%if(strncmpi(vtype, 'row', 3) || strncmpi(vtype, 'col', 3))
	%	%Get a reference vector		
	%	[refVec status dims] = genHueVec(V, fh, vtype, val, 'scale', S_FAC);
	%	if(status == -1)
	%		fprintf('ERROR: genHueVec() produced badly-formed vector\n');
	%		if(nargout > 1)
	%			varargout{1} = -1;
	%		end
	%		return;
	%	end
	%	vdim   = dims(1) / val;
	%	vec    = cell(1,rdim);
	%	errVec = cell(1,rdim);
	%	numErr = 0;
	%	%Show a waitbar to indicate progress hasn't stalled
	%	total  = vdim * length(vec{0});		%Total progress
	%	prg    = 0;							%Current progress
	%	wb = waitbar(0, 'Name', 'Verifying Vector...');
	%	for k = 1:vdim
	%		rvec = refVec{k};				
	%		tvec = vec{k};					%test vector for element k
	%		evec = zeros(1,length(rvec));
	%		for n = 1:length(tvec)
	%			if(rvec(n) ~= tvec(n))
	%				numErr  = numErr + 1;
	%				evec(n) = 1;
	%			end
	%			prg = prg + 1;
	%			waitbar(prg/total, wb, sprintf('Verifying (%d/%d)', prg, total));
	%		end
	%		errVec{k} = evec;
	%	end
	%	delete(wb);

	%	if(nargout > 1)
	%		%Format stats for output
	%	end
	%elseif(strncmpi(vtype, 'scalar', 6))
	%	% Get a reference vector
	%	[refVec status dims] = genHueVec(V, fh, vtype, val, 'scale', S_FAC);
	%else
	%	fprintf('ERROR: Not a valid vtype [%s]\n', vtype);
	%	status = -1;
	%	return;
	%end	

end 	%verifyBPVec()
