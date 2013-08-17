function [ihist varargout] = ihist_verify(ifile, bufsize, varargin)
% IHIST_VERIFY
% Verify the image histogram contents in histogram backprojection pipeline.
%
% [ihist (..OPTIONAL..)] = ihist_verify(ifile, bufsize, [..OPTIONS..])
%

% Stefan Wong 2013
	
	VERBOSE = false;
	DISPLAY = false;

	if(~isempty(varargin))
		for k = 1:length(varargin)
			if(ischar(varargin{k}))
				if(strncmpi(varargin{k}, 'verbose', 7) || ...
		           strncmpi(varargin{k}, 'ver', 3))
					VERBOSE = true;
				elseif(strncmpi(varargin{k}, 'disp', 4))
					DISPLAY = true;
				elseif(strncmpi(varargin{k}, 'bmin', 4))
					bmin = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'nbins', 4))
					nbins = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'bwidth', 5))
					bwidth = varargin{k+1};
				elseif(strncmpi(varargin{k}, 'ref', 3))
					refdata = varargin{k+1};
				end				
			end
		end
	end

	if(~exist('nbins', 'var'))
		nbins = 16;
	end
	if(~exist('bmin', 'var'))
		bmin = 0;
	end
	if(~exist('bwidth', 'var'))
		bwidth = 16;
	end
	if(exist('refdata', 'var') && ~iscell(refdata))
		fprintf('ERROR: reference data must be cell array\n');
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

	edges = bmin:bwidth:(bwidth*nbins)-1;

	%Try to open input file
	finp = fopen(ifile, 'r');
	if(finp == -1)
		fprintf('ERROR: Couldn''t open file [%s]\n', ifile);
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

	[hist_data hpos] = textscan(finp, '%u8 ');
    hist_data = cell2mat(hist_data);
	if(hpos < bufsize)
		fprintf('ERROR: Not enough elements to fill buffer (bufsize must be > %d)\n', hpos);
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

	% Check that buffer size is a multiple of file length
	if(mod(hpos, bufsize) ~= 0)
		fprintf('ERROR: bufsize (%d) not a multple of file length (%d)\n', bufsize, hpos);
		if(nargout > 1)
			varargout{1} = -1;
		end
		return;
	end

	ihist = cell(1, fix(length(hist_data)/bufsize));
	
	for k = 1 : length(ihist)
		htemp = hist_data((k-1)*bufsize+1 : k*bufsize);
		if(VERBOSE)
			fprintf('Computing histogram %d of %d\n', k, length(ihist));
		end
		ihist{k} = histc(double(htemp), edges);
		%Do any additional processing here
	end

	if(exist('refdata', 'var'))
		%Compare hist data from disk to reference data
		if(length(refdata) ~= length(ihist))
			fprintf('ERROR: refdata length (%d) does not match ihist length (%d)\n', length(refdata), length(ihist));
			if(nargout > 1)
				varargout{1} = -1;
			end
			return;
		end
		%Test each histogram
		ehist = cell(1, length(refdata));
		for k = 1 : length(refdata)
			rh = refdata{k};
			ih = ihist{k};	
			errHist = abs(rh - ih);
			if(sum(errHist) > 0)
				ehist{k} = errHist;
				if(VERBOSE)
					fprintf('ERROR: Histogram %d of %d doesn''t match\n', k, length(refdata));
				end
			else
				if(VERBOSE)
					fprintf('Histogram %d / %d matches reference data\n', k, length(refdata));
				end
				ehist{k} = [];
			end
		end
		%Return error array if requested
		if(nargout == 3)
			varargout{2} = ehist;
		end
	end

	if(DISPLAY)
		fprintf('Histogram contents :\n');
		for k = 1:length(ihist)
			fprintf('Cycle %3d:', k);
			disp(ihist{k}');
		end
	end

	if(nargout > 1)
		varargout{1} = length(hist_data);
	end

end 	%ihist_verify()
