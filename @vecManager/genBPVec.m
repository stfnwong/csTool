function [vec varargout] = genBPVec(V, fh, vtype, val) %#ok
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
	bpimg         = vec2bpimg(get(fh, 'bpVec'), get(fh, 'dims'));
	[img_h img_w] = size(bpimg);		%should be 1 channel, so don't need extra d
	
	switch(vtype)
		case 'row'
			%Data enters the system serially, so row vectors need to be pulled out 
			%along the row dimension of the image
			rdim = img_w / val;
			vec  = cell(val, rdim * img_w);
			%Bookkeeping for waitbar
			t    = img_w * rdim;
			p    = 1;				%progress counter
			wb   = waitbar(0, sprintf('Generating row vector (0/%d0', t));
			for v = 1:val
				idx = 0;
				for n = 1:img_h
					vec{v, (idx*rdim+1 : (idx+1)*rdim)} = bpimg(n, v:val:img_w);
					idx = idx + 1;
					%Update waitbar
					waitbar(p/t, wb, sprintf('Generating row vector (%d/%d)', ...
						    p, t));
					p = p + 1;
				end
			end
			delete(wb);
			if(nargout > 1)
				varargout{1} = 0;
			end
		case 'col'
			cdim = img_h / val;
			vec  = cell(val, cdim * img_w);
			% Bookkeeping for waitbar
			t    = cdim * img_w;
			p    = 1;		%progress counter
			wb   = waitbar(0, sprintf('Generating col vector (0/%d)', t));
			for v = 1 : val
				%Need to compute start and end row for vector 
				idx = 0;
				for n = v : val : img_h
					% RHS has too few values to satisfy LHS
					vec{v, (idx*img_w+1 : (idx+1)*img_w)} = bpimg(n, 1:img_w);
					idx = idx + 1;
					%Update waitbar
					waitbar(p/t, wb, sprintf('Generating row vector (%d/%d)', ...
						    p,t));
					p = p + 1;
				end
			end
			delete(wb);
			if(nargout > 1)
				varargout{1} = 0;
			end
		case 'scalar'
			%Linearise data into raster
			data = zeros(1, img_w*img_h);
			t    = img_w * img_h;
			wb   = waitbar(0, sprintf('Generating raster vector (0/%d)', t), ...
                              'Name', 'Generating raster vector');
			p    = 1;		%Progress counter
			%Extract raster data
			for y = 1:img_h
				for x = 1:img_w
					data(y,x) = bpimg(y,x);
					waitbar(p/t, wb, sprintf('Generating raster vector (%d/%d)', ...
                                     p, t));
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
