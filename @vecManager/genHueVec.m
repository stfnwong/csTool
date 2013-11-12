function [vec varargout] = genHueVec(V, fh, vtype, val, varargin) %#ok<INUSL>
% GENHUEVEC
% vec = genHueVec(fh, vtype, val)
% Generate hue vector for the frame handle fh.
%
% This function takes the frame stored in frame handle fh and generates a hue vector 
% for use in CSoC Verilog testbenches. The orientation and size of the hue vectors is
% determined by the formatting string fmt, where fmt is a vecManager formatting string
% (see section FORMATTING ARGUMENTS)
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
% OUTPUTS
% vec    - Cell array containing formatted data to be written to disk
% status - (Optional) -1 if unsuccessful, 0 otherwise
% dims   - (Optional) dimensions of hue_img (appears in nargout{2})

% Stefan Wong 2013

%CHANGES: MLINT warning about V argument was suppressed, so that this
%function is identified as part of vecManager class
% TODO: The documentation is out of date - the fmt string has been replaced by vtype
% and val arguments (see code for details)

	%SCALE_HUE = false;
	
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'scale', 5))
					scale = varargin{k+1};
				end
			end
		end
	end

	%Check optional arguments
	if(exist('scale', 'var'))
		if(ischar(scale))
			if(strncmpi(scale, 'def', 3))
				S_FAC = 256;		%default scaling factor
			end
		else
			S_FAC = scale;
		end
	end

	%Get data for vector
	hsv_img = rgb2hsv(imread(get(fh, 'filename'), 'TIFF'));
	hue_img = hsv_img(:,:,1);
	if(exist('S_FAC', 'var'))
		%hue_img = hue_img .* S_FAC;
        hue_img = fix(hue_img .* S_FAC);
	end 
	[img_h img_w] = size(hue_img);
	
	switch(vtype)
		case 'row'
			%Data enters the system serially, so row vectors need to be pulled out 
			%along the row dimension of the image
			rdim = img_w / val;
			vec  = cell(val, 1);
			t    = rdim * img_h;
			wb   = waitbar(0, sprintf('Generating column vector (0/%d)', t), ...
                              'Name', 'Generating column vector');
			p    = 1;		%Progress counter
			%Extract row vectors
			for n = 1 : val
				row  = zeros(1, img_h * (img_w/rdim));
                ridx = 1;
				for y = 1 : img_h
                    %TODO: check this expression
					%row(y:y+(img_h/rdim)) = hue_img(y, n:rdim:img_w);
                    row(ridx:ridx+numel(n:rdim:img_w)-1) = hue_img(y, n:rdim:img_w);
					waitbar(p/t, wb, sprintf('Generating column vector (%d/%d)', ...
                                     p, t));
					p = p+1;
                    ridx = rdix + numel(n:rdim:img_w);
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
			cdim = fix(img_h / val);
			vec  = cell(val, 1);
			t    = cdim * (img_h/cdim);
			wb   = waitbar(0, sprintf('Generating row vector (0/%d)', t), ...
                              'Name', 'Generating row vector');
			p     = 1;	%Progress counter
			%Extract column vectors
			for n = 1 : val
				col = zeros(1, cdim * img_w);
                idx = 0;
				for y = n : val : img_h
					%col(cidx:(cidx+img_w)) = hue_img(y, :);
					col(idx*img_w+1 : (idx+1)*img_w) = hue_img(n, 1:img_w);
					waitbar(p/t, wb, sprintf('Generating row vector (%d/%d)', ...
                                     p, t));
					idx = idx + 1;
					p   = p + 1;
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
            t    = img_w * img_h;
			wb   = waitbar(0, sprintf('Generating raster vector (0/%d)', t), ...
                              'Name', 'Generating raster vector');
			p    = 1;		%Progress counter
			%Extract raster data
			for y = 1:img_h
				for x = 1:img_w
					data(p) = hue_img(y,x);
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

	%Check if we want to send dims back to caller
	if(nargout > 2)
		varargout{2} = [img_w img_h];
	end

end 	%genHueVec()
