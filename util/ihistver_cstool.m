function [ihist varargout] = ihistver_cstool(ifile, bufsize, opts)
% IHISTVER_CSTOOL
% csTool implementation of ihist_verify()
%

% Stefan Wong 2013

	%Get options from structure
	VERBOSE = opts.verbose;
	bmin    = opts.bmin;
	nbins   = opts.nbins;
	bwidth  = opts.bwidth;
	refdata = opts.refdata;
	delim   = opts.delim;

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

	[hist_data hpos] = textscan(finp, '%u8', 'Delimiter', delim);
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

end 	%ihistver_cstool()
