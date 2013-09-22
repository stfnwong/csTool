function vec = vecGen(img, varargin)
% VECGEN
% Generate vectors for use with assemTest(0
% 

% Stefan Wong 2013

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'vecfmt', 6))
					vtype = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'vecsz', 5))
					val = varargin{k+1};
				end
			end
		end
	end

	if(~exist('vtype', 'var'))
		vtype = 'row';
	end
	if(~exist('val','var'))
		val = 16;
	end

	% Show options in console
	fprintf('(vecGen) : vtype : %s\n', vtype);
	fprintf('(vecGen) : val   : %d\n', val);

	[img_h img_w] = size(img);		%should be 1 channel, so don't need extra d
	
	switch(vtype)
		case 'row'
			%Data enters the system serially, so row vectors need to be pulled out 
			%along the row dimension of the image
			rdim = fix(img_w / val);
			vec  = cell(val, 1);
			%Bookkeeping for waitbar
			t    = rdim * (img_h / rdim);
			p    = 1;				%progress counter
			wb   = waitbar(0, sprintf('Generating row vector (0/%d)', t));

			for k = 1:length(vec)
				vk = zeros(1, rdim * img_h);
				n  = 1;
				for y = 1:img_h
					for x = k:val:img_w
						vk(n) = img(y,x);
						n     = n + 1;
					end
				end
				vec{k} = vk;
				waitbar(p/t, wb, sprintf('Generating row vector (%d/%d)', p, t));
			end
			delete(wb);

		case 'col'
			cdim = fix(img_h / val);
			vec  = cell(val, 1);
			% Bookkeeping for waitbar
			t    = cdim * (img_w / cdim);
			p    = 1;		%progress counter
			wb   = waitbar(0, sprintf('Generating col vector (0/%d)', t));
			for v = 1 : val
				%Need to compute start and end row for vector 
				idx     = 0;
                cur_col = zeros(1, cdim * img_w);
				for n = v : val : img_h
                    cur_col(idx*img_w+1 : (idx+1)*img_w) = img(n, 1:img_w);
					idx = idx + 1;
					waitbar(p/t, wb, sprintf('Generating col vector (%d/%d)', ...
						    p,t));
					p = p + 1;
				end
                vec{v} = cur_col;
			end
			delete(wb);

		case 'scalar'
			%Linearise data into raster
			data = zeros(1, img_w*img_h);
			%t    = img_w * img_h;
			t    = img_w;
			wb   = waitbar(0, sprintf('Generating raster vector (0/%d)', t), ...
                              'Name', 'Generating raster vector');
			p    = 1;		%Progress counter
			for y = 1:img_h
				data((y-1)*img_w+1:y*img_w) = img(y,:);
				waitbar(y/t, wb, sprintf('Generating raster vector (%d/%d)...', ...
					   p, t));
			end
			vec    = cell(1,1);
			vec{1} = data;
			delete(wb);

		otherwise
			fprintf('ERROR: (%s) not a valid orientation\n', orientation);
			return;
	end


end 	%vecGen()
