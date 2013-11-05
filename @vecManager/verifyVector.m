function [status varargout] = verifyVector(V, fh, vec, opts, varargin)
% VERIFYVECTOR
% Generic routine to generate error vectors from testbench data.
% [status (..OPTIONS..)] = verifyVector(V, fh, vec, [..OPTIONS..])
%

% Stefan Wong 2013

	debug   = false;
	vsparse = false;



	% TODO : Replace this with options structure
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
				elseif(strncmpi(varargin{k}, 'vectype', 7))
					vectype = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'debug', 5))
					debug   = true;
				end
			end
		end
	end

	% Check options contents
	if(~isfield(opts, 'vtype') || isempty(opts.vtype))
		opts.vtype = 'scalar';
	end
	if(~isfield(opts, 'val') || isempty(opts.val))
		opts.val = length(vec);
	end
	if(~isfield(opts, 'scale') || isempty(opts.scale))
		opts.scale = 256;
	end
	if(~isfield(opts, 'cp') || isempty(opts.cp))
		opts.cp = 20;		%time in nanoseconds
	end
	if(~isfield(opts, 'filename') || isempty(opts.filename))
		opts.filename = 'errvec-timing-report.txt';
	end
	if(~isfield(opts, 'vectype') || isempty(opts.vectype))
		opts.vectype = 'backprojection';
	end
	% If no axis handle field, add an empty entry
	if(~isfield(opts, 'ah'))
		opts.ah = [];
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
	if(~exist('vectype', 'var'))
		vectype = 'backprojection';
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

	switch(vectype)
		case 'RGB'
			[refvec status dims] = genRGBVec(V, fh, vtype, val, 'scale', S_FAC); %#ok
			errVec = genErrVec(V, vec, refvec, 'vtype', vtype, 'imsz', imsz);
		case 'HSV'
			[refvec status dims] = genHSVVec(V, fh, vtype, val, 'scale', S_FAC);
		case 'Hue'
			[refvc status dims] = genHueVec(V, fh, vtype, val, 'scale', S_FAC);
		case 'backprojection'
			[refvec status dims] = genBPVec(V, fh, vtype, val, 'scale', S_FAC); %#ok
			%errVec = bpErrVec(V, vec, refvec, 'vtype', vtype, 'imsz', imsz);
			%numErr = length(find(errVec > 0));
			fprintf('numErr - %d\n', numErr);
	end

	% TODO : Finish genericising this method
	errVec = genErrVec(V, vec, refvec, 'vtype', vtype, 'imsz', imsz);
	
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

end 	%verifyVector()
