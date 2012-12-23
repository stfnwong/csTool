function data = genBpImgData(V, bpImg, varargin)
% GENBPIMGDATA
%
% data = genBpImgData(V, bpImg, ... [optional format arguments] );
%
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
% OPTIONAL FORMATTING ARGUMENTS
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

%Parse arguments
	if(nargin > 1)
		if(ischar(varargin{1}))
			if(strncmpi(varargin{1}, 'fmt', 3))
				fmt = varargin{2};
			end
		else
			error('Expecting type char in varargin{1}');
		end
	else
		fmt = V.bpvecFmt;
	end

	switch(fmt)
		case '16c'
			type = 'col';
			val  = 16;
		case '8c' 
			type = 'col';
			val  = 8;
		case '4c'
			type = 'col';
			val  = 4;
		case '16r' 
			type = 'row';
			val  = 16;
		case '8r'
			type = 'row';
			val  = 8;
		case '4r'
			type = 'row';
			val  = 4;
		case 'scalar'
			type = 'scalar';
		otherwise
			error('Invalid formatting code');
	end
	
	switch(type)
		case 'row'
			rdim = w/val; 
			vec  = cell(h, rdim);
			for y = 1:h
				for x = 1:rdim
					vec{y,x} = data(y, x:x+val)
				end
			end
		case 'col'
			cdim = h/val;
			vec  = cell(rdim, w);
			for x = 1:w
				for y = 1:cdim;
					vec{y,x} = data(y:y+val, x);
				end
			end
		case 'scalar'
			vec = data;
		otherwise
			%probably never get here, but just in case
			error('Invalid direction');
	end

		



end 	%genBpImgVec()
