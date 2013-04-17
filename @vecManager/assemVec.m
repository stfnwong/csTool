function img = assemVec(vectors, varargin)
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
	if(~iscell(vectors))
		fprintf('ERROR: vectors must be cell array\n');
		img = [];
		return;
	end

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
		imSz = [640 480];
	end

	%Take the data and place into image array
	img = zeros(imSz(2), imSz(1));
	
	switch vecFmt
		case 'row'
			for k = 1:vecSz
				vk = vectors{k};
				i  = 0;
				for n = 1:vecSz:(imSz(1) / vecSz)
					img(:,n) = vk(i*imSz(1)+1:(2*i)*imSz(1));
					i = i +1;
				end
			end
					
		case 'col'
			for k = 1:vecSz
				vk = vectors{k};
				i  = 0;
				for n = 1:vecSz:(imSz(2) / vecSz)
					img(n,:) = vk(i*imSz(2)+1:(2*i)*imSz(2));
					i = i + 1;
				end
			end
		otherwise
			fprintf('ERROR: Not a valid vecFmt (%s)\n', vecFmt);
			img = [];
			return;
	end

end 	%assemVec()
