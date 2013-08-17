function [ihist varargout] = ihist_generate(data, varargin)
% IHIST_GENERATE
% Generate image histogram blocks with memory constraints from FPGA
%
% ihist = ihist_generate(data, [..OPTIONS..])
%

% Stefan Wong 2013

	VERBOSE = false;

	if(~isempty(varargin))
		for k = 1 : length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'ver', 3))
					VERBOSE = true;
				elseif(strncmpi(varargin{k}, 'nbins', 5))
					nbins = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bwidth', 6))
					bwidth = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bufsize', 7))
					bufsize = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'boffset', 7))
					boffset = varargin{k+1};
				end
			end
		end
	end

	%Check what we have
	if(~exist('nbins', 'var'))
		nbins = 16;
	end
	if(~exist('bwidth', 'var'))
		bwidth = 16;
	end
	if(~exist('bufsize', 'var'))
		bufsize = 128;
		if(VERBOSE)
			fprintf('WARNING: Using default bufsize (%d)\n', bufsize);
		end
	end
	if(~exist('boffset', 'var'))
		boffset = 0;
	end
	if(VERBOSE)
		if(boffset > 0)
			fprintf('WARNING: First bin starts at %d\n', boffset);
		end
	end

	bEdge = boffset:bwidth:(nbins*width);
	if(VERBOSE)
		fprintf('Histogram range : [%d - %d]\n', boffset, (nbins*width));
	end

	if(mod(length(data), bufsize) ~= 0)
		fprintf('ERROR: bufsize (%d) must be multiple of data stream length (%d)\n', bufsize, length(data));
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

	% Split stream into blocks and generate histogram
	hdata = cell(1, fix(length(data) / bufsize));	
	ihist = cell(1, fix(length(data) / bufsize));
	
	for k = 1 : length(hdata)
		hdata{k} = data((k-1)*bufsize+1:k*bufsize);
		ihist{k} = histc(hdata{k}, bEdge);
	end	

	if(nargout > 1)
		varargout{1} = hdata;
	end	


end 	%ihist_generate()
