function [vec varargout] = genBPVec(V, bpimg, vtype, val, varargin) %#ok
% GENBPVEC
% vec = genBPVec(bpimg, vtype, val)
% Generate backprojection vector in either row or column format with 
% variable vector size. This function takes the backprojection data from 
% the parameter bpimg and generates a set of backprojection vectors 
% suitable for use with CSoC Verilog testbenches. The style of vector can 
% be specified by passing a vecManager format string (i.e: '16c', '8r', etc). 
%
% The output vec is a cell array, each element of which is a linearized 
% stream for the corresponding element of the input vector (i.e: vec{3} is 
% all instances of the third element of each vector). This is done so that 
% the Verilog testbenches can read the data for the vectors as a series of 
% linearised streams, which simplifies the test architecture. The size of 
% the output cell array is automatically determined by 
% the formatting string fmt.
%
% ARGUMENTS:
% bpimg - Backprojection image to generate vector from
% fmt   - Formatting string
%
% FORMATTING ARGUMENTS
% Pass the string 'fmt' followed by a string containing one of the following 
% format codes 
%
% - '16c', '8c', '4c' : 16, 8, or 4 element column vectors
% - '16r', '8r', '4r' : 16, 8, or 4 element row vectors
% - 'scalar'          : Single pixel per element 
% 
% If no format code is specified, genBpImgVec() uses the character code 
% found in V.bpvecFmt
%
% OUTPUTS
% vec - Cell array containing formatted data to be written to disk

% Stefan Wong 2013

	%Get data for vector
	%bpimg         = vec2bpimg(get(fh, 'bpVec'), 'dims', get(fh, 'dims'));
	[img_h img_w] = size(bpimg);%should be 1 channel, so don't need extra d
	
	switch(vtype)
		case 'row'
			%Data enters the system serially, so row vectors need to be 
			%pulled out along the row dimension of the image
			rdim = fix(img_w / val);
			vec  = cell(val, 1);
			for k = 1 : length(vec)
				vk = zeros(1, rdim*img_h);
				n  = 1;
				for y = 1 : img_h
					for x = k:val:img_w
						vk(n) = bpimg(y,x);
						n = n + 1;
					end
				end
				vec{k} = vk;
			end
			if(nargout > 1)
				varargout{1} = 0;
			end

		case 'col'
			cdim = fix(img_h / val);
			vec  = cell(val, 1);
			for v = 1 : val
				%Need to compute start and end row for vector 
				idx     = 0;
                cur_col = zeros(1, cdim * img_w);
				for n = v : val : img_h
                    cur_col(idx*img_w+1 : (idx+1)*img_w) = bpimg(n, 1:img_w);
					idx = idx + 1;
				end
                vec{v} = cur_col;
			end
			if(nargout > 1)
				varargout{1} = 0;
			end

		case 'scalar'
			%Linearise data into raster
			data = zeros(1, img_w*img_h);
			for y = 1:img_h
				data((y-1)*img_w+1:y*img_w) = bpimg(y,:);
			end
			vec    = cell(1,1);
			vec{1} = data;
			if(nargout > 1)
				varargout{1} = 0;
			end

		otherwise
			fprintf('ERROR: (%s) not a valid orientation\n', orientation);
			if(nargout > 1)
				varargout{1} = -1;
			end
			return;
	end

end 	%genBPVec()
