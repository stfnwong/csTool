function status = writeImgVec(V, fh, opts)
% WRITEIMGVEC
% status = writeImgVec(V, fh, opts)
%
% Generic function for writing test vectors to disk
% 
% ARGUMENTS
%
% V    - vecManager object
% fh   - Frame handle or vector of frame handles to generate vector data for
% opts - Structure containing vector generation options. The opts structure
%        contains the following fields
%
%        vtype  : orientation of vector, one of 'row', 'col' or 'scalar'
%        val    : size of vector
%        scale  : scaling factor for image data
%        fname  : filename to write to disk
%
% OUTPUTS
% status - Returns -1 if operation fails, 0 otherwise
%

% Stefan Wong 2013

	if(~isa(fh, 'csFrame'))
		fprintf('ERROR: Invalid frame handle fh\n');
		status = -1;
		return;
	end

	% Do sanity check on options
	if(~isfield(opts, 'vtype') || isempty(opts.vtype))
		opts.vtype = 'scalar';
	end
	if(~isfield(opts, 'val') || isempty(opts.val))
		opts.val   = 0;
	end	
	if(~isfield(opts.scale) || isempty(otps.scale))
		opts.scale = 256;
	end
	% This check might be excessive
	if(~isfield(opts.fname))
		opts.fname = [];
	end
		

	for k = 1:length(fh)

		% Check for filename 
		if(isempty(opts.fname))
			fs = fname_parse(get(fh(k), 'filename'));
			if(fs.exitflag == -1)
				fprintf('ERROR: bad filename [%s] in writeVec\n', get(fh(k), 'filename'));
				status = -1;
				return;
			end
			opts.fname = sprintf('%d.dat', fs.filename, fs.vecNum);
		end

		% Generate correct vector for this type
		switch vecType
			% ==== RGB ==== %
			case 'rgb'
				vec = genRGVec(V, fh(k), opts.vtype, opts.val);
				vecname = sprintf('%s.dat', opts.fname);
				vecDiskWrite(V, vec, 'fname', vecname, 'vsim');
			% ==== HSV === %
			case 'hsv'
				vec = genHueVec(V, fh(k));
				vecname{1} = sprintf('%s-hue.dat', opts.fname);
				vecname{2} = sprintf('%s-sat.dat', opts.fname);
				vecname{3} = sprintf('%s-val.dat', opts.fname);
				vecDiskWrite(V, vec, 'fname', vecnames, 'vsim');
			% ==== HUE ==== %
			case 'hue'
				vec = genHueVec(V, fh(k), opts.vtype, opts.val, 'scale', opts.scale);
				if(strncmpi(opts.vtype, 'scalar', 6))
					vecDiskWrite(V, {vec}, 'fname', {opts.fname}, 'vsim');
				else
					for n = length(vec):-1:1
						vecnames{n} = sprintf('%s-vec%03d.dat', opts.fname);
					end
					vecDiskWrite(V, vec, 'fname', vecnames, 'vsim');
				end
			% ==== BACKPROJECTION ==== %
			case 'bp'
				vec = genBPVec(V, fh(k), opts.vtype, opts.val);
				for n = length(vec):-1:1
					vecnames{n} = sprintf('%s-vec%03d.dat', opts.fname, n);
				end
				vecDiskWrite(V, vec, 'fname', vecnames, 'vsim', '1b');

			otherwise
				fprintf('ERROR: Not a supported vectype [%s]', vecType);
				status = -1;
				return;
		end
	end

	status = 0;
	return;

end 	%writeVec()
