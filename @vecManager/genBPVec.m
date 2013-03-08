function vec = genBPVec(data, opts)
% GENBPIMGVEC
% Generate backprojection image test data from bpimg. This method takes the 
% data in bpImg and transforms it into a format suitable for importing into a
% testbench for module verification. The data in bpimg is expected to be a 
% matrix of dimension H x W, where H and W are the height and width of the 
% backprojection image respectively (if a vector is used during testing, call
% bpvec2img() on it first). Formatting arguments can be optionally specified.
%
% ARGUMENTS:
% V - vecManager object
% bpImg - Backprojection image to generate test data from 
%
% FORMATTING ARGUMENTS
% Pass the string 'fmt' followed by a string containing one of the following 
% format codes 
%
% - '16c', '8c', '4c' : 16, 8, or 4 element column vectors
% - '16r', '8r', '4r' : 16, 8, or 4 element row vectors
% - 'scalar'          : Single pixel per element 
% 
% If no format code is specified, genBpImgVec() uses the character code found
% in V.bpvecFmt
%

% Stefan Wong 2012

	if(isempty(opts.val))
		val = 16;
	else
		val     = opts.val;
	end
	if(isempty(opts.type))
		type = 'row';
	else
		type    = opts.type;
	end
	%data    = vec2bpimg(get(fh, 'bpData'));
	[h w d] = size(data);
	
	switch(type)
		case 'row'
			rdim = w/val; 
			vec  = cell(h, rdim);
			for y = 1:h
				for x = 1:rdim
					vec{y,x} = data(y, x:x+val);
				end
			end
		case 'col'
			cdim = h/val;
			vec  = cell(cdim, w);
			for x = 1:w
				for y = 1:cdim;
					vec{y,x} = data(y:y+val, x);
				end
			end
		case 'scalar'
			%unroll data
			vec = zeros(1, h*w);
			k   = 1;
			for x = 1:w
				for y = 1:h
					vec(k) = data(y,x);
					k = k+1;
				end
			end
		otherwise
			%probably never get here, but just in case
			error('Invalid direction (SOMEHOW?!?!)');
	end	

end 	%genBpImgVec() 

