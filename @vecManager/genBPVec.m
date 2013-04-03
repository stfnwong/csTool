function [vec varargout] = genBPVec(fh, vtype, val)
% GENBPVEC
% vec = genBPVec(fh, vtype, val)
% Generate backprojection vector in either row or column format with variable vector
% size. This function takes the backprojection data stored in the frame handle fh
% and generates a set of backprojection vectors suitable for use with CSoC Verilog 
% testbenches. The style of vector can be specified by passing a vecManager format 
% string (i.e: '16c', '8r', etc). 
%
% The output vec is a cell array, each element of which is a linearized stream for 
% the corresponding element of the input vector (i.e: vec{3} is all instances of the
% third element of each vector). This is done so that the Verilog testbenches can read
% the data for the vectors as a series of linearised streams, which simplifies the 
% test architecture. The size of the output cell array is automatically determined by 
% the formatting string fmt.
%
% ARGUMENTS:
% fh - Frame handle to generate backprojection data for
% fmt - Formatting string
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
% OUTPUTS
% vec - Cell array containing formatted data to be written to disk

% Stefan Wong 2013

	%Get data for vector
	bpimg = vec2bpimg(get(fh, 'bpVec'), get(fh, 'dims'));
	[img_h img_w] = size(bpimg);		%should be 1 channel, so don't need extra d
	
	switch(vtype)
		case 'row'
			
			%Data enters the system serially, so row vectors need to be pulled out 
			%along the row dimension of the image
			rdim = img_w / val;
			vec  = cell(1, rdim);
			t    = rdim * img_h;
			wb   = waitbar(0, sprintf('Generating column vector (0/%d)', t), ...
                              'Name', 'Generating column vector');
			p    = 1;		%Progress counter
			%Extract row vectors
			for n = 1:rdim
				row = zeros(1, img_h * (img_w/rdim));
				for y = 1:img_h
					row(y:*+(img_h/rdim)) = bpimg(y, n:rdim:img_w);
					waitbar(p/t, wb, sprintf('Generating column vector (%d/%d)', ...
                                     p, t);
					p = p+1;
				end
				vec{n} = row;
			end
			delete(wb);
			if(nargout > 1)
				varargout{1} = 0;
			end			
		case 'col'
			%Because data enters serially, we can just pull the whole row out, and 
			%then move down the image by N rows, where N is the size of the vector.
			cdim = img_h / val;
			vec  = cell(1, cdim);
			t    = cdim * img_h;
			wb   = waitbar(0, sprintf('Generating row vector (0/%d)', t), ...
                              'Name', 'Generating row vector');
			p     = 1;	%Progress counter
			%Extract column vectors
			for n = 1:cdim
				col = zeros(1, img_w * (img_h/cdim));
				for y = n:cdim:img_h
					col(y:y*img_w) = bpimg(y, n:img_w);
					waitbar(p/t, wb, sprintf('Generating row vector (%d/%d)', ...
                                     p, t);
					p = p + 1;
				end
				vec{n} = col;
			end
			delete(wb);
			if(nargout > 1)
				varargout{1} = 0;
			end
		case 'scalar'
			%Linearise data into raster
			data = zeros(1, img_w*img_h);
			wb   = waitbar(0, sprintf('Generating raster vector (0/%d)', t), ...
                              'Name', 'Generating raster vector');
			t    = img_w * img_h;
			p    = 1;		%Progress counter
			%Extract raster data
			for y = 1:img_h
				for x = 1:img_w
					data(y,x) = bpimg(y,x);
					waitbar(p/t, wb, sprintf('Generating raster vector (%d/%d)', ...
                                     p, t);
					p = p + 1;
				end
			end
			vec = data;
			delete(wb);
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
