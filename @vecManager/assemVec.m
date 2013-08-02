function img = assemVec(V, vectors, varargin)
% ASSEMVEC
% img = assemVec(vectors, [..OPTIONS..])
%
% Assemble vector components back into image. 
%
% ARGUMENTS
% vectors - Cell array containing vector file contents from disk. 
%
% (OPTIONAL ARGUMENTS)
% vecFmt  - Format to use for vector. Legal values are 'row', 'col', and 'scalar'. If
%           no format parameter specified, row is used as default.
% imSz    - Size of image to recover. If no parameter is specified, 640x480 is used.
%
%

% Stefan Wong 2013

	DEBUG = false;
	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'debug', 5))
					DEBUG = true;
				elseif(strncmpi(varargin{k}, 'imsz', 4))
					imSz  = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'vecfmt', 6))
					vecFmt = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'vecsz', 5))
					%No idea why I would want to set this, so its undocumented
					vecSz  = varargin{k+1};		
				end
			end
		end
	end

	%Check what we have
	if(~exist('vecSz', 'var'))
		vecSz = length(vectors);
	else
		%Even though this is a stupid option, we still ought to do a basic check
		if(vecSz > length(vectors))
			vecSz = length(vectors);
		end
	end
	if(~exist('vecFmt', 'var'))
		vecFmt = 'row';
	end
	if(~exist('imSz', 'var'))
		fprintf('WARNING: Using default image size of 640x480\n');
		imSz = [640 480];
	end

	%If the vectors parameter isn't a cell array, this must be an image stream, and
	%therefore the vecFmt parameter should be scalar
	if(~iscell(vectors))
		vecFmt = 'scalar';
	else
		%Format cell array for processing
	end

	%Take the data and place into image array (WxH)
	img = zeros(imSz(2), imSz(1));

	switch vecFmt
		case 'row'
			% NOTE : For row orientation, there is the problem of jumping over the (currently) 
			if(~iscell(vectors))
				fprintf('ERROR: vectors must be cell array\n');
				img = [];
				return;
			end
            % NOTE : We can probaby take advantage of the fact that we have
            % all the vectors available to us in memory and just write the 
            % pattern into the image array column-wise
			% unused column entries until vectors{k+1} is read.
			for k = 1 : length(vectors)
				vk   = vectors{k};
				cidx = 0;
				%TODO : Try get rid of double nested loop here
				for y = k:vecSz:imSz(1)
                    

				end
			end
		case 'col'
			if(~iscell(vectors))
				fprintf('ERROR: vectors must be cell array\n');
				img = [];
				return;
			end
            wb = waitbar(0, 'Assembling column vectors...', 'Name', 'Assembling column vectors');
			for k = 1 : length(vectors)
				vk   = vectors{k};
				ridx = 0;
				for n = k:vecSz:imSz(2)
					img(n,:) = vk(ridx*imSz(1)+1 : (ridx+1)*imSz(1));
                    ridx = ridx + 1;
				end
                waitbar(k/length(vectors), wb, sprintf('Assembling column vector (%d/%d)', k, length(vectors)));
			end
            delete(wb);

		case 'scalar'
			%Take a serialised vector and lay it out in raster form, wrapping the 
			%dimensions based on imSz parameter. If we get to there and the vectors
			%parameter is a cell array, then exit early (we could extract the first
			%thing in the cell array and try it, but we have no idea what the contents
			%would be.)
			if(iscell(vectors))
				fprintf('ERROR: scalar option requires non-cell array argument\n');
				img = [];
				return;
			end	
			n = 1;
			for y = 1:imSz(2)
				for x = 1:imSz(1)
					img(y,x) = vectors(n);
					n = n +1;
				end
			end
		otherwise
			fprintf('ERROR: Invalid vector format %s\n', vecFmt);
			img = [];
			return;	
	end

	%switch vecFmt
	%	case 'row'
	%		for k = 1:vecSz
	%			vk = vectors{k};
	%			i  = 0;
	%			%for n = 1:vecSz:(imSz(1) / vecSz)
	%			%	img(:,n) = vk(i*imSz(1)+1:(2*i)*imSz(1));
	%			%	i = i +1;
	%			%end
	%		end
	%
	%	case 'col'
	%		for k = 1:vecSz
	%			vk = vectors{k};
	%			i  = 0;
	%			for n = 1:vecSz:(imSz(2) / vecSz)
	%				img(n,:) = vk(i*imSz(2)+1:(i+1)*imSz(2));
	%				i = i + 1;
	%			end
	%		end
	%	case 'scalar'
	%		%Take a serialised vector and lay it out in raster form, wrapping the 
	%		%dimensions based on imSz parameter. If we get to there and the vectors
	%		%parameter is a cell array, then exit early (we could extract the first
	%		%thing in the cell array and try it, but we have no idea what the contents
	%		%would be.
	%		if(iscell(vectors))
	%			fprintf('ERROR: scalar option requires non-cell array argument\n');
	%			img = [];
	%			return;
	%		end	
	%		n = 1;
	%		for y = 1:imSz(2)
	%			for x = 1:imSz(1)
	%				img(y,x) = vectors(n);
	%				n = n +1;
	%			end
	%		end
	%	otherwise
	%		fprintf('ERROR: Not a valid vecFmt (%s)\n', vecFmt);
	%		img = [];
	%		return;
	%end

end 	%assemVec()
